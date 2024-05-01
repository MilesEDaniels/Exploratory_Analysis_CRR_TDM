# Cohort Replacement and TDM 
Last updated 5/1/2024, Miles Daniels (miedanie@ucsc.edu)

Script to explore relationship between cohort replacement rate (CRR) and temperature-dependent mortality (TDM) for Winter-Run Chinook salmon on the Sacramento River

_Simulations last ran with R version 4.3.2 (2023-10-31) -- "Eye Holes"_

_Note 1: recent data provided by USFWS allows for adjustment of hatchery returnss from 2001 to 2022. We are estimating the relationship from 1996-2022 assuming minimal hatchery influence prior to 2001_

_Note 2: models have only undergone preliminary diagnostics to look for clear miss-specificaiton._

To start we can plot the data. We have CRR and TDM from 1996-2022. Assume that the average age of returning adults is 3 years.
The eqaution to calculate the  CRR is:  $$\frac{E_i}{E_{i-3}}$$

Where _E_ is the total estimated run for year _i_.

We can also adjust for hatchery influence to better constrain for the actual number of the populaiton that experiecned TDM for a given year. 

The eqaution to calculate the adjusted CRR is:  $$\frac{E_i-H_i}{E_{i-3}}$$

Where _E_ is the total estimated run for year _i_, _H_ is the hatchery estimated run.

## Below are time series for CCR and TDM. 
![plot](Raw_CRR_and_TDM_5_1_24.png)

Another way to look at this data, however, is shown below where the time series of CRR is plotted, but each year is color coded by brood year TDM. Looking at the data this way seems to show that brood years with a significant amount of TDM often have a CRR of < 1. This relationship is even more apparent when looking at CRR on the log scale, which may be more approproate to detect the importance of CRR below 1.

## Below is a time series of CRR color coded by TDM.
![plot](TDM_Color_Coded_CRR_5_1_24.png)

We can also explore if there is a linear relationship between log CRR and TDM. We can add the model fit, 95% CI, and R<sup>2</sup>. 

## Below is a plot of the linear model with log CRR as the response and TDM as the predictor.
![plot](Linear_Model_CRR_TDM_5_1_24.png)

The fits result in a negative slope for the relationship (_P_ < 0.05) indicating that as TDM increases, CRR decreases. _Note that since both quanities use carcass survey data, they are not independent and spurious relationships can occur._ 

# Conclusions, caveates, and future work 

Overall, the linear model describing the relationship between TDM and log CRR captures 45% of the variaiton in the response variable and suggestes a strong negative association, such that increased TDM reduces CRR.

However, there are years where TDM was low and CRR was < 1, indicating that other factors not included in this model are responsible for low adult returns. For example, in 2006 TDM was estimated to be zero, but CRR was well below 1. This year happened to predicted as a very poor ocean entry suruval year (Vasbinder et al, 2024; https://onlinelibrary.wiley.com/doi/pdfdirect/10.1111/fog.12654) and lends support that other factors realted to this realtionship should be explored.

We also made simplifying assumptions about CRR, such as not using fully reconstructed cohorts, not adjusting for ocean harvest, and pre-spawn mortality among other things. 

Lastly, this work is currenly exploratory in nature and should be interpreted as such.
