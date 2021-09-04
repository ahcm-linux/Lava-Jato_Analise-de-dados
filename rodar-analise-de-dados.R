# CARREGAR ARQUIVOS EXTERNOS ---------------------------------------------------

source("./codigos-adicionais-do-R/carregar-pacotes.R") # carregar pacotes
source("./codigos-adicionais-do-R/carregar-funcoes.R") # carregar funções

# PARÂMETROS DO SCRIPT ---------------------------------------------------------

set.seed(2021) # fixar semente em algoritmos randômicos (bootstrap)

width_1 = 16
height_1 = 12
  
width_2 = 21
height_2 = 14

width_3 = 18
height_3 = 25

width_4 = 21
height_4 = 27

width_5 = 18
height_5 = 29.7

width_6 = 21
height_6 = 29.7

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
p_genero <- plot_type_stackedbars(dados_cand, "ds_genero", "Lava Jato", "Percentual", "Gênero: ", c(2, 1))

# gráfico de envolvolvidos e não envolvidos, por grau de instrução
p_educacao <- plot_type_stackedbars(dados_cand, "ds_grau_instrucao", "Lava Jato", "Percentual", "Instrução: ", c(2, 1))

# gráfico de envolvolvidos e não envolvidos, estado civil
p_estadocivil <- plot_type_stackedbars(dados_cand, "ds_estado_civil", "Lava Jato", "Percentual", "Estado civil: ")

# gráfico de envolvolvidos e não envolvidos, por etnia
p_etnia <- plot_type_stackedbars(dados_cand, "ds_cor_raca", "Lava Jato", "Percentual", "Etnia: ")

# gráfico de envolvolvidos e não envolvidos, por tipo de eleição
dados_temp <- dados_cand
dados_temp$ds_sit_tot_turno_new <- ifelse(dados_temp$ds_sit_tot_turno == "NÃO ELEITO", "Não eleito", "Eleito")

p_eleicao <- plot_type_stackedbars(dados_temp, "ds_sit_tot_turno_new", "Lava Jato", "Percentual", "Eleição: ")

# gráfico de envolvolvidos e não envolvidos, mostrando distribuição de idade
p_idade <- plot_type_boxplot(dados_cand, "nr_idade_data_posse", "Envolvimento na Lava Jato", "Idade na data da posse")

# gráfico de envolvolvidos e não envolvidos, mostrando distribuição de total de bens declarados
#dados_temp$total_bem_candidato_log <- log(dados_cand$total_bem_candidato) # não incluído nos outputs devido à presença de dados faltantes
#p_bens <- plot_type_boxplot(dados_temp, "nr_idade_data_posse", "Envolvimento na Lava Jato", "Valor total dos bens declarados (log)") # não incluído nos outputs devido à presença de dados faltantes

# gráfico de envolvolvidos e não envolvidos, mostrando distribuição de total de receitas declarados
p_receitas <- plot_type_boxplot(dados_temp, "total_vr_receita_candidato", "Envolvimento na Lava Jato", "Valor total das receitas\ndeclaradas por candidatos")

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
                        log(total_vr_receita_partido) +
                        log(total_qt_votos_nominais_2014),
                      data = dados_cand, method = "full", estimand = "ATT", distance = "glm")

# dados após matching
dados_matching_1 <- match.data(matching_1)

# distribuição dos escores de propensão
#plot(matching_1, type = "jitter", interactive = FALSE)

# medidas descritivas para avaliar balanço de covariáveis
tab_desc_matching <- bal.tab(matching_1, un = TRUE, stats = c("m", "v", "ks"))

# gráficos do balanço das covariáveis antes e depois do matching
p_matching_genero <- bal.plot(matching_1, var.name = "ds_genero", which = "both") +
  geom_bar(position = "fill", color = "black") +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "black") +
  facet_grid(~ which, labeller = as_labeller(c("Unadjusted Sample" = "Antes do matching", "Adjusted Sample" = "Após o matching"))) +
  scale_fill_manual("Lava Jato: ", values = c("0" = "white", "1" = "grey"), labels = c("0" = "Não", "1" = "Sim")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = scales::pretty_breaks()) +
  scale_x_discrete(labels = c("FEMININO" = "Feminino", "MASCULINO" = "Masculino")) +
  theme_bw(base_size = 14) + theme(plot.caption = element_text(hjust = 0.5), panel.grid = element_blank(), strip.text = element_text(size = 14)) +
  labs(x = "Gênero", y = "Percentual na amostra", title = "")

