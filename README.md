# Episode recurrence modelling and prediction

This project demonstrates an end-to-end modelling workflow for predicting recurrence using simulated event data. 
The goal is not to build a production-ready model, but to illustrate how modelling decisions relate to the underlying data generating process.

## Methodology

The workflow consists of four main steps:

### 1. Data Simulation

- The binary recurrence outcome (y as whether an event will recur) is generated based on **risk level**:
  - Risk levels (low, medium, high) are sampled with probabilities: 0.5, 0.3, and 0.2
  - Recurrence probability is determined by risk level:
    - low: 0.2
    - medium: 0.4
    - high: 0.7
  - The binary outcome is generated using a binomial sampling process with the determined recurrence probability

- Episode duration is generated **randomly and independently**:
  - First episode start dates are sampled between 01/01/2022 and 31/12/2022
  - Episode duration ranges from 1 to 10 days
  - Second episode start dates are defined as:
    - first episode end date + gap days (if recurrence occurs)
    - gap days are randomly sampled between 10 and 180 days

### 2. Feature Engineering

- Risk level is encoded as a numerical variable
- Episode duration is represented as:
  - a continuous variable, or
  - a categorical variable (short, medium, long)

### 3. Modelling

- Logistic regression is used to estimate `P(y = 1 | features)`, probability of recurrence

- Two models are compared:
  - Model A (continuous): `y ~ risk_level + episode1_duration`
  - Model B (categorical): `y ~ risk_level + episode_type`

### 4. Prediction

- Predicted probabilities are converted into binary outcomes using a threshold:
  - predicted y = 1 if probability ≥ 0.5  
  - predicted y = 0 otherwise  

## Key insight

The modelling results reflect the data generating process:

- **Risk level acts as signal** and strongly predicts recurrence  
- **Episode duration acts as noise**, as it is generated independently from the outcome  

This demonstrates the importance of understanding whether features carry real predictive information


## Outputs

- HTML report `report/model_report.qmd` consists of:
  - Visualisation of recurrence patterns  
  - Model results and interpretation  

## How to Run

1. Open the project in RStudio, `my_ds_portfolio/portfolio_projects/recurrence_modelling/recurrence_modellin.Rproj`
2. Navigate to the folder `report/model_report.qmd)` and render the report, or simply render the report in the terminal via `quarto::quarto_render("report/model_report.qmd")`
