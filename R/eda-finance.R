# Regression Trees - Income
# "Finanacial Characteristics"
# US Census - American Community Survey, table S2503.
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/
# Federal Firearms License data

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(broom)
library(rpart)
library(rpart.plot)
library(tree)
library(ggplot2)

# load themes and functions
source("~/GitHub/ATF-FFL/R/00-pd-themes.R")

# load and bind all per capita data -------------------------------------------

# Finance

# read in individual CSVs
ffl <- read.csv("data/ffl-per-capita.csv", stringsAsFactors = F)
income <- read.csv("data/04-per-capita-clean/per-capita-finance.csv", stringsAsFactors = F)
str(income)

# remove total occupied housing, 
# median household income, 
# and populations variables
# 50 observations of 13 variables
income <- income %>%
  select(1, 3:13, 17)

# Faceted plot of FFL ~ Income Bracket ----------------------------------------

# create long dataframe for facets
income.long <- income %>%
  gather(key = category, value = perCapitaPop, 2:12)


income.long$category <- factor(income.long$category)
levels(income.long$category)
str(income.long)

# facet scatter of all brackets
income.long %>%
  ggplot(aes(perCapitaPop, 
             perCapitaFFL, 
             label = NAME)) +
  geom_smooth(method = "lm", se = F,
              color = "red3",
              linetype = "dashed",
              size = 0.65) +
  geom_point() +
  facet_wrap(~ category, 
             scales = "free_x",
             ncol = 3) +
  pd.facet +
  theme(axis.text = element_text(size = 10.5),
        strip.text = element_text(size = 10),
        panel.grid.major = element_line(color = "gray98"),
        panel.grid.minor = element_line(color = "gray96")) +
  labs(x = "per capita population ~ annual household income",
       y = "per capita firearms licenses")

## At the extremes of poverty and wealth, FFLs appear to follow a negative trend
# as those populations increase. FFLs show a postive, gradually growing trend moving 
# from lower to higher income - appearing to most firmly positive around (g) and (h).

# Naturally the population at extremes will not be as high as towards center.
# Interestingly, the trend line plateaus only once, at the entry level 6-figure bracket.

# Facets - Extremes -----------------------------------------------------------

# Poverty and Wealth
income.long %>%
  filter(category == "a.LessThan5000" | category == "k.150000.or.more") %>%
  ggplot(aes(perCapitaPop, 
             perCapitaFFL, 
             label = NAME)) +
  geom_smooth(method = "lm", se = F,
              color = "red3",
              linetype = "dashed",
              size = 0.65) +
  geom_point(size = 0.75) +
  geom_text(aes(perCapitaPop,
                perCapitaFFL,
                label = NAME),
            hjust = -0.07, vjust = 1,
            size = 2.75, 
            check_overlap = T) +
  facet_wrap(~ category, 
             scales = "free_x", 
             ncol = 1) +
  expand_limits(x = c(0, 7400), y = 0) +
  pd.facet +
  theme(axis.text = element_text(size = 10.5),
        strip.text = element_text(size = 11),
        panel.grid.major = element_line(color = "gray94"),
        panel.grid.minor = element_line(color = "gray94")) +
  labs(x = "per capita population ~ annual household income",
       y = "per capita firearms licenses")

# Facets - Nulls --------------------------------------------------------------

# Poverty and Wealth
income.long %>%
  filter(category == "b.5000to9999" | category == "j.100000to149999") %>%
  ggplot(aes(perCapitaPop, 
             perCapitaFFL, 
             label = NAME)) +
  geom_smooth(method = "lm", se = F,
              color = "red3",
              linetype = "dashed",
              size = 0.5) +
  geom_point(size = 0.75) +
  geom_text(aes(perCapitaPop,
                perCapitaFFL,
                label = NAME),
            hjust = -0.06, vjust = 1,
            size = 3, 
            check_overlap = T) +
  facet_wrap(~ category, 
             scales = "free_x", 
             ncol = 1) +
  pd.facet +
  theme(axis.text = element_text(size = 10.5),
        strip.text = element_text(size = 11),
        panel.grid.major = element_line(color = "gray94"),
        panel.grid.minor = element_line(color = "gray94")) +
  labs(x = "per capita population ~ annual household income",
       y = "per capita firearms licenses")

# Outliers Wyoming and Alaska: low per capita poverty, high per capita wealth.

# Facets - Trending Up --------------------------------------------------------

levels(income.long$category)

# Trending Up - Middle Class
income.long %>%
  filter(category == "d.15000to19999" | category == "e.20000to24999" 
         | category == "f.25000to34999" | category == "g.35000to49999" 
         | category ==  "h.50000to74999" | category == "i.75000to99999") %>%
  ggplot(aes(perCapitaPop, perCapitaFFL, label = NAME)) +
  geom_smooth(method = "lm", se = F,
              color = "red3",
              linetype = "dashed",
              size = 0.5) +
  geom_point(size = 0.75) +
  geom_text(aes(perCapitaPop,
                perCapitaFFL,
                label = NAME),
            hjust = -0.06, vjust = 1,
            size = 2.5, 
            check_overlap = T) +
  facet_wrap(~ category, 
             scales = "free_x", 
             ncol = 2) +
  pd.facet +
  theme(axis.text = element_text(size = 10.5),
        strip.text = element_text(size = 11),
        panel.grid.major = element_line(color = "gray94"),
        panel.grid.minor = element_line(color = "gray94")) +
  labs(x = "per capita population ~ annual household income",
       y = "per capita firearms licenses",
       title = "positive FFL trends across annual income categories")


# Facets - Trending Up --------------------------------------------------------

income.long %>%
  filter(category == "g.35000to49999" | category ==  "h.50000to74999") %>%
  ggplot(aes(perCapitaPop, perCapitaFFL, label = NAME)) +
  geom_smooth(method = "lm", se = F,
              color = "red3",
              linetype = "dashed",
              size = 0.5) +
  geom_point(size = 0.75) +
  geom_text(aes(perCapitaPop,
                perCapitaFFL,
                label = NAME),
            hjust = -0.06, vjust = 1,
            size = 2.95, 
            check_overlap = T) +
  facet_wrap(~ category, 
             scales = "free_x", 
             ncol = 1) +
  pd.facet +
  theme(axis.text = element_text(size = 10.5),
        strip.text = element_text(size = 11),
        panel.grid.major = element_line(color = "gray94"),
        panel.grid.minor = element_line(color = "gray94")) +
  labs(x = "per capita population ~ annual household income",
       y = "per capita firearms licenses",
       title = "positive FFL trends across annual income categories")

