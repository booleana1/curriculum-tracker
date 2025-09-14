PRAGMA foreign_keys = ON;
BEGIN;

-- 1) Currículo alvo (preferência: CECA / Matriz ano 2019 / versão 2019; fallback: último ativo)
CREATE TEMP TABLE _curr(id INTEGER);
INSERT INTO _curr(id)
SELECT COALESCE(
  (SELECT c.id
     FROM curriculum c
     JOIN degree d ON d.id=c.degree_id
    WHERE d.code='CECA' AND c.name='Matriz ano 2019' AND c.version=2019
    LIMIT 1),
  (SELECT c.id
     FROM curriculum c
    WHERE c.is_active=1
    ORDER BY c.id DESC
    LIMIT 1)
);

-- 2) Aliases para variações de nomenclatura (aplique aqui quaisquer abreviações/pontuação)
CREATE TEMP TABLE _alias(alias TEXT PRIMARY KEY, canonical TEXT NOT NULL);
INSERT INTO _alias(alias, canonical) VALUES
  ('Sistemas Operacionais.', 'Sistemas Operacionais');

-- 3) Matriz crua de CO (1 linha por co-requisito)
CREATE TEMP TABLE _co_raw(target_code TEXT NOT NULL, coreq_name TEXT NOT NULL);

INSERT INTO _co_raw(target_code, coreq_name) VALUES
('CECA402','Cálculo Diferencial e Integral III'),
('CECA404','Circuitos Elétricos'),
('CECA405','Cálculo Diferencial e Integral III'),
('CECA405','Física Geral III'),
('CECA503','Dispositivos e Circuitos Eletrônicos Básicos'),
('CECA604','Instrumentação Industrial I'),
('CECA702','Segurança do Trabalho'),
('CECA804','Comandos e Proteção em Baixa Tensão'),
('CECA806','Programação de Controlador Lógico Programável'),
('CECA901','Gerência de Projetos'),
('CECA905','Sistemas Operacionais');

-- 4) Normalização do nome do CO (aplica alias quando existir)
CREATE TEMP VIEW _co_norm AS
SELECT
  r.target_code,
  COALESCE(a.canonical, TRIM(r.coreq_name)) AS coreq_canonical
FROM _co_raw r
LEFT JOIN _alias a
  ON a.alias = TRIM(r.coreq_name);

-- 5) Resolver IDs no currículo alvo
CREATE TEMP TABLE _edges AS
SELECT
  t.id  AS course_id,
  p.id  AS related_course_id
FROM _co_norm n
JOIN course t
  ON t.code = n.target_code
 AND t.curriculum_id = (SELECT id FROM _curr)
JOIN course p
  ON p.name = n.coreq_canonical
 AND p.curriculum_id = (SELECT id FROM _curr);

-- (opcional) Inspeção de linhas não resolvidas por nome — deve ficar vazia
-- SELECT n.* FROM _co_norm n
-- LEFT JOIN course p ON p.name=n.coreq_canonical AND p.curriculum_id=(SELECT id FROM _curr)
-- WHERE p.id IS NULL;

-- 6) Limpeza e insert idempotente dos CO
DELETE FROM course_requirement
 WHERE type='CO'
   AND course_id IN (SELECT DISTINCT course_id FROM _edges);

INSERT OR IGNORE INTO course_requirement (course_id, type, related_course_id)
SELECT course_id, 'CO', related_course_id
  FROM _edges;

COMMIT;

-- =========================
-- Blocos de auditoria (opcionais)
-- =========================

-- A) Listagem completa dos CO gravados (alvo -> co-requisito)
-- WITH curr(id) AS (SELECT id FROM _curr)
-- SELECT t.code AS course_code, t.name AS course_name,
--        p.code AS coreq_code,  p.name AS coreq_name
-- FROM course_requirement r
-- JOIN course t ON t.id=r.course_id
-- JOIN course p ON p.id=r.related_course_id
-- WHERE r.type='CO'
--   AND t.curriculum_id=(SELECT id FROM curr)
--   AND p.curriculum_id=(SELECT id FROM curr)
-- ORDER BY t.code, coreq_code, coreq_name;

-- B) Contagem de CO por disciplina
-- WITH curr(id) AS (SELECT id FROM _curr)
-- SELECT t.code AS course_code, t.name AS course_name, COUNT(*) AS qtd_co
-- FROM course_requirement r
-- JOIN course t ON t.id=r.course_id
-- WHERE r.type='CO' AND t.curriculum_id=(SELECT id FROM curr)
-- GROUP BY t.id
-- ORDER BY t.code;

-- C) Auto-dependências (não deve retornar nada)
-- SELECT * FROM course_requirement
-- WHERE type='CO' AND course_id=related_course_id;
