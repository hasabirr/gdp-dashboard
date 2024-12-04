# ihk_tahunan <<- NULL
# ihk_triwulanan <<- NULL
# ihk_mtm <<- NULL
# ihk_ytd <<- NULL
# ihk_yoy <<- NULL
# share_mtm <<- NULL
# share_ytd <<- NULL
# share_yoy <<- NULL
# Triwulan_4_Before <<- NULL
# inflasi_triwulanan <<- NULL
# 
# uploaded_files <- reactiveValues(names = NULL)
# uploaded_files_before <- reactiveValues(names = NULL)
# 
# data_uploaded <- reactiveVal(FALSE) 
# valid_files <- reactiveVal(FALSE)
# 
# # FUNCTION =====================================================================
# 
# # Fungsi validasi ekstensi file
# validate_file_extensions <- function(file_names) {
#   all(tools::file_ext(file_names) == "xlsx")
# }
# 
# # Fungsi validasi file names tahun sekarang
# validate_file_names <- function(file_names) {
#   valid_pattern <- "3317 (0[1-9]|1[0-2]) Bahan Rilis Inflasi (Januari|Februari|Maret|April|Mei|Juni|Juli|Agustus|September|Oktober|November|Desember) (\\d{4})"
#   
#   matches <- grepl(valid_pattern, file_names)
#   
#   if (all(matches)) {
#     tahun_sekarang <- unique(sub(valid_pattern, "\\3", file_names[matches]))
#     tahun_sekarang <- sub("\\.xlsx$", "", tahun_sekarang)
#     return(list(all_match = TRUE, tahun_sekarang = tahun_sekarang))
#   } else {
#     return(list(all_match = FALSE))
#   }
# }
# 
# # Fungsi untuk validasi nama file tahun sebelumnya
# validate_previous_year_file_names <- function(file_names, tahun_sekarang) {
#   previous_year <- as.numeric(tahun_sekarang) - 1
#   
#   # Pola regex untuk nama file yang valid
#   valid_pattern <- paste0("3317 (1[0-2]|0[1-3]) Bahan Rilis Inflasi (Oktober|November|Desember) ", previous_year, "\\.xlsx$")
#   
#   # Ambil file yang sesuai dengan pola
#   valid_files <- file_names[grepl(valid_pattern, file_names)]
#   
#   # Cek jumlah file yang valid
#   if (length(valid_files) != 3) {
#     showNotification(paste("Jumlah file yang valid harus tepat 3 untuk bulan Oktober, November, dan Desember. Anda mengunggah: ", 
#                            paste(file_names, collapse = ", ")), type = "error")
#     return(FALSE)
#   }
#   
#   # Cek apakah semua bulan yang dibutuhkan ada
#   required_months <- c("Oktober", "November", "Desember")
#   found_months <- gsub(valid_pattern, "\\2", valid_files)
#   
#   if (!all(required_months %in% found_months)) {
#     missing_months <- setdiff(required_months, found_months)
#     showNotification(paste("File yang valid harus mencakup bulan: ", paste(missing_months, collapse = ", "), 
#                            ". File yang ditemukan: ", paste(found_months, collapse = ", ")), type = "error")
#     return(FALSE)
#   }
#   
#   return(TRUE)
# }
# 
# # Fungsi untuk memeriksa jumlah file dan bulan yang diperlukan
# check_file_count <- function(file_names, session) {
#   # Daftar bulan yang harus ada
#   required_months <- c("Oktober", "November", "Desember")
#   
#   # Hitung file yang valid untuk bulan yang diinginkan
#   valid_files <- file_names[grepl("3317 (10|11|12) Bahan Rilis Inflasi", file_names)]
#   
#   # Cek jumlah file
#   if (length(valid_files) != 3) {
#     showNotification("Jumlah file yang valid harus tepat 3 untuk bulan Oktober, November, dan Desember. Anda mengunggah: ", 
#                      paste(file_names, collapse = ", "), type = "error")
#     return(FALSE)
#   }
#   
#   # Cek apakah semua bulan yang dibutuhkan ada
#   found_months <- gsub("3317 (10|11|12) Bahan Rilis Inflasi ([A-Za-z]+) \\d{4}", "\\2", valid_files)
#   found_months <- sub("\\.xlsx$", "", found_months)
#   if (!all(required_months %in% found_months)) {
#     missing_months <- setdiff(required_months, found_months)
#     showNotification(paste("File yang valid harus mencakup bulan: ", paste(missing_months, collapse = ", "), 
#                            ". File yang ditemukan: ", paste(found_months, collapse = ", ")), type = "error")
#     return(FALSE)
#   }
#   
#   return(TRUE)
# }
# 
# 
# 
# # PROSES INPUT DATA ============================================================
# observeEvent(input$process_data, {
#   
#   # req(input$data_files)
#   # req(input$data_files_before)
#   
#   # Case jika file sekarang dan tahun sebelumnya belum diunggah
#   # if (is.null(uploaded_files$names) || is.null(uploaded_files_before$names)) {
#   #   showNotification("Lengkapi data terlebih dahulu dengan mengunggah kedua file.", type = "error")
#   #   return()
#   # }
#   
#   # Cek apakah file input data_files kosong
#   if (is.null(input$data_files) || nrow(input$data_files) == 0) {
#     showNotification("Lengkapi data terlebih dahulu dengan mengunggah file.", type = "error")
#     return(NULL)  # Hentikan proses jika file tidak ada
#   }
#   
#   # Cek apakah file input data_files_before kosong
#   if (is.null(input$data_files_before) || nrow(input$data_files_before) == 0) {
#     showNotification("Lengkapi data sebelumnya dengan mengunggah file.", type = "error")
#     return(NULL)  # Hentikan proses jika file sebelumnya tidak ada
#   }
#   
#   uploaded_file_names <- input$data_files$name
#   uploaded_file_names_before <- input$data_files_before$name
# 
#   
#   ## VALIDASI FILE =======================================================
#   
#   ### Tahun Sekarang =====================================================
#   
#   # Validasi ekstensi file tahun sekarang
#   if (!validate_file_extensions(uploaded_file_names)) {
#     showNotification("Semua file harus tahun sekarang memiliki ekstensi '.xlsx'.", type = "error")
#     return(NULL)
#   }
#   
#   # Validasi nama file tahun sekarang
#   result_validate <- validate_file_names(uploaded_file_names)
#   tahun_sekarang <- result_validate$tahun_sekarang
#   
#   if (!result_validate$all_match) {
#     showNotification("Nama file tidak sesuai format yang diharapkan. Pastikan nama file mengikuti format: '3317 [bulan] Bahan Rilis Inflasi [nama bulan] Tahun'.", type = "error")
#     return(NULL)
#   }
#   
#   ### Tahun Sebelumnya =====================================================
# 
#   # Validasi ekstensi file tahun sebelumnya
#   if (!validate_file_extensions(uploaded_file_names_before)) {
#     showNotification("Semua file tahun sebelumnya harus memiliki ekstensi '.xlsx'.", type = "error")
#     return(NULL)  # Stop processing if validation fails
#   }
#   
#   # Validasi nama file tahun sebelumnya
#   if (!validate_previous_year_file_names(uploaded_file_names_before, tahun_sekarang)) {
#     return(NULL)  
#   }
#   
#   # Validasi jumlah file yang diunggah
#   if (!check_file_count(uploaded_file_names_before, session)) {
#     return(NULL)  
#   }
#   
#   # Return TRUE jika semua file benar
#   valid_files(TRUE)
#   
#   ## PROSES DATA ===============================================================
#   
#   ### Data IHK Tahunan =========================================================
#   months <- c("Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember")
#   
#   data_list <- lapply(input$data_files$datapath, function(path) {
#     readxl::read_excel(path, skip = 2)
#   })
#   
#   ihk_tahunan <<- data_list[[1]] %>%
#     select(Tahun, `Kode Kota`, `Nama Kota`, `Kode Komoditas`, `Nama Komoditas`, `Flag`, IHK_Januari = `IHK`)
#   
#   for (i in 2:length(data_list)) {
#     ihk_tahunan <<- ihk_tahunan %>%
#       left_join(
#         data_list[[i]] %>%
#           select(`Kode Komoditas`, IHK = `IHK`), 
#         by = "Kode Komoditas"
#       ) %>%
#       rename(!!paste0("IHK_", months[i]) := `IHK`)
#   }
#   
#   # Update UI setelah data diproses
#   updateSelectInput(session, "flag", choices = unique(ihk_tahunan$Flag))
#   updateSelectInput(session, "kode_komoditas", choices = unique(ihk_tahunan$`Kode Komoditas`))
#   
#   ### Data IHK Triwulanan ========================================================
#   ihk_triwulanan <<- ihk_tahunan %>%
#     mutate(across(starts_with("IHK_"), as.numeric)) %>%
#     mutate(
#       Triwulan_1 = if(all(c("IHK_Januari", "IHK_Februari", "IHK_Maret") %in% colnames(ihk_tahunan))) {
#         rowMeans(select(., IHK_Januari, IHK_Februari, IHK_Maret), na.rm = TRUE)
#       } else NA,
#       
#       Triwulan_2 = if(all(c("IHK_April", "IHK_Mei", "IHK_Juni") %in% colnames(ihk_tahunan))) {
#         rowMeans(select(., IHK_April, IHK_Mei, IHK_Juni), na.rm = TRUE)
#       } else NA,
#       
#       Triwulan_3 = if(all(c("IHK_Juli", "IHK_Agustus", "IHK_September") %in% colnames(ihk_tahunan))) {
#         rowMeans(select(., IHK_Juli, IHK_Agustus, IHK_September), na.rm = TRUE)
#       } else NA,
#       
#       Triwulan_4 = if(all(c("IHK_Oktober", "IHK_November", "IHK_Desember") %in% colnames(ihk_tahunan))) {
#         rowMeans(select(., IHK_Oktober, IHK_November, IHK_Desember), na.rm = TRUE)
#       } else NA
#     )
#   
#   updateSelectInput(session, "flag_triwulan", choices = unique(ihk_triwulanan$Flag))
#   updateSelectInput(session, "kode_komoditas", choices = unique(ihk_triwulanan$`Kode Komoditas`))
#   
#   ### Data Inflasi MTM =========================================================
#   ihk_mtm <<- data_list[[1]] %>%
#     select(Tahun, `Kode Kota`, `Nama Kota`, `Kode Komoditas`, `Nama Komoditas`, `Flag`, `Inflasi MtM`) %>%
#     rename(Inflasi_Januari = `Inflasi MtM`)
#   
#   for (i in 2:length(data_list)) {
#     ihk_mtm <<- ihk_mtm %>%
#       left_join(
#         data_list[[i]] %>%
#           select(`Kode Komoditas`, `Inflasi MtM`), 
#         by = "Kode Komoditas"
#       ) %>%
#       rename(!!paste0("Inflasi_", months[i]) := `Inflasi MtM`)  # Rename kolom sesuai bulan
#   }
#   
#   updateSelectInput(session, "delta_flag", choices = unique(ihk_mtm$Flag))
#   updateSelectInput(session, "kode_komoditas", choices = unique(ihk_mtm$`Kode Komoditas`))
#   
#   updateSelectInput(session, "delta_flag_per_komoditas", choices = unique(ihk_mtm$Flag))
#   updateSelectInput(session, "kode_komoditas", choices = unique(ihk_mtm$`Kode Komoditas`))
#   
#   ### Data Inflasi YTD =========================================================
#   ihk_ytd <<- data_list[[1]] %>%
#     select(Tahun, `Kode Kota`, `Nama Kota`, `Kode Komoditas`, `Nama Komoditas`, `Flag`, `Inflasi YtD`) %>%
#     rename(Inflasi_Januari = `Inflasi YtD`)
#   
#   for (i in 2:length(data_list)) {
#     ihk_ytd <<- ihk_ytd %>%
#       left_join(
#         data_list[[i]] %>%
#           select(`Kode Komoditas`, `Inflasi YtD`), 
#         by = "Kode Komoditas"
#       ) %>%
#       rename(!!paste0("Inflasi_", months[i]) := `Inflasi YtD`)
#   }
#   
#   updateSelectInput(session, "ytd_flag", choices = unique(ihk_ytd$Flag))
#   updateSelectInput(session, "kode_komoditas", choices = unique(ihk_ytd$`Kode Komoditas`))
#   
#   ### Data Inflasi YOY =========================================================
#   ihk_yoy <<- data_list[[1]] %>%
#     select(Tahun, `Kode Kota`, `Nama Kota`, `Kode Komoditas`, `Nama Komoditas`, `Flag`, `Inflasi YoY`) %>%
#     rename(Inflasi_Januari = `Inflasi YoY`)
#   
#   for (i in 2:length(data_list)) {
#     ihk_yoy <<- ihk_yoy %>%
#       left_join(
#         data_list[[i]] %>%
#           select(`Kode Komoditas`, `Inflasi YoY`), 
#         by = "Kode Komoditas"
#       ) %>%
#       rename(!!paste0("Inflasi_", months[i]) := `Inflasi YoY`)
#   }
#   
#   updateSelectInput(session, "yoy_flag", choices = unique(ihk_yoy$Flag))
#   updateSelectInput(session, "kode_komoditas", choices = unique(ihk_yoy$`Kode Komoditas`))
#   
#   ### Data Share MtM =============================================================
#   share_mtm <<- data_list[[1]] %>%
#     select(Tahun, `Kode Kota`, `Nama Kota`, `Kode Komoditas`, `Nama Komoditas`, `Flag`, Share_Januari = `Andil MtM`)
#   
#   for (i in 2:length(data_list)) {
#     share_mtm <<- share_mtm %>%
#       left_join(
#         data_list[[i]] %>%
#           select(`Kode Komoditas`, Share = `Andil MtM`), 
#         by = "Kode Komoditas"
#       ) %>%
#       rename(!!paste0("Share_", months[i]) := Share)
#   }
#   
#   updateSelectInput(session, "mtm_share_flag", choices = unique(share_mtm$Flag))
#   updateSelectInput(session, "mtm_share_kode_komoditas", choices = unique(share_mtm$`Kode Komoditas`))
#   
#   ### Data Share YtD ===========================================================
#   share_ytd <<- data_list[[1]] %>%
#     select(Tahun, `Kode Kota`, `Nama Kota`, `Kode Komoditas`, `Nama Komoditas`, `Flag`, Share_Januari = `Andil YtD`)
#   
#   for (i in 2:length(data_list)) {
#     share_ytd <<- share_ytd %>%
#       left_join(
#         data_list[[i]] %>%
#           select(`Kode Komoditas`, Share = `Andil YtD`), 
#         by = "Kode Komoditas"
#       ) %>%
#       rename(!!paste0("Share_", months[i]) := Share)
#   }
#   updateSelectInput(session, "ytd_share_flag", choices = unique(share_ytd$Flag))
#   updateSelectInput(session, "ytd_share_kode_komoditas", choices = unique(share_ytd$`Kode Komoditas`))
#   
#   ### Data Share YoY ===========================================================
#   share_yoy <<- data_list[[1]] %>%
#     select(Tahun, `Kode Kota`, `Nama Kota`, `Kode Komoditas`, `Nama Komoditas`, `Flag`, Share_Januari = `Andil YoY`)
#   
#   for (i in 2:length(data_list)) {
#     share_yoy <<- share_yoy %>%
#       left_join(
#         data_list[[i]] %>%
#           select(`Kode Komoditas`, Share = `Andil YoY`), 
#         by = "Kode Komoditas"
#       ) %>%
#       rename(!!paste0("Share_", months[i]) := Share)
#   }
#   updateSelectInput(session, "yoy_share_flag", choices = unique(share_yoy$Flag))
#   updateSelectInput(session, "yoy_share_kode_komoditas", choices = unique(share_yoy$`Kode Komoditas`))
#   
#   
#   
#   ### Data IHK Tahunan (Prev) ====================================================
#   data_list_before <- lapply(input$data_files_before$datapath, function(path) {
#     readxl::read_excel(path, skip = 2)
#   })
#   
#   ihk_tahunan_before <<- data_list_before[[1]] %>%
#     select(`Kode Komoditas`, IHK_Oktober = `IHK`)
#   
#   for (i in 2:length(data_list_before)) {
#     ihk_tahunan_before <<- ihk_tahunan_before %>%
#       left_join(
#         data_list_before[[i]] %>%
#           select(`Kode Komoditas`, IHK = `IHK`), 
#         by = "Kode Komoditas"
#       ) %>%
#       rename(!!paste0("IHK_", months[i + 9]) := `IHK`)  # Adjust index for months of previous year
#   }
# 
#   # Hitung triwulan 4 for previous year
#   ihk_triwulan_4_before <<- ihk_tahunan_before %>%
#     mutate(across(starts_with("IHK_"), as.numeric)) %>%
#     mutate(
#       Triwulan_4_Before = if (all(c("IHK_Oktober", "IHK_November", "IHK_Desember") %in% colnames(ihk_tahunan_before))) {
#         rowMeans(select(., IHK_Oktober, IHK_November, IHK_Desember), na.rm = TRUE)
#       } else NA
#     ) %>%
#     select(`Kode Komoditas`, Triwulan_4_Before)
#   
#   ### Data Inflasi Triwulanan ==================================================
#   inflasi_sekarang <- ihk_triwulanan %>%
#     select(`Nama Kota`, `Kode Komoditas`, `Nama Komoditas`, Flag, Triwulan_1, Triwulan_2, Triwulan_3, Triwulan_4) %>%
#     rename(kode_komoditas = `Kode Komoditas`)
#   
#   inflasi_sebelum <- ihk_triwulan_4_before %>%
#     select(`Kode Komoditas`, Triwulan_4_Before) %>%
#     rename(kode_komoditas = `Kode Komoditas`)
#   
#   temp_inflasi_triwulanan <- inflasi_sekarang %>%
#     left_join(inflasi_sebelum, by = "kode_komoditas")
#   
#   inflasi_triwulanan <<- temp_inflasi_triwulanan %>%
#     mutate(
#       Inflasi_Triwulan_1 = ((Triwulan_1 - Triwulan_4_Before) / Triwulan_4_Before) * 100,
#       Inflasi_Triwulan_2 = ((Triwulan_2 - Triwulan_1) / Triwulan_1) * 100,
#       Inflasi_Triwulan_3 = ((Triwulan_3 - Triwulan_2) / Triwulan_2) * 100,
#       Inflasi_Triwulan_4 = ((Triwulan_4 - Triwulan_3) / Triwulan_3) * 100
#     ) %>%
#     rename(`Kode Komoditas` = kode_komoditas) %>%
#     select(`Nama Kota`, `Kode Komoditas`, `Nama Komoditas`, Flag, Inflasi_Triwulan_1,
#            Inflasi_Triwulan_2, Inflasi_Triwulan_3, Inflasi_Triwulan_4)
#   
#   updateSelectInput(session, "inf_tri_flag", choices = unique(inflasi_triwulanan$Flag))
#   updateSelectInput(session, "inf_tri_kode_komoditas", choices = unique(inflasi_triwulanan$`Kode Komoditas`))
# 
#   # PROSES SELESAI============================================================================
#   uploaded_files$names <- input$data_files$name
#   uploaded_files_before$names <- input$data_files_before$name
#   
#   showNotification("Data berhasil diproses!", type = "message")
#   
#   data_uploaded(TRUE)
# })
# 
# output$file_list <- renderUI({
#   req(uploaded_files$names)
#   tagList(
#     h4("File yang telah di-upload:"),
#     tags$ul(
#       lapply(uploaded_files$names, function(file) {
#         tags$li(file)
#       })
#     )
#   )
# })
# 
# output$file_list_before <- renderUI({
#   req(uploaded_files$names)
#   tagList(
#     h4("File yang telah di-upload:"),
#     tags$ul(
#       lapply(uploaded_files_before$names, function(file) {
#         tags$li(file)
#       })
#     )
#   )
# })
adhb <- read_excel("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/data/data_pdrb.xlsx", sheet = "adhb")
adhk <- read_excel("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/data/data_pdrb.xlsx", sheet = "adhk")
  
