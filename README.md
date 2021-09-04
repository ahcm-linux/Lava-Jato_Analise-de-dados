Este texto pretende apresentar brevemente aspectos essenciais da análise de dados e mostrar o passo-a-passo de **como reproduzir esta análise de dados no seu computador**. Cada pasta deste repositório (*c.f.* pastas acima) trás um arquivo de texto como esse (com extensão .md) explicando o conteúdo da pasta.

**Partes do texto realçadas em cor azul são clicáveis.**

# Objetivo da análise de dados

Estimar o efeito da Operação Lava Jato sobre o total de votos nominais dos candidatos que concorreram nas eleições de 2018 à reeleição para o cargo de Deputado Federal.

# Amostra de dados

Dados descrevendo o perfil socioeconomico e político de uma amostra de candidatos da população estudada foram obtidos do [Repositório de Dados do TSE](https://www.tse.jus.br/eleicoes/estatisticas/repositorio-de-dados-eleitorais-1) na data de 03/08/2021. Foram considerados dois grupos de candidatos, envolvidos e não envolvidos na Operação Lava Jato, incluindo na amostra apenas candidatos com dados completos. Um total de 391 candidatos foram incluídos na amostra, o número de candidatos em cada grupo está apresentado na tabela abaixo:

| Envolvimento na Op. Lava Jato | Número de candidatos na amostra |
| :---------------------------: | :-----------------------------: |
| Não                           |                             346 |
| Sim                           |                              45 |

As seguintes variáveis (visíveis no arquivo [dados-de-todos-os-candidatos.csv](https://github.com/ahcm-linux/Lava-Jato_Analise-de-dados/blob/main/dados-Lava-Jato/dados-de-todos-os-candidatos.csv)) foram consideradas na análise de dados:
1. **ds_genero**: Gênero declarado pelo do candidato;
2. **ds_cor_raca**: Etnia declarada pelo candidato;
3. **sg_uf**: Estado pelo qual o candidato concorreu;
4. **ds_estado_civil**: Estado civil do candidato;
5. **ds_grau_de_instrucao**: Grau de instrução do candidato;
6. **sg_partido_2018**: Partido do candidato;
7. **total_vr_receita_candidato**: Total da receita declarada pelo candidato;
8. **total_vr_receita_partido**: Total da receita declarada pelo partido;
9. **total_qt_votos_nominais_2014**: Total de votos nominais obtido pelo candidato em 2014;
10. **total_qt_votos_nominais_2018**: Total de votos nominais obtido pelo candidato em 2014;
11. **lava_jato**: Indicador para distinguir entre candidatos envolvidos e não envolvidos na Operação Lava Jato.

A listagem dos candidatos envolvidos na Operação Lava Jato e considerados na amostra de dados está no arquivo [lista-de-candidatos-envolvidos.csv](https://github.com/ahcm-linux/Lava-Jato_Analise-de-dados/blob/main/dados-Lava-Jato/lista-de-candidatos-envolvidos.csv).

# Metódos estatísticos

O efeito da variável de tratamento (*e.i* Lava Jato, designada como **lava_jato**) sobre o total de votos nominais obtidos pelo candidatos (variável dependente, designada como **total_qt_votos_nominais_2018**) foi estimado através de um modelo de regressão linear com observações ponderadas com pesos gerados pelo médoto de *matching* não paramétrico descrito em [Hoe *et al. (2007)*](https://www.cambridge.org/core/journals/political-analysis/article/matching-as-nonparametric-preprocessing-for-reducing-model-dependence-in-parametric-causal-inference/4D7E6D07C9727F5A604E5C9FCCA2DD21).

O métodos de *matching* não paramétrico foi usado para controlar o efeito de variáveis de confusão sobre a variável dependente do modelo de regressão linear e permitir estimar adequadamente o efeito da variável de tratamento Lava Jato.

O modelo de regressão linear foi especificado sob a suposições clássicas de erros independentes e normalmente distrbuídos e incluindo as demais variáveis descritas na seção anterior como covariáveis, ou seja, considerou-se um modelo de regressão linear múltipla "tradicional". As demais covariáveis foram incluídas para equilibrar qualquer desbalanço não corrigido pelo *matching*.

Um intervalo de confiança *bootstrap* BCa (*Bias-Corrected and accelerated*) [(Efron, 1987)](https://www.jstor.org/stable/2289144), baseado em 999 reamostragens, foi obtido para o coefiente de regressão da variável Lava Jato.

Todas as etapas da análise estatística foram realizadas no *software* R versão 3.6.1.

# Resultados

O coeficiente de regressão estimado para a variável Lava Jato foi negativo (igual a -0.27) e estatisticamente significativo (p-valor < 0.01) com respectivo intervalo de confiança *bootstrap* BCa igual a (-0.40, -0.07).

Portanto, concluí-se que a candidatos envolvidos na Operação Lava Jato obtiveram em 2018 total de votos nominais inferior aos candidatos não envolvidos.

# Como reproduzir os resultados no seu computador

Caso você queira reproduzir esta análise de dados no seu computador, você precisará ter instalado no seu computador uma versão so *softwares* R igual ou superior a 3.6.1 e o RStudio. Após confirmar que voê tem os *softwares* exigidos, sigua as instruções a seguir:
1. Faça o download deste repositório. Para fazer isso, procure no topo [desta página](https://github.com/ahcm-linux/Lava-Jato_Analise-de-dados) o botão verde com o nome **Code** ou **Código**. Clique no botão e escolha fazer o download do arquivo ZIP;
2. Descompacte o arquivo ZIP na sua área de trabalho. A pasta gerada neste processo conterá todos os arquivos do repositório;
3. Abra a pasta e clique duas vezes no arquivo *Lava-Jato_Analise-de-dados.Rproj*. Isto deverá abrir o projeto da anpalise de dados no RStudio;
4. A partir do RStudio, abra o arquivo *rodar-analise-de-dados.R*;
5. Pressione as teclas Ctrl + A (para selecionar todo o código R do script) e, em seguida, pressione as teclas Ctrl + Enter (para rodar os códigos selecionados).

Após a realização do procedimento acima, você terá no seu RStudio todos os objetos gerados pela análise de dados.

**Observe que durante este processo todos os pacotes R necessários serão instalados automaticamente**.