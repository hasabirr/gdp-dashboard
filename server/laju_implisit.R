# OLAH DATA

# Implisit Parsial
implisit <- adhb %>%
  tidyr::pivot_longer(cols = matches("^\\d{4}_\\d$"), names_to = "periode", values_to = "adhb") %>%
  left_join(
    adhk %>%
      tidyr::pivot_longer(cols = matches("^\\d{4}_\\d$"), names_to = "periode", values_to = "adhk"),
    by = c("flag", "kode", "nama", "periode")
  ) %>%
  mutate(implisit = (adhb / adhk) * 100)

implisit <- implisit %>%
  arrange(flag, kode, periode) %>%
  group_by(flag, kode) %>%
  mutate(laju_implisit = (implisit / lag(implisit))*100 - 100) %>%
  ungroup()

implisit_2 <- implisit %>%
  select(flag, kode, nama, periode, adhb, adhk) %>%
  mutate(tahun = substr(periode, 1, 4)) %>%
  group_by(tahun, flag, kode, nama) %>%
  summarise(
    total_adhb = sum(adhb, na.rm = TRUE),
    total_adhk = sum(adhk, na.rm = TRUE)
  ) %>%
  mutate(implisit = (total_adhb / total_adhk) * 100) %>%
  arrange(flag, kode, nama, tahun) %>%
  group_by(flag, kode, nama) %>%
  mutate(laju_implisit = (implisit / lag(implisit))*100 - 100) %>%  # Menghitung laju_implisit menggunakan lag()
  ungroup() %>%
  tidyr::fill(laju_implisit, .direction = "down") %>%  # Mengisi NA dengan nilai sebelumnya dalam grup
  rename(periode = tahun)

# Implisit Total Triwulanan
implisit_triwulanan <- adhb_triwulanan_total %>%
  left_join(adhk_triwulanan_total, by = "periode") %>%
  mutate(implisit = (nilai_adhb / nilai_adhk) * 100) %>%
  mutate(laju_implisit = (implisit / lag(implisit))*100 - 100)

implisit_tahunan <- adhb_tahunan_total %>%
  left_join(adhk_tahunan_total, by = "periode") %>%
  mutate(implisit = (nilai_adhb / nilai_adhk) * 100) %>%
  mutate(laju_implisit = (implisit / lag(implisit))*100 - 100)

# CHART 1 ======================================================================
observe({
  updateSelectInput(session, "flag_laju", choices = unique(adhb$flag))
})

output$kodeUI_laju <- renderUI({
  kode_choices <- adhb %>%
    filter(flag == input$flag_laju) %>%
    pull(kode)
  
  if (input$select_all_laju) {
    selected_choices <- kode_choices
  } else {
    selected_choices <- kode_choices[1]
  }
  
  selectInput("kode_laju", "Pilih Kode:",
              choices = kode_choices, selected = selected_choices, multiple = TRUE)
})

output$nama_lapangan_usaha_laju <- renderText({
  search_term <- input$search_code_laju
  
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

output$tahun_laju <- renderUI({
  kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)
  
  tahun_min <- min(as.integer(sub("_.*", "", kolom_tahun))) 
  tahun_max <- max(as.integer(sub("_.*", "", kolom_tahun)))
  
  sliderInput("tahun_laju", "Pilih Rentang Tahun:",
              min = tahun_min, max = tahun_max,
              value = c(tahun_min, tahun_max),
              step = 1, animate = TRUE)
})

output$periode_laju <- renderUI({
  radioButtons("periode_laju", "Pilih Periode:",
               choices = c("Triwulanan" = "Triwulanan", "Tahunan" = "Tahunan"),
               selected = "Triwulanan")
})

output$line_laju <- renderPlotly({
  req(input$flag_laju)
  req(input$periode_laju)
  
  # Filter data berdasarkan flag dan kode
  filtered_data <- implisit %>%
    filter(flag == input$flag_laju, 
           kode %in% input$kode_laju)
  
  # Ambil rentang tahun dari slider
  tahun_range <- as.integer(input$tahun_laju)
  
  # Filter data berdasarkan periode
  if (input$periode_laju == "Triwulanan") {
    filtered_data <- filtered_data %>%
      filter(as.integer(substr(periode, 1, 4)) >= input$tahun_laju[1] &
               as.integer(substr(periode, 1, 4)) <= input$tahun_laju[2])
    
    long_data <- filtered_data %>%
      select(kode, nama, periode, laju_implisit) %>%
      mutate(periode = gsub("_", ".", periode))
    
  } else if (input$periode_laju == "Tahunan") {
    filtered_data <- implisit_2 %>%
      filter(flag == input$flag_laju, 
             kode %in% input$kode_laju)
    
    long_data <- filtered_data %>%
      filter(as.integer(periode) >= input$tahun_laju[1] &
               as.integer(periode) <= input$tahun_laju[2])
  } else {
    stop("Nilai input$periode_laju tidak valid.")
  }
  
  validate(
    need(nrow(long_data) > 0, "Tidak ada data untuk filter yang dipilih.")
  )
  
  plotly::plot_ly(
    data = long_data,
    x = ~periode,
    y = ~laju_implisit,
    color = ~factor(kode),
    type = 'scatter',
    mode = 'lines+markers',
    customdata = ~paste("[", kode, "] ", nama),
    hovertemplate = paste(
      "<b>%{customdata}</b><br>",
      "<b>Periode:</b> %{x}<br>",
      "<b>Laju Implisit:</b> %{y}<extra></extra>"
    )
  ) %>%
    layout(
      title = paste("Laju Indeks Implisit - Periode", input$periode_laju),
      xaxis = list(title = ifelse(input$periode_laju == "Triwulanan", "Periode (Triwulanan)", "Tahun")),
      yaxis = list(title = "Laju Indeks Implisit")
    )
})

# CHART 2 - Line Simple Chart ==================================================
output$tahun_laju_simple <- renderUI({

  kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)
  tahun_min <- min(as.integer(sub("_.*", "", kolom_tahun)))
  tahun_max <- max(as.integer(sub("_.*", "", kolom_tahun)))

  sliderInput("tahun_laju_simple", "Pilih Rentang Tahun:",
              min = tahun_min, max = tahun_max,
              value = c(tahun_min, tahun_max),
              step = 1, animate = TRUE)
})

