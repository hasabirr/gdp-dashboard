tabItem(tabName = "qtq",
        fluidRow(
          box(title = "Pertumbuhan Ekonomi Quarter-to-Quarter (QtQ)", status = "primary", solidHeader = TRUE, width = 12,
              p("Pertumbuhan ekonomi QtQ dihitung menggunakan data PDRB ADHK"))
        ),
        fluidRow(
                
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    selectInput("flag_qtq", "Pilih Flag:", choices = NULL),
                    checkboxInput("select_all_qtq", "Pilih Semua Kode", value = FALSE), 
                    div(style = "max-height: 80px; overflow-y: auto;",
                        uiOutput("kodeUI_qtq")
                    ),
                    uiOutput("tahun_range_qtq"),
                    textInput("search_code_qtq", "Cari Kode Lapangan Usaha:"), 
                    textOutput("nama_lapangan_usaha_qtq")
                ),
                box(title = "Pertumbuhan Ekonomi Quarter-to-Quarter (QtQ)", status = "primary", solidHeader = TRUE, width = 8,
                    withSpinner(plotlyOutput("qtq_plot"), type = 1)
                )
        ),
        fluidRow(
                box(
                        title = "Tabel Nilai Pertumbuhan Ekonnomi Quarter-to-Quarter (QtQ)", status = "primary", solidHeader = TRUE, width = 12,
                        withSpinner(DT::DTOutput("qtq_table"), type = 1)
                )
        )
)