dashboardSidebar(
  sidebarMenu(
    style = "overflow: visible;",
    menuItem(textOutput("current_year_text")),
    menuItem("Upload Data", tabName = "upload_data", icon = icon("file-upload"), selected = TRUE),
    menuItemOutput("ihk_item"),
    menuItemOutput("inflasi_item"),
    menuItemOutput("share_item"),
    menuItemOutput("download_data_item"),
    menuItemOutput("glosarium_item"))
)