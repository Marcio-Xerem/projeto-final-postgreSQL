-- =====================================================
-- SISTEMA DE APURAÇÃO DE NOTAS DO CARNAVAL
-- HOMENAGEM ÀS PERSONALIDADES HISTÓRICAS DO CARNAVAL DO RJ
-- Banco de Dados: bd_carnaval
-- Autor: Márcio da Mota Xerém
-- Data: 14/02/2026
-- =====================================================
-- =====================================================
-- 1. CRIAÇÃO DO BANCO DE DADOS
-- =====================================================
CREATE DATABASE bd_carnaval;

-- =====================================================
-- 2. CRIAÇÃO DAS TABELAS
-- =====================================================
-- Tabela: Quesitos
CREATE TABLE quesitos (
    id_quesito SERIAL PRIMARY KEY,
    nome_quesito VARCHAR(45) NOT NULL UNIQUE,
    descricao TEXT
);

-- Tabela: Escolas de Samba
CREATE TABLE escolas (
    id_escola SERIAL PRIMARY KEY,
    nome_escola VARCHAR(50) NOT NULL UNIQUE
);

-- Tabela: Jurados
CREATE TABLE jurados (
    id_jurado SERIAL PRIMARY KEY,
    nome_jurado VARCHAR(100) NOT NULL,
    foto BYTEA
);

-- Tabela: Notas
CREATE TABLE notas (
    id_nota SERIAL PRIMARY KEY,
    fk_id_escola INTEGER NOT NULL,
    fk_id_jurado INTEGER NOT NULL,
    fk_id_quesito INTEGER NOT NULL,
    nota DECIMAL(3, 1) NOT NULL CHECK (
        nota >= 9.0
        AND nota <= 10.0
    ),
    data_lancamento TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fk_id_escola) REFERENCES escolas(id_escola),
    FOREIGN KEY (fk_id_jurado) REFERENCES jurados(id_jurado),
    FOREIGN KEY (fk_id_quesito) REFERENCES quesitos(id_quesito)
);

-- =====================================================
-- 3. ADIÇÃO DE CONSTRAINTS
-- =====================================================
-- Constraint única: Um jurado não pode dar mais de uma nota para o mesmo quesito da mesma escola
ALTER TABLE
    notas
ADD
    CONSTRAINT uk_nota_unica UNIQUE (fk_id_escola, fk_id_jurado, fk_id_quesito);

-- =====================================================
-- 4. INSERÇÃO DE DADOS
-- =====================================================
-- Inserir Quesitos
INSERT INTO
    quesitos (nome_quesito, descricao)
VALUES
    (
        'Samba-enredo',
        'Avaliação da letra, melodia e interpretação do samba'
    ),
    (
        'Alegorias',
        'Avaliação das alegorias e adereços'
    ),
    (
        'Casal de Mestre-sala e Porta-bandeira',
        'Avaliação da performance e harmonia do casal'
    ),
    (
        'Bateria',
        'Avaliação do ritmo, cadência e harmonia da bateria'
    );

-- Inserir Escolas de Samba
INSERT INTO
    escolas (nome_escola)
VALUES
    ('Unidos da Tijuca'),
    ('Portela'),
    ('Mangueira'),
    ('Salgueiro'),
    ('Beija-Flor');

-- Inserir Jurados - HOMENAGEM ÀS PERSONALIDADES HISTÓRICAS DO CARNAVAL RJ
INSERT INTO
    jurados (nome_jurado)
VALUES
    ('Clóvis Bornay'),
    ('Wilza Carla'),
    ('Evandro de Castro Lima'),
    ('Hermínia Paiva'),
    ('Mauro Rosas');

-- Inserir Notas da Escola Mangueira (5 jurados x 4 quesitos = 20 notas)
INSERT INTO
    notas (fk_id_escola, fk_id_jurado, fk_id_quesito, nota)
