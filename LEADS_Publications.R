install.packages("rcrossref")
library(rcrossref)

# Function to search for publications by author
get_publications_by_author <- function(author_name) {
  query <- paste0("author:", author_name)
  cr_results <- cr_works(query = query)
  return(cr_results$data)
}

# Example usage
author_name <- "Henry Wang"
publications <- get_publications_by_author(author_name)
print(publications)
