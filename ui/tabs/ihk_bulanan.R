tabItem(tabName = "ihk_bulanan",
        fluidRow(
          box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
              selectInput("flag", "Pilih Flag:", choices = NULL),
              checkboxInput("select_all", "Pilih Semua Komoditas", value = FALSE), 
              div(style = "max-height: 80px; overflow-y: auto;",
                  uiOutput("kodeKomoditasUI")
              ), 
              selectInput("bulan", "Pilih Bulan:", 
                          choices = c("Januari", "Februari", "Maret", "April", "Mei", "Juni", 
                                      "Juli", "Agustus", "September", "Oktober", "November", "Desember"), selected = "Januari"),
              textInput("search_code", "Cari Kode Komoditas:"), 
              textOutput("nama_komoditas")
          ),
          box(title = "Grafik IHK", status = "primary", solidHeader = TRUE, width = 8,
              plotlyOutput("ihk_plot")
          )
        ),
        fluidRow(
          box(title = "Perkembangan IHK", status = "primary", solidHeader = TRUE, width = 12,
              plotlyOutput("ihk_plot_tahunan")
          )
        ),
        fluidRow(
          box(
            title = "Tabel IHK", status = "primary", solidHeader = TRUE, width = 12,
            DT::DTOutput("filtered_table")
          )
        )
)