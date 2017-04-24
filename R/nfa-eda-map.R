# ATF Commerce Report Data
# National Firearms Act Registrations
# Exploratory Data Analysis

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)
library(maps)
library(mapproj)
library(sp)
library(rgdal)

# vis themes + maps
source("R/00-pd-themes.R")
source("R/00-usa-map-prep.R")

nfa.pc <- read.csv("data/nfa-per-capita.csv")
str(nfa.pc)

# map by firearms type --------------------------------------------------------

# join NFA and map data
nfa.map <- left_join(nfa.pc, fifty_states)

# Map: Total Firearms by State ------------------------------------------------

# look at figures
summary(nfa.map$Total)
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#   356.5  1081.0  1623.0  1616.0  1822.0 21790.0

(21790.0 - 356.5)/2 #  10716.75

# map
ggplot(nfa.map, aes(lon, lat, group = group, fill = Total)) +
  geom_polygon() +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite1",
                       high = "coral4", 
                       midpoint = 10716.75) +
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10, 
                                   hjust = 1, 
                                   vjust = 1)) +
  labs(title = "2016: Total Registered Weapons ~ State (per 100k residents)", 
       x = "", y = "", fill = "")

# Map: Silencers by State -----------------------------------------------------

summary(nfa.map$Silencer)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#    2.747  242.600  429.400  413.500  571.100 1100.000

(max(nfa.map$Silencer) - min(nfa.map$Silencer)) / 2 
# 548.4719

# map
ggplot(nfa.map, aes(lon, lat, 
                    group = group, 
                    fill = Silencer)) +
  geom_polygon() +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite1",
                       high = "coral4", 
                       midpoint = 548.4719) +
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10, 
                                   hjust = 1, 
                                   vjust = 1)) +
  labs(title = "Silencers", x = "", y = "", fill = "")

# Map: Destructive Devices by State -------------------------------------------

summary(nfa.map$DestructiveDevice)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#    207.9   500.9   630.5   813.2   818.5      20610.0

# compute gradient midpoint
(20610 - 207.9) / 2  # 10201.05

# map
ggplot(nfa.map, aes(lon, lat, 
                    group = group, 
                    fill = DestructiveDevice)) +
  geom_polygon() +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite1",
                       high = "coral4", 
                       midpoint = 10201) +
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10, 
                                   hjust = 1, 
                                   vjust = 1)) +
  labs(title = "Destructive Devices", 
       x = "", y = "", fill = "")

# Map: Machine Guns by State --------------------------------------------------

summary(nfa.map$MachineGun)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#   28.77  130.20     184.90    207.40  238.00  1058.00

(1058 - 28.77) / 2  # 514.615

# map
ggplot(nfa.map, aes(lon, lat, 
                    group = group, 
                    fill = MachineGun)) +
  geom_polygon() +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite1",
                       high = "coral4", 
                       midpoint = 514.615) +
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10, 
                                   hjust = 1, 
                                   vjust = 1)) +
  labs(title = "Machine Guns", 
       x = "", y = "", fill = "")

# Map: Rifles by State --------------------------------------------------------

summary(nfa.map$Rifle)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#    4.14   58.44      78.30    92.95  124.60    240.10

(240.10 - 4.14) / 2  # 117.98

# map
ggplot(nfa.map, aes(lon, lat, 
                    group = group, 
                    fill = Rifle)) +
  geom_polygon() +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite1",
                       high = "coral4", 
                       midpoint = 117.98) +
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10, 
                                   hjust = 1, 
                                   vjust = 1)) +
  labs(title = "Short-Barreled Rifles", 
       x = "", y = "", fill = "")

# Map: Shotguns by State ------------------------------------------------------

summary(nfa.map$Shotgun)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#     4.35   27.77     37.72    62.69   91.13    171.90 

(171.90 - 4.35) / 2  # 83.775

# map
ggplot(nfa.map, aes(lon, lat, 
                    group = group, 
                    fill = Shotgun)) +
  geom_polygon() +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite1",
                       high = "coral4", 
                       midpoint = 83.775) +
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10, 
                                   hjust = 1, 
                                   vjust = 1)) +
  labs(title = "Short-Barreled Shotguns", 
       x = "", y = "", fill = "")

# Map: Any Other Weapon by State ----------------------------------------------

summary(nfa.map$OtherWeapon)
#     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
#     2.386  14.520   24.420   25.890  38.780    51.660 

(51.660 - 2.386) / 2  # 24.637

# map
ggplot(nfa.map, aes(lon, lat, 
                    group = group, 
                    fill = OtherWeapon)) +
  geom_polygon() +
  scale_fill_gradient2(low = "deepskyblue4",
                       mid = "antiquewhite1",
                       high = "coral4", 
                       midpoint = 24.637) +
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text = element_blank(),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 10, 
                                   hjust = 1, 
                                   vjust = 1)) +
  labs(title = "Any Other Weapon", 
       x = "", y = "", fill = "")

