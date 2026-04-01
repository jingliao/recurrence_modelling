library(dplyr)
library(lubridate)

simulate_events <- function(n_person = 500){
  
  set.seed(123)
  
  # 1. person baseline with risk of having episode recurrence
  # risk from low, medium to high, the probability is assumed 0.5, 0.3, 0.2, respectively
  
  df_person <- tibble(person_id = 1:n_person,
                      risk_level = sample(c("low", "medium", "high"),
                                          n_person,
                                          replace = TRUE,
                                          prob = c(0.5, 0.3, 0.2)))
  
  # 2. assign recurrence probability using a binomial distribution, Y_i~Ber(p_i)
  # define recurrance probability, which is a conditional probability, P(recurrence|risk level)
  # if risk level is low, medium or high, the recurrence probability is 0.2, 0.4 or 0.7
  # design logic: assume feature (risk level) affects outcome, 
  # i.e. high rish -> high probability of recurrence 
  
  df_person <- df_person |>
    mutate(recur_prob = case_when(risk_level == "low" ~ 0.2,
                                  risk_level == "medium" ~ 0.4,
                                  risk_level == "high" ~ 0.7),
           will_recur = rbinom(n_person, 1, recur_prob)
           )
  
  # 3. first episode assuming episode duration is no more than 10 days
  df_episode_first <- df_person |>
    mutate(episode_start = as.Date("2022-01-01") + sample(0:365, n_person, replace = TRUE),
           episode_first_duration = sample(1:10, n_person, replace = TRUE),
           episode_first_end = episode_start + episode_first_duration)
  
  # 4. second episode (only for some people)
  df_episode_second <- df_episode_first |>
    mutate(gap_days = sample(10:180, n_person, replace = TRUE),
           episode_second_start = if_else(will_recur == 1,
                                          episode_first_end + gap_days,
                                          as.Date(NA))
           )
  
  # 5. build modelling dataset, only use FIRST episode information
  df_model <- df_episode_second |>
    mutate(y_recur_within_180 = if_else(!is.na(episode_second_start) & 
                                          (episode_second_start - episode_first_end) <= 180,
                                        1,
                                        0)
           ) |>
    dplyr::select(person_id,
                  risk_level,
                  episode_first_duration,
                  y_recur_within_180)
  
  return(df_model)
}
