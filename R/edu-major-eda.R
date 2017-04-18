# ATF - FFL
# US Census - American Community Survey - Table 1502
# "FIELD OF BACHELOR'S DEGREE FOR FIRST MAJOR"
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/ 

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)
library(grDevices)

# custom plot themes
source("R/00-pd-themes.R")
source("R/00-usa-map-prep.R")

# per capita bachelor's degree data
major <- read.csv("data/04-per-capita-clean/per-capita-major-major.csv", stringsAsFactors = F)

# drop 2016 population data
major <- major %>%
  select(-POPESTIMATE2016)

# 50 obs of 21 variables
str(major)
summary(major)

# Map 01: BA major by State --------------------------------------------------

# Map Preparation:
# merge USA map data with FFL data
perCapitaMap <- left_join(major, fifty_states, by = "NAME") %>%
  arrange(group, order)


# for gradient fill midpoint
summary(major$total.BA)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   13600   17600   19450   20120   22360   28770 


# map per capita Bachelor's degreees
ggplot(perCapitaMap, aes(lon, lat, 
                         group = group,
                         fill = total.BA)) +
  geom_polygon(color = "white", size = 0.1) +
  scale_fill_gradient2(high = "deepskyblue4",
                       mid = "antiquewhite1",
                       low = "coral4", 
                       midpoint = 19450) +
  coord_map("polyconic") + pd.theme +
  theme(panel.border = element_rect(linetype = "solid", 
                                    fill = NA, 
                                    color = "white"),
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 10, hjust = 1, vjust = 1),
        legend.position = "right") +
  labs(title = "Bachelor's Degrees per 100,000")


# facet plot of the majors ----------------------------------------------------

major %>%
  select(1:7, 21) %>%
  gather(key = field, value = n, 2:7) %>%
  filter(field != "total.BA" & field != "Science.Engineering.related") %>%
  ggplot(aes(NAME, n, fill = n)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient2(high = "deepskyblue4",
                       mid = "antiquewhite2",
                       low = "firebrick4", 
                       midpoint = 5000, 
                       guide = F) +
  facet_grid(field ~ .) +
  pd.facet +
  theme(axis.text.x = element_text(angle = 45, size = 12,
                                   hjust = 1, vjust = 1),
        axis.text.y = element_text(size = 10)) +
  labs(x = "", y = "")


# Exploratory linear model ----------------------------------------------------

library(broom)

major.total <- major %>%
  select(-contains("male"), -contains("female"), -POPESTIMATE2015)

m1 <- lm(perCapitaFFL ~ .-NAME, data = major.total)
summary(m1)

tidy(m1) %>% arrange(p.value) %>% filter(term != "(Intercept)")
#                          term     estimate   std.error statistic      p.value
# 1                   Education  0.038130638 0.006268787  6.082618 2.551416e-07
# 2     Science.and.Engineering  0.020499076 0.006367654  3.219251 2.416285e-03
# 3                    total.BA -0.011197904 0.003971607 -2.819490 7.184586e-03
# 4                    Business -0.008159489 0.004415105 -1.848085 7.131843e-02
# 5 Science.Engineering.related  0.002716693 0.011543839  0.235337 8.150391e-01

glance(m1)
confint(m1)


ggplot(major.total, aes(Education, perCapitaFFL, 
                        label = NAME,
                        fill = perCapitaFFL)) +
  geom_point(size = 3, shape = 21, color = "white") +
  geom_text(aes(Education, perCapitaFFL, label = NAME),
            check_overlap = T, 
            hjust = 1.05, vjust = 1.1,
            size = 3.2) +
  geom_smooth(method = "lm", se = F,
              color = "cadetblue3",
              linetype = "dashed",
              size = 0.5) +
  scale_fill_gradient2(high = "deepskyblue4",
                       mid = "antiquewhite2",
                       low = "firebrick4", 
                       midpoint = 52, 
                       guide = F) +
  expand_limits(x = c(1350, 4000)) +
  pd.scatter +
  labs(x = "per capita BAs: Education")






