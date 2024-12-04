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
  mutate(across(4:ncol(.), ~ round(., 4))) # Membulatkan kolom ke-4 hingga terakhir ke 4 digit

adhk <- read_excel("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/data/data_pdrb.xlsx", sheet = "adhk") %>%
  mutate(kode = factor(kode)) %>%
  mutate(across(4:ncol(.), ~ round(., 4))) # Membulatkan kolom ke-4 hingga terakhir ke 4 digit


# UI Definition
ui <- dashboardPage(
  source("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/ui/ui_header.R")$value,
  source("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/ui/ui_sidebar.R")$value,
  source("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/ui/ui_body.R")$value
)

# Server Logic
server <- function(input, output, session) {
  
  # Update available flags in the dropdown
  observe({
    updateSelectInput(session, "flag_pdrb", choices = unique(adhb$flag))
  })
  
  # Menampilkan kode yang sesuai dengan flag yang dipilih
  output$kodeUI_pdrb <- renderUI({
    kode_choices <- adhb %>%
      filter(flag == input$flag_pdrb) %>%
      pull(kode)
    
    if (input$select_all_pdrb) {
      selected_choices <- kode_choices
    } else {
      selected_choices <- kode_choices[1]
    }
    
    selectInput("kode_pdrb", "Pilih Kode:",
                choices = kode_choices, selected = selected_choices, multiple = TRUE)
  })
  
  # Menampilkan nama lapangan usaha berdasarkan kode
  output$nama_lapangan_usaha <- renderText({
    search_term <- input$search_code
    nama <- adhb %>%
      filter(kode == search_term) %>%
      pull(nama)
    
    if (length(nama) > 0) {
      return(nama[1])
    } else {
      return("Nama Lapangan Usaha tidak ditemukan")
    }
  })
  
  # Plot PDRB berdasarkan tahun dan triwulan yang dipilih
  output$pdrb_plot <- renderPlotly({
    # req(input$flag_pdrb, input$kode_pdrb, input$tahun_pdrb, input$triwulan_pdrb)
    
    # Filter data berdasarkan flag, kode, tahun, dan triwulan
    triwulan_col <- paste(input$tahun_pdrb, 
                          switch(input$triwulan_pdrb,
                                 "Triwulan 1" = "_1",
                                 "Triwulan 2" = "_2",
                                 "Triwulan 3" = "_3",
                                 "Triwulan 4" = "_4"), sep = "")
    
    filtered_data <- adhb %>%
      mutate(custom_hover = paste("[", kode, "] ", nama)) %>%
      filter(
        flag == input$flag_pdrb,
        kode %in% input$kode_pdrb
      ) %>%
      select(kode, nama, !!sym(triwulan_col), custom_hover) %>%
      rename(PDRB_Value = !!sym(triwulan_col))
    
    # Plot dengan plotly
    plotly::plot_ly(
      data = filtered_data,
      x = ~kode, # Tetap menggunakan kode pada sumbu x
      y = ~PDRB_Value, # Nilai PDRB pada sumbu y
      type = "bar",
      marker = list(color = "steelblue"),
      hovertemplate = paste(
        "%{customdata}<br>",
        "<b>Nilai: </b> %{y}<extra></extra>"
      ),
      customdata = ~custom_hover # Data tambahan untuk hovertemplate
    ) %>%
      layout(
        title = paste("Grafik PDRB Tahun", input$tahun_pdrb, input$triwulan_pdrb),
        xaxis = list(title = "Kode"),
        yaxis = list(title = "Nilai PDRB"),
        bargap = 0.2
      )
  })
  
  # Tabel
  output$adhb_table <- renderDT({
    data_to_show <- adhb
    datatable(data_to_show, 
              options = list(
                pageLength = 10,         
                lengthMenu = c(10, 20, 50), 
                scrollX = TRUE,     
                autoWidth = TRUE,    
                columnDefs = list(list(width = '100%', targets = "_all"))
              ),
              rownames = FALSE) 
  })
  
  # Update Flag Filter Line Chart
  observe({
    updateSelectInput(session, "flag_line", choices = unique(adhb$flag))
  })
  
  # observe({
  #   updateSelectInput(session, "flag_line_simple", choices = unique(adhb$flag))
  # })
  # 
  
  output$kodeUI_line <- renderUI({
    req(input$flag_line)  # Pastikan flag_line sudah dipilih
    
    # Ambil pilihan kode berdasarkan flag yang dipilih
    kode_choices <- adhb %>%
      filter(flag == input$flag_line) %>%
      pull(kode)
    
    # Logika untuk select all
    if (input$select_all_line) {
      selected_choices <- kode_choices
    } else {
      selected_choices <- kode_choices[1]
    }
    
    # Dropdown untuk memilih kode
    selectInput("kode_line", "Pilih Kode:",
                choices = kode_choices, selected = selected_choices, multiple = TRUE)
  })
  
  
  output$tahun_range_ui <- renderUI({
    # Ambil nama kolom yang berisi data triwulan (seperti 2017_1, 2017_2, ...)
    kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)
    
    # Ekstrak tahun dari nama kolom
    tahun_min <- min(as.integer(sub("_.*", "", kolom_tahun)))  # Ambil tahun dari kolom pertama
    tahun_max <- max(as.integer(sub("_.*", "", kolom_tahun)))  # Ambil tahun dari kolom terakhir
    
    # Buat slider dinamis berdasarkan tahun yang ditemukan
    sliderInput("tahun_range", "Pilih Rentang Tahun:",
                min = tahun_min, max = tahun_max,
                value = c(tahun_min, tahun_max),
                step = 1, animate = TRUE)
  })
  
  output$tahun_range_ui_simple <- renderUI({
    # Ambil nama kolom yang berisi data triwulan (seperti 2017_1, 2017_2, ...)
    kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)
    
    # Ekstrak tahun dari nama kolom
    tahun_min <- min(as.integer(sub("_.*", "", kolom_tahun)))  # Ambil tahun dari kolom pertama
    tahun_max <- max(as.integer(sub("_.*", "", kolom_tahun)))  # Ambil tahun dari kolom terakhir
    
    # Buat slider dinamis berdasarkan tahun yang ditemukan
    sliderInput("tahun_range_simple", "Pilih Rentang Tahun:",
                min = tahun_min, max = tahun_max,
                value = c(tahun_min, tahun_max),
                step = 1, animate = TRUE)
  })
  
  # Pilihan periode (Triwulanan atau Tahunan)
  output$periode_filter_ui <- renderUI({
    radioButtons("periode", "Pilih Periode:",
                 choices = c("Triwulanan" = "Triwulanan", "Tahunan" = "Tahunan"),
                 selected = "Triwulanan")
  })
  
  output$periode_filter_ui_simple <- renderUI({
    radioButtons("periode_simple", "Pilih Periode:",
                 choices = c("Triwulanan" = "Triwulanan", "Tahunan" = "Tahunan"),
                 selected = "Triwulanan")
  })
  
  # Line Simple Chart
  output$line_adhb_simple <- renderPlotly({
    
    # Filter kolom berdasarkan rentang tahun yang dipilih
    kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)
    
    # Ambil kolom yang sesuai dengan rentang tahun dari slider
    tahun_range <- as.integer(input$tahun_range_simple)
    kolom_terpilih <- kolom_tahun[as.integer(sub("_.*", "", kolom_tahun)) >= tahun_range[1] & 
                                    as.integer(sub("_.*", "", kolom_tahun)) <= tahun_range[2]]
    
    data_filtered <- adhb %>%
      filter(flag == 1) %>%  # Hanya baris dengan flag == 1
      select(c(kode, nama, all_of(kolom_terpilih)))  # Pilih kolom yang relevan

    if (input$periode_simple == "Triwulanan") {
      long_data <- data_filtered %>%
        tidyr::pivot_longer(
          cols = -c(kode, nama),
          names_to = "periode",
          values_to = "nilai"
        ) %>%
        mutate(periode = gsub("_", ".", periode)) %>%
        group_by(periode) %>%
        summarise(nilai = sum(nilai, na.rm = TRUE), .groups = "drop")

    } else if (input$periode_simple == "Tahunan") {
      long_data <- data_filtered %>%
        tidyr::pivot_longer(
          cols = -c(kode, nama),
          names_to = "periode",
          values_to = "nilai"
        ) %>%
        mutate(tahun = gsub("_", ".", periode)) %>%
        mutate(tahun = as.integer(substr(periode, 1, 4))) %>%
        group_by(tahun) %>%
        summarise(nilai = sum(nilai, na.rm = TRUE), .groups = "drop") %>%
        mutate(periode = as.character(tahun))
    } else {
      long_data <- NULL
    }
    
    View(long_data)
    # Plot line chart dengan customdata
    plotly::plot_ly(
      data = long_data,
      x = ~periode,
      y = ~nilai,
      # color = ~factor(kode),  # Warna berdasarkan kode
      type = 'scatter',
      mode = 'lines+markers',
      # customdata = ~paste("[", kode, "] ", nama),
      hovertemplate = paste(
        # "<b>%{customdata}</b><br>",
        "<b>Periode:</b> %{x}<br>",
        "<b>Nilai:</b> %{y}<extra></extra>"
      )
    ) %>%
      layout(
        title = paste("Line Chart PDRB - Periode:", input$periode),
        xaxis = list(title = ifelse(input$periode_simple == "Triwulanan", "Periode (Triwulanan)", "Tahun")),
        yaxis = list(title = "Nilai PDRB")
      )
  })
  
  # Line Filter Chart
  output$line_adhb <- renderPlotly({
    req(input$kode_line)  # Pastikan kode_line dipilih
    
    # Filter kolom berdasarkan rentang tahun yang dipilih
    kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)
    
    # Ambil kolom yang sesuai dengan rentang tahun dari slider
    tahun_range <- as.integer(input$tahun_range)
    kolom_terpilih <- kolom_tahun[as.integer(sub("_.*", "", kolom_tahun)) >= tahun_range[1] & 
                                    as.integer(sub("_.*", "", kolom_tahun)) <= tahun_range[2]]
    
    # Filter data berdasarkan flag, kode yang dipilih, dan kolom yang terpilih
    filtered_data <- adhb %>%
      filter(flag == input$flag_line, 
             kode %in% input$kode_line) %>%
      select(kode, nama, all_of(kolom_terpilih))  # Pilih hanya kolom yang sesuai dengan tahun terpilih
    
    # Pisahkan kolom nama dan kolom triwulanan
    nama_data <- filtered_data %>% select(kode, nama)  # Pastikan kode tetap ada di sini

    if(input$periode == "Triwulanan") {
      nama_data <- filtered_data %>% select(kode, nama)
      triwulan_data <- filtered_data %>%
        select(-kode, -nama) %>%
        tidyr::pivot_longer(
          cols = everything(), 
          names_to = "periode", 
          values_to = "nilai"
        ) %>%
        mutate(periode = gsub("_", ".", periode))  # Format periode agar lebih rapi
      
      n_kode <- nrow(filtered_data)  # Jumlah kode yang ada
      n_baris_per_kode <- nrow(triwulan_data) / n_kode  # Jumlah baris per kode setelah pivot

      # Repeat `kode` to match the length of `triwulan_data`
      triwulan_data$kode <- rep(filtered_data$kode, each = n_baris_per_kode)
      
      long_data <- triwulan_data %>%
        left_join(nama_data, by = "kode")
      
    } else if (input$periode == "Tahunan") {
      triwulan_data <- filtered_data %>%
        tidyr::pivot_longer(cols = matches("^\\d{4}(_.*)?$"), 
                            names_to = "periode",
                            values_to = "nilai") %>%
        mutate(periode = as.integer(gsub("_.*", "", periode)))
      long_data <- triwulan_data %>%
        group_by(periode, kode) %>% # Kelompokkan berdasarkan tahun dan kode
        summarise(nilai = sum(nilai, na.rm = TRUE), .groups = "drop") %>%
        left_join(nama_data, by = "kode")
    } else {
        long_data <- NULL
      }

    # Cek apakah kolom periode ada di long_data
    if(!"periode" %in% names(long_data)) {
      stop("Kolom 'periode' tidak ditemukan dalam long_data.")
    }
    
    # Plot line chart dengan customdata
    plotly::plot_ly(
      data = long_data,
      x = ~periode,
      y = ~nilai,
      color = ~factor(kode),  # Warna berdasarkan kode
      type = 'scatter',
      mode = 'lines+markers',
      customdata = ~paste("[", kode, "] ", nama),
      hovertemplate = paste(
        "<b>%{customdata}</b><br>",
        "<b>Periode:</b> %{x}<br>",
        "<b>Nilai:</b> %{y}<extra></extra>"
      )
    ) %>%
      layout(
        title = paste("Line Chart PDRB - Periode:", input$periode),
        xaxis = list(title = ifelse(input$periode == "Triwulanan", "Periode (Triwulanan)", "Tahun")),
        yaxis = list(title = "Nilai PDRB")
      )
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

