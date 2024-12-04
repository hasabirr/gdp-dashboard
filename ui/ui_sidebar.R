dashboardSidebar(
  sidebarMenu(
    style = "overflow: visible;",
    menuItem("Upload Data", tabName = "upload_data", icon = icon("file-upload"), selected = TRUE),
    menuItemOutput("pdrb_general"),
    menuItemOutput("pdrb_growth"), # kasih keterangan dari data ADHK
    menuItem("Laju Implisit", tabName = "laju_implisit", icon = icon("file-upload")),
    menuItem("Share PDRB", tabName = "share", icon = icon("file-upload")),
    menuItem("PDRB Per Kapita", tabName = "pdrb_perkapita", icon = icon("file-upload")),
    menuItem("Download Data", tabName = "download", icon = icon("file-upload")),
    menuItem("Glosarium", tabName = "glosarium", icon = icon("file-upload"))
  )
)