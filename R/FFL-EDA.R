# ATF - Federal Firearms Licenses
# Exploratory Data Analysis
# Firearm Licenses and Population by State

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)
library(maps)
library(mapproj)

# data: Census Population and License Counts
perCap16 <- read.csv("~/Documents/ATF-FFL/data/ffl-2016-perCapita.csv")
str(perCap16)

# load custom theme and map data
source("~/GitHub/ATF-FFL/R/00-pd-themes.R")
source("~/GitHub/ATF-FFL/R/usa-map-prep.R")

# Map Preparation --------------------------------------------------------------

# merge USA map data with FFL data
perCapitaMap <- left_join(perCap16, fifty_states, by = "NAME")

# Map with Per Capita FFL data
# reorder group and order variables from `usa` data
perCapitaMap <- perCapitaMap %>%
  arrange(group, order)

# Map 01: FFL per cap, default color fill -------------------------------------
ggplot(perCapitaMap, aes(lon, lat, group = group, fill = perCapitaFFL)) +
  geom_polygon(color = "black") +
  coord_map("polyconic")

# Bar Plot FFLs by state with FFLs mapped to color ----------------------------

summary(perCapitaMap$perCapitaFFL)
#  Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 3.687  16.500  22.720  26.360  31.840 104.700

perCap16 %>%
  arrange(desc(perCapitaFFL)) %>%
  ggplot(aes(reorder(NAME, desc(perCapitaFFL)), perCapitaFFL, fill = perCapitaFFL)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite1",
                       high = "coral4", midpoint = 52, guide = F) +
  pd.theme +
  theme(axis.text.x = element_text(angle = 45, size = 9.5, hjust = 1, vjust = 1,
                                   lineheight = 1.5)) +
  labs(title = "2016: Federal Firearms Licenses ~ State", x = "", y = "", fill = "")

# Bar Plot FFLs by state with population mapped to color ----------------------

perCap16 %>% 
  mutate(perCapPop = POPESTIMATE2016/100000) %>%
  arrange(desc(perCapPop)) %>%
  ggplot(aes(reorder(NAME, perCapitaFFL), perCapitaFFL, fill = perCapPop)) +
  geom_bar(stat = "identity") + 
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite3",
                       high = "coral4", midpoint = 200) +
  scale_y_discrete(limits = c(0, 10, 25, 50, 75, 100, 125)) +
  labs(title = "2016: Federal Firearms Licenses by State (per 100,000 residents)",
       x = "", y = "number of licenses per 100k residents", fill = "") +
  pd.theme + 
  theme(legend.position = "right",
        panel.background = element_blank()) +
  coord_flip()

# Map 02 : FFL Per 100k -------------------------------------------------------

ggplot(perCapitaMap, aes(lon, lat, group = group, fill = perCapitaFFL)) +
  geom_polygon() +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite1",
                       high = "coral4", midpoint = 52) +
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right",
        panel.border = element_rect(linetype = "solid", 
                                    fill = NA, 
                                    color = "white"),
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 12, hjust = 1, vjust = 1)) +
  labs(title = "2016: Federal Firearms Licenses ~ State (per 100k residents)", 
       x = "", y = "", fill = "")

# Map 03: Raw population data, divergent color fill ----------------------------

summary(perCapitaMap$POPESTIMATE2016)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#   585500  4093000  6651000  9828000 10310000 39250000

# bar plot of population by state ---------------------------------------------
perCap16 %>%
  arrange(desc(POPESTIMATE2016)) %>%
  ggplot(aes(reorder(NAME, desc(POPESTIMATE2016)), POPESTIMATE2016, fill = POPESTIMATE2016)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite1",
                       high = "coral4", midpoint = 19625000, guide = F) +
  pd.theme +
  theme(axis.text.x = element_text(angle = 45, size = 9.5, hjust = 1, vjust = 1,
                                   lineheight = 1.5)) +
  labs(title = "2016: US Census Population ~ State", x = "", y = "", fill = "")

