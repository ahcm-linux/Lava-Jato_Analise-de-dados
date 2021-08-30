-- update old tables

UPDATE	consulta_cand_2018
SET	st_reeleicao = 'S'
WHERE		nr_cpf_candidato LIKE '%4240952387%'
    	OR	nr_cpf_candidato LIKE '%73255319820%';

-- create new tables

CREATE TABLE perfil_candidatos (
	sq_candidato_2018 		TEXT NOT NULL,
	nm_candidato			TEXT,
	nm_urna_candidato 		TEXT,
	nr_cpf_candidato  		TEXT NOT NULL,
	ds_cargo	 		TEXT,
	sg_uf 				TEXT,
	nm_ue 				TEXT,
	sg_partido_2018 		TEXT,
	nr_idade_data_posse 		INTEGER,
	ds_genero 			TEXT,
	ds_grau_instrucao 		TEXT,
	ds_estado_civil 		TEXT,
	ds_cor_raca 			TEXT,
	ds_situacao_candidatura 	TEXT,
	ds_situacao_candidato_urna 	TEXT,
	ds_sit_tot_turno		TEXT,
	st_reeleicao			TEXT,
	PRIMARY KEY(sq_candidato_2018, nr_cpf_candidato)
);

CREATE TABLE sq_cpf_2014 (
	sq_candidato_2014 		TEXT PRIMARY KEY,
	nr_cpf_candidato		TEXT,
	FOREIGN KEY(nr_cpf_candidato) 	REFERENCES perfil_candidatos(nr_cpf_candidato)
);

CREATE TABLE total_bens_candidatos (
	total_bem_candidato 		REAL,
	sq_candidato_2018		TEXT,
	FOREIGN KEY(sq_candidato_2018) 	REFERENCES perfil_candidatos(sq_candidato_2018)
);

CREATE TABLE total_receitas_candidatos (
	total_vr_receita_candidato	REAL,
        sq_candidato_2018               TEXT,
	FOREIGN KEY(sq_candidato_2018) 	REFERENCES perfil_candidatos(sq_candidato_2018)
);

CREATE TABLE total_receitas_partidos (
	total_vr_receita_partido	REAL,
	sg_uf				TEXT,
        sg_partido_2018			TEXT,
	FOREIGN KEY(sg_partido_2018) 	REFERENCES perfil_candidatos(sg_partido_2018)
);

CREATE TABLE total_votos_candidatos (
	total_qt_votos_nominais_2018	REAL,
        sq_candidato_2018               TEXT,
	FOREIGN KEY(sq_candidato_2018) 	REFERENCES perfil_candidatos(sq_candidato_2018)
);

CREATE TABLE total_votos_candidatos_2014 (
	total_qt_votos_nominais_2014	REAL,
        sq_candidato_2014               TEXT,
	FOREIGN KEY(sq_candidato_2014) 	REFERENCES sq_cpf_2014(sq_candidato_2014)
);

CREATE TABLE dados (
	sq_candidato_2014		TEXT,
	sq_candidato_2018 		TEXT,
	nm_candidato			TEXT,
	nm_urna_candidato 		TEXT,
	nr_cpf_candidato  		TEXT PRIMARY KEY,
	ds_cargo	 		TEXT,
	sg_uf 				TEXT,
	nm_ue 				TEXT,
	sg_partido_2018 		TEXT,
	nr_idade_data_posse 		INTEGER,
	ds_genero 			TEXT,
	ds_grau_instrucao 		TEXT,
	ds_estado_civil 		TEXT,
	ds_cor_raca 			TEXT,
	ds_situacao_candidatura 	TEXT,
	ds_situacao_candidato_urna 	TEXT,
	ds_sit_tot_turno		TEXT,
	st_reeleicao			TEXT,
	total_bem_candidato		REAL,
        total_vr_receita_candidato	REAL,
	total_vr_receita_partido	REAL,
	total_qt_votos_nominais_2014	INTEGER,
        total_qt_votos_nominais_2018	INTEGER
);

-- populate new tables

INSERT INTO perfil_candidatos
	SELECT 	sq_candidato, nm_candidato, nm_urna_candidato, CAST(nr_cpf_candidato AS INTEGER),
		ds_cargo, sg_uf, nm_ue, sg_partido, nr_idade_data_posse,
		ds_genero, ds_grau_instrucao, ds_estado_civil, ds_cor_raca,
		ds_situacao_candidatura, ds_situacao_candidato_urna,
		ds_sit_tot_turno, st_reeleicao
	FROM	consulta_cand_2018
	WHERE 		ds_cargo == 'DEPUTADO FEDERAL'
		AND	ds_situacao_candidatura == 'APTO'
		AND	ds_situacao_candidato_urna LIKE 'DEFERIDO%'
		AND	ds_genero != 'NÃO DIVULGÁVEL'
		AND	ds_grau_instrucao != 'NÃO DIVULGÁVEL'
		AND	ds_estado_civil != 'NÃO DIVULGÁVEL'
		AND	ds_cor_raca != 'NÃO DIVULGÁVEL'
		AND	st_reeleicao == 'S';

