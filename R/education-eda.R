# ATF- FFL - Exploratory Data Analysis
# US Census - American Community Survey - Table S1501
# "Educational Attainment"
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/


# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)
library(grDevices)

# custom plot themes
source("R/00-pd-themes.R")
source("R/00-usa-map-prep.R")

# total and per capita full-time education data
education <- read.csv("data/04-per-capita-clean/per-capita-education.csv", stringsAsFactors = F)

str(education)
# 50 obs of 55 variables
summary(education)

# select only variables that pertain to HS and BA
# the only data that is complete across age groups

edu <- education %>%
  select(NAME, perCapitaFFL, POPESTIMATE2015, POPESTIMATE2016,
         contains("HS"), contains("BA"), -contains("Less"))

# clean up variable names
colnames(edu) <- gsub("edu.[0-9][0-9].Total", "per.capita", colnames(edu))

str(edu)
# 50 obs of 34 variables

# Regression Tree -------------------------------------------------------------

# Data inspection using regression trees.
# Because of the large number of variables, 
# regression trees are fit to better understand the structure of the dataframe.

# Fitting regression trees to each Census dataset (e.g. education, workforce)
# and then fitting a regression tree on all variables at once,
# to see which factors might be best used for a multiple robust regression model. 
  
library(rpart)
library(rpart.plot)
library(tree)

# remove non-numeric variables
edu.tree <- edu %>%
  select(-POPESTIMATE2015, -POPESTIMATE2016)

# set rownames as states
rownames(edu.tree) <- edu.tree$NAME
edu.tree$NAME <- NULL

# palette
show.prp.palettes()

# `rpart` regression tree 01 --------------------------------------------------

# different rpart.control minsplits and complexity parameters
# can be experimented with - perhaps on a dataframe with more variables.
edu.rpart01 <- rpart(perCapitaFFL ~ ., data = edu.tree, 
                     control = rpart.control())
print(edu.rpart01)
summary(edu.rpart01)

# plot tree - 4 digits
rpart.plot(edu.rpart01, 
           type = 1, extra = 1, digits = 4, cex = 0.8, 
           branch.lty = 3, branch.lwd = 2.5,
           split.cex = 1.1, nn.cex = 0.9,
           box.palette = "BuBn", 
           pal.thresh = mean(edu$perCapitaFFL),
           round = 1,
           family = "GillSans")

prp(edu.rpart01, 
    type = 4, extra = 1, digits = 4, under = T,
    branch.lty = 2, branch.lwd = 2.5, 
    cex = 0.8,  split.cex = 1.1, nn.cex = 0.9,
    box.palette = "BuBn",
    family = "GillSans")

rsq.rpart(edu.rpart01)

# `tree` regression tree 01 --------------------------------------------------

edu.tree01 <- tree(perCapitaFFL ~ ., data = edu.tree)
print(edu.tree01)
summary(edu.tree01)

# plot tree
par(family = "GillSans")
plot(edu.tree01, branch = 0, lty = 3)
text(edu.tree01, pretty = 0, use.n = T, cex = 0.85)

# Is using gender variables in addition to age groups creating unnecessary complexity? 
# Or is providing insight? 

# Important age groups are 18-24, 25-34, and 35-44.
# Young people with BAs is the most important deciding factor. 
# This number should be relatively small - typically in education, 
# 18 would be the age one graduates HS. 22 would be the age one graduates college -
# Following this, there's only a span of 2 years (ages 22-24) to measure from. 

# How many of them are there? 
# Where are the 18-24 BAs? 25-34 BAs? 34-44 HS Females? 

summary(edu$per.capita.18to24.BA)
#   Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#  442.5   738.4   931.0   961.9  1164.0  1787.0

# By the regression tree split, we see that 18-24 BAs per capita per state
# under the 1st quantile leads to the highest average FFL count.
# 1st Quantile: 738
# Primary Regression Tree Split: n < 717, 58.25 mean FFL
# Primary Regression Tree Split: n > 717, 42.28 mean FFL at most.

