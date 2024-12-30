tabItem(tabName = "adhb_perkapita",
        fluidRow(
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    selectInput("flag_adhb_perkapita", "Pilih Flag:", choices = NULL),
                    checkboxInput("select_all_adhb_perkapita", "Pilih Semua Kode", value = FALSE), 
                    div(style = "max-height: 80px; overflow-y: auto;",
                        uiOutput("kodeUI_adhb_perkapita")
                    ), 
                    # selectInput("tahun_adhb_perkapita", "Pilih Tahun:", 
                    #             choices = c("2017", "2018", "2019", "2020", "2021", "2022", "2023", "2024"), selected = "2023"),
                    uiOutput("tahun_adhb_perkapita_ui"),
                    selectInput("triwulan_adhb_perkapita", "Pilih Triwulan:", 
                                choices = c("Triwulan 1", "Triwulan 2", "Triwulan 3", "Triwulan 4"), selected = "Triwulan 1"),
                    textInput("search_code_adhb_perkapita", "Cari Kode Lapangan Usaha:"), 
                    textOutput("nama_lapangan_usaha_adhb_perkapita")
                ),
                box(title = "PDRB ADHB Perkapita Menurut Kode, Tahun, dan Triwulan", status = "primary", solidHeader = TRUE, width = 8,
                    plotlyOutput("adhb_perkapita_plot")
                )
        ),
        fluidRow(
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    selectInput("flag_adhb_perkapita_line", "Pilih Flag:", choices = NULL), # Input Flag
                    checkboxInput("select_all_adhb_perkapita_line", "Pilih Semua Kode", value = FALSE),
                    div(style = "max-height: 80px; overflow-y: auto;", 
                        uiOutput("kodeUI_adhb_perkapita_line")
                    ),
                    uiOutput("periode_adhb_perkapita_line"),
                    uiOutput("tahun_adhb_perkapita_line")
                ),
                box(title = "Total PDRB ADHB Perkapita Menurut Periode dan Kode", status = "primary", solidHeader = TRUE, width = 8,
                    plotlyOutput("line_adhb_perkapita")
                )
        ),
        fluidRow(
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    uiOutput("periode_adhb_perkapita_line_simple"),
                    uiOutput("tahun_adhb_perkapita_line_simple")
                ),
                box(title = "Total PDRB ADHB Perkapita Per Periode (Triwulan dan Tahunan)", status = "primary", solidHeader = TRUE, width = 8,
                    plotlyOutput("line_adhb_perkapita_simple")
                )
        ),
        fluidRow(
                box(
                        title = "Tabel PDRB ADHB Perkapita", status = "primary", solidHeader = TRUE, width = 12,
                        DT::DTOutput("adhb_perkapita_table")
                )
        )
)