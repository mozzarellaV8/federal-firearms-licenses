# ATF - Federal Firearms Licenses
# US Census - American Community Survey - Table S0802
# "MEANS OF TRANSPORTATION TO WORK BY SELECTED CHARACTERISTICS"
# https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/

# There are 3 means of transportation across multiple characteristics.
# 1. Car, truck, or van - drove alone
# 2. Car, truck, or van - carpooled
# 3. Public transportation (excluding taxicabs)

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)

# vis themes
source("R/00-pd-themes.R")

# means of transportation by industry
industry <- read.csv("data/03-additional-data/transporation-by-industry.csv")
str(industry)
summary(industry)

# departure time from home to work
departure.time <- read.csv("data/03-additional-data/transportation-time-leaving-home.csv")
str(departure.time)
summary(departure.time)

# Federal Firearms Licenses
ffl <- read.csv("data/ffl-per-capita.csv")

# compare total population to total surveyed population
sum(ffl$POPESTIMATE2015)    # 320,226,241
sum(industry$total.workers) # 147,966,010

sum(ffl$POPESTIMATE2015) - sum(industry$total.workers) 
# There is a difference of 172,260,231

# explore: means-of-transportation totals -------------------------------------

# select totals, bind firearms data, and compute per capita figures
industry.perCapita <- industry %>%
  select(NAME, 
         total.workers, 
         total.drove.alone, 
         total.carpool, 
         total.public.transportation) %>%
  left_join(ffl, by = "NAME") %>%
  mutate(percent.working = total.workers/POPESTIMATE2015,
         perCapita.workers = (total.workers/POPESTIMATE2015) * 100000,
         perCapita.drove.alone = (total.drove.alone/POPESTIMATE2015) * 100000,
         perCapita.carpool = (total.carpool/POPESTIMATE2015) * 100000,
         perCapita.public = (total.public.transportation/POPESTIMATE2015) * 100000) %>%
  select(-POPESTIMATE2016)

# rename variables for cleaner plots
colnames(industry.perCapita)[2:5] <- gsub("total.", "", colnames(industry.perCapita)[2:5])
colnames(industry.perCapita)[9:12] <- c("workers.per.capita", "a.drove.alone", "b.carpool",
                                        "c.public.transportation")

# total data - stack data and facet vis
industry.perCapita %>%
  select(NAME, perCapitaFFL, workers, 
         drove.alone, carpool, public.transportation) %>%
  gather(key = means, value = total, 3:6) %>%
  ggplot(aes(reorder(NAME, total), 
             total, 
             fill = total)) +
  geom_bar(stat = "identity") +
  facet_wrap(~ means, nrow = 3) +
  pd.facet + 
  theme(axis.text.x = element_text(size = 11),
        legend.position = "right") +
  coord_flip() +
  labs(x = "", y = "")

# per capita data - stack data and facet vis
industry.perCapita %>%
  select(NAME, perCapitaFFL, 
         workers.per.capita, 
         a.drove.alone, b.carpool, c.public.transportation) %>%
  gather(key = means, value = total, 3:6) %>%
  filter(means != "workers.per.capita" & 
           means != "a.drove.alone") %>%
  ggplot(aes(reorder(NAME, total), 
             total, 
             fill = total)) +
  geom_bar(stat = "identity") +
  facet_wrap(~ means, ncol = 1) +
  pd.facet + 
  theme(axis.text.x = element_text(size = 11),
        axis.text.y = element_text(size = 8),
        plot.margin = margin(0, 0, 0, 0)) +
  coord_flip() +
  labs(x = "", y = "")

# per capita data - stack data and stacked vis --------------------------------

industry.pc.stack <- industry.perCapita %>%
  select(NAME, perCapitaFFL, workers.per.capita, 
         a.drove.alone, b.carpool, c.public.transportation) %>%
  gather(key = means, value = total, 3:6) %>%
  filter(means != "workers.per.capita") %>%
  group_by(means) %>%
  arrange(total, means) %>%
  ungroup()

# stacked bar chart
ggplot(industry.pc.stack, 
       aes(reorder(NAME, total), 
             total, 
             fill = means)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = c("deepskyblue4", 
                               "firebrick4", 
                               "antiquewhite2")) +
  pd.theme + 
  coord_flip() +
  guides(fill = guide_legend(reverse = F)) +
  labs(x = "", y = "", fill = "transporation")

# faceted bar chart
ggplot(industry.pc.stack,
       aes(reorder(NAME, total),
           total,
           fill = means)) +
  geom_bar(stat = "identity") +
  facet_wrap(~ means, ncol = 1) +
  pd.facet +
  coord_flip()

# explore: departure time totals ----------------------------------------------

departure.stack <- departure.time %>%
  select(NAME, contains("total")) %>%
  gather(key = time, value = percentage, 2:11)

departure.stack$time <- gsub("\\.total", "", departure.stack$time)

ggplot(departure.stack,
       aes(NAME,
           percentage,
           fill = time)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = c("firebrick4",
                               "firebrick3",
                               "firebrick2",
                               "firebrick1",
                               "deepskyblue1",
                               "deepskyblue2",
                               "deepskyblue3",
                               "deepskyblue4",
                               "goldenrod2",
                               "darkgoldenrod")) +
  pd.theme +
  theme(axis.text = element_text(size = 12),
        axis.title = element_text(size = 11),
        legend.position = "right") +
  labs(x = "", y = "percentage of population") +
  guides(fill = guide_legend(reverse = T)) +
  coord_flip()

# too many levels
  






