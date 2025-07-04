*******************************************************
* 01_descriptive.do - Descriptive analysis
* Author: Min Kang
* Date: [25 Jun 2025]
* Description: Generates summary stats, recodes variables,
*   and reproduces descriptive and incidence results in analysis.md
*******************************************************

* Load dataset
use "data/uganda_firstevents.dta", clear
* NOTE: Raw data not included in this repository due to privacy considerations.
* The code assumes access to a cleaned dataset named "uganda_firstevents.dta".

* DESCRIPTIVE ANALYSIS *

* ------------------------
* 1. Study period check
* ------------------------
summarize dob doexit
format dob %td
format doexit %td
list dob if dob==r(min)  // Expect: 17 April 2003
list dob if dob==r(max)  // Expect: 19 April 2006
list doexit if doexit==r(min) // Earliest exit date
list doexit if doexit==r(max) // Expect: 29 March 2011

* ------------------------
* 2. Diarrhoea Episodes
* ------------------------
tab diarrhoea, m  // Expected: 1,832 / 2,315 = 79.14%

* ------------------------
* 3. Exit status
* ------------------------
tab exit_reason, m  // Expect: 69.7% completed, 4.8% died, 25.5% lost to follow-up

* ------------------------
* 4. Exit by Diarrhoea Status
* ------------------------
tab exit_reason diarrhoea, chi2 col  // Chi-square p < 0.001

* ------------------------
* 5. Maternal infection missingness
* ------------------------
generate hookworm_missing = hookworm
replace hookworm_missing = 9 if missing(hookworm)
label define misslbl 9 "Missing"
label values hookworm_missing misslbl
tab hookworm_missing, m

generate mansonella_missing = mansonella
replace mansonella_missing = 9 if missing(mansonella)
label values mansonella_missing misslbl
tab mansonella_missing, m

generate malaria_missing = malaria
replace malaria_missing = 9 if missing(malaria)
label values malaria_missing misslbl
tab malaria_missing, m

* ------------------------
* Logistic regression for predictors of maternal infection missingness
* ------------------------
quietly logistic hookworm_missing hhsesgp exit_reason
quietly estat gof  // p ~ 0.2

quietly logistic mansonella_missing hhsesgp exit_reason
quietly estat gof  // p ~ 0.4

quietly logistic malaria_missing hhsesgp exit_reason
quietly estat gof  // p ~ 0.2

* ------------------------
* 6. Birthweight categorisation
* ------------------------
gen bwtgp = .
replace bwtgp = 1 if bwt < 2.5 & bwt < .
replace bwtgp = 0 if bwt >= 2.5 & bwt < .
replace bwtgp = 9 if missing(bwtgp)
label define bwtlbl 0 "Normal (≥2.5kg)" 1 "Low (<2.5kg)" 9 "Missing"
label values bwtgp bwtlbl
tab bwtgp, m

* ------------------------
* 7. Socioeconomic status grouping
* ------------------------
gen ses4 = .
replace ses4 = 1 if inlist(hhsesgp, 1, 2)
replace ses4 = 2 if hhsesgp == 3
replace ses4 = 3 if hhsesgp == 4
replace ses4 = 4 if inlist(hhsesgp, 5, 6)
label define ses4lbl 1 "Low" 2 "Lower-middle" 3 "Upper-middle" 4 "High"
label values ses4 ses4lbl
tab ses4, m

* ------------------------
* 8. Mother's age grouping
* ------------------------
replace magegp = 4 if inlist(magegp, 4, 5)  // Collapse top two groups
label define magelbl 1 "14–19" 2 "20–24" 3 "25–29" 4 "30+"
label values magegp magelbl
tab magegp, m

* ------------------------
* 9. Number of previous episodes grouping
* ------------------------
gen nprevdiar_grp = .
replace nprevdiar_grp = 0 if nprevdiar == 0
replace nprevdiar_grp = 1 if nprevdiar == 1
replace nprevdiar_grp = 2 if nprevdiar == 2
replace nprevdiar_grp = 3 if inrange(nprevdiar, 3, 4)
replace nprevdiar_grp = 4 if nprevdiar >= 5
label define nprevdiar_lbl 0 "0" 1 "1" 2 "2" 3 "3-4" 4 "5+"
label values nprevdiar_grp nprevdiar_lbl
