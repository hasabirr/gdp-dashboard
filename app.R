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
  adhb <<- NULL
  data_uploaded <- reactiveVal(FALSE)
  
  validate_file_names <- function(file_names) {
    # Pola untuk nama file yang valid
    valid_names <- c("data_pdrb_adhb.xlsx", "data_pdrb_adhk.xlsx")
    
    # 1. Periksa jumlah file
    if (length(file_names) != 2) {
      return(list(valid = FALSE, message = "Jumlah file harus tepat 2."))
    }
    
    # 2. Periksa apakah semua file berformat .xlsx
    if (!all(grepl("\\.xlsx$", file_names))) {
      return(list(valid = FALSE, message = "Semua file harus berformat .xlsx."))
    }
    
    # 3. Periksa nama file
    if (!all(file_names %in% valid_names)) {
      return(list(valid = FALSE, message = "Nama file harus 'data_pdrb_adhb.xlsx' dan 'data_pdrb_adhk.xlsx'."))
    }
    
    # Jika semua validasi lulus
    return(list(valid = TRUE, message = "File valid."))
  }
  
  observeEvent(input$process_data, {
    req(input$data_files)  # Pastikan file diunggah
    
    # Cek jumlah file
    if (nrow(input$data_files) != 2) {
      showNotification("Harap unggah tepat dua file.", type = "error")
      return()
    }
    
    # Nama file yang diunggah
    uploaded_files <- input$data_files$name
    
    # Validasi nama file
    if (!all(c("data_pdrb_adhb.xlsx", "data_pdrb_adhk.xlsx") %in% uploaded_files)) {
      showNotification("File yang diunggah harus berupa data_pdrb_adhb.xlsx dan data_pdrb_adhk.xlsx.", type = "error")
      return()
    }
    
    # Proses file
    adhb_file <- input$data_files$datapath[uploaded_files == "data_pdrb_adhb.xlsx"]
    adhk_file <- input$data_files$datapath[uploaded_files == "data_pdrb_adhk.xlsx"]
    
    # Simpan sebagai variabel global
    adhb <<- read_excel(adhb_file) %>%
      mutate(kode = factor(kode)) %>%
      mutate(across(4:ncol(.), ~ round(., 4))) 
    adhk <<- read_excel(adhk_file) %>%
      mutate(kode = factor(kode)) %>%
      mutate(across(4:ncol(.), ~ round(., 4))) 
    
    observe({
      updateSelectInput(session, "flag_pdrb", choices = unique(adhb$flag))
    })
    observe({
      updateSelectInput(session, "flag_line", choices = unique(adhb$flag))
    })
    showNotification("Data berhasil diproses.", type = "message")
    data_uploaded(TRUE)
  })
  
  output$file_list <- renderUI({
    req(input$data_files)  # Pastikan ada file yang diunggah
    
    # Ambil nama file yang diunggah
    file_names <- input$data_files$name
    
    # Tampilkan nama file dalam bentuk teks
    tagList(
      strong("Daftar File yang Diupload:"),
      tags$ul(
        lapply(file_names, tags$li)  # Buat list item untuk setiap file
      )
    )
  })
  
  # SERVER SIDEBAR =============================================================
  output$pdrb_general <- renderMenu({
    req(data_uploaded())
    menuItem("General", icon = icon("bar-chart"), startExpanded = TRUE,
             menuSubItem("PDRB ADHB", tabName = "adhb_general"),
             menuSubItem("PDRB ADHK", tabName = "adhk_general"))
  })
  output$pdrb_growth <- renderMenu({
    req(data_uploaded())
    menuItem("Pertumbuhan", icon = icon("bar-chart"), startExpanded = TRUE,
             menuSubItem("Quarter to Quarter (Q-to-Q)", tabName = "qtq"),
             menuSubItem("Year on Year (Y-o-Y)", tabName = "yoy"),
             menuSubItem("Cumulative (C-to-C)", tabName = "ctc"))
  })
  
  output$laju_implisit <- renderMenu({
    req(data_uploaded())
    menuItem("Laju Implisit", tabName = "laju_implisit", icon = icon("file-upload"))
  })
  
  output$share <- renderMenu({
    req(data_uploaded())
    menuItem("Share PDRB", tabName = "share", icon = icon("file-upload"))
  })
  
  output$pdrb_perkapita <- renderMenu({
    req(data_uploaded())
    menuItem("PDRB Per Kapita", tabName = "pdrb_perkapita", icon = icon("file-upload"))
  })
  
  output$download <- renderMenu({
    req(data_uploaded())
    menuItem("Download Data", tabName = "download", icon = icon("file-upload"))
  })
  
  output$glosarium <- renderMenu({
    req(data_uploaded())
    menuItem("Glosarium", tabName = "glosarium", icon = icon("file-upload"))
  })
  
  # SERVER PDRB GENERAL ========================================================
  source("server/adhb_general.R", local = TRUE)
  # lengkapi untuk source lainnya
}

# Run the application 
shinyApp(ui = ui, server = server)

