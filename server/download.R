# Download data IHK Bulanan
output$download_ihk_bulanan <- downloadHandler(
  filename = function() {
    file_name <- paste("data_ihk_bulanan_", current_year(), ".xlsx", sep = "")
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(ihk_tahunan, path = file)
  }
)

# Download data IHK Triwulanan
output$download_ihk_triwulanan <- downloadHandler(
  filename = function() {
    file_name <- paste("data_ihk_triwulanan_", current_year(), ".xlsx", sep = "")
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(ihk_triwulanan, path = file)
  }
)

# Download data Inflasi MTM
output$download_inflasi_mtm <- downloadHandler(
  filename = function() {
    file_name <- paste("data_inflasi_mtm_", current_year(), ".xlsx", sep = "")
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(ihk_mtm, path = file)
  }
)

# Download data Inflasi YtD
output$download_inflasi_ytd <- downloadHandler(
  filename = function() {
    file_name <- paste("data_inflasi_ytd_", current_year(), ".xlsx", sep = "")
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(ihk_ytd, path = file)
  }
)
# Download data Inflasi YoY
output$download_inflasi_yoy <- downloadHandler(
  filename = function() {
    file_name <- paste("data_inflasi_yoy_", current_year(), ".xlsx", sep = "")
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(ihk_yoy, path = file)
  }
)

# Download data Inflasi Triwulanan
output$download_inflasi_triwulanan <- downloadHandler(
  filename = function() {
    file_name <- paste("data_inflasi_triwulanan_", current_year(), ".xlsx", sep = "")
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(inflasi_triwulanan, path = file)
  }
)
# Download data Andil MTM
output$download_andil_mtm <- downloadHandler(
  filename = function() {
    file_name <- paste("data_andil_mtm_", current_year(), ".xlsx", sep = "")
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(share_mtm, path = file)
  }
)

# Download data Andil YtD
output$download_andil_ytd <- downloadHandler(
  filename = function() {
    file_name <- paste("data_andil_ytd_", current_year(), ".xlsx", sep = "")
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(share_ytd, path = file)
  }
)
# Download data Andil YoY
output$download_andil_yoy <- downloadHandler(
  filename = function() {
    file_name <- paste("data_andil_yoy_", current_year(), ".xlsx", sep = "")
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(share_yoy, path = file)
  }
)