VALUES
    -- Clóvis Bornay - Mangueira
    (3, 1, 1, 9.9),
    (3, 1, 2, 10.0),
    (3, 1, 3, 9.8),
    (3, 1, 4, 10.0),
    -- Wilza Carla - Mangueira
    (3, 2, 1, 10.0),
    (3, 2, 2, 9.9),
    (3, 2, 3, 9.7),
    (3, 2, 4, 10.0),
    -- Evandro de Castro Lima - Mangueira
    (3, 3, 1, 9.8),
    (3, 3, 2, 10.0),
    (3, 3, 3, 9.9),
    (3, 3, 4, 9.9),
    -- Hermínia Paiva - Mangueira
    (3, 4, 1, 9.9),
    (3, 4, 2, 9.8),
    (3, 4, 3, 10.0),
    (3, 4, 4, 10.0),
    -- Mauro Rosas - Mangueira
    (3, 5, 1, 9.7),
    (3, 5, 2, 9.9),
    (3, 5, 3, 9.8),
    (3, 5, 4, 9.8),
    -- Hermínia Paiva - Beija-Flor
    (5, 4, 1, 9.3),
    (5, 4, 2, 9.4),
    (5, 4, 3, 9.3),
    (5, 4, 4, 9.1),
    -- Mauro Rosas - Beija-Flor
    (5, 5, 1, 9.5),
    (5, 5, 2, 9.5),
    (5, 5, 3, 9.8),
    (5, 5, 4, 9.9),
    -- Clóvis Bornay - Beija-Flor
    (5, 1, 1, 9.3),
    (5, 1, 2, 9.7),
    (5, 1, 3, 9.9),
    (5, 1, 4, 10.0),
    -- Wilza Carla - Beija-Flor
    (5, 2, 1, 9.7),
    (5, 2, 2, 9.8),
    (5, 2, 3, 10.0),
    (5, 2, 4, 9.9),
    -- Evandro de Castro Lima - Beija-Flor
    (5, 3, 1, 9.9),
    (5, 3, 2, 9.9),
    (5, 3, 3, 10.0),
    (5, 3, 4, 10.0);

-- =====================================================
-- 5. CRIAÇÃO DE VIEWS
-- =====================================================
-- VIEW 1: Notas Individuais de Cada Jurado
CREATE
OR REPLACE VIEW vw_notas_individuais AS
SELECT
    e.nome_escola,
    q.nome_quesito,
    j.nome_jurado,
    n.nota
FROM
    notas n
    JOIN escolas e ON n.fk_id_escola = e.id_escola
    JOIN jurados j ON n.fk_id_jurado = j.id_jurado
    JOIN quesitos q ON n.fk_id_quesito = q.id_quesito
ORDER BY
    e.nome_escola,
    q.nome_quesito,
    j.nome_jurado;

-- VIEW 2: Nota Final de Cada Quesito (descarta menor nota e calcula média das 4 maiores)
CREATE
OR REPLACE VIEW vw_nota_final_quesito AS WITH notas_com_ranking AS (
    SELECT
        n.fk_id_escola,
        e.nome_escola,
        n.fk_id_quesito,
        q.nome_quesito,
        n.nota,
        ROW_NUMBER() OVER (
            PARTITION BY n.fk_id_escola,
            n.fk_id_quesito
            ORDER BY
                n.nota ASC
        ) as posicao,
        COUNT(*) OVER (PARTITION BY n.fk_id_escola, n.fk_id_quesito) as total_notas
    FROM
        notas n
        JOIN escolas e ON n.fk_id_escola = e.id_escola
        JOIN quesitos q ON n.fk_id_quesito = q.id_quesito
)
SELECT
    nome_escola,
    nome_quesito,
    ROUND(
        MIN(
            CASE
                WHEN posicao = 1 THEN nota
            END
        ),
        1
    ) as menor_nota_descartada,
    ROUND(
        AVG(nota) FILTER (
            WHERE
                posicao > 1
        ),
        3
    ) as nota_final
FROM
    notas_com_ranking
WHERE
    total_notas >= 5
GROUP BY
    fk_id_escola,
    nome_escola,
    fk_id_quesito,
    nome_quesito
ORDER BY
    nome_escola,
    nome_quesito;

-- VIEW 3: Pontuação Total de Cada Escola (soma das notas finais dos quesitos)
CREATE
OR REPLACE VIEW vw_pontuacao_total AS
SELECT
    nome_escola,
    ROUND(SUM(nota_final), 3) AS pontuacao_total
FROM
    vw_nota_final_quesito
GROUP BY
    nome_escola
ORDER BY
    pontuacao_total DESC;

-- VIEW 4: Escola Vencedora (maior pontuação total)
CREATE
OR REPLACE VIEW vw_escola_vencedora AS
SELECT
    nome_escola,
    pontuacao_total
FROM
    vw_pontuacao_total
ORDER BY
    pontuacao_total DESC
LIMIT
    1;

-- =====================================================
-- 6. CRIAÇÃO DE FUNCTIONS
-- =====================================================
-- FUNCTION: Calcular nota final de um quesito específico
CREATE FUNCTION fn_calcular_nota_final(
    p_id_escola INTEGER,
    p_id_quesito INTEGER
) RETURNS NUMERIC AS $ $ DECLARE v_notas NUMERIC [];

v_soma NUMERIC := 0;

i INTEGER;

BEGIN -- Pegar todas as notas ordenadas
SELECT
    ARRAY_AGG(
        nota
        ORDER BY
            nota ASC
    ) INTO v_notas
FROM
    notas
WHERE
    fk_id_escola = p_id_escola
    AND fk_id_quesito = p_id_quesito;

-- Calcular a média das 4 maiores notas (descartar a menor)
FOR i IN 2..5 LOOP v_soma := v_soma + v_notas [i];

