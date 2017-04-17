# ATF-FFL - Exploratory Data Analysis
# NCSL State Legislator Data
# "Legislator Data - State Partisan Composition"
# http://www.ncsl.org/research/about-state-legislatures/partisan-composition.aspx
# http://www.ncsl.org/documents/statevote/legiscontrol_2014.pdf

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)

# plot themes
source("~/GitHub/ATF-FFL/R/00-pd-themes.R")
source("~/GitHub/ATF-FFL/R/usa-map-prep.R")

# legislator data by state
# 150 observations of 14 variables
legislature <- read.csv("data/04-per-capita-clean/legislature.csv")

# ffl data
ffl <- read.csv("~/GitHub/ATF-FFL/data/ffl-2016-perCapita-compact.csv", stringsAsFactors = F)

# Which Party controls more States, 2014-2016? --------------------------------
ggplot(legislature, aes(State.Control)) +
  geom_bar() + pd.theme

# Which Party controls more States, in each year? -----------------------------
ggplot(legislature, aes(State.Control, fill = State.Control)) +
  geom_bar() +
  facet_wrap(~ Year) + pd.scatter + coord_flip() +
  scale_fill_manual(values = c("deepskyblue4", "antiquewhite2", 
                               "gray23", "firebrick4"), guide = F) +
  theme(strip.background = element_rect(fill = NA, color = "black"),
        panel.border = element_rect(fill = NA, color = "black")) +
  labs(y = "seats", x = "party", 
       title = "2014-2016: State Control by Party")

# Which Party controls more Legislature, in each year? ------------------------
ggplot(legislature, aes(Legis.Control, fill = Legis.Control)) +
  geom_bar() +
  facet_wrap(~ Year) + pd.scatter + coord_flip() +
  scale_fill_manual(values = c("deepskyblue4", 
                               "gray23", 
                               "firebrick4", 
                               "antiquewhite2"), guide = F) +
  theme(strip.background = element_rect(fill = NA, color = "black"),
        panel.border = element_rect(fill = NA, color = "black")) +
  labs(y = "seats", x = "party",
       title = "2014-2016: Legislative Control by Party")


# Which is the Governing Party, in each year? ---------------------------------
ggplot(legislature, aes(Gov.Party, fill = Gov.Party)) +
  geom_bar() +
  facet_wrap(~ Year) + pd.scatter + coord_flip() +
  scale_fill_manual(values = c("deepskyblue4", 
                               "firebrick4", 
                               "antiquewhite2"), guide = F) +
  theme(strip.background = element_rect(fill = NA, color = "black"),
        panel.border = element_rect(fill = NA, color = "black")) +
  labs(y = "seats", x = "party",
       title = "2014-2016: Governing Party")

# Republicans dominate both years. Democrats make a very small portion,
# with there being nearly as many "Divided" as there are "Republican". 

# Which States are divided? ---------------------------------------------------
legislature %>%
  filter(State.Control == "Divided") %>%
  ggplot(aes(STATE, State.Control, fill = Legis.Control)) +
  geom_tile() + facet_wrap(~ Year) + pd.scatter + coord_flip() +
  scale_fill_manual(values = c("deepskyblue4",
                               "firebrick4",
                               "antiquewhite2")) +
  theme(strip.background = element_rect(fill = NA, color = "black"),
        panel.border = element_rect(fill = NA, color = "black"))

# Facet Party Totals ----------------------------------------------------------

# clean up variable names
colnames(legislature)[11:13] <- c("Legislative.Control", 
                                  "Governing.Party", 
                                  "State.Control")

legislature.stack <- legislature %>%
  dplyr::select(STATE, Legislative.Control, Governing.Party, State.Control, Year) %>%
  gather("Area", "Party", 2:4)


ggplot(legislature.stack, aes(Party, fill = Party)) +
  geom_bar(stat = "count", position = "dodge") +
  facet_wrap(~ Year) + 
  pd.scatter + 
  scale_fill_manual(values = c("deepskyblue4",
                               "antiquewhite2",
                               "cadetblue4",
                               "gray23",
                               "firebrick4",
                               "antiquewhite4"), guide = F) +
  theme(strip.background = element_rect(fill = NA, color = "black"),
        panel.background = element_rect(fill = NA, color = "black"),
        axis.text.x = element_text(angle = 45, size = 11,
                                   hjust = 1, vjust = 1),
        axis.title = element_text(size = 12)) +
  labs(x = "", y = "number of seats")

