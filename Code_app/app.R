# Librarys

library(shiny)
library(tidyverse)
library(lubridate)
library(shinythemes)
library(semantic.dashboard)
library(plotly)
library(ggfortify)
library(tsibble)
library(shinyWidgets)
library(zoo)
library(viridis)
library(hrbrthemes)
library(sf)
library(tmap)
library(readxl)
library(DT)

# Dados

theme_set(theme_ipsum())

base_inter_final <- readRDS('dados/base_inter_final_29_01_21.rds') %>% dplyr::filter(!is.na(Data))

base_inter_final_map <- st_read(dsn = 'dados/ACC_SEV_s.geojson')  %>% st_transform(32724)

base_inter_final_map <- base_inter_final_map %>% dplyr::select(CdAcidente, geometry)
base_inter_final_map <- left_join(base_inter_final_map,
                                 base_inter_final,
                                 by = c("CdAcidente" = "CdAcidente"))
glossario <- read_xlsx('dados/glossario.xlsx')

ZT <-  st_read(dsn = 'dados/ZT_s.geojson')  %>% st_transform(32724)


# UI
ui <- fluidPage(
  theme <- shinytheme("lumen"),
  
  titlePanel(
    "Análise dos acidentes envolvendo motociclistas em interseções viárias na cidade de Fortaleza-CE dos anos de 2017 a 2019",
    windowTitle = "Acidentes - Motos"
  ),
  
  sidebarLayout(
    shiny::column(
      width = 4,
      sidebarPanel(
        align = "center",
        width = 14,
        checkboxGroupButtons(
          "Severidade",
          "Severidade do acidente:",
          c('Ileso', 'Leve', 'Moderado', 'Grave' , "Fatal"),
          selected = c('Ileso', 'Leve', 'Moderado', 'Grave' , "Fatal"),
          status = "primary"
        ),
        
        tags$head(
          tags$style(
            type = "text/css",
            ".irs-grid-text {font-size: 12pt !important; transform: rotate(-90deg) translate(-30px);"
          )
        ),
        
        sliderTextInput(
          inputId    = "Data_range",
          label      = "Acidentes entre as datas:",
          choices    = as.yearmon(unique(base_inter_final$Data)[order(unique(base_inter_final$Data))]),
          selected   = c(as.yearmon((
            min(base_inter_final$Data)
          )), as.yearmon(max(
            base_inter_final$Data
          ))),
          grid       = TRUE,
          width      = "100%"
        ),
        
        br(),
        br(),
        br(),
        
        tags$head(
          tags$style(
            type = "text/css",
            ".shiny-html-output {color: white;font-size: 17pt !important;background-color: #0080C1
              ;width: 100%;height: 30%;text-align: center;align: center;"
          )
        ),
        
        infoBoxOutput("acidentes") ,
        
        h4("Desenvolvido por Francisco Altanizio", align = "center"),
        p(
        a(tags$i(
          class = "fa fa-github", 
          style = "font-size: 30pt;"
        ), href = "https://github.com/altanizio/R-Dashboard-Shiny-motociclistas"),align = "center"),
        
        h6("Foram utilizados somente dados geolocalizados. As representações gráficas demonstram somente os valores válidos.", align = "center")
        
      )
    ),
    
    shiny::column(width = 8, mainPanel(
      align = "center",
      tabsetPanel(
        type = "tabs",
        tabPanel(
          "Gráfico",
          h4("Quantidade de acidentes por variável e severidade") ,
          
          shiny::column(
            6,
            dropdown(
              tags$h3("Entradas"),
              
              pickerInput(
                inputId = 'xcol2',
                label = 'Variável',
                choices = c(
                  'Idade',
                  'Experiencia_cat',
                  'Sexo',
                  'Ano_Veic_cat',
                  'Comportamento',
                  'CNH_cond',
                  'Dia',
                  'Natureza',
                  'Iluminacao',
                  'Tempo',
                  'Superficie_Pista',
                  'Tipo_cruzamento',
                  'Controle_trafego',
                  'Uso_Solo',
                  'Rel_Veic',
                  'n_faixas',
                  'max_tipo_class',
                  'Fiscalizac',
                  "Noite",
                  "Hora_pico",
                  'Motobox'
                ),
                options = list(`style` = "btn-info")
              ),
              
              style = "unite",
              icon = shiny::icon("arrow-circle-down"),
              status = "primary",
              width = "300px",
              animate = animateOptions(
                enter = animations$fading_entrances$fadeInUp,
                exit = animations$fading_exits$fadeOutDown
              )
            )
          ),
          
          shiny::column(
            6,
            
            switchInput(
              inputId = "Id077",
              label = "Separado",
              value = TRUE,
              labelWidth = "80px"
            )
          ),
          
          br(),
          br(),
          plotlyOutput("idadePlot", width = "100%", height = "100%")
        ),
        tabPanel(
          'Série Temporal',
          prettyRadioButtons(
            inputId = "Data_type",
            label = "Acidentes agrupados por:",
            choices = c('Semana', 'Mês', 'Semestre'),
            selected = c('Mês'),
            
            shape = "square",
            outline = T,
            inline = T,
            animation = 'smooth',
            plain = T
          ),
          plotlyOutput("temporalPlot", width = "100%", height = "100%")
        ),
        tabPanel(
          "Mapa",
          align = "left",
          tmapOutput('mapPlot', width = "100%", height = 600)
        ),
        tabPanel(
          "Glossário",
          align = "left",
          DTOutput('tableGlossario')
        )
      )
    ))
  )
)

