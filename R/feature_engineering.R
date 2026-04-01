library(dplyr)

create_features <- function(df){
  
  df_feature <- df |>
    # 1. encode categorical
    mutate(risk_num = case_when(risk_level == "low" ~ 1,
                                risk_level == "medium" ~ 2,
                                risk_level == "high" ~3)
           ) |>
    # 2. episode type
    mutate(episode_type = case_when(episode_first_duration <= 3 ~ "short",
                                    episode_first_duration <= 6 ~ "medium",
                                    TRUE ~ "long"),
           episode_type = factor(episode_type, 
                                 levels = c("short", "medium", "long"))
           ) |>
    # 3. interaction: high risk and prolonged event => more likely to recurrence
    mutate(risk_duration_interaction = risk_num * episode_first_duration) 

  return(df_feature)  

}