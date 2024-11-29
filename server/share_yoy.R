# Update pilihan Flag dan Kode Komoditas berdasarkan data share_yoy
observe({
  updateSelectInput(session, "yoy_share_flag", choices = unique(share_yoy$Flag))
  updateSelectInput(session, "yoy_share_kode_komoditas", choices = unique(share_yoy$`Kode Komoditas`))
})

# Reactive filter for data based on flag and bulan
filtered_share_yoy <- reactive({
  # Tentukan bulan yang dipilih
  bulan_terpilih <- paste0("Share_", input$share_yoy_bulan)
  
  # Filter data berdasarkan flag yang dipilih
  data_filtered <- share_yoy %>%
    select(`Kode Komoditas`, `Nama Komoditas`, `Flag`, `Kode Kota`, !!sym(bulan_terpilih)) %>%
    filter(!is.na(!!sym(bulan_terpilih)))  # Hapus NA pada bulan
  
  # Filter kode komoditas berdasarkan flag yang dipilih
  if (input$share_yoy_flag == "Flag 1 - 2 Digit") {
    data_filtered <- data_filtered %>%
      filter(nchar(`Kode Komoditas`) == 3) %>%
      mutate(`Kode Komoditas 2 Digit` = substr(`Kode Komoditas`, 1, 2))
  } else if (input$share_yoy_flag == "Flag 2 - 3 Digit") {
    data_filtered <- data_filtered %>%
      filter(nchar(`Kode Komoditas`) > 3) %>%
      mutate(`Kode Komoditas 3 Digit` = substr(`Kode Komoditas`, 1, 3))
    
    # Filter untuk Kode Komoditas 2 Digit
    if (input$share_yoy_kode_komoditas_2_digit != "Pilih Semua" && input$share_yoy_kode_komoditas_2_digit != "") {
      data_filtered <- data_filtered %>%
        filter(substr(`Kode Komoditas`, 1, 2) == input$share_yoy_kode_komoditas_2_digit)
    }
  }
  
  # Additional filtering based on selected 2-digit Kode Komoditas
  if (input$share_yoy_flag == "Flag 2 - 3 Digit" && input$share_yoy_kode_komoditas_2_digit != "") {
    if (input$share_yoy_kode_komoditas_2_digit != "Pilih Semua") {
      data_filtered <- data_filtered %>%
        filter(substr(`Kode Komoditas`, 1, 2) == input$share_yoy_kode_komoditas_2_digit)
    }
  }
  
  # Sort the filtered data
  data_filtered <- data_filtered %>%
    arrange(desc(abs(!!sym(bulan_terpilih))))
  
  return(data_filtered)
})

# Update dropdown Kode Komoditas berdasarkan Flag dan checkbox yang dipilih untuk Share yoy
output$yoy_shareKodeKomoditasUI <- renderUI({
  req(share_yoy)
  komoditas_choices <- share_yoy %>%
    filter(Flag == input$yoy_share_flag) %>%
    pull(`Kode Komoditas`) %>%
    unique()
  
  # Tentukan pilihan default untuk checkbox "Pilih Semua"
  if (input$yoy_share_select_all) {
    selected_choices <- komoditas_choices
  } else {
    selected_choices <- komoditas_choices[1]  # Pilih yang pertama jika tidak dicentang
  }
  
  selectInput("yoy_share_kode_komoditas", "Pilih Kode Komoditas:", 
              choices = komoditas_choices, selected = selected_choices, multiple = TRUE)
})

# Update choices for Kode Komoditas 2 Digit based on selected flag
observe({
  if (input$share_yoy_flag == "Flag 2 - 3 Digit") {
    unique_2_digit_codes <- share_yoy %>%
      filter(nchar(`Kode Komoditas`) > 3) %>%
      mutate(`Kode Komoditas 2 Digit` = substr(`Kode Komoditas`, 1, 2)) %>%
      distinct(`Kode Komoditas 2 Digit`) %>%
      pull(`Kode Komoditas 2 Digit`)
    
    choices_with_all <- c("Pilih Semua", unique(unique_2_digit_codes))
    
    updateSelectInput(session, "share_yoy_kode_komoditas_2_digit", 
                      choices = choices_with_all, 
                      selected = "Pilih Semua")
  } else {
    updateSelectInput(session, "share_yoy_kode_komoditas_2_digit", 
                      choices = NULL)
  }
})

