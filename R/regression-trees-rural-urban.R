# Regression Trees - Rural-Urban proportions
# "Rural-Urban Proportions"
# US Census - Rural-Urban Proportions Data
# "2010 Census Urban and Rural Classification and Urban Area Criteria"
# https://www.census.gov/geo/reference/ua/urban-rural-2010.html


# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(broom)
library(ggplot2)
library(rpart)
library(rpart.plot)
library(tree)

rural.urban <- read.csv("data/04-per-capita-clean/pct-rural-urban.csv", stringsAsFactors = F)
str(rural.urban)

# variables describe population and land area by rural-urban classifications.
# total numbers and percentages. 
# strata:
# urban, urbanized area, urbanized cluster, rural

# load themes and functions
source("~/GitHub/ATF-FFL/R/00-pd-themes.R")

# prepare data for regression trees -------------------------------------------

# remove total occupied housing, POPESTIMATE2015, POPESTIMATE2016
rural.urban$STATE <- NULL
rural.urban$POPESTIMATE2015 <- NULL
rural.urban$POPESTIMATE2016 <- NULL

# rownames as statenames, remove NAME variable
rownames(rural.urban) <- rural.urban$NAME
rural.urban$NAME <- NULL

# Regression Trees ------------------------------------------------------------

str(rural.urban)
# 50 observations of 23 variables
# How is this dataframe composed? 

# rpart model 01 --------------------------------------------------------------

# grow `rpart` regression tree
rural.urban.rp01 <- rpart(perCapitaFFL ~ ., data = rural.urban)

# plot `rpart` tree 01
rpart.plot(rural.urban.rp01, 
           type = 1, extra = 1, digits = 4, cex = 0.85, 
           branch.lty = 1, branch.lwd = 1,
           split.cex = 1.1, nn.cex = 0.9,
           box.palette = "BuBn", 
           pal.thresh = mean(rural.urban$perCapitaFFL),
           round = 1,
           family = "GillSans")

print(rural.urban.rp01)
# n= 50 

# node), split, n, deviance, yval
# * denotes terminal node

# 1) root 50 22865.9600 31.168860  
# 2) POP_UA>=616118 42  5508.6760 24.204560  
# 4) AREAPCT_UA>=2.665 25  1495.8680 17.292370  
# 8) POPPCT_RURAL< 14.05 10   161.9899  9.792603 *
#   9) POPPCT_RURAL>=14.05 15   396.4374 22.292210 *
#   5) AREAPCT_UA< 2.665 17  1061.7880 34.369550 *
#   3) POP_UA< 616118 8  4625.6530 67.731430 *

summary(rural.urban.rp01)
# Variable importance
# POP_UA       AREA_UA    AREA_URBAN     POP_URBAN AREAPCT_URBAN    POP_ST    AREAPCT_UA     
#     16            15            14            14            14        10             4

# POPPCT_UC AREAPCT_RURAL    AREAPCT_UC  POPPCT_RURAL  POPPCT_URBAN     POPPCT_UA 
#         3             3             2             1             1             1 
# POPDEN_URBAN 
#            1 

# tree` model 01 -------------------------------------------------------------

rural.urban.t01 <- tree(perCapitaFFL ~ ., data = rural.urban,
                        control = tree.control(50, minsize = 6))

par(mfrow = c(1, 1), family = "GillSans")
plot(rural.urban.t01, lty = 3, all = T)
text(rural.urban.t01, pretty = 0, cex = 0.9, all = T)

summary(rural.urban.t01)
# Variables actually used in tree construction:
# "AREAPCT_URBAN" "AREA_ST"       "AREAPCT_UA"    "POP_URBAN"     "POPPCT_URBAN" 
# Distribution of residuals:
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# -14.9700  -2.5740  -0.2692   0.0000   2.6780  14.9200 

# Regression Trees 01 Commentary ----------------------------------------------

# There's a good chance the `urban` variables are collinear, 
# as `URBAN` is the sum of `UA` and `UC`

library(corrplot)
library(ggcorrplot)

# create correlation matrix
urban.cor <- cor(rural.urban)

# plot correlation matrix
corrplot(urban.cor, method = "color", 
         type = "upper", order = "hclust",
         tl.col = "black", tl.cex = 0.75,
         addCoef.col = "black", number.cex = 0.7)


# plot correlation matrix using ggcorrplot
ggcorrplot(urban.cor, method = "square", 
           legend.title = "",
           hc.order = T, 
           lab = T, lab_size = 2.75) +
  scale_fill_gradient2(low = "firebrick3",
                       mid = "aliceblue",
                       high = "deepskyblue4",
                       midpoint = 0,
                       guide = F) +
  pd.theme +
  theme(axis.text.x = element_text(angle = 45, size = 10,
                                   hjust = 1, vjust = 1)) +
  labs(x = "", y = "")