output$pdrb_item <- renderMenu({
  # req(data_uploaded())
  menuItem("PDRB", icon = icon("chart-line"), startExpanded = TRUE,
           menuSubItem("PDRB ADHB", tabName = "pdrb_adhb"),
           menuSubItem("PDRB ADHK", tabName = "pdrb_adhk"))
})
# 
# output$inflasi_item <- renderMenu({
#   # req(data_uploaded())
#   menuItem("Inflasi", icon = icon("chart-line"), startExpanded = FALSE,
#            menuSubItem("Inflasi Month to Month", tabName = "inflasi_mtm"),
#            menuSubItem("Inflasi Year to Date", tabName = "inflasi_ytd"),
#            menuSubItem("Inflasi Year on Year", tabName = "inflasi_yoy"),
#            menuSubItem("Inflasi Triwulanan", tabName = "inflasi_triwulanan")
#            )
# })
# 
# output$share_item <- renderMenu({
#   # req(data_uploaded())
#   menuItem("Share/Andil", icon = icon("chart-line"), startExpanded = FALSE,
#            menuSubItem("Share Month to Month", tabName = "share_mtm"),
#            menuSubItem("Share Year to Date", tabName = "share_ytd"),
#            menuSubItem("Share Year on Year", tabName = "share_yoy"))
# })
# 
# output$download_data_item <- renderMenu({
#   # req(data_uploaded())
#   menuItem("Download Data", tabName = "download_data", icon = icon("download"))
# })
# 
# output$glosarium_item <- renderMenu({
#   # req(data_uploaded())
#   menuItem("Glosarium", tabName = "glosarium_komoditas", icon = icon("book"))
# })

# current_year <<- reactiveVal(NULL)
# 
# observeEvent(input$data_files, {
#   filenames <- input$data_files$name
#   year <- get_year_from_filename(filenames)
#   current_year(year)
# })
# 
# output$current_year_text <- renderText({
#   req(valid_files())
#   paste("Tahun:", current_year())  # Menampilkan tahun dalam format h4
# })