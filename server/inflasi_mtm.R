observe({
  updateSelectInput(session, "delta_flag", choices = unique(ihk_mtm$Flag))
  updateSelectInput(session, "kode_komoditas", choices = unique(ihk_mtm$`Kode Komoditas`))
})

# Tampilkan nama komoditas berdasarkan input kode di kolom pencarian
output$nama_komoditas2 <- renderText({
  req(ihk_tahunan)
  search_term <- input$search_code2
  
  # Cari kode komoditas yang sesuai
  nama_komoditas2 <- ihk_tahunan %>%
    filter(`Kode Komoditas` == search_term) %>%
    pull(`Nama Komoditas`)
  
  if (length(nama_komoditas2) > 0) {
    return(nama_komoditas2[1])
  } else {
    return("Nama Komoditas tidak ditemukan")
  }
})

# Update dropdown Kode Komoditas berdasarkan Flag dan checkbox yang dipilih di Delta IHK
output$deltaKodeKomoditasUI <- renderUI({
  req(ihk_mtm)
  komoditas_choices <- ihk_mtm %>%
    filter(Flag == input$delta_flag) %>%
    pull(`Kode Komoditas`)
  
  if (input$delta_select_all) {
    # Jika checkbox dicentang, pilih semua kode komoditas yang sesuai
    selected_choices <- komoditas_choices
  } else {
    # Jika checkbox tidak dicentang, biarkan pilihan pertama saja yang terpilih
    selected_choices <- komoditas_choices[1]
  }
  
  selectInput("delta_kode_komoditas", "Pilih Kode Komoditas:", 
              choices = komoditas_choices, selected = selected_choices, multiple = TRUE)
})

# Filter data Delta IHK
delta_filtered_data <- reactive({
  ihk_mtm %>%
    filter(Flag == input$delta_flag, `Kode Komoditas` %in% input$delta_kode_komoditas)
})

# Plot Delta IHK Per Komoditas Per Bulan
output$delta_ihk_plot <- renderPlotly({
  data_to_plot <- delta_filtered_data()
  ihk_columns <- colnames(data_to_plot) %>%
    grep("^Inflasi_[A-Za-z]+$", ., value = TRUE)
  
  bulan_order <- c("Inflasi_Januari", "Inflasi_Februari", "Inflasi_Maret", 
                   "Inflasi_April", "Inflasi_Mei", "Inflasi_Juni", 
                   "Inflasi_Juli", "Inflasi_Agustus", 
                   "Inflasi_September", "Inflasi_Oktober", 
                   "Inflasi_November", "Inflasi_Desember")
  
  ihk_columns_sorted <- bulan_order[bulan_order %in% ihk_columns]
  delta_bulan_terpilih <- paste0("Inflasi_", input$delta_bulan)
  
  # Cek apakah data bulan yang dipilih tersedia
  if (!delta_bulan_terpilih %in% colnames(data_to_plot) || 
      all(is.na(data_to_plot[[delta_bulan_terpilih]]))) {
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
  
  plot_ly(data_to_plot, x = ~`Kode Komoditas`, y = as.formula(paste0("~", delta_bulan_terpilih)), 
          type = 'bar', color = ~`Nama Kota`) %>%
    layout(title = paste("Inflasi Bulan", input$delta_bulan, "(m-to-m)"), 
           xaxis = list(title = "Kode Komoditas", tickangle = 45), 
           yaxis = list(title = "Inflasi (m-to-m)"))
})

# Plot Tahunan (Line Chart)
output$delta_ihk_plot_tahunan <- renderPlotly({
  data_to_plot <- delta_filtered_data()
  
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
    layout(title = "Inflasi Month-to-Month", 
           xaxis = list(title = "Bulan"), 
           yaxis = list(title = "Inflasi (m-to-m)"))
})

# Kenaikan/penurunan terbesar
output$max_change_text <- renderText({
  delta_data <- delta_filtered_data()
  
  if (nrow(delta_data) > 0) {
    delta_bulan_terpilih <- paste0("Inflasi_", input$delta_bulan)
    
    max_change <- delta_data %>%
      filter(!is.na(get(delta_bulan_terpilih))) %>%
      arrange(desc(get(delta_bulan_terpilih))) %>%
      slice(1)
    
    min_change <- delta_data %>%
      filter(!is.na(get(delta_bulan_terpilih))) %>%
      arrange(get(delta_bulan_terpilih)) %>%
      slice(1)
    
    if (max_change$`Kode Komoditas` == 0 || min_change$`Kode Komoditas` == 0) {
      output_text <- "Pilih Flag > 0 terlebih dahulu"
    } else if (abs(max_change[[delta_bulan_terpilih]]) > abs(min_change[[delta_bulan_terpilih]])) {
      output_text <- paste("Kenaikan Terbesar:<br>",
                           "<strong>Kode Komoditas:</strong> ", max_change$`Kode Komoditas`, "<br>",
                           "<strong>Nama Komoditas:</strong> ", max_change$`Nama Komoditas`, "<br>",
                           "<strong>Nilai:</strong> ", round(max_change[[delta_bulan_terpilih]], 2))
    } else {
      output_text <- paste("Penurunan Terbesar:<br>",
                           "<strong>Kode Komoditas:</strong> ", min_change$`Kode Komoditas`, "<br>",
                           "<strong>Nama Komoditas:</strong> ", min_change$`Nama Komoditas`, "<br>",
                           "<strong>Nilai:</strong> ", round(min_change[[delta_bulan_terpilih]], 2))
    }
    
    return(HTML(output_text))
  } else {
    return("Data tidak tersedia.")
  }
})

# 10 Komoditas dengan kenaikan terbesar
output$top_increase <- renderTable({
  delta_data <- delta_filtered_data()
  
  if (nrow(delta_data) > 0) {
    delta_bulan_terpilih <- paste0("Inflasi_", input$delta_bulan)
    
    delta_data %>%
      arrange(desc(get(delta_bulan_terpilih))) %>%
      head(10) %>%
      select(`Kode Komoditas`, `Nama Komoditas`, !!sym(delta_bulan_terpilih)) %>%
      mutate(!!sym(delta_bulan_terpilih) := sprintf("%.4f", !!sym(delta_bulan_terpilih)))
  } else {
    return(data.frame(`Kode Komoditas` = character(), `Nama Komoditas` = character(), Nilai = numeric()))
  }
})

# 10 Komoditas dengan penurunan terbesar
output$top_decrease <- renderTable({
  delta_data <- delta_filtered_data()
  
  if (nrow(delta_data) > 0) {
    delta_bulan_terpilih <- paste0("Inflasi_", input$delta_bulan)
    
    delta_data %>%
      arrange(get(delta_bulan_terpilih)) %>%
      slice_head(n = 10) %>%
      select(`Kode Komoditas`, `Nama Komoditas`, !!sym(delta_bulan_terpilih)) %>%
      mutate(!!sym(delta_bulan_terpilih) := sprintf("%.4f", !!sym(delta_bulan_terpilih)))
  } else {
    return(data.frame(`Kode Komoditas` = character(), `Nama Komoditas` = character(), Nilai = numeric()))
  }
})