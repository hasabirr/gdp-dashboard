observe({
  updateSelectInput(session, "flag_triwulan", choices = unique(ihk_triwulanan$Flag))
  updateSelectInput(session, "kode_komoditas", choices = unique(ihk_triwulanan$`Kode Komoditas`))
})

# Update daftar kode komoditas berdasarkan Flag dan checkbox yang dipilih untuk Triwulan
output$kodeKomoditasTriwulanUI <- renderUI({
  # req(ihk_triwulanan)
  komoditas_choices_triwulan <- ihk_triwulanan %>%
    filter(Flag == input$flag_triwulan) %>%
    pull(`Kode Komoditas`)
  
  if (input$select_all_triwulan) {
    selected_choices_triwulan <- komoditas_choices_triwulan
  } else {
    selected_choices_triwulan <- komoditas_choices_triwulan[1]
  }
  
  selectInput("kode_komoditas_triwulan", "Pilih Kode Komoditas:", 
              choices = komoditas_choices_triwulan, selected = selected_choices_triwulan, multiple = TRUE)
})

# Filter data sesuai input pengguna untuk Triwulan
filtered_data_triwulan <- reactive({
  # req(ihk_triwulanan)
  ihk_triwulanan %>%
    filter(Flag == input$flag_triwulan, `Kode Komoditas` %in% input$kode_komoditas_triwulan)
})

# Plot IHK Triwulanan
output$ihk_plot_triwulan <- renderPlotly({
  # req(ihk_triwulanan)
  triwulan_terpilih <- paste0("Triwulan_", gsub("Triwulan ", "", input$triwulan))
  data_to_plot_triwulan <- filtered_data_triwulan()
  
  # Cek apakah data triwulan yang dipilih tersedia
  if (!triwulan_terpilih %in% colnames(data_to_plot_triwulan)) {
    return(plot_ly() %>% 
             layout(xaxis = list(visible = FALSE),
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
  
  plot_ly(data_to_plot_triwulan, x = ~`Kode Komoditas`, y = as.formula(paste0("~", triwulan_terpilih)), 
          type = 'bar', color = ~`Nama Kota`) %>%
    layout(title = paste("IHK -", input$triwulan), 
           xaxis = list(title = "Kode Komoditas"), 
           yaxis = list(title = "Indeks Harga Konsumen (IHK) Triwulanan"))
})

# Plot IHK Triwulanan (Line Chart)
output$ihk_plot_triwulanan_tahunan <- renderPlotly({
  data_to_plot_triwulan <- filtered_data_triwulan()
  
  # Mendapatkan kolom triwulan dalam urutan Triwulan 1 hingga Triwulan 4
  triwulan_columns <- colnames(data_to_plot_triwulan) %>%
    grep("^Triwulan_[0-9]+$", ., value = TRUE)
  triwulan_order <- c("Triwulan_1", "Triwulan_2", "Triwulan_3", "Triwulan_4")
  triwulan_columns_sorted <- triwulan_order[triwulan_order %in% triwulan_columns]
  
  # Membatasi nama triwulan singkat hanya untuk kolom yang tersedia
  triwulan_singkat <- c("Triwulan 1", "Triwulan 2", "Triwulan 3", "Triwulan 4")
  triwulan_singkat <- triwulan_singkat[1:length(triwulan_columns_sorted)]
  print(data_to_plot_triwulan)
  # Mengubah data menjadi format panjang untuk memplot line chart
  data_long <- data_to_plot_triwulan %>%
    select(`Kode Komoditas`, `Nama Kota`, all_of(triwulan_columns_sorted)) %>%
    tidyr::pivot_longer(cols = triwulan_columns_sorted, 
                        names_to = "Triwulan", 
                        values_to = "IHK") %>%
    mutate(Triwulan = factor(Triwulan, levels = triwulan_columns_sorted, labels = triwulan_singkat))
  
  plot_ly(data_long, x = ~Triwulan, y = ~IHK, color = ~`Kode Komoditas`, 
          type = 'scatter', mode = 'lines+markers', line = list(shape = 'linear'),
          text = ~paste("Kode Komoditas:", `Kode Komoditas`, "<br>IHK:", round(IHK, 4), "<br>Triwulan:", Triwulan),
          hoverinfo = 'text') %>%
    layout(title = "Indeks Harga Konsumen (IHK) Triwulanan", 
           xaxis = list(title = "Triwulan"), 
           yaxis = list(title = "Indeks Harga Konsumen (IHK)"))
})

# Tampilkan nama komoditas berdasarkan input kode komoditas untuk Triwulan
output$nama_komoditas_triwulan <- renderText({
  # req(ihk_triwulanan)
  search_term_triwulan <- input$search_code_triwulan
  nama_komoditas_triwulan <- ihk_triwulanan %>%
    filter(`Kode Komoditas` == search_term_triwulan) %>%
    pull(`Nama Komoditas`)
  
  if (length(nama_komoditas_triwulan) > 0) {
    return(nama_komoditas_triwulan[1])
  } else {
    return("Nama Komoditas tidak ditemukan")
  }
})

# Tabel IHK Triwulanan
output$filtered_table_triwulan <- renderDT({
  # req(ihk_triwulanan)
  data_to_show_triwulan <- filtered_data_triwulan()
  
  # Kolom triwulan yang dipilih
  triwulan_terpilih <- paste0("Triwulan_", gsub("Triwulan ", "", input$triwulan))
  
  # Pastikan kolom triwulan tersedia di data
  if (!triwulan_terpilih %in% colnames(data_to_show_triwulan)) {
    return(data.frame(Pesan = "Data Tidak Tersedia untuk triwulan yang dipilih"))
  }
  
  # Pilih kolom yang relevan: Kode Komoditas, Nama Komoditas, dan triwulan yang dipilih
  data_to_show_triwulan <- data_to_show_triwulan %>%
    select(`Kode Komoditas`, `Nama Komoditas`, all_of(triwulan_terpilih)) %>%
    rename(!!input$triwulan := !!triwulan_terpilih)  # Rename kolom triwulan yang dipilih
  
  # Kembalikan data dalam format DT
  datatable(data_to_show_triwulan, 
            options = list(
              pageLength = 10,         
              lengthMenu = c(10, 20, 50), 
              scrollX = TRUE,     
              autoWidth = TRUE,    
              columnDefs = list(list(width = '150px', targets = 0), 
                                list(width = '100%', targets = "_all"))
            ),
            rownames = FALSE) # Hapus nomor baris
})
