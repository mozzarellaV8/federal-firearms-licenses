# ATF Commerce Report Data
# National Firearms Act Registrations
# Exploratory Data Analysis

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)

# vis themes + maps
source("R/00-pd-themes.R")
source("R/00-usa-map-prep.R")

# function to compute per 100,000
source("R/00-per-capita.R")

# National Firearms Act: Firearms registrations by type and state
nfa <- read.csv("data/00-ATF-commerce/08-registration-by-state.csv",
                stringsAsFactors = F)
str(nfa)

# Federal Firearms License data
ffl <- read.csv("data/ffl-per-capita.csv", stringsAsFactors = F)
str(ffl)

# functions -------------------------------------------------------------------

# function to remove commas from numeric variables
commas <- function(x) {
  x <- gsub(",", "", x)
  x <- as.integer(x)
  x
}

# function to compute per capita figures
perCapita <- function(x) {
  x <- as.numeric(x)
  x <- (x / nfa$POPESTIMATE2015) * 100000
  x
}

# cleanse: registrations ------------------------------------------------------

# remove DC and Other Territories
nfa <- nfa[-c(8, 52), ]

# change column names
colnames(nfa) <- c("NAME", "OtherWeapon", "DestructiveDevice", "MachineGun", 
                   "Silencer", "Rifle", "Shotgun", "Total")

# remove commas from numeric variables
nfa <- nfa %>%
  mutate_each(funs(commas), 2:8)

# bind NFA and FFL data
nfa <- nfa %>%
  left_join(ffl, by = "NAME")

# convert state names to factor
nfa$NAME <- factor(nfa$NAME)

# new dataframe with NFA per capita figures
nfa.pc <- nfa %>%
  mutate_each(funs(perCapita), 2:8)

write.csv(nfa.pc, file = "data/nfa-per-capita.csv", row.names = F)
  
# explore: registrations ------------------------------------------------------

# create population / 100000 variables
nfa.pc <- nfa.pc %>%
  mutate(pop2015.100k = POPESTIMATE2015 / 100000,
         pop2016.100k = POPESTIMATE2016 / 100000)

hist(nfa.pc$pop2015.100k)

# explore: bar plots by firearms type and state -------------------------------

# Total Firearms by State, Population color fill
nfa.pc %>% 
  arrange(desc(Total)) %>%
  ggplot(aes(reorder(NAME, Total), Total, 
             fill = pop2015.100k)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite2",
                       high = "firebrick4", 
                       midpoint = 200) +
  pd.theme + 
  coord_flip() +
  theme(legend.position = "right",
        axis.text = element_text(size = 11)) +
  labs(x = "", fill = "",
       y = "Registered Firearms per 100k residents",
       title = "Total Registered Weapons by State")

# 'Any Other Weapon' by State - population color fill
nfa.pc %>%
  arrange(desc(OtherWeapon)) %>%
  ggplot(aes(reorder(NAME, OtherWeapon),
             OtherWeapon,
             fill = pop2015.100k)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite2",
                       high = "firebrick4",
                       midpoint = 200) +
  pd.theme +
  coord_flip() +
  theme(axis.text = element_text(size = 11)) +
  labs(x = "", fill = "", 
       y = "registrations per 100k residents",
       title = "Registrations of 'Any Other Weapon' by State")

# 'Destructive Devices' by State - pop color fill
nfa.pc %>%
  arrange(desc(DestructiveDevice)) %>%
  ggplot(aes(reorder(NAME, DestructiveDevice),
             DestructiveDevice,
             fill = pop2015.100k)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite2",
                       high = "firebrick4",
                       midpoint = 200) +
  pd.theme +
  coord_flip() +
  theme(axis.text = element_text(size = 11)) +
  labs(x = "", fill = "",
       y = "registered 'Destructive Devices' per 100k residents",
       title = "Destructive Devices")

# 'Machine Gun' by State - pop color fill
nfa.pc %>%
  arrange(desc(MachineGun)) %>%
  ggplot(aes(reorder(NAME, MachineGun),
             MachineGun,
             fill = pop2015.100k)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite2",
                       high = "firebrick4",
                       midpoint = 200) +
  pd.theme +
  coord_flip() +
  theme(axis.text = element_text(size = 11)) +
  labs(x = "", fill = "",
       y = "registered 'Machine Guns' per 100k residents",
       title = "Machine Guns")

# 'Silencer' by State - pop color fill
nfa.pc %>%
  arrange(desc(Silencer)) %>%
  ggplot(aes(reorder(NAME, Silencer),
             Silencer,
             fill = pop2015.100k)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite2",
                       high = "firebrick4",
                       midpoint = 200) +
  pd.theme +
  coord_flip() +
  theme(axis.text = element_text(size = 11)) +
  labs(x = "", fill = "",
       y = "registered silencers per 100k residents",
       title = "Silencers")

# 'Rifles' by State - pop color fill
nfa.pc %>%
  arrange(desc(Rifle)) %>%
  ggplot(aes(reorder(NAME, Rifle),
             Rifle,
             fill = pop2015.100k)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite2",
                       high = "firebrick4",
                       midpoint = 200) +
  pd.theme +
  coord_flip() +
  theme(axis.text = element_text(size = 11)) +
  labs(x = "", fill = "",
       y = "registered rifles per 100k residents",
       title = "Short-Barreled Rifles")


# 'Shotgun' by State - pop color fill
nfa.pc %>%
  arrange(desc(Shotgun)) %>%
  ggplot(aes(reorder(NAME, Shotgun),
             Shotgun,
             fill = pop2015.100k)) +
  geom_bar(stat = "identity") +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite2",
                       high = "firebrick4",
                       midpoint = 200) +
  pd.theme +
  coord_flip() +
  theme(axis.text = element_text(size = 11)) +
  labs(x = "", fill = "",
       y = "registered shotguns per 100k residents",
       title = "Short-Barreled Shotguns")
