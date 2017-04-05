# ATF-FFL: Functions to compute per capita (100,000) totals

#### FFL and population data: load and tidy -----------------------------------

# ffl <- read.csv("data/ffl-2016-perCapita.csv")
# pop <- read.csv("data/01-US-Census/nst-est2016-alldata.csv")

#### remove US, Regions, DC, PR
# pop <- pop[-c(1:5, 14, 57), ]
# pop$NAME <- factor(pop$NAME)
# str(pop)

#### select relevant columns
# ffl <- ffl %>%
#   select(NAME, perCapitaFFL)

# ffl.pop <- pop %>%
#   select(NAME, POPESTIMATE2015, POPESTIMATE2016) %>%
#   left_join(ffl)

#### output FFL per capita data
# write.csv(ffl.pop, file = "data/05-per-capita-clean/per-capita-ffl.csv",
#           row.names = F)

# FFL per capita data ---------------------------------------------------------
# population totals to use in computation 
ffl.pop <- read.csv("data/04-per-capita-clean/per-capita-ffl.csv")

# function to compute per capita 2015 -----------------------------------------
perCapita2015 <- function (x) {
  x <- as.integer(x)
  x <- (x / ffl.pop$POPESTIMATE2015) * 100000
  x
}

# function to compute per capita 2016 -----------------------------------------
perCapita2016 <- function (x) {
  x <- as.integer(x)
  x <- (x / ffl.pop$POPESTIMATE2016) * 100000
  x
}