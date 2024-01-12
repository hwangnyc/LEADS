#Extract LEADS Last Name
#Need to create a column that only has last names

# Function to extract last names
extract_last_name <- function(names) {
  # Remove text within quotation marks
  names <- gsub('".*?"', '', names)

  # Remove commas and specific strings like "Ph.D.", "III", "Ed'D", and handle Treviño
  names <- gsub(",|Ph\\.?D\\.?|III|Ed.D.|JD", "", names)

  # Extract last names
  last_names <- gsub(".*\\b(\\w+)(?:\\s+\\w+\\.?|\\s+\\w+)?\\s*$", "\\1", names, perl = TRUE)

  return(last_names)
}
# Apply the function to extract last names
all_data_wOrg2$last_names <- tolower(extract_last_name(all_data_wOrg2$Lead_Scholar))
