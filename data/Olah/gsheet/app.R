library(shiny)
library(googlesheets4)
library(gsheet)



# Fungsi untuk membaca data
read_google_sheet <- function() {
  data <- gsheet2tbl('docs.google.com/spreadsheets/d/1FeTRkKfhJc4z29vP5ftXL2hNBolYTtQU/edit?gid=1723490359#gid=1723490359')
  return(data)
}

# UI Aplikasi
ui <- fluidPage(
  titlePanel("Tabel Data dari Google Sheets"),
  mainPanel(
    tableOutput("data_table")
  )
)

# Server Aplikasi
server <- function(input, output, session) {
  # Membaca data saat aplikasi dijalankan
  data <- reactive({
    read_google_sheet()
  })
  
  # Menampilkan data dalam tabel
  output$data_table <- renderTable({
    data()
  })
}

# Jalankan aplikasi
shinyApp(ui, server)