INSERT INTO sq_cpf_2014
	SELECT  t1.sq_candidato, CAST(t1.nr_cpf_candidato AS INTEGER)
	FROM	consulta_cand_2014	AS t1
	JOIN	perfil_candidatos 	AS t2 ON CAST(t1.nr_cpf_candidato AS INTEGER) == t2.nr_cpf_candidato
	WHERE		t1.ds_sit_tot_turno LIKE '%ELEITO%' OR t1.ds_sit_tot_turno == 'SUPLENTE'
 		AND	t1.ds_cargo == 'DEPUTADO FEDERAL'
		AND	t1.ds_situacao_candidatura == 'APTO'
		AND	t1.ds_situacao_candidato_urna LIKE 'DEFERIDO%'
		AND	t1.ds_genero != 'NÃO DIVULGÁVEL'
		AND	t1.ds_grau_instrucao != 'NÃO DIVULGÁVEL'
		AND	t1.ds_estado_civil != 'NÃO DIVULGÁVEL'
		AND	t1.ds_cor_raca != 'NÃO DIVULGÁVEL';

INSERT INTO total_bens_candidatos
	SELECT	   	SUM(CAST(REPLACE(t1.vr_bem_candidato, ',', '.') AS REAL)) AS total_bem_candidato, t1.sq_candidato
	FROM	    	bem_candidato_2018 AS t1, perfil_candidatos AS t2
	WHERE	   	t1.sq_candidato == t2.sq_candidato_2018
	GROUP BY    	t1.sq_candidato;

INSERT INTO total_receitas_candidatos
	SELECT		SUM(CAST(REPLACE(t1.vr_receita, ',', '.') AS REAL)) AS total_vr_receita_candidato, t1.sq_candidato
	FROM		prestacao_de_contas_eleitorais_candidatos_2018 AS t1, perfil_candidatos AS t2
	WHERE		t1.sq_candidato == t2.sq_candidato_2018
	GROUP BY    	t1.sq_candidato;

INSERT INTO total_receitas_partidos
	SELECT		SUM(CAST(REPLACE(t1.vr_receita, ',', '.') AS REAL)) AS total_vr_bem_receita_partido, t1.sg_uf, t1.sg_partido
	FROM		prestacao_de_contas_eleitorais_orgaos_partidarios_2018 AS t1, perfil_candidatos AS t2
	WHERE		t1.sg_partido == t2.sg_partido_2018 AND t1.sg_uf == t2.sg_uf
	GROUP BY    	t1.sg_partido, t1.sg_uf;

INSERT INTO total_votos_candidatos
	SELECT		SUM(CAST(REPLACE(t1.qt_votos_nominais, ',', '.') AS INTEGER)) AS total_qt_votos_nominais, t1.sq_candidato
	FROM		votacao_candidato_munzona_2018 AS t1, perfil_candidatos AS t2
	WHERE		t1.sq_candidato == t2.sq_candidato_2018
	GROUP BY    	t1.sq_candidato;

INSERT INTO total_votos_candidatos_2014
	SELECT		SUM(CAST(REPLACE(t1.qt_votos_nominais, ',', '.') AS INTEGER)) AS total_qt_votos_nominais, t1.sq_candidato
	FROM		votacao_candidato_munzona_2014 AS t1, sq_cpf_2014 AS t2
	WHERE		t1.sq_candidato == t2.sq_candidato_2014
	GROUP BY    	t1.sq_candidato;

INSERT INTO dados
	SELECT	vc14.sq_candidato_2014, pc.*, bc.total_bem_candidato,
		rc.total_vr_receita_candidato, rp.total_vr_receita_partido,
		vc14.total_qt_votos_nominais_2014, vc.total_qt_votos_nominais_2018
	FROM	perfil_candidatos 					AS pc
	LEFT JOIN	total_bens_candidatos 					AS bc	USING(sq_candidato_2018)
	JOIN	total_receitas_candidatos				AS rc 	USING(sq_candidato_2018)
	JOIN	total_receitas_partidos 				AS rp 	USING(sg_partido_2018, sg_uf)
	JOIN	total_votos_candidatos 					AS vc 	USING(sq_candidato_2018)
	JOIN	(SELECT t1.*, t2.nr_cpf_candidato
		 FROM 	total_votos_candidatos_2014	AS t1,
			sq_cpf_2014 			AS t2
		 WHERE 	t1.sq_candidato_2014 == t2.sq_candidato_2014) 	AS vc14 USING(nr_cpf_candidato);

-- drop old tables

--DROP TABLE consulta_cand_2018;

--DROP TABLE bem_candidato_2018;

--DROP TABLE prestacao_de_contas_eleitorais_candidatos_2018;

--DROP TABLE prestacao_de_contas_eleitorais_orgaos_partidarios_2018;

--DROP TABLE votacao_candidato_munzona_2014;

--DROP TABLE votacao_candidato_munzona_2018;

--DROP TABLE consulta_cand_2014;

-- replacements

-- ds_grau_instrucao
UPDATE  dados
SET     ds_grau_instrucao = 'superior'
WHERE   ds_grau_instrucao LIKE '%SUPERIOR%';

UPDATE  dados
SET     ds_grau_instrucao = 'não-superior'
WHERE   ds_grau_instrucao LIKE '%MÉDIO%';

UPDATE  dados
SET     ds_grau_instrucao = 'não-superior'
WHERE   ds_grau_instrucao LIKE '%FUNDAMENTAL%' OR ds_grau_instrucao LIKE '%ESCREVE%';

-- ds_estado_civil
UPDATE  dados
SET     ds_estado_civil = 'solteiro'
WHERE   ds_estado_civil == 'SOLTEIRO(A)';

UPDATE  dados
SET     ds_estado_civil = 'não-solteiro'
WHERE   ds_estado_civil != 'solteiro';

-- ds_cor_raca
UPDATE  dados
SET     ds_cor_raca = 'outro'
WHERE   ds_cor_raca NOT IN ('BRANCA', 'PRETA');
