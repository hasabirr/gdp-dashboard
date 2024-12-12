tabItem(tabName = "yoy",
        fluidRow(
                
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    selectInput("flag_yoy", "Pilih Flag:", choices = NULL),
                    checkboxInput("select_all_yoy", "Pilih Semua Kode", value = FALSE), 
                    div(style = "max-height: 80px; overflow-y: auto;",
                        uiOutput("kodeUI_yoy")
                    ),
                    uiOutput("tahun_range_yoy"),
                    textInput("search_code_yoy", "Cari Kode Lapangan Usaha:"), 
                    textOutput("nama_lapangan_usaha_yoy")
                ),
                box(title = "Pertumbuhan Ekonomi Quarter-to-Quarter (YoY)", status = "primary", solidHeader = TRUE, width = 8,
                    plotlyOutput("yoy_plot")
                )
        ),
        fluidRow(
                box(
                        title = "Tabel Nilai Pertumbuhan Ekonnomi Quarter-to-Quarter (YoY)", status = "primary", solidHeader = TRUE, width = 12,
                        DT::DTOutput("yoy_table")
                )
        )
)