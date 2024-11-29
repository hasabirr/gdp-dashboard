# Update SelectInput untuk Flag dan Kode Komoditas berdasarkan pilihan triwulan
observe({
  updateSelectInput(session, "inf_tri_flag", choices = unique(inflasi_triwulanan$Flag))
  updateSelectInput(session, "inf_tri_kode_komoditas", choices = unique(inflasi_triwulanan$`Kode Komoditas`))
})

# Tampilkan nama komoditas berdasarkan input kode di kolom pencarian
output$inf_tri_nama_komoditas <- renderText({
  req(inflasi_triwulanan)
  search_term <- input$inf_tri_search_code
  
  # Cari kode komoditas yang sesuai
  nama_komoditas <- inflasi_triwulanan %>%
    filter(`Kode Komoditas` == search_term) %>%
    pull(`Nama Komoditas`)
  
  if (length(nama_komoditas) > 0) {
    return(nama_komoditas[1])
  } else {
    return("Nama Komoditas tidak ditemukan")
  }
})

# Update dropdown Kode Komoditas berdasarkan Flag dan checkbox yang dipilih untuk Triwulanan
output$inf_tri_kodeKomoditasUI <- renderUI({
  req(inflasi_triwulanan)
  komoditas_choices <- inflasi_triwulanan %>%
    filter(Flag == input$inf_tri_flag) %>%
    pull(`Kode Komoditas`)
  
  if (input$inf_tri_select_all) {
    selected_choices <- komoditas_choices
  } else {
    selected_choices <- komoditas_choices[1]
  }
  
  selectInput("inf_tri_kode_komoditas", "Pilih Kode Komoditas:", 
              choices = komoditas_choices, selected = selected_choices, multiple = TRUE)
})

# Filter data Delta IHK Triwulanan
inf_tri_filtered_data <- reactive({
  inflasi_triwulanan %>%
    filter(Flag == input$inf_tri_flag, `Kode Komoditas` %in% input$inf_tri_kode_komoditas)
})

