# Metadata

Project : Incident Episode Recurrence Modelling and Prediction
Author  : Jing Liao
Last updated date  : 26-04-2026
Stakeholders       : les humains


## 1. Purpose

A modelling focused project that predicts outcomes based on structured event data and that demonstrates end-to-end analytical thinking. 
It displays pipeline thinking and modelling logic, instead of writing models.

## 2. Dependencies

- R version 4.5.0
- Required R packages, details see R/


## 3. Project Overview

This modelling project is an extra touch based on an Integrated Data Infrastructure (IDI) project completed at my work and the IDI lab. 
The IDI project aimed to understand better the incidents of family violence and sexual violence (FVSV) recorded across multiple agencies with data available in the IDI. 
The IDI data is individual based to connect FVSV events from different agencies. The scope of this IDI work ends up using an innovative approach to link incident events 
across different sources as incident episodes. Therefore, this modelling project is a semi-continuous work for the linked episode data.

The objectives of this project are:

- to show results of a proof-of-concept network method to link events recorded across sources as episodes using a synthetic data.
- to demonstrates an end-to-end modelling workflow for prediction of episode recurrence using simulated episode event data. 
  It is not to build a production-ready model, but to illustrate how modelling decisions relate to the underlying data generating process.


## 4. Architecture/Structure

```text

my_ds_portfolio/portfolio_projects/recurrence_modelling/
|----- recurrence_modelling.Rproj
|----- README.md
|----- R/
       |----- load_global_parameters.R
       |----- load_packages.R
       |----- func_simulate_data.R
       |----- func_feature_engineering.R
       |----- func_model.R
       |----- poc_episode_resolution.R
|----- report/
       |----- model_report_files/ 
       |----- model_report.qmd
       |----- model_report.html
|----- design/
       |----- pipeline_visualisation.R
       |----- DAG.html
       |----- DAG_files
```

## 5. Criteria/Business Rules

### Simulated Data

1. The data includes the following variables:
   - personal identification
   - risk level of having episode recurrence
   - recurrence probability
   - first episode start and end date
   - second episode start date
   - a binary recurrence flag (whether the second episode happens within 180 days)
   
2. The binary recurrence outcome (Y as whether an event will recur within 180 days) is generated based on **risk level**:
  - Risk levels (low, medium, high) are independently sampled with probabilities: 0.5, 0.3, and 0.2
  - Recurrence probability is predefined to connect the risk levels:
    - low risk level with 0.2 recurrence probability
    - medium risk with 0.4 recurrence probability
    - high risk with 0.7 recurrence probability
  - The binary outcome is generated using a binomial sampling process with the predefined recurrence probability

3. Episode duration is generated **randomly and independently**:
  - First episode start dates are sampled between 01/01/2022 and 31/12/2022
  - Episode duration (the difference between first episode start and end date) ranges from 1 to 10 days
  - Second episode start dates are defined as:
    - first episode end date + gap days (if recurrence occurs, i.e. Y = 1)
    - gap days are randomly sampled between 10 and 180 days

### Feature Engineering

1. Risk number (1,2,3) is encoded by risk level from low, medium to high level
2. Episode type (short, medium, long) is defined based on the first episode duration: within 3 days, between 3 and 6 days, and exceeding 6 days
3. Risk duration interaction is the product of numeric encoded risk level and first episode duration, e.g. high risk and prolonged event may be more likely to event recurrence

### Modelling

To estimate probability of event recurrence, a logistic regression model is used with the glm family binomial distribution.
The features considered in the model are risk level and either first episode duration (continuous) or episode type (categorical).

### Prediction

1. According to the model fitting from the modelling process, input the simulated data as new data set to do prediction.
2. Set a prediction class and relate it to the response variable Y. If the predicted probability is 0.5+, then the recurrence outcome is Yes, otherwise, No

### Model evaluation

Evaluation is to compare what has been observed with what is predicted in the following two aspects:

- Confusion: a table to compare the binary recurrence outcome Y between observations and predictions
- Accuracy: a proportion of observed Y matched the predicted Y
- Baseline: a baseline representing the accuracy achieved by a naive model that always predicts the majority class

## 6. Deployment

To reproduce the report locally, simply navigate to report/model_report.qmd and render the file, 
or execute `quarto::quarto_render("report/model_report.qmd")` in the Console in this project directory.

## 7. Outputs
Currently only an HTML report is available through quarto.

## 8. Known Issues/To Do
This is an in-sample prediction, as predictions are generated on the same simulated data used for training. 
In a production setting, a train-test split (out-of-sample evaluation) would be used to obtain unbiased performance estimates. 
E.g. use 70% of simulated data for model training and 30% for evaluation.

## 9. Useful Commands
The design/ folder is used for demonstration purposes only. It is not part of the project pipeline or workflow.
