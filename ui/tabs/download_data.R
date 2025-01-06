tabItem(tabName = "download_data",
        fluidRow(
          box(title = "Download Data", status = "primary", solidHeader = TRUE, width = 12,
              downloadButton("download_adhb", "PDRB ADHB"),
              downloadButton("download_adhk", "PDRB ADHK"),
              downloadButton("download_qtq", "Pertumbuhan Ekonomi QtQ"),
              downloadButton("download_yoy", "Pertumbuhan Ekonomi YoY"),
              downloadButton("download_ctc", "Pertumbuhan Ekonomi CtC"),
              downloadButton("download_laju_triwulanan", "Laju Implisit Triwulanan"),
              downloadButton("download_laju_tahunan", "Laju Implisit Tahunan"),
              downloadButton("download_total_laju_triwulanan", "Total Laju Implisit Triwulanan"),
              downloadButton("download_total_laju_tahunan", "Total Laju Implisit Tahunan"),
              downloadButton("download_share", "Share PDRB"),
              downloadButton("download_adhb_perkapita", "PDRB ADHB Perkapita"),
              downloadButton("download_adhk_perkapita", "PDRB ADHK Perkapita")
              # downloadButton("download_inflasi_yoy", "Download Data Inflasi YoY"),
              # downloadButton("download_inflasi_triwulanan", "Download Data Inflasi Triwulanan"),
              # downloadButton("download_andil_mtm", "Download Data Andil MtM"),
              # downloadButton("download_andil_ytd", "Download Data Andil YtD"),
              # downloadButton("download_andil_yoy", "Download Data Andil YoY")
          )
        )
        # fluidRow(
        #   box(
        #     title = "Download Data", 
        #     status = "primary", 
        #     solidHeader = TRUE, 
        #     width = 12,
        #     # Baris pertama: PDRB ADHB dan ADHK
        #     fluidRow(
        #       column(4, downloadButton("download_adhb", "PDRB ADHB")),
        #       column(4, downloadButton("download_adhk", "PDRB ADHK")),
        #       column(4, downloadButton("download_adhb_perkapita", "PDRB ADHB Perkapita"))
        #     ),
        #     # Baris kedua: Data PDRB ADHK Perkapita
        #     fluidRow(
        #       column(4, downloadButton("download_adhk_perkapita", "PDRB ADHK Perkapita")),
        #       column(4, downloadButton("download_laju_triwulanan", "Laju Implisit Triwulanan")),
        #       column(4, downloadButton("download_laju_tahunan", "Laju Implisit Tahunan"))
        #     ),
        #     # Baris ketiga: Total Laju Implisit
        #     fluidRow(
        #       column(6, downloadButton("download_total_laju_triwulanan", "Total Laju Implisit Triwulanan")),
        #       column(6, downloadButton("download_total_laju_tahunan", "Total Laju Implisit Tahunan"))
        #     )
        #     # Uncomment jika diperlukan tombol tambahan
        #     # fluidRow(
        #     #   column(4, downloadButton("download_inflasi_yoy", "Inflasi YoY")),
        #     #   column(4, downloadButton("download_inflasi_triwulanan", "Inflasi Triwulanan")),
        #     #   column(4, downloadButton("download_andil_mtm", "Andil MtM"))
        #     # )
        #   )
        # )
        
)