ggplot(legislature.stack, aes(Year, fill = Party)) +
  geom_bar(stat = "count") +
  facet_wrap(~ Area) + 
  pd.scatter + 
  scale_fill_manual(values = c("deepskyblue4",
                               "antiquewhite2",
                               "cadetblue4",
                               "gray23",
                               "firebrick4",
                               "antiquewhite4")) +
  theme(strip.background = element_rect(fill = NA, color = "black"),
        panel.background = element_rect(fill = NA, color = "black"),
        axis.text = element_text(size = 11),
        axis.title = element_text(size = 12),
        legend.position = "bottom") + 
  labs(x = "", y = "number of states")


# Map Parties by State --------------------------------------------------------

# merge spatial data
colnames(legislature)[1] <- "NAME"
leg.map <- legislature %>%
  left_join(fifty_states)

# map divided states
leg.map %>%
  filter(State.Control == "Divided" & Year == "2014") %>%
  ggplot(aes(lon, lat, group = group)) +
  geom_polygon(aes(fill = Legislative.Control)) + 
  scale_fill_manual(values = c("deepskyblue4",
                               "firebrick4",
                               "antiquewhite2")) +
  coord_map("polyconic") +
  pd.theme +
  theme(panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        legend.title = element_text(size = 12)) +
  labs(title = "2014: Divided States, by Party in Legislative Control",
       fill = "legislative\ncontrol")

# map all states by Legislative Control ---------------------------------------
leg.map %>%
  filter(Year == "2014") %>%
  ggplot(aes(lon, lat, group = group)) +
  geom_polygon(aes(fill = Legislative.Control), 
               color = "white", size = 0.025) + 
  scale_fill_manual(values = c("deepskyblue4",
                               "gray23",
                               "firebrick4",
                               "antiquewhite2")) +
  coord_map("polyconic") +
  pd.theme +
  theme(panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        legend.title = element_text(size = 12)) +
  labs(title = "2014: by Party in Legislative Control",
       fill = "legislative\ncontrol")

# map all states by Governing Party -------------------------------------------
leg.map %>%
  filter(Year == "2014") %>%
  ggplot(aes(lon, lat, group = group)) +
  geom_polygon(aes(fill = Governing.Party), 
               color = "white", size = 0.025) + 
  scale_fill_manual(values = c("deepskyblue4",
                               "firebrick4")) +
  coord_map("polyconic") +
  pd.theme +
  theme(panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        legend.title = element_text(size = 12)) +
  labs(title = "2014: by Governing Party",
       fill = "")

# map all states by State Control ---------------------------------------------
leg.map %>%
  filter(Year == "2014") %>%
  ggplot(aes(lon, lat, group = group)) +
  geom_polygon(aes(fill = State.Control)) + 
  scale_fill_manual(values = c("deepskyblue4",
                               "antiquewhite2",
                               "gray23",
                               "firebrick4")) +
  coord_map("polyconic") +
  pd.theme +
  theme(panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        legend.title = element_text(size = 12)) +
  labs(title = "2014: by Party in State Control",
       fill = "governing\nparty")

# House Democrat count --------------------------------------------------------
leg.map$House.Dem <- as.integer(leg.map$House.Dem)
legislature$House.Dem <- as.integer(legislature$House.Dem)
summary(leg.map$House.Dem)
summary(legislature$House.Dem)
hist(legislature$House.Dem)

leg.map %>%
  filter(Year == "2014" & NAME != "New Hampshire") %>%
  ggplot(aes(lon, lat, group = group)) +
  geom_polygon(aes(fill = House.Dem), 
               color = "white", size = 0.025) + 
  scale_fill_gradient2(low = "firebrick4",
                       mid = "antiquewhite2",
                       high = "deepskyblue4",
                       midpoint = 44) +
  coord_map("polyconic") +
  pd.theme +
  theme(panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        legend.title = element_text(size = 12)) +
  labs(title = "2014: by number of House Democrats",
       fill = "")

# House Republican count ------------------------------------------------------
leg.map$House.Rep <- as.integer(leg.map$House.Rep)
legislature$House.Rep <- as.integer(legislature$House.Rep)
summary(leg.map$House.Rep)
summary(legislature$House.Rep)
hist(legislature$House.Rep)

leg.map %>%
  filter(Year == "2014" & NAME != "New Hampshire") %>%
  ggplot(aes(lon, lat, group = group)) +
  geom_polygon(aes(fill = House.Rep), 
               color = "white", size = 0.025) + 
  scale_fill_gradient2(high = "firebrick4",
                       mid = "antiquewhite2",
                       low = "deepskyblue4",
                       midpoint = 59) +
  coord_map("polyconic") +
  pd.theme +
  theme(panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        legend.title = element_text(size = 12)) +
  labs(title = "2014: by number of House Republicans",
       fill = "")

