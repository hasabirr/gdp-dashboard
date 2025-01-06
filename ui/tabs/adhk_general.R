tabItem(tabName = "adhk_general",
        fluidRow(
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    selectInput("flag_adhk", "Pilih Flag:", choices = NULL),
                    checkboxInput("select_all_adhk", "Pilih Semua Kode", value = FALSE), 
                    div(style = "max-height: 80px; overflow-y: auto;",
                        uiOutput("kodeUI_adhk")
                    ), 
                    # selectInput("tahun_adhk", "Pilih Tahun:", 
                    #             choices = c("2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024"), selected = "2023"),
                    uiOutput("tahun_adhk_ui"),
                    selectInput("triwulan_adhk", "Pilih Triwulan:", 
                                choices = c("Triwulan 1", "Triwulan 2", "Triwulan 3", "Triwulan 4"), selected = "Triwulan 1"),
                    textInput("search_code_adhk", "Cari Kode Lapangan Usaha:"), 
                    textOutput("nama_lapangan_usaha_adhk")
                ),
                box(title = "Grafik 1 - PDRB ADHK Menurut Kode, Tahun, dan Triwulan", status = "primary", solidHeader = TRUE, width = 8,
                    withSpinner(plotlyOutput("adhk_plot"), type = 1)
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
                box(title = "Grafik 2 - Total PDRB ADHK Menurut Periode dan Kode", status = "primary", solidHeader = TRUE, width = 8,
                    withSpinner(plotlyOutput("line_adhk"), type = 1)
                )
        ),
        fluidRow(
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    uiOutput("periode_filter_ui_simple_adhk"),
                    uiOutput("tahun_range_ui_simple_adhk")
                ),
                box(title = "Grafik 3 - Total PDRB ADHK Per Periode (Triwulan dan Tahunan)", status = "primary", solidHeader = TRUE, width = 8,
                    withSpinner(plotlyOutput("line_adhk_simple"), type = 1)
                ),
        ),
        fluidRow(
                box(
                        title = "Pilih Jenis Data Untuk Ditampilkan (Klik Lagi Untuk Menerapkan Filter)", status = "primary", solidHeader = TRUE, width = 12,
                        # div(
                        #         style = "display: flex; align-items: center; gap: 30px; flex-wrap: wrap; color: white;",
                        #         actionButton("data_adhk_grafik1", "Data Grafik 1", class = "btn-primary"),
                        #         actionButton("data_adhk_grafik2_triwulanan", "Data Grafik 2 Triwulanan", class = "btn-primary"),
                        #         actionButton("data_adhk_grafik2_tahunan", "Data Grafik 2 Tahunan", class = "btn-primary"),
                        #         actionButton("data_adhk_grafik3_triwulanan", "Data Grafik 3 Triwulanan", class = "btn-primary"),
                        #         actionButton("data_adhk_grafik3_tahunan", "Data Grafik 3 Tahunan", class = "btn-primary")
                        # )
                        div(
                          style = "display: flex; align-items: center; gap: 30px; flex-wrap: wrap;",
                          actionButton("data_adhk_grafik1", "Data Grafik 1", class = "btn-primary"),
                          actionButton("data_adhk_grafik2_triwulanan", "Data Grafik 2 Triwulanan", class = "btn-primary"),
                          actionButton("data_adhk_grafik2_tahunan", "Data Grafik 2 Tahunan", class = "btn-primary"),
                          actionButton("data_adhk_grafik3_triwulanan", "Data Grafik 3 Triwulanan", class = "btn-primary"),
                          actionButton("data_adhk_grafik3_tahunan", "Data Grafik 3 Tahunan", class = "btn-primary")
                        )
                ),
                box(
                        # title = uiOutput("dynamic_box_title_adhk"), 
                        status = "primary", solidHeader = TRUE, width = 12,
                        withSpinner(DT::DTOutput("adhk_table"), type = 1)
                )
        )
)