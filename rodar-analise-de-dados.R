# CARREGAR ARQUIVOS EXTERNOS ---------------------------------------------------

source("./codigos-adicionais-do-R/carregar-pacotes.R") # carregar pacotes
source("./codigos-adicionais-do-R/carregar-funcoes.R") # carregar funções

# PARÂMETROS DO SCRIPT ---------------------------------------------------------

set.seed(2021) # fixar semente em algoritmos randômicos (bootstrap)

# CARREGAR DADOS ---------------------------------------------------------------

# carregar dados de todos os candidatos
dados_cand <- read.csv("./dados-Lava-Jato/dados-de-todos-os-candidatos.csv")

# carregar lista de candidatos envolvidos
cand_lavajato <- read.csv("./dados-Lava-Jato/lista-de-candidatos-envolvidos.csv")

# TRASNFORMAR DADOS ------------------------------------------------------------

# adicionar coluna que indica quais os candidatos envolvidos
cond <- dados_cand$nr_cpf_candidato %in% cand_lavajato$nr_cpf_candidato
dados_cand$lava_jato <- factor(ifelse(cond, "S", "N"))

# ANÁLISE DESCRITIVA -----------------------------------------------------------

# contagem de candidatos envolvidos e não envolvidos
tab_contagem_cand <- plyr::count(dados_cand, "lava_jato")

# gráfico de candidatos envolvidos por estado
p_estados <- plot_type_segments(dados_cand, "sg_uf", "Estado", "Nº de candidatos envolvidos na Lava Jato")

# gráfico de candidatos envolvidos por partido
p_partidos <- plot_type_segments(dados_cand, "sg_partido_2018", "Partido", "Nº de candidatos envolvidos na Lava Jato")

# gráfico de envolvolvidos e não envolvidos, por gênero
p_genero <- plot_type_stackedbars(dados_cand, "ds_genero", "Gênero", "Percentual")

# gráfico de envolvolvidos e não envolvidos, por grau de instrução
p_educacao <- plot_type_stackedbars(dados_cand, "ds_grau_instrucao", "Grau de instrução", "Percentual")

# gráfico de envolvolvidos e não envolvidos, estado civil
p_estadocivil <- plot_type_stackedbars(dados_cand, "ds_estado_civil", "Estado Civil", "Percentual")

# gráfico de envolvolvidos e não envolvidos, por etnia
p_etnia <- plot_type_stackedbars(dados_cand, "ds_cor_raca", "Etnia", "Percentual")

# gráfico de envolvolvidos e não envolvidos, por tipo de eleição
dados_temp <- dados_cand
dados_temp$ds_sit_tot_turno_new <- ifelse(dados_temp$ds_sit_tot_turno == "NÃO ELEITO", "Não eleito", "Eleito")

p_eleicao <- plot_type_stackedbars(dados_temp, "ds_sit_tot_turno_new", "Eleição", "Percentual")

# gráfico de envolvolvidos e não envolvidos, mostrando distribuição de idade
p_idade <- plot_type_boxplot(dados_cand, "nr_idade_data_posse", "Envolvimento na Lava Jato", "Idade na data da posse")

# gráfico de envolvolvidos e não envolvidos, mostrando distribuição de total de bens declarados
#dados_temp$total_bem_candidato_log <- log(dados_cand$total_bem_candidato) # não incluído nos outputs devido à presença de dados faltantes

p_bens <- plot_type_boxplot(dados_temp, "nr_idade_data_posse", "Envolvimento na Lava Jato", "Valor total dos bens declarados (log)")

# gráfico de envolvolvidos e não envolvidos, mostrando distribuição de total de receitas declarados
p_receitas <- plot_type_boxplot(dados_temp, "total_vr_receita_candidato", "Envolvimento na Lava Jato", "Valor total das receitas declaradas")

# gráfico de envolvolvidos e não envolvidos, mostrando distribuição de total de votos nominais em 2014
dados_temp$total_qt_votos_nominais_2014 <- log(dados_cand$total_qt_votos_nominais_2014)

p_votos14 <- plot_type_boxplot(dados_temp, "total_qt_votos_nominais_2014", "Envolvimento na Lava Jato", "Total de votos nominais em 2014 (log)")

