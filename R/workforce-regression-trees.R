# Regression Trees - Workforce-Industry
# Federal Firearms License data
# "INDUSTRY BY SEX FOR THE FULL-TIME, YEAR-ROUND CIVILIAN EMPLOYED POPULATION 16 YEARS AND OVER"
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/
# American Community Survey - Subject Tables - Table S2404
# 2015 American Community Survey 1-Year Estimates

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

# ffl data and industry per capita data
ffl <- read.csv("data/ffl-per-capita.csv", stringsAsFactors = F)
wf <- read.csv("data/04-per-capita-clean/per-capita-workforce.csv", stringsAsFactors = F)
str(wf)

# remove population total variables
wf <- wf %>% select(1:22, 25)
str(wf)

# Regression Trees ------------------------------------------------------------

# remove NAME
rownames(wf) <- wf$NAME
wf$NAME <- NULL

# rpart - tree 01a - all features ---------------------------------------------
wf.tree01 <- rpart(perCapitaFFL ~ ., data = wf)

rpart.plot(wf.tree01, 
           type = 1, extra = 1, digits = 4, cex = 0.85, 
           branch.lty = 1, branch.lwd = 1,
           split.cex = 1.1, nn.cex = 0.9,
           box.palette = "BuBn", 
           pal.thresh = mean(wf$perCapitaFFL),
           round = 1,
           family = "GillSans")

print(wf.tree01)
summary(wf.tree01)

# tree- tree 01b - all features ---------------------------------------------
wf.tree01b <- tree(perCapitaFFL ~ ., data = wf)
print(wf.tree01b)
summary(wf.tree01b)

par(mfrow = c(1, 1), family = "GillSans")
plot(wf.tree01b, lty = 1)
text(wf.tree01b, pretty = 0, cex = 0.8, all = T)

# the results are similar to the rpart model, but with more terminal nodes
# and slightly finer grain.

print(wf.tree01b)
summary(wf.tree01b)

# Scatterplot: Primary & Secondary Rpart Splits -------------------------------

summary(wf$Waste.Management)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   613.7   974.2  1172.0  1177.0  1307.0  1842.0 

summary(wf$Mining.Oil.Gas)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#    3.884   41.610   89.730  376.700  346.900 4282.000 

wf$NAME <- rownames(wf)

ggplot(wf, aes(Waste.Management,
               Mining.Oil.Gas,
               label = NAME, 
               size = perCapitaFFL)) +
  geom_segment(x = 936, xend = 936, 
               y = -100, yend = 5000,
               linetype = "dashed", 
               color = "red3", 
               size = 0.25) +
  geom_segment(x = 936, xend = 2200, 
               y = 24.75, yend = 24.75, 
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
  geom_text(aes(Waste.Management,
                Mining.Oil.Gas, 
                label = NAME),
            size = 3.5,
            hjust = -0.01, vjust = -0.55, 
            check_overlap = T, 
            family = "GillSans", 
            data = wf) +
  expand_limits(x = c(500, 1900), 
                y = c(0, 4300)) +
  pd.facet +
  theme(legend.position = "right",
        legend.title = element_text(size = 10),
        panel.grid = element_blank()) +
  labs(title = "FFLs ~ Workforce Sector - Primary & Secondary Regression Tree Splits",
       x = "Waste Management", y = "Mining, Oil and Gas Extraction",
       color = "per capita FFLs")

# Wyoming appears to be exerting significant influence due to what appears to be 
# a monopoly in the Mining, Oil & Gas industry. How does the distribution look
# with Wyoming removed.

wf.wy <- wf %>%
  filter(NAME != "Wyoming")

summary(wf.wy$Mining.Oil.Gas)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#    3.884   41.460   86.700  297.000  331.500 1632.000

# Scatterplot: Third & Fourth Rpart Splits ------------------------------------

summary(wf$Finance.Insurance)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   721.8  1420.0  1777.0  1809.0  2077.0  3365.0 

summary(wf$Construction)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#     1558    2008    2194       2277    2482      3164


ggplot(wf, aes(Finance.Insurance,
               Construction,
               label = NAME, 
               size = perCapitaFFL)) +
  geom_segment(x = 1368, xend = 1368, 
               y = -1000, yend = 5000,
               linetype = "dashed", 
               color = "red3", 
               size = 0.25) +
  geom_segment(x = 1368, xend = 4000, 
               y = 2399, yend = 2399, 
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
  geom_text(aes(Finance.Insurance,
                Construction,
                label = NAME),
            size = 3.5,
            hjust = -0.01, vjust = -0.55, 
            check_overlap = T, 
            family = "GillSans", 
            data = wf) +
  expand_limits(x = c(700, 3500), 
                y = c(1500, 3200)) +
  pd.facet +
  theme(legend.position = "right",
        legend.title = element_text(size = 10),
        panel.grid = element_blank()) +
  labs(title = "FFLs ~ Workforce Sector - 3rd & 4th Regression Tree Splits",
       x = "Finance & Insurance", y = "Construction",
       color = "per capita FFLs")