observe({
  updateSelectInput(session, "yoy_flag", choices = unique(ihk_yoy$Flag))
  updateSelectInput(session, "kode_komoditas", choices = unique(ihk_yoy$`Kode Komoditas`))
})

# Tampilkan nama komoditas berdasarkan input kode di kolom pencarian
output$nama_komoditas_yoy <- renderText({
  req(ihk_tahunan)
  search_term <- input$search_code_yoy
  
  # Cari kode komoditas yang sesuai
  nama_komoditas_yoy <- ihk_tahunan %>%
    filter(`Kode Komoditas` == search_term) %>%
    pull(`Nama Komoditas`)
  
  if (length(nama_komoditas_yoy) > 0) {
    return(nama_komoditas_yoy[1])
  } else {
    return("Nama Komoditas tidak ditemukan")
  }
})

# Update dropdown Kode Komoditas berdasarkan Flag dan checkbox yang dipilih di Y-O-Y IHK
output$yoyKodeKomoditasUI <- renderUI({
  komoditas_choices <- ihk_yoy %>%
    filter(Flag == input$yoy_flag) %>%
    pull(`Kode Komoditas`)
  
  if (input$yoy_select_all) {
    # Jika checkbox dicentang, pilih semua kode komoditas yang sesuai
    selected_choices <- komoditas_choices
  } else {
    # Jika checkbox tidak dicentang, biarkan pilihan pertama saja yang terpilih
    selected_choices <- komoditas_choices[1]
  }
  
  selectInput("yoy_kode_komoditas", "Pilih Kode Komoditas:", 
              choices = komoditas_choices, selected = selected_choices, multiple = TRUE)
})

# Filter data Y-O-Y IHK
yoy_filtered_data <- reactive({
  ihk_yoy %>%
    filter(Flag == input$yoy_flag, `Kode Komoditas` %in% input$yoy_kode_komoditas)
})

# Plot Y-O-Y IHK Per Komoditas Per Bulan
output$yoy_ihk_plot <- renderPlotly({
  data_to_plot <- yoy_filtered_data()
  
  ihk_columns <- colnames(data_to_plot) %>%
    grep("^Inflasi_[A-Za-z]+$", ., value = TRUE)
  
  bulan_order <- c("Inflasi_Januari", "Inflasi_Februari", "Inflasi_Maret", 
                   "Inflasi_April", "Inflasi_Mei", "Inflasi_Juni", 
                   "Inflasi_Juli", "Inflasi_Agustus", 
                   "Inflasi_September", "Inflasi_Oktober", 
                   "Inflasi_November", "Inflasi_Desember")
  
  ihk_columns_sorted <- bulan_order[bulan_order %in% ihk_columns]
  yoy_bulan_terpilih <- paste0("Inflasi_", input$yoy_bulan)
  
  # Cek apakah data bulan yang dipilih tersedia
  if (!yoy_bulan_terpilih %in% colnames(data_to_plot) || 
      all(is.na(data_to_plot[[yoy_bulan_terpilih]]))) {
    return(
      plot_ly() %>% 
        layout(
          xaxis = list(visible = FALSE),
          yaxis = list(visible = FALSE),
          annotations = list(
            x = 0.5, 
            y = 0.5, 
            text = "Data Tidak Tersedia", 
            showarrow = FALSE,
            font = list(size = 20)
          )
        )
    )
  }
  
  plot_ly(data_to_plot, x = ~`Kode Komoditas`, y = as.formula(paste0("~", yoy_bulan_terpilih)), 
          type = 'bar', color = ~`Nama Kota`) %>%
    layout(title = paste("Inflasi Bulan", input$yoy_bulan, "(y-o-y)"), 
           xaxis = list(title = "Kode Komoditas", tickangle = 45), 
           yaxis = list(title = "Inflasi (y-o-y)"))
})

