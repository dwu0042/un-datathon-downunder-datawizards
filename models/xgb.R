
load(file = "/datathon/train_data.rdata")
set.seed(2023)
library(caret)


results = caret::train(formula(fit),
                       data = modelMat,
                       method = "xgbDART",
                       trControl = trainControl(method = "repeatedcv",
                                                number = 10,
                                                repeats = 10))


saveRDS(results, "/datathon/results/resultsXGB.rds")