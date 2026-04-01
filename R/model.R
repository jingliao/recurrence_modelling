
library(dplyr)

# model A: continuous duration

fit_model_continuous <- function(df_feature){
  
  model <- glm(y_recur_within_180 ~ risk_level + episode_first_duration,
               data = df_feature,
               family = binomial()
               )
  
  return(model)
}


# model B: categorical duration

fit_model_categorical <- function(df_feature){
  
  model <- glm(y_recur_within_180 ~ risk_level + episode_type,
               data = df_feature,
               family = binomial()
               )
  
  return(model)
  
}

# add prediction

add_prediction <- function(df_feature, model){
  
  df_pred <- df_feature |>
    mutate(pred_prob = predict(model,
                               newdata = df_feature,
                               type = "response"),
           pred_class = if_else(pred_prob >= 0.5, 1, 0)
           )
  
  return(df_pred)
  
}

# evaluate model

evaluate_model <- function(df_pred){
  
  confusion <- table(Actual = df_pred$y_recur_within_180,
                     Predicted = df_pred$pred_class)
  
  accuracy <- mean(df_pred$y_recur_within_180 == df_pred$pred_class)
  
  # purpose of the baseline, how accurate it would be if doing nothing, i.e. model fitting
  baseline <- max(mean(df_pred$y_recur_within_180 == 1),
                  mean(df_pred$y_recur_within_180 == 0))
  
  list(confusion_matrix = confusion,
       accuracy = accuracy,
       baseline_accuracy = baseline)
  
}

