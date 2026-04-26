#################### Header Start ####################
# Title : functions to do model fitting, prediction and evaluation
# Author: Jing Liao
# Date created : 22/03/2026
# Date modified: 26/04/2026
#################### Header End   ####################

# model fitting

func_fit_model_episode <- function(df_feature, continuous_episode = TRUE){

  # model A: continuous duration
  if(continuous_episode){
    
    model <- glm(y_recur_within_180 ~ risk_level + episode_first_duration,
                 data = df_feature,
                 family = binomial()
                 )
  } else {

    # model B: categorical duration
    model <- glm(y_recur_within_180 ~ risk_level + episode_type,
                 data = df_feature,
                 family = binomial()
                 )
  }
  
  return(model)
}

# add prediction

func_add_prediction <- function(df_feature, model){
  
  df_pred <- df_feature |>
    mutate(pred_prob = predict(model,
                               newdata = df_feature,
                               type = "response"),
           pred_class = if_else(pred_prob >= 0.5, 1, 0)
           )
  
  return(df_pred)
  
}

# evaluate model

func_evaluate_model <- function(df_pred){
  
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

