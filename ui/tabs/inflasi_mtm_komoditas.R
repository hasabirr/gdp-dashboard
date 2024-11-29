tabItem(
  tabName = "inflasi_mtm_per_komoditas",
  fluidRow(
    box(
      title = "Filter", 
      status = "primary", 
      solidHeader = TRUE, 
      width = 4,
      selectInput("delta_flag_per_komoditas", "Pilih Flag:", choices = NULL),
      # selectInput("delta_flag_per_komoditas", "Pilih Flag:", choices = unique(ihk_mtm$Flag)),
      selectInput("kode_komoditas_flag", "Pilih Kode Komoditas:", choices = NULL),
      div(
        tags$p("Kenaikan/Penurunan Terbesar", style = "font-weight: bold; font-size: 16px; margin-bottom: 5px;"),
        htmlOutput("max_change_text2"), 
        style = "border: 2px solid #000; padding: 10px; margin: 10px; border-radius: 5px; background-color: #f9f9f9;"
      )
    ),
    box(
      title = "Grafik Inflasi (m-to-m) per Komoditas", 
      status = "primary", 
      solidHeader = TRUE, 
      width = 8,
      plotlyOutput("delta_komoditas_plot")
    )
  )
)