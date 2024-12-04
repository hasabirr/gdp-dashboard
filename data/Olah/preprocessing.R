library(dplyr)
library(stringr)
library(readxl)

# Sample data
data <- read_excel("E:/OneDrive/Work/Training/BPS Orientation/PDRB/gdp-dashboard/data/data_pdrb.xlsx", sheet = "kode")

# Sample data
# data <- data.frame(
#   Kode = c(
#     "A. Pertanian, Kehutanan, dan Perikanan",
#     "A. 1. Pertanian, Peternakan, Perburuan dan Jasa Pertanian",
#     "A. 1. a. Tanaman Pangan",
#     "A. 1. b. Tanaman Hortikultura Semusim",
#     "A. 1. c. Perkebunan Semusim",
#     "A. 1. d. Tanaman Hortikultura Tahunan dan Lainnya",
#     "A. 1. e. Perkebunan Tahunan",
#     "A. 1. f. Peternakan",
#     "A. 1. g. Jasa Pertanian dan Perburuan",
#     "A. 2. Kehutanan dan Penebangan Kayu",
#     "A. 3. Perikanan"
#   )
# )

process_hierarchy <- function(data) {
  # Initialize levels
  level1 <- level2 <- level3 <- level4 <- 0
  
  data %>%
    rowwise() %>%
    mutate(
      # Determine flag
      flag = case_when(
        str_detect(Kode, "^[A-Z]\\.\\s") & !str_detect(Kode, "\\d") ~ 1,  # Level 1
        str_detect(Kode, "^[A-Z]\\.\\s\\d{1,2}\\.\\s") & !str_detect(Kode, "[a-z]\\.") ~ 2,  # Level 2 (support 2 digits)
        str_detect(Kode, "^[A-Z]\\.\\s\\d{1,2}\\.\\s[a-z]\\.") ~ 3,  # Level 3
        str_detect(Kode, "^[R-U]\\.\\s") ~ 4,  # Unique Level 4
        TRUE ~ NA_integer_
      ),
      # Parse kode
      kode = if (!is.na(flag)) {
        if (flag == 1) {
          # Reset levels and assign new code for Level 1 (with two digits)
          level1 <<- level1 + 1
          level2 <<- 0
          level3 <<- 0
          level4 <<- 0
          sprintf("%02d", level1)  # Ensure 2-digit format for Level 1
        } else if (flag == 2) {
          # Assign code for Level 2 (supporting 2-digit codes)
          level2 <- as.integer(str_extract(Kode, "\\d{1,2}"))  # Extract 1-2 digit number
          level3 <<- 0
          level4 <<- 0
          sprintf("%02d%02d", level1, level2)  # Ensure 2-digit format for Level 2
        } else if (flag == 3) {
          # Assign code for Level 3
          level3 <<- level3 + 1
          level4 <<- 0
          sprintf("%02d%02d%02d", level1, level2, level3)  # 2 digits for each level
        } else if (flag == 4) {
          # Assign unique code for Level 4 starting from 1
          level4 <<- level4 + 1
          sprintf("%d", 10 + level4)  # Code starts after Q (Q = 10, R = 11, etc.)
        } else {
          NA_character_
        }
      } else {
        NA_character_
      },
      # Extract nama
      nama = if (!is.na(flag)) {
        # Hapus bagian di level 1 (huruf besar dan titik, diikuti spasi)
        if (flag == 1) {
          str_trim(str_remove(Kode, "^[A-Z]\\.\\s*"))  # Remove the "A." part for Level 1
        } else {
          # Hapus untuk level 2 dan 3 (huruf besar, angka, dan huruf kecil dengan titik)
          str_trim(str_remove(Kode, "^[A-Z]\\.\\s*\\d{1,2}\\.?(\\s[a-z]\\.)?\\s*"))
        }
      } else {
        NA_character_
      }
    ) %>%
    ungroup()
}



# Apply the function
result <- process_hierarchy(data)

# Print the result
print(result)
writexl::write_xlsx(result, "E:/dataaa.xlsx")
