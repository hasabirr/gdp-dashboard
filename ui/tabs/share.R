tabItem(tabName = "share",
        fluidRow(
          box(title = "Share PDRB Menurut Lapangan Usaha", status = "primary", solidHeader = TRUE, width = 12,
              p("Share PDRB dihitung menggunakan data PDRB ADHB"))
        ),
        fluidRow(
          box(title = "Grafik Share", status = "primary", solidHeader = TRUE, width = 12,
              withSpinner(plotlyOutput("share_plot"), type = 1)
          )
        ),
        fluidRow(
          box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
              # Dropdown untuk memilih flag
              selectInput("share_flag_def", "Pilih Flag:", 
                          choices = c("Lapangan Usaha Utama", "Flag 1 - 2 Digit", "Flag 2 - 3 Digit"),
                          selected = "Lapangan Usaha Utama"),
              uiOutput("tahun_range_share"),
              selectInput("triwulan_share", "Pilih Triwulan:", 
                          choices = c("Triwulan 1", "Triwulan 2", "Triwulan 3", "Triwulan 4"), selected = "Triwulan 1"),
              # New input for 2-digit Kode Komoditas, shown only when Flag 2 - 3 Digit is selected
              conditionalPanel(
                condition = "input.share_flag_def == 'Flag 2 - 3 Digit'",
                selectInput("kode_2_digit", "Filter Kode Komoditas:", 
                            choices = c("Pilih Semua", ""),
                            selected = "Pilih Semua")  # Choices will be updated in server
              ),
              # Search field untuk kode komoditas
              textInput("search_code_share", "Cari Kode Lapangan Usaha:"),
              # Tampilkan nama komoditas yang dipilih
              textOutput("nama_lapangan_usaha_share"),
              
              # tags$div(style = "border-top: 1px solid #ccc; margin: 10px 0;"),
              htmlOutput("max_change_text")
          ),
          box(title = "Top 10 Andil Positif", status = "primary", solidHeader = TRUE, width = 8,
              withSpinner(DT::DTOutput("top_increase"), type = 1)
          )
        ),
        fluidRow(
          box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
              selectInput("share_flag", "Pilih Flag:", choices = NULL),
              checkboxInput("select_all_share", "Pilih Semua Komoditas", value = FALSE),
              div(style = "max-height: 80px; overflow-y: auto;",
                  uiOutput("kodeUI_share")
              ),
              uiOutput("tahun_slider_share_ui")), 
          box(title = "Perkembangan Share PDRB", status = "primary", solidHeader = TRUE, width = 8,
              withSpinner(plotlyOutput("share_plot_tahunan"), type = 1)
          )
        )
)