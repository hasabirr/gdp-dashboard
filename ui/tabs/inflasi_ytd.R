tabItem(tabName = "inflasi_ytd",
        fluidRow(
          box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
              # selectInput("ytd_flag", "Pilih Flag:", 
              #             choices = unique(ihk_ytd$Flag), selected = "A"),
              selectInput("ytd_flag", "Pilih Flag:", choices = NULL),
              checkboxInput("ytd_select_all", "Pilih Semua Komoditas", value = FALSE),
              div(style = "max-height: 80px; overflow-y: auto;",
                  uiOutput("ytdKodeKomoditasUI")
              ), 
              selectInput("ytd_bulan", "Pilih Bulan:", 
                          choices = c("Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus",
                                      "September", "Oktober", "November", "Desember"), selected = "Januari"),
              textInput("search_code_ytd", "Cari Kode Komoditas:"),
              div(
                textOutput("nama_komoditas_ytd"), 
                style = "border: 2px solid #000; padding: 2px; margin: 2px; border-radius: 5px; background-color: #f9f9f9;"
              )
          ),
          box(title = "Grafik Inflasi (YTD)", status = "primary", solidHeader = TRUE, width = 8,
              plotlyOutput("ytd_ihk_plot")
          )
        ),
        fluidRow(
          box(title = "Kenaikan/Penurunan Terbesar", status = "primary", solidHeader = TRUE, width = 4,
              htmlOutput("ytd_max_change_text")
          ),
          box(title = "Perkembangan Inflasi (y-to-d)", status = "primary", solidHeader = TRUE, width = 8,
              plotlyOutput("ytd_ihk_plot_tahunan")
          )
        ),
        fluidRow(
          box(title = "Top 10 Kenaikan Terbesar", status = "primary", solidHeader = TRUE, width = 6,
              tableOutput("ytd_top_increase")
          ),
          box(title = "Top 10 Penurunan Terbesar", status = "primary", solidHeader = TRUE, width = 6,
              tableOutput("ytd_top_decrease")
          )
        )
)