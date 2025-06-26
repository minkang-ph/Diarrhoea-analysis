*******************************************************
* 02_incidence_trends.do - Incidence & Time Trends
* Author: Min Kang
* Date: [26 Jun 2025]
* Description: Estimates baseline incidence rates and 
*   investigates time trends and subgroup crude IRRs
*******************************************************

* --------------------------------------------
* BASELINE INCIDENCE RATE: First Event Only
* --------------------------------------------
use "data/uganda_firstevents.dta", clear
stset timeout, fail(diarrhoea) origin(timein) enter(timein) id(bidno) scale(365.25)
stdes  // Expect: ~2,803.9 person-years; median ~7.5 months; max ~5 years

* --------------------------------------------
* BASELINE INCIDENCE RATE: Recurrent Events
* --------------------------------------------
use "data/uganda_multipleevents.dta", clear
* NOTE: This dataset contains multiple episodes per child
stset timeout, fail(diarrhoea) id(bidno) origin(dob) enter(timein) exit(time .) scale(365.25)

quietly streg, dist(exp) frailty(gamma) shared(bidno) forceshared
* Expect: ~6,117 events / 9,549.1 PY; ~0.661 events per PY
* LRT for theta ≠ 0: p < 0.001

* --------------------------------------------
* INCIDENCE RATE RATIOS BY SUBGROUP (Crude)
* Only include variables used in plots/tables
* --------------------------------------------

* --- Sex ---
streg i.sex, dist(exp) frailty(gamma) shared(bidno) forceshared base
lincom _cons + 2.sex, eform

* --- Age Band ---
streg i.ageband, dist(exp) frailty(gamma) shared(bidno) forceshared base

* --- Calendar Year ---
streg i.calyear, dist(exp) frailty(gamma) shared(bidno) forceshared base

* --- Season ---
streg i.season, dist(exp) frailty(gamma) shared(bidno) forceshared base

* (Optional: Save estimates or predict adjusted rates if needed)

* --------------------------------------------
* Notes:
* - Do NOT include full multivariable models here.
* - Keep this file focused on crude patterns and trends.
* - Further adjustment/interaction goes in 03_causal_models.do
*******************************************************
