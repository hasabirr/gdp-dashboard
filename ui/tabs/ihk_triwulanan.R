tabItem(tabName = "ihk_triwulanan",
        fluidRow(
          box(title = "Filter", status = "primary", solidHeader = TRUE, width = 4,
              selectInput("flag_triwulan", "Pilih Flag:", choices = NULL),
              checkboxInput("select_all_triwulan", "Pilih Semua Komoditas", value = FALSE), 
              div(style = "max-height: 80px; overflow-y: auto;",
                  uiOutput("kodeKomoditasTriwulanUI")
              ), 
              selectInput("triwulan", "Pilih Triwulan:", 
                          choices = c("Triwulan 1", "Triwulan 2", "Triwulan 3", "Triwulan 4"), selected = "Triwulan 1"),
              textInput("search_code_triwulan", "Cari Kode Komoditas:"), 
              textOutput("nama_komoditas_triwulan")
          ),
          box(title = "Grafik IHK Triwulanan", status = "primary", solidHeader = TRUE, width = 8,
              plotlyOutput("ihk_plot_triwulan")
          )
        ),
        fluidRow(
          box(title = "Perkembangan IHK Triwulanan", status = "primary", solidHeader = TRUE, width = 12,
              plotlyOutput("ihk_plot_triwulanan_tahunan")
          )
        ),
        fluidRow(
          box(
            title = "Tabel IHK Triwulanan", status = "primary", solidHeader = TRUE, width = 12,
            DT::DTOutput("filtered_table_triwulan")
          )
        )
)