END LOOP;

RETURN ROUND(v_soma / 4.0, 3);

END;

$ $ LANGUAGE plpgsql;

-- =====================================================
-- 7. CRIAÇÃO DE PROCEDURES
-- =====================================================
-- PROCEDURE: Apurar notas de uma escola
CREATE PROCEDURE sp_apurar_escola(IN p_id_escola INTEGER) AS $ $ DECLARE v_quesito RECORD;

v_nota_final NUMERIC;

v_nome_escola VARCHAR(50);

BEGIN
SELECT
    nome_escola INTO v_nome_escola
FROM
    escolas
WHERE
    id_escola = p_id_escola;

RAISE NOTICE 'APURAÇÃO: %',
v_nome_escola;

RAISE NOTICE '=====================================';

FOR v_quesito IN
SELECT
    id_quesito,
    nome_quesito
FROM
    quesitos LOOP
SELECT
    fn_calcular_nota_final(p_id_escola, v_quesito.id_quesito) INTO v_nota_final;

RAISE NOTICE 'Quesito: % | Nota Final: %',
v_quesito.nome_quesito,
v_nota_final;

END LOOP;

END;

$ $ LANGUAGE plpgsql;

-- =====================================================
-- 8. CONSULTAS ÚTEIS
-- =====================================================
-- Consultar todas as notas individuais
SELECT
    *
FROM
    vw_notas_individuais;

-- Consultar nota final de cada quesito
SELECT
    *
FROM
    vw_nota_final_quesito;

-- Consultar pontuação total de cada escola
SELECT
    *
FROM
    vw_pontuacao_total;

-- Consultar escola vencedora
SELECT
    *
FROM
    vw_escola_vencedora;

-- Consultar quantidade de notas por escola
SELECT
    e.nome_escola,
    COUNT(*) as total_notas,
    COUNT(DISTINCT n.fk_id_jurado) as total_jurados,
    COUNT(DISTINCT n.fk_id_quesito) as total_quesitos
FROM
    notas n
    JOIN escolas e ON n.fk_id_escola = e.id_escola
GROUP BY
    e.nome_escola
ORDER BY
    e.nome_escola;

-- Execução da function
SELECT
    fn_calcular_nota_final(3, 1) as nota_final_mangueira_samba;

-- Execução da procedure
CALL sp_apurar_escola(3);


-- =====================================================
-- INSERÇÃO DE NOTAS - PORTELA
-- =====================================================

INSERT INTO
    notas (fk_id_escola, fk_id_jurado, fk_id_quesito, nota)
VALUES
    -- ====================================
    -- JURADO 1: Clóvis Bornay - Portela
    -- ====================================
    (2, 1, 1, 9.8),
    -- Samba-enredo: 9.8
    (2, 1, 2, 9.9),
    -- Alegorias: 9.9
    (2, 1, 3, 9.7),
    -- Casal de Mestre-sala e Porta-bandeira: 9.7
    (2, 1, 4, 9.8),
    -- Bateria: 9.8
    -- ====================================
    -- JURADO 2: Wilza Carla - Portela
    -- ====================================
    (2, 2, 1, 9.7),
    -- Samba-enredo: 9.7
    (2, 2, 2, 9.8),
    -- Alegorias: 9.8
    (2, 2, 3, 9.8),
    -- Casal de Mestre-sala e Porta-bandeira: 9.8
    (2, 2, 4, 9.9),
    -- Bateria: 9.9
    -- ====================================
    -- JURADO 3: Evandro de Castro Lima - Portela
    -- ====================================
    (2, 3, 1, 9.9),
    -- Samba-enredo: 9.9
    (2, 3, 2, 9.7),
    -- Alegorias: 9.7
    (2, 3, 3, 9.6),
    -- Casal de Mestre-sala e Porta-bandeira: 9.6
    (2, 3, 4, 9.7),
    -- Bateria: 9.7
    -- ====================================
    -- JURADO 4: Hermínia Paiva - Portela
    -- ====================================
    (2, 4, 1, 9.6),
    -- Samba-enredo: 9.6
    (2, 4, 2, 9.9),
    -- Alegorias: 9.9
    (2, 4, 3, 9.9),
    -- Casal de Mestre-sala e Porta-bandeira: 9.9
    (2, 4, 4, 9.8),
    -- Bateria: 9.8
    -- ====================================
    -- JURADO 5: Mauro Rosas - Portela
    -- ====================================
    (2, 5, 1, 9.7),
    -- Samba-enredo: 9.7
    (2, 5, 2, 9.6),
    -- Alegorias: 9.6
    (2, 5, 3, 9.7),
    -- Casal de Mestre-sala e Porta-bandeira: 9.7
    (2, 5, 4, 9.7);

-- Bateria: 9.7

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================