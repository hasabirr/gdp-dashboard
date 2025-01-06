# PDRB ADHB
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

# PDRB ADHK
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

# ADHB Perkapita
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

# ADHK Perkapita
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

# Laju implisit triwulanan
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

# Laju implisit tahunan
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

# Total laju implisit triwulanan
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

# Total laju implisit tahunan
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

# QtQ
output$download_qtq <- downloadHandler(
  filename = function() {
    file_name <- "data_pertumbuhan_ekonomi_qtq.xlsx"
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(qtq_data, path = file)
  }
)
# YoY
output$download_yoy <- downloadHandler(
  filename = function() {
    file_name <- "data_pertumbuhan_ekonomi_yoy.xlsx"
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(yoy_data, path = file)
  }
)
# CtC
output$download_ctc <- downloadHandler(
  filename = function() {
    file_name <- "data_pertumbuhan_ekonomi_ctc.xlsx"
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(ctc_data, path = file)
  }
)
# Share PDRB
output$download_share <- downloadHandler(
  filename = function() {
    file_name <- "data_share_pdrb.xlsx"
    file_name_no_spaces <- gsub(" ", "", file_name) 
    return(file_name_no_spaces)
  },
  content = function(file) {
    write_xlsx(share, path = file)
  }
)