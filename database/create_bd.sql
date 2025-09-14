PRAGMA foreign_keys = ON;

-- =========================
-- 1) DEGREE / CURRICULUM
-- =========================
CREATE TABLE degree (
  id            INTEGER PRIMARY KEY,
  code          TEXT,                    -- opcional
  name          TEXT NOT NULL,
  grade_scale   TEXT NOT NULL DEFAULT '0-100'
);

CREATE TABLE curriculum (
  id           INTEGER PRIMARY KEY,
  degree_id    INTEGER NOT NULL,
  name         TEXT NOT NULL,
  version      INTEGER NOT NULL DEFAULT 1,
  is_active    INTEGER NOT NULL DEFAULT 1,
  UNIQUE (degree_id, name, version),
  FOREIGN KEY (degree_id) REFERENCES degree(id) ON DELETE CASCADE
);

-- Requisitos do degree (flat, 1:1)
CREATE TABLE degree_requirements (
  degree_id               INTEGER PRIMARY KEY REFERENCES degree(id) ON DELETE CASCADE,
  ch_obrigatoria_req      INTEGER NOT NULL DEFAULT 0 CHECK (ch_obrigatoria_req >= 0),
  ch_optativa_req         INTEGER NOT NULL DEFAULT 0 CHECK (ch_optativa_req    >= 0),
  ch_estagio_req          INTEGER NOT NULL DEFAULT 0 CHECK (ch_estagio_req     >= 0),
  ch_complementar_req     INTEGER NOT NULL DEFAULT 0 CHECK (ch_complementar_req>= 0),
  ch_pf_req               INTEGER NOT NULL DEFAULT 0 CHECK (ch_pf_req          >= 0),
  ch_total_req            INTEGER NOT NULL DEFAULT 0 CHECK (ch_total_req       >= 0),
  cr_total_req            INTEGER NOT NULL DEFAULT 0 CHECK (cr_total_req       >= 0),
  min_gpa_req             NUMERIC NOT NULL DEFAULT 0 CHECK (min_gpa_req >= 0),
  CHECK (
    ch_total_req = ch_obrigatoria_req + ch_optativa_req 
                 + ch_estagio_req + ch_complementar_req + ch_pf_req
  )
);

-- Núcleos (opcionais por degree)
CREATE TABLE nucleo (
  id         INTEGER PRIMARY KEY,
  degree_id  INTEGER NOT NULL,
  name       TEXT NOT NULL,
  UNIQUE (degree_id, name),
  FOREIGN KEY (degree_id) REFERENCES degree(id) ON DELETE CASCADE
);

-- Ênfase por curriculum
CREATE TABLE emphasis (
  id             INTEGER PRIMARY KEY,
  curriculum_id  INTEGER NOT NULL,
  code           TEXT,        -- opcional
  name           TEXT NOT NULL,
  is_active      INTEGER NOT NULL DEFAULT 1,
  UNIQUE (curriculum_id, code),   -- aceita múltiplos NULLs
  FOREIGN KEY (curriculum_id) REFERENCES curriculum(id) ON DELETE CASCADE
);

-- =========================
-- 2) CATÁLOGO CURRICULAR (MERGED)
-- =========================
-- UMA tabela 'course' já com contexto de curriculum/ênfase
CREATE TABLE course (
  id                INTEGER PRIMARY KEY,
  curriculum_id     INTEGER NOT NULL,
  emphasis_id       INTEGER,                   -- NULL = universal
  nucleo_id         INTEGER,                   -- opcional
  code              TEXT,                      -- opcional
  name              TEXT NOT NULL,
  ementa            TEXT,
  -- CH/CR efetivas desta oferta no curriculum/ênfase:
  ch_presencial     INTEGER NOT NULL CHECK (ch_presencial >= 0),
  ch_distancia      INTEGER NOT NULL CHECK (ch_distancia  >= 0),
  credits           INTEGER NOT NULL CHECK (credits > 0),
  -- classificação acadêmica
  type              TEXT NOT NULL CHECK (type IN ('OBRIGATORIA','OPTATIVA','ELETIVA','ESTAGIO','PROJETO_FINAL')),
  period_suggested  INTEGER CHECK (period_suggested BETWEEN 1 AND 10),  -- 1..10 (não é YYYYS)
  is_active         INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (curriculum_id) REFERENCES curriculum(id) ON DELETE CASCADE,
  FOREIGN KEY (emphasis_id)   REFERENCES emphasis(id)   ON DELETE SET NULL,
  FOREIGN KEY (nucleo_id)     REFERENCES nucleo(id)     ON DELETE SET NULL
);

