dashboardSidebar(
  sidebarMenu(
    id = "sidebar_menu",
    style = "overflow: visible;",
    # menuItem("Upload Data", tabName = "upload_data", icon = icon("file-upload"), selected = TRUE),
    menuItemOutput("pdrb_general"),
    menuItemOutput("pdrb_growth"), # kasih keterangan dari data ADHK
    menuItemOutput("laju_implisit"),
    menuItemOutput("share"),
    menuItemOutput("pdrb_perkapita"),
    menuItemOutput("download"),
    menuItemOutput("glosarium")
  )
)