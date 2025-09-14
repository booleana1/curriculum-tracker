
INSERT INTO degree (code, name, grade_scale)
SELECT 'CECA', 'Engenharia de Controle e Automação', '0-100'
WHERE NOT EXISTS (SELECT 1 FROM degree WHERE code='CECA');

INSERT INTO curriculum (degree_id, name, version, is_active)
SELECT d.id, 'Matriz ano 2019', 2019, 1 FROM degree d
WHERE d.code='CECA'
  AND NOT EXISTS (
    SELECT 1 FROM curriculum c WHERE c.degree_id=d.id AND c.name='Matriz ano 2019' AND c.version=2019
  );

-- Ensure nucleos present
INSERT OR IGNORE INTO nucleo (degree_id, name)
SELECT d.id, 'Automação' FROM degree d WHERE d.code='CECA';
INSERT OR IGNORE INTO nucleo (degree_id, name)
SELECT d.id, 'Básico' FROM degree d WHERE d.code='CECA';
INSERT OR IGNORE INTO nucleo (degree_id, name)
SELECT d.id, 'Controle' FROM degree d WHERE d.code='CECA';
INSERT OR IGNORE INTO nucleo (degree_id, name)
SELECT d.id, 'Gestão e Normativas' FROM degree d WHERE d.code='CECA';
INSERT OR IGNORE INTO nucleo (degree_id, name)
SELECT d.id, 'Instrumentação' FROM degree d WHERE d.code='CECA';

