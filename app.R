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

  # DATA ADHB ==================================================================
  # adhb <- gsheet2tbl('docs.google.com/spreadsheets/d/1zX-sS-QRhgQw8N5I0OU-Su06NBRm66J1/edit?gid=326092188#gid=326092188') %>%
  adhb <- read_xlsx("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/data/data_pdrb_adhb.xlsx") %>%
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
  
  # DATA ADHK ==================================================================
  # adhk <- gsheet2tbl('docs.google.com/spreadsheets/d/1FeTRkKfhJc4z29vP5ftXL2hNBolYTtQU/edit?gid=1723490359#gid=1723490359') %>%
  adhk <- read_xlsx("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/data/data_pdrb_adhk.xlsx") %>%
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
  
  # DATA PERKAPITA =============================================================
  # population <- gsheet2tbl('docs.google.com/spreadsheets/d/1ACQnSbPG6oDPEc0o3oVF-gdyoImhSXzLe0rS3d_xxiQ/edit?gid=0#gid=0')
  population <- read_xlsx("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/data/population.xlsx")
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
  
  # DATA PERTUMBUHAN - Dari ADHK
  qtq_data <- adhk %>%
    tidyr::pivot_longer(
      cols = matches("^\\d{4}_.+"), 
      names_to = "periode",
      values_to = "nilai"
    ) %>%
    arrange(kode, periode) %>%
    group_by(kode) %>%
    mutate(
      qtq = ((nilai / lag(nilai)) * 100) - 100  # Hitung qtq
    ) %>%
    ungroup()
  
  # Jika ingin kembali ke format wide
  qtq_data_wide <- qtq_data %>%
    select(flag, kode, nama, periode, qtq) %>%
    tidyr::pivot_wider(names_from = periode, values_from = qtq)

  yoy_data <- adhk %>%
    tidyr::pivot_longer(
      cols = matches("^\\d{4}_.+"),  # Pilih kolom dengan tahun dan kuartal
      names_to = "periode",
      values_to = "nilai"
    ) %>%
    mutate(
      year = as.numeric(substr(periode, 1, 4)),        # Ekstrak tahun
      quarter = as.numeric(substr(periode, 6, 6))     # Ekstrak triwulan
    ) %>%
    arrange(kode, year, quarter) %>%
    group_by(kode, quarter) %>%
    mutate(
      yoy = (nilai / lag(nilai, 1)) * 100 - 100       # Hitung YoY (dibandingkan dengan tahun sebelumnya pada triwulan yang sama)
    ) %>%
    ungroup()
  
  # Jika ingin kembali ke format wide
  yoy_data_wide <- yoy_data %>%
    select(flag, kode, nama, periode, yoy) %>%
    tidyr::pivot_wider(names_from = periode, values_from = yoy)
  
  ctc_data <- adhk %>%
    tidyr::pivot_longer(
      cols = matches("^\\d{4}_.+"),  # Pilih kolom dengan tahun dan kuartal
      names_to = "periode",
      values_to = "nilai"
    ) %>%
    mutate(
      year = as.numeric(substr(periode, 1, 4)),
      quarter = as.numeric(substr(periode, 6, 6)), 
      flag_kode = paste(flag, kode, sep = "_")
    ) %>%
    group_by(flag_kode, kode) %>%
    arrange(kode, year, quarter) %>%
    mutate(
      # C-to-C: (nilai saat ini / nilai tahun sebelumnya) * 100 - 100
      ctc = case_when(
        year == 2017 ~ NA_real_,  # Tidak ada CTC untuk tahun 2017
        quarter == 1 ~ (nilai / lag(nilai, 4)) * 100 - 100,  # C-to-C untuk triwulan 1
        quarter == 2 ~ (nilai + lag(nilai)) / (lag(nilai, 5) + lag(nilai, 4)) * 100 - 100,  # CTC untuk triwulan 2
        quarter == 3 ~ ((nilai + lag(nilai) + lag(nilai, 2)) / (lag(nilai, 6) + lag(nilai, 5) + lag(nilai, 4))) * 100 - 100,  # CTC untuk triwulan 3
        quarter == 4 ~ ((nilai + lag(nilai) + lag(nilai, 2) + lag(nilai, 3)) / (lag(nilai, 7) + lag(nilai, 6) + lag(nilai, 5) + lag(nilai, 4))) * 100 - 100  # CTC untuk triwulan 4
      )
    ) %>%
    ungroup()
  
  # Share Data
  triwulan_cols <- grep("^\\d{4}_\\d$", colnames(adhb), value = TRUE)
  
  # Hitung total triwulan untuk flag = 1
  total_triwulan <- adhb %>%
    filter(flag == 1) %>%
    summarise(across(all_of(triwulan_cols), \(x) sum(x, na.rm = TRUE)))
  
  # Menghitung share per cell
  # Hitung share untuk masing-masing triwulan
  # Hitung share untuk masing-masing triwulan dalam persen
  share <- adhb %>%
    mutate(across(all_of(triwulan_cols), 
                  ~ (.x / total_triwulan[[cur_column()]]) * 100, 
                  .names = "Share_{.col}")) %>%
    select(-all_of(triwulan_cols))
  
  
  
  # SERVER SIDEBAR =============================================================
  output$pdrb_general <- renderMenu({
    # req(data_uploaded())
    menuItem("General", icon = icon("chart-simple"), startExpanded = TRUE,
             menuSubItem("ADHB", tabName = "adhb_general"),
             menuSubItem("ADHK", tabName = "adhk_general"))
  })
  
  observe({
    updateTabItems(session, "sidebar_menu", selected = "adhb_general")
  })
  
  output$pdrb_growth <- renderMenu({
    menuItem("Pertumbuhan Ekonomi", icon = icon("line-chart"),
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
  source("server/adhk_perkapita.R", local = TRUE)
  source("server/qtq.R", local = TRUE)
  source("server/yoy.R", local = TRUE)
  source("server/ctc.R", local = TRUE)
  source("server/share.R", local = TRUE)
  source("server/download.R", local = TRUE)
  source("server/glosarium.R", local = TRUE)
  # lengkapi untuk source lainnya
}

# Run the application 
shinyApp(ui = ui, server = server)

