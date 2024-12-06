tabItem(tabName = "adhk_perkapita",
        fluidRow(
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    selectInput("flag_adhk_perkapita", "Pilih Flag:", choices = NULL),
                    checkboxInput("select_all_adhk_perkapita", "Pilih Semua Kode", value = FALSE), 
                    div(style = "max-height: 80px; overflow-y: auto;",
                        uiOutput("kodeUI_adhk_perkapita")
                    ), 
                    # selectInput("tahun_adhk_perkapita", "Pilih Tahun:", 
                    #             choices = c("2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024"), selected = "2023"),
                    uiOutput("tahun_adhk_perkapita_ui"),
                    selectInput("triwulan_adhk_perkapita", "Pilih Triwulan:", 
                                choices = c("Triwulan 1", "Triwulan 2", "Triwulan 3", "Triwulan 4"), selected = "Triwulan 1"),
                    textInput("search_code_adhk_perkapita", "Cari Kode Lapangan Usaha:"), 
                    textOutput("nama_lapangan_usaha_adhk_perkapita")
                ),
                box(title = "PDRB adhk Menurut Kode, Tahun, dan Triwulan", status = "primary", solidHeader = TRUE, width = 8,
                    plotlyOutput("adhk_perkapita_plot")
                )
        ),
        fluidRow(
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    selectInput("flag_adhk_perkapita_line", "Pilih Flag:", choices = NULL), # Input Flag
                    checkboxInput("select_all_adhk_perkapita_line", "Pilih Semua Kode", value = FALSE),
                    div(style = "max-height: 80px; overflow-y: auto;", 
                        uiOutput("kodeUI_adhk_perkapita_line")
                    ),
                    uiOutput("periode_adhk_perkapita_line"),
                    uiOutput("tahun_adhk_perkapita_line")
                ),
                box(title = "Total PDRB adhk Menurut Periode dan Kode", status = "primary", solidHeader = TRUE, width = 8,
                    plotlyOutput("line_adhk_perkapita")
                )
        ),
        fluidRow(
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    uiOutput("periode_adhk_perkapita_line_simple"),
                    uiOutput("tahun_adhk_perkapita_line_simple")
                ),
                box(title = "Total PDRB adhk Per Periode (Triwulan dan Tahunan)", status = "primary", solidHeader = TRUE, width = 8,
                    plotlyOutput("line_adhk_perkapita_simple")
                )
        ),
        fluidRow(
                box(
                        title = "PDRB SERI 2010 ATAS DASAR HARGA BERLAKU MENURUT LAPANGAN USAHA (JUTA RUPIAH)", status = "primary", solidHeader = TRUE, width = 12,
                        DT::DTOutput("adhk_perkapita_table")
                )
        )
)