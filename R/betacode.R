#' Betacode to Unicode conversion
#'
#' @param beta_text The text to be converted to Unicode
#'
#' @return A string with the Unicode representation of the betacode
#' @export
#'
#' @examples
#' betacode_to_unicode("*sidw\\n e)pi\\ qala/tth| po/lis *)assuri/wn")
betacode_to_unicode <- function(beta_text) {
  beta_trie <- triebeard::trie(keys = names(BETACODE_MAP),
                               values = as.character(BETACODE_MAP))
  beta_text <- stringr::str_split(beta_text, " ", simplify = TRUE)
  reverse_data <- as.data.frame(beta_trie)
  res <- ""
  for(word in beta_text) {
    while(stringr::str_length(word) > 0) {
      match <- triebeard::longest_match(trie = beta_trie, word)
      prefix <- reverse_data$keys[ reverse_data$values == match]
      word <- stringr::str_remove(word, stringr::fixed(prefix))
      word <- word[ stringr::str_length(word) == min(stringr::str_length(word)) ]
      if(word == "" && "s" %in% prefix) {
        match <- '\u03c2'
      }
      res <- paste0(res, match)

    }
    res <- paste0(res, " ")
  }
  stringr::str_trim(res)

}

#' Betacode for Plato's Republic
#'
#' This is the betacode for Plato's Republic, sourced from the Diorisis ancient
#' Greek corpus. The dataframe contains two columns: the `text` column contains
#' each sentence in betacode, and the `location` column contains the Stephanus
#' book and page number for the sentence.
#'
#' @source Vatri, A. and B. McGillivray (2018). "The Diorisis ancient Greek
#'   corpus: linguistics and literature." Research Data Journal for the
#'   Humanities and Social Sciences 3(1): 55-65. Available at
#'   https://figshare.com/articles/dataset/The_Diorisis_Ancient_Greek_Corpus/6187256
#'
#'
#'
#'
"plato_republic"