p_matching_etnia <- bal.plot(matching_1, var.name = "ds_cor_raca", which = "both") +
  geom_bar(position = "fill", color = "black") +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "black") +
  facet_grid(~ which, labeller = as_labeller(c("Unadjusted Sample" = "Antes do matching", "Adjusted Sample" = "Após o matching"))) +
  scale_fill_manual("Lava Jato: ", values = c("0" = "white", "1" = "grey"), labels = c("0" = "Não", "1" = "Sim")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = scales::pretty_breaks()) +
  scale_x_discrete(labels = c("BRANCA" = "Branca", "PRETA" = "Preta", "outro" = "Outro")) +
  theme_bw(base_size = 14) + theme(plot.caption = element_text(hjust = 0.5), panel.grid = element_blank(), strip.text = element_text(size = 14)) +
  labs(x = "Etnia", y = "Percentual na amostra", title = "")

p_matching_estados <- bal.plot(matching_1, var.name = "sg_uf", which = "both") +
  geom_bar(position = "fill", color = "black") +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "black") +
  facet_grid(~ which, labeller = as_labeller(c("Unadjusted Sample" = "Antes do matching", "Adjusted Sample" = "Após o matching"))) +
  scale_fill_manual("Lava Jato: ", values = c("0" = "white", "1" = "grey"), labels = c("0" = "Não", "1" = "Sim")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = scales::pretty_breaks()) +
  theme_bw(base_size = 14) + theme(plot.caption = element_text(hjust = 0.5), panel.grid = element_blank(), strip.text = element_text(size = 14),
                                   axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(x = "Estado", y = "Percentual na amostra", title = "")

p_matching_estadocivil <- bal.plot(matching_1, var.name = "ds_estado_civil", which = "both") +
  geom_bar(position = "fill", color = "black") +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "black") +
  facet_grid(~ which, labeller = as_labeller(c("Unadjusted Sample" = "Antes do matching", "Adjusted Sample" = "Após o matching"))) +
  scale_fill_manual("Lava Jato: ", values = c("0" = "white", "1" = "grey"), labels = c("0" = "Não", "1" = "Sim")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = scales::pretty_breaks()) +
  scale_x_discrete(labels = c("não-solteiro" = "Não-Solteiro", "solteiro" = "Solteiro")) +
  theme_bw(base_size = 14) + theme(plot.caption = element_text(hjust = 0.5), panel.grid = element_blank(), strip.text = element_text(size = 14)) +
  labs(x = "Estado civil", y = "Percentual na amostra", title = "")

p_matching_educacao <- bal.plot(matching_1, var.name = "ds_grau_instrucao", which = "both") +
  geom_bar(position = "fill", color = "black") +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "black") +
  facet_grid(~ which, labeller = as_labeller(c("Unadjusted Sample" = "Antes do matching", "Adjusted Sample" = "Após o matching"))) +
  scale_fill_manual("Lava Jato: ", values = c("0" = "white", "1" = "grey"), labels = c("0" = "Não", "1" = "Sim")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = scales::pretty_breaks()) +
  scale_x_discrete(labels = c("não-superior" = "Não-Superior", "superior" = "Supeiror")) +
  theme_bw(base_size = 14) + theme(plot.caption = element_text(hjust = 0.5), panel.grid = element_blank(), strip.text = element_text(size = 14)) +
  labs(x = "Grau de instrução", y = "Percentual na amostra", title = "")

