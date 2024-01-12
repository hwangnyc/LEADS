#Page to Scrape LEADS IMG URLS

# Load necessary libraries
library(rvest)
library(dplyr)

# Function to scrape data from a single page
scrape_page <- function(page_num) {
  url <- paste0("https://nij.ojp.gov/funding/leads-scholar-biographies?page=", page_num)

  # Read the HTML content
  webpage <- read_html(url)

  # Extract the desired information
  bio_sections <- webpage %>%
    html_nodes(".view-content .views-row")

  # Initialize empty vectors for names and image URLs
  extracted_names <- character(0)
  extracted_urls <- character(0)

  # Loop through bio sections to extract names and URLs
  for (section in bio_sections) {
    name <- section %>% html_node(".field--name-title") %>% html_text(trim = TRUE)
    image_url <- section %>% html_node("img") %>% html_attr("src")

    if (!is.na(name) && !is.na(image_url) && image_url != "") {
      extracted_names <- c(extracted_names, name)
      extracted_urls <- c(extracted_urls, image_url)
    }
  }

  # Create a data frame for this page
  page_df <- data.frame(Name = extracted_names, Image_URL = extracted_urls, stringsAsFactors = FALSE)

  return(page_df)
}

# Scrape data from all five pages and combine into one dataframe
all_data <- lapply(0:4, scrape_page)
leads_img <- do.call(rbind, all_data)

leads_img$Image_URL <- paste0("https://nij.ojp.gov/",leads_img$Image_URL)

leads_img <- leads_img %>% rename(Lead_Scholar="Name")
