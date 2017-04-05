# Firearms Licenses in the United States
**Milestone Report** - Foundations of Data Science

- [The Problem](#the-problem)
- [Inversely Proportional?](#inversely-proportional)
- [The Data](#the-data)

Contents:
1. An introduction to the problem.
2. A deeper dive into the data set:
- What important fields and information does the data set have?
- What are its limitations i.e. what are some questions that you cannot answer with this data set?
- What kind of cleaning and wrangling did you need to do?
- Any preliminary exploration you’ve performed and your initial findings.
- Based on these findings, what approach are you going to take? How has your approach changed from what you initially proposed, if applicable?

## The Problem

Can general characteristics on the American population provide insight relating to firearms - specifically what might contribute to the number of firearms licenses in a given state? Or conversely - by examining Federal Firearms License data, can something be learned about the American population? 

## Inversely Proportional?






## The Data

Data was acquired from multiple sources to build a set of characteristics about the American population in relation to firearms licenses. The  most important sources are the [Bureau of Alcohol, Tobacco, and Firearms (ATF)](https://www.atf.gov/firearms/listing-federal-firearms-licensees-ffls-2016) and the [United States Census](). 

#### **What this Data CAN NOT do**

- **Provide total numbers for firearms in the United States.** Why not? The data comprises Federal Firearms License holders - FFLs being a  requirement for those who engage in the _business of firearms_ - generally **dealers**, **manufacturers**, and **importers**.
- **Account for all gun owners in the US.** FFLs again are a requirement for conducting business, and additionally gun shows are generally exempt from needing an FFL to operate. 
- **Establish ground-truths** for why firearms exist in some places more than others, or any other causal conclusions. 
- Again, because of exceptions in certain laws, and the existence of black market trade - only those with Federal Firearms Licenses will be considered.

#### **What this Data CAN do**

- **Build a set of features of the American public in relation to firearms licenses**. These 'features' include **educational**, **economic**, **legislative**, **race**, and **workforce** characteristics by state.
- **Establish broad patterns and identify outliers in US firearm culture**. By providing an overview of firearms trends and anomolies across the states, more specific questions can be asked in regards to firearms. 
- **Provide a foundation for further exploration**, with finer grain data in any of the above mentioned fields. For example - if the relationship between _**working class industry**_ and _**firearms licenses**_ was of interest, then finer grain data than that provided by the US Census could be used to cross-compare against firearms data provided by the ATF. 



### ATF Federal Firearms License data

[Federal Firearms License](https://www.atf.gov/firearms/listing-federal-firearms-licensees-ffls-2016) data is available monthly, in .xlsx or .txt files. I'd downloaded all .xlsx files available, and grouped them into different folders by year. 

CSVs with annual FFL totals were created by:
 - creating a list of .xlsx files corresponding to directory by year
 - initializing a dataframe
 - using a `for` loop to read in each .xlsx file
 - adding the month and year as variables
 - binding each monthly .xlsx into a single dataframe

This data comprised many fields, such as business name, license holder name, full addresses for mailing and premise, phone number. While interesting to have, what became most important was to calculate monthly total FFLs by state, and from there derive monthy per capita (100,000) FFL counts by state.

### United States Census data

Data from the [US Census](https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/) were acquired<sup>[1](#Notes)</sup>, on different the total population and different attributes of America. 

- _"National Population Totals Datasets: 2010-2016"_, [US Census](https://www.census.gov/data/datasets/2016/demo/popest/nation-total.html).
- _"2010 Census Urban and Rural Classification and Urban Area Criteria"_, [US Census](https://www.census.gov/geo/reference/ua/urban-rural-2010.html).

National population totals were acquired to merge with ATF firearms license data - to begin answering basic 

- _"Educational Attainment"_, [US Census - American Community Survey](https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/), table S1501.
- _"Finanacial Characteristics"_, [US Census - American Community Survey](https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/), table S2503.
- _"Industry by Class of Worker for the Civilian Employed Population 16 Years and Over"_, [US Census - American Community Survey](https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/), table S2407.

US Census data on education, finance, and industry were downloaded as CSVs from the Census site, and required a large amount of filtering and cleansing. For example, _Educational Attainment_ data came with 53 observations of 771 variables; _Financial Characteristics_ comprised 53 observations of 279 variables. These datasets were filtered down to select variables so that they could used for model building. 

## National Conference of State Legislators data

State legislator data acquired from NCLS came in the form of PDF files with tables; these were imported into [Tabula](http://tabula.technology/) to be processed into CSV to read into R. 

 - _"Legislator Data - State Partisan Composition"_, [NCSL](http://www.ncsl.org/research/about-state-legislatures/partisan-composition.aspx), [2014 data](http://www.ncsl.org/documents/statevote/legiscontrol_2014.pdf)



 
 # Notes
 
 <sup>1</sup>  corresponding US Census dataset names:
 - _"Educational Attainment"_, [US Census - American Community Survery](https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/), table S1501.
 - _"Finanacial Characteristics"_, [US Census - American Community Survery](https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/)table S2503.
 - _"Industry by Class of Worker for the Civilian Employed Population 16 Years and Over"_, [US Census - American Community Survery](https://www.census.gov/acs/www/data/data-tables-and-tools/subject-tables/), table S2407.
 - _"National Population Totals Datasets: 2010-2016"_, [US Census](https://www.census.gov/data/datasets/2016/demo/popest/nation-total.html)
 - _"2010 Census Urban and Rural Classification and Urban Area Criteria"_, [US Census](https://www.census.gov/geo/reference/ua/urban-rural-2010.html)







