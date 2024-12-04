dashboardBody(
  tags$head(
    tags$link(rel = "icon", type = "image/png", href = "https://www.bps.go.id/_next/image?url=%2Fassets%2Flogo-bps.png&w=1080&q=75")
  ),
  tags$script(HTML("$('body').addClass('fixed');")),
  tabItems(
    tabItem(tabName = "pdrb",
            fluidRow(
              box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                  selectInput("flag_pdrb", "Pilih Flag:", choices = NULL),
                  checkboxInput("select_all_pdrb", "Pilih Semua Kode", value = FALSE), 
                  div(style = "max-height: 80px; overflow-y: auto;",
                      uiOutput("kodeUI_pdrb")
                  ), 
                  selectInput("tahun_pdrb", "Pilih Tahun:", 
                              choices = c("2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024"), selected = "2023"),
                  selectInput("triwulan_pdrb", "Pilih Triwulan:", 
                              choices = c("Triwulan 1", "Triwulan 2", "Triwulan 3", "Triwulan 4"), selected = "Triwulan 1"),
                  textInput("search_code", "Cari Kode:"), 
                  textOutput("nama_lapangan_usaha")
              ),
              box(title = "Grafik PDRB", status = "primary", solidHeader = TRUE, width = 8,
                  plotlyOutput("pdrb_plot")
              )
            ),
            fluidRow(
              box(title = "Filter Line Chart", status = "primary", solidHeader = TRUE, width = 4,
                  selectInput("flag_line", "Pilih Flag:", choices = NULL), # Input Flag
                  checkboxInput("select_all_line", "Pilih Semua Kode", value = FALSE), # Checkbox select all
                  uiOutput("periode_filter_ui"),
                  div(style = "max-height: 80px; overflow-y: auto;", # Scrollable dropdown
                      uiOutput("kodeUI_line")
                  ),
                  uiOutput("tahun_range_ui")
              ),
              box(title = "Line Chart PDRB Triwulanan", status = "primary", solidHeader = TRUE, width = 8,
                  plotlyOutput("line_adhb")
              )
            ),
            fluidRow(
              box(title = "Filter Line Chart", status = "primary", solidHeader = TRUE, width = 4,
                  # selectInput("flag_line", "Pilih Flag:", choices = NULL), # Input Flag
                  # checkboxInput("select_all_line", "Pilih Semua Kode", value = FALSE), # Checkbox select all
                  uiOutput("periode_filter_ui_simple"),
                  # div(style = "max-height: 80px; overflow-y: auto;", # Scrollable dropdown
                  #     uiOutput("kodeUI_line")
                  # ),
                  uiOutput("tahun_range_ui_simple")
                  # uiOutput("conditional")
              ),
              box(title = "Line Chart PDRB Triwulanan", status = "primary", solidHeader = TRUE, width = 8,
                  plotlyOutput("line_adhb_simple")
              )
            ),
            fluidRow(
              box(
                title = "PDRB SERI 2010 ATAS DASAR HARGA BERLAKU MENURUT LAPANGAN USAHA (JUTA RUPIAH)", status = "primary", solidHeader = TRUE, width = 12,
                DT::DTOutput("adhb_table")
              )
            )
    )
  )
)