# Map 01: Education by State --------------------------------------------------

# Map Preparation:
# merge USA map data with FFL data
perCapitaMap <- left_join(edu, fifty_states, by = "NAME") %>%
  arrange(group, order)

# Map per capita workforce
# 18-24 BA color fill
# fill midpoint set to primary tree split/1st quantile.
ggplot(perCapitaMap, aes(lon, lat, 
                         group = group,
                         fill = per.capita.18to24.BA)) +
  geom_polygon(color = "white", size = 0.1) +
  scale_fill_gradient2(high = "deepskyblue4",
                       mid = "antiquewhite1",
                       low = "coral4", 
                       midpoint = 717) +
  coord_map("polyconic") + pd.theme +
  theme(panel.border = element_rect(linetype = "solid", 
                                    fill = NA, 
                                    color = "white"),
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 10, hjust = 1, vjust = 1),
        legend.position = "right") +
  labs(title = "Per Capita 18-24 year olds with BA", 
       x = "", y = "", fill = "")

# Map 02: Education by State - 18-24 BA Discretized  --------------------------

# discretize population into 20% quantiles
ba.q <- quantile(edu$per.capita.18to24.BA,
                 seq(0, 1, 0.2))

ba.q
#       0%       20%       40%       60%       80%      100% 
# 442.5129  721.6580  840.9432  968.9943 1197.4317 1787.0535 

# The 20th percentile is actually a good approximation to the regression tree split.

# add discretized variable to `edu` dataframe
edu <- edu %>%
  mutate(BA.18to24.Q = cut(edu$per.capita.18to24.BA, 
                           breaks = ba.q,
                           labels = c("0-20%", "20-40%", "40-60%", "60-80%", "80-100%"),
                           include.lowest = T))

# merge new variable into map dataframe
perCapitaMap <- left_join(edu, fifty_states, by = "NAME") %>%
  arrange(group, order)

# create discrete palette
edu.pal <- colorRampPalette(c("coral4", "antiquewhite2", "deepskyblue4"))(5)

# Map per capita education: 
# discretized 18-24 BA color fill
ggplot(perCapitaMap, aes(lon, lat, 
                         group = group,
                         fill = BA.18to24.Q)) +
  geom_polygon(color = "white", size = 0.1) +
  scale_fill_manual(values = edu.pal) +
  coord_map("polyconic") + pd.theme +
  theme(panel.border = element_rect(linetype = "solid", 
                                    fill = NA, 
                                    color = "white"),
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9.5, hjust = 1, vjust = 1),
        legend.position = "right") +
  guides(fill = guide_legend(reverse = T)) +
  labs(title = "Where are the 18 to 24 year old college graduates?", 
       x = "", y = "", fill = "")

# Map 03: Education by State - 35-44 HS Female Discretized --------------------
# rpart tree 01 - Secondary Split

summary(edu$per.capita.35to44.HS.Female)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   4919    5476    5632    5648    5808    6242 

# discretize population into 20% quantiles
ba.q2 <- quantile(edu$per.capita.35to44.HS.Female, seq(0, 1, 0.2))

ba.q2
#         0%      20%      40%      60%      80%     100% 
#   4918.503 5441.502 5594.813 5713.596 5833.349 6241.937 

# 35 to 44 year old female high school graduates - 
# The deciding value on the secondary split is just under the mean and median,
# which lies in the lower the 20th percentile:

# 5435 female high school graduates per capita - aged 35-44 - decides this split.

# Below the split: more FFLs - 38.41 average.
# Above the split: less FFLs - from 14-27 on average, 
# depending on the number 25-34 year old college graduates.

# add discretized variable to `edu` dataframe
edu <- edu %>%
  mutate(BA.35to44.HS.FemaleQ = cut(edu$per.capita.35to44.HS.Female, 
                                    breaks = ba.q2,
                                    labels = c("0-20%", "20-40%", "40-60%", "60-80%", "80-100%"),
                                    include.lowest = T))