# map of population by state --------------------------------------------------
ggplot(perCapitaMap, aes(lon, lat, group = group, fill = POPESTIMATE2016)) +
  geom_polygon() +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite1",
                       high = "coral4", midpoint = 19625000) +
  coord_map("polyconic") + pd.theme +
  theme(panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.title = element_text(size = 12)) +
  labs(title = "2016: US Census Population ~ State", 
       x = "", y = "", fill = "population")

# Could there be an inverse relationship between 
# a given state's population and Federal Firearms Licenses? 

# FFL per 100k by state -------------------------------------------------------

# Are there more FFLs in certain states than others? 
# And what factors might influence why there would or wouldnt be more?

summary(perCap16$POPESTIMATE2016)
#    Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 585500  1850000  4559000  6449000  7199000 39250000

perCap16 <- perCap16 %>%
  mutate(perCapPop = POPESTIMATE2016 / 100000)

summary(perCap16$perCapPop)
#     Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   5.855  18.500  45.590  64.490  71.990 392.500 

# Pattern? : FFLs by Population -----------------------------------------------

# create a new dataframe with only FFLs and population
ffl.pop <- perCap16 %>%
  select(NAME, POPESTIMATE2016, LicCount, LicCountMonthly, perCapitaFFL) %>%
  mutate(pop100k = POPESTIMATE2016/100000)

# assign state names as row names
rownames(ffl.pop) <- ffl.pop$NAME
ffl.pop$NAME <- NULL

# by raw counts
ggplot(ffl.pop, aes(LicCountMonthly, POPESTIMATE2016, 
                    label = rownames(ffl.pop))) +
  geom_text(size = 3, position = "jitter", 
            hjust = 1, vjust = 1,
            check_overlap = T,
            alpha = 0.75)

# The raw counts for FFLs can be misleading - 
# more populated states should naturally have more FFLs.
# Use normalized, per capita counts to plot instead.

# per 100k
ggplot(ffl.pop, aes(perCapitaFFL, pop100k, 
                    label = rownames(ffl.pop))) +
  geom_text(size = 3.5, alpha = 0.95, 
            hjust = -0.1, vjust = 1, 
            check_overlap = T, 
            family = "GillSans") +
  geom_point(aes(perCapitaFFL, pop100k), 
             size = 0.75, data = ffl.pop,
             alpha = 0.25) +
  geom_smooth(method = "lm", se = F, linetype = "dashed", 
              color = "red3", size = 0.5) +
  pd.scatter + expand_limits(x = c(-5, 120)) +
  labs(x = "Federal Firearms Licenses per 100k", y = "population / 100k")

# FFL ~ Population w/log scales  
ggplot(ffl.pop, aes(perCapitaFFL, pop100k, label = rownames(ffl.pop))) +
  geom_text(size = 3.75, alpha = 0.95, hjust = -0.05, vjust = 1, 
            check_overlap = T, family = "GillSans") +
  geom_point(aes(perCapitaFFL, pop100k), size = 0.75, 
             data = ffl.pop, alpha = 0.25) +
  geom_smooth(method = "lm", se = F, linetype = "dashed", 
              color = "red3", size = 0.5) +
  scale_x_log10() + 
  scale_y_log10() + 
  expand_limits(x = c(0, 120)) +
  pd.scatter +
  labs(x = "log(Federal Firearms Licenses per 100k)", y = "log(population / 100k)")

# holy shit it does look inversely proportional

# Exploratory Models ----------------------------------------------------------

library(broom)

# model 01:  on raw counts ----------------------------------------------------
pop.model.01 <- lm(LicCountMonthly ~ POPESTIMATE2016, data = ffl.pop)

# check metrics
summary(pop.model.01)
tidy(pop.model.01)
#              term     estimate    std.error statistic      p.value
# 1     (Intercept) 6.422972e+02 1.305428e+02  4.920203 1.057363e-05
# 2 POPESTIMATE2016 1.057498e-04 1.350694e-05  7.829293 3.991996e-10

# a strong p-value, but using raw population counts again is problematic.

