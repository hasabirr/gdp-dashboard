library(googlesheets4) 
library(dplyr)

# Nonaktifkan autentikasi jika file publik
gs4_deauth()

# Membaca data
sheet_url <- "https://docs.google.com/spreadsheets/d/1FeTRkKfhJc4z29vP5ftXL2hNBolYTtQU"
data <- read_sheet(sheet_url, sheet = "adhk")

install.packages('gsheet')
library(gsheet)
adhk <- gsheet2tbl('docs.google.com/spreadsheets/d/1FeTRkKfhJc4z29vP5ftXL2hNBolYTtQU/edit?gid=1723490359#gid=1723490359')
View(adhk) 
