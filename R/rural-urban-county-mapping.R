# ATF-FFL - Rural-Urban county-level mapping

# load data -------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(ggplot2)

# custom plot themes and maps
source("~/GitHub/federal-firearms-licenses/R/00-pd-themes.R")
source("~/GitHub/federal-firearms-licenses/R/00-usa-map-prep.R")
source("~/GitHub/federal-firearms-licenses/R/00-capwords.R")

# Map of States - Simple -------------------------------------

library(maps)
library(mapproj)
library(rgdal)

# Map of States ~ County -------------------------------------------------------

# READ IN SHAPEFILE
tl <- readOGR(dsn = "/Users/pdpd/GitHub/ffl-data/tl_2015_us_county",
              layer = "tl_2015_us_county")

tl.county <- fortify(tl, region = "NAME")

# read in data, bind to us.county map
counties <- read.csv("~/GitHub/ffl-data/PctUrbanRural_County.csv", stringsAsFactors = F)
colnames(counties)[3] <- "NAME"
colnames(counties)[4] <- "id"

tl.counties <- left_join(tl.county, counties)
levels(tl.counties$group) # 3395

# Map: Continental United States Urban PopPct by County  ----------------------

# filter out AK and HI
tlc02 <- tl.counties %>%
  filter(NAME != "Alaska", NAME != "Hawaii", NAME != "Puerto Rico",
         lat < 50, lat > 20) %>%
  select(long, lat, order, hole, piece, id, group, NAME, POPPCT_URBAN)

rm(tl.counties)

# factor group and NAME variables
tlc02$group <- factor(tlc02$group)
levels(tlc02$group) #3194

tlc02$NAME <- factor(tlc02$NAME)
levels(as.factor(tlc02$NAME))

# map urban population percentage by county
ggplot(tlc02, aes(long, lat, 
                  group = group,
                  fill = POPPCT_URBAN)) +
  geom_polygon(color = "white", size = 0.025) +
  scale_fill_gradient2(low = "firebrick4",
                       mid = "antiquewhite2",
                       high = "deepskyblue4",
                       midpoint = 50) + 
  coord_map("polyconic") + 
  pd.theme +
  theme(legend.position = "right",
        panel.background = element_blank(),
        panel.grid = element_blank(),
        axis.text = element_blank()) +
  guides(fill = guide_legend(reverse = T)) +
  labs(title = "Urban Population Percentage by County", 
       x = "", y = "", fill = "")

# Map: WY urban population percentage by county -------------------------------

# subset for Wyoming
wy <- tl.counties %>%
  filter(NAME == "Wyoming",
         long > -112, long < -105,
         lat > 40, lat < 45)

wy$STATE <- factor(wy$STATE)
wy$group <- factor(wy$group)
levels(wy$group)

# map urban population percentage by county
ggplot(wy, aes(long, lat, 
               group = group,
               fill = POPPCT_URBAN)) +
  geom_polygon(color = "white", size = 0.025) +
  scale_fill_gradient2(low = "firebrick4",
                       mid = "antiquewhite2",
                       high = "deepskyblue4",
                       midpoint = 50) + 
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right") +
  guides(fill = guide_legend(reverse = T)) +
  labs(title = "Urban Population Percentage by County", 
       x = "", y = "", fill = "")

# Alaska ----------------------------------------------------------------------
# subset for Alaska
ak <- tl.counties %>%
  filter(NAME == "Alaska", long < 100, id != "Petersburg")

ak$group <- factor(ak$group)
levels(ak$group)

summary(ak$long)

# map urban population percentage by county
ggplot(ak, aes(long, lat, 
               group = group,
               fill = POPPCT_URBAN)) +
  geom_polygon(color = "white", size = 0.025) +
  scale_fill_gradient2(low = "firebrick4",
                       mid = "antiquewhite2",
                       high = "deepskyblue4",
                       midpoint = 50) + 
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right",
        panel.grid = element_blank(),
        axis.text = element_blank()) +
  guides(fill = guide_legend(reverse = T)) +
  labs(title = "Urban Population Percentage by County", 
       x = "", y = "", fill = "")

# Montana ----------------------------------------------------------------------
# subset for Montana
mt <- tl.counties %>%
  filter(NAME == "Montana", long > -116, long < -104, lat > 45)

mt$group <- factor(mt$group)
levels(mt$group)

summary(mt$long)

# map urban population percentage by county
ggplot(mt, aes(long, lat, 
               group = group,
               fill = POPPCT_URBAN)) +
  geom_polygon(color = "white", size = 0.025) +
  scale_fill_gradient2(low = "firebrick4",
                       mid = "antiquewhite2",
                       high = "deepskyblue4",
                       midpoint = 50) + 
  coord_map("polyconic") + pd.theme +
  theme(legend.position = "right") +
  guides(fill = guide_legend(reverse = T)) +
  labs(title = "Urban Population Percentage by County", 
       x = "", y = "", fill = "")


# Map: Federal Firearms Licenses by County ------------------------------------

# read in raw FFL data
ffl <- read.csv("~/GitHub/ffl-data/ffl-2015.csv")
ffl <- unique(ffl)
str(ffl)

colnames(ffl)[10:11] <- c("id", "NAME")
ffl$id <- tolower(ffl$id)
ffl$id <- capwords(ffl$id)
levels(as.factor(ffl$id))

# merge with lat-lon data
ffl.counties <- left_join(ffl, tl.county)

ffl.counties <- ffl.counties %>%
  filter(NAME != "AK", NAME != "HI", NAME != "PR",
                  lat < 50, lat > 20)

ffl.counties[!is.na(ffl.counties$STATE),]
levels(as.factor(ffl.counties$STATE))

summary(ffl.counties)