# create dataframe with fitted values and metrics
pm01.fitted <- augment(pop.model.01)

# plot population ~ fitted values
ggplot(pm01.fitted, aes(POPESTIMATE2016, .fitted, label = .rownames)) +
  geom_line(linetype = "dashed", color = "red3") +
  geom_text(aes(POPESTIMATE2016, LicCountMonthly), size = 2.75,
            hjust = 1, vjust = 1, check_overlap = T) +
  geom_point(aes(y = LicCountMonthly), color = "black", 
             alpha = 0.25, data = pm01.fitted) +
  expand_limits(x = c(-2000000, 4000000)) +
  pd.scatter +
  scale_x_log10() +
  labs(x = "(log) 2016 population", y = "fitted FFL count ~ population",
       title = "Raw Counts: Monthly Licenses by State Population")

# model 02: on per capita -----------------------------------------------------

# fit linear model
pm02 <- lm(perCapitaFFL ~ pop100k, data = ffl.pop)
summary(pm02)
tidy(pm02)
#          term   estimate std.error statistic      p.value
# 1 (Intercept) 39.7032073 3.7101985 10.701100 2.629924e-14
# 2     pop100k -0.1323375 0.0383885 -3.447322 1.187279e-03

# create dataframe with fitted values and metrics
pm02.fitted <- augment(pm02)

# plot per capita population ~ fitted values
ggplot(pm02.fitted, aes(pop100k, .fitted, label = .rownames)) +
  geom_line(linetype = "dashed", color = "red3") +
  geom_text(aes(pop100k, perCapitaFFL), size = 3,
            hjust = 1.1, vjust = 1.1, check_overlap = T) +
  geom_point(aes(y = perCapitaFFL), color = "black", 
             alpha = 0.25, data = pm02.fitted) +
  expand_limits(x = c(-25, 425), y = c(0, 110)) +
  pd.scatter +
  labs(x = "2016 population", y = "FFL rate per 100k",
       title = "Per Capita FFL Counts: Monthly Licenses by State Population")

# plot per capita population ~ fitted values on log scale
ggplot(pm02.fitted, aes(pop100k, .fitted, label = .rownames)) +
  geom_line(linetype = "dashed", color = "red3") +
  geom_text(aes(pop100k, perCapitaFFL), size = 3,
            hjust = 1, vjust = 1, check_overlap = T) +
  geom_point(aes(y = perCapitaFFL), color = "black", 
             alpha = 0.25, data = pm02.fitted) +
  scale_x_log10() + scale_y_log10() +
  expand_limits(x = c(log(1), log(200))) +
  pd.scatter +
  labs(x = "(log) 2016 population", y = "FFL rate per 100k",
       title = "Per Capita FFL Counts: Monthly Licenses by State Population (log scale)")

# It appears in both models that an FFL count commensurate to population
# leads to high residuals in the outliers.

# on log transformed per capita
pm03 <- lm(perCapitaFFL ~ log10(POPESTIMATE2016), data = ffl.pop)
summary(pm03)
tidy(pm03)

pm03.fitted <- augment(pm03)
tidy(pm03)
#                     term  estimate std.error statistic      p.value
# 1            (Intercept) 238.39108 35.493797  6.716415 2.001968e-08
# 2 log10(POPESTIMATE2016) -31.40694  5.367612 -5.851194 4.228007e-07

# the p.value improves tremendously.

ggplot(pm03.fitted, aes(log10.POPESTIMATE2016., .fitted, label = .rownames)) +
  geom_line(linetype = "dashed", color = "red3") +
  geom_text(aes(log10.POPESTIMATE2016., perCapitaFFL), size = 3,
            hjust = -0.1, vjust = 1.1, check_overlap = T) +
  geom_point(aes(y = perCapitaFFL), color = "black", 
             alpha = 0.25, data = pm03.fitted) +
  pd.scatter + scale_x_log10() + scale_y_log10() +
  labs(x = "2016 population", y = "FFL rate per 100k",
       title = "Per Capita FFL ~ State Populations")

