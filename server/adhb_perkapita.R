# CHART 1 - General

# Update flag di dropdown
observe({
  updateSelectInput(session, "flag_adhb_perkapita", choices = unique(adhb$flag))
})

output$tahun_adhb_perkapita_ui <- renderUI({
  selectInput("tahun_adhb_perkapita", "Pilih Tahun:", choices = tahun_tersedia, selected = "2023")
})

output$kodeUI_adhb_perkapita <- renderUI({
  kode_choices <- adhb %>%
    filter(flag == input$flag_adhb_perkapita) %>%
    pull(kode)
  
  if (input$select_all_adhb_perkapita) {
    selected_choices <- kode_choices
  } else {
    selected_choices <- kode_choices[1]
  }
  
  selectInput("kode_adhb_perkapita", "Pilih Kode:",
              choices = kode_choices, selected = selected_choices, multiple = TRUE)
})

output$nama_lapangan_usaha_adhb_perkapita <- renderText({
  search_term <- input$search_code_adhb_perkapita
  
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

output$adhb_perkapita_plot <- renderPlotly({
  
  triwulan_col <- paste(input$tahun_adhb_perkapita, 
                        switch(input$triwulan_adhb_perkapita,
                               "Triwulan 1" = "_1",
                               "Triwulan 2" = "_2",
                               "Triwulan 3" = "_3",
                               "Triwulan 4" = "_4"), sep = "")
  
  filtered_data <- adhb_perkapita %>%
    mutate(custom_hover = paste("[", kode, "] ", nama)) %>%
    filter(
      flag == input$flag_adhb_perkapita,
      kode %in% input$kode_adhb_perkapita
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
      title = paste("PDRB ADHB Perkapita Tahun", input$tahun_adhb_perkapita, input$triwulan_adhb_perkapita),
      xaxis = list(title = "Kode"),
      yaxis = list(title = "Nilai PDRB"),
      bargap = 0.2
    )
})

# CHART 2 - Line Chart
observe({
  updateSelectInput(session, "flag_adhb_perkapita_line", choices = unique(adhb$flag))
})

output$kodeUI_adhb_perkapita_line <- renderUI({
  req(input$flag_adhb_perkapita_line)
  
  kode_choices <- adhb %>%
    filter(flag == input$flag_adhb_perkapita_line) %>%
    pull(kode)
  
  if (input$select_all_adhb_perkapita_line) {
    selected_choices <- kode_choices
  } else {
    selected_choices <- kode_choices[1]
  }
  
  selectInput("kode_adhb_perkapita_line", "Pilih Kode:",
              choices = kode_choices, selected = selected_choices, multiple = TRUE)
})

output$tahun_adhb_perkapita_line <- renderUI({
  kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)
  
  tahun_min <- min(as.integer(sub("_.*", "", kolom_tahun))) 
  tahun_max <- max(as.integer(sub("_.*", "", kolom_tahun)))
  
  sliderInput("tahun_adhb_p_line", "Pilih Rentang Tahun:",
              min = tahun_min, max = tahun_max,
              value = c(tahun_min, tahun_max),
              step = 1, animate = TRUE)
})

output$periode_adhb_perkapita_line <- renderUI({
  radioButtons("periode_adhb_p_line", "Pilih Periode:",
               choices = c("Triwulanan" = "Triwulanan", "Tahunan" = "Tahunan"),
               selected = "Triwulanan")
})

output$line_adhb_perkapita <- renderPlotly({
  req(input$periode_adhb_p_line)
  req(input$tahun_adhb_p_line)
  # req(input$flag_adhb_perkapita_line)
  # req(input$kode_adhb_perkapita_line)
  # req(input$periode_adhb_perkapita_line)
  # req(input$tahun_adhb_perkapita_line)

  kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)
  tahun_range <- as.integer(input$tahun_adhb_p_line)
  kolom_terpilih <- kolom_tahun[as.integer(sub("_.*", "", kolom_tahun)) >= tahun_range[1] &
                                  as.integer(sub("_.*", "", kolom_tahun)) <= tahun_range[2]]

  filtered_data <- adhb_perkapita %>%
    filter(flag == input$flag_adhb_perkapita_line,
           kode %in% input$kode_adhb_perkapita_line) %>%
    select(kode, nama, all_of(kolom_terpilih))

  nama_data <- filtered_data %>% select(kode, nama)

  if(input$periode_adhb_p_line == "Triwulanan") {
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

  } else if (input$periode_adhb_p_line == "Tahunan") {
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
  print("sampe siniii")
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
      title = paste("Total PDRB ADHB Perkapita - Periode:", input$periode_adhb_p_line),
      xaxis = list(title = ifelse(input$periode_adhb_p_line == "Triwulanan", "Periode (Triwulanan)", "Tahun")),
      yaxis = list(title = "Nilai PDRB")
    )
})

