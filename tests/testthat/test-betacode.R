test_that("Incorrect betacode gives a warning", {
  expect_warning(betacode_to_unicode(paste("p*l*%a*t*o*n*", plato_republic$text[1])))
  expect_warning(betacode_to_unicode("fh|\\s"))
  expect_no_warning(betacode_to_unicode("fh|\\s", strict = FALSE))
})

test_that("Produces correct Unicode", {
  expect_equal(betacode_to_unicode("*sidw\\n e)pi\\ qala/tth| po/lis *)assuri/wn"),
               "Σιδὼν ἐπὶ θαλάττῃ πόλις Ἀσσυρίων")
})

test_that("Returns character vector of unicode vectors", {
  expect_equal(length(betacode_to_unicode(plato_republic$text[1:10])),
               10)
})

test_that("Returns character vector of unicode vectors", {
  expect_equal(length(betacode_to_unicode(plato_republic$text[1:10])),
               10)
})

test_that("Incorrect unicode gives a warning", {
  expect_warning(unicode_to_betacode(paste("PLATON", plato_republic$text[1])))
})

test_that("Produces correct betacode", {
  expect_equal(unicode_to_betacode("Σιδὼν ἐπὶ θαλάττῃ πόλις Ἀσσυρίων"),
               "*sidw\\n e)pi\\ qala/tth| po/lis *)assuri/wn")
})