p_matching_partidos <- bal.plot(matching_1, var.name = "sg_partido_2018", which = "both") +
  geom_bar(position = "fill", color = "black") +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "black") +
  facet_grid(~ which, labeller = as_labeller(c("Unadjusted Sample" = "Antes do matching", "Adjusted Sample" = "Após o matching"))) +
  scale_fill_manual("Lava Jato: ", values = c("0" = "white", "1" = "grey"), labels = c("0" = "Não", "1" = "Sim")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = scales::pretty_breaks()) +
  theme_bw(base_size = 14) + theme(plot.caption = element_text(hjust = 0.5), panel.grid = element_blank(), strip.text = element_text(size = 14),
                                   axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(x = "Partido", y = "Percentual na amostra", title = "")

p_matching_receitas <- bal.plot(matching_1, var.name = "log(total_vr_receita_candidato)", which = "both", colors = c("white", "grey"), type = "hist", mirror = TRUE) +
  facet_grid(~ which, labeller = as_labeller(c("Unadjusted Sample" = "Antes do matching", "Adjusted Sample" = "Após o matching"))) +
  scale_fill_manual("Lava Jato: ", values = c("0" = "white", "1" = "grey"), labels = c("0" = "Não", "1" = "Sim")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = scales::pretty_breaks()) +
  theme_bw(base_size = 14) + theme(plot.caption = element_text(hjust = 0.5), panel.grid = element_blank(), strip.text = element_text(size = 14)) +
  labs(x = "Total das receitas declaradas pelos candidatos (log)", y = "Percentual na amostra", title = "")

p_matching_votos14 <- bal.plot(matching_1, var.name = "log(total_qt_votos_nominais_2014)", which = "both", colors = c("white", "grey"), type = "hist", mirror = TRUE) +
  facet_grid(~ which, labeller = as_labeller(c("Unadjusted Sample" = "Antes do matching", "Adjusted Sample" = "Após o matching"))) +
  scale_fill_manual("Lava Jato: ", values = c("0" = "white", "1" = "grey"), labels = c("0" = "Não", "1" = "Sim")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = scales::pretty_breaks()) +
  theme_bw(base_size = 14) + theme(plot.caption = element_text(hjust = 0.5), panel.grid = element_blank(), strip.text = element_text(size = 14)) +
  labs(x = "Total de votos nominais recebidos nas eleições de 2014 (log)", y = "Percentual na amostra", title = "")

p_matching_receitas_partidos <- bal.plot(matching_1, var.name = "log(total_vr_receita_partido)", which = "both", colors = c("white", "grey"), type = "hist", mirror = TRUE) +
  facet_grid(~ which, labeller = as_labeller(c("Unadjusted Sample" = "Antes do matching", "Adjusted Sample" = "Após o matching"))) +
  scale_fill_manual("Lava Jato: ", values = c("0" = "white", "1" = "grey"), labels = c("0" = "Não", "1" = "Sim")) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = scales::pretty_breaks()) +
  theme_bw(base_size = 14) + theme(plot.caption = element_text(hjust = 0.5), panel.grid = element_blank(), strip.text = element_text(size = 14)) +
  labs(x = "Total das receitas (em nível estadual) declaradas pelos partidos (log)", y = "Percentual na amostra", title = "")

# love plot para avaliar balanço de covariáveis
p_love_plot <- love.plot(matching_1, binary = "std", threshold = .1, var.order = "alphabetic", colors = c("grey", "black"))

# modificar rótulo do love plot
love_names <- love_labels <- unique(p_love_plot$data$var)
love_labels <- gsub("(^.._)|(_2018)", "", love_labels)
love_labels <- gsub("_", " ", love_labels)
love_labels <- gsub("cor raca", "Etnia", love_labels)
love_labels <- gsub("estado civil", "Estado civil", love_labels)
love_labels <- gsub("grau instrucao", "Grau de instrução", love_labels)
love_labels <- gsub("partido", "Partido", love_labels)
love_labels <- gsub("uf", "UF", love_labels)
love_labels <- gsub("total vr receita Partido", "Total de receitas do partido", love_labels)
love_labels <- gsub("total vr receita candidato", "Total de receitas do candidato", love_labels)
love_labels <- gsub("total qt votos nominais 2014", "Total de votos nominais em 2014", love_labels)
love_labels <- gsub("BRANCA", "branca", love_labels)
love_labels <- gsub("PRETA", "preta", love_labels)
love_labels <- gsub("distance", "Distância", love_labels)
names(love_labels) <- love_names

# atualizar love plot com novos rótulos
p_love_plot <- love.plot(matching_1, binary = "std", threshold = .1, var.order = "alphabetic", colors = c("grey", "black")) +
  scale_x_continuous(breaks = scales::pretty_breaks()) +
  scale_y_discrete(labels = love_labels) +
  theme_bw(base_size = 14) + theme(plot.caption = element_text(hjust = 0.5), panel.grid = element_blank(), legend.position = "none") +
  labs(x = "Diferença média estandartizada", y = "", title = "")

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
tab_modelo_1 <- coeftest(modelo_1, vcov. = vcovCL, cluster =~ subclass) # modelo incluindo apenas lava_jato