# merge new variable into map dataframe
perCapitaMap <- left_join(edu, fifty_states, by = "NAME") %>%
  arrange(group, order)


# Map per capita education: 
# discretized 25-34 BA color fill
ggplot(perCapitaMap, aes(lon, lat, 
                         group = group,
                         fill = BA.35to44.HS.FemaleQ)) +
  geom_polygon(color = "white", 
               size = 0.1) +
  scale_fill_manual(values = edu.pal) +
  coord_map("polyconic") + 
  pd.theme +
  theme(panel.border = element_blank(),
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9.5, 
                                   hjust = 1, 
                                   vjust = 1),
        legend.position = "right") +
  guides(fill = guide_legend(reverse = T)) +
  labs(title = "Female High School Graduates, Age 35-44", 
       x = "", y = "", fill = "")

# California's percentile is unexpected.

# Map 04: Education by State - 25-34 BA Discretized ---------------------------
# rpart tree 01 - Tertiary Split

summary(edu$per.capita.25to34.BA)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#    2841    3743    4246    4397    4905    7063 

# discretize population into 10% quantiles
ba.q3 <- quantile(edu$per.capita.25to34.BA, seq(0, 1, 0.2))

ba.q3
#         0%      20%      40%      60%      80%     100% 
#   2840.562 3686.376 4104.471 4584.480 5248.371 7063.385 

# The deciding value on the tertiary split is at the 70th percentile:
# 4765 college graduates per capita, aged 25-34.

# add discretized variable to `edu` dataframe
edu <- edu %>%
  mutate(BA.25to34.Q = cut(edu$per.capita.25to34.BA, 
                           breaks = ba.q3,
                           labels = c("0-20%", "20-40%", "40-60%", "60-80%", "80-100%"),
                           include.lowest = T))

# merge new variable into map dataframe
perCapitaMap <- left_join(edu, fifty_states, by = "NAME") %>%
  arrange(group, order)

# Map per capita education: 
# discretized 25-34 BA color fill
ggplot(perCapitaMap, aes(lon, lat, 
                         group = group,
                         fill = BA.25to34.Q)) +
  geom_polygon(color = "white", 
               size = 0.1) +
  scale_fill_manual(values = edu.pal) +
  coord_map("polyconic") + 
  pd.theme +
  theme(panel.border = element_blank(),
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.title = element_text(size = 10),
        legend.text = element_text(size = 9.5, 
                                   hjust = 1, 
                                   vjust = 1),
        legend.position = "right") +
  guides(fill = guide_legend(reverse = T)) +
  labs(title = "Where are the 25 to 34 year old college graduates?", 
       x = "", y = "", fill = "")

# At 70% and below, the mean FFL goes up to 27 - 
# Above 70%, the mean FFL is at its lowest at 14.

# Decision Tree Split 01: scatterplot -----------------------------------------

# Primary & Secondary split
# scatterplot with labels and decision-tree splits
# state names for labels
ggplot(edu, aes(per.capita.18to24.BA, 
                per.capita.35to44.HS.Female, 
                label = NAME, 
                size = perCapitaFFL)) +
  geom_segment(x = 717, xend = 717, y = 0, yend = 10000,
               linetype = "dashed", color = "red3", size = 0.25) +
  geom_segment(x = 717, xend = 10000, y = 5435, yend = 5435, 
               linetype = "dashed", color = "red3", size = 0.25) +
  geom_smooth(method = "lm", se = F, 
              linetype = "dotted",
              color = "cadetblue3",
              size = 0.8) +
  geom_point(aes(color = perCapitaFFL)) +
  scale_color_gradient2(low = "deepskyblue4",
                        mid = "antiquewhite2",
                        high = "firebrick4", 
                        midpoint = 52, 
                        guide = F) +
  scale_size(name = "per capita FFLs", 
             range = c(1, 14), 
             guide = F) +
  geom_text(aes(per.capita.18to24.BA, 
                per.capita.35to44.HS.Female, 
                label = NAME),
            size = 3, 
            hjust = -0.01, vjust = -0.55, 
            check_overlap = T, 
            family = "GillSans", 
            data = edu) +
  expand_limits(x = c(400, 2000)) +
  pd.facet +
  theme(legend.position = "right",
        legend.title = element_text(size = 10),
        panel.grid = element_line(color = "gray82")) +
  labs(x = "18 to 24 year old college graduates, per 100,000", 
       y = "35 to 44 year olds high school graduates - female, per 100,000",
       color = "per capita FFLs")

