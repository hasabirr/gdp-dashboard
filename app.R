# Libraries
library(shiny)
library(shinydashboard)
library(dplyr)
library(plotly)
library(dplyr)
library(readxl)
library(openxlsx)
library(ggplot2)
library(DT)
library(writexl)
library(ggplot2)
library(RColorBrewer)

library(readxl)
library(dplyr)

# Baca data dari file Excel
adhb <- read_excel("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/data/data_pdrb.xlsx", sheet = "adhb") %>%
  mutate(kode = factor(kode)) %>%
  mutate(across(4:ncol(.), ~ round(., 4)))

adhk <- read_excel("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/data/data_pdrb.xlsx", sheet = "adhk") %>%
  mutate(kode = factor(kode)) %>%
  mutate(across(4:ncol(.), ~ round(., 4))) 


# UI
ui <- dashboardPage(
  source("ui/ui_header.R")$value,
  source("ui/ui_sidebar.R")$value,
  source("ui/ui_body.R")$value
)

# SERVER
server <- function(input, output, session) {
  
  # SERVER SIDEBAR =============================================================
  output$pdrb_general <- renderMenu({
    menuItem("General", icon = icon("bar-chart"), startExpanded = TRUE,
             menuSubItem("PDRB ADHB", tabName = "adhb_general"),
             menuSubItem("PDRB ADHK", tabName = "adhk_general"))
  })
  output$pdrb_growth <- renderMenu({
    menuItem("Pertumbuhan", icon = icon("bar-chart"), startExpanded = TRUE,
             menuSubItem("Quarter to Quarter (Q-to-Q)", tabName = "qtq"),
             menuSubItem("Year on Year (Y-o-Y)", tabName = "yoy"),
             menuSubItem("Cumulative (C-to-C)", tabName = "ctc"))
  })
  
  # SERVER PDRB GENERAL ========================================================
  source("server/adhb_general.R", local = TRUE)
  # lengkapi untuk source lainnya
}

# Run the application 
shinyApp(ui = ui, server = server)

