# DARI DATA ADHB

# Update pilihan Flag dan Kode Komoditas berdasarkan data share_mtm
observe({
  updateSelectInput(session, "share_flag", choices = unique(adhb$flag))
})

output$tahun_range_share <- renderUI({
  
  kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)
  tahun_min <- min(as.integer(sub("_.*", "", kolom_tahun)))
  tahun_max <- max(as.integer(sub("_.*", "", kolom_tahun)))
  
  selectInput("tahun_share", "Pilih Tahun:", 
              choices = c(tahun_min:tahun_max), selected = tahun_min)
  
})

output$nama_lapangan_usaha_share <- renderText({
  search_term <- input$search_code_share
  
  if (is.null(search_term) || search_term == "") {
    return("Masukkan kode lapangan usaha")
  }
  
  nama <- adhb %>%
    filter(kode == search_term) %>%
    pull(nama)
  
  if (length(nama) > 0) {
    return(nama[1])
  } else {
    return("Nama Lapangan Usaha tidak ditemukan")
  }
})

output$kodeUI_share <- renderUI({
  kode_choices <- adhb %>%
    filter(flag == input$share_flag) %>%
    pull(kode)
  
  if (input$select_all_share) {
    selected_choices <- kode_choices
  } else {
    selected_choices <- kode_choices[1]
  }
  
  selectInput("kode_share", "Pilih Kode:",
              choices = kode_choices, selected = selected_choices, multiple = TRUE)
})

# Reactive filter for data based on flag and bulan
filtered_share <- reactive({
  # Tentukan tahun terpilih
  tahun_terpilih <- paste0("Share_", input$tahun_share, "_", gsub("Triwulan ", "", input$triwulan_share))
  

  # Filter data berdasarkan flag yang dipilih
  data_filtered <- share %>%
    select(flag, kode, nama, tahun_terpilih)
  # %>%
  #   filter(!is.na(!!sym(bulan_terpilih)))  # Hapus NA pada bulan

  # View(data_filtered)
  # Filter kode komoditas berdasarkan flag yang dipilih
  if (input$share_flag_def == "Flag 1 - 2 Digit") {
    data_filtered <- data_filtered %>%
      filter(nchar(as.character(kode)) %in% c(3, 4)) %>%
      mutate(`Kode 2 Digit` = if_else(
        nchar(as.character(kode)) == 4, 
        substr(as.character(kode), 1, 2), 
        substr(as.character(kode), 1, 1)
      ))  # Ambil 2 digit awal
  } else if (input$share_flag_def == "Flag 2 - 3 Digit") {
    data_filtered <- data_filtered %>%
      filter(nchar(as.character(kode)) == 5) %>%
      mutate(`Kode 3 Digit` = substr(as.character(kode), 1, 3))  # Ambil 3 digit awal

    # Filter untuk Kode Komoditas 2 Digit
    if (input$kode_2_digit != "Pilih Semua" && input$kode_2_digit != "") {
      data_filtered <- data_filtered %>%
        filter(substr(as.character(kode), 1, 2) == input$kode_2_digit)
    }
  } else if (input$share_flag_def == "Lapangan Usaha Utama") {
    data_filtered <- data_filtered %>%
      filter(nchar(as.character(kode)) %in% c(1,2))
  }

  # Additional filtering based on selected 2-digit Kode Komoditas
  if (input$share_flag_def == "Flag 2 - 3 Digit" && input$kode_2_digit != "") {
    # This condition ensures that all data is kept when "Pilih Semua" is selected
    if (input$kode_2_digit != "Pilih Semua") {
      data_filtered <- data_filtered %>%
        filter(substr(as.character(kode), 1, 2) == input$kode_2_digit)
    }
  }

  # Sort the filtered data
  # data_filtered <- data_filtered %>%
  #   arrange(desc(abs(!!sym(bulan_terpilih))))

  # View(data_filtered)
  return(data_filtered)
})
# 
# # Update dropdown Kode Komoditas berdasarkan Flag dan checkbox yang dipilih untuk Share MTM
# output$mtm_shareKodeKomoditasUI <- renderUI({
#   req(share_mtm)
#   komoditas_choices <- share_mtm %>%
#     filter(Flag == input$mtm_share_flag) %>%
#     pull(`Kode Komoditas`) %>%
#     unique()
#   
#   # Tentukan pilihan default untuk checkbox "Pilih Semua"
#   if (input$mtm_share_select_all) {
#     selected_choices <- komoditas_choices
#   } else {
#     selected_choices <- komoditas_choices[1]  # Pilih yang pertama jika tidak dicentang
#   }
#   
#   selectInput("mtm_share_kode_komoditas", "Pilih Kode Komoditas:", 
#               choices = komoditas_choices, selected = selected_choices, multiple = TRUE)
# })
# 
# 
# Update choices for Kode Komoditas 2 Digit based on selected flag
observe({
  if (input$share_flag_def == "Flag 2 - 3 Digit") {
    # Get unique 2-digit codes from the filtered data
    unique_2_digit_codes <- share %>%
      filter(nchar(as.character(kode)) > 3) %>%
      mutate(`Kode 2 Digit` = substr(as.character(kode), 1, 2)) %>%
      distinct(`Kode 2 Digit`) %>%
      pull(`Kode 2 Digit`)

    # Add "Pilih Semua" to the list of choices
    choices_with_all <- c("Pilih Semua", unique(unique_2_digit_codes))

    updateSelectInput(session, "kode_2_digit",
                      choices = choices_with_all,
                      selected = "Pilih Semua")  # Set default to "Pilih Semua"
  } else {
    updateSelectInput(session, "kode_2_digit",
                      choices = NULL)
  }
})

