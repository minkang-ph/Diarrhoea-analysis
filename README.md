# 📘 Childhood Diarrhoea in a Ugandan Birth Cohort

This project investigates the incidence and predictors of childhood diarrhoea in a Ugandan birth cohort followed for five years. We explore patterns in time (age, calendar year, season), the effects of maternal infections (hookworm, mansonella, malaria), and whether prior episodes influence subsequent diarrhoea risk. Recurrent events are modelled using Poisson random effects models with gamma-distributed frailty terms to account for within-child clustering.

---

## 📂 Dataset Overview

The dataset includes children enrolled at birth and followed until age 5 or exit due to death, loss to follow-up (LTFU), or end of study. It contains information on child demographics, maternal infection status during pregnancy, household characteristics, and longitudinal diarrhoea outcomes.

> **Note**: The dataset is not publicly available due to institutional data sharing restrictions. Only the analysis code is shared in this repository.

---

## 🔑 Key Variables

| Variable       | Description |
|----------------|-------------|
| `bidno`        | Unique child ID |
| `dob`          | Date of birth |
| `timein`       | Start of observation (same as `dob`) |
| `timeout`      | End of observation (date of event or censoring) |
| `diarr`        | Diarrhoea event (1 = episode, 0 = exit) |
| `doexit`       | Date of exit |
| `exit_reason`  | Exit reason (1 = censored at 5y, 2 = died, 3 = LTFU) |
| `sex`          | Sex of child (1 = male, 2 = female) |
| `bwt`          | Birthweight (kg) |
| `immunisation` | Place of 6-week immunisation (1 = study clinic, 2 = elsewhere) |
| `hivchild`     | Child HIV status (0 = negative, 1 = positive) |
| `hookworm`     | Maternal hookworm infection (0 = negative, 1 = positive) |
| `mansonella`   | Maternal mansonella infection |
| `malaria`      | Maternal malaria infection |
| `mage`         | Mother's age (continuous) |
| `magegp`       | Mother's age group (1 = 14–19, ... 5 = 35+) |
| `mparity`      | Mother's parity (1 = 1, 2 = 2–4, 3 = 5+) |
| `meduc`        | Mother's education level |
| `wall`         | Wall material |
| `elec`         | Electricity access |
| `water`        | Water source |
| `toilet`       | Toilet facility |
| `hhsesgp`      | Household SES (1 = low, 6 = high) |
| `location`     | Household location (urban, peri-urban, rural) |
| `nprevdiar`    | Number of prior diarrhoea episodes |

---

## 📈 Analysis Overview

- Descriptive statistics were used to understand baseline characteristics, timing of first episodes, and missingness patterns.
- To estimate incidence, both **first-event rates** and **recurrent-event rates** were calculated.
- Recurrent events were analysed using **Poisson random effects models with gamma frailty**.
- Covariates were treated carefully based on subject-matter knowledge, with checks for confounding, mediation, and effect modification.
- Backward selection was used to improve interpretability and model stability.

For detailed methods, see [`analysis.md`](./analysis.md).

---

## 📁 Repository Structure
```
uganda-diarrhoea-analysis/
├── README.md             # This overview file
├── analysis.md           # Full analytical report with code & interpretation
├── do_files/             # STATA .do files 
└── outputs/              # Tables or figures 
```

## 🔍 Key Findings & Interpretation

- Diarrhoea incidence was high (66 per 100 PY), peaking at 6–12 months of age.
- Maternal hookworm and mansonella infections were associated with ~10% lower incidence.
- Malaria infection showed no overall association, but effects varied by SES.
- Among HIV-positive children, previous episodes predicted higher recurrence (dose-response).
- Potential biases include selection from loss to follow-up, residual confounding, and misclassification.
