# gerar gráfico de segmentos
plot_type_segments <- function(dados_cand, dvar, xlab, ylab)
{
    dvar_pos <- which(colnames(dados_cand) == dvar)
    dados_cand$dvar <- dados_cand[, dvar_pos]
  
    p1_data <- ddply(subset(dados_cand, lava_jato == "S"), ~ dvar, summarise, y = length(dvar))
    p1_data$dvar <- factor(p1_data$dvar, levels = p1_data$dvar[order(p1_data$y)], ordered = TRUE)
    
    p <- ggplot(p1_data, aes(x = dvar, xend = dvar, yend = y)) +
    geom_segment(y = 0, color = "black") +
    geom_point(aes(y = y)) +
    coord_flip() +
    scale_y_continuous(breaks = scales::pretty_breaks()) +
    theme_light(base_size = 12) +
    theme(panel.grid.major.y = element_blank(),
          panel.grid.minor.y = element_blank()) +
    labs(x = xlab, y = ylab)
    
    return(p)
}

# gerar gráfico de barras empilhadas
plot_type_stackedbars <- function(dados_cand, dvar, xlab, ylab)
{
  dvar_pos <- which(colnames(dados_cand) == dvar)
  dados_cand$dvar <- dados_cand[, dvar_pos]
    
  p <- ggplot(dados_cand, aes(x = str_to_title(dvar), group = lava_jato, fill = lava_jato)) +
    geom_bar(position = "fill", color = "black", alpha = 0.5) +
    scale_fill_manual("Lava Jato: ", values = c(S = "grey", N = "white"), labels = c(S = "Sim", N = "Não")) +
    scale_y_continuous(breaks = scales::pretty_breaks(), labels = scales::percent_format(accuracy = 1)) +
    theme_light(base_size = 12) +
    theme(panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank()) +
    labs(x = xlab, y = ylab)
  
  return(p)
}

# gerar gráfico de box-plot
plot_type_boxplot <- function(dados_cand, dvar, xlab, ylab)
{
  dvar_pos <- which(colnames(dados_cand) == dvar)
  dados_cand$dvar <- dados_cand[, dvar_pos]
  
  p <- ggplot(dados_cand, aes(x = ifelse(lava_jato == "S", "Sim", "Não"), y = dvar,
                                   group = lava_jato, fill = lava_jato)) +
    geom_jitter(pch = 21, alpha = 0.5, show.legend = FALSE) +
    geom_boxplot(alpha = 0.5, show.legend = FALSE, outlier.shape = NA) +
    scale_fill_manual("", values = c(S = "grey", N = "white")) +
    scale_y_continuous(breaks = scales::pretty_breaks()) +
    theme_light(base_size = 12) +
    theme(panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank()) +
    labs(x = xlab, y = ylab)
  
  return(p)
}

# calcular intervalo de confiança usando bootstrap
est_fun <- function(pairs, i)
{
  numreps <- table(pairs[i])
  
  ids <- unlist(lapply(pair_ids[pair_ids %in% names(numreps)],
                       function(p) rep(which(dados_matching_1$subclass == p), 
                                       numreps[p])))
  
  md_boot <- dados_matching_1[ids, ]
  
  fit_boot <- lm(log(total_qt_votos_nominais_2018) ~ lava_jato, data = md_boot, weights = weights)
  
  return(coef(fit_boot)[2])
}