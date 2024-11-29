# SERVER GLOSARIUM ===========================================================

# Render DataTable untuk glosarium komoditas
output$table_glosarium <- renderDataTable({
  req(ihk_tahunan)  # Pastikan ihk_tahunan tersedia
  
  # Pilih kolom Kode Komoditas dan Nama Komoditas
  data_glosarium <- ihk_tahunan %>%
    select(`Kode Komoditas`, `Nama Komoditas`) %>%
    distinct()  # Menghilangkan duplikat jika ada
  
  # Tampilkan DataTable
  DT::datatable(data_glosarium, 
                options = list(pageLength = 10, autoWidth = TRUE),
                rownames = FALSE)
})