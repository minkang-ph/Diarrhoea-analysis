# 📘 Childhood Diarrhoea in a Ugandan Birth Cohort

This study investigates childhood diarrhoea in a Ugandan birth cohort followed for five years. We explore the incidence of diarrhoea, time trends, the effect of maternal infections during pregnancy (hookworm, mansonella, malaria), and whether prior episodes influence subsequent diarrhoea risk.

---

## 📂 Dataset Overview

The dataset includes children enrolled at birth and followed until age 5 or earlier exit. Key domains include child demographics, maternal infections, and household socioeconomic status.

### 🔑 Variable Dictionary

| Variable      | Description |
|---------------|-------------|
| `bidno`       | Unique child ID |
| `dob`         | Date of birth of child |
| `timein`      | Start of observation period (= dob) |
| `timeout`     | End of observation period (date of diarrhoea or censoring) |
| `diarr`       | Diarrhoea event (1 = episode, 0 = exit) |
| `doexit`      | Date of exit from study |
| `exit_reason` | Exit reason (1 = censored at 5y, 2 = died, 3 = LTFU) |
| `sex`         | Sex (1 = male, 2 = female) |
| `bwt`         | Birthweight (kg) |
| `immunisation`| Place of 6-week immunisation (1 = study clinic, 2 = elsewhere) |
| `hivchild`    | Child HIV status (0 = negative, 1 = positive) |
| `hookworm`    | Maternal hookworm at enrolment (0 = neg, 1 = pos) |
| `mansonella`  | Maternal mansonella (0 = neg, 1 = pos) |
| `malaria`     | Maternal malaria (0 = neg, 1 = pos) |
| `mage`        | Mother's age (years) |
| `magegp`      | Mother's age group (1 = 14–19, ... 5 = 35+) |
| `mparity`     | Mother's parity (1 = 1, 2 = 2–4, 3 = 5+) |
| `meduc`       | Mother's education (1 = none/primary, 2 = secondary, 3 = tertiary) |
| `wall`        | Wall materials (1 = mud/metal, 2 = brick) |
| `elec`        | Electricity (1 = yes, 2 = no) |
| `water`       | Water source (1 = tap, 2 = borehole, 3 = well/lake) |
| `toilet`      | Toilet (1 = WC, 2 = latrine, 3 = neither) |
| `hhsesgp`     | Household SES (1 = low, 6 = high) |
| `location`    | Household location (1 = urban, 2 = peri-urban, 3 = rural) |
| `nprevdiar`   | Number of previous diarrhoea episodes |

---

## 🔍 Descriptive Analysis 
```stata
// 1. Study period: check date range 
summarize dob
format dob %td
list dob if dob == r(min)   // 17 April 2003
list dob if dob == r(max)   // 19 April 2006 

summarize doexit
format doexit %td
list doexit if doexit == r(min)   // 16 July 2003
list doexit if doexit == r(max)   // 29 March 2011
// → Study spans April 2003 to March 2011

// 2. Diarrhoea episodes
tab diarrhoea
// Among 2,315 children, 1,832 (79.14%) experienced at least one episode of diarrhoea

// 3. Exit status
tab exit_reason, missing
// 1,614 (69.7%) completed 5-year follow-up
// 111 (4.8%) died, 590 (25.5%) lost to follow-up

// 4. Exit reason by diarrhoea status
tab exit_reason diarrhoea, chi
// LTFU 40.6% among no-diarrhoea vs 21.5% among those with diarrhoea
// Chi-square p < 0.001
// → Suggests outcome ascertainment may depend on clinic contact

// 5. Maternal infections – summary and missingness
tab hookworm, missing
generate hookworm_missing = hookworm
replace hookworm_missing = 9 if missing(hookworm)

tab mansonella, missing
generate mansonella_missing = mansonella
replace mansonella_missing = 9 if missing(mansonella)

tab malaria, missing
generate malaria_missing = malaria
replace malaria_missing = 9 if missing(malaria)

// Hookworm: 1,014 (43.8%) positive, 9 (0.39%) missing
// Mansonella: 494 (21.3%) positive, 8 (0.35%) missing
// Malaria: 242 (10.5%) positive, 43 (1.86%) missing

// 6. Birthweight categorisation
gen bwtgp = .
replace bwtgp = 1 if bwt < 2.5 & bwt < .
replace bwtgp = 0 if bwt >= 2.5 & bwt < .
replace bwtgp = 9 if missing(bwtgp)

label define bwtlbl 0 "Normal (≥2.5kg)" 1 "Low (<2.5kg)" 9 "Missing"
label values bwtgp bwtlbl
tab bwtgp, missing
// → Created binary category using clinical cutoff

// 8. Socioeconomic status: regrouping
tab hhsesgp
tab hhsesgp diarrhoea
// SES groups 1 and 6 have few observations → regroup into 4 categories

gen ses4 = .
replace ses4 = 1 if inlist(hhsesgp, 1, 2)
replace ses4 = 2 if hhsesgp == 3
replace ses4 = 3 if hhsesgp == 4
replace ses4 = 4 if inlist(hhsesgp, 5, 6)

label define ses4lbl 1 "low" 2 "lower-middle" 3 "upper-middle" 4 "high"
label values ses4 ses4lbl
tab ses4, missing

// 9. Mother's age group: collapsing higher age categories
tab magegp diarrhoea
replace magegp = 4 if inlist(magegp, 4, 5)

label define magegplbl 1 "14–19" 2 "20–24" 3 "25–29" 4 "30+"
label values magegp magegplbl
tab magegp, missing
