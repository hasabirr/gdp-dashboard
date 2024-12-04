tabItem(tabName = "upload_data",
        fluidRow(
          box(title = "Upload Data PDRB", status = "primary", solidHeader = TRUE, width = 6,
              fileInput("data_files", "Pilih File (Excel)", multiple = TRUE, accept = c(".xlsx"))
          ),
          box(title = "File yang di-upload", status = "primary", solidHeader = TRUE, width = 6,
              uiOutput("file_list"))
        ),
        fluidRow(
          box(
            status = "primary", solidHeader = TRUE, width = 12,
            actionButton("process_data", "Proses Data")
          )
        )
)
