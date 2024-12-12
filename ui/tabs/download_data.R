tabItem(tabName = "download_data",
        fluidRow(
          box(title = "Download Data", status = "primary", solidHeader = TRUE, width = 12,
              downloadButton("download_adhb", "Download Data PDRB ADHB"),
              downloadButton("download_adhk", "Download Data PDRB ADHK"),
              downloadButton("download_adhb_perkapita", "Download Data PDRB ADHB Perkapita"),
              downloadButton("download_adhk_perkapita", "Download Data PDRB ADHK Perkapita"),
              downloadButton("download_laju_triwulanan", "Download Data Laju Implisit Triwulanan"),
              downloadButton("download_laju_tahunan", "Download Data Laju Implisit Tahunan"),
              downloadButton("download_total_laju_triwulanan", "Download Data Total Laju Implisit Triwulanan"),
              downloadButton("download_total_laju_tahunan", "Download Data Total Laju Implisit Tahunan")
              # downloadButton("download_inflasi_yoy", "Download Data Inflasi YoY"),
              # downloadButton("download_inflasi_triwulanan", "Download Data Inflasi Triwulanan"),
              # downloadButton("download_andil_mtm", "Download Data Andil MtM"),
              # downloadButton("download_andil_ytd", "Download Data Andil YtD"),
              # downloadButton("download_andil_yoy", "Download Data Andil YoY")
          )
        )
)