# rpart model 02 --------------------------------------------------------------

# remove `URBAN` variables

urban02 <- rural.urban %>%
  select(-contains("URBAN"))

str(urban02)
# 50 observations of 18 variables

# grow `rpart` regression tree
rural.urban.rp02 <- rpart(perCapitaFFL ~ ., data = urban02)

# plot `rpart` tree 01
rpart.plot(rural.urban.rp02, 
           type = 1, extra = 1, digits = 4, cex = 0.85, 
           branch.lty = 1, branch.lwd = 1,
           split.cex = 1.1, nn.cex = 0.9,
           box.palette = "BuBn", 
           pal.thresh = mean(rural.urban$perCapitaFFL),
           round = 1,
           family = "GillSans")

print(rural.urban.rp02)
# n= 50 

# node), split, n, deviance, yval
# * denotes terminal node

# 1) root 50 22865.9600 31.168860  
# 2) POP_UA>=616118 42  5508.6760 24.204560  
# 4) AREAPCT_UA>=2.665 25  1495.8680 17.292370  
# 8) POPPCT_RURAL< 14.05 10   161.9899  9.792603 *
#   9) POPPCT_RURAL>=14.05 15   396.4374 22.292210 *
#   5) AREAPCT_UA< 2.665 17  1061.7880 34.369550 *
#   3) POP_UA< 616118 8  4625.6530 67.731430 *

summary(rural.urban.rp02)
# Variable importance
#        POP_UA       AREA_UA    AREAPCT_UA AREAPCT_RURAL     POPPCT_UA     
#            18            16            16            15            12

# POP_ST     POPPCT_UC    AREAPCT_UC       AREA_ST  POPPCT_RURAL    AREA_RURAL     POPDEN_UA 
#     11             4             3             2             1             1             1

# tree model 02 -------------------------------------------------------------

rural.urban.t02 <- tree(perCapitaFFL ~ ., data = urban02,
                        control = tree.control(50, minsize = 6))

par(mfrow = c(1, 1), family = "GillSans")
plot(rural.urban.t02, lty = 3, all = T)
text(rural.urban.t02, pretty = 0, cex = 0.9, all = T)

summary(rural.urban.t02)
# Variables actually used in tree construction:
# "AREAPCT_RURAL" "AREAPCT_UA"    "POP_UA"        "POPPCT_RURAL"  "AREA_ST"
# Distribution of residuals:
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# -14.9700  -2.5740  -0.2692   0.0000   2.6780  14.9200 

# Removing `URBAN` in this case appears to just flip the variables used to RURAL.

# rpart02 - Scatterplots of Regional Splits -----------------------------------
summary(urban02$POP_UA)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#   108700   957100  2487000  4386000  5204000 33430000

summary(urban02$AREAPCT_UA)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   0.020   0.815   2.665   6.406   6.350  38.350

urban02$NAME <- rownames(urban02)

ggplot(urban02, aes(POP_UA, AREAPCT_UA,
                   label = NAME, 
                   size = perCapitaFFL)) +
  geom_segment(x = 616000, xend = 616000, 
               y = -100, yend = 1000,
               linetype = "dashed", 
               color = "red3", 
               size = 0.25) +
  geom_segment(x = 616000, xend = 34000000, 
               y = 2.665, yend = 2.665, 
               linetype = "dashed", 
               color = "red3", 
               size = 0.25) +
  geom_point(aes(color = perCapitaFFL)) +
  scale_color_gradient2(low = "deepskyblue4",
                        mid = "antiquewhite2",
                        high = "firebrick4", 
                        midpoint = 52, 
                        guide = F) +
  scale_size(name = "per capita FFLs", 
             range = c(1, 20), 
             guide = F) +
  geom_text(aes(POP_UA, AREAPCT_UA,
                label = NAME),
            size = 3.5,
            hjust = -0.01, vjust = -0.55, 
            check_overlap = T, 
            family = "GillSans", 
            data = urban02) +
  geom_smooth(method = "lm", se = F, 
              linetype = "dotted",
              color = "cadetblue3",
              size = 0.75) +
  pd.facet +
  scale_x_log10() +
  theme(legend.position = "right",
        legend.title = element_text(size = 10),
        panel.grid = element_blank()) +
  labs(title = "FFLs ~ Rural-Urban Classification",
       x = "(log10) urbanized area population", y = "percentage land area - urbanized area",
       color = "per capita FFLs")

# rpart model 03 --------------------------------------------------------------

