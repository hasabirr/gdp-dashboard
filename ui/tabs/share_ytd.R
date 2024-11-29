tabItem(tabName = "share_ytd",
        fluidRow(
          box(title = "Filter Share YTD", status = "primary", solidHeader = TRUE, width = 4,
              # Dropdown untuk memilih flag
              selectInput("share_ytd_flag", "Pilih Flag:", 
                          choices = c("Flag 1 - 2 Digit", "Flag 2 - 3 Digit"),
                          selected = "Flag 1 - 2 Digit"),
              # Dropdown dinamis untuk kode komoditas
              div(style = "max-height: 100px; overflow-y: auto;", 
                  uiOutput("share_ytd_kode_komoditas_UI")
              ), 
              # Dropdown untuk memilih bulan
              selectInput("share_ytd_bulan", "Pilih Bulan:", 
                          choices = c("Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus",
                                      "September", "Oktober", "November", "Desember"), selected = "Januari"),
              # New input for 2-digit Kode Komoditas, shown only when Flag 2 - 3 Digit is selected
              conditionalPanel(
                condition = "input.share_ytd_flag == 'Flag 2 - 3 Digit'",
                selectInput("share_ytd_kode_komoditas_2_digit", "Filter Kode Komoditas:", 
                            choices = c("Pilih Semua", ""),
                            selected = "Pilih Semua")  # Choices will be updated in server
              ),
              # Search field untuk kode komoditas
              textInput("search_code_share_ytd", "Cari Kode Komoditas:"),
              # Tampilkan nama komoditas yang dipilih
              textOutput("share_ytd_nama_komoditas"),
              tags$div(style = "border-top: 1px solid #ccc; margin: 10px 0;"),
              htmlOutput("share_ytd_max_change_text")
          ),
          box(title = "Grafik Share YTD", status = "primary", solidHeader = TRUE, width = 8,
              plotlyOutput("share_ytd_plot")
          )
        ),
        fluidRow(
          box(title = "Top 10 Andil Positif", status = "primary", solidHeader = TRUE, width = 6,
              tableOutput("share_ytd_top_increase")
          ),
          box(title = "Top 10 Andil Negatif", status = "primary", solidHeader = TRUE, width = 6,
              tableOutput("share_ytd_top_decrease")
          )
        ),
        fluidRow(
                box(title = "Filter Perkembangan Andil Inflasi", status = "primary", solidHeader = TRUE, width = 4,
                    selectInput("ytd_share_flag", "Pilih Flag:", choices = NULL),
                    checkboxInput("ytd_share_select_all", "Pilih Semua Komoditas", value = FALSE),
                    div(style = "max-height: 80px; overflow-y: auto;",
                        uiOutput("ytd_shareKodeKomoditasUI")
                    )), 
                box(title = "Perkembangan Andil Inflasi (y-to-d)", status = "primary", solidHeader = TRUE, width = 8,
                    plotlyOutput("ytd_share_plot_tahunan")
                )
        ),
)