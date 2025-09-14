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

-- 2) Aliases para bater nomes abreviados/variações com o nome canônico existente no DB
CREATE TEMP TABLE _alias(alias TEXT PRIMARY KEY, canonical TEXT NOT NULL);
INSERT INTO _alias(alias, canonical) VALUES
  ('Algoritmos e Estruturas de Dados', 'Algoritmos e Estrutura de Dados'),
  ('Introdução a Geometria Analítica e Variáveis Complexas', 'Introdução à Geometria Analítica e Variáveis Complexas'),
  ('Arquitetura de Comp. e Sis. Embarcados', 'Arquitetura de Computadores e Sistemas Embarcados'),
  ('Programação de CLP', 'Programação de Controlador Lógico Programável'),
  ('Física Geral I.', 'Física Geral I'),
  ('Sistemas Operacionais.', 'Sistemas Operacionais'),
  ('Arquitetura de Computadores e Sistemas Embarcados.', 'Arquitetura de Computadores e Sistemas Embarcados');

-- 3) Matriz crua: (curso alvo por code, pré-requisito por nome — 1 linha por PR)
CREATE TEMP TABLE _pr_raw(target_code TEXT NOT NULL, prereq_name TEXT NOT NULL);

INSERT INTO _pr_raw(target_code, prereq_name) VALUES
('CECA201','Química Geral e Experimental'),
('CECA202','Introdução à Computação para Controle e Automação'),
('CECA203','Introdução à Computação para Controle e Automação'),
('CECA204','Pré-Cálculo'),
('CECA205','Introdução a Geometria Analítica e Variáveis Complexas'),
('CECA206','Pré-Cálculo'),
('CECA301','Algoritmos e Estruturas de Dados'),
('CECA302','Sistemas Digitais I'),
('CECA303','Cálculo Diferencial e Integral I'),
('CECA303','Geometria Analítica'),
('CECA304','Geometria Analítica'),
('CECA305','Cálculo Diferencial e Integral I'),
('CECA305','Física Geral I.'),
('CECA401','Sistemas Digitais II'),
('CECA402','Programação Orientada a Objetos'),
('CECA403','Álgebra Linear'),
('CECA403','Cálculo Diferencial e Integral II'),
('CECA406','Cálculo Diferencial e Integral II'),
('CECA406','Física Geral II'),
('CECA501','Programação Orientada a Objetos'),
('CECA501','Projetos com Sistemas Digitais'),
('CECA502','Cálculo Diferencial e Integral III'),
('CECA502','Circuitos Elétricos'),
('CECA504','Circuitos Elétricos'),
('CECA504','Laboratório de Circuitos Elétricos'),
('CECA505','Cálculo Diferencial e Integral III'),
('CECA505','Física Geral II'),
('CECA506','Cálculo Diferencial e Integral III'),
('CECA506','Física Geral III'),
('CECA601','Arquitetura de Comp. e Sis. Embarcados'),
('CECA602','Arquitetura de Comp. e Sis. Embarcados'),
('CECA603','Análise de Sinais e Sistemas'),
('CECA603','Fenômenos de Transporte'),
('CECA603','Dispositivos e Circuitos Eletrônicos Básicos'),
('CECA605','Fenômenos de Transporte'),
('CECA605','Dispositivos e Circuitos Eletrônicos Básicos'),
('CECA606','Química Geral e Experimental'),
('CECA607','Álgebra Linear'),
('CECA607','Cálculo Diferencial e Integral I'),
('CECA607','Física Geral I'),
('CECA703','Comunicação de Dados'),
('CECA704','Modelagem de Sistemas Dinâmicos'),
('CECA705','Cálculo Diferencial e Integral III'),
('CECA706','Dispositivos e Circuitos Eletrônicos Básicos'),
('CECA706','Laboratório de Dispositivos e Circuitos Eletrônicos Básicos'),
('CECA801','Comunicação e Expressão'),
('CECA802','Ciência dos Materiais'),
('CECA803','Geometria Analítica'),
('CECA804','Sistemas Microcontrolados'),
('CECA805','Programação Orientada a Objetos'),
('CECA805','Cálculo Numérico'),
('CECA805','Probabilidade e Estatística'),
('CECA806','Modelagem de Sistemas Dinâmicos'),
('CECA806','Controle Automático'),
('CECA807','Eletrônica de Potência'),
('CECA901','Metodologia Científica'),
('CECA902','Metodologia Científica'),
('CECA903','Processo de Fabricação'),
('CECA904','Probabilidade e Estatística'),
('CECA905','Redes para Controle e Automação'),
('CECA905','Programação de CLP'),
('CECA906','Arquitetura de Computadores e Sistemas Embarcados.'),
('CECA907','Modelagem de Sistemas Dinâmicos'),
('CECA908','Controle de Processos'),
('CECA909','Controle de Processos'),
('CECA910','Ciência dos Materiais'),
('CECA910','Controle de Processos'),
('CECA911','Fenômenos de Transporte'),
('CECA911','Programação de CLP'),
('CECA912','Programação de CLP'),
('CECA912','Comandos e Proteção em Baixa Tensão'),
('CECA1001','Projeto Final de Curso I'),
('CECA1002','Gerência de Projetos'),
('CECA1002','Manufatura Integrada'),
('CECA1003','Administração para Engenharia'),
('CECA1004','Administração para Engenharia'),
('CECA1005','Segurança Digital'),
('CECA1005','Sistemas Operacionais'),
('CECA1005','Robótica'),
('CECA1006','Inteligência Artificial'),
('CECA1006','Controle Preditivo'),
('CECA1007','Física Geral IV'),
('CECA1007','Instrumentação Analítica I');

-- 4) Normalização do nome do PR (aplica alias quando existir; trim de bordas)
CREATE TEMP VIEW _pr_norm AS
SELECT
  r.target_code,
  COALESCE(a.canonical, TRIM(r.prereq_name)) AS prereq_canonical
FROM _pr_raw r
LEFT JOIN _alias a
  ON a.alias = TRIM(r.prereq_name);

-- 5) Resolver IDs no currículo alvo
CREATE TEMP TABLE _edges AS
SELECT
  t.id  AS course_id,
  p.id  AS related_course_id
FROM _pr_norm n
JOIN course t
  ON t.code = n.target_code
 AND t.curriculum_id = (SELECT id FROM _curr)
JOIN course p
  ON p.name = n.prereq_canonical
 AND p.curriculum_id = (SELECT id FROM _curr);

-- 6) Limpeza e insert idempotente
DELETE FROM course_requirement
 WHERE type='PR'
   AND course_id IN (SELECT DISTINCT course_id FROM _edges);

INSERT OR IGNORE INTO course_requirement (course_id, type, related_course_id)
SELECT course_id, 'PR', related_course_id
  FROM _edges;

-- 7) (Opcional) Relatórios rápidos para conferência no console
-- SELECT COUNT(*) AS inseridos FROM _edges;
-- SELECT n.* FROM _pr_norm n
-- LEFT JOIN course p ON p.name=n.prereq_canonical AND p.curriculum_id=(SELECT id FROM _curr)
-- WHERE p.id IS NULL; -- PR não resolvidos por nome

COMMIT;