# Decision Tree Split 02: scatterplot -----------------------------------------

library(broom)
slope <- lm(per.capita.25to34.BA ~ per.capita.35to44.HS.Female, 
            data = edu)
tidy(slope)

summary(edu$per.capita.35to44.HS.Female)
# Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
# 4919    5476    5632    5648    5808    6242

summary(edu$per.capita.25to34.BA)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#    2841    3743    4246    4397    4905    7063

# Secondary & Tertiary split
# scatterplot with labels and decision-tree splits
# state names for labels
ggplot(edu, aes(per.capita.35to44.HS.Female, 
                per.capita.25to34.BA, 
                label = NAME, 
                size = perCapitaFFL)) +
  geom_segment(x = 5435, xend = 5435, y = 0, yend = 10000, 
               linetype = "dashed", color = "red3", size = 0.375) +
  geom_segment(x = 5435, xend = 10000, y = 4765, yend = 4765, 
               linetype = "dashed", color = "red3", size = 0.25) +
  geom_smooth(method = "lm", se = F, 
              linetype = "dotted",
              color = "cadetblue3",
              size = 0.8) +
  geom_point(aes(color = perCapitaFFL)) +
  scale_color_gradient2(low = "deepskyblue4",
                        mid = "antiquewhite2",
                        high = "firebrick4", 
                        midpoint = 52, 
                        guide = F) +
  scale_size(name = "per capita FFLs", 
             range = c(1, 14), 
             guide = F) +
  geom_text(aes(per.capita.35to44.HS.Female, 
                per.capita.25to34.BA,
                label = NAME),
            size = 3, 
            hjust = -0.01, vjust = -0.55, 
            check_overlap = T, 
            family = "GillSans", 
            data = edu) +
  expand_limits(x = c(4900, 6300)) +
  pd.facet +
  theme(legend.position = "right",
        legend.title = element_text(size = 10),
        panel.grid = element_line(color = "gray82")) +
  labs(y = "25 to 34 year olds college graduates per 100,000", 
       x = "35 to 44 year olds with high school graduates - female",
       color = "per capita FFLs")

# FFL by Area: scatterplot ----------------------------------------------------

# state names for labels
ggplot(edu, aes(per.capita.18to24.BA, 
                perCapitaFFL,
                label = NAME, 
                size = perCapitaFFL)) +
  geom_point(aes(fill = perCapitaFFL, 
                 alpha = perCapitaFFL/100), 
             shape = 21) +
  scale_fill_gradient2(low = "deepskyblue4",
                        mid = "antiquewhite2",
                        high = "firebrick4", 
                        midpoint = 52, 
                        guide = F) +
  scale_size(name = "per capita FFLs", 
             range = c(1, 50),
             guide = F) +
  geom_text(aes(per.capita.18to24.BA, 
                perCapitaFFL,
                label = NAME,
                size = perCapitaFFL/200), 
            hjust = -0.01, vjust = -0.55, 
            check_overlap = T, 
            family = "GillSans", 
            data = edu) +
  pd.facet + 
  expand_limits(y = c(0, 120)) +
  theme(legend.position = "none",
        legend.title = element_text(size = 10),
        panel.grid = element_line(color = "gray82")) +
  labs(y = "Federal Firearms Licenses per 100,000", 
       x = "18 to 24 year old college graduates per 100,000",
       color = "per capita FFLs")
