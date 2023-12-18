library(googlesheets4)
#Writing data to google sheets
# Assuming your dataframe is named all_data
# Replace "YOUR_GOOGLE_SHEET_URL" with the actual URL of your Google Sheets document
gs4_deauth()

# Authenticate with your Google account (you will be prompted to log in)
gs4_auth()

sheet_id <- "SEE Henry"

write_sheet(all_data_wOrg, ss = sheet_id, sheet = "Sheet1")
