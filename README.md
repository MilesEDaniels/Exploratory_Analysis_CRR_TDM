# Cohort Replacement and TDM 
Last updated 4/18/2024, Miles Daniels (miedanie@ucsc.edu)

**Script to explore relationship between Cohort Replacement Rate and TDM for Winter-Run

_Simulations last ran with R version 4.3.2 (2023-10-31) -- "Eye Holes"_

To start we can plot raw data. We have TDM and CRR from 1990-2022. Assume that the average age of returning adults is 3 years. This means that to see the relationship between CRR and TDM for the first year of available data we would take the population of adults in 1993 and divide by the populaiton in 1990 to get the CRR. We would then take the TDM estimated in 1990 and apply this to the 1993 CRR.

The eqaution to calculate the  CRR is:  $$\frac{E_i}{E_{i-3}}$$

Where _E_ is the total estimated run for year _i_.

_Note 1: recent data provided by USFWS that allows for adjustment of hatchery retunrs and age of returning fish only goes from 2001 to 2022._

_Note 2: models have only undergone preliminary diagnostics to look for clear miss-specificaiton_

## Below are time series for CCR and TDM.These are raw values that are not adjusted for hatchery or age.
![plot](CRR_TDM_Raw.png)

## What if we adjust for hatchery influence and use age data to better constrain for the actual number of the populaiton that experiecned TDM for a given year. 

The eqaution to calculate the adjusted CRR is:  $$\frac{(E_i-(H_i\times{H3_i}))\times{N3_i}}{(E_{i-3}-(H_{i-3}\times{H3_{i-3}}))\times{N3_{i-3}}}$$

Where _E_ is the total estimated run for year _i_, _H_ is the hatchery estimated run, _H3_ is the percent of age 3 hatchery origin, and _N3_ is the percent of age 3 or more natural origin fish. Note that while all hatchery fish are aged to year, natural are only classified as 2 year or 3 and older.

Adjusting for hatchery and age results in the updated plots that are shown below and are in similar format to the plots above.

## Below is a time series of CRR color coded by TDM after adjusting for hatchery and age.
![plot](CRR_Time_TDM_Coded_Hatchery_Age_Adjusted.png)


## Below is a plot of the linear model after adjusting for hatchery and age.
![plot](Linear_Model_Hatchery_Age_Adjusted.png)

## Below is a plot of the logistic model after adjusting for hatchery and age.
![plot](Logistic_Model_Hatchery_Age_Adjusted.png)