server <- function(input, output, session) {
  
  output$acidentes <- renderInfoBox({
    base_inter_final <- base_inter_final %>% dplyr::filter(Severidade %in% input$Severidade,
                                                          Data >= ymd(as.Date(as.yearmon(
                                                            input$Data_range[1]
                                                          ))) & Data <= ymd(as.Date(as.yearmon(
                                                            input$Data_range[2]
                                                          ))))
    
    infoBox(
      "",
      tags$p(paste(
        '#Acc', prettyNum(nrow(base_inter_final), big.mark = ",")
      ), style = "font-size: 120%;"),
      icon = shiny::icon("motorcycle"),
      color = "purple",
      size = "huge",
      width = 16
    )
  })
  
  output$idadePlot <- renderPlotly({
    base_inter_final <- base_inter_final %>% dplyr::filter(Severidade %in% input$Severidade,
                                                          Data >= ymd(as.Date(as.yearmon(
                                                            input$Data_range[1]
                                                          ))) & Data <= ymd(as.Date(as.yearmon(
                                                            input$Data_range[2]
                                                          ))))
    
    base <- base_inter_final
    
    base <- base[, c(input$xcol2, 'Severidade')]
    
    colnames(base)[1] <- 'x'
    
    base <- base %>% filter_all( ~ !is.na(.))
    
    tipo <- ifelse(input$Id077 == T, "dodge", "stack")
    a <- ggplot(data = base, aes(x = x, fill = Severidade)) + geom_bar(position =
                                                                        tipo) +
      scale_fill_viridis(discrete = T) +
      ylab("") + xlab(input$xcol2) + scale_fill_brewer(palette = "Blues") + theme(legend.position =
                                                                                    "top", legend.title = element_blank())
    
    ggplotly(a) %>%
      layout(legend = list(
        orientation = "h",
        x = 0.1,
        y = -0.2
      ))
  })
  
  output$temporalPlot <- renderPlotly({
    base_inter_final <- base_inter_final %>% dplyr::filter(Severidade %in% input$Severidade,
                                                          Data >= ymd(as.Date(as.yearmon(
                                                            input$Data_range[1]
                                                          ))) & Data <= ymd(as.Date(as.yearmon(
                                                            input$Data_range[2]
                                                          ))))
    
    
    
    
    if (input$Data_type == 'Mês') {
      base <-  base_inter_final %>% dplyr::filter(!is.na(Data)) %>% group_by(Ano = year(Data), Mes = month(Data)) %>% summarise(Acidentes = n())
      
      base <- base %>% mutate(Data = yearmonth(ymd(paste(
        Ano, Mes, 1, sep = "-"
      ))))
      
      a <-  ggplot(base, aes(x = Data)) +
        geom_line(aes(y = Acidentes), color = 'cyan', size = 1.5) +
        scale_x_yearmonth(date_breaks = "3 month", date_labels = "%Y %b") +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5),
              panel.grid.minor = element_blank()) +
        labs(x = "", y = '')
      
      ggplotly(a)
      
      
    } else if (input$Data_type == 'Semestre') {
      base <-  base_inter_final %>% dplyr::filter(!is.na(Data)) %>% group_by(Ano = year(Data), semetre = semester(Data)) %>% summarise(Acidentes = n())
      
      base <- base %>% mutate(Data = yq(paste(Ano, semetre + 1, sep =
                                               "-")))
      
      a <-   ggplot(base, aes(x = Data)) +
        geom_line(aes(y = Acidentes), color = 'cyan', size = 1.5) +
        scale_x_date(date_breaks = "6 month", date_labels = "%Y") +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5),
              panel.grid.minor = element_blank()) +
        labs(x = "", y = '')
      ggplotly(a)
    } else{
      base <-  base_inter_final %>% dplyr::filter(!is.na(Data)) %>% mutate(Data = yearweek(Data)) %>% group_by(Data) %>% summarise(Acidentes = n())
      
      a <-   ggplot(base, aes(x = Data)) +
        geom_line(aes(y = Acidentes), color = 'cyan', size = 1.5) +
        scale_x_yearweek(date_breaks = "15 week", date_labels = "%Y %b") +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5),
              panel.grid.minor = element_blank()) +
        labs(x = "", y = '')
      ggplotly(a)
    }
    
    
  })
  
  output$mapPlot <- renderTmap({
    validate(need(input$Severidade != "", "Por favor escolha alguma severidade"))
    
    base_inter_final_map  <- base_inter_final_map  %>% dplyr::filter(Severidade %in% input$Severidade,
                                                                    Data >= ymd(as.Date(as.yearmon(
                                                                      input$Data_range[1]
                                                                    ))) & Data <= ymd(as.Date(as.yearmon(
                                                                      input$Data_range[2]
                                                                    ))))
    
    tmap_mode("view")
    ZT$`Acidentes` = lengths(st_intersects(ZT, base_inter_final_map))
    
    #Converter para mapa plotavel
    mapa <- tm_shape(ZT, name = 'Zonas de Tráfego') + tm_borders(col = 'black', lwd = 0.15) + tm_polygons(
      col = "Acidentes",
      n = 5,
      alpha = 0.4,
      palette = 'Reds'
    ) +
      tm_shape(base_inter_final_map, name = 'Pontos de acidente') + tm_symbols(col = 'Severidade',
                                                                               palette = 'Reds',
                                                                               size = 0.005)
    
    mapa + tm_basemap(server = "OpenStreetMap.Mapnik")
    
    
  })
  
  output$tableGlossario <- renderDT(glossario, options = list(
    pageLength = 25))
}

shinyApp(ui = ui, server = server)
