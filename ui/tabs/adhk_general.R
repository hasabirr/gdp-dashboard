tabItem(tabName = "adhk_general",
        fluidRow(
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    selectInput("flag_adhk", "Pilih Flag:", choices = NULL),
                    checkboxInput("select_all_adhk", "Pilih Semua Kode", value = FALSE), 
                    div(style = "max-height: 80px; overflow-y: auto;",
                        uiOutput("kodeUI_adhk")
                    ), 
                    selectInput("tahun_adhk", "Pilih Tahun:", 
                                choices = c("2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024"), selected = "2023"),
                    selectInput("triwulan_adhk", "Pilih Triwulan:", 
                                choices = c("Triwulan 1", "Triwulan 2", "Triwulan 3", "Triwulan 4"), selected = "Triwulan 1"),
                    textInput("search_code_adhk", "Cari Kode Lapangan Usaha:"), 
                    textOutput("nama_lapangan_usaha_adhk")
                ),
                box(title = "PDRB ADHK Menurut Kode, Tahun, dan Triwulan", status = "primary", solidHeader = TRUE, width = 8,
                    plotlyOutput("adhk_plot")
                )
        ),
        fluidRow(
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    selectInput("flag_line_adhk", "Pilih Flag:", choices = NULL), # Input Flag
                    checkboxInput("select_all_line_adhk", "Pilih Semua Kode", value = FALSE),
                    div(style = "max-height: 80px; overflow-y: auto;", 
                        uiOutput("kodeUI_line_adhk")
                    ),
                    uiOutput("periode_filter_ui_adhk"),
                    uiOutput("tahun_range_ui_adhk")
                ),
                box(title = "Total PDRB ADHK Menurut Periode dan Kode", status = "primary", solidHeader = TRUE, width = 8,
                    plotlyOutput("line_adhk")
                )
        ),
        fluidRow(
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    uiOutput("periode_filter_ui_simple_adhk"),
                    uiOutput("tahun_range_ui_simple_adhk")
                ),
                box(title = "Total PDRB ADHK Per Periode (Triwulan dan Tahunan)", status = "primary", solidHeader = TRUE, width = 8,
                    plotlyOutput("line_adhk_simple")
                )
        ),
        fluidRow(
                box(
                        title = "PDRB SERI 2010 ATAS DASAR HARGA BERLAKU MENURUT LAPANGAN USAHA (JUTA RUPIAH)", status = "primary", solidHeader = TRUE, width = 12,
                        DT::DTOutput("adhk_table")
                )
        )
)