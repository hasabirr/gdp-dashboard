tabItem(tabName = "share_mtm",
        fluidRow(
          box(title = "Filter Share MtM", status = "primary", solidHeader = TRUE, width = 4,
              # Dropdown untuk memilih flag
              selectInput("mtm_flag", "Pilih Flag:", 
                          choices = c("Flag 1 - 2 Digit", "Flag 2 - 3 Digit"),
                          selected = "Flag 1 - 2 Digit"),
              div(style = "max-height: 100px; overflow-y: auto;", 
                  uiOutput("mtmKodeKomoditasUI")
              ), 
              # Dropdown untuk memilih bulan
              selectInput("mtm_bulan", "Pilih Bulan:", 
                          choices = c("Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus",
                                      "September", "Oktober", "November", "Desember"), selected = "Januari"),
              # New input for 2-digit Kode Komoditas, shown only when Flag 2 - 3 Digit is selected
              conditionalPanel(
                condition = "input.mtm_flag == 'Flag 2 - 3 Digit'",
                selectInput("mtm_kode_komoditas_2_digit", "Filter Kode Komoditas:", 
                            choices = c("Pilih Semua", ""),
                            selected = "Pilih Semua")  # Choices will be updated in server
              ),
              # Search field untuk kode komoditas
              textInput("search_code_share_mtm", "Cari Kode Komoditas:"),
              # Tampilkan nama komoditas yang dipilih
              textOutput("nama_komoditas_mtm"),
              tags$div(style = "border-top: 1px solid #ccc; margin: 10px 0;"),
              htmlOutput("mtm_max_change_text")
          ),
          box(title = "Grafik Share MtM", status = "primary", solidHeader = TRUE, width = 8,
              plotlyOutput("mtm_share_plot")
          )
        ),
        fluidRow(
          box(title = "Top 10 Andil Positif", status = "primary", solidHeader = TRUE, width = 6,
              tableOutput("mtm_top_increase")
          ),
          box(title = "Top 10 Andil Negatif", status = "primary", solidHeader = TRUE, width = 6,
              tableOutput("mtm_top_decrease")
          )
        ),
        fluidRow(
          box(title = "Filter Perkembangan Andil Inflasi", status = "primary", solidHeader = TRUE, width = 4,
              selectInput("mtm_share_flag", "Pilih Flag:", choices = NULL),
              checkboxInput("mtm_share_select_all", "Pilih Semua Komoditas", value = FALSE),
              div(style = "max-height: 80px; overflow-y: auto;",
                  uiOutput("mtm_shareKodeKomoditasUI")
              )), 
          box(title = "Perkembangan Andil Inflasi (m-to-m)", status = "primary", solidHeader = TRUE, width = 8,
              plotlyOutput("mtm_share_plot_tahunan")
          )
        )
)