-- (opcionais, mas recomendados p/ evitar duplicatas óbvias)
CREATE INDEX ix_course_lookup       ON course(curriculum_id, emphasis_id, type);
CREATE INDEX ix_course_names        ON course(curriculum_id, name);
CREATE INDEX ix_course_codes        ON course(curriculum_id, code);

-- =========================
-- 3) REQUISITOS DE DISCIPLINA (unificados)
-- =========================
-- Renomeado para course_requirement; 'type' em vez de rule_type; sem same_term_required
CREATE TABLE course_requirement (
  id                INTEGER PRIMARY KEY,
  course_id         INTEGER NOT NULL,     -- curso alvo (já carrega curriculum/ênfase)
  type              TEXT NOT NULL CHECK (type IN ('PR','CO','MIN_TOTAL_CH')),
  related_course_id INTEGER,              -- obrigatório para PR/CO
  required_min      NUMERIC,              -- obrigatório para MIN_TOTAL_CH (horas)
  CHECK (
    (type IN ('PR','CO') AND related_course_id IS NOT NULL AND required_min IS NULL)
    OR
    (type = 'MIN_TOTAL_CH' AND related_course_id IS NULL AND required_min IS NOT NULL)
  ),
  CHECK (course_id IS NULL OR related_course_id IS NULL OR course_id <> related_course_id),
  FOREIGN KEY (course_id)         REFERENCES course(id) ON DELETE CASCADE,
  FOREIGN KEY (related_course_id) REFERENCES course(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX ux_course_requirement
  ON course_requirement(course_id, type, IFNULL(related_course_id, 0));
CREATE INDEX ix_req_related
  ON course_requirement(related_course_id, type);

-- =========================
-- 4) USUÁRIOS / PROGRESSO
-- =========================
CREATE TABLE app_user (
  id            INTEGER PRIMARY KEY,
  username      TEXT NOT NULL UNIQUE,
  degree_id     INTEGER NOT NULL,
  curriculum_id INTEGER NOT NULL,
  emphasis_id   INTEGER,                         -- ênfase do usuário (opcional)
  created_at    TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (degree_id)     REFERENCES degree(id)     ON DELETE RESTRICT,
  FOREIGN KEY (curriculum_id) REFERENCES curriculum(id) ON DELETE RESTRICT,
  FOREIGN KEY (emphasis_id)   REFERENCES emphasis(id)   ON DELETE SET NULL
);

CREATE TABLE user_course (
  id              INTEGER PRIMARY KEY,
  user_id         INTEGER NOT NULL,
  course_id       INTEGER NOT NULL,
  status          TEXT NOT NULL CHECK (status IN ('PLANEJADO','ATUAL','CONCLUIDO','TRANCADO','REPROVADO','APROVEITADO')),
  -- períodos YYYYS, obrigatoriamente > 20101 (2010.1), e semestre ∈ {1,2}
  period_planned  INTEGER CHECK (period_planned  > 20101 AND period_planned  % 10 IN (1,2)),
  period_taken    INTEGER CHECK (period_taken    > 20101 AND period_taken    % 10 IN (1,2)),
  grade           NUMERIC CHECK (grade >= 0),
  aproveitamento  INTEGER NOT NULL DEFAULT 0 CHECK (aproveitamento IN (0,1)),   -- bypass transacional
  created_at      TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (user_id, course_id, status),
  FOREIGN KEY (user_id)   REFERENCES app_user(id) ON DELETE CASCADE,
  FOREIGN KEY (course_id) REFERENCES course(id)   ON DELETE RESTRICT
);

-- CH complementar (workflow)
CREATE TABLE user_ch_complementar (
  id          INTEGER PRIMARY KEY,
  user_id     INTEGER NOT NULL,
  ch_hours    INTEGER NOT NULL CHECK (ch_hours > 0),
  description TEXT,
  status      TEXT NOT NULL DEFAULT 'solicitar'
                CHECK (status IN ('solicitar','solicitado','deferido','indeferido')),
  created_at  TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE CASCADE
);

CREATE INDEX ix_user_course_userstatus ON user_course(user_id, status);
CREATE INDEX ix_user_comp_user         ON user_ch_complementar(user_id);

-- =========================
-- 5) VIEWS (progresso + dashboard)
-- =========================
-- Base de progresso: DONE + APROVEITADO contam carga/creditagem
CREATE VIEW v_user_progress_base AS
SELECT
  uc.user_id,
  au.degree_id,
  au.curriculum_id,
  uc.course_id,
  c.type,
  (c.ch_presencial + c.ch_distancia) AS ch_total,
  c.credits,
  uc.grade
