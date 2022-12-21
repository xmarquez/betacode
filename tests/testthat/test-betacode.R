test_that("Incorrect betacode gives a warning", {
  expect_warning(betacode_to_unicode(paste("p*l*%a*t*o*n*", plato_republic$text[1])))
})

test_that("Produces correct Unicode", {
  expect_equal(betacode_to_unicode("*sidw\\n e)pi\\ qala/tth| po/lis *)assuri/wn"),
               "Σιδὼν ἐπὶ θαλάττῃ πόλις Ἀσσυρίων")
})

test_that("Returns character vector of unicode vectors", {
  expect_equal(length(betacode_to_unicode(plato_republic$text[1:10])),
               10)
})
