# Análise dos acidentes envolvendo motociclistas em interseções viárias na cidade de Fortaleza-CE dos anos de 2017 a 2019

## Link para a aplicação: https://altanizio.shinyapps.io/acidentes_motociclistas_fortaleza/
<p align="center">
<a href="https://github.com/altanizio/R-Dashboard-Shiny-motociclistas/blob/main/LICENSE" alt="LICENSE">
        <img src="https://img.shields.io/github/license/altanizio/R-Dashboard-Shiny-motociclistas" /></a>
</p>
<p align="center">
 <a href="#objetivo">Objetivo</a> •
 <a href="#glossario">Glossário</a> • 
 <a href="#demonstração">Demonstração</a> • 
 <a href="#fonte">Fonte dos dados</a> 
</p>

<h2 id="objetivo">Objetivo</h2>

O objetivo dessa aplicação desenvolvida no shinyapps em R é apresentar uma análise exploratória dinâmica da influência dos fatores de risco na severidade dos acidentes de trânsito envolvendo os motociclistas em interseções urbanas.

<h2 id="glossario">Glossário</h2>

| Variáveis  |  Descrição  |
| ------------------- | ------------------- |
|  Idade |  Idade do motociclista |
|  Experiencia_cat |  Experiência do motocilista. Obtida através da diferença de tempo entre a 1°CNH e data do acidente |
|  Sexo |  Sexo do motociclista |
|  Ano_veic_cat |  Ano do veículo (colisão) no acidente com o motociclista |
|  Comportamento |  Manobra de risco (Ex.: andando na contra-mão, ultrapassando) cometido pelo motociclista |
|  CNH_COND |  Condição (Vencimento) da CNH (Carteira do motociclista) |
|  Dia |  Dia útil e Fim de semana |
|  Natureza |  Natureza do acidente (colisão, queda, atropelamento) |
|  Iluminação |  Iluminação da via |
|  Tempo |  Tempo na hora do acidente |
|  Superficie_pista |  Superfície da pista na hora do acidente |
|  Tipo_cruzamento | Tipo do cruzamento (Ex.: Rotatoria) |
|  Controle_tráfego | Controle do tráfego da interseção |
|  Uso_solo | Tipo do uso do solo |
|  Rel_veic | Tipo de veículo/acidente com o motociclista. Choque pesado: Caminhão, ônibus. Acidente pessoal: Queda |
|  n_faixas | Número total de faixas da interseção |
|  max_tipo_class | Maior classificação viária (arterial, local, ...) da interseção |
|  Fiscalizac | Presença de fiscalização eletrônica a 100 metros da interseção |
|  Noite | Noite (18h-05h) |
|  Hora_pico | Pico (07h-09h e 17h - 19h) |
|  Motobox | Presença de área de espera para motos em inteseções |


<h2 id="demonstração">Demonstração</h2>

![](Imagens/app.gif?raw=true)

<h2 id="fonte">Fonte dos dados</h2>

https://vida.centralamc.com.br/registros/sinistros