# gráfico de envolvolvidos e não envolvidos, mostrando distribuição de total de votos nominais em 2018
dados_temp$total_qt_votos_nominais_2018 <- log(dados_cand$total_qt_votos_nominais_2018)

p_votos18 <- plot_type_boxplot(dados_temp, "total_qt_votos_nominais_2018", "Envolvimento na Lava Jato", "Total de votos nominais em 2018 (log)")

# descartar objeto dados_temp (o qual foi criado com para ser apenas temporário)
rm(list = "dados_temp")

# MATCHING ---------------------------------------------------------------------

# realizar matching
matching_1 <- matchit(lava_jato ~ ds_genero + ds_cor_raca + sg_uf +
                        ds_estado_civil + ds_grau_instrucao + sg_partido_2018 +
                        log(total_vr_receita_candidato) +
                        log(total_qt_votos_nominais_2014),
                      data = dados_cand, method = "full", estimand = "ATT", distance = "glm")

# dados após matching
dados_matching_1 <- match.data(matching_1)

# distribuição dos escores de propensão
#plot(matching_1, type = "jitter", interactive = FALSE)

# medidas descritivas para avaliar balanço de covariáveis
tab_desc_matching <- bal.tab(matching_1, un = TRUE, stats = c("m", "v", "ks"))

# gráficos do balanço das covariáveis antes e depois do matching
p_matching_genero <- bal.plot(matching_1, var.name = "ds_genero", which = "both")

p_matching_etnia <- bal.plot(matching_1, var.name = "ds_cor_raca", which = "both")

p_matching_estados <- bal.plot(matching_1, var.name = "sg_uf", which = "both")

p_matching_estadocivil <- bal.plot(matching_1, var.name = "ds_estado_civil", which = "both")

p_matching_educacao <- bal.plot(matching_1, var.name = "ds_grau_instrucao", which = "both")

p_matching_partidos <- bal.plot(matching_1, var.name = "sg_partido_2018", which = "both")

p_matching_receitas <- bal.plot(matching_1, var.name = "log(total_vr_receita_candidato)", which = "both")

p_matching_votos14 <- bal.plot(matching_1, var.name = "log(total_qt_votos_nominais_2014)", which = "both")

# love plot para avaliar balanço de covariáveis
p_love_plot <- love.plot(matching_1, binary = "std", threshold = .1, var.order = "alphabetic")

# ajustar modelos de regressão para total de votos nominais em 2018 contra lava_jato
modelo_1 <- lm(log(total_qt_votos_nominais_2018) ~ lava_jato,
               data = dados_matching_1, weights = weights)

modelo_2 <- lm(log(total_qt_votos_nominais_2018) ~ lava_jato +
                 ds_genero + ds_cor_raca + sg_uf +
                 ds_estado_civil + ds_grau_instrucao + sg_partido_2018 +
                 log(total_vr_receita_candidato) +
                 log(total_qt_votos_nominais_2014),
               data = dados_matching_1, weights = weights)

# error padrão robusto para modelo_1 e modelo_2
est_modelo_1 <- coeftest(modelo_1, vcov. = vcovCL, cluster =~ subclass) # modelo incluindo apenas lava_jato

est_modelo_2 <- coeftest(modelo_2, vcov. = vcovCL, cluster =~ subclass) # modelo incluindo demais covariáveis

# intervalo de confiança bootstrap BCa
pair_ids <- levels(matching_1$subclass)
boot_est <- boot(pair_ids, est_fun, R = 999)
ic <- boot.ci(boot_est, type = "bca")

# gráfico do intervalo de confiança bootstrap BCa
dados_ic <- data.frame(est = coef(modelo_1)[2], lwr = ic$bca[4], upr = ic$bca[5])
p_icbootstrap <- ggplot(dados_ic, aes(ymin = lwr, ymax = upr, y = est, x = "Efeito da Lava Jato")) +
  geom_pointrange() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  coord_flip() +
  scale_y_continuous(limits = c(-0.5, 0.5), breaks = scales::pretty_breaks()) +
  theme_light(base_size = 12) +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank()) +
  labs(x = "", y = "Estimativa")

# OUTPUTS ----------------------------------------------------------------------


