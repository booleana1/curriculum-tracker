WITH mapping(name, code) AS (
  VALUES
    ('Sociologia e Cidadania','CECA101'),
    ('Ética e Legislação Profissional','CECA102'),
    ('Comunicação e Expressão','CECA103'),
    ('Introdução à Computação para Controle e Automação','CECA104'),
    ('Pré-Cálculo','CECA105'),
    ('Introdução a Geometria Analítica e Variáveis Complexas','CECA106'),
    ('Química Geral e Experimental','CECA107'),

    ('Ciências do Ambiente','CECA201'),
    ('Algoritmos e Estrutura de Dados','CECA202'),
    ('Sistemas Digitais I','CECA203'),
    ('Cálculo Diferencial e Integral I','CECA204'),
    ('Geometria Analítica','CECA205'),
    ('Física Geral I','CECA206'),

    ('Programação Orientada a Objetos','CECA301'),
    ('Sistemas Digitais II','CECA302'),
    ('Cálculo Diferencial e Integral II','CECA303'),
    ('Álgebra Linear','CECA304'),
    ('Física Geral II','CECA305'),

    ('Projetos com Sistemas Digitais','CECA401'),
    ('Cálculo Numérico','CECA402'),
    ('Cálculo Diferencial e Integral III','CECA403'),
    ('Laboratório de Circuitos Elétricos','CECA404'),
    ('Circuitos Elétricos','CECA405'),
    ('Física Geral III','CECA406'),

    ('Arquitetura de Computadores e Sistemas Embarcados','CECA501'),
    ('Análise de Sinais e Sistemas','CECA502'),
    ('Laboratório de Dispositivos e Circuitos Eletrônicos Básicos','CECA503'),
    ('Dispositivos e Circuitos Eletrônicos Básicos','CECA504'),
    ('Fenômenos de Transporte','CECA505'),
    ('Física Geral IV','CECA506'),

    ('Comunicação de Dados','CECA601'),
    ('Sistemas Microcontrolados','CECA602'),
    ('Modelagem de Sistemas Dinâmicos','CECA603'),
    ('Laboratório de Instrumentação Industrial','CECA604'),
    ('Instrumentação Industrial I','CECA605'),
    ('Ciência dos Materiais','CECA606'),
    ('Mecânica dos Sólidos','CECA607'),

    ('Segurança do Trabalho','CECA701'),
    ('Segurança em Área Industrial','CECA702'),
    ('Redes para Controle e Automação','CECA703'),
    ('Controle Automático','CECA704'),
    ('Probabilidade e Estatística','CECA705'),
    ('Eletrônica de Potência','CECA706'),

    ('Metodologia Científica','CECA801'),
    ('Processo de Fabricação','CECA802'),
    ('Expressão Gráfica','CECA803'),
    ('Programação de Controlador Lógico Programável','CECA804'),
    ('Inteligência Artificial','CECA805'),
    ('Controle de Processos','CECA806'),
    ('Comandos e Proteção em Baixa Tensão','CECA807'),

    ('Projeto Final de Curso I','CECA901'),
    ('Gerência de Projetos','CECA902'),
    ('Manufatura Integrada','CECA903'),
    ('Controle Estatístico de Processos','CECA904'),
    ('Segurança Digital','CECA905'),
    ('Sistemas Operacionais','CECA906'),
    ('Robótica','CECA907'),
    ('Controle Preditivo','CECA908'),
    ('Controle Digital','CECA909'),
    ('Instrumentação Analítica I','CECA910'),
    ('Acionamentos Hidráulicos e Pneumáticos','CECA911'),
    ('Acionamentos de Máquinas Elétricas','CECA912'),

    ('Projeto Final de Curso II','CECA1001'),
    ('Administração para Engenharia','CECA1002'),
    ('Economia para Engenharia','CECA1003'),
    ('Empreendedorismo','CECA1004'),
    ('Integração de Sistemas de Automação','CECA1005'),
    ('Controle Inteligente','CECA1006'),
    ('Instrumentação Analítica II','CECA1007')
)
UPDATE course
SET code = (SELECT m.code FROM mapping m WHERE m.name = course.name)
WHERE name IN (SELECT name FROM mapping);
