dashboardBody(
  tags$head(
    tags$link(rel = "icon", type = "image/png", href = "https://www.bps.go.id/_next/image?url=%2Fassets%2Flogo-bps.png&w=1080&q=75")
  ),
  tags$script(HTML("$('body').addClass('fixed');")),
  tabItems(
    source("ui/tabs/adhb_general.R")$value,
    source("ui/tabs/adhk_general.R")$value,
    source("ui/tabs/laju_implisit.R")$value,
    source("ui/tabs/adhb_perkapita.R")$value,
    source("ui/tabs/glosarium.R")$value
    # source("ui/tabs/upload_data.R")$value
  )
)