# CHART 3 - Line Simple Chart
output$tahun_adhb_perkapita_line_simple <- renderUI({
  
  kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)
  tahun_min <- min(as.integer(sub("_.*", "", kolom_tahun)))
  tahun_max <- max(as.integer(sub("_.*", "", kolom_tahun)))
  
  sliderInput("tahun_adhb_p_line_simple", "Pilih Rentang Tahun:",
              min = tahun_min, max = tahun_max,
              value = c(tahun_min, tahun_max),
              step = 1, animate = TRUE)
})

output$periode_adhb_perkapita_line_simple <- renderUI({
  radioButtons("periode_adhb_p_line_simple", "Pilih Periode:",
               choices = c("Triwulanan" = "Triwulanan", "Tahunan" = "Tahunan"),
               selected = "Triwulanan")
})

output$line_adhb_perkapita_simple <- renderPlotly({
  req(input$periode_adhb_p_line_simple)
  req(input$tahun_adhb_p_line_simple)

  kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)

  tahun_range <- as.integer(input$tahun_adhb_p_line_simple)
  kolom_terpilih <- kolom_tahun[as.integer(sub("_.*", "", kolom_tahun)) >= tahun_range[1] &
                                  as.integer(sub("_.*", "", kolom_tahun)) <= tahun_range[2]]

  data_filtered <- adhb_perkapita %>%
    filter(flag == 1) %>%
    select(c(kode, nama, all_of(kolom_terpilih)))

  if (input$periode_adhb_p_line_simple == "Triwulanan") {
    long_data <- data_filtered %>%
      tidyr::pivot_longer(
        cols = -c(kode, nama),
        names_to = "periode",
        values_to = "nilai"
      ) %>%
      mutate(periode = gsub("_", ".", periode)) %>%
      group_by(periode) %>%
      summarise(nilai = sum(nilai, na.rm = TRUE), .groups = "drop")

  } else if (input$periode_adhb_p_line_simple == "Tahunan") {
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
      title = paste("Total PDRB ADHB Perkapita - Periode:", input$periode_adhb_p_line_simple),
      xaxis = list(title = ifelse(input$periode_adhb_p_line_simple == "Triwulanan", "Periode (Triwulanan)", "Tahun")),
      yaxis = list(title = "Nilai PDRB")
    )
})

# Tabel
output$adhb_perkapita_table <- renderDT({
  kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)

  tahun_range <- as.integer(input$tahun_adhb_p_line_simple)
  kolom_terpilih <- kolom_tahun[as.integer(sub("_.*", "", kolom_tahun)) >= tahun_range[1] &
                                  as.integer(sub("_.*", "", kolom_tahun)) <= tahun_range[2]]
  # 
  data_to_show <- adhb_perkapita %>%
    filter(flag == 1) %>%
    select(c(kode, nama, all_of(kolom_terpilih))) %>%
    tidyr::pivot_longer(
      cols = -c(kode, nama),
      names_to = "periode",
      values_to = "nilai"
    ) %>%
  #   #   mutate(periode = gsub("_", ".", periode)) %>%
    group_by(periode) %>%
    summarise(nilai = sum(nilai, na.rm = TRUE), .groups = "drop")
  
  datatable(data_to_show, 
            options = list(
              pageLength = 10,         
              lengthMenu = c(10, 20, 50), 
              scrollX = TRUE,     
              autoWidth = FALSE,    
              columnDefs = list(list(width = '100%', targets = "_all"))
            ),
            rownames = FALSE) 
})