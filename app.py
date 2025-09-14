import os
import sqlite3
from collections import defaultdict
from contextlib import closing
from flask import Flask, render_template, request, abort, jsonify, redirect, url_for, session

DB_PATH = "controle_curricular.sqlite"
app = Flask(__name__)
app.secret_key = "dev-secret"

NUCLEO_COLORS_PASTEL = {
    "Básico":              "#F2F3F5",  # cinza bem claro
    "Instrumentação":      "#FFE8D6",  # laranja pastel
    "Controle":            "#DCEBFF",  # azul pastel
    "Automação":           "#E6F4EA",  # verde pastel
    "Gestão e Normativas": "#E5E7EB",  # cinza um pouco mais forte
    None:                  "#F8F9FA",  # fallback
}

NUCLEO_COLORS_VIVID = {
    "Básico":              "#E0E0E0",  # cinza claro, mas mais marcado que #F2F3F5
    "Instrumentação":      "#FFD2A6",  # laranja pastel mais vivo
    "Controle":            "#B3D4FF",  # azul mais saturado
    "Automação":           "#BEEBC2",  # verde mais vivo
    "Gestão e Normativas": "#CFCFCF",  # cinza mais forte que o "Básico"
    None:                  "#F2F2F2",  # fallback
}


def load_status_map(user_id: int | None) -> dict[int, str]:
    """Retorna {course_id: status_prioritário} para o usuário (CONCLUIDO > ATUAL > PLANEJADO > ...)."""
    if not user_id:
        return {}
    prio = {"CONCLUIDO": 3, "ATUAL": 2, "PLANEJADO": 1,
            "APROVEITADO": 3, "REPROVADO": 1, "TRANCADO": 1}
    out = {}
    with closing(conn()) as c:
        rows = c.execute("""
            SELECT course_id, status
            FROM user_course
            WHERE user_id=?
            ORDER BY created_at DESC
        """, (user_id,)).fetchall()
    for r in rows:
        cid, st = r["course_id"], r["status"]
        if cid not in out or prio.get(st, 0) > prio.get(out[cid], 0):
            out[cid] = st
    return out


def load_prereqs_map(course_ids: list[int]) -> dict[int, list[int]]:
    if not course_ids:
        return {}
    placeholders = ",".join("?" * len(course_ids))
    with closing(conn()) as c:
        rows = c.execute(f"""
            SELECT course_id, related_course_id
              FROM course_requirement
             WHERE type='PR'
               AND course_id IN ({placeholders})
        """, course_ids).fetchall()
    mp = defaultdict(list)
    for r in rows:
        mp[r["course_id"]].append(r["related_course_id"])
    return mp


def load_coreqs_maps(course_ids: list[int]) -> tuple[dict[int, list[int]], dict[int, list[int]]]:
    if not course_ids:
        return {}, {}
    placeholders = ",".join("?" * len(course_ids))
    with closing(conn()) as c:
        rows = c.execute(f"""
            SELECT course_id, related_course_id
              FROM course_requirement
             WHERE type='CO'
               AND (course_id IN ({placeholders}) OR related_course_id IN ({placeholders}))
        """, (*course_ids, *course_ids)).fetchall()
    fwd, rev = defaultdict(list), defaultdict(list)
    for r in rows:
        fwd[r["course_id"]].append(r["related_course_id"])
        rev[r["related_course_id"]].append(r["course_id"])
    return fwd, rev


def conn():
    c = sqlite3.connect(DB_PATH)
    c.row_factory = sqlite3.Row
    c.execute("PRAGMA foreign_keys=ON;")
    return c


def get_curriculum_id_auto():
    """Pega um curriculum 'padrão' (CECA + Matriz 2019) se existir; senão o mais recente ativo."""
    with closing(conn()) as c:
        r = c.execute("""
            SELECT c.id
              FROM curriculum c
              JOIN degree d ON d.id=c.degree_id
             WHERE d.code='CECA' AND c.name='Matriz ano 2019' AND c.version=2019
             LIMIT 1
        """).fetchone()
        if r:
            return r["id"]
        r = c.execute("""
            SELECT c.id FROM curriculum c
            WHERE c.is_active=1
            ORDER BY c.id DESC LIMIT 1
        """).fetchone()
        return r["id"] if r else None