# Plot Delta IHK Triwulanan Per Komoditas Per Triwulan
output$inf_tri_ihk_plot <- renderPlotly({
  data_to_plot <- inf_tri_filtered_data()
  ihk_columns <- colnames(data_to_plot) %>%
    grep("^Inflasi_Triwulan_[1-4]$", ., value = TRUE)
  
  triwulan_order <- c("Inflasi_Triwulan_1", "Inflasi_Triwulan_2", 
                      "Inflasi_Triwulan_3", "Inflasi_Triwulan_4")
  
  ihk_columns_sorted <- triwulan_order[triwulan_order %in% ihk_columns]
  delta_triwulan_terpilih <- paste0("Inflasi_", gsub(" ", "_", input$inf_tri_periode))
  # print(data_to_plot)
  if (!delta_triwulan_terpilih %in% colnames(data_to_plot) || 
      all(is.na(data_to_plot[[delta_triwulan_terpilih]]))) {
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
  
  plot_ly(data_to_plot, x = ~`Kode Komoditas`, y = as.formula(paste0("~", delta_triwulan_terpilih)), 
          type = 'bar', color = ~`Nama Kota`) %>%
    layout(title = paste("Inflasi", input$inf_tri_periode, "(Triwulanan)"), 
           xaxis = list(title = "Kode Komoditas", tickangle = 45), 
           yaxis = list(title = "Inflasi (Triwulanan)"))
})

output$inf_tri_ihk_plot_tahunan <- renderPlotly({
  data_to_plot <- inf_tri_filtered_data()
  
  # Mendapatkan kolom inflasi triwulanan yang tersedia
  ihk_columns <- colnames(data_to_plot) %>%
    grep("^Inflasi_Triwulan_[1-4]$", ., value = TRUE)
  
  # Urutan triwulan dan label untuk x-axis
  triwulan_order <- c("Inflasi_Triwulan_1", "Inflasi_Triwulan_2", 
                      "Inflasi_Triwulan_3", "Inflasi_Triwulan_4")
  ihk_columns_sorted <- triwulan_order[triwulan_order %in% ihk_columns]
  
  # Nama singkat triwulan untuk x-axis
  triwulan_labels <- c("Triwulan 1", "Triwulan 2", "Triwulan 3", "Triwulan 4")
  triwulan_labels <- triwulan_labels[1:length(ihk_columns_sorted)]
  
  # Mengubah data menjadi format panjang untuk memplot line chart
  data_long <- data_to_plot %>%
    select(`Kode Komoditas`, `Nama Kota`, all_of(ihk_columns_sorted)) %>%
    tidyr::pivot_longer(cols = ihk_columns_sorted, 
                        names_to = "Triwulan", 
                        values_to = "Inflasi") %>%
    mutate(Triwulan = factor(Triwulan, levels = ihk_columns_sorted, labels = triwulan_labels))
  
  plot_ly(data_long, x = ~Triwulan, y = ~Inflasi, color = ~`Kode Komoditas`, 
          type = 'scatter', mode = 'lines+markers', line = list(shape = 'linear'),
          text = ~paste("Kode Komoditas:", `Kode Komoditas`, "<br>Inflasi:", round(Inflasi,4), "<br>Triwulan:", Triwulan),
          hoverinfo = 'text') %>%
    layout(title = "Inflasi Triwulanan per Kode Komoditas", 
           xaxis = list(title = "Triwulan"), 
           yaxis = list(title = "Inflasi Triwulanan"))
})


# Kenaikan/penurunan terbesar Triwulanan
output$inf_tri_max_change_text <- renderText({
  delta_data <- inf_tri_filtered_data()
  
  if (nrow(delta_data) > 0) {
    delta_triwulan_terpilih <- paste0("Inflasi_", gsub(" ", "_", input$inf_tri_periode))
    
    max_change <- delta_data %>%
      filter(!is.na(get(delta_triwulan_terpilih))) %>%
      arrange(desc(get(delta_triwulan_terpilih))) %>%
      slice(1)
    
    min_change <- delta_data %>%
      filter(!is.na(get(delta_triwulan_terpilih))) %>%
      arrange(get(delta_triwulan_terpilih)) %>%
      slice(1)
    
    if (max_change$`Kode Komoditas` == 0 || min_change$`Kode Komoditas` == 0) {
      output_text <- ""
    } else if (abs(max_change[[delta_triwulan_terpilih]]) > abs(min_change[[delta_triwulan_terpilih]])) {
      output_text <- paste("Kenaikan Terbesar:<br>",
                           "<strong>Kode Komoditas:</strong> ", max_change$`Kode Komoditas`, "<br>",
                           "<strong>Nama Komoditas:</strong> ", max_change$`Nama Komoditas`, "<br>",
                           "<strong>Nilai:</strong> ", round(max_change[[delta_triwulan_terpilih]], 2))
    } else {
      output_text <- paste("Penurunan Terbesar:<br>",
                           "<strong>Kode Komoditas:</strong> ", min_change$`Kode Komoditas`, "<br>",
                           "<strong>Nama Komoditas:</strong> ", min_change$`Nama Komoditas`, "<br>",
                           "<strong>Nilai:</strong> ", round(min_change[[delta_triwulan_terpilih]], 2))
    }
    
    return(HTML(output_text))
  } else {
    return("Data tidak tersedia.")
  }
})

# 10 Komoditas dengan kenaikan terbesar Triwulanan
output$inf_tri_top_increase <- renderTable({
  delta_data <- inf_tri_filtered_data()
  
  if (nrow(delta_data) > 0) {
    delta_triwulan_terpilih <- paste0("Inflasi_", gsub(" ", "_", input$inf_tri_periode))
    
    delta_data %>%
      arrange(desc(get(delta_triwulan_terpilih))) %>%
      slice_head(n = 10) %>%
      select(`Kode Komoditas`, `Nama Komoditas`, !!sym(delta_triwulan_terpilih))
  } else {
    return(data.frame(`Kode Komoditas` = character(), `Nama Komoditas` = character(), Nilai = numeric()))
  }
})

# 10 Komoditas dengan penurunan terbesar Triwulanan
output$inf_tri_top_decrease <- renderTable({
  delta_data <- inf_tri_filtered_data()
  
  if (nrow(delta_data) > 0) {
    delta_triwulan_terpilih <- paste0("Inflasi_", gsub(" ", "_", input$inf_tri_periode))
    
    delta_data %>%
      arrange(get(delta_triwulan_terpilih)) %>%
      slice_head(n = 10) %>%
      select(`Kode Komoditas`, `Nama Komoditas`, !!sym(delta_triwulan_terpilih))
  } else {
    return(data.frame(`Kode Komoditas` = character(), `Nama Komoditas` = character(), Nilai = numeric()))
  }
})
