tabItem(tabName = "laju_implisit",
        fluidRow(
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    selectInput("flag_laju", "Pilih Flag:", choices = NULL), # Input Flag
                    checkboxInput("select_all_laju", "Pilih Semua Kode", value = FALSE),
                    div(style = "max-height: 80px; overflow-y: auto;", 
                        uiOutput("kodeUI_laju")
                    ),
                    uiOutput("periode_laju"),
                    uiOutput("tahun_laju"),
                    textInput("search_code_laju", "Cari Kode Lapangan Usaha:"), 
                    textOutput("nama_lapangan_usaha_laju")
                ),
                box(title = "Grafik 1 Laju Implisit", status = "primary", solidHeader = TRUE, width = 8,
                    withSpinner(plotlyOutput("line_laju"), type = 1)
                )
        ),
        fluidRow(
                box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
                    uiOutput("periode_laju_simple"),
                    uiOutput("tahun_laju_simple")
                ),
                box(title = "Grafik 2 Laju Implisit", status = "primary", solidHeader = TRUE, width = 8,
                    withSpinner(plotlyOutput("line_laju_simple"), type = 1)
                )
        ),
        # Input Baris Pertama
        fluidRow(
          box(
            title = "Pilih Jenis Data Untuk Ditampilkan (Klik Lagi Untuk Menerapkan Filter)", status = "primary", solidHeader = TRUE, width = 12,
            div(
              style = "display: flex; align-items: center; gap: 20px; flex-wrap: wrap; color: white;",
              actionButton("data_grafik1_triwulanan", "Data Grafik 1 Triwulanan", class = "btn-primary"),
              actionButton("data_grafik1_tahunan", "Data Grafik 1 Tahunan", class = "btn-primary"),
              actionButton("data_grafik2_triwulanan", "Data Grafik 2 Triwulanan", class = "btn-primary"),
              actionButton("data_grafik2_tahunan", "Data Grafik 2 Tahunan", class = "btn-primary")
            )
          )
        ),
        
        # Tabel Baris Kedua
        fluidRow(
          box(
            status = "primary", solidHeader = TRUE, width = 12,
            withSpinner(DT::DTOutput("laju_table"), type = 1)
          )
        )
)