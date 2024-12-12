# CHART 1 - Line Simple Chart
observe({
  updateSelectInput(session, "flag_yoy", choices = unique(adhb$flag))
})

output$kodeUI_yoy <- renderUI({
  kode_choices <- adhb %>%
    filter(flag == input$flag_yoy) %>%
    pull(kode)
  
  if (input$select_all_yoy) {
    selected_choices <- kode_choices
  } else {
    selected_choices <- kode_choices[1]
  }
  
  selectInput("kode_yoy", "Pilih Kode:",
              choices = kode_choices, selected = selected_choices, multiple = TRUE)
})

output$nama_lapangan_usaha_yoy <- renderText({
  search_term <- input$search_code_yoy
  
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

output$tahun_range_yoy <- renderUI({
  
  kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)
  tahun_min <- min(as.integer(sub("_.*", "", kolom_tahun)))
  tahun_max <- max(as.integer(sub("_.*", "", kolom_tahun)))
  
  sliderInput("tahun_yoy", "Pilih Rentang Tahun:",
              min = tahun_min, max = tahun_max,
              value = c(tahun_min, tahun_max),
              step = 1, animate = TRUE)
})

output$yoy_plot <- renderPlotly({
  req(input$tahun_yoy)
  
  kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)

  tahun_range <- as.integer(input$tahun_yoy)
  kolom_terpilih <- kolom_tahun[as.integer(sub("_.*", "", kolom_tahun)) >= tahun_range[1] &
                                  as.integer(sub("_.*", "", kolom_tahun)) <= tahun_range[2]]
  
  long_data <- yoy_data %>%
    filter(
      flag == input$flag_yoy,
      kode %in% input$kode_yoy
    ) %>%
    filter(periode %in% all_of(kolom_terpilih))
  
  plotly::plot_ly(long_data, x = ~periode, y = ~yoy, color = ~factor(kode), type = 'scatter', mode = 'lines+markers',
                  text = ~paste("Periode:", periode, "<br>yoy:", yoy),
                  # line = list(color = 'blue'),
                  marker = list(size = 8)) %>%
    layout(
      title = "Pertumbuhan Ekonomi YoY",
      xaxis = list(title = "Periode"),
      yaxis = list(title = "yoy (%)"),
      hovermode = "closest"
    )
})

# Tabel
output$yoy_table <- renderDT({
  
  kolom_tahun <- grep("^\\d{4}_", names(adhb), value = TRUE)
  
  tahun_range <- as.integer(input$tahun_yoy)
  kolom_terpilih <- kolom_tahun[as.integer(sub("_.*", "", kolom_tahun)) >= tahun_range[1] &
                                  as.integer(sub("_.*", "", kolom_tahun)) <= tahun_range[2]]
  
  data_to_show <- yoy_data %>%
    filter(
      flag == input$flag_yoy,
      kode %in% input$kode_yoy
    ) %>%
    filter(periode %in% all_of(kolom_terpilih))
  
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