output$share_plot <- renderPlotly({
  data_to_plot <- filtered_share()  # Ambil data terfilter
  # View(data_to_plot)
  # bulan_terpilih <- grep("^\\d{4}_\\d$", colnames(adhb), value = TRUE) # Ambil nama kolom bulan yang dipilih
  # bulan_terpilih <- paste0("Share_", bulan_terpilih)
  bulan_terpilih <- paste0("Share_", input$tahun_share, "_", gsub("Triwulan ", "", input$triwulan_share))
  
  if (!is.null(data_to_plot) && nrow(data_to_plot) > 0 && bulan_terpilih %in% names(data_to_plot)) {

    if (input$share_flag_def == "Lapangan Usaha Utama") {
      p_gg <- ggplot(data_to_plot, aes(x = data_to_plot[[bulan_terpilih]], y = reorder(kode, data_to_plot[[bulan_terpilih]]), fill = kode, 
                                       text = paste(nama, "<br>",
                                                    "Share: ", data_to_plot[[bulan_terpilih]]))) +
        geom_bar(stat = "identity", width = 0.7, show.legend = FALSE) +
        labs(
          title = "Kontribusi Lapangan Usaha Utama terhadap Total PDRB ADHB",
          x = "Share (%)",
          y = "Lapangan Usaha"
        ) +
        theme_minimal()
      
      p_plotly <- ggplotly(p_gg, tooltip = "text")
      return(p_plotly)
    } else {
      # Pisahkan komoditas berdasarkan nilai positif dan negatif
      data_to_plot$positif <- ifelse(data_to_plot[[bulan_terpilih]] > 0, data_to_plot[[bulan_terpilih]], 0)
      data_to_plot$negatif <- ifelse(data_to_plot[[bulan_terpilih]] < 0, data_to_plot[[bulan_terpilih]], 0)  # Set nilai >= 0 jadi 0
      
      # Pilih kode komoditas yang akan digunakan berdasarkan input flag
      data_to_plot$kode2 <- if (input$share_flag_def == "Flag 1 - 2 Digit") {
        data_to_plot$`Kode 2 Digit`
      } else {
        data_to_plot$`Kode 3 Digit`
      }
      
      # Generate a distinct color palette from RColorBrewer
      unique_codes <- unique(data_to_plot$kode)
      num_colors <- length(unique_codes)
      
      # Use the Set1 or Paired palette for better color distinction
      colors <- brewer.pal(min(num_colors, 12), "Set1")  # Use up to 12 distinct colors
      if (num_colors > 12) {
        colors <- colorRampPalette(brewer.pal(12, "Set1"))(num_colors)  # Extend palette if needed
      }
      
      color_map <- setNames(colors, unique_codes)  # Map colors to corresponding Kode Komoditas

      # Create ggplot object with custom tooltip text
      p_gg <- ggplot(data_to_plot, aes(x = kode2)) +
        geom_bar(aes(y = positif, fill = kode,
                     text = paste("Kode Komoditas:", kode, "<br>Share:", positif)), stat = "identity") +
        geom_bar(aes(y = negatif, fill = kode,
                     text = paste("Kode Komoditas:", kode, "<br>Share:", negatif)), stat = "identity") +
        scale_fill_manual(values = color_map) +  # Apply color mapping
        labs(
          title = paste("Share", input$triwulan_share, "Tahun", input$tahun_share),
          x = "Kode Komoditas",
          y = paste("Share", input$triwulan_share, "Tahun", input$tahun_share)
        ) +
        theme_minimal()
      
      # Convert ggplot to plotly with custom tooltip
      p_plotly <- ggplotly(p_gg, tooltip = "text")  # Use custom text for tooltip
      
      return(p_plotly)
    }
    
  } else {
    plot_ly() %>%
      layout(title = "Tidak ada data untuk ditampilkan.")
  }
})