# Faceted Maps ---------------------------------------------------------------
# facet map - state control
leg.map %>% 
  group_by(Year) %>%
  ggplot(aes(lon, lat, group = group)) +
  geom_polygon(aes(fill = State.Control)) + 
  scale_fill_manual(values = c("deepskyblue4",
                               "antiquewhite2",
                               "gray23",
                               "firebrick4")) +
  coord_map("polyconic") +
  facet_wrap(~ Year, ncol = 1) +
  pd.theme +
  theme(panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        legend.title = element_text(size = 12),
        legend.position = "bottom") +
  labs(title = "State Control by Year",
       fill = "")

# facet map - legislative control ---------------------------------------------
leg.map %>% 
  group_by(Year) %>%
  ggplot(aes(lon, lat, group = group)) +
  geom_polygon(aes(fill = Legislative.Control)) + 
  scale_fill_manual(values = c("deepskyblue4",
                               "gray23",
                               "firebrick4",
                               "antiquewhite2")) +
  coord_map("polyconic") +
  facet_wrap(~ Year, ncol = 1) +
  pd.theme +
  theme(panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        legend.title = element_text(size = 12),
        legend.position = "bottom") +
  labs(title = "Legislative Control by Year",
       fill = "")

# facet map - governing control -----------------------------------------------
leg.map %>% 
  group_by(Year) %>%
  ggplot(aes(lon, lat, group = group)) +
  geom_polygon(aes(fill = Governing.Party)) + 
  scale_fill_manual(values = c("deepskyblue4",
                               "firebrick4",
                               "antiquewhite2")) +
  coord_map("polyconic") +
  facet_wrap(~ Year, ncol = 1) +
  pd.theme +
  theme(panel.grid = element_blank(),
        axis.text = element_blank(),
        axis.title = element_blank(),
        legend.title = element_text(size = 12),
        legend.position = "bottom") +
  labs(title = "Governing Party by Year",
       fill = "")

####
# Exploratory Model Building --------------------------------------------------
####

# Model data ------------------------------------------------------------------

# merge ffl data
colnames(leg.14)[1] <- "NAME"

leg.ffl <- leg.14 %>%
  left_join(ffl)

# clean Nebraska
str(leg.ffl)
leg.ffl[27, c(4, 5, 7, 8, 9, 10)] <- "0"

leg.ffl$Total.House <- as.numeric(levels(leg.ffl$Total.House))[leg.ffl$Total.House]
rownames(leg.ffl) <- leg.ffl$NAME
leg.ffl$Total.House <- as.integer(leg.ffl$Total.House)
leg.ffl$Total.House

leg.model <- leg.ffl %>%
  dplyr::select(1:9, 11, 12, 13, 20) %>%
  filter(NAME != "Nebraska")

rownames(leg.model) <- leg.model$NAME
leg.model$House.Dem <- as.integer(leg.model$House.Dem)
leg.model$House.Rep <- as.integer(leg.model$House.Rep)
leg.model$Senate.Dem <- as.integer(leg.model$Senate.Dem)
leg.model$Senate.Rep <- as.integer(leg.model$Senate.Rep)

# Model 01 --------------------------------------------------------------------
mod01 <- lm(perCapitaFFL ~ Total.Seats + Total.Senate + Senate.Dem + Senate.Rep +
              Total.House + House.Dem + House.Rep, data = leg.model)
summary(mod01)
tidy(mod01) %>% arrange(p.value)
#           term   estimate std.error statistic      p.value
# 1  (Intercept)  49.094068 12.254647  4.006159 0.0002468812
# 2    House.Dem  -3.256067  2.258325 -1.441806 0.1567726105
# 3  Total.Seats   3.128997  2.200194  1.422146 0.1623683507
# 4    House.Rep  -3.091004  2.175298 -1.420957 0.1627117619
# 5 Total.Senate -13.532077 10.186946 -1.328374 0.1912277275
# 6   Senate.Rep  10.409151  8.437532  1.233672 0.2241844081
# 7   Senate.Dem   9.661568  8.521697  1.133761 0.2633249268

par(mfrow = c(2, 2), family = "GillSans")
plot(mod01)

# Model 02 --------------------------------------------------------------------
mod02 <- lm(perCapitaFFL ~ Senate.Dem + Senate.Rep + House.Dem + House.Rep, data = leg.model)
summary(mod02)
tidy(mod02) %>% arrange(p.value)
#          term    estimate  std.error   statistic     p.value
# 1 (Intercept) 45.00080953 11.8567237  3.79538316 0.000447215
# 2  Senate.Dem -0.83752320  0.4927200 -1.69979540 0.096229382
# 3   House.Dem -0.06850476  0.1673119 -0.40944337 0.684200777
# 4  Senate.Rep  0.21093691  0.5424836  0.38883558 0.699273130
# 5   House.Rep  0.00328551  0.2010904  0.01633848 0.987038224

