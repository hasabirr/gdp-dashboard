# SERVER GLOSARIUM ===========================================================

# Render DataTable untuk glosarium komoditas
output$table_glosarium <- renderDataTable({
  
  # Pilih kolom Kode Komoditas dan Nama Komoditas
  data_glosarium <- adhb %>%
    select(kode, nama) %>%
    distinct()  # Menghilangkan duplikat jika ada
  
  # Tampilkan DataTable
  DT::datatable(data_glosarium, 
                options = list(pageLength = 10, autoWidth = TRUE),
                rownames = FALSE)
})