output$tahun_slider_share_ui <- renderUI({
  
  kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)
  tahun_min <- min(as.integer(sub("_.*", "", kolom_tahun)))
  tahun_max <- max(as.integer(sub("_.*", "", kolom_tahun)))
  
  sliderInput("tahun_slider_share", "Pilih Rentang Tahun:",
              min = tahun_min, max = tahun_max,
              value = c(tahun_min, tahun_max),
              step = 1, animate = TRUE)
})

# Plot Tahunan (Line Chart)
output$share_plot_tahunan <- renderPlotly({
  # Filter data by flag and selected commodity codes
  data_to_plot <- share %>%
    filter(
      flag == input$share_flag,
      kode %in% input$kode_share
    )
  
  # Extract the year range from the slider input
  year_min <- input$tahun_slider_share[1]
  year_max <- input$tahun_slider_share[2]
  
  # Get the column names that match the year range
  share_columns <- colnames(data_to_plot) %>%
    grep("^Share_\\d+_\\d+$", ., value = TRUE) %>%
    .[sapply(., function(col) {
      year <- as.numeric(gsub("Share_(\\d+)_\\d+", "\\1", col))
      year >= year_min & year <= year_max
    })]
  
  # Sort the columns by year and quarter
  share_columns_sorted <- share_columns[order(gsub("Share_(\\d+)_\\d+", "\\1", share_columns) %>%
                                                as.numeric())]
  
  # Create shortened labels for each quarter
  quarter_labels <- sapply(share_columns_sorted, function(col) {
    year <- gsub("Share_(\\d+)_\\d+", "\\1", col)
    quarter <- gsub("Share_\\d+_(\\d+)", "\\1", col)
    paste0("Q", quarter, "-", year)
  })
  
  # Transform data to long format for the plot
  data_long <- data_to_plot %>%
    select(kode, nama, all_of(share_columns_sorted)) %>%
    tidyr::pivot_longer(cols = share_columns_sorted,
                        names_to = "Quarter",
                        values_to = "Share") %>%
    mutate(Quarter = factor(Quarter, levels = share_columns_sorted, labels = quarter_labels))
  
  # View(data_long)
  # Generate the Plotly line chart
  plot_ly(data_long, 
          x = ~Quarter, 
          y = ~Share, 
          color = ~kode,
          type = 'scatter', 
          mode = 'lines+markers', 
          line = list(shape = 'linear'),
          text = ~paste("Nama:", nama, "<br>Share:", round(Share, 4), "<br>Quarter:", Quarter),
          hoverinfo = 'text') %>%
    layout(title = "Share PDRB Triwulanan",
           xaxis = list(title = "Triwulan"),
           yaxis = list(title = "Share (%)"))
})