output$share_yoy_plot <- renderPlotly({
  data_to_plot <- filtered_share_yoy()
  bulan_terpilih <- paste0("Share_", input$share_yoy_bulan)
  
  if (!is.null(data_to_plot) && nrow(data_to_plot) > 0 && bulan_terpilih %in% names(data_to_plot)) {
    
    # Pisahkan komoditas berdasarkan nilai positif dan negatif
    data_to_plot$positif <- ifelse(data_to_plot[[bulan_terpilih]] > 0, data_to_plot[[bulan_terpilih]], 0)
    data_to_plot$negatif <- ifelse(data_to_plot[[bulan_terpilih]] < 0, data_to_plot[[bulan_terpilih]], 0)
    
    # Pilih kode komoditas berdasarkan flag input
    data_to_plot$kode_komoditas <- if (input$share_yoy_flag == "Flag 1 - 2 Digit") {
      data_to_plot$`Kode Komoditas 2 Digit`
    } else {
      data_to_plot$`Kode Komoditas 3 Digit`
    }
    
    # Generate color palette
    unique_codes <- unique(data_to_plot$`Kode Komoditas`)
    num_colors <- length(unique_codes)
    colors <- brewer.pal(min(num_colors, 12), "Set1")
    if (num_colors > 12) {
      colors <- colorRampPalette(brewer.pal(12, "Set1"))(num_colors)
    }
    color_map <- setNames(colors, unique_codes)
    
    # Create ggplot object with custom tooltip
    p_gg <- ggplot(data_to_plot, aes(x = kode_komoditas)) +
      geom_bar(aes(y = positif, fill = `Kode Komoditas`, 
                   text = paste("Kode Komoditas:", `Kode Komoditas`, "<br>Share:", positif)), stat = "identity") +
      geom_bar(aes(y = negatif, fill = `Kode Komoditas`, 
                   text = paste("Kode Komoditas:", `Kode Komoditas`, "<br>Share:", negatif)), stat = "identity") +
      scale_fill_manual(values = color_map) +
      labs(
        title = paste("Share Inflasi Y-on-Y Bulan", input$share_yoy_bulan, "per Kode Komoditas"),
        x = "Kode Komoditas",
        y = paste("Share", input$share_yoy_bulan),
      ) +
      theme_minimal()
    
    # Convert to plotly with custom tooltip
    p_plotly <- ggplotly(p_gg, tooltip = "text")  # Use custom text for tooltip
    
    return(p_plotly)
  } else {
    plot_ly() %>%
      layout(title = "Tidak ada data untuk ditampilkan.")
  }
})

# Plot Tahunan (Line Chart)
output$yoy_share_plot_tahunan <- renderPlotly({
  data_to_plot <- share_yoy %>%
    filter(
      Flag == input$yoy_share_flag,
      `Kode Komoditas` %in% input$yoy_share_kode_komoditas
    )
  
  # Mendapatkan kolom share bulanan dalam urutan Januari hingga Desember
  share_columns <- colnames(data_to_plot) %>%
    grep("^Share_[A-Za-z]+$", ., value = TRUE)
  
  bulan_order <- c("Share_Januari", "Share_Februari", "Share_Maret", 
                   "Share_April", "Share_Mei", "Share_Juni", 
                   "Share_Juli", "Share_Agustus", 
                   "Share_September", "Share_Oktober", 
                   "Share_November", "Share_Desember")
  share_columns_sorted <- bulan_order[bulan_order %in% share_columns]
  
  # Membatasi nama bulan singkat hanya untuk kolom yang tersedia
  bulan_singkat <- c("Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des")
  bulan_singkat <- bulan_singkat[1:length(share_columns_sorted)]
  
  # Mengubah data menjadi format panjang untuk memplot line chart
  data_long <- data_to_plot %>%
    select(`Kode Komoditas`, `Nama Komoditas`, all_of(share_columns_sorted)) %>%
    tidyr::pivot_longer(cols = share_columns_sorted, 
                        names_to = "Bulan", 
                        values_to = "Share") %>%
    mutate(Bulan = factor(Bulan, levels = share_columns_sorted, labels = bulan_singkat))
  
  plot_ly(data_long, x = ~Bulan, y = ~Share, color = ~`Kode Komoditas`, 
          type = 'scatter', mode = 'lines+markers', line = list(shape = 'linear'),
          text = ~paste("Kode Komoditas:", `Kode Komoditas`, "<br>Share:", round(Share, 4), "<br>Bulan:", Bulan),
          hoverinfo = 'text') %>%
    layout(title = "Andil Inflasi Year-on-Year", 
           xaxis = list(title = "Bulan"), 
           yaxis = list(title = "Share (y-on-y)"))
})