-- Ensure emphases present (excluding 'Comum')
INSERT INTO emphasis (curriculum_id, code, name, is_active)
SELECT c.id, NULL, 'Automação Integrada', 1 FROM curriculum c
JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (SELECT 1 FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Automação Integrada');
INSERT INTO emphasis (curriculum_id, code, name, is_active)
SELECT c.id, NULL, 'Instrumentação', 1 FROM curriculum c
JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (SELECT 1 FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Instrumentação');
INSERT INTO emphasis (curriculum_id, code, name, is_active)
SELECT c.id, NULL, 'Sistemas Inteligentes', 1 FROM curriculum c
JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (SELECT 1 FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Sistemas Inteligentes');

-- Insert courses (idempotent)
INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Sociologia e Cidadania',
       NULL,
       0, 30, 2,
       'OBRIGATORIA',
       1, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Sociologia e Cidadania' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Ética e Legislação Profissional',
       NULL,
       45, 0, 3,
       'OBRIGATORIA',
       1, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Ética e Legislação Profissional' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Comunicação e Expressão',
       NULL,
       0, 30, 2,
       'OBRIGATORIA',
       1, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Comunicação e Expressão' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Automação'),
       NULL,
       'Introdução à Computação para Controle e Automação',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       1, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Introdução à Computação para Controle e Automação' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Controle'),
       NULL,
       'Pré-Cálculo',
       NULL,
       90, 0, 6,
       'OBRIGATORIA',
       1, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Pré-Cálculo' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Controle'),
       NULL,
       'Introdução a Geometria Analítica e Variáveis Complexas',
       NULL,
       30, 0, 2,
       'OBRIGATORIA',
       1, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Introdução a Geometria Analítica e Variáveis Complexas' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Química Geral e Experimental',
       NULL,
       75, 0, 5,
       'OBRIGATORIA',
       1, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Química Geral e Experimental' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Ciências do Ambiente',
       NULL,
       0, 30, 2,
       'OBRIGATORIA',
       2, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Ciências do Ambiente' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Algoritmos e Estrutura de Dados',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       2, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Algoritmos e Estrutura de Dados' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Automação'),
       NULL,
       'Sistemas Digitais I',
       NULL,
       45, 0, 3,
       'OBRIGATORIA',
       2, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Sistemas Digitais I' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Cálculo Diferencial e Integral I',
       NULL,
       90, 0, 6,
       'OBRIGATORIA',
       2, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Cálculo Diferencial e Integral I' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Geometria Analítica',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       2, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Geometria Analítica' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Física Geral I',
       NULL,
       90, 0, 6,
       'OBRIGATORIA',
       2, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Física Geral I' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Automação'),
       NULL,
       'Programação Orientada a Objetos',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       3, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Programação Orientada a Objetos' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Automação'),
       NULL,
       'Sistemas Digitais II',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       3, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Sistemas Digitais II' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Cálculo Diferencial e Integral II',
       NULL,
       90, 0, 6,
       'OBRIGATORIA',
       3, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Cálculo Diferencial e Integral II' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Álgebra Linear',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       3, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Álgebra Linear' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Física Geral II',
       NULL,
       90, 0, 6,
       'OBRIGATORIA',
       3, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Física Geral II' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Automação'),
       NULL,
       'Projetos com Sistemas Digitais',
       NULL,
       45, 0, 3,
       'OBRIGATORIA',
       4, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Projetos com Sistemas Digitais' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Cálculo Numérico',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       4, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Cálculo Numérico' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Cálculo Diferencial e Integral III',
       NULL,
       75, 0, 5,
       'OBRIGATORIA',
       4, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Cálculo Diferencial e Integral III' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Instrumentação'),
       NULL,
       'Laboratório de Circuitos Elétricos',
       NULL,
       30, 0, 2,
       'OBRIGATORIA',
       4, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Laboratório de Circuitos Elétricos' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Instrumentação'),
       NULL,
       'Circuitos Elétricos',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       4, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Circuitos Elétricos' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Física Geral III',
       NULL,
       90, 0, 6,
       'OBRIGATORIA',
       4, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Física Geral III' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Automação'),
       NULL,
       'Arquitetura de Computadores e Sistemas Embarcados',
       NULL,
       75, 0, 5,
       'OBRIGATORIA',
       5, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Arquitetura de Computadores e Sistemas Embarcados' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Controle'),
       NULL,
       'Análise de Sinais e Sistemas',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       5, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Análise de Sinais e Sistemas' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Instrumentação'),
       NULL,
       'Laboratório de Dispositivos e Circuitos Eletrônicos Básicos',
       NULL,
       30, 0, 2,
       'OBRIGATORIA',
       5, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Laboratório de Dispositivos e Circuitos Eletrônicos Básicos' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Instrumentação'),
       NULL,
       'Dispositivos e Circuitos Eletrônicos Básicos',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       5, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Dispositivos e Circuitos Eletrônicos Básicos' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Instrumentação'),
       NULL,
       'Fenômenos de Transporte',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       5, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Fenômenos de Transporte' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Física Geral IV',
       NULL,
       75, 0, 5,
       'OBRIGATORIA',
       5, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Física Geral IV' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Automação'),
       NULL,
       'Comunicação de Dados',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       6, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Comunicação de Dados' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Automação'),
       NULL,
       'Sistemas Microcontrolados',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       6, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Sistemas Microcontrolados' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Controle'),
       NULL,
       'Modelagem de Sistemas Dinâmicos',
       NULL,
       45, 0, 3,
       'OBRIGATORIA',
       6, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Modelagem de Sistemas Dinâmicos' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Instrumentação'),
       NULL,
       'Laboratório de Instrumentação Industrial',
       NULL,
       30, 0, 2,
       'OBRIGATORIA',
       6, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Laboratório de Instrumentação Industrial' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Instrumentação'),
       NULL,
       'Instrumentação Industrial I',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       6, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Instrumentação Industrial I' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Ciência dos Materiais',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       6, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Ciência dos Materiais' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Mecânica dos Sólidos',
       NULL,
       45, 0, 3,
       'OBRIGATORIA',
       6, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Mecânica dos Sólidos' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Segurança do Trabalho',
       NULL,
       0, 30, 2,
       'OBRIGATORIA',
       7, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Segurança do Trabalho' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Gestão e Normativas'),
       NULL,
       'Segurança em Área Industrial',
       NULL,
       0, 30, 2,
       'OBRIGATORIA',
       7, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Segurança em Área Industrial' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Automação'),
       NULL,
       'Redes para Controle e Automação',
       NULL,
       90, 0, 6,
       'OBRIGATORIA',
       7, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Redes para Controle e Automação' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Controle'),
       NULL,
       'Controle Automático',
       NULL,
       90, 0, 6,
       'OBRIGATORIA',
       7, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Controle Automático' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Probabilidade e Estatística',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       7, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Probabilidade e Estatística' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Instrumentação'),
       NULL,
       'Eletrônica de Potência',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       7, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Eletrônica de Potência' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Metodologia Científica',
       NULL,
       0, 30, 2,
       'OBRIGATORIA',
       8, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Metodologia Científica' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Gestão e Normativas'),
       NULL,
       'Processo de Fabricação',
       NULL,
       30, 0, 2,
       'OBRIGATORIA',
       8, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Processo de Fabricação' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Expressão Gráfica',
       NULL,
       45, 0, 3,
       'OBRIGATORIA',
       8, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Expressão Gráfica' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Automação'),
       NULL,
       'Programação de Controlador Lógico Programável',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       8, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Programação de Controlador Lógico Programável' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Controle'),
       NULL,
       'Inteligência Artificial',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       8, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Inteligência Artificial' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Controle'),
       NULL,
       'Controle de Processos',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       8, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Controle de Processos' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Instrumentação'),
       NULL,
       'Comandos e Proteção em Baixa Tensão',
       NULL,
       30, 0, 2,
       'OBRIGATORIA',
       8, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Comandos e Proteção em Baixa Tensão' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Projeto Final de Curso I',
       NULL,
       15, 0, 1,
       'OBRIGATORIA',
       9, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Projeto Final de Curso I' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Gestão e Normativas'),
       NULL,
       'Gerência de Projetos',
       NULL,
       30, 0, 2,
       'OBRIGATORIA',
       9, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Gerência de Projetos' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Gestão e Normativas'),
       NULL,
       'Manufatura Integrada',
       NULL,
       30, 0, 2,
       'OBRIGATORIA',
       9, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Manufatura Integrada' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Gestão e Normativas'),
       NULL,
       'Controle Estatístico de Processos',
       NULL,
       45, 15, 4,
       'OBRIGATORIA',
       9, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Controle Estatístico de Processos' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       (SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Automação Integrada'),
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Automação'),
       NULL,
       'Segurança Digital',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       9, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Segurança Digital' AND cx.emphasis_id=(SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Automação Integrada'));

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       (SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Automação Integrada'),
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Automação'),
       NULL,
       'Sistemas Operacionais',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       9, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Sistemas Operacionais' AND cx.emphasis_id=(SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Automação Integrada'));

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       (SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Automação Integrada'),
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Automação'),
       NULL,
       'Robótica',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       9, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Robótica' AND cx.emphasis_id=(SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Automação Integrada'));

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       (SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Sistemas Inteligentes'),
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Controle'),
       NULL,
       'Controle Preditivo',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       9, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Controle Preditivo' AND cx.emphasis_id=(SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Sistemas Inteligentes'));

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       (SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Sistemas Inteligentes'),
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Controle'),
       NULL,
       'Controle Digital',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       9, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Controle Digital' AND cx.emphasis_id=(SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Sistemas Inteligentes'));

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       (SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Instrumentação'),
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Instrumentação'),
       NULL,
       'Instrumentação Analítica I',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       9, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Instrumentação Analítica I' AND cx.emphasis_id=(SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Instrumentação'));

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       (SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Instrumentação'),
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Instrumentação'),
       NULL,
       'Acionamentos Hidráulicos e Pneumáticos',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       9, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Acionamentos Hidráulicos e Pneumáticos' AND cx.emphasis_id=(SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Instrumentação'));

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       (SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Instrumentação'),
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Instrumentação'),
       NULL,
       'Acionamentos de Máquinas Elétricas',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       9, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Acionamentos de Máquinas Elétricas' AND cx.emphasis_id=(SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Instrumentação'));

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Básico'),
       NULL,
       'Projeto Final de Curso II',
       NULL,
       0, 15, 1,
       'OBRIGATORIA',
       10, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Projeto Final de Curso II' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Gestão e Normativas'),
       NULL,
       'Administração para Engenharia',
       NULL,
       30, 0, 2,
       'OBRIGATORIA',
       10, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Administração para Engenharia' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Gestão e Normativas'),
       NULL,
       'Economia para Engenharia',
       NULL,
       30, 0, 2,
       'OBRIGATORIA',
       10, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Economia para Engenharia' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       NULL,
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Gestão e Normativas'),
       NULL,
       'Empreendedorismo',
       NULL,
       30, 0, 2,
       'OBRIGATORIA',
       10, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Empreendedorismo' AND cx.emphasis_id IS NULL);

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       (SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Automação Integrada'),
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Automação'),
       NULL,
       'Integração de Sistemas de Automação',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       10, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Integração de Sistemas de Automação' AND cx.emphasis_id=(SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Automação Integrada'));

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       (SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Sistemas Inteligentes'),
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Controle'),
       NULL,
       'Controle Inteligente',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       10, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Controle Inteligente' AND cx.emphasis_id=(SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Sistemas Inteligentes'));

INSERT INTO course (curriculum_id, emphasis_id, nucleo_id, code, name, ementa, ch_presencial, ch_distancia, credits, type, period_suggested, is_active)
SELECT c.id,
       (SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Instrumentação'),
       (SELECT n.id FROM nucleo n JOIN degree d2 ON d2.id=n.degree_id WHERE d2.code='CECA' AND n.name='Instrumentação'),
       NULL,
       'Instrumentação Analítica II',
       NULL,
       60, 0, 4,
       'OBRIGATORIA',
       10, 1
FROM curriculum c JOIN degree d ON d.id=c.degree_id AND d.code='CECA'
WHERE c.name='Matriz ano 2019' AND c.version=2019
  AND NOT EXISTS (
    SELECT 1 FROM course cx WHERE cx.curriculum_id=c.id AND cx.name='Instrumentação Analítica II' AND cx.emphasis_id=(SELECT e.id FROM emphasis e WHERE e.curriculum_id=c.id AND e.name='Instrumentação'));