output$periode_laju_simple <- renderUI({
  radioButtons("periode_laju_simple", "Pilih Periode:",
               choices = c("Triwulanan" = "Triwulanan", "Tahunan" = "Tahunan"),
               selected = "Triwulanan")
})

output$line_laju_simple <- renderPlotly({

  req(input$periode_laju_simple)
  
  kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)

  tahun_range <- as.integer(input$tahun_laju_simple)
  kolom_terpilih <- kolom_tahun[as.integer(sub("_.*", "", kolom_tahun)) >= tahun_range[1] &
                                  as.integer(sub("_.*", "", kolom_tahun)) <= tahun_range[2]]
  
  if (input$periode_laju_simple == "Triwulanan") {
    long_data <- implisit_triwulanan %>%
      filter(as.integer(sub("\\..*", "", periode)) >= input$tahun_laju_simple[1] &
               as.integer(sub("\\..*", "", periode)) <= input$tahun_laju_simple[2])
    
  } else if (input$periode_laju_simple == "Tahunan") {
    
    long_data <- implisit_tahunan %>%
      filter(as.integer(periode) >= input$tahun_laju_simple[1] &
               as.integer(periode) <= input$tahun_laju_simple[2])
  } else {
    stop("Nilai input$periode_laju tidak valid.")
  }

  plotly::plot_ly(
    data = long_data,
    x = ~periode,
    y = ~laju_implisit,
    type = 'scatter',
    mode = 'lines+markers',
    hovertemplate = paste(
      "<b>Periode:</b> %{x}<br>",
      "<b>Nilai:</b> %{y}<extra></extra>"
    )
  ) %>%
    layout(
      title = paste("Total Laju Indeks Implisit - Periode", input$periode_laju_simple),
      xaxis = list(title = ifelse(input$periode_laju_simple == "Triwulanan", "Periode (Triwulanan)", "Tahun")),
      yaxis = list(title = "Nilai PDRB")
    )
})

# Reactive value to store the selected dataset
selected_data <- reactiveVal()

# kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)
# 
# tahun_range <- as.integer(input$tahun_laju)
# kolom_terpilih <- kolom_tahun[as.integer(sub("_.*", "", kolom_tahun)) >= tahun_range[1] &
#                                 as.integer(sub("_.*", "", kolom_tahun)) <= tahun_range[2]]
# 
# data_implisit_def <- implisit %>%
#   filter(flag == input$flag_laju,
#          kode %in% input$kode_laju) %>%
#   filter(periode %in% all_of(kolom_terpilih))

selected_data(NULL)

# Observe button clicks to update the dataset
observeEvent(input$data_grafik1_triwulanan, {
  kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)
  
  tahun_range <- as.integer(input$tahun_laju)
  kolom_terpilih <- kolom_tahun[as.integer(sub("_.*", "", kolom_tahun)) >= tahun_range[1] &
                                  as.integer(sub("_.*", "", kolom_tahun)) <= tahun_range[2]]
  
  data_table_1 <- implisit %>%
    filter(flag == input$flag_laju,
           kode %in% input$kode_laju) %>%
    filter(periode %in% all_of(kolom_terpilih))
  
  selected_data(data_table_1)
})

observeEvent(input$data_grafik1_tahunan, {
  
  data_table_2 <- implisit_2 %>%
    filter(flag == input$flag_laju,
           kode %in% input$kode_laju)
  
  selected_data(data_table_2)
})

observeEvent(input$data_grafik2_triwulanan, {
  selected_data(implisit_triwulanan)
})

observeEvent(input$data_grafik2_tahunan, {
  selected_data(implisit_tahunan)
})

# Render the table dynamically
output$laju_table <- renderDT({
  datatable(
    selected_data(),
    options = list(
      pageLength = 10,         # Default rows per page
      lengthMenu = c(10, 20, 50), # Options for rows per page
      scrollX = TRUE,          # Enable horizontal scrolling
      autoWidth = TRUE,        # Automatically adjust column widths
      columnDefs = list(
        list(width = '200px', targets = 2), # Set specific width for column 2
        list(width = '100%', targets = "_all") # Set remaining columns to auto-width
      )
    ),
    rownames = FALSE # Do not show row names
  ) 
})

# Dynamic title for the box
output$dynamic_box_title <- renderText({
  if (input$data_grafik1_triwulanan > 0) {
    "Tabel Data Grafik 1 Triwulanan"
  } else if (input$data_grafik1_tahunan > 0) {
    "Tabel Data Grafik 1 Tahunan"
  } else if (input$data_grafik2_triwulanan > 0) {
    "Tabel Data Grafik 2 Triwulanan"
  } else if (input$data_grafik2_tahunan > 0) {
    "Tabel Data Grafik 2 Tahunan"
  } else {
    "Pilih Data Grafik"
  }
})