# remove all PCT variables
# select only PCT variables
urban.pct <- rural.urban %>%
  select(contains("PCT"), -contains("URBAN"), perCapitaFFL)
  
  # grow `rpart` regression tree
rural.urban.rp03 <- rpart(perCapitaFFL ~ ., data = urban.pct)

# plot `rpart` tree 01
rpart.plot(rural.urban.rp03, 
           type = 1, extra = 1, digits = 4, cex = 0.85, 
           branch.lty = 1, branch.lwd = 1,
           split.cex = 1.1, nn.cex = 0.9,
           box.palette = "BuBn", 
           pal.thresh = mean(rural.urban$perCapitaFFL),
           round = 1,
           family = "GillSans")

print(rural.urban.rp03)
summary(rural.urban.rp03)
# Variable importance
#    AREAPCT_UA AREAPCT_RURAL    AREAPCT_UC     POPPCT_UC     POPPCT_UA  POPPCT_RURAL   
#            30            26            21            15             4             4   

# tree model 03 ---------------------------------------------------------------

rural.urban.t03 <- tree(perCapitaFFL ~ ., data = urban.pct)

par(mfrow = c(1, 1), family = "GillSans")
plot(rural.urban.t03, lty = 3, all = T)
text(rural.urban.t03, pretty = 0, cex = 0.9, all = T)

# rpart model 04 --------------------------------------------------------------

# remove all PCT variables
# select only PCT variables
urban.total <- rural.urban %>%
  select(-contains("PCT"), perCapitaFFL)

# grow `rpart` regression tree
rural.urban.rp04 <- rpart(perCapitaFFL ~ ., data = urban.total)

# plot `rpart` tree 04
rpart.plot(rural.urban.rp04, 
           type = 1, extra = 1, digits = 4, cex = 0.85, 
           branch.lty = 1, branch.lwd = 1,
           split.cex = 1.1, nn.cex = 0.9,
           box.palette = "BuBn", 
           pal.thresh = mean(rural.urban$perCapitaFFL),
           round = 1,
           family = "GillSans")

print(rural.urban.rp04)
summary(rural.urban.rp04)
# Variable importance
#    AREAPCT_UA AREAPCT_RURAL    AREAPCT_UC     POPPCT_UC     POPPCT_UA  POPPCT_RURAL   
#            30            26            21            15             4             4   

# tree model 04 ---------------------------------------------------------------

rural.urban.t04 <- tree(perCapitaFFL ~ ., data = urban.pct)

par(mfrow = c(1, 1), family = "GillSans")
plot(rural.urban.t04, lty = 3, all = T)
text(rural.urban.t04, pretty = 0, cex = 0.9, all = T)


# Linear and Robust models ----------------------------------------------------

# linear models and subsets

# no urban total; rural and UC + UA
m01 <- lm(perCapitaFFL ~ .-NAME, data = urban02)
tidy(m01) %>% arrange(p.value)
summary(m01)

# rural only
urban03 <- urban02 %>%
  select(contains("RURAL"), perCapitaFFL)

m02 <- lm(perCapitaFFL ~ ., data = urban03)
summary(m02)

# urbanized areas and clusters
urban04 <- urban02 %>%
  select(contains("UA"), contains("UC"), perCapitaFFL)

m03 <- lm(perCapitaFFL ~ ., data = urban04)
summary(m03)

# urban totals only
urban05 <- rural.urban %>%
  select(contains("URBAN"), perCapitaFFL)

m04 <- lm(perCapitaFFL ~ ., data = urban05)
summary(m04)

mt01 <- tidy(m01) %>% mutate(model = "m01")
mt02 <- tidy(m02) %>% mutate(model = "m02")
mt03 <- tidy(m03) %>% mutate(model = "m03")
mt04 <- tidy(m04) %>% mutate(model = "m04")

lm.comparison <- bind_rows(mt01, mt02, mt03, mt04) %>%
  arrange(p.value)

lm.comparison %>%
  group_by(model) %>%
  filter(term != "(Intercept)")

mta01 <- glance(m01) %>% select(r.squared, adj.r.squared, p.value) %>% mutate(model = "m01")
mta02 <- glance(m02) %>% select(r.squared, adj.r.squared, p.value) %>% mutate(model = "m02")
mta03 <- glance(m03) %>% select(r.squared, adj.r.squared, p.value) %>% mutate(model = "m03")
mta04 <- glance(m04) %>% select(r.squared, adj.r.squared, p.value) %>% mutate(model = "m04")

lm.compare.R <- bind_rows(mta01, mta02, mta03, mta04)
lm.compare.R %>% arrange(desc(adj.r.squared))

# model 03, using only UC and UA variables, seems to fit best.


