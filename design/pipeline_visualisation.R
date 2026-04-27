#################### Header Start ####################
# Title : Pipeline visualisation using Directed Acyclic Graph (DAG)
# Author: Jing Liao
# Date created : 25/04/2026
# Date modified: 25/04/2026
# Context      :
# This script is independent from the project structure. 
# It aims to demonstrate the pipeline design for the project.
#################### Header End   ####################

# [0.0] requiredd packages ----

library(visNetwork)
library(dplyr)
library(htmlwidgets)

# [1.0] node definition ----

nodes <- data.frame(id = c("load_pacakges",
                           "func_simulate_data",
                           "func_feature_engineering",
                           "func_model",
                           "load_global_parameters",
                           "poc_episode_resolution",
                           "quarto_html_report"),
                    label = c("load_pacakges.R",
                              "func_simulate_data.R",
                              "func_feature_engineering.R",
                              "func_model.R",
                              "load_global_parameters.R",
                              "poc_episode_resolution.R",
                              "model_report.R"),
                    group = c("setup",
                              "setup",
                              "setup",
                              "setup",
                              "setup",
                              "data",
                              "output")
                    )

edges <- data.frame(from = c("load_pacakges",
                             "func_simulate_data",
                             "func_feature_engineering",
                             "func_model",
                             "load_global_parameters",
                             "poc_episode_resolution"),
                    to = c("load_global_parameters",
                           "load_global_parameters",
                           "load_global_parameters",
                           "load_global_parameters",
                           "quarto_html_report",
                           "quarto_html_report")
                    )

visN <- visNetwork(nodes, edges) |>
  visGroups(groupname = "setup", color = "#D9EAF7") |>
  visGroups(groupname = "data", color = "#E2F0D9") |>
  visGroups(groupname = "output", color = "#EADCF8") |>
  visEdges(arrows = "to") |>
  visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE) |>
  visLayout(hierarchical = list(enabled = TRUE,
                                direction = "LR",
                                sortMethod = "directed")
            ) |>
  visInteraction(navigationButtons = TRUE)
  
saveWidget(visN, "design/DAG.html", selfcontained = TRUE)

