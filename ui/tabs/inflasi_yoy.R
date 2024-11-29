tabItem(tabName = "inflasi_yoy",
        fluidRow(
          box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
              # selectInput("yoy_flag", "Pilih Flag:", 
              #             choices = unique(ihk_yoy$Flag), selected = "A"),
              selectInput("yoy_flag", "Pilih Flag:", choices = NULL),
              checkboxInput("yoy_select_all", "Pilih Semua Komoditas", value = FALSE),
              div(style = "max-height: 80px; overflow-y: auto;",
                  uiOutput("yoyKodeKomoditasUI")
              ), 
              selectInput("yoy_bulan", "Pilih Bulan:", 
                          choices = c("Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus",
                                      "September", "Oktober", "November", "Desember"), selected = "Januari"),
              textInput("search_code_yoy", "Cari Kode Komoditas:"),
              div(
                textOutput("nama_komoditas_yoy"), 
                style = "border: 2px solid #000; padding: 2px; margin: 2px; border-radius: 5px; background-color: #f9f9f9;"
              )
          ),
          box(title = "Grafik Inflasi (y-o-y)", status = "primary", solidHeader = TRUE, width = 8,
              plotlyOutput("yoy_ihk_plot")
          )
        ),
        fluidRow(
          box(title = "Kenaikan/Penurunan Terbesar", status = "primary", solidHeader = TRUE, width = 4,
              htmlOutput("max_change_yoy_text")
          ),
          box(title = "Perkembangan Inflasi (y-on-y)", status = "primary", solidHeader = TRUE, width = 8,
              plotlyOutput("yoy_ihk_plot_tahunan")
          )
        ),
        fluidRow(
          box(title = "Top 10 Kenaikan Terbesar", status = "primary", solidHeader = TRUE, width = 6,
              tableOutput("top_increase_yoy")
          ),
          box(title = "Top 10 Penurunan Terbesar", status = "primary", solidHeader = TRUE, width = 6,
              tableOutput("top_decrease_yoy")
          )
        )
)