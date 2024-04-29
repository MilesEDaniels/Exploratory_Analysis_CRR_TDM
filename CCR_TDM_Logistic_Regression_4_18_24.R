
# set working directory and load data
setwd("/Volumes/MD_Working/Models/Cohort_Replacement")

Dat<- read.csv("Escapment_1970_2022_GrandTab.csv", header=T, stringsAsFactors=F)
YrUseIdx = which(Dat$Year >= 1996) # reduce to years provided by USFWS report
Dat = Dat[YrUseIdx,]

# based on correspondence with USFWS, we assume little hatchery influence earlier than 2001
# also we do not have age data for wild population pre 2001, so assume mean of data post 2000
YrAdjustIdx = which(Dat$Year >= 1996 & Dat$Year < 2001) # reduce to years provided by USFWS report
YrAdjustWithIdx = which(Dat$Year >= 2001) # reduce to years provided by USFWS report
Dat$Hatchery_Origin[YrAdjustIdx] = 0
Dat$Percent_Age3_or_More_Natrual[YrAdjustIdx] = mean(Dat$Percent_Age3_or_More_Natrual[YrAdjustWithIdx])

# Calculate adjusted model by hatchery numbers and age. CRR is for age 3.
CRR_Adjust = matrix(NA,nrow =length(Dat$Year)-3, ncol = 10)
for (i in 4:length(Dat$Year)){
  CRR_Adjust[i-3,2] =  ((Dat$Escapment[i]-(Dat$Hatchery_Origin[i]))*Dat$Percent_Age3_or_More_Natrual[i])/((Dat$Escapment[i-3]-(Dat$Hatchery_Origin[i-3]))*Dat$Percent_Age3_or_More_Natrual[i-3])
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
Dat_TDM<- read.csv("TDM_Temp_ETF_CCR_table_1996_2022.csv", header=T, stringsAsFactors=F)
for (i in 1:length(CRR_Adjust[,1])){
  TDMIdx = which(Dat_TDM$TDM_Year == CRR_Adjust[i,1]-3)
  CRR_Adjust[i,4] = Dat_TDM$TDM[TDMIdx] # TDM
  CRR_Adjust[i,5] = Dat_TDM$Mean_Temp_F[TDMIdx] # mean temp
  CRR_Adjust[i,6] =  CRR_Adjust[i,1]-3
  CRR_Adjust[i,8] =  CRR_Adjust[i,1]
  CRR_Adjust[i,10] = Dat_TDM$USFWS_ETF[TDMIdx] # ETF
}

for (i in 1:length(CRR_Adjust[,1])){
  BroodIdx = which(Dat$Year == CRR_Adjust[i,1]-3)
  RetunIdx = which(Dat$Year == CRR_Adjust[i,1])
  CRR_Adjust[i,7] =  round(((Dat$Escapment[BroodIdx]-(Dat$Hatchery_Origin[BroodIdx]*Dat$Percent_Age3_Hatchery[BroodIdx]))*Dat$Percent_Age3_or_More_Natrual[BroodIdx]))
  CRR_Adjust[i,9] =  round(((Dat$Escapment[RetunIdx]-(Dat$Hatchery_Origin[RetunIdx]*Dat$Percent_Age3_Hatchery[RetunIdx]))*Dat$Percent_Age3_or_More_Natrual[RetunIdx]))
}

colnames(CRR_Adjust) <- c('CRR_Year','CRR', 'CRR_Binary', 'TDM','TEMP', 'Brood_Year','Brood_Year_Number', 'Return_Year','Return_Year_Number', 'ETF') 
CRR_Adjust= as.data.frame(CRR_Adjust)
#write.csv(CRR_Adjust, "Cohort_Replacement_Table_4_19_24.csv", row.names=F)

# Some quick plots
# plot time series of CRR and TDM
png("CRR_TDM_Raw_Hatchery_Age_Adjusted.png", height=2000/2, width=4000/2, units="px", res=300)
par(mfrow = c(1, 2))
plot(CRR_Adjust$Brood_Year , CRR_Adjust$CRR, data=CRR_Adjust, xlab="Brood Year", ylab="CRR", main="", xlim=c(1996,2019), xaxt="n", yaxt = "n")
axis(1, at = seq(1996, 2019, by = 2), las=2)
axis(2, at = seq(0, 25, by = 5), las=1)
lines(CRR_Adjust$Brood_Year , CRR_Adjust$CRR, col="blue", lty=2, lwd=2)
plot(CRR_Adjust$Brood_Year , CRR_Adjust$TDM, data=CRR_Adjust, xlab="Brood Year", ylab="TDM", main="", xlim=c(1996,2019), xaxt="n", yaxt = "n")
axis(1, at = seq(1996, 2019, by = 2), las=2)
axis(2, at = seq(0, 100, by = 20), las=1)
lines(CRR_Adjust$Brood_Year , CRR_Adjust$TDM, col="blue", lty=2, lwd=2)
dev.off()



# build linear model of CRR and TDM
linear_model = lm((CRR)~TDM, data = CRR_Adjust)
Predicted_data <- data.frame(TDM=seq(0, 100,len=500))
preds = predict(linear_model, newdata = Predicted_data, type = "response", se.fit = TRUE)
conf_interval <- predict(linear_model, newdata=Predicted_data, interval="confidence", level = 0.95)
summary(linear_model)$r.squared 

# plot linear model 
png("Linear_Model_Hatchery_Age_Adjusted_CRR_4_19_24.png", height=2000, width=2000, units="px", res=300)
plot(CRR_Adjust$TDM, (CRR_Adjust$CRR), xlab="TDM", ylab="CRR", main="Linear Regression", ylim =c(0,25))
abline(linear_model, col="lightblue",lwd=2)
lines(t(Predicted_data), conf_interval[,2], col="blue", lty=2, lwd=2)
lines(t(Predicted_data), conf_interval[,3], col="blue", lty=2, lwd=2)
text(70,20, paste0("R2 = ", round(summary(linear_model)$r.squared,2)))
dev.off()

# build linear model of log CRR and TDM
linear_model_log = lm(log(CRR)~TDM, data = CRR_Adjust)
Predicted_data <- data.frame(TDM=seq(0, 100,len=500))
preds = predict(linear_model_log, newdata = Predicted_data, type = "response", se.fit = TRUE)
conf_interval <- predict(linear_model_log, newdata=Predicted_data, interval="confidence", level = 0.95)
summary(linear_model_log)$r.squared 

# plot linear model log
png("Linear_Model_Hatchery_Age_Adjusted_Log_CRR_4_19_24.png", height=2000, width=2000, units="px", res=300)
plot(CRR_Adjust$TDM, log(CRR_Adjust$CRR), xlab="TDM", ylab="log CRR", main="Linear Regression", ylim =c(-4,4))
abline(linear_model_log, col="lightblue",lwd=2)
lines(t(Predicted_data), conf_interval[,2], col="blue", lty=2, lwd=2)
lines(t(Predicted_data), conf_interval[,3], col="blue", lty=2, lwd=2)
text(70,3, paste0("R2 = ", round(summary(linear_model_log)$r.squared,2)))
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
png("Logistic_Model_Hatchery_Age_Adjusted_4_19_24.png", height=2000, width=2000, units="px", res=300)
plot(CRR_Binary ~ TDM, data=CRR_Adjust, xlab="TDM", ylab="CRR Binary", main="Logistic Regression")
lines(fit2 ~ TDM, Predicted_data, lwd=2, col="lightblue")
lines(upr2 ~ TDM, Predicted_data, lwd=2, col="blue", lty=2)
lines(lwr2 ~ TDM, Predicted_data, lwd=2, col="blue", lty=2)
dev.off()
