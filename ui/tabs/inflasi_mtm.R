tabItem(tabName = "inflasi_mtm",
        fluidRow(
          box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
              selectInput("delta_flag", "Pilih Flag:", choices = NULL),
              checkboxInput("delta_select_all", "Pilih Semua Komoditas", value = FALSE),
              div(style = "max-height: 80px; overflow-y: auto;",
                  uiOutput("deltaKodeKomoditasUI")
              ), 
              selectInput("delta_bulan", "Pilih Bulan:", 
                          choices = c("Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus",
                                      "September", "Oktober", "November", "Desember"), selected = "Januari"),
              textInput("search_code2", "Cari Kode Komoditas:"),
              div(
                textOutput("nama_komoditas2"), 
                style = "border: 2px solid #000; padding: 2px; margin: 2px; border-radius: 5px; background-color: #f9f9f9;"
              )
          ),
          box(title = "Grafik Inflasi (m-to-m)", status = "primary", solidHeader = TRUE, width = 8,
              plotlyOutput("delta_ihk_plot")
          )
        ),
        fluidRow(
          box(title = "Kenaikan/Penurunan Terbesar", status = "primary", solidHeader = TRUE, width = 4,
              htmlOutput("max_change_text")
          ),
          box(title = "Perkembangan Inflasi (m-to-m)", status = "primary", solidHeader = TRUE, width = 8,
              plotlyOutput("delta_ihk_plot_tahunan")
          )
        ),
        fluidRow(
          box(title = "Top 10 Kenaikan Terbesar", status = "primary", solidHeader = TRUE, width = 6,
              tableOutput("top_increase")
          ),
          box(title = "Top 10 Penurunan Terbesar", status = "primary", solidHeader = TRUE, width = 6,
              tableOutput("top_decrease")
          )
        )
)