tab_modelo_2 <- coeftest(modelo_2, vcov. = vcovCL, cluster =~ subclass) # modelo incluindo demais covariáveis

# intervalo de confiança bootstrap BCa
pair_ids <- levels(matching_1$subclass)
boot_est <- boot(pair_ids, est_fun, R = 999)
ic <- boot.ci(boot_est, type = "bca")

# gráfico do intervalo de confiança bootstrap BCa
dados_ic <- data.frame(est = coef(modelo_1)[2], lwr = ic$bca[4], upr = ic$bca[5])
p_icbootstrap <- ggplot(dados_ic, aes(ymin = lwr, ymax = upr, y = est,
                                      x = "Efeito da Lava Jato sobre o\ntotal de votos nominais em 2018")) +
  geom_pointrange() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  coord_flip() +
  scale_y_continuous(limits = c(-0.5, 0.5), breaks = scales::pretty_breaks()) +
  theme_light(base_size = 14) +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank()) +
  labs(x = "", y = "Estimativa")

# OUTPUTS ----------------------------------------------------------------------

path <- "./resultados-da-analise-dos-dados-da-Lava-Jato/"

# exportar tabelas
write.csv(tab_contagem_cand, file = paste0(path, "Tabelas/", "contagem-de-candidatos-na-amostra", ".csv"), quote = FALSE, row.names = FALSE)
write.csv(tab_desc_matching$Balance, file = paste0(path, "Tabelas/", "estatisticas-descritivas-relacionadas-ao-matching", ".csv"), quote = FALSE, row.names = TRUE)
write.csv(tab_modelo_1, file = paste0(path, "Tabelas/", "estimativas-para-o-modelo-apenas-com-lavajato", ".csv"), quote = FALSE, row.names = TRUE)
write.csv(tab_modelo_2, file = paste0(path, "Tabelas/", "estimativas-para-o-modelo-com-todas-as-covariaveis", ".csv"), quote = FALSE, row.names = TRUE)

# exportar figuras da análise descritiva
p_agrupado_1 <- arrangeGrob(p_genero + theme(legend.position = "top") + labs(caption = "(a)"),
                            p_educacao + theme(legend.position = "top") + labs(caption = "(b)"),
                            p_estadocivil + theme(legend.position = "top") + labs(caption = "(c)"),
                            p_etnia + theme(legend.position = "top") + labs(caption = "(d)"),
                            p_idade + theme(legend.position = "top") + labs(caption = "(e)"),
                            p_eleicao + theme(legend.position = "top") + labs(caption = "(f)")
                            nrow = 3)
p_agrupado_2 <- arrangeGrob(p_votos14 + theme(legend.position = "top") + labs(caption = "(a)"),
                            p_votos18 + theme(legend.position = "top") + labs(caption = "(b)"),
                            p_receitas + theme(legend.position = "top") + labs(caption = "(c)"),
                            p_estados + theme(legend.position = "top") + labs(caption = "(d)"),
                            p_partidos + theme(legend.position = "top") + labs(caption = "(e)"),
                            nrow = 3)
