# Firearms Licenses in the United States
**Milestone Report** - [Foundations of Data Science](https://www.springboard.com/workshops/data-science/#curriculum-syllabus-ctn)

- [The Problem](#the-problem)
- [Inversely Proportional?](#inversely-proportional)
- [Potential Approaches](#potential-approaches)
- [The Data](#the-data)
- [Notes](#notes)

# The Problem

Can general characteristics on the American population provide insight relating to firearms - specifically what might contribute to the number of firearms licenses in a given state? 

Or conversely - by examining Federal Firearms License data, can something be learned about the American population? How much influence do factors such as education, income, legislation, and race have on the number of firearms licenses in a given state - if any at all? 

# Inversely Proportional?
## **Initial Discoveries with Firearms Licenses and Populations**

Staring out simply: which states have the most Federal Firearms Licenses (FFLs), and which states are the most populous?

![bar-comparison-01](presentation/vis/eda-ffl-bars-V0.jpg)

Interestingly, Wyoming tops the list for FFLs while being the least populous state. Could there be a relationship between a state's population and the number of Federal Firearms Licenses? 

Another quick bar chart might clear things up - with _per capita FFLs_ mapped to bar length, and _state population_ mapped to color fill. 

![bar-ffl-fill](presentation/vis/ffl-eda-by-state-pop.jpg)

While Texas has many more _total_ FFLs than Wyoming or Montana, when adjusted per capita the FFL-to-resident ratio appears average.

There's just over 10 Federal Firearms Licenses for every 10,000 residents of Wyoming and Montana, compared to less than 2.5 for Texas. There's _less than one_ Federal Firearms License for every 10,000 for New Yorkers or Californians - two of the most populous states in the US. 

Per 100,000 adjusted - there is one Federal Firearms License for every 1,000 residents of Wyoming or Montana. 1:1000. 


![ffl-eda](presentation/vis/ffl-eda-scatterplot-01-V2.jpg)

Log transforming the population yields a trend that appears more linear, with outliers coming from the extreme low end of the FFL count. Withouth the log transform, outliers could be seen at the tails - in extremely high FFL counts or extremely high state populations.

![ffl-pop - log scale](presentation/vis/ffl-eda-scatterplot-log.jpg)


Could FFLs and Population really be inversely proportional?? Maybe not exactly so (i.e. _y = <sup>1</sup>/<sub>x</sub>_ ), but rough visual inspection seems to suggest such a trend. Put bluntly: 

- more populous states --> less firearms licenses
- less populous states --> more firearms licenses

What is it about different states' populations that drives this seemingly inverse trend? Is the pattern really inverse at all? 

Can looking at different characteristics of state populations show deeper relationships? 

![population map](presentation/vis/ffl-eda-map-population.jpg)
![ffl map](presentation/vis/ffl-eda-map-ffl.jpg)

# Potential Approaches

- Robust Regressions - to identify outliers with calculated weights
- Robust Regressions with outliers removed
- Regression Trees
- Nonlinear regression
- Zipf Distribution fitting

# The Data

Since population seems to have a relationship with FFLs, what attributes of each state contribute to, or define,  its population? 

Things that came to mind were **land area**, **urban vs. rural population**, and **state goverment/voting tendencies**. To further investigate, data was acquired from multiple sources to build a set of characteristics about the American population in relation to firearms licenses. Most relevant data were from: 

-  [Bureau of Alcohol, Tobacco, and Firearms (ATF)](https://www.atf.gov/firearms/listing-federal-firearms-licensees-ffls-2016)
-  [United States Census](https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/)
-  [National Conference of State Legislators](http://www.ncsl.org/research/about-state-legislatures/partisan-composition.aspx)

#### **What these Data CANNOT do**

- **Provide total numbers for firearms in the United States.** Why not? The data comprises Federal Firearms License holders - FFLs being a  requirement for those who engage in the _business of firearms_ - generally **dealers**, **manufacturers**, and **importers**.
- **Account for all gun owners in the US.** FFLs again are a requirement for conducting business, and additionally gun shows are generally exempt from needing an FFL to operate. 
- **Establish ground-truths** for why firearms exist in some places more than others, or any other causal conclusions. 

#### **What these Data CAN do**

- **Build a set of features of the American public in relation to firearms licenses**. These 'features' include **educational**, **economic**, **legislative**, **race**, and **workforce** characteristics by state.
- **Establish broad patterns and identify outliers in US firearm culture**. By providing an overview of firearms trends and anomolies across the states, more specific questions can be asked in regards to firearms. 
- **Provide a foundation for further exploration**, with finer grain data in any of the above mentioned fields. For example - if the relationship between _**working class industry**_ and _**firearms licenses**_ was of interest, then finer grain data than that provided by the US Census could be used to cross-compare against firearms data provided by the ATF. 

Again, because of exceptions in certain laws, and the existence of black market trade - only Federal Firearms Licenses will be considered. FFLs, in this case, can be considered a certain 'metric' for a United States concensus on what is permissible (and possibly extreme) in firearms culture.

## United States Census

Data from the [US Census](https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/) were acquired<sup>[1](#Notes)</sup>, on different the total population and different attributes of America. They're numbered here to keep track - but reflect no rank or order.

1. _"National Population Totals Datasets: 2010-2016"_, [US Census](https://www.census.gov/data/datasets/2016/demo/popest/nation-total.html).
2. _"2010 Census Urban and Rural Classification and Urban Area Criteria"_, [US Census](https://www.census.gov/geo/reference/ua/urban-rural-2010.html). ![](presentation/vis/rural-urban-map-EDA-V3.jpg)
3. _"Educational Attainment"_, [US Census - American Community Survey](https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/), table S1501. High School and College graduation by one of five age brackets as defined by the US Census. ![education scatterplot](vis/eda-education/edu-ffl-facet.png)
4. _"Finanacial Characteristics"_, [US Census - American Community Survey](https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/), table S2503.  Annual Household Income, stratified into 12 brackets by the US Census. ![](vis/eda-education/edu-ffl-facet.png)
5. _"Industry by Class of Worker for the Civilian Employed Population 16 Years and Over"_, [US Census - American Community Survey](https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/), table S2407. All workforce sectors: ![workforce-facet-all](presentation/vis/workforce-facet-all.png) ![ffl~hunting](presentation/vis/workforce-eda-ffl-hunting.jpg)

US Census data on education, finance, and industry were downloaded as CSVs from the Census site, and required a large amount of filtering and cleansing. For example:

-  _Educational Attainment_ data comprised 53 observations of 771 variables,
-  _Financial Characteristics_ comprised 53 observations of 279 variables

These datasets were filtered down to select variables so that they could used for model building.  Beyond total population estimates per category, most of the variables were Census-provided derivations of the totals, e.g. percentages. 

## National Conference of State Legislators

State legislator data was acquired from the National Conference of State Legislators, and came in the form of PDF files with tables; these were imported into [Tabula](http://tabula.technology/) to be processed into CSV to read into R. 

 - _"Legislator Data - State Partisan Composition"_, [NCSL](http://www.ncsl.org/research/about-state-legislatures/partisan-composition.aspx), [2014 data](http://www.ncsl.org/documents/statevote/legiscontrol_2014.pdf)

This data comprised numerical fields by state, providing totals for State (not Federal) governing bodies. Of particular interest:

- Senate Democrats
- Senate Republicans
- House Democrats
- House Republicans
- Legislative Control 
- Governing Party
- State Control

**Legislative Control** refers to the majority party in State Senate and State House, and **Governing Party** refers to party of the governorship. **State Control** is determined by the parties in control of Legislative and Governing branches.

![legislative EDA heatmap 02](presentation/vis/legislative-EDA-heatmap-02.jpg)

## ATF Federal Firearms Licenses

Finally, [Federal Firearms License](https://www.atf.gov/firearms/listing-federal-firearms-licensees-ffls-2016) data<sup>[1](#Notes)</sup> is available monthly from the ATF website, in .xlsx or .txt files. I'd downloaded all .xlsx files available, and grouped them into different folders by year. 

CSVs with annual FFL totals were created by:
 - creating a list of .xlsx files corresponding to directory by year
 - initializing a dataframe
 - using a `for` loop to read in each .xlsx file
 - adding the month and year as variables
 - binding each monthly .xlsx into a single dataframe

This data comprised many fields, such as business name, license holder name, full addresses for mailing and premise, phone number.

What became most important was to calculate **monthly total FFLs by state**, and from there **derive monthy per capita (100,000) FFL counts by state**. Why? Often, FFL entries would repeat monthly, aslLicenses generally were granted on annual terms. After subsetting for unique license holder & business names - a monthly per capita metric seemed to be most suited to capturing FFL counts. 

For context, what _kind_ of FFLs are there? And what are the trends by type over time? 
![](presentation/assets/TypesOverTime.jpg)

 # Notes
 
 <sup>1</sup> names and sources for all datasets:  
- _"Listing of Federal Firearms Licensees (FFLs) - 2016"_, [Bureau of Alcohol, Tobacco, and Firearms (ATF)](https://www.atf.gov/firearms/listing-federal-firearms-licensees-ffls-2016), complete listings by month and year.
- _"National Population Totals Datasets: 2010-2016"_, [US Census](https://www.census.gov/data/datasets/2016/demo/popest/nation-total.html)
- _"2010 Census Urban and Rural Classification and Urban Area Criteria"_, [US Census](https://www.census.gov/geo/reference/ua/urban-rural-2010.html)
- _"Educational Attainment"_, [US Census - American Community Survery](https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/), table S1501.
- _"Finanacial Characteristics"_, [US Census - American Community Survery](https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/)table S2503.
- _"Industry by Class of Worker for the Civilian Employed Population 16 Years and Over"_, [US Census - American Community Survery](https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/), table S2407.
- _"Legislator Data - State Partisan Composition"_, [NCSL](http://www.ncsl.org/research/about-state-legislatures/partisan-composition.aspx), [2014 data](http://www.ncsl.org/documents/statevote/legiscontrol_2014.pdf)

<sup>2</sup> R scripts - functions and themes:
- [capwords function](R/00-capwords.R)
- [modified ggplot2 themes](R/00-pd-themes.R)
- [per capita function](R/00-per-capita.R)
- [United States mapping](R/00-usa-map-prep.R)

<sup>3</sup> R scripts - FFL data import & cleansing:
- [FFL - import](R/ffl-data-import.R)
- [FFL - cleanse](R/ffl-cleanse.R)
- [FFL - derive per capita](R/ffl-derive-per-capita.R)

 <sup>4</sup> R scripts - cross-data import & cleansing:
- [Cleanse - Educational Attainment](R/acs-cleanse-education.R)
- [Cleanse - Financial Characteristics](R/acs-cleanse-finance.R)
- [Cleanse - Legislature by State](R/acs-cleanse-legislature.R)
- [Cleanse - Race](R/acs-cleanse-race.R)
- [Cleanse - Rural-Urban Proportions](R/acs-cleanse-rural-urban.R)
- [Cleanse - Workforce Sector Populations](R/acs-cleanse-workforce.R)

<sup>5</sup> R scripts - exploratory data analysis
- [EDA - Federal Firearms Licenses](R/ffl-EDA.R)
- [EDA - Educational Attainment](R/eda-education.R)
- [EDA - Legislature by State](R/eda-legislature.R)
- [EDA - Workforce Sector](R/eda-workforce.R)

