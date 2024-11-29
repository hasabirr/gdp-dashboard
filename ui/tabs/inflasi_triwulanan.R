tabItem(tabName = "inflasi_triwulanan",
        fluidRow(
          box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
              selectInput("inf_tri_flag", "Pilih Flag:", choices = NULL),
              checkboxInput("inf_tri_select_all", "Pilih Semua Komoditas", value = FALSE),
              div(style = "max-height: 80px; overflow-y: auto;",
                  uiOutput("inf_tri_kodeKomoditasUI")
              ), 
              selectInput("inf_tri_periode", "Pilih Triwulan:", 
                          choices = c("Triwulan 1", "Triwulan 2", "Triwulan 3", "Triwulan 4"), selected = "Triwulan 1"),
              textInput("inf_tri_search_code", "Cari Kode Komoditas:"),
              div(
                textOutput("inf_tri_nama_komoditas"), 
                style = "border: 2px solid #000; padding: 2px; margin: 2px; border-radius: 5px; background-color: #f9f9f9;"
              )
          ),
          box(title = "Grafik Inflasi Triwulanan", status = "primary", solidHeader = TRUE, width = 8,
              plotlyOutput("inf_tri_ihk_plot")
          )
        ),
        fluidRow(
          box(title = "Kenaikan/Penurunan Terbesar", status = "primary", solidHeader = TRUE, width = 4,
              htmlOutput("inf_tri_max_change_text")
          ),
          box(title = "Perkembangan Inflasi Triwulanan", status = "primary", solidHeader = TRUE, width = 8,
              plotlyOutput("inf_tri_ihk_plot_tahunan")
          )
        ),
        fluidRow(
          box(title = "Top 10 Kenaikan Terbesar", status = "primary", solidHeader = TRUE, width = 6,
              tableOutput("inf_tri_top_increase")
          ),
          box(title = "Top 10 Penurunan Terbesar", status = "primary", solidHeader = TRUE, width = 6,
              tableOutput("inf_tri_top_decrease")
          )
        )
)