ggsave(paste0(path, "Figuras/figuras-adicionais/", "graficos-descritivos_painel-1", ".png"), p_agrupado_1, width = width_3, height = height_3, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/figuras-adicionais/", "graficos-descritivos_painel-2", ".png"), p_agrupado_2, width = width_4, height = height_4, units = "cm", dpi = 300)

ggsave(paste0(path, "Figuras/figuras-adicionais/", "lava-jato-por-grau-de-instrucao", ".png"), plot = p_educacao, width = width_1, height = height_1, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/figuras-adicionais/", "lava-jato-por-eleicao", ".png"), plot = p_eleicao, width = width_1, height = height_1, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/figuras-adicionais/", "lava-jato-por-estado-civil", ".png"), plot = p_estadocivil, width = width_1, height = height_1, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/figuras-adicionais/", "lava-jato-por-estados-uf", ".png"), plot = p_estados, width = width_1, height = height_1, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/figuras-adicionais/", "lava-jato-por-etnia", ".png"), plot = p_etnia, width = width_1, height = height_1, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/figuras-adicionais/", "lava-jato-por-genero", ".png"), plot = p_genero, width = width_1, height = height_1, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/figuras-adicionais/", "lava-jato-por-idade", ".png"), plot = p_idade, width = width_1, height = height_1, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/figuras-adicionais/", "lava-jato-por-partidos-", ".png"), plot = p_partidos, width = width_1, height = height_1, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/figuras-adicionais/", "lava-jato-por-receitas-dos-candidatos", ".png"), plot = p_receitas, width = width_1, height = height_1, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/figuras-adicionais/", "lava-jato-por-total-de-votos-nominais-em-2014", ".png"), plot = p_votos14, width = width_1, height = height_1, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/figuras-adicionais/", "lava-jato-por-total-de-votos-nominais-em-2018", ".png"), plot = p_votos18, width = width_1, height = height_1, units = "cm", dpi = 300)

# exportar figuras do matching
p_agrupado_3 <- arrangeGrob(p_matching_genero + theme(legend.position = "right") + labs(caption = "(a)"),
                            p_matching_educacao + theme(legend.position = "right") + labs(caption = "(b)"),
                            p_matching_estadocivil + theme(legend.position = "right") + labs(caption = "(c)"),
                            p_matching_etnia + theme(legend.position = "right") + labs(caption = "(d)"),
                            nrow = 4)
p_agrupado_4 <- arrangeGrob(p_matching_votos14 + theme(legend.position = "top") + labs(caption = "(a)"),
                            p_matching_receitas + theme(legend.position = "top") + labs(caption = "(b)"),
                            p_matching_receitas_partidos + theme(legend.position = "top") + labs(caption = "(c)"),
                            nrow = 3)
p_agrupado_5 <- arrangeGrob(p_matching_estados + theme(legend.position = "top") + labs(caption = "(a)"),
                            p_matching_partidos + theme(legend.position = "top") + labs(caption = "(b)"),
                            nrow = 2)
ggsave(paste0(path, "Figuras/", "balanco-de-covariaveis_painel-1", ".png"), p_agrupado_3, width = width_5, height = height_5, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/", "balanco-de-covariaveis_painel-2", ".png"), p_agrupado_4, width = width_5, height = height_5, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/", "balanco-de-covariaveis_painel-3", ".png"), p_agrupado_5, width = width_6, height = height_6, units = "cm", dpi = 300)

ggsave(paste0(path, "Figuras/", "balanco-da-covariavel-grau-de-instrucao", ".png"), plot = p_matching_educacao, width = width_2, height = height_2, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/", "balanco-da-covariavel-estado-civil", ".png"), plot = p_matching_estadocivil, width = width_2, height = height_2, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/", "balanco-da-covariavel-estados-uf", ".png"), plot = p_matching_estados + theme(legend.position = "top"), width = width_2, height = height_2, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/", "balanco-da-covariavel-etnia", ".png"), plot = p_matching_etnia, width = width_2, height = height_2, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/", "balanco-da-covariavel-genero", ".png"), plot = p_matching_genero, width = width_2, height = height_2, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/", "balanco-da-covariavel-partidos", ".png"), plot = p_matching_partidos + theme(legend.position = "top"), width = width_2, height = height_2, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/", "balanco-da-covariavel-receitas-dos-candidatos", ".png"), plot = p_matching_receitas, width = width_2, height = height_2, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/", "balanco-da-covariavel-receitas-dos-partidos", ".png"), plot = p_matching_receitas_partidos, width = width_2, height = height_2, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/", "balanco-da-covariavel-total-de-votos-nominais-em-2014", ".png"), plot = p_matching_votos14, width = width_2, height = height_2, units = "cm", dpi = 300)

ggsave(paste0(path, "Figuras/", "balanco-de-todas-as-covariaveis-love-plot", ".png"), plot = p_love_plot, width = width_4, height = height_4, units = "cm", dpi = 300)
ggsave(paste0(path, "Figuras/", "estimativas-efeito-da-lava-jato-sobre-votos-nominais-em-2018", ".png"), plot = p_icbootstrap, width = width_1, height = height_1, units = "cm", dpi = 300)