def load_courses_by_period(curriculum_id: int, emphasis_id: int | None = None):
    """Carrega disciplinas do curriculum, agrupadas por period_suggested.
       Se emphasis_id for dado, prioriza linhas com essa ênfase e inclui universais (emphasis_id NULL)."""
    with closing(conn()) as c:
        params = [curriculum_id]
        where_emphasis = "AND (co.emphasis_id IS NULL OR co.emphasis_id = ?)" if emphasis_id else ""
        if emphasis_id:
            params.append(emphasis_id)
        rows = c.execute(f"""
            SELECT
            co.id AS course_id,
            co.name AS course_name,
            (co.ch_presencial + co.ch_distancia) AS ch_total,
            co.period_suggested,
            co.type,
            n.name AS nucleo_name
            FROM course co
            LEFT JOIN nucleo n ON n.id = co.nucleo_id
            WHERE co.curriculum_id = ?
            {where_emphasis}
            ORDER BY (co.period_suggested IS NULL), co.period_suggested, co.code
        """, params).fetchall()

    grouped = defaultdict(list)
    periods = set()
    for r in rows:
        p = r["period_suggested"]
        periods.add(p)
        grouped[p].append(dict(r))

    periods_sorted = sorted([p for p in periods if p is not None])
    return periods_sorted, grouped


def load_periods_index(curriculum_id):
    with closing(conn()) as c:
        rows = c.execute("""
            SELECT DISTINCT period_suggested
            FROM course
            WHERE curriculum_id=?
            ORDER BY period_suggested
        """, (curriculum_id,)).fetchall()
    return [r["period_suggested"] for r in rows if r["period_suggested"] is not None]


def load_emphases(curriculum_id: int):
    with closing(conn()) as c:
        rows = c.execute("""
            SELECT id, name
            FROM emphasis
            WHERE curriculum_id = ? AND is_active = 1
            ORDER BY name
        """, (curriculum_id,)).fetchall()
    return [{"id": r["id"], "name": r["name"]} for r in rows]


def get_degree_id_by_curriculum(curriculum_id: int) -> int | None:
    with closing(conn()) as c:
        r = c.execute("SELECT degree_id FROM curriculum WHERE id=?",
                      (curriculum_id,)).fetchone()
        return r["degree_id"] if r else None


def get_or_create_user(username: str, curriculum_id: int, emphasis_id: int | None) -> int:
    """Upsert em app_user por username; retorna user_id."""
    degree_id = get_degree_id_by_curriculum(curriculum_id)
    if not degree_id:
        raise abort(400, "Curriculum inválido")

    with closing(conn()) as c:
        exist = c.execute(
            "SELECT id FROM app_user WHERE username=?", (username,)).fetchone()
        if exist:
            # Atualiza vínculo de currículo/ênfase para refletir a tela atual
            c.execute("""
                UPDATE app_user
                   SET degree_id=?, curriculum_id=?, emphasis_id=?
                 WHERE id=?
            """, (degree_id, curriculum_id, emphasis_id, exist["id"]))
            c.commit()
            return exist["id"]
        else:
            c.execute("""
                INSERT INTO app_user (username, degree_id, curriculum_id, emphasis_id)
                VALUES (?,?,?,?)
            """, (username, degree_id, curriculum_id, emphasis_id))
            c.commit()
            return c.execute("SELECT last_insert_rowid() AS id").fetchone()["id"]


def load_username(user_id: int | None) -> str | None:
    if not user_id:
        return None
    with closing(conn()) as c:
        r = c.execute("SELECT username FROM app_user WHERE id=?",
                      (user_id,)).fetchone()
        return r["username"] if r else None


@app.route("/")
def home():
    curriculum_id = get_curriculum_id_auto()

    # sessão + querystring
    user_id = request.args.get("user_id", type=int) or session.get("user_id")
    req_eid = request.args.get("emphasis_id", type=int)

    # emphases e fallback
    emphases = load_emphases(curriculum_id)
    emphasis_id = req_eid
    if not emphasis_id and user_id:
        with closing(conn()) as c:
            r = c.execute(
                "SELECT emphasis_id FROM app_user WHERE id=?", (user_id,)).fetchone()
            if r and r["emphasis_id"]:
                emphasis_id = r["emphasis_id"]
    if not emphasis_id and emphases:
        emphasis_id = emphases[0]["id"]

    # disciplinas + status
    periods, grouped = load_courses_by_period(
        curriculum_id, emphasis_id=emphasis_id)
    status_map = load_status_map(user_id)
    total_ch_display = sum(c["ch_total"] for p in periods for c in grouped[p])

    # ids no grid
    visible_ids = [c["course_id"] for p in periods for c in grouped[p]]

    # CO: só para badges e sync de clique
    co_fwd, co_rev = load_coreqs_maps(visible_ids)

    # PR: (ignorando PR de parceiros CO)
    pr_map = load_prereqs_map(visible_ids)

    def color_for(nucleo_name):
        if not nucleo_name:
            return "#F5F5F5"
        return NUCLEO_COLORS_VIVID.get(nucleo_name, "#F5F5F5")

    return render_template(
        "periods.html",
        curriculum_id=curriculum_id,
        periods=periods,
        grouped=grouped,
        color_for=color_for,
        emphases=emphases,
        selected_emphasis_id=emphasis_id,
        status_map=status_map,
        user_id=user_id,
        total_ch_display=total_ch_display,
        username=load_username(user_id),
        pr_map=pr_map,
        co_fwd=co_fwd,
        co_rev=co_rev,
    )


