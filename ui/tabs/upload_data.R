tabItem(tabName = "upload_data",
        fluidRow(
          box(title = "Upload Data IHK", status = "primary", solidHeader = TRUE, width = 6,
              fileInput("data_files", "Pilih File IHK (Excel)", multiple = TRUE, accept = c(".xlsx"))
          ),
          box(title = "Upload Data IHK Tahun Sebelumnya", status = "primary", solidHeader = TRUE, width = 6,
              fileInput("data_files_before", "Pilih File IHK (Excel)", multiple = TRUE, accept = c(".xlsx"))
          )
        ),
        fluidRow(
          box(
            status = "primary", solidHeader = TRUE, width = 12,
            actionButton("process_data", "Proses Data")
          )
        ),
        fluidRow(
          box(title = "File yang di-upload", status = "primary", solidHeader = TRUE, width = 6,
              uiOutput("file_list")
          ),
          box(title = "File yang di-upload", status = "primary", solidHeader = TRUE, width = 6,
              uiOutput("file_list_before")
          )
        )
)
