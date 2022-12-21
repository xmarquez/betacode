#' Betacode to Unicode conversion
#'
#' @param beta_text The text to be converted to Unicode. Can be a character
#'   vector or a list of character vectors.
#'
#' @return A character vector of the same length as `beta_text` with the Unicode
#'   representation of the betacode in it. Gives a warning when it encounters
#'   malformed betacode.
#' @export
#'
#' @examples
#' betacode_to_unicode("*sidw\\n e)pi\\ qala/tth| po/lis *)assuri/wn")
#' betacode_to_unicode(plato_republic$text[1:4])
#'
#' # Gives a warning when encountering bad betacode:
#' betacode_to_unicode(paste("p*l*%a*t*o*n*", plato_republic$text[1]))
betacode_to_unicode <- function(beta_text) {
  beta_trie <- triebeard::trie(keys = names(BETACODE_MAP),
                               values = as.character(BETACODE_MAP))
  beta_text <- stringr::str_split(beta_text, " ", simplify = FALSE)
  reverse_data <- as.data.frame(beta_trie)
  unlist(lapply(beta_text, function(x) bc_to_uc_single(x,
                                                       beta_trie,
                                                       reverse_data)))

}

bc_to_uc_single <- function(sentence, beta_trie, reverse_data) {
  res <- ""
  for(word in sentence) {
    orig_word <- word
    while(stringr::str_length(word) > 0) {
      match <- triebeard::longest_match(trie = beta_trie, word)
      if(is.na(match)) {
        res <- stringr::str_glue("{res}[bad betacode: {word}]")
        warning(stringr::str_glue("Word `{orig_word}` contains incorrect betacode. "),
                stringr::str_glue("Returning `{res}`."))
        word <- ""
        break()
      }
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
