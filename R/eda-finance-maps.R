# EDA - Income
# "Finanacial Characteristics"
# US Census - American Community Survey, table S2503.
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/
# Federal Firearms License data

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)

# dataset containing data by state for:
# - financial characteristics

# custom plot themes and maps
source("~/GitHub/ATF-FFL/R/00-pd-themes.R")
source("~/GitHub/ATF-FFL/R/usa-map-prep.R")

# ACS Financial Characteristics data, FFL data
ffl <- read.csv("data/ffl-per-capita.csv", stringsAsFactors = F)
income <- read.csv("data/04-per-capita-clean/per-capita-finance.csv", stringsAsFactors = F)

rownames(income) <- income$NAME
income$NAME <- NULL

# create long dataframe for facet plots ---------------------------------------

finance.stack <- income %>%
  select(-c(2, 14:16)) %>%
  gather(key = Category, value = PerCapCategory, 2:12)

str(finance.stack)

levels(as.factor(finance.stack$Category))
finance.stack$Category <- factor(finance.stack$Category)

# write.csv(finance.stack, file = "~/GitHub/ATF-FFL/data/2015-ACS-financePerCapita-stack.csv")

# Map of States ~ Median Household Income -------------------------------------

library(maps)
library(mapproj)

# load map data for US
usa <- map_data("state")
colnames(usa) <- c("lon", "lat", "group", "order", "NAME", "subregion")

# capitalize state.name (function from tolower() documentation)
source("~/GitHub/ATF-FFL/R/capwords.R")
usa$NAME <- capwords(usa$NAME)

# bind geo data to finance data
finance.map <- income %>%
  left_join(usa, by = "NAME") %>%
  arrange(group, order)


# ACS-Finance-Map 150k Income bracket -----------------------------------------

# discretize into 20% quantiles
wealthy <- quantile(income$k.150000.or.more, seq(0, 1, 0.2))
wealthy
#       0%      20%      40%      60%      80%     100% 
# 1699.377 2699.526 3154.033 3602.583 5004.089 6972.017

# add discretized to dataframe
income <- income %>%
  mutate(q.150k = cut(income$k.150000.or.more, 
                      breaks = wealthy,
                      labels = c("0-20%", "20-40%", "40-60%", "60-80%", "80-100%"),
                      include.lowest = T))

# merge new variable into map dataframe
perCapitaMap <- left_join(income, fifty_states, by = "NAME") %>%
  arrange(group, order)

# create palette for 20% quantiles
income.pal <- colorRampPalette(c("darkgoldenrod4", "antiquewhite2", "cadetblue4"))(5)

# map
ggplot(perCapitaMap, aes(lon, lat, group = group, 
                        fill = q.150k)) +
  geom_polygon(color = "white", size = 0.2) +
  scale_fill_manual(values = income.pal) +
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.text = element_text(size = 10, hjust = 1, vjust = 1)) +
  guides(fill = guide_legend(reverse = T)) +
  labs(title = "Where are annual household incomes greater than $150,000?", 
       x = "", y = "", fill = "")

# ACS-Finance-Map LessThan5k Income bracket -----------------------------------

summary(finance.map$a.LessThan5000)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   610.4  1040.0  1286.0  1266.0  1435.0  2032.0

# discretize into 20% quantiles
poverty <- quantile(income$a.LessThan5000, seq(0, 1, 0.2))
poverty
#       0%       20%       40%       60%       80%      100% 
# 610.4033 1003.0886 1091.3738 1292.1212 1440.6141 2031.8527

# merge into dataframe, then into map dataframe
income <- income %>%
  mutate(q.Under5k = cut(income$a.LessThan5000,
                         breaks = poverty,
                         labels = c("0-20%", "20-40%", "40-60%", "60-80%", "80-100%"),
                         include.lowest = T))

# merge new variable into map dataframe
perCapitaMap <- left_join(income, fifty_states, by = "NAME") %>%
  arrange(group, order)

