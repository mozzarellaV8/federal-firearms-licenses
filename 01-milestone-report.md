# ATF Federal Firearms License data
_milestone report_

Can general characteristics on the American population provide insight relating to firearms? Or conversely - by examining Federal Firearms License data, can something be learned about the American population? 

Data from the [US Census](https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/) and National Conference of State Legislatures ([NCLS](http://www.ncsl.org/)) were acquired<sup>[1](#Notes)</sup>, on different characteristics such as:

- Educational Attainment - high school and college graduate populations, by age bracket
- Financial Characteristics - annual household income, by income bracket
- Industry by Class of Worker - state populations by 14 broad industries
- state government and legislation 
- rural-urban proportions: populations and land areas
- general population

State legislator data acquired from NCLS came in the form of PDF files with tables; these were imported into [Tabula](http://tabula.technology/) to be processed into CSV to read into R. 

US Census data on education, finance, and industry were downloaded as CSVs from the Census site, and required a large amount of filtering and cleansing. Generally speaking, the data is very fine-grain - often with far too many variables per state to be used meaningfully. For example, _Educational Attainment_ data came with 53 observations of 771 variables; _Financial Characteristics_ comprised 53 observations of 279 variables. These datasets were filtered down to select variables so that they could used for model building. 

 [Federal Firearms License](https://www.atf.gov/firearms/listing-federal-firearms-licensees-ffls-2016) data is available monthly, in .xlsx or .txt files. I'd downloaded all .xlsx files available into different folders by year. 

CSVs with annual FFL totals were created by:
 - creating a list of .xlsx files corresponding to directory by year
 - initializing a dataframe
 - using a `for` loop to read in each .xlsx file
 - binding each monthly .xlsx into a single dataframe

```{R}
y2015dir <- "~/Documents/ATF-FFL/data/2015"
setwd(y2015dir)

y2015.list <- list.files(path = y2015dir, pattern = ".xlsx", recursive = T, all.files = T)
y2015 <- data.frame()

system.time(
for(i in 1:length(y2015.list)) {
  
  temp <- read_excel(y2015.list[i])
  temp <- temp[-1, ]
  temp$`Expire Date` <- ""
  
  temp$year <- as.factor("2015")
  temp$month <- paste(y2015.list[i])
  temp$month <- gsub(".xlsx", "", temp$month)
  temp$month <- gsub("15", "", temp$month)
  
  y2015 <- rbind(temp, y2015)
  
}
)

#    user  system elapsed 
#  16.990   2.628  19.650
```


 
 # Notes
 
 <sup>1</sup>  corresponding US Census dataset names:
 - table S1501, _"Educational Attainment"_ 
 - table S2503, _"Finanacial Characteristics"_
 - table S2407, _"Industry by Class of Worker for the Civilian Employed Population 16 Years and Over"_
 - _"Overiew: Legislator Data - State Partisan Composition"_, [NCLS](http://www.ncsl.org/research/about-state-legislatures/partisan-composition.aspx), [2014 data](http://www.ncsl.org/documents/statevote/legiscontrol_2014.pdf)
 - _"2010 Census Urban and Rural Classification and Urban Area Criteria"_, [US Census](https://www.census.gov/geo/reference/ua/urban-rural-2010.html)