FROM user_course uc
JOIN app_user au ON au.id = uc.user_id
JOIN course c    ON c.id  = uc.course_id
WHERE uc.status IN ('DONE','APROVEITADO');

-- KPIs por categoria + total
CREATE VIEW v_user_kpis AS
WITH agg AS (
  SELECT
    user_id,
    SUM(CASE WHEN type='OBRIGATORIA'   THEN ch_total ELSE 0 END) AS ch_obrigatoria_done,
    SUM(CASE WHEN type='OPTATIVA'      THEN ch_total ELSE 0 END) AS ch_optativa_done,
    SUM(CASE WHEN type='ELETIVA'       THEN ch_total ELSE 0 END) AS ch_eletiva_done,
    SUM(CASE WHEN type='ESTAGIO'       THEN ch_total ELSE 0 END) AS ch_estagio_done,
    SUM(CASE WHEN type='PROJETO_FINAL' THEN ch_total ELSE 0 END) AS ch_pf_done,
    SUM(credits) AS credits_total_done,
    AVG(grade)   AS gpa_raw
  FROM v_user_progress_base
  GROUP BY user_id
),
comp AS (
  SELECT user_id, COALESCE(SUM(ch_hours),0) AS ch_complementar_done
  FROM user_ch_complementar
  WHERE status = 'deferido'
  GROUP BY user_id
)
SELECT
  u.id AS user_id,
  u.degree_id,
  COALESCE(a.ch_obrigatoria_done,0)   AS ch_obrigatoria_done,
  COALESCE(a.ch_optativa_done,0)      AS ch_optativa_done,
  COALESCE(a.ch_eletiva_done,0)       AS ch_eletiva_done,
  COALESCE(a.ch_estagio_done,0)       AS ch_estagio_done,
  COALESCE(c.ch_complementar_done,0)  AS ch_complementar_done,
  COALESCE(a.ch_pf_done,0)            AS ch_pf_done,
  (COALESCE(a.ch_obrigatoria_done,0)
   + COALESCE(a.ch_optativa_done,0)
   + COALESCE(a.ch_eletiva_done,0)
   + COALESCE(a.ch_estagio_done,0)
   + COALESCE(c.ch_complementar_done,0)
   + COALESCE(a.ch_pf_done,0))        AS ch_total_done,
  COALESCE(a.credits_total_done,0)    AS credits_total_done,
  CASE WHEN a.gpa_raw IS NULL THEN NULL ELSE round(a.gpa_raw, 2) END AS gpa
FROM app_user u
LEFT JOIN agg a  ON a.user_id = u.id
LEFT JOIN comp c ON c.user_id = u.id;

-- Dashboard: EXIGIDO vs CUMPRIDO
CREATE VIEW v_user_degree_status AS
SELECT
  k.user_id,
  k.degree_id,
  k.ch_obrigatoria_done,
  k.ch_optativa_done,
  k.ch_eletiva_done,
  k.ch_estagio_done,
  k.ch_complementar_done,
  k.ch_pf_done,
  k.ch_total_done,
  k.credits_total_done,
  k.gpa,
  dr.ch_obrigatoria_req  AS ch_obrigatoria_req,
  dr.ch_optativa_req     AS ch_optativa_req,
  dr.ch_eletiva_req      AS ch_eletiva_req,
  dr.ch_estagio_req      AS ch_estagio_req,
  dr.ch_complementar_req AS ch_complementar_req,
  dr.ch_pf_req           AS ch_pf_req,
  dr.ch_total_req        AS ch_total_req,
  dr.cr_total_req        AS credits_total_req,
  dr.min_gpa_req         AS min_gpa_req
