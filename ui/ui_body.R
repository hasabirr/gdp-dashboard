dashboardBody(
  # 
  # 
  # # Memastikan Shinyjs berfungsi dengan benar
  # tags$script(HTML("alert('Shinyjs is working!');")),
  # 
  # # Menambahkan spinner dan kutipan pada body
  # waiter_show_on_load(
  #   tagList(
  #     spin_puzzle(), # Animasi spinner
  #     br(),
  #     h4("Sedang memuat aplikasi, mohon tunggu"), # Teks utama
  #     br(),
  #     tags$i(
  #       id = "dynamic-quotes", 
  #       style = "font-size: 14px; color: #555;", 
  #       "Memuat..." # Placeholder awal
  #     )
  #   )
  # ),
  
  # Menambahkan script JS untuk mengganti kutipan setiap 3 detik
  tags$head(
    tags$link(rel = "icon", type = "image/png", href = "https://www.bps.go.id/_next/image?url=%2Fassets%2Flogo-bps.png&w=1080&q=75"),
    tags$style(HTML("
      .btn-primary {
        background-color: #1f77b4;
        color: white;
        border: none;
        padding: 10px 20px;
        font-size: 14px;
      }
      .btn-primary:hover {
        background-color: grey;
        color: black;
      }
    "))
    # tags$script(HTML("
    #     $(document).on('shiny:connected', function() {  // Pastikan Shiny terhubung
    #       console.log('Shiny connected');  // Debugging log
    #       var quotes = [
    #         'Success usually comes to those who are too busy to be looking for it.',
    #         'Opportunities don\\'t happen. You create them.',
    #         'The harder you work for something, the greater you'll feel when you achieve it.',
    #         'Great things never come from comfort zones.',
    #         'Don't stop when you're tired. Stop when you're done.',
    #         'Dream big and dare to fail.',
    #         'The only limit to our realization of tomorrow is our doubts of today.',
    #         'Act as if what you do makes a difference. It does.'
    #       ];
    #       var index = 0;
    #       setInterval(function() {
    #         console.log('Changing quote');  // Debugging log
    #         // Pastikan elemen ada sebelum mencoba menggantinya
    #         if ($('#dynamic-quotes').length) {
    #           $('#dynamic-quotes').text('\"' + quotes[index] + '\"');
    #           index = (index + 1) % quotes.length; // Loop kembali ke awal
    #         }
    #       }, 3000); // Perbarui setiap 3 detik
    #     });
    #   "))
  ),
  tags$script(HTML("$('body').addClass('fixed');")),
  
  
  
  tabItems(
    source("ui/tabs/adhb_general.R")$value,
    source("ui/tabs/adhk_general.R")$value,
    source("ui/tabs/laju_implisit.R")$value,
    source("ui/tabs/adhb_perkapita.R")$value,
    source("ui/tabs/adhk_perkapita.R")$value,
    source("ui/tabs/share.R")$value,
    source("ui/tabs/qtq.R")$value,
    source("ui/tabs/yoy.R")$value,
    source("ui/tabs/ctc.R")$value,
    source("ui/tabs/download_data.R")$value,
    source("ui/tabs/glosarium.R")$value
  )
)