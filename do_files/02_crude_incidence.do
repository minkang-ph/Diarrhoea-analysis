*******************************************************
* 02_crude_incidence.do - Crude IRRs from frailty model
* Author: Min Kang
* Date: [26 Jun 2025]
* Description: Estimates crude incidence rate ratios 
*   using exponential frailty models (gamma) for each 
*   subgroup variable. All models are univariable.
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
* CRUDE INCIDENCE RATE RATIOS BY SUBGROUP
* Each model is univariable (no adjustment)
* --------------------------------------------

* --- Hookworm (0/1) ---
streg i.hookworm, dist(exp) frailty(gamma) shared(bidno) forceshared base
lincom _cons + 1.hookworm, eform

* --- Mansonella (0/1) ---
streg i.mansonella, dist(exp) frailty(gamma) shared(bidno) forceshared base
lincom _cons + 1.mansonella, eform

* --- Malaria (0/1) ---
streg i.malaria, dist(exp) frailty(gamma) shared(bidno) forceshared base
lincom _cons + 1.malaria, eform

* --- Sex (1 = male, 2 = female) ---
streg i.sex, dist(exp) frailty(gamma) shared(bidno) forceshared base
lincom _cons + 2.sex, eform

* --- Mother's Age Group (14–19, 20–24, 25–29, 30+) ---
streg i.magegp, dist(exp) frailty(gamma) shared(bidno) forceshared base
lincom _cons + 2.magegp, eform
lincom _cons + 3.magegp, eform
lincom _cons + 4.magegp, eform

* --- Mother's Parity (1, 2, 3+) ---
streg i.mparity, dist(exp) frailty(gamma) shared(bidno) forceshared base
lincom _cons + 2.mparity, eform
lincom _cons + 3.mparity, eform

* --- Mother's Education (None, Primary, Secondary+) ---
streg i.meduc, dist(exp) frailty(gamma) shared(bidno) forceshared base
lincom _cons + 2.meduc, eform
lincom _cons + 3.meduc, eform

* --- Water Source (1 = Unprotected, 2 = Protected) ---
streg i.water, dist(exp) frailty(gamma) shared(bidno) forceshared base
lincom _cons + 2.water, eform

* --- Toilet Facility (1 = None, 2 = Latrine) ---
streg i.toilet, dist(exp) frailty(gamma) shared(bidno) forceshared base
lincom _cons + 2.toilet, eform

* --- Socioeconomic Status (1 = Low, ..., 4 = High) ---
streg i.ses4, dist(exp) frailty(gamma) shared(bidno) forceshared base
lincom _cons + 2.ses4, eform
lincom _cons + 3.ses4, eform
lincom _cons + 4.ses4, eform

* --- Location (1 = Urban, 2 = Peri-urban, 3 = Rural, 4 = Remote) ---
streg i.location, dist(exp) frailty(gamma) shared(bidno) forceshared base
lincom _cons + 2.location, eform
lincom _cons + 3.location, eform
lincom _cons + 4.location, eform

* --- Child HIV Status (1 = Negative, 2 = Positive) ---
streg i.hivchild, dist(exp) frailty(gamma) shared(bidno) forceshared base
lincom _cons + 2.hivchild, eform

* --- Electricity (0 = No, 1 = Yes) ---
streg i.elec, dist(exp) frailty(gamma) shared(bidno) forceshared base
lincom _cons + 2.elec, eform

* --- Wall Type (1 = Mud, 2 = Brick/Other) ---
streg i.wall, dist(exp) frailty(gamma) shared(bidno) forceshared base
lincom _cons + 2.wall, eform

* --- Prior Diarrhoea Episodes Group (0, 1, 2–3, 4+) ---
streg i.nprevdiar_grp, dist(exp) frailty(gamma) shared(bidno) forceshared base
lincom _cons + 2.nprevdiar_grp, eform
lincom _cons + 3.nprevdiar_grp, eform
lincom _cons + 4.nprevdiar_grp, eform

*******************************************************
* END OF FILE
*******************************************************