# map under 5k locations
ggplot(perCapitaMap, aes(lon, lat, 
                         group = group, 
                         fill = q.Under5k)) +
  geom_polygon(color = "white", size = 0.2) +
  scale_fill_manual(values = income.pal) +
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.text = element_text(size = 10, hjust = 1, vjust = 1)) +
  guides(fill = guide_legend(reverse = T)) +
  labs(title = "Where are annual household incomes less than $5,000?", 
       x = "", y = "", fill = "")


# ACS-Finance-Map 50-75k ------------------------------------------------------
summary(finance.map$h.50000to74999)

# discretize
middle <- quantile(income$h.50000to74999, seq(0, 1, 0.2))
middle
#       0%      20%      40%      60%      80%     100% 
# 5423.925 6206.348 6812.213 7045.879 7341.262 8149.848

# merge into dataframe, then into map dataframe
income <- income %>%
  mutate(q.50to75k = cut(income$h.50000to74999,
                         breaks = middle,
                         labels = c("0-20%", "20-40%", "40-60%", "60-80%", "80-100%"),
                         include.lowest = T))

# merge new variable into map dataframe
perCapitaMap <- left_join(income, fifty_states, by = "NAME") %>%
  arrange(group, order)

ggplot(perCapitaMap, aes(lon, lat, group = group, 
                        fill = q.50to75k)) +
  geom_polygon(color = "white", size = 0.2) +
  scale_fill_manual(values = income.pal) +
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.text = element_text(size = 10, hjust = 1, vjust = 1)) +
  guides(fill = guide_legend(reverse = T)) +
  labs(title = "Where are annual household incomes between $50,000 and $74,999?", 
       x = "", y = "", fill = "")

# ACS-Finance-Map 35 to 50k ---------------------------------------------------
summary(finance.map$g.35000to49999)

# discretize
middle.02 <- quantile(income$g.35000to49999, seq(0, 1, 0.2))
middle.02
#      0%      20%      40%      60%      80%     100% 
# 3410.642 4595.835 5041.910 5413.748 5630.990 6223.992

# merge into dataframe
income <- income %>%
  mutate(q.35to50k = cut(income$g.35000to49999,
                         breaks = middle.02,
                         labels = c("0-20%", "20-40%", "40-60%", "60-80%", "80-100%"),
                         include.lowest = T))

# merge new variable into map dataframe
perCapitaMap <- left_join(income, fifty_states, by = "NAME") %>%
  arrange(group, order)

ggplot(perCapitaMap, aes(lon, lat, 
                         group = group, 
                         fill = q.35to50k)) +
  geom_polygon(color = "white", size = 0.2) +
  scale_fill_manual(values = income.pal) +
  coord_map("polyconic") + 
  pd.theme +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.text = element_text(size = 10, hjust = 1, vjust = 1)) +
  guides(fill = guide_legend(reverse = T)) +
  labs(title = "Where are annual household incomes between $35,000 and $49,999?", 
       x = "", y = "", fill = "")


# Facet Plot all Income Brackets ~ FFLs ---------------------------------------
finance.stack %>% group_by(Category) %>%
  filter(Category != "Occupied Housing Units" & 
           Category != "Median Household Income") %>%
  ggplot(aes(PerCapCategory, perCapitaFFL, label = NAME)) +
  geom_point(size = 1, alpha = 0.65) +
  geom_text(size = 2.25, position = "jitter", 
            alpha = 0.75, hjust = 1, vjust = 1,
            check_overlap = T, family = "GillSans") +
  facet_wrap(~ Category, scales = "free_x") + pd.theme +
  theme(strip.background = element_rect(fill = NA, color = "black"),
        panel.background = element_rect(fill = NA, color = "black"),
        axis.text = element_text(size = 9),
        axis.title = element_text(size = 10)) +
  labs(title = "FFLs ~ Financial Category, per 100k",
       x = "income bracket per capita", y = "FFLs per capita")

# It almost appears as if there's a weak, but positive linear trend 
# as the household income approaches the median. 


