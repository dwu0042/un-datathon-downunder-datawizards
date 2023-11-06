

load(file = "/datathon/train_data.rdata")
set.seed(2023)
library(caret)
library(keras)
library(tensorflow)
library(doParallel)

registerDoParallel(cores = 10)

form = powerRatio ~ biomass_ndvi + slope + PVOUT + x + y
#form = powerRatio ~ biomass_ndvi + slope + PVOUT

method = "ranger"

results = caret::train(form,
                       data = modelMat,
                       method = method,
                       trControl = trainControl(method = "repeatedcv",
                                                number = 10,
                                                repeats = 10),
                       allowParallel = TRUE)


saveRDS(results, paste("/datathon/results/results", toupper(method), ".rds", sep = ""))