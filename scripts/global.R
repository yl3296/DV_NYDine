'__author__' ='Yang Liu(yl3296)'


library(tm)
library(wordcloud)
library(memoise)

# The list of valid books
books <<- list("1Star" = "newt1",
               "2Star" = "newt2",
               "3Star" = "newt3",
               "4Star" = "newt4",
               "5Star" = "newt5")

# Using "memoise" to automatically cache the results
getTermMatrix <- memoise(function(book) {
  # Careful not to let just any name slip in here; a
  # malicious user could manipulate this value.
if (!(book %in% books))
    stop("Unknown book")
  
  a = read.table(sprintf("./%s.txt", book))
  idx = a$word
  a = a[,2]
  names(a) = idx
  sqrt(a)
  
  
})
