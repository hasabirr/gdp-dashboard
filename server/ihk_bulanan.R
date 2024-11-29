observe({
  updateSelectInput(session, "flag", choices = unique(ihk_tahunan$Flag))
  updateSelectInput(session, "kode_komoditas", choices = unique(ihk_tahunan$`Kode Komoditas`))
})

# Update daftar kode komoditas berdasarkan Flag dan checkbox yang dipilih
output$kodeKomoditasUI <- renderUI({
  req(ihk_tahunan)
  komoditas_choices <- ihk_tahunan %>%
    filter(Flag == input$flag) %>%
    pull(`Kode Komoditas`)
  
  if (input$select_all) {
    selected_choices <- komoditas_choices
  } else {
    selected_choices <- komoditas_choices[1]
  }
  
  selectInput("kode_komoditas", "Pilih Kode Komoditas:", 
              choices = komoditas_choices, selected = selected_choices, multiple = TRUE)
})

# Filter data sesuai input pengguna
filtered_data <- reactive({
  req(ihk_tahunan)
  ihk_tahunan %>%
    filter(Flag == input$flag, `Kode Komoditas` %in% input$kode_komoditas)
})

# Plot IHK
output$ihk_plot <- renderPlotly({
  bulan_terpilih <- paste0("IHK_", input$bulan)
  data_to_plot <- filtered_data()
  
  # Cek apakah data bulan yang dipilih tersedia
  if (!bulan_terpilih %in% colnames(data_to_plot)) {
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
  
  plot_ly(data_to_plot, x = ~`Kode Komoditas`, y = as.formula(paste0("~", bulan_terpilih)), 
          type = 'bar', color = ~`Nama Kota`) %>%
    layout(title = paste("IHK -", input$bulan), 
           xaxis = list(title = "Kode Komoditas"), 
           yaxis = list(title = "Indeks Harga Konsumen (IHK)"))
})

# Plot IHK (Line Chart)
output$ihk_plot_tahunan <- renderPlotly({
  data_to_plot <- filtered_data()
  
  # Mendapatkan kolom IHK dalam urutan Januari hingga Desember
  ihk_columns <- colnames(data_to_plot) %>%
    grep("^IHK_[A-Za-z]+$", ., value = TRUE)
  bulan_order <- c("IHK_Januari", "IHK_Februari", "IHK_Maret", 
                   "IHK_April", "IHK_Mei", "IHK_Juni", 
                   "IHK_Juli", "IHK_Agustus", 
                   "IHK_September", "IHK_Oktober", 
                   "IHK_November", "IHK_Desember")
  ihk_columns_sorted <- bulan_order[bulan_order %in% ihk_columns]
  
  # Membatasi nama bulan singkat hanya untuk kolom yang tersedia
  bulan_singkat <- c("Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des")
  bulan_singkat <- bulan_singkat[1:length(ihk_columns_sorted)]
  
  # Mengubah data menjadi format panjang untuk memplot line chart
  data_long <- data_to_plot %>%
    select(`Kode Komoditas`, `Nama Kota`, all_of(ihk_columns_sorted)) %>%
    tidyr::pivot_longer(cols = ihk_columns_sorted, 
                        names_to = "Bulan", 
                        values_to = "IHK") %>%
    mutate(Bulan = factor(Bulan, levels = ihk_columns_sorted, labels = bulan_singkat))
  
  plot_ly(data_long, x = ~Bulan, y = ~IHK, color = ~`Kode Komoditas`, 
          type = 'scatter', mode = 'lines+markers', line = list(shape = 'linear'),
          text = ~paste("Kode Komoditas:", `Kode Komoditas`, "<br>IHK:", round(IHK, 4), "<br>Bulan:", Bulan),
          hoverinfo = 'text') %>%
    layout(title = "Indeks Harga Konsumen (IHK)", 
           xaxis = list(title = "Bulan"), 
           yaxis = list(title = "Indeks Harga Konsumen (IHK)"))
})


# Tampilkan nama komoditas berdasarkan input kode komoditas
output$nama_komoditas <- renderText({
  req(ihk_tahunan)
  search_term <- input$search_code
  nama_komoditas <- ihk_tahunan %>%
    filter(`Kode Komoditas` == search_term) %>%
    pull(`Nama Komoditas`)
  
  if (length(nama_komoditas) > 0) {
    return(nama_komoditas[1])
  } else {
    return("Nama Komoditas tidak ditemukan")
  }
})

# Tabel
# Tabel dinamis dengan scroll dan pilihan jumlah baris
output$filtered_table <- renderDT({
  data_to_show <- filtered_data()
  
  # Kolom bulan yang dipilih
  bulan_terpilih <- paste0("IHK_", input$bulan)
  
  # Pastikan kolom bulan tersedia di data
  if (!bulan_terpilih %in% colnames(data_to_show)) {
    return(data.frame(Pesan = "Data Tidak Tersedia untuk bulan yang dipilih"))
  }
  
  # Pilih kolom yang relevan: Kode Komoditas, Nama Komoditas, dan bulan yang dipilih
  data_to_show <- data_to_show %>%
    select(`Kode Komoditas`, `Nama Komoditas`, all_of(bulan_terpilih)) %>%
    rename(!!input$bulan := !!bulan_terpilih)  # Rename kolom bulan yang dipilih
  
  # Kembalikan data dalam format DT
  datatable(data_to_show, 
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