tabItem(tabName = "download_data",
        fluidRow(
          box(title = "Download Data", status = "primary", solidHeader = TRUE, width = 12,
              downloadButton("download_ihk_bulanan", "Download Data IHK Bulanan"),
              downloadButton("download_ihk_triwulanan", "Download Data IHK Triwulanan"),
              downloadButton("download_inflasi_mtm", "Download Data Inflasi MtM"),
              downloadButton("download_inflasi_ytd", "Download Data Inflasi YtD"),
              downloadButton("download_inflasi_yoy", "Download Data Inflasi YoY"),
              downloadButton("download_inflasi_triwulanan", "Download Data Inflasi Triwulanan"),
              downloadButton("download_andil_mtm", "Download Data Andil MtM"),
              downloadButton("download_andil_ytd", "Download Data Andil YtD"),
              downloadButton("download_andil_yoy", "Download Data Andil YoY")
          )
        )
)