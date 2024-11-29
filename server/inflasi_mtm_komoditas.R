observe({
  updateSelectInput(session, "delta_flag_per_komoditas", choices = unique(ihk_mtm$Flag))
  updateSelectInput(session, "kode_komoditas", choices = unique(ihk_mtm$`Kode Komoditas`))
})

# Kode komoditas dinamis berdasarkan flag
observeEvent(input$delta_flag_per_komoditas, {
  req(ihk_mtm)
  komoditas_choices <- ihk_mtm %>%
    filter(Flag == input$delta_flag_per_komoditas) %>%
    pull(`Kode Komoditas`)
  
  updateSelectInput(session, "kode_komoditas_flag", 
                    choices = komoditas_choices, 
                    selected = komoditas_choices[1])
})

# Plot Delta IHK Per Komoditas
output$delta_komoditas_plot <- renderPlotly({
  req(ihk_tahunan)
  req(ihk_mtm)
  data_filtered <- ihk_mtm %>%
    filter(`Kode Komoditas` == input$kode_komoditas_flag)
  
  if (nrow(data_filtered) == 0) {
    return(NULL)
  }
  
  ihk_columns <- colnames(ihk_mtm) %>%
    grep("^Inflasi_[A-Za-z]+$", ., value = TRUE)
  
  
  if (length(ihk_columns) == 0) {
    return(NULL)
  }
  
  urutan_manual <- c("Inflasi_Januari", "Inflasi_Februari", "Inflasi_Maret", 
                     "Inflasi_April", "Inflasi_Mei", "Inflasi_Juni", 
                     "Inflasi_Juli", "Inflasi_Agustus", 
                     "Inflasi_September", "Inflasi_Oktober", 
                     "Inflasi_November", "Inflasi_Desember")
  
  ihk_columns_sorted <- urutan_manual[urutan_manual %in% ihk_columns]
  
  data_long <- data_filtered %>%
    tidyr::pivot_longer(cols = all_of(ihk_columns_sorted), 
                        names_to = "Bulan", 
                        values_to = "Nilai_IHK")
  
  data_long$Bulan <- factor(data_long$Bulan, levels = ihk_columns_sorted)
  
  nama_komoditas <- ihk_tahunan %>%
    filter(`Kode Komoditas` == input$kode_komoditas_flag) %>%
    pull(`Nama Komoditas`)
  
  plot_ly(data_long, x = ~Bulan, y = ~Nilai_IHK, type = 'scatter', mode = 'lines+markers') %>%
    layout(title = paste("Inflasi untuk Kode Komoditas", input$kode_komoditas_flag),
           xaxis = list(title = "Bulan", tickangle = 45),
           yaxis = list(title = "Inflasi"))
})

# Kenaikan/penurunan terbesar
output$max_change_text2 <- renderText({
  delta_data2 <- ihk_mtm %>%
    filter(`Kode Komoditas` %in% input$kode_komoditas_flag)
  
  if (nrow(delta_data2) > 0) {
    ihk_columns <- colnames(ihk_mtm) %>%
      grep("^Inflasi_[A-Za-z]+$", ., value = TRUE)
    
    max_change2 <- delta_data2 %>%
      select(`Kode Komoditas`, `Nama Komoditas`, all_of(ihk_columns)) %>%
      tidyr::pivot_longer(cols = all_of(ihk_columns), names_to = "Bulan", values_to = "Nilai_IHK") %>%
      filter(!is.na(Nilai_IHK)) %>%
      arrange(desc(Nilai_IHK)) %>%
      slice(1)
    
    min_change2 <- delta_data2 %>%
      select(`Kode Komoditas`, `Nama Komoditas`, all_of(ihk_columns)) %>%
      tidyr::pivot_longer(cols = all_of(ihk_columns), names_to = "Bulan", values_to = "Nilai_IHK") %>%
      filter(!is.na(Nilai_IHK)) %>%
      arrange(Nilai_IHK) %>%
      slice(1)
    
    if (max_change2$`Kode Komoditas` == 0 || min_change2$`Kode Komoditas` == 0) {
      output_text2 <- "Pilih komoditas terlebih dahulu!"
    } else if (abs(max_change2$Nilai_IHK) > abs(min_change2$Nilai_IHK)) {
      output_text2 <- paste("Kenaikan Terbesar:<br>",
                            "<strong>Kode Komoditas:</strong> ", max_change2$`Kode Komoditas`, "<br>",
                            "<strong>Nama Komoditas:</strong> ", max_change2$`Nama Komoditas`, "<br>",
                            "<strong>Bulan:</strong> ", max_change2$Bulan, "<br>",
                            "<strong>Nilai:</strong> ", round(max_change2$Nilai_IHK, 2))
    } else {
      output_text2 <- paste("Penurunan Terbesar:<br>",
                            "<strong>Kode Komoditas:</strong> ", min_change2$`Kode Komoditas`, "<br>",
                            "<strong>Nama Komoditas:</strong> ", min_change2$`Nama Komoditas`, "<br>",
                            "<strong>Bulan:</strong> ", min_change2$Bulan, "<br>",
                            "<strong>Nilai:</strong> ", round(min_change2$Nilai_IHK, 2))
    }
    
    return(HTML(output_text2))
  } else {
    return("Data tidak tersedia.")
  }
})