tabItem(
  tags$head(
    tags$style(HTML("
    .dataTables_wrapper {
      width: 100%;
    }
    table.dataTable {
      width: 100% !important;
      table-layout: auto !important;
    }
  "))
  ),
  tabName = "glosarium_komoditas",
  fluidRow(
    box(
      title = "Glosarium Kode dan Nama Komoditas", 
      width = 12, status = "primary", solidHeader = TRUE,
      DT::DTOutput("table_glosarium")  # Output DT
    )
  )
)