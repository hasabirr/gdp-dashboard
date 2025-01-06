tabItem(tabName = "ctc",
        fluidRow(
          box(title = "Pertumbuhan Ekonomi Cumulative (CtC)", status = "primary", solidHeader = TRUE, width = 12,
              p("Pertumbuhan ekonomi CtC dihitung menggunakan data PDRB ADHK"))
        ),
        fluidRow(box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    selectInput("flag_ctc", "Pilih Flag:", choices = NULL),
                    checkboxInput("select_all_ctc", "Pilih Semua Kode", value = FALSE), 
                    div(style = "max-height: 80px; overflow-y: auto;",
                        uiOutput("kodeUI_ctc")
                    ),
                    uiOutput("tahun_range_ctc"),
                    textInput("search_code_ctc", "Cari Kode Lapangan Usaha:"), 
                    textOutput("nama_lapangan_usaha_ctc")
                ),
                box(title = "Pertumbuhan Ekonomi Cumulative (CtC)", status = "primary", solidHeader = TRUE, width = 8,
                    withSpinner(plotlyOutput("ctc_plot"), type = 1)
                )
        ),
        fluidRow(
                box(
                        title = "Tabel Nilai Pertumbuhan Ekonomi Cumulative (CtC)", status = "primary", solidHeader = TRUE, width = 12,
                        withSpinner(DT::DTOutput("ctc_table"), type = 1)
                )
        )
)