FROM v_user_kpis k
LEFT JOIN degree_requirements dr ON dr.degree_id = k.degree_id;

-- Exibição YYYY.S para períodos do usuário
CREATE VIEW v_user_course_display AS
SELECT
  uc.*,
  CASE WHEN period_planned IS NULL THEN NULL
       ELSE substr(CAST(period_planned AS TEXT),1,4) || '.' || substr(CAST(period_planned AS TEXT),-1)
  END AS period_planned_display,
  CASE WHEN period_taken IS NULL THEN NULL
       ELSE substr(CAST(period_taken AS TEXT),1,4) || '.' || substr(CAST(period_taken AS TEXT),-1)
  END AS period_taken_display
FROM user_course uc;

-- =========================
-- 6) TRIGGER DE MATRÍCULA (CURRENT)
-- =========================
DROP TRIGGER IF EXISTS trg_uc_validate_current;
CREATE TRIGGER trg_uc_validate_current
BEFORE INSERT ON user_course
WHEN NEW.status = 'CURRENT'
BEGIN
  -- período obrigatório e válido
  SELECT RAISE(ABORT, 'period_taken é obrigatório para ATUAL')
  WHERE NEW.period_taken IS NULL;

  -- BYPASS executivo: ignora validações
  SELECT CASE WHEN NEW.aproveitamento = 1 THEN NULL END;

  -- PR: todos PR precisam estar DONE ou APROVEITADO
  SELECT RAISE(ABORT, 'Pré-requisito não cumprido')
  WHERE NEW.aproveitamento = 0
    AND EXISTS (
      SELECT 1
      FROM course_requirement r
      WHERE r.course_id = NEW.course_id
        AND r.type = 'PR'
        AND r.related_course_id NOT IN (
          SELECT uc2.course_id
          FROM user_course uc2
          WHERE uc2.user_id = NEW.user_id
            AND uc2.status IN ('CONCLUIDO','APROVEITADO')
        )
    );

  -- CO: precisa estar DONE/APROVEITADO ou CURRENT no MESMO período
  SELECT RAISE(ABORT, 'Co-requisito não alocado')
  WHERE NEW.aproveitamento = 0
    AND EXISTS (
      SELECT 1
      FROM course_requirement r
      WHERE r.course_id = NEW.course_id
        AND r.type = 'CO'
        AND r.related_course_id NOT IN (
          SELECT uc2.course_id
          FROM user_course uc2
          WHERE uc2.user_id = NEW.user_id
            AND (
              uc2.status IN ('CONCLUIDO','APROVEITADO')
              OR (uc2.status='ATUAL' AND uc2.period_taken = NEW.period_taken)
            )
        )
    );

  -- Gate: MIN_TOTAL_CH (CONCLUIDO + APROVEITADO + complementar deferido)
  SELECT RAISE(ABORT, 'Carga horária mínima não atendida')
  WHERE NEW.aproveitamento = 0
    AND EXISTS (
      WITH agg AS (
        SELECT
          COALESCE((
            SELECT SUM(c.ch_presencial + c.ch_distancia)
            FROM user_course ucd
            JOIN course c ON c.id = ucd.course_id
            WHERE ucd.user_id = NEW.user_id
              AND ucd.status IN ('CONCLUIDO','APROVEITADO')
          ),0)
          + COALESCE((
            SELECT SUM(ch_hours)
            FROM user_ch_complementar
            WHERE user_id = NEW.user_id AND status = 'deferido'
          ),0) AS ch_done
      )
      SELECT 1
      FROM course_requirement r
      WHERE r.course_id = NEW.course_id
        AND r.type = 'MIN_TOTAL_CH'
        AND (SELECT ch_done FROM agg) < r.required_min
    );
END;