# Tampilkan nama komoditas berdasarkan input kode komoditas
output$share_yoy_nama_komoditas <- renderText({
  search_term <- input$search_code_share_yoy
  nama_komoditas <- share_yoy %>%
    filter(`Kode Komoditas` == search_term) %>%
    pull(`Nama Komoditas`)
  
  if (length(nama_komoditas) > 0) {
    return(nama_komoditas[1])
  } else {
    return("Nama Komoditas tidak ditemukan")
  }
})

output$share_yoy_max_change_text <- renderUI({
  data_to_plot <- filtered_share_yoy()
  bulan_terpilih <- paste0("Share_", input$share_yoy_bulan)
  
  if (!is.null(data_to_plot) && nrow(data_to_plot) > 0) {
    valid_data <- data_to_plot %>%
      filter(!is.na(!!sym(bulan_terpilih)) & !!sym(bulan_terpilih) != 0)
    
    if (nrow(valid_data) > 0) {
      max_increase <- valid_data %>%
        slice_max(!!sym(bulan_terpilih), n = 1)
      
      max_decrease <- valid_data %>%
        slice_min(!!sym(bulan_terpilih), n = 1) 
      
      if (nrow(max_increase) > 0 && nrow(max_decrease) > 0) {
        HTML(paste0(
          "Andil Positif Terbesar: <b>", max_increase$`Nama Komoditas`, "</b> (", max_increase$`Kode Komoditas`, ") = ", max_increase[[bulan_terpilih]], "<br>",
          "Andil Negatif Terbesar: <b>", max_decrease$`Nama Komoditas`, "</b> (", max_decrease$`Kode Komoditas`, ") = ", max_decrease[[bulan_terpilih]]
        ))
      } else {
        "Tidak ada data untuk ditampilkan."
      }
    } else {
      "Tidak ada data yang valid untuk ditampilkan."
    }
  } else {
    "Tidak ada data untuk ditampilkan."
  }
})

# Output untuk top 10 andil positif
output$share_yoy_top_increase <- renderTable({
  data_filtered <- filtered_share_yoy()
  bulan_terpilih <- paste0("Share_", input$share_yoy_bulan)
  if (nrow(data_filtered) > 0) {
    top_increase <- data_filtered %>%
      arrange(desc(!!sym(bulan_terpilih))) %>%
      head(10) %>%
      select(`Kode Komoditas`, `Nama Komoditas`, !!sym(bulan_terpilih)) %>%
      mutate(!!sym(bulan_terpilih) := sprintf("%.4f", !!sym(bulan_terpilih)))
    colnames(top_increase) <- c("Kode Komoditas", "Nama Komoditas", "Share Value")
    return(top_increase)
  } else {
    return(NULL)
  }
})

# Output untuk top 10 andil negatif
output$share_yoy_top_decrease <- renderTable({
  data_filtered <- filtered_share_yoy()
  bulan_terpilih <- paste0("Share_", input$share_yoy_bulan)
  
  if (nrow(data_filtered) > 0) {
    top_decrease <- data_filtered %>%
      arrange(!!sym(bulan_terpilih)) %>%
      head(10) %>%
      select(`Kode Komoditas`, `Nama Komoditas`, !!sym(bulan_terpilih)) %>%
      mutate(!!sym(bulan_terpilih) := sprintf("%.4f", !!sym(bulan_terpilih)))
    
    colnames(top_decrease) <- c("Kode Komoditas", "Nama Komoditas", "Share Value")
    return(top_decrease)
  } else {
    return(NULL)
  }
})