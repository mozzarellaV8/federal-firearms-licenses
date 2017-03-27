# Federal Firearms Licenses in the United States

Mass shootings are an unfortunate [characteristic of the United States](https://en.wikipedia.org/wiki/Category:Mass_shootings_in_the_United_States_by_year)<sup>[1](#notes)</sup>, and generally their occurence is the main time that issues of firearms are brought to national attention. Debates on gun control tend to follow, and tend to be highly charged or emotional. While accusations, greivances, and demands are publicly aired - it's difficult to discern if changes actually happen or if causes are truly discovered. 

This project doesn't aim to find the root causes of gun violence; rather, it seeks to understand broader characterstics of America and it's relationship to firearms. Looking at data from state to state, different features - such as education, economics, and legislation - can be examined in relation to firearms. Often with firearms there are groundless ideas or -isms that are repeated until they seem true. Ideally this project would establish general features of state populations and look at how those features relate to the number of firearms - while resisting naming single causes or claiming ground-truths. 

In short - building a set of characteristics about America that hopefully provide building blocks for better insight into firearms. 

The "client" I have in mind for this would be a news/media source - ideally a not-for-profit, independent (such as ProPublica, NPR) that values deeper investigation over sensational headlines or clicks. With this data, the "client" could feasibly craft a story with the backing of historical data and analysis - or dispute the findings to tell another story. 

To do this, data on **Federal Firearms Licenses** would be gathered from the ATF - along with **US Census data** pertaining to fields of **_education_**, **_income**_, **_industry_**, **_legislation_**, and **_population_**. What characteristics of American populations by state show tendencies toward more firearms licenses, and which towards less? After exploratory visualizations and analysis, robust regression models will be fit and regression trees will be grown - to corroborate prevailing ideas or dispute them. 

## What is a Federal Firearms License?

In the United States, a Federal Firearms License (FFL) is a requirement for those who engage in the business of firearms - generally **dealers**, **manufacturers**, and **importers**. 

It's not actually a license to carry a firearm; it's strictly for conducting business involving firearms. It's not necessary to have one if selling at gun shows, or when purchasing guns for personal reasons. 

The ATF considers 9 __types__ of FFLs: 

- Dealer
- Pawnbroker
- Collector
- Manufacturer of Ammunition
- Manufacturer of Firearms
- Dealer in Destructive Devices
- Manufacturer of Destructive Devices
- Importer of Destructive Devices

The ATF [publishes data on this FFL holders](https://www.atf.gov/firearms/listing-federal-firearms-licensees-ffls-2016) monthly, generally with the present year and two years previous. 

Additionally, an [annual commerce report](https://www.atf.gov/resource-center/data-statistics) is released, which contains numbers on weapons registrations, imports and taxes, and historical FFL data. With historical FFL data, we can broadly see how license counts have changed over time - from 1975-2015. 

## A Brief History in Numbers

Before delving into American characteristics and how they relate to Federal Firearms Licenses, a quick look at the ATF Commerce Report provides a numerical history of FFLs - something to establish our place in time. 

By the 9 Types of FFLs as defined by the ATF, how have the counts changed from 1975 to 2015<sup>[1](#works-cited)</sup>?

![FFL-History](presentation/assets/TypesOverTime.jpg)

- Looking specifically at Destructive Devices - the number has increased steadily and heavily since 1975.
- Manufacturers of Ammunition have gone down dramatically.
- around 2010, Manufacturers of Firearms began to increase steadily.
- peak of all FFL types appears to have happened in the early 1990s.

# Notes

<sup>1</sup> Mass shootings in the United States by year, [Wikipedia](https://en.wikipedia.org/wiki/Category:Mass_shootings_in_the_United_States_by_year). Accessed March 27th, 2017. 

<sup>2</sup>Tufte-style sparkline plot originally translated to R by [Lukasz Piwek](http://motioninsocial.com/tufte/).