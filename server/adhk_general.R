# CHART 1 - General

# Update flag di dropdown
observe({
  updateSelectInput(session, "flag_adhk", choices = unique(adhk$flag))
})

output$kodeUI_adhk <- renderUI({
  kode_choices <- adhk %>%
    filter(flag == input$flag_adhk) %>%
    pull(kode)
  
  if (input$select_all_adhk) {
    selected_choices <- kode_choices
  } else {
    selected_choices <- kode_choices[1]
  }
  
  selectInput("kode_adhk", "Pilih Kode:",
              choices = kode_choices, selected = selected_choices, multiple = TRUE)
})

output$nama_lapangan_usaha_adhk <- renderText({
  search_term <- input$search_code_adhk
  
  if (is.null(search_term) || search_term == "") {
    return("Masukkan kode lapangan usaha")
  }
  
  nama <- adhk %>%
    filter(kode == search_term) %>%
    pull(nama)
  
  if (length(nama) > 0) {
    return(nama[1])
  } else {
    return("Nama Lapangan Usaha tidak ditemukan")
  }
})

output$adhk_plot <- renderPlotly({
  
  triwulan_col <- paste(input$tahun_adhk, 
                        switch(input$triwulan_adhk,
                               "Triwulan 1" = "_1",
                               "Triwulan 2" = "_2",
                               "Triwulan 3" = "_3",
                               "Triwulan 4" = "_4"), sep = "")
  
  filtered_data <- adhk %>%
    mutate(custom_hover = paste("[", kode, "] ", nama)) %>%
    filter(
      flag == input$flag_adhk,
      kode %in% input$kode_adhk
    ) %>%
    select(kode, nama, !!sym(triwulan_col), custom_hover) %>%
    rename(PDRB_Value = !!sym(triwulan_col))
  
  plotly::plot_ly(
    data = filtered_data,
    x = ~kode,
    y = ~PDRB_Value, 
    type = "bar",
    marker = list(color = "orange"),
    hovertemplate = paste(
      "<b>%{customdata}</b><br>",
      "<b>Nilai: </b> %{y}<extra></extra>"
    ),
    customdata = ~custom_hover
  ) %>%
    layout(
      title = paste("PDRB ADHK Tahun", input$tahun_adhk, input$triwulan_adhk),
      xaxis = list(title = "Kode"),
      yaxis = list(title = "Nilai PDRB"),
      bargap = 0.2
    )
})

# CHART 2 - Line Chart

observe({
  updateSelectInput(session, "flag_line_adhk", choices = unique(adhk$flag))
})

output$kodeUI_line_adhk <- renderUI({
  req(input$flag_line_adhk)
  
  kode_choices <- adhb %>%
    filter(flag == input$flag_line_adhk) %>%
    pull(kode)
  
  if (input$select_all_line_adhk) {
    selected_choices <- kode_choices
  } else {
    selected_choices <- kode_choices[1]
  }
  
  selectInput("kode_line_adhk", "Pilih Kode:",
              choices = kode_choices, selected = selected_choices, multiple = TRUE)
})

output$tahun_range_ui_adhk <- renderUI({
  kolom_tahun <- grep("^\\d{4}_", names(adhk), value = TRUE)
  
  tahun_min <- min(as.integer(sub("_.*", "", kolom_tahun))) 
  tahun_max <- max(as.integer(sub("_.*", "", kolom_tahun)))
  
  sliderInput("tahun_range_adhk", "Pilih Rentang Tahun:",
              min = tahun_min, max = tahun_max,
              value = c(tahun_min, tahun_max),
              step = 1, animate = TRUE)
})

output$periode_filter_ui_adhk <- renderUI({
  radioButtons("periode_adhk", "Pilih Periode:",
               choices = c("Triwulanan" = "Triwulanan", "Tahunan" = "Tahunan"),
               selected = "Triwulanan")
})

