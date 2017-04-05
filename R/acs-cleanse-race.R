# ATF - FFL
# US Census Electoral Profile Data
# http://www.census.gov/data/tables/time-series/demo/voting-and-registration/electorate-profiles-2016.html
# 2014: http://www.census.gov/data/tables/time-series/demo/voting-and-registration/p20-577.html
# 2012: http://www.census.gov/data/tables/2012/demo/voting-and-registration/p20-568.html

# "Selected Characteristics of the Citizen, 18 years and older"
# .xls file with cumulative US estimates on electorate by race

# Totals are reported in thousands

# "Voting and Registration in the Election of November 2014"
# two .xls files:
# of note is "table04b.xls", which contains:
# "Reported Voting and Registration by Sex, Race and Hispanic Origin, for States: November 2014 [<1.0 MB]"

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)
library(corrplot)
library(zoo)

race <- read.csv("data/01-US-Census/2014-electorate/2014-table4b-race.csv")
str(race)

# Race: Basic Tidying ---------------------------------------------------------

# convert blank to NA; carry last observation forward
race$State[race$State == ""] <- NA
race$State <- na.locf(race$State)

# remove commas - columns 3:5, 10
# replace dashes with zero
# replace '(B)' with NA
race <- as.data.frame(apply(race, 2, function(x) gsub(",", "", x)))
race <- as.data.frame(apply(race, 2, function(x) gsub("-", 0, x)))
race <- as.data.frame(apply(race, 2, function(x) gsub("\\(B\\)", NA, x)))

# rename column and levels of race.and.Hispanic.origin
colnames(race)[2] <- "Race"
levels(race$Race)[levels(race$Race) == ".White non0Hispanic alone"] <- "White non-Hispanic alone"
race$Race <- factor(race$Race)
levels(race$Race)

# rename 'Margin of Error' variables to void confusion
colnames(race)[c(7, 9, 12, 14)] <- c("MarginError1", "MarginError2", "MarginError3", "MarginError4")

# rename levels of race
levels(race$Race)[1:11]
levels(race$Race)[1:11] <- c("White.NonHispanic", "Asian", "Asian.combination", "Black", "Black.combination",
                             "Female", "Hispanic", "Male", "Total", "White", "White.combination")
race$Race <- factor(race$Race)
levels(race$Race)

# Race: Reshape dataframe -----------------------------------------------------
# spread Race observations into variables
race.voting <- race %>%
  select(State, Race, Total.voted) %>%
  spread(key = Race, value = Total.voted)

# percentage by race is of total population of race, not total population
race.voting.pct <- race %>%
  select(State, Race, Percent.voted..Total.) %>%
  spread(key = Race, value = Percent.voted..Total.)

# chck the math
239874*1000
# 239,874,000 accounts for 239.8 million for total US population.

# state populations by race
race.population <- race %>%
  select(State, Race, Total.Population) %>%
  spread(key = Race, value = Total.Population, fill = 0)

# reorder columns
race.population <- race.population[, c(1, 8, 6, 9, 2, 3, 4, 5, 7, 10:12)]

# populations are reported in thousands
# calculate totals, so per capita 100k can be calculated

# Cleanse: Race - compute actual totals ---------------------------------------

# Populations are reported in thousands.
# Calculate actual totals, so per capita 100k can be derived.

# Race - Multiplier Function 
# function to multiply by 1000
one.k <- function (x) {
  x <- x * 1000
  x
}

# convert all variables to integer
for (i in 2:ncol(race.population)) {
  race.population[, i] <- as.integer(race.population[, i])
}

# apply `one.k` function to all variables but state name
race.pop <- race.population %>%
  mutate_each(funs(one.k), 2:12)

# remove Total US and DC
race.pop <- race.pop[-c(9, 45), ]

# output csv of totals
write.csv(race.pop, file = "data/04-total-data-clean/us-census-race.csv", row.names = F)

# Race: Per Capita Values -----------------------------------------------------

# Race - Per Capita Function
# compute per capita racial population by state
# function to calculate per capita totals
perCapita.race <- function (x) {
  x <- (x / race.pop$Total) * 100000
  x
}

# test `perCapita.race` function on first value
perCapita.race(race.pop$Asian)[1]                   # [1] 131597.2
((race.pop$Asian / race.pop$Total) * 100000)[1]     # [1] 131597.2

# apply `perCapita.race` function to all variables but state name
race.perCapita <- race.pop %>%
  mutate_each(funs(perCapita.race), 2:12)

write.csv(race.perCapita, file = "data/05-per-capita-clean/per-capita-race.csv", row.names = F)