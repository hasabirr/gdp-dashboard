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
library(gsheet)
library(readxl)
library(dplyr)

# Baca data dari file Excel
# adhb <- read_excel("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/data/data_pdrb.xlsx", sheet = "adhb") %>%
#   mutate(kode = factor(kode)) %>%
#   mutate(across(4:ncol(.), ~ round(., 4)))
# 
# adhk <- read_excel("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/data/data_pdrb.xlsx", sheet = "adhk") %>%
#   mutate(kode = factor(kode)) %>%
#   mutate(across(4:ncol(.), ~ round(., 4))) 


# UI
ui <- dashboardPage(
  source("ui/ui_header.R")$value,
  source("ui/ui_sidebar.R")$value,
  source("ui/ui_body.R")$value
)

# SERVER
server <- function(input, output, session) {
  
  # SERVER UPLOAD DATA =========================================================
  # adhb <<- NULL
  
  # data_uploaded <- reactiveVal(FALSE)
  # 
  # validate_file_names <- function(file_names) {
  #   valid_names <- c("data_pdrb_adhb.xlsx", "data_pdrb_adhk.xlsx")
  #   
  #   if (length(file_names) != 2) {
  #     return(list(valid = FALSE, message = "Jumlah file harus tepat 2."))
  #   }
  #   
  #   if (!all(grepl("\\.xlsx$", file_names))) {
  #     return(list(valid = FALSE, message = "Semua file harus berformat .xlsx."))
  #   }
  #   
  #   if (!all(file_names %in% valid_names)) {
  #     return(list(valid = FALSE, message = "Nama file harus 'data_pdrb_adhb.xlsx' dan 'data_pdrb_adhk.xlsx'."))
  #   }
  #   
  #   return(list(valid = TRUE, message = "File valid."))
  # }
  # 
  # observeEvent(input$process_data, {
  #   req(input$data_files)
  #   
  #   if (nrow(input$data_files) != 2) {
  #     showNotification("Harap unggah tepat dua file.", type = "error")
  #     return()
  #   }
  #   
  #   uploaded_files <- input$data_files$name
  #   
  #   if (!all(c("data_pdrb_adhb.xlsx", "data_pdrb_adhk.xlsx") %in% uploaded_files)) {
  #     showNotification("File yang diunggah harus berupa data_pdrb_adhb.xlsx dan data_pdrb_adhk.xlsx.", type = "error")
  #     return()
  #   }
  #   
  #   adhb_file <- input$data_files$datapath[uploaded_files == "data_pdrb_adhb.xlsx"]
  #   adhk_file <- input$data_files$datapath[uploaded_files == "data_pdrb_adhk.xlsx"]
  #   
  #   adhb <<- read_excel(adhb_file) %>%
  #     mutate(kode = factor(kode)) %>%
  #     mutate(across(4:ncol(.), ~ round(., 4))) 
  #   adhk <<- read_excel(adhk_file) %>%
  #     mutate(kode = factor(kode)) %>%
  #     mutate(across(4:ncol(.), ~ round(., 4))) 
  #   
  #   observe({
  #     updateSelectInput(session, "flag_pdrb", choices = unique(adhb$flag))
  #   })
  #   observe({
  #     updateSelectInput(session, "flag_line", choices = unique(adhb$flag))
  #   })
  #   showNotification("Data berhasil diproses.", type = "message")
  #   data_uploaded(TRUE)
  # })
  # 
  # output$file_list <- renderUI({
  #   req(input$data_files) 
  # 
  #   file_names <- input$data_files$name
  # 
  #   tagList(
  #     strong("Daftar File yang Diupload:"),
  #     tags$ul(
  #       lapply(file_names, tags$li) 
  #     )
  #   )
  # })
  adhb <- gsheet2tbl('docs.google.com/spreadsheets/d/1zX-sS-QRhgQw8N5I0OU-Su06NBRm66J1/edit?gid=326092188#gid=326092188') %>%
    mutate(kode = factor(kode)) %>%
    mutate(across(4:ncol(.), ~ round(., 4)))
  adhk <- gsheet2tbl('docs.google.com/spreadsheets/d/1FeTRkKfhJc4z29vP5ftXL2hNBolYTtQU/edit?gid=1723490359#gid=1723490359') %>%
    mutate(kode = factor(kode)) %>%
    mutate(across(4:ncol(.), ~ round(., 4)))
  
  # SERVER SIDEBAR =============================================================
  output$pdrb_general <- renderMenu({
    # req(data_uploaded())
    menuItem("General", icon = icon("chart-simple"), startExpanded = TRUE,
             menuSubItem("PDRB ADHB", tabName = "adhb_general"),
             menuSubItem("PDRB ADHK", tabName = "adhk_general"))
  })
  observe({
    updateTabItems(session, "sidebar_menu", selected = "adhb_general")
  })
  output$pdrb_growth <- renderMenu({
    # req(data_uploaded())
    menuItem("Pertumbuhan", icon = icon("line-chart"),
             menuSubItem("Quarter to Quarter (Q-to-Q)", tabName = "qtq"),
             menuSubItem("Year on Year (Y-o-Y)", tabName = "yoy"),
             menuSubItem("Cumulative (C-to-C)", tabName = "ctc"))
  })
  
  output$laju_implisit <- renderMenu({
    # req(data_uploaded())
    menuItem("Laju Implisit", tabName = "laju_implisit", icon = icon("arrow-up-right-dots"))
  })
  
  output$share <- renderMenu({
    # req(data_uploaded())
    menuItem("Share PDRB", tabName = "share", icon = icon("cubes-stacked"))
  })
  
  output$pdrb_perkapita <- renderMenu({
    # req(data_uploaded())
    menuItem("PDRB Per Kapita", tabName = "pdrb_perkapita", icon = icon("people-group"))
  })
  
  output$download <- renderMenu({
    # req(data_uploaded())
    menuItem("Download Data", tabName = "download", icon = icon("download"))
  })
  
  output$glosarium <- renderMenu({
    # req(data_uploaded())
    menuItem("Glosarium", tabName = "glosarium", icon = icon("book"))
  })
  
  # SERVER PDRB GENERAL ========================================================
  source("server/adhb_general.R", local = TRUE)
  source("server/glosarium.R", local = TRUE)
  # lengkapi untuk source lainnya
}

# Run the application 
shinyApp(ui = ui, server = server)

