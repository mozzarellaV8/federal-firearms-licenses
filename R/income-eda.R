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

summary(finance.map$MedianHouseholdIncome)

# ACS-Finance-Map Median Household Income
ggplot(finance.map, aes(lon, lat, group = group, 
                        fill = MedianHouseholdIncome)) +
  geom_polygon(color = "gray92", size = 0.075) +
  scale_fill_gradient2(low = "darkgoldenrod",
                       mid = "antiquewhite2",
                       high = "cadetblue4", 
                       midpoint = 54440) +
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.text = element_text(size = 10, hjust = 1, vjust = 1)) +
  labs(title = "Median Household Income ~ State", 
       x = "", y = "", fill = "USD")

summary(finance.map$k.150000.or.more)

# ACS-Finance-Map 150k Income bracket
ggplot(finance.map, aes(lon, lat, group = group, 
                        fill = k.150000.or.more)) +
  geom_polygon(color = "gray92", size = 0.075) +
  scale_fill_gradient2(low = "darkgoldenrod",
                       mid = "antiquewhite2",
                       high = "cadetblue4", 
                       midpoint = 3177) +
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.text = element_text(size = 10, hjust = 1, vjust = 1)) +
  labs(title = "Household Incomes > $150,000", 
       x = "", y = "", fill = "number of\nhouseholds\nper 100k")

# ACS-Finance-Map LessThan5k Income bracket
summary(finance.map$a.LessThan5000)

ggplot(finance.map, aes(lon, lat, group = group, 
                        fill = a.LessThan5000)) +
  geom_polygon(color = "gray92", size = 0.075) +
  scale_fill_gradient2(low = "darkgoldenrod",
                       mid = "antiquewhite2",
                       high = "cadetblue4", 
                       midpoint = 1286.0) +
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.text = element_text(size = 10, hjust = 1, vjust = 1)) +
  labs(title = "Household Incomes < $5,000", 
       x = "", y = "", fill = "number of\nhouseholds\nper 100k")

# ACS-Finance-Map 35-50k
summary(finance.map$g.35000to49999)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   3411    4637    5283    5105    5602    6224

ggplot(finance.map, aes(lon, lat, group = group, 
                        fill = g.35000to49999)) +
  geom_polygon(color = "gray92", size = 0.075) +
  scale_fill_gradient2(low = "darkgoldenrod",
                       mid = "antiquewhite2",
                       high = "cadetblue4", 
                       midpoint = 5283) +
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.text = element_text(size = 10, hjust = 1, vjust = 1)) +
  labs(title = "Household Incomes $35,000-49,999", 
       x = "", y = "", fill = "number of\nhouseholds\nper 100k")

# ACS-Finance-Map upper.median
summary(finance.map$h.50000to74999)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   5424    6212    6820    6798    7275    8150

ggplot(finance.map, aes(lon, lat, group = group, 
                        fill = h.50000to74999)) +
  geom_polygon(color = "gray92", size = 0.075) +
  scale_fill_gradient2(low = "darkgoldenrod",
                       mid = "antiquewhite2",
                       high = "cadetblue4", 
                       midpoint = 6820) +
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.text = element_text(size = 10, hjust = 1, vjust = 1)) +
  labs(title = "Household Incomes $50,000-74,999", 
       x = "", y = "", fill = "number of\nhouseholds\nper 100k")


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


