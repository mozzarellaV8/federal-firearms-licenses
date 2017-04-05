# Federal Firearms Licenses and United States Populations

- [Project Proposal](00-project-proposal.md)
- [Milestone Report](01-milestone-report.md)
- [What is a Federal Firearms License?](#what-is-a-federal-firearms-license)
- [A Brief History in Numbers](#a-brief-history-in-numbers)
- [Notes](#notes)

### What is this project trying to do?

The **ATF** publishes data monthly on all **Federal Firearms License (FFL)** holders across the United States. This data is one facet of many in the broader culture of firearms in the US. 

This project doesn't aim to find the root causes of gun violence - rather, it seeks to understand broader characterstics of America and it's relationship to firearms. 

How do qualities of the American population look when viewed through the lens of firearms licenses? Do certain qualities conform to prevailing expectations? And are there others that might be unexpected? 

The United States Census provides estimates on different features of state populations. It covers broader aspects such as **education**, **economics**, and **race** - to more specific ones such as **fertility rates** and **types of internet subscriptions by household**. 

Comparing this to data from the ATF on Federal Firearms License holders - what trends or idiosyncracies might emerge? Where are there more firearms licenses - and what are these places like? Is the country as divided as the news makes it seem? Could capitalism - rather than democracy - be a stronger factor in the availability of firearms? 

Can developing features of the American population from data promote a a deeper understanding across different states, agendas, and ways of living?

Some of these questions are larger than the scope of any dataset. It's my hope that by examining foundational characteristics of the American population, these 'larger' questions can be approached with a fresh or mindful perspective. 

# What is a Federal Firearms License?

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

Additionally, an [annual commerce report](https://www.atf.gov/resource-center/data-statistics)<sup>[1](#notes)</sup> is released, which contains numbers on weapons registrations, imports and taxes, and historical FFL data. With historical FFL data, we can broadly see how license counts have changed over time - from 1975-2015. 

# A Brief History in Numbers

Before delving into American characteristics and how they relate to Federal Firearms Licenses, a quick look at the ATF Commerce Report provides a numerical history of FFLs - something to establish our place in time. 

By the 9 Types of FFLs as defined by the ATF, how have the counts changed from 1975 to 2015<sup>[2](#works-cited)</sup>?

![FFL-History](presentation/assets/TypesOverTime.jpg)

Quick observations:
- Looking specifically at Destructive Devices - the number has increased steadily and heavily since 1975.
- Manufacturers of Ammunition have gone down dramatically.
- Around 2010: Manufacture of Firearms began to increase steadily.
- peak of all FFL types appears to have happened in the early 1990s - what was happening in America at this time? 

# Notes
<sup>1</sup> _"Firearms Commerce Report in the United States"_, [atf.gov](https://www.atf.gov/resource-center/data-statistics)

<sup>2</sup>Tufte-style sparkline plot originally translated to R by [Lukasz Piwek](http://motioninsocial.com/tufte/).