# Plot Tahunan (Line Chart)
output$yoy_ihk_plot_tahunan <- renderPlotly({
  data_to_plot <- yoy_filtered_data()
  
  # Mendapatkan kolom inflasi bulanan dalam urutan Januari hingga Desember
  ihk_columns <- colnames(data_to_plot) %>%
    grep("^Inflasi_[A-Za-z]+$", ., value = TRUE)
  bulan_order <- c("Inflasi_Januari", "Inflasi_Februari", "Inflasi_Maret", 
                   "Inflasi_April", "Inflasi_Mei", "Inflasi_Juni", 
                   "Inflasi_Juli", "Inflasi_Agustus", 
                   "Inflasi_September", "Inflasi_Oktober", 
                   "Inflasi_November", "Inflasi_Desember")
  ihk_columns_sorted <- bulan_order[bulan_order %in% ihk_columns]
  
  # Membatasi nama bulan singkat hanya untuk kolom yang tersedia
  bulan_singkat <- c("Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des")
  bulan_singkat <- bulan_singkat[1:length(ihk_columns_sorted)]
  
  # Mengubah data menjadi format panjang untuk memplot line chart
  data_long <- data_to_plot %>%
    select(`Kode Komoditas`, `Nama Kota`, all_of(ihk_columns_sorted)) %>%
    tidyr::pivot_longer(cols = ihk_columns_sorted, 
                        names_to = "Bulan", 
                        values_to = "Inflasi") %>%
    mutate(Bulan = factor(Bulan, levels = ihk_columns_sorted, labels = bulan_singkat))
  
  plot_ly(data_long, x = ~Bulan, y = ~Inflasi, color = ~`Kode Komoditas`, 
          type = 'scatter', mode = 'lines+markers', line = list(shape = 'linear'),
          text = ~paste("Kode Komoditas:", `Kode Komoditas`, "<br>Inflasi:", round(Inflasi,4), "<br>Bulan:", Bulan),
          hoverinfo = 'text') %>%
    layout(title = "Inflasi Year-on-Year", 
           xaxis = list(title = "Bulan"), 
           yaxis = list(title = "Inflasi (y-on-y)"))
})

# Kenaikan/penurunan terbesar
output$max_change_yoy_text <- renderText({
  yoy_data <- yoy_filtered_data()
  
  if (nrow(yoy_data) > 0) {
    yoy_bulan_terpilih <- paste0("Inflasi_", input$yoy_bulan)
    
    max_change <- yoy_data %>%
      filter(!is.na(get(yoy_bulan_terpilih))) %>%
      arrange(desc(get(yoy_bulan_terpilih))) %>%
      slice(1)
    
    min_change <- yoy_data %>%
      filter(!is.na(get(yoy_bulan_terpilih))) %>%
      arrange(get(yoy_bulan_terpilih)) %>%
      slice(1)
    
    if (max_change$`Kode Komoditas` == 0 || min_change$`Kode Komoditas` == 0) {
      output_text <- ""
    } else if (abs(max_change[[yoy_bulan_terpilih]]) > abs(min_change[[yoy_bulan_terpilih]])) {
      output_text <- paste("Kenaikan Terbesar:<br>",
                           "<strong>Kode Komoditas:</strong> ", max_change$`Kode Komoditas`, "<br>",
                           "<strong>Nama Komoditas:</strong> ", max_change$`Nama Komoditas`, "<br>",
                           "<strong>Nilai:</strong> ", round(max_change[[yoy_bulan_terpilih]], 2))
    } else {
      output_text <- paste("Penurunan Terbesar:<br>",
                           "<strong>Kode Komoditas:</strong> ", min_change$`Kode Komoditas`, "<br>",
                           "<strong>Nama Komoditas:</strong> ", min_change$`Nama Komoditas`, "<br>",
                           "<strong>Nilai:</strong> ", round(min_change[[yoy_bulan_terpilih]], 2))
    }
    
    return(HTML(output_text))
  } else {
    return("Data tidak tersedia.")
  }
})

# 10 Komoditas dengan kenaikan terbesar
output$top_increase_yoy <- renderTable({
  yoy_data <- yoy_filtered_data()
  
  if (nrow(yoy_data) > 0) {
    yoy_bulan_terpilih <- paste0("Inflasi_", input$yoy_bulan)
    
    yoy_data %>%
      arrange(desc(get(yoy_bulan_terpilih))) %>%
      slice_head(n = 10) %>%
      select(`Kode Komoditas`, `Nama Komoditas`, !!sym(yoy_bulan_terpilih)) %>%
      mutate(!!sym(yoy_bulan_terpilih) := sprintf("%.4f", !!sym(yoy_bulan_terpilih)))
  } else {
    return(data.frame(`Kode Komoditas` = character(), `Nama Komoditas` = character(), Nilai = numeric()))
  }
})

# 10 Komoditas dengan penurunan terbesar
output$top_decrease_yoy <- renderTable({
  yoy_data <- yoy_filtered_data()
  
  if (nrow(yoy_data) > 0) {
    yoy_bulan_terpilih <- paste0("Inflasi_", input$yoy_bulan)
    
    yoy_data %>%
      arrange(get(yoy_bulan_terpilih)) %>%
      slice_head(n = 10) %>%
      select(`Kode Komoditas`, `Nama Komoditas`, !!sym(yoy_bulan_terpilih)) %>%
      mutate(!!sym(yoy_bulan_terpilih) := sprintf("%.4f", !!sym(yoy_bulan_terpilih)))
  } else {
    return(data.frame(`Kode Komoditas` = character(), `Nama Komoditas` = character(), Nilai = numeric()))
  }
})