@app.post("/api/set_status")
def api_set_status():
    user_id = (
        request.args.get("user_id", type=int)
        or (request.json or {}).get("user_id")
        or session.get("user_id")
    )
    payload = request.get_json(silent=True) or {}
    course_id = payload.get("course_id")
    new_status = payload.get("status")  # 'PLANEJADO' | 'CONCLUIDO' | None

    if not user_id or not course_id:
        abort(400, "user_id e course_id são obrigatórios")

    if new_status not in (None, "PLANEJADO", "CONCLUIDO"):
        abort(400, "status inválido")

    with closing(conn()) as c:
        c.execute("""
            DELETE FROM user_course
             WHERE user_id=? AND course_id=? AND status IN ('PLANEJADO','CONCLUIDO')
        """, (user_id, course_id))
        if new_status:
            c.execute("""
                INSERT INTO user_course (user_id, course_id, status)
                VALUES (?,?,?)
            """, (user_id, course_id, new_status))
        c.commit()

    return jsonify({"ok": True, "course_id": course_id, "status": new_status})


@app.post("/api/save_selections")
def api_save_selections():
    # user pela sessão (preferido), aceita override por args/json
    user_id = (
        session.get("user_id")
        or request.args.get("user_id", type=int)
        or (request.json or {}).get("user_id")
    )
    payload = request.get_json(silent=True) or {}
    items = payload.get("selections")

    if not user_id:
        abort(400, "Nenhum usuário ativo. Use 'Abrir perfil' e salve um username.")
    if not isinstance(items, list):
        abort(
            400, "Payload inválido. Esperado: selections=[{course_id,status|null}, ...]")

    # Sanitiza
    normalized = []
    for it in items:
        if not isinstance(it, dict):
            continue
        cid = it.get("course_id")
        st = it.get("status")  # 'PLANEJADO' | 'CONCLUIDO' | None
        if not isinstance(cid, int):
            continue
        if st not in (None, "PLANEJADO", "CONCLUIDO"):
            st = None
        normalized.append((cid, st))

    course_ids = [cid for cid, _ in normalized]
    if not course_ids:
        return jsonify({"ok": True, "saved": 0})

    placeholders = ",".join("?" * len(course_ids))

    with closing(conn()) as c:
        c.execute(
            f"""DELETE FROM user_course
                 WHERE user_id=? AND status IN ('PLANEJADO','CONCLUIDO')
                   AND course_id IN ({placeholders})""",
            (user_id, *course_ids)
        )
        rows_to_insert = [(user_id, cid, st)
                          for cid, st in normalized if st is not None]
        if rows_to_insert:
            c.executemany(
                "INSERT INTO user_course (user_id, course_id, status) VALUES (?,?,?)",
                rows_to_insert
            )
        c.commit()

    return jsonify({"ok": True, "saved": len(rows_to_insert)})


@app.route("/user/set", methods=["POST"])
def user_set():
    username = (request.form.get("username") or "").strip()
    emphasis_id = request.form.get("emphasis_id", type=int)
    if not username:
        abort(400, "username é obrigatório")

    curriculum_id = get_curriculum_id_auto()
    user_id = get_or_create_user(username, curriculum_id, emphasis_id)

    session["user_id"] = user_id
    session["username"] = username

    # Redireciona preservando a ênfase
    return redirect(url_for("home", emphasis_id=emphasis_id, user_id=user_id))


@app.get("/user/logout")
def user_logout():
    session.clear()
    return redirect(url_for("home"))


if __name__ == "__main__":
    if not os.path.exists(DB_PATH):
        raise SystemExit(
            f"Banco não encontrado em {DB_PATH}. Ajuste DB_PATH ou coloque o .sqlite no diretório atual.")
    app.run(debug=True)
