library(rvest)
library(dplyr)
library(stringr)

# Function to scrape data from a given URL
scrape_data <- function(url) {
  webpage <- read_html(url)
  data <- webpage %>%
    html_nodes(".field--name-title, .field--name-field-biography-title,  .field--type-text-with-summary") %>%
    html_text() %>%
    matrix(ncol = 3, byrow = TRUE, dimnames = list(NULL, c("Lead_Scholar", "Rank_Cohort_UNICIV", "Bio")))

  df <- as.data.frame(data, stringsAsFactors = FALSE)
  return(df)
}

# Create an empty data frame to store the results
all_data <- data.frame()

# Set the base URL
base_url <- "https://nij.ojp.gov/funding/leads-scholar-biographies?page="

# Set the number of pages you want to scrape
num_pages <- 5

# Loop through the pages and scrape data
for (i in 0:num_pages) {
  url <- paste0(base_url, i, "#biographies-biographies-by-role-1fno2kjmxvggmpkr")
  page_data <- scrape_data(url)
  all_data <- bind_rows(all_data, page_data)
}

#Data Cleaning
job_titles <- gsub(";.*|,.*", "", all_data$Rank_Cohort_UNICIV)
type <- gsub(".*NIJ LEADS|;.*|,.*", "", all_data$Rank_Cohort_UNICIV)
year <- gsub("[^0-9]", "", all_data$Rank_Cohort_UNICIV)

all_data$Job_Title <- job_titles
all_data$Type <- type
all_data$Year <- as.integer(year)  # Convert to integer if needed


#use stringer package to remove whitespace
#then recode into LEO, Civilian and Academic
all_data <-  all_data %>%  mutate( Type = str_squish(Type),
                                    Type = recode(Type,
                                         "Lieutenant" = "Law Enforcement Officer",
                                         "Sergeant" = "Law Enforcement Officer",
                                         "Scholar" = "Civilian",
                                         "Civilian Scholar" = "Civilian",
                                         "Assistant Professor" = "Academic"))


#Scrape Organization Data from the website

# Function to scrape organization data from a given URL
scrape_organizations <- function(url) {
  webpage <- read_html(url)
  org_data <- webpage %>%
    html_nodes(".field--name-title, .field--name-field-affiliation") %>%
    html_text()

  # Ensure the length of org_data is a multiple of 2
  org_data <- org_data[1:(length(org_data) %/% 2 * 2)]

  # Create a matrix with 2 columns for organization data
  org_matrix <- matrix(org_data, ncol = 2, byrow = TRUE, dimnames = list(NULL, c("Lead_Scholar", "Organization")))

  org_df <- as.data.frame(org_matrix, stringsAsFactors = FALSE)
  return(org_df)
}

# Create an empty data frame to store organization results
all_org_data <- data.frame()

# Set the base URL
base_url <- "https://nij.ojp.gov/funding/leads-scholar-biographies?page="

# Set the number of pages you want to scrape
num_pages <- 5

# Loop through the pages and scrape organization data
for (i in 0:num_pages) {
  url <- paste0(base_url, i, "#biographies-biographies-by-role-1fno2kjmxvggmpkr")
  org_page_data <- scrape_organizations(url)
  all_org_data <- bind_rows(all_org_data, org_page_data)
}


#there is something wrong with 32:50
#Names and Orgs got reversed when scraping for this data
#keep good ones
all_org_data_good <- all_org_data %>%
  slice(-32:-49)

#subset erors
all_org_data_error <- all_org_data %>%
  slice(32:49)

#seperate two seperate columns
lead_nam <- all_org_data_error %>% select(Organization) %>% rename("Lead_Scholar" = Organization)

#Nick did not have the proper org synced up - It had Laurie as the ORG
lead_org <- all_org_data_error %>%
  select(Lead_Scholar) %>%
  rename("Organization" = Lead_Scholar) %>%
  filter(Organization != "Nick Petitti")

#Memphis was missing from the list
# Add the value to the last row of the data frame
lead_org[nrow(lead_org) + 1, "Organization"] <- "Memphis Police Department"

#cbind two columns
all_org_data_error2 <- cbind(lead_nam, lead_org)

#add back to the list that was scraped well
all_org_data_final<- rbind(all_org_data_good, all_org_data_error2)


#Dupliates in both datasets?
all_data <- all_data %>%
  distinct(Lead_Scholar, .keep_all = TRUE)

all_org_data_final <- all_org_data_final %>%
  distinct(Lead_Scholar, .keep_all = TRUE)


#Join them all together
all_data_wOrg<- left_join(all_data, all_org_data_final, by="Lead_Scholar")

#Nick is missing his dept

# Replace missing values in your_column with a specific value, for example, 0
all_data_wOrg$Organization <- ifelse(is.na(all_data_wOrg$Organization), "Rochester, NY", all_data_wOrg$Organization)



all_data_wOrg <- all_data_wOrg %>%
  mutate(Organization = if_else(Lead_Scholar == "Joe Treviño", "New York Police Department", Organization))




