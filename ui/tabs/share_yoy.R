tabItem(tabName = "share_yoy",
        fluidRow(
          box(title = "Filter Share YOY", status = "primary", solidHeader = TRUE, width = 4,
              # Dropdown untuk memilih flag
              selectInput("share_yoy_flag", "Pilih Flag:", 
                          choices = c("Flag 1 - 2 Digit", "Flag 2 - 3 Digit"),
                          selected = "Flag 1 - 2 Digit"),
              # Dropdown dinamis untuk kode komoditas
              div(style = "max-height: 100px; overflow-y: auto;", 
                  uiOutput("share_yoy_kode_komoditas_UI")
              ), 
              # Dropdown untuk memilih bulan
              selectInput("share_yoy_bulan", "Pilih Bulan:", 
                          choices = c("Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus",
                                      "September", "Oktober", "November", "Desember"), selected = "Januari"),
              # New input for 2-digit Kode Komoditas, shown only when Flag 2 - 3 Digit is selected
              conditionalPanel(
                condition = "input.share_yoy_flag == 'Flag 2 - 3 Digit'",
                selectInput("share_yoy_kode_komoditas_2_digit", "Filter Kode Komoditas:", 
                            choices = c("Pilih Semua", ""),
                            selected = "Pilih Semua")  # Choices will be updated in server
              ),
              # Search field untuk kode komoditas
              textInput("search_code_share_yoy", "Cari Kode Komoditas:"),
              # Tampilkan nama komoditas yang dipilih
              textOutput("share_yoy_nama_komoditas"),
              tags$div(style = "border-top: 1px solid #ccc; margin: 10px 0;"),
              htmlOutput("share_yoy_max_change_text")
          ),
          box(title = "Grafik Share YOY", status = "primary", solidHeader = TRUE, width = 8,
              plotlyOutput("share_yoy_plot")
          )
        ),
        fluidRow(
          box(title = "Top 10 Andil Positif", status = "primary", solidHeader = TRUE, width = 6,
              tableOutput("share_yoy_top_increase")
          ),
          box(title = "Top 10 Andil Negatif", status = "primary", solidHeader = TRUE, width = 6,
              tableOutput("share_yoy_top_decrease")
          )
        ),
        fluidRow(
          box(title = "Filter Perkembangan Andil Inflasi", status = "primary", solidHeader = TRUE, width = 4,
              selectInput("yoy_share_flag", "Pilih Flag:", choices = NULL),
              checkboxInput("yoy_share_select_all", "Pilih Semua Komoditas", value = FALSE),
              div(style = "max-height: 80px; overflow-y: auto;",
                  uiOutput("yoy_shareKodeKomoditasUI")
              )), 
          box(title = "Perkembangan Andil Inflasi (y-on-y)", status = "primary", solidHeader = TRUE, width = 8,
              plotlyOutput("yoy_share_plot_tahunan")
          )
        )
)