output$line_adhk <- renderPlotly({
  req(input$flag_line_adhk)
  req(input$kode_line_adhk)
  req(input$periode_adhk)
  req(input$tahun_range_adhk)
  
  kolom_tahun <- grep("^\\d{4}_", names(adhk), value = TRUE)
  tahun_range <- as.integer(input$tahun_range_adhk)
  kolom_terpilih <- kolom_tahun[as.integer(sub("_.*", "", kolom_tahun)) >= tahun_range[1] & 
                                  as.integer(sub("_.*", "", kolom_tahun)) <= tahun_range[2]]
  filtered_data <- adhk %>%
    filter(flag == input$flag_line_adhk, 
           kode %in% input$kode_line_adhk) %>%
    select(kode, nama, all_of(kolom_terpilih)) 
  
  nama_data <- filtered_data %>% select(kode, nama)
  
  if(input$periode_adhk == "Triwulanan") {
    nama_data <- filtered_data %>% select(kode, nama)
    triwulan_data <- filtered_data %>%
      select(-kode, -nama) %>%
      tidyr::pivot_longer(
        cols = everything(), 
        names_to = "periode", 
        values_to = "nilai"
      ) %>%
      mutate(periode = gsub("_", ".", periode))
    
    n_kode <- nrow(filtered_data)
    n_baris_per_kode <- nrow(triwulan_data) / n_kode
    
    triwulan_data$kode <- rep(filtered_data$kode, each = n_baris_per_kode)
    
    long_data <- triwulan_data %>%
      left_join(nama_data, by = "kode")
    
  } else if (input$periode_adhk == "Tahunan") {
    triwulan_data <- filtered_data %>%
      tidyr::pivot_longer(cols = matches("^\\d{4}(_.*)?$"), 
                          names_to = "periode",
                          values_to = "nilai") %>%
      mutate(periode = as.integer(gsub("_.*", "", periode)))
    long_data <- triwulan_data %>%
      group_by(periode, kode) %>%
      summarise(nilai = sum(nilai, na.rm = TRUE), .groups = "drop") %>%
      left_join(nama_data, by = "kode")
  } else {
    long_data <- NULL
  }
  
  # Cek
  if(!"periode" %in% names(long_data)) {
    stop("Kolom 'periode' tidak ditemukan dalam long_data.")
  }
  
  plotly::plot_ly(
    data = long_data,
    x = ~periode,
    y = ~nilai,
    color = ~factor(kode),
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
      title = paste("Total PDRB ADHK - Periode:", input$periode),
      xaxis = list(title = ifelse(input$periode == "Triwulanan", "Periode (Triwulanan)", "Tahun")),
      yaxis = list(title = "Nilai PDRB")
    )
})

# CHART 3 - Line Simple Chart
output$tahun_range_ui_simple_adhk <- renderUI({
  
  kolom_tahun <- grep("^\\d{4}_", names(adhk), value = TRUE)
  tahun_min <- min(as.integer(sub("_.*", "", kolom_tahun)))
  tahun_max <- max(as.integer(sub("_.*", "", kolom_tahun)))
  
  sliderInput("tahun_range_simple_adhk", "Pilih Rentang Tahun:",
              min = tahun_min, max = tahun_max,
              value = c(tahun_min, tahun_max),
              step = 1, animate = TRUE)
})

output$periode_filter_ui_simple_adhk <- renderUI({
  radioButtons("periode_simple_adhk", "Pilih Periode:",
               choices = c("Triwulanan" = "Triwulanan", "Tahunan" = "Tahunan"),
               selected = "Triwulanan")
})

output$line_adhk_simple <- renderPlotly({
  req(input$periode_simple_adhk)
  req(input$tahun_range_simple_adhk)
  
  kolom_tahun <- grep("^\\d{4}_", names(adhk), value = TRUE)
  
  tahun_range <- as.integer(input$tahun_range_simple_adhk)
  kolom_terpilih <- kolom_tahun[as.integer(sub("_.*", "", kolom_tahun)) >= tahun_range[1] & 
                                  as.integer(sub("_.*", "", kolom_tahun)) <= tahun_range[2]]
  
  data_filtered <- adhk %>%
    filter(flag == 1) %>% 
    select(c(kode, nama, all_of(kolom_terpilih)))
  
  if (input$periode_simple_adhk == "Triwulanan") {
    long_data <- data_filtered %>%
      tidyr::pivot_longer(
        cols = -c(kode, nama),
        names_to = "periode",
        values_to = "nilai"
      ) %>%
      mutate(periode = gsub("_", ".", periode)) %>%
      group_by(periode) %>%
      summarise(nilai = sum(nilai, na.rm = TRUE), .groups = "drop")
    
  } else if (input$periode_simple_adhk == "Tahunan") {
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
  
  plotly::plot_ly(
    data = long_data,
    x = ~periode,
    y = ~nilai,
    type = 'scatter',
    mode = 'lines+markers',
    hovertemplate = paste(
      "<b>Periode:</b> %{x}<br>",
      "<b>Nilai:</b> %{y}<extra></extra>"
    )
  ) %>%
    layout(
      title = paste("Total PDRB ADHK - Periode:", input$periode_simple),
      xaxis = list(title = ifelse(input$periode_simple == "Triwulanan", "Periode (Triwulanan)", "Tahun")),
      yaxis = list(title = "Nilai PDRB")
    )
})

# Tabel
output$adhk_table <- renderDT({
  data_to_show <- adhk
  datatable(data_to_show, 
            options = list(
              pageLength = 10,         
              lengthMenu = c(10, 20, 50), 
              scrollX = TRUE,     
              autoWidth = TRUE,    
              columnDefs = list(list(width = '200px', targets = 2),
                                list(width = '100%', targets = "_all"))
            ),
            rownames = FALSE) 
})