par(mfrow = c(2, 2), family = "GillSans")
plot(mod01)

# Model 03 --------------------------------------------------------------------
# proportions

leg.model$Senate.Dem <- as.integer(leg.model$Senate.Dem)
leg.model$Senate.Rep <- as.integer(leg.model$Senate.Rep)
leg.model$House.Dem <- as.integer(leg.model$House.Dem)
leg.model$House.Rep <- as.integer(leg.model$House.Rep)

leg.model <- leg.model %>%
  mutate(ratio.senate.Dems = Senate.Dem/Total.Senate,
         ratio.senate.Reps = Senate.Rep/Total.Senate,
         ratio.house.Dems = House.Dem/Total.House,
         ratio.house.Reps = House.Rep/Total.House,
         ratio.Dems = (Senate.Dem + House.Dem)/Total.Seats,
         ratio.Reps = (Senate.Rep + House.Rep)/Total.Seats)

leg.model.ratio <- leg.model %>%
  dplyr::select(NAME, perCapitaFFL, contains("ratio"))

rownames(leg.model.ratio) <- leg.model.ratio$NAME

mod03 <- lm(perCapitaFFL ~ .-NAME, data = leg.model.ratio)
summary(mod03)
tidy(mod03) %>% arrange(p.value)
#                term   estimate std.error  statistic   p.value
# 1       (Intercept)   227.9726  224.4824  1.0155479 0.3156595
# 2  ratio.house.Dems -2135.0378 3537.1103 -0.6036108 0.5493488
# 3  ratio.house.Reps -1873.6344 3568.2999 -0.5250776 0.6022902
# 4        ratio.Dems  2493.7917 4972.7673  0.5014897 0.6186451
# 5        ratio.Reps  2286.8601 5024.9665  0.4550996 0.6513815
# 6 ratio.senate.Dems  -590.7779 1442.6016 -0.4095225 0.6842374
# 7 ratio.senate.Reps  -579.2694 1457.8498 -0.3973451 0.6931252

# Model 04 --------------------------------------------------------------------

legislature.ffl <- legislature %>%
  left_join(ffl) %>%
  dplyr::select(1:14, perCapitaFFL)

legislature2$House.Dem <- as.integer(legislature2$House.Dem)
legislature2$House.Rep <- as.integer(legislature2$House.Rep)
rownames(legislature2) <- legislature2$NAME

mod04<- lm(perCapitaFFL ~ .-NAME, data = legislature2)
summary(mod04)


# Model 05 --------------------------------------------------------------------

mod05 <- lm(perCapitaFFL ~ Legislative.Control + Governing.Party + State.Control, 
            data = legislature.ffl)
summary(mod05)
anova(mod05)

# Model 06 --------------------------------------------------------------------

mod06 <- lm(perCapitaFFL ~ Legislative.Control + Governing.Party, data = legislature.ffl)
summary(mod06)
anova(mod06)

# Model 07 --------------------------------------------------------------------

mod07 <- lm(perCapitaFFL ~ Legislative.Control, data = legislature.ffl)
summary(mod07)
anova(mod07)
plot(mod07)

# Robust Regression 01 --------------------------------------------------------

library(MASS)

rr.leg.01 <- rlm(perCapitaFFL ~ Legislative.Control, data = legislature.ffl)
summary(rr.leg.01)

weights.rr01 <- data.frame(.rownames = legislature.ffl$NAME, 
                           .resid = rr.leg.01$resid,
                           weight = rr.leg.01$w,
                           year = legislature.ffl$Year) %>% arrange(weight)

weights.rr01 %>% filter(year == "2014")
#         .rownames        .resid    weight year
# 1         Wyoming  7.255818e+01 0.2597453 2014
# 2         Montana  7.164401e+01 0.2630597 2014
# 3          Alaska  4.965067e+01 0.3795889 2014
# 4         Vermont  3.311714e+01 0.5690920 2014
# 5   West Virginia  3.229100e+01 0.5836522 2014
# 6    South Dakota  2.747420e+01 0.6860015 2014
# 7           Idaho  2.458215e+01 0.7667139 2014
# 8           Maine  2.229809e+01 0.8452263 2014
# 9    North Dakota  2.227802e+01 0.8460180 2014
# 10        Alabama -6.873761e+00 1.0000000 2014

# join with fitted and observed data
rr.huber01 <- augment(rr.leg.01) %>%
  left_join(weights.rr01) %>%
  arrange(weight) %>%
  mutate(weighted.resid = .resid * weight,
         weighted.fit = .fitted + weighted.resid)