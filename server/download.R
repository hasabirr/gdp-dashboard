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

# Download data
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

output$download_laju_triwulanan <- downloadHandler(
  filename = function() {
    file_name <- "data_pdrb_adhk_perkapita.xlsx"
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(implisit, path = file)
  }
)
output$download_laju_tahunan <- downloadHandler(
  filename = function() {
    file_name <- "data_pdrb_adhk_perkapita.xlsx"
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(implisit_2, path = file)
  }
)
output$download_total_laju_triwulanan <- downloadHandler(
  filename = function() {
    file_name <- "data_pdrb_adhk_perkapita.xlsx"
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(implisit_triwulanan, path = file)
  }
)
output$download_total_laju_tahunan <- downloadHandler(
  filename = function() {
    file_name <- "data_pdrb_adhk_perkapita.xlsx"
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(implisit_tahunan, path = file)
  }
)