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

# UI
ui <- dashboardPage(
  source("ui/ui_header.R")$value,
  source("ui/ui_sidebar.R")$value,
  source("ui/ui_body.R")$value
)

# SERVER
server <- function(input, output, session) {

  adhb <- gsheet2tbl('docs.google.com/spreadsheets/d/1zX-sS-QRhgQw8N5I0OU-Su06NBRm66J1/edit?gid=326092188#gid=326092188') %>%
    mutate(kode = factor(kode)) %>%
    mutate(across(4:ncol(.), ~ round(., 4)))
  
  tahun_tersedia <- unique(substr(names(adhb)[grepl("_", names(adhb))], 1, 4))
  
  adhb_triwulanan_total <- adhb %>%
    filter(flag == 1) %>%
    tidyr::pivot_longer(
      cols = -c(kode, nama, flag),
      names_to = "periode",
      values_to = "nilai_adhb"
    ) %>%
    mutate(periode = gsub("_", ".", periode)) %>%
    group_by(periode) %>%
    summarise(nilai_adhb = sum(nilai_adhb, na.rm = TRUE), .groups = "drop")
  
  adhb_tahunan_total <- adhb %>%
    filter(flag == 1) %>% 
    tidyr::pivot_longer(
      cols = -c(flag, kode, nama),
      names_to = "periode",
      values_to = "nilai_adhb"
    ) %>%
    mutate(tahun = gsub("_", ".", periode)) %>%
    mutate(tahun = as.integer(substr(periode, 1, 4))) %>%
    group_by(tahun) %>%
    summarise(nilai_adhb = sum(nilai_adhb, na.rm = TRUE), .groups = "drop") %>%
    mutate(periode = as.character(tahun)) %>% select(-tahun)
  
  adhk <- gsheet2tbl('docs.google.com/spreadsheets/d/1FeTRkKfhJc4z29vP5ftXL2hNBolYTtQU/edit?gid=1723490359#gid=1723490359') %>%
    mutate(kode = factor(kode)) %>%
    mutate(across(4:ncol(.), ~ round(., 4)))
  
  adhk_triwulanan_total <- adhk %>%
    filter(flag == 1) %>%
    tidyr::pivot_longer(
      cols = -c(kode, nama, flag),
      names_to = "periode",
      values_to = "nilai_adhk"
    ) %>%
    mutate(periode = gsub("_", ".", periode)) %>%
    group_by(periode) %>%
    summarise(nilai_adhk = sum(nilai_adhk, na.rm = TRUE), .groups = "drop")
  
  adhk_tahunan_total <- adhk %>%
    filter(flag == 1) %>% 
    tidyr::pivot_longer(
      cols = -c(flag, kode, nama),
      names_to = "periode",
      values_to = "nilai_adhk"
    ) %>%
    mutate(tahun = gsub("_", ".", periode)) %>%
    mutate(tahun = as.integer(substr(periode, 1, 4))) %>%
    group_by(tahun) %>%
    summarise(nilai_adhk = sum(nilai_adhk, na.rm = TRUE), .groups = "drop") %>%
    mutate(periode = as.character(tahun)) %>% select(-tahun)
  
  population <- gsheet2tbl('docs.google.com/spreadsheets/d/1ACQnSbPG6oDPEc0o3oVF-gdyoImhSXzLe0rS3d_xxiQ/edit?gid=0#gid=0')
  
  calculate_per_capita <- function(adhb, population) {
    # Menentukan kolom-kolom yang mengandung data tahun secara dinamis
    tahun_columns <- grep("^\\d{4}", names(adhb), value = TRUE)
    
    # Pivot data dari wide ke long berdasarkan kolom tahun yang ditemukan
    adhb_long <- adhb %>%
      tidyr::pivot_longer(cols = all_of(tahun_columns), 
                          names_to = "year_quarter", values_to = "PDRB") %>%
      mutate(
        year = as.numeric(substr(year_quarter, 1, 4)),  # Extract tahun
        quarter = as.numeric(substr(year_quarter, 6, 6))  # Extract triwulan
      )
    
    # Menggabungkan dengan data populasi
    adhb_long <- adhb_long %>%
      left_join(population, by = c("year" = "periode")) %>%
      mutate(PDRB_per_capita = PDRB / population)
    
    # Pivot kembali menjadi wide untuk setiap tahun dan triwulan
    adhb_wide <- adhb_long %>%
      select(flag, kode, nama, year_quarter, PDRB_per_capita) %>%
      tidyr::pivot_wider(names_from = year_quarter, values_from = PDRB_per_capita)
    
    return(adhb_wide)
  }
  
  # Panggil fungsi untuk menghitung PDRB per kapita
  adhb_perkapita <- calculate_per_capita(adhb, population)
  adhk_perkapita <- calculate_per_capita(adhk, population)
  # adhb_triwulanan_perkapita <- calculate_per_capita(adhb_triwulanan_total, population)
  # adhb_tahunan_perkapita <- calculate_per_capita(adhb_tahunan_total, population)
  # adhk_triwulanan_perkapita <- calculate_per_capita(adhk_triwulanan_total, population)
  # adhk_tahunan_perkapita <- calculate_per_capita(adhk_tahunan_total, population)
  
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
    menuItem("Pertumbuhan", icon = icon("line-chart"),
             menuSubItem("Quarter to Quarter (Q-to-Q)", tabName = "qtq"),
             menuSubItem("Year on Year (Y-o-Y)", tabName = "yoy"),
             menuSubItem("Cumulative (C-to-C)", tabName = "ctc"))
  })
  
  output$laju_implisit <- renderMenu({
    menuItem("Laju Implisit", tabName = "laju_implisit", icon = icon("arrow-up-right-dots"))
  })
  
  output$share <- renderMenu({
    menuItem("Share PDRB", tabName = "share", icon = icon("cubes-stacked"))
  })
  
  output$pdrb_perkapita <- renderMenu({
    menuItem("PDRB Per Kapita", icon = icon("people-group"),
             menuSubItem("ADHB", tabName = "adhb_perkapita"),
             menuSubItem("ADHK", tabName = "adhk_perkapita"))
  })
  
  output$download <- renderMenu({
    menuItem("Download Data", tabName = "download_data", icon = icon("download"))
  })
  
  output$glosarium <- renderMenu({
    menuItem("Glosarium", tabName = "glosarium", icon = icon("book"))
  })
  
  # SERVER PDRB GENERAL ========================================================
  source("server/adhb_general.R", local = TRUE)
  source("server/adhk_general.R", local = TRUE)
  source("server/laju_implisit.R", local = TRUE)
  source("server/adhb_perkapita.R", local = TRUE)
  source("server/download.R", local = TRUE)
  source("server/glosarium.R", local = TRUE)
  # lengkapi untuk source lainnya
}

# Run the application 
shinyApp(ui = ui, server = server)

