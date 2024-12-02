dashboardBody(
  tags$head(
    tags$link(rel = "icon", type = "image/png", href = "https://www.bps.go.id/_next/image?url=%2Fassets%2Flogo-bps.png&w=1080&q=75")
  ),
  tags$script(HTML("$('body').addClass('fixed');")),
  tabItems(
    source("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/ui/tabs/upload_data.R")$value,
    source("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/ui/tabs/ihk_bulanan.R")$value,
    source("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/ui/tabs/ihk_triwulanan.R")$value,
    source("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/ui/tabs/inflasi_mtm.R")$value,
    source("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/ui/tabs/inflasi_mtm_komoditas.R")$value,
    source("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/ui/tabs/inflasi_ytd.R")$value,
    source("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/ui/tabs/inflasi_yoy.R")$value,
    source("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/ui/tabs/inflasi_triwulanan.R")$value,
    source("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/ui/tabs/share_mtm.R")$value,
    source("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/ui/tabs/share_ytd.R")$value,
    source("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/ui/tabs/share_yoy.R")$value,
    source("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/ui/tabs/download_data.R")$value,
    source("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/ui/tabs/glosarium.R")$value
  )
)
