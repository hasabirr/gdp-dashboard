# Libraries
library(shiny)
library(shinydashboard)
library(dplyr)
library(plotly)
library(dplyr)
library(readxl)
library(openxlsx)
library(ggplot2)
library(DT)
library(writexl)
library(ggplot2)
library(RColorBrewer)

# Custom Function
get_year_from_filename <- function(filenames) {
  filename <- filenames[1]
  year <- sub(".*(\\d{4})\\..*", "\\1", filename)
  return(trimws(year))
}

# USER INTERFACE ===============================================================
ui <- dashboardPage(
  source("ui/ui_header.R")$value,
  source("ui/ui_sidebar.R")$value,
  source("ui/ui_body.R")$value
)

# SERVER =======================================================================
server <- function(input, output, session) {
  
  # INITIAL SERVER ================================================================
  source("server/initial.R", local = TRUE)
  
  # SERVER IHK BULANAN ===============================================================
  source("server/ihk_bulanan.R", local = TRUE)
  
  # SERVER IHK TRIWULANAN ===============================================================
  source("server/ihk_triwulanan.R", local = TRUE)
  
  # SERVER INFLASI MTM ===============================================================
  source("server/inflasi_mtm.R", local = TRUE)
  
  # SERVER INFLASI YTD =========================================================
  source("server/inflasi_ytd.R", local = TRUE)
  
  # SERVER INFLASI YOY =========================================================
  source("server/inflasi_yoy.R", local = TRUE)
  
  # SERVER INFLASI MTM PER KOMODITAS ===========================================
  source("server/inflasi_mtm_komoditas.R", local = TRUE)
  
  # SERVER INFLASI TRIWULANAN ==================================================
  source("server/inflasi_triwulanan.R", local = TRUE)
  
  # SERVER SHARE MTM ===========================================================
  source("server/share_mtm.R", local = TRUE)
  
  # SERVER SHARE YTD ===========================================================
  source("server/share_ytd.R", local = TRUE)
  
  # SERVER SHARE YOY ===========================================================
  source("server/share_yoy.R", local = TRUE)
  
  # SERVER DOWNLOAD DATA =======================================================
  source("server/download.R", local = TRUE)
  
  # SERVER GLOSARIUM ===========================================================
  source("server/glosarium.R", local = TRUE)
}

# Run Aplikasi
shinyApp(ui, server)
