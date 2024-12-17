tabItem(tabName = "adhb_general",
        fluidRow(
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    selectInput("flag_pdrb", "Pilih Flag:", choices = NULL),
                    checkboxInput("select_all_pdrb", "Pilih Semua Kode", value = FALSE), 
                    div(style = "max-height: 80px; overflow-y: auto;",
                        uiOutput("kodeUI_pdrb")
                    ), 
                    # selectInput("tahun_pdrb", "Pilih Tahun:", 
                    #             choices = c("2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024"), selected = "2023"),
                    uiOutput("tahun_pdrb_ui"),
                    selectInput("triwulan_pdrb", "Pilih Triwulan:", 
                                choices = c("Triwulan 1", "Triwulan 2", "Triwulan 3", "Triwulan 4"), selected = "Triwulan 1"),
                    textInput("search_code", "Cari Kode Lapangan Usaha:"), 
                    textOutput("nama_lapangan_usaha")
                ),
                box(title = "Grafik 1 - PDRB ADHB Menurut Kode, Tahun, dan Triwulan", status = "primary", solidHeader = TRUE, width = 8,
                    plotlyOutput("pdrb_plot")
                )
        ),
        fluidRow(
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    selectInput("flag_line", "Pilih Flag:", choices = NULL), # Input Flag
                    checkboxInput("select_all_line", "Pilih Semua Kode", value = FALSE),
                    div(style = "max-height: 80px; overflow-y: auto;", 
                        uiOutput("kodeUI_line")
                    ),
                    uiOutput("periode_filter_ui"),
                    uiOutput("tahun_range_ui")
                ),
                box(title = "Grafik 2 - Total PDRB ADHB Menurut Periode dan Kode", status = "primary", solidHeader = TRUE, width = 8,
                    plotlyOutput("line_adhb")
                )
        ),
        fluidRow(
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    uiOutput("periode_filter_ui_simple"),
                    uiOutput("tahun_range_ui_simple")
                ),
                box(title = "Grafik 3 - Total PDRB ADHB Per Periode (Triwulan dan Tahunan)", status = "primary", solidHeader = TRUE, width = 8,
                    plotlyOutput("line_adhb_simple")
                )
        ),
        fluidRow(
          box(
            title = "Pilih Jenis Data Untuk Ditampilkan (Klik Lagi Untuk Menerapkan Filter)", status = "primary", solidHeader = TRUE, width = 12,
            div(
              style = "display: flex; align-items: center; gap: 30px; flex-wrap: wrap; color: white;",
              actionButton("data_adhb_grafik1", "Data Grafik 1", class = "btn-primary"),
              actionButton("data_adhb_grafik2_triwulanan", "Data Grafik 2 Triwulanan", class = "btn-primary"),
              actionButton("data_adhb_grafik2_tahunan", "Data Grafik 2 Tahunan", class = "btn-primary"),
              actionButton("data_adhb_grafik3_triwulanan", "Data Grafik 3 Triwulanan", class = "btn-primary"),
              actionButton("data_adhb_grafik3_tahunan", "Data Grafik 3 Tahunan", class = "btn-primary")
            )
          ),
          box(
            # title = uiOutput("dynamic_box_title_adhb"), 
            status = "primary", solidHeader = TRUE, width = 12,
            DT::DTOutput("adhb_table")
          )
        ),
        # fluidRow(
        #         box(
        #                 # title = uiOutput("dynamic_box_title_adhb"), 
        #                 status = "primary", solidHeader = TRUE, width = 12,
        #                 DT::DTOutput("adhb_table")
        #         )
        # )
)