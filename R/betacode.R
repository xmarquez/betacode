#' Beta Code to Unicode conversion
#'
#' @param beta_text The Beta Code text to be converted to Unicode. Can be a
#'   character vector.
#' @param strict Whether to use strict accent and diacritics order. Default is
#'   `TRUE`.
#'
#' @return A character vector of the same length as `beta_text` with the Unicode
#'   representation of the Beta Code in it. Gives a warning when it encounters
#'   malformed Beta Code.
#' @export
#'
#' @examples
#' betacode_to_unicode("*sidw\\n e)pi\\ qala/tth| po/lis *)assuri/wn")
#' betacode_to_unicode(plato_republic$text[1:4])
#'
#' # Gives a warning when encountering bad Beta Code:
#' betacode_to_unicode(paste("p*l*%a*t*o*n*", plato_republic$text[1]))
#' betacode_to_unicode("fh|\\s")
#'
#' # But sometimes the warning can be avoided by relaxing the matching of
#' # diacritics
#' betacode_to_unicode("fh|\\s", strict = FALSE)
betacode_to_unicode <- function(beta_text, strict = TRUE) {
  if(strict) {
    beta_trie <- triebeard::trie(keys = names(BETACODE_MAP),
                                 values = as.character(BETACODE_MAP))

  } else {
    character_perms <- lapply(stringr::str_split(names(BETACODE_MAP), ""),
                              permute_diacritics)
    lengths <- unlist(lapply(character_perms, length))
    values <- mapply(rep, as.character(BETACODE_MAP), lengths)
    beta_trie <- triebeard::trie(keys = unlist(character_perms),
                                 values = unlist(values))
  }
  beta_text <- stringr::str_split(beta_text, " ", simplify = FALSE)
  reverse_data <- as.data.frame(beta_trie)
  unlist(lapply(beta_text, function(x) bc_to_uc_single(x,
                                                       beta_trie,
                                                       reverse_data)))

}

#' Unicode to Beta Code Conversion
#'
#' This function reverses the work of [betacode_to_unicode], converting Ancient
#' Greek text in Unicode to well-formed Beta Code.
#'
#' @param unicode_text A character vector with Greek Unicode to convert to Beta
#'   Code.
#'
#' @return A character vector with corresponding Beta Code. The function gives a
#'   warning when it encounters characters that cannot be converted to Beta
#'   Code, returning these characters wrapped in brackets.
#'
#' @export
#'
#' @examples
#' unicode_text <- betacode_to_unicode(plato_republic$text[1:2])
#' unicode_text
#' unicode_to_betacode(unicode_text)
#'
#' # The function gives a warning when it encounters non-Unicode Greek
#' # characters, wrapping them in brackets.
#' unicode_to_betacode(paste(unicode_text, "abc"))
unicode_to_betacode <- function(unicode_text) {
  reverse_data <- data.frame(values = names(BETACODE_MAP),
                             keys = as.character(BETACODE_MAP))
  reverse_data <- reverse_data[!duplicated(reverse_data$keys), ]
  reverse_data <- rbind(reverse_data, c(" ", " "))
  reverse_data$values <- stringr::str_replace(reverse_data$values,
                                              "s[12]", "s")
  unicode_text <- stringr::str_split(unicode_text, "")
  unicode_matches <- (reverse_data$values)
  names(unicode_matches) <- reverse_data$keys

  res <- lapply(unicode_text, function(x) uc_to_bc_single(x, unicode_matches))
  unlist(res)

}

uc_to_bc_single <- function(unicode_characters, unicode_matches) {
  matches <- unicode_matches[unicode_characters]

  if(any(is.na(matches))) {
    warning("Some characters were not converted to Beta Code. ",
            "They may not be unicode Greek characters. ",
            "These are wrapped in brackets.")
  }
  matches[which(is.na(matches))] <- stringr::str_c("[",
                                                   unicode_characters[which(is.na(matches))],
                                                   "]")

  matches <- paste(matches, collapse = "")

  matches <- stringr::str_replace_all(matches, "\\]\\[", "")

  stringr::str_replace_all(matches, "\\] \\[", " ")
}

bc_to_uc_single <- function(sentence, beta_trie, reverse_data) {
  res <- ""
  for(word in sentence) {
    orig_word <- word
    while(stringr::str_length(word) > 0) {
      match <- triebeard::longest_match(trie = beta_trie, word)
      if(is.na(match)) {
        res <- stringr::str_glue("{res}[bad Beta Code: {word}]")
        warning(stringr::str_glue("Word `{orig_word}` contains incorrect Beta Code. "),
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

permute_diacritics <- function(beta_string) {
  if(length(beta_string) <= 1) {
    return(beta_string)
  }

  to_permute <- beta_string[2:length(beta_string)]
  res <- gtools::permutations(length(to_permute), length(to_permute),
                              to_permute, repeats.allowed = FALSE)
  res <- apply(res, MARGIN = 1, FUN = function(x) paste0(x, collapse = ""))
  stringr::str_trim(paste0(beta_string[1], res))

}
#' Beta Code for Plato's Republic
#'
#' This is the Beta Code for Plato's Republic, sourced from the [Diorisis
#' ancient Greek
#' corpus](https://figshare.com/articles/dataset/The_Diorisis_Ancient_Greek_Corpus/6187256).
#' The dataframe contains two columns: the `text` column contains each sentence
#' in Beta Code, and the `location` column contains the Stephanus book and page
#' number for the sentence.
#'
#' @source Vatri, A. and B. McGillivray (2018). "The Diorisis ancient Greek
#'   corpus: linguistics and literature." Research Data Journal for the
#'   Humanities and Social Sciences 3(1): 55-65. Available at
#'   https://figshare.com/articles/dataset/The_Diorisis_Ancient_Greek_Corpus/6187256
#'
#'
#'
#'
#'
"plato_republic"
