// ===== KPI State =====
let chDone = 0;
let chPlanned = 0;

function renderKPIs() {
    document.getElementById('chDone').textContent = chDone;
    document.getElementById('chPlanned').textContent = chPlanned;
    document.getElementById('chProjected').textContent = chDone + chPlanned;
    const remaining = Math.max(0, TOTAL_CH - (chDone + chPlanned));
    document.getElementById('chRemaining').textContent = remaining;
}

function recalcKPIsFromDOM() {
    chDone = 0;
    chPlanned = 0;
    document.querySelectorAll('.course-btn').forEach(btn => {
        const ch = Number(btn.dataset.ch || 0);
        const st = btn.dataset.status || '';
        if (st === 'CONCLUIDO' || st === 'APROVEITADO') chDone += ch; // <<< inclui APROVEITADO
        else if (st === 'PLANEJADO') chPlanned += ch;
    });
    renderKPIs();
}

// ===== Aplicação local de status =====
function applyLocalStatus(btn, newStatus) {
    const prev = btn.dataset.status || '';
    const ch = Number(btn.dataset.ch || 0);

    if (prev === 'CONCLUIDO' || prev === 'APROVEITADO') chDone -= ch; // <<< inclui APROVEITADO
    else if (prev === 'PLANEJADO') chPlanned -= ch;

    if (newStatus === 'CONCLUIDO') chDone += ch;
    else if (newStatus === 'PLANEJADO') chPlanned += ch;

    btn.dataset.status = newStatus || '';
    btn.classList.toggle('is-done', newStatus === 'CONCLUIDO' || newStatus === 'APROVEITADO');
    btn.classList.toggle('is-planned', newStatus === 'PLANEJADO');

    renderKPIs();
    recomputePrereqHighlights();
}


function recomputePrereqHighlights() {
    const doneSet = new Set();
    document.querySelectorAll('.course-btn').forEach(btn => {
        const st = btn.dataset.status || '';
        if (st === 'CONCLUIDO' || st === 'APROVEITADO') {
            doneSet.add(Number(btn.dataset.courseId));
        }
    });

    document.querySelectorAll('.course-btn').forEach(btn => {
        const cid = Number(btn.dataset.courseId);
        const prs = (PR_MAP[String(cid)] ?? PR_MAP[cid]) ?? [];
        const hasPR = Array.isArray(prs) && prs.length > 0;
        const allOwnPROk = hasPR && prs.every(pid => doneSet.has(Number(pid)));
        const isDone = (btn.dataset.status === 'CONCLUIDO' || btn.dataset.status === 'APROVEITADO');

        btn.classList.toggle('pr-ok', allOwnPROk && !isDone);
    });
}



// ===== Interações por disciplina =====
function syncCoreqsFrom(btn, newStatus) {
    if (!newStatus) return;
    const cid = Number(btn.dataset.courseId);
    const partners = getCoreqPartners(cid);
    partners.forEach(pid => {
        const pbtn = document.querySelector(`.course-btn[data-course-id="${pid}"]`);
        if (!pbtn) return;
        applyLocalStatus(pbtn, newStatus);
    });
}

function wirePerCourseInteractions() {
    document.querySelectorAll('.course-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            applyLocalStatus(btn, 'PLANEJADO');
            syncCoreqsFrom(btn, 'PLANEJADO');
        });
        btn.addEventListener('dblclick', () => {
            applyLocalStatus(btn, 'CONCLUIDO');
            syncCoreqsFrom(btn, 'CONCLUIDO');
        });
        btn.addEventListener('contextmenu', (ev) => {
            ev.preventDefault();
            applyLocalStatus(btn, '');
        });
    });
}


// ===== Ações em massa por período =====
async function handlePeriodLocal(period, targetStatus) {
    const col = document.querySelector(`#p${period}`);
    if (!col) return;
    const buttons = Array.from(col.querySelectorAll('.course-btn'));

    const shouldSet = (btn) => {
        const st = btn.dataset.status || '';
        if (targetStatus === 'PLANEJADO') return st !== 'CONCLUIDO';
        if (targetStatus === 'CONCLUIDO') return true;
        if (targetStatus === null) return !!st;
        return false;
    };

    buttons.filter(shouldSet).forEach(btn => applyLocalStatus(btn, targetStatus));
}

function wirePerPeriodInteractions() {
    const SINGLE_DELAY_MS = 220; // mesma janela do per-course
    document.querySelectorAll('.period-title.period-action').forEach(el => {
        const period = Number(el.dataset.period);
        let clickTimer = null;

        // 1x = Plan não concluídas
        el.addEventListener('click', () => {
            if (clickTimer) return;
            clickTimer = setTimeout(() => {
                clickTimer = null;
                handlePeriodLocal(period, 'PLANEJADO');
            }, SINGLE_DELAY_MS);
        });

        // 2x = Concluir todas
        el.addEventListener('dblclick', () => {
            if (clickTimer) {
                clearTimeout(clickTimer);
                clickTimer = null;
            }
            handlePeriodLocal(period, 'CONCLUIDO');
        });

        // direito = limpar todas
        el.addEventListener('contextmenu', (ev) => {
            ev.preventDefault();
            if (clickTimer) {
                clearTimeout(clickTimer);
                clickTimer = null;
            }
            handlePeriodLocal(period, null);
        });
    });
}