# Tampilkan nama komoditas berdasarkan input kode komoditas
output$nama_komoditas_mtm <- renderText({
  search_term <- input$search_code_share_mtm
  nama_komoditas <- share_mtm %>%
    filter(`Kode Komoditas` == search_term) %>%
    pull(`Nama Komoditas`)

  if (length(nama_komoditas) > 0) {
    return(nama_komoditas[1])
  } else {
    return("Nama Komoditas tidak ditemukan")
  }
})
# 
# # Kenaikan/Penurunan Terbesar
# output$mtm_max_change_text <- renderUI({
#   data_to_plot <- filtered_share_mtm()  # Ambil data yang sudah difilter
#   bulan_terpilih <- paste0("Share_", input$mtm_bulan)
#   
#   if (!is.null(data_to_plot) && nrow(data_to_plot) > 0) {
#     # Filter data yang valid (tidak NA dan tidak 0)
#     valid_data <- data_to_plot %>%
#       filter(!is.na(!!sym(bulan_terpilih)) & !!sym(bulan_terpilih) != 0)
#     
#     if (nrow(valid_data) > 0) {
#       max_increase <- valid_data %>%
#         slice_max(!!sym(bulan_terpilih), n = 1)  # Ambil satu baris maksimum
#       
#       max_decrease <- valid_data %>%
#         slice_min(!!sym(bulan_terpilih), n = 1)  # Ambil satu baris minimum
#       
#       # Pastikan kita mengakses elemen dengan benar
#       if (nrow(max_increase) > 0 && nrow(max_decrease) > 0) {
#         HTML(paste0(
#           "Andil Positif Terbesar: <b>", max_increase$`Nama Komoditas`, "</b> (", max_increase$`Kode Komoditas`, ") = ", max_increase[[bulan_terpilih]], "<br>",
#           "Andil Negatif Terbesar: <b>", max_decrease$`Nama Komoditas`, "</b> (", max_decrease$`Kode Komoditas`, ") = ", max_decrease[[bulan_terpilih]]
#         ))
#       } else {
#         "Tidak ada data untuk ditampilkan."
#       }
#     } else {
#       "Tidak ada data yang valid untuk ditampilkan."
#     }
#   } else {
#     "Tidak ada data untuk ditampilkan."
#   }
# })
# 
# 
# # Top 10 Kenaikan Terbesar
output$top_increase <- renderDT({
  data_to_plot <- filtered_share()  # Ambil data yang sudah difilter
  bulan_terpilih <- paste0("Share_", input$tahun_share, "_", gsub("Triwulan ", "", input$triwulan_share))
  
  
  if (!is.null(data_to_plot) && nrow(data_to_plot) > 0) {
    data_to_show <- data_to_plot %>%
      arrange(desc(!!sym(bulan_terpilih))) %>%
      head(10) %>%
      select(nama, kode, !!sym(bulan_terpilih)) %>%
      mutate(!!sym(bulan_terpilih) := sprintf("%.4f", !!sym(bulan_terpilih)))
    
    datatable(data_to_show, 
              options = list(
                pageLength = 10,         
                lengthMenu = c(10, 20, 50), 
                scrollX = TRUE,     
                autoWidth = FALSE,
                columnDefs = list(list(width = '100%', targets = "_all"))
              ),
              rownames = FALSE) 
  } else {
    # data.frame(kode = character(), nama = character(), Share = numeric())  # Mengembalikan data frame kosong
    paste("Tidak ada data")
  }
})
# 
# # Top 10 Penurunan Terbesar
# output$mtm_top_decrease <- renderTable({
#   data_to_plot <- filtered_share_mtm()  # Ambil data yang sudah difilter
#   bulan_terpilih <- paste0("Share_", input$mtm_bulan)
#   
#   if (!is.null(data_to_plot) && nrow(data_to_plot) > 0) {
#     data_to_plot %>%
#       arrange(!!sym(bulan_terpilih)) %>%
#       head(10) %>%
#       select(`Kode Komoditas`, `Nama Komoditas`, !!sym(bulan_terpilih)) %>%
#       mutate(!!sym(bulan_terpilih) := sprintf("%.4f", !!sym(bulan_terpilih)))
#   } else {
#     data.frame(`Kode Komoditas` = character(), `Nama Komoditas` = character(), Share = numeric())  # Mengembalikan data frame kosong
#   }
# })