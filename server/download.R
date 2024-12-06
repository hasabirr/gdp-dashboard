# Download data IHK Bulanan
output$download_adhb <- downloadHandler(
  filename = function() {
    file_name <- "data_pdrb_adhb.xlsx"
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(adhb, path = file)
  }
)

# Download data IHK Triwulanan
output$download_adhk <- downloadHandler(
  filename = function() {
    file_name <- "data_pdrb_adhk.xlsx"
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(adhb, path = file)
  }
)

# Download data Inflasi MTM
output$download_adhb_perkapita <- downloadHandler(
  filename = function() {
    file_name <- "data_pdrb_adhb_perkapita.xlsx"
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(adhb, path = file)
  }
)

# Download data Inflasi YtD
output$download_adhk_perkapita <- downloadHandler(
  filename = function() {
    file_name <- "data_pdrb_adhk_perkapita.xlsx"
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(adhb, path = file)
  }
)