// ===== "Salvar" =====
async function saveSelections() {
    const selections = Array.from(document.querySelectorAll('.course-btn')).map(btn => ({
        course_id: Number(btn.dataset.courseId),
        status: btn.dataset.status || null
    }));

    try {
        const res = await fetch('/api/save_selections', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                selections
            })
        });
        if (!res.ok) {
            const txt = await res.text();
            throw new Error(txt || ('HTTP ' + res.status));
        }
        alert('Seleções salvas com sucesso.');
    } catch (e) {
        alert('Falha ao salvar seleções. ' + (e.message || ''));
    }
}

function getCoreqPartners(cid) {
    cid = Number(cid);
    const a = CO_FWD[String(cid)] || CO_FWD[cid] || [];
    const b = CO_REV[String(cid)] || CO_REV[cid] || [];
    const s = new Set([...a, ...b].map(Number));
    s.delete(cid);
    return Array.from(s);
}

const CO_PALETTE = [
    '#1565C0', // cobalt
    '#C62828', // crimson
    '#00838F', // cyan
    '#6D4C41', // brown
    '#2E7D32', // forest green
    '#D81B60', // raspberry
    '#EF6C00', // orange
    '#1A237E', // navy indigo
    '#00796B', // deep teal
    '#B8860B', // dark gold
    '#6A1B9A', // purple
    '#D84315', // vermilion
    '#8E24AA', // violet
    '#558B2F', // olive green
    '#880E4F' // burgundy
];

// util: HSL → #RRGGBB
function hslToHex(h, s, l) {
    s /= 100;
    l /= 100;
    const k = n => (n + h / 30) % 12;
    const a = s * Math.min(l, 1 - l);
    const f = n => l - a * Math.max(-1, Math.min(k(n) - 3, Math.min(9 - k(n), 1)));
    const toHex = x => Math.round(255 * x).toString(16).padStart(2, '0');
    return `#${toHex(f(0))}${toHex(f(8))}${toHex(f(4))}`;
}

function pairKey(a, b) {
    a = Number(a);
    b = Number(b);
    return a < b ? `${a}-${b}` : `${b}-${a}`;
}


// coletar todos os pares CO existentes (CO_FWD + CO_REV)
function getAllCoreqPairKeys() {
    const set = new Set();

    const pushFrom = (mapObj) => {
        Object.entries(mapObj || {}).forEach(([k, arr]) => {
            const a = Number(k);
            (arr || []).forEach(b => set.add(pairKey(a, b)));
        });
    };

    pushFrom(CO_FWD);
    pushFrom(CO_REV);
    return Array.from(set);
}

// map global de cores por par
const CO_COLOR_MAP = Object.create(null);

// gerador extra com ângulo áureo (cores únicas ad infinitum)
const GOLDEN_ANGLE = 137.508;

function vividColorByIndex(i) {
    const h = (i * GOLDEN_ANGLE) % 360;
    return hslToHex(h, 92, 54); // saturação/claridade altas
}

// alocar SEM repetir: usa paleta; depois, gera HSL únicos
function allocateCoreqColors() {
    const keys = getAllCoreqPairKeys()
        .map(k => k.split('-').map(n => Number(n)))
        .sort((a, b) => (a[0] - b[0]) || (a[1] - b[1]))
        .map(([x, y]) => `${x}-${y}`);

    keys.forEach((k, idx) => {
        if (!CO_COLOR_MAP[k]) {
            CO_COLOR_MAP[k] = idx < CO_PALETTE.length ?
                CO_PALETTE[idx] :
                vividColorByIndex(idx - CO_PALETTE.length);
        }
    });
}

// API de cor
function colorForPair(a, b) {
    const key = pairKey(a, b);
    return CO_COLOR_MAP[key] || '#000';
}

function annotateRequirementBadges() {
    document.querySelectorAll('.course-btn').forEach(btn => {
        const cid = Number(btn.dataset.courseId);
        const prs = PR_MAP[String(cid)] || PR_MAP[cid] || [];
        const partners = getCoreqPartners(cid);

        // limpa badges anteriores
        btn.querySelectorAll('.co-badges').forEach(n => n.remove());

        if (partners.length > 0) {
            const wrap = document.createElement('div');
            wrap.className = 'co-badges';
            partners.forEach(pid => {
                const sp = document.createElement('span');
                sp.className = 'co-badge';
                sp.textContent = '↔';
                sp.style.color = colorForPair(cid, pid);
                wrap.appendChild(sp);
            });
            btn.appendChild(wrap);
        }

        if (prs.length === 0 && partners.length === 0) btn.classList.add('no-req');
        else btn.classList.remove('no-req');
    });
}

function markNoPR() {
    document.querySelectorAll('.course-btn').forEach(btn => {
        const cid = Number(btn.dataset.courseId);
        // PR_MAP contém apenas cursos com PR; se não houver chave => sem PR
        const prs = PR_MAP[String(cid)] ?? PR_MAP[cid];
        const hasPR = Array.isArray(prs) && prs.length > 0;
        btn.classList.toggle('no-pr', !hasPR);
    });
}



// boot
recalcKPIsFromDOM();
wirePerCourseInteractions();
wirePerPeriodInteractions();
markNoPR();
allocateCoreqColors();
annotateRequirementBadges();
recomputePrereqHighlights();
