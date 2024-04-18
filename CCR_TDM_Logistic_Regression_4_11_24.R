
# set working directory and load data
setwd("/Volumes/MD_Working/Models/Cohort_Replacement")

Dat<- read.csv("Escapment_1970_2022_GrandTab.csv", header=T, stringsAsFactors=F)
YrUseIdx = which(Dat$Year >= 2001) # reduce to years provided by USFWS report
Dat = Dat[YrUseIdx,]

# Calculate adjusted model by hatchery numbers and age. CRR is for age 3.
CRR_Adjust = matrix(NA,nrow =length(Dat$Year)-3, ncol = 4)
for (i in 4:length(Dat$Year)){
  CRR_Adjust[i-3,2] =  ((Dat$Escapment[i]-(Dat$Hatchery_Origin[i]*Dat$Percent_Age3_Hatchery[i]))*Dat$Percent_Age3_or_More_Natrual[i])/((Dat$Escapment[i-3]-(Dat$Hatchery_Origin[i-3]*Dat$Percent_Age3_Hatchery[i-3]))*Dat$Percent_Age3_or_More_Natrual[i-3])
  CRR_Adjust[i-3,1] =  Dat$Year[i]
  if(CRR_Adjust[i-3,2] < 1)
  {
    CRR_Adjust[i-3,3] =  0
  }else
  {
    CRR_Adjust[i-3,3] =  1 
    }
}

# Link TDM to Year
Dat_TDM<- read.csv("CRR_TDM_Table_4_1_24.csv", header=T, stringsAsFactors=F)
for (i in 1:length(CRR_Adjust[,1])){
  TDMIdx = which(Dat_TDM$CRR_Year == CRR_Adjust[i,1])
  CRR_Adjust[i,4] = Dat_TDM$TDM[TDMIdx]
}
colnames(CRR_Adjust) <- c('CRR_Year','CRR', 'CRR_Binary', 'TDM') 
CRR_Adjust= as.data.frame(CRR_Adjust)
write.csv(CRR_Adjust, "Cohort_Replacement_Table_4_11_24.csv", row.names=F)

# Calculate non-adjusted model by hatchery numbers and age
Dat<- read.csv("Escapment_1970_2022_GrandTab.csv", header=T, stringsAsFactors=F)
YrUseIdx = which(Dat$Year >= 1990) # reduce to years provided by USFWS report 
Dat = Dat[YrUseIdx,]

CRR_No_Adjust = matrix(NA,nrow =length(Dat$Year)-3, ncol = 4)
for (i in 4:length(Dat$Year)){
  
  CRR_No_Adjust[i-3,2] =  Dat$Escapment[i]/Dat$Escapment[i-3]
  CRR_No_Adjust[i-3,1] =  Dat$Year[i]
  if(CRR_No_Adjust[i-3,2] < 1)
  {
    CRR_No_Adjust[i-3,3] =  0
  }else
  {
    CRR_No_Adjust[i-3,3] =  1 
  }
}

# Link TDM to Year
Dat_TDM<- read.csv("CRR_TDM_Table_4_1_24.csv", header=T, stringsAsFactors=F)
for (i in 1:length(CRR_No_Adjust[,1])){
  TDMIdx = which(Dat_TDM$CRR_Year == CRR_No_Adjust[i,1])
  CRR_No_Adjust[i,4] = Dat_TDM$TDM[TDMIdx]
}
colnames(CRR_No_Adjust) <- c('CRR_Year','CRR', 'CRR_Binary', 'TDM') 
CRR_No_Adjust= as.data.frame(CRR_No_Adjust)
write.csv(CRR_No_Adjust, "Cohort_Replacement_Table_4_1_24.csv", row.names=F)


# Some quick plots
# plot time series of CRR and TDM
png("CRR_TDM_Raw_Hatchery_Age_Adjusted.png", height=4000, width=2000, units="px", res=300)
par(mfrow = c(2, 1))
plot(CRR_Adjust$CRR_Year , CRR_Adjust$CRR, data=CRR_Adjust, xlab="Year", ylab="CRR", main="", xlim=c(2004,2022))
lines(CRR_Adjust$CRR_Year , CRR_Adjust$CRR, col="blue", lty=2, lwd=2)
plot(CRR_Adjust$CRR_Year , CRR_Adjust$TDM, data=CRR_Adjust, xlab="Year", ylab="TDM", main="", xlim=c(2004,2022))
lines(CRR_Adjust$CRR_Year , CRR_Adjust$TDM, col="blue", lty=2, lwd=2)
dev.off()


# build linear model of CRR and TDM
linear_model = lm(CRR~TDM, data = CRR_Adjust)
Predicted_data <- data.frame(TDM=seq(0, 1,len=500))
preds = predict(linear_model, newdata = Predicted_data, type = "response", se.fit = TRUE)
conf_interval <- predict(linear_model, newdata=Predicted_data, interval="confidence", level = 0.95)
summary(linear_model)$r.squared 

# plot linear model
png("Linear_Model_Hatchery_Age_Adjusted.png", height=2000, width=2000, units="px", res=300)
plot(CRR_Adjust$TDM, CRR_Adjust$CRR, xlab="TDM", ylab="CRR", main="Linear Regression", ylim =c(0,14))
abline(linear_model, col="lightblue",lwd=2)
lines(t(Predicted_data), conf_interval[,2], col="blue", lty=2, lwd=2)
lines(t(Predicted_data), conf_interval[,3], col="blue", lty=2, lwd=2)
text(.8, 7.5, paste0("R2 = ", round(summary(linear_model)$r.squared,2)))
dev.off()


# create logistic regression model
logistic_model <- glm(CRR_Binary ~ TDM, data=CRR_Adjust, family=binomial)
preds = predict(logistic_model, newdata = Predicted_data, type = "link", se.fit = TRUE)
Predicted_data$CRR_Binary = predict(logistic_model, Predicted_data, type="response")
# estimate confidence interval
critval <- 1.96
upr <- preds$fit + (critval * preds$se.fit)
lwr <- preds$fit - (critval * preds$se.fit)
fit <- preds$fit
fit2 <- logistic_model$family$linkinv(fit)
upr2 <- logistic_model$family$linkinv(upr)
lwr2 <- logistic_model$family$linkinv(lwr)

# Plot Predicted data and original data points
png("Logistic_Model_Hatchery_Age_Adjusted.png", height=2000, width=2000, units="px", res=300)
plot(CRR_Binary ~ TDM, data=CRR_Adjust, xlab="TDM", ylab="CRR Binary", main="Logistic Regression")
lines(fit2 ~ TDM, Predicted_data, lwd=2, col="lightblue")
lines(upr2 ~ TDM, Predicted_data, lwd=2, col="blue", lty=2)
lines(lwr2 ~ TDM, Predicted_data, lwd=2, col="blue", lty=2)
dev.off()
