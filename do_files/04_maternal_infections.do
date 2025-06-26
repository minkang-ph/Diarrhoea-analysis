*******************************************************
* 04_maternal_infections.do - Maternal Infection Effects
* Author: Min Kang
* Date: [26 Jun 2025]
* Description: Estimates association between maternal 
* infections and rate of childhood diarrhoea, with
* a priori and fully adjusted models and interaction tests
*******************************************************

*---------------------------------------------*
* 0. Setup
*---------------------------------------------*
use "data/uganda_multipleevents.dta", clear
stset timeout, fail(diarrhoea) id(bidno) origin(dob) enter(timein) exit(time .) scale(365.25)

*---------------------------------------------*
* 1. A priori adjusted models (time-varying)
*---------------------------------------------*
streg i.hookworm i.calyear i.ageband i.season, dist(exp) frailty(gamma) shared(bidno) forceshared base
// HR = 0.90 (95% CI: 0.83–0.97), p = 0.005
estimates store hook_apriori

streg i.mansonella i.calyear i.ageband i.season, dist(exp) frailty(gamma) shared(bidno) forceshared base
// HR = 0.90 (95% CI: 0.82–0.99), p = 0.03
estimates store manso_apriori

streg i.malaria i.calyear i.ageband i.season, dist(exp) frailty(gamma) shared(bidno) forceshared base
// HR = 1.02 (95% CI: 0.90–1.15), p = 0.8
estimates store mala_apriori

* Likelihood ratio tests vs. baseline model (time-varying confounders only)
preserve
drop if missing(malaria)
streg i.calyear i.ageband i.season, dist(exp) frailty(gamma) shared(bidno) forceshared base
estimates store base_apriori
restore

lrtest hook_apriori base_apriori
lrtest manso_apriori base_apriori
lrtest mala_apriori base_apriori

*---------------------------------------------*
* 2. Fully adjusted model
*---------------------------------------------*
streg i.hookworm i.mansonella i.malaria ///
      i.calyear i.ageband i.season ///
      i.sex c.mage c.mparity c.meduc ///
      i.water i.toilet i.ses4 i.location i.hivchild ///
      i.elec i.wall, ///
      dist(exp) frailty(gamma) shared(bidno) forceshared base
// HRs: Hookworm = 0.91 (p = 0.02), Mansonella = 0.90 (p = 0.04), Malaria = 1.02 (p = 0.8)
estimates store full_model

* inspect coefficients and SEs (log scale)
streg i.hookworm i.mansonella i.malaria ///
      i.calyear i.ageband i.season ///
      i.sex c.mage c.mparity c.meduc ///
      i.water i.toilet i.ses4 i.location i.hivchild ///
      i.elec i.wall, ///
      dist(exp) frailty(gamma) shared(bidno) forceshared base nohr

* Sensitivity check: remove covariates one at a time

*---------------------------------------------*
* 3. LRT: Contribution of each infection (full model)
*---------------------------------------------*
* --- Hookworm ---
preserve
drop if missing(hookworm)
streg i.mansonella i.malaria ///
      i.calyear i.ageband i.season ///
      i.sex c.mage c.mparity c.meduc ///
      i.water i.toilet i.ses4 i.location i.hivchild ///
      i.elec i.wall, ///
      dist(exp) frailty(gamma) shared(bidno) forceshared base
estimates store no_hook
lrtest full_model no_hook
restore

* --- Mansonella ---
preserve
drop if missing(mansonella)
streg i.hookworm i.malaria ///
      ... [same as above]
estimates store no_manso
lrtest full_model no_manso
restore

* --- Malaria ---
preserve
drop if missing(malaria)
streg i.hookworm i.mansonella ///
      ... [same as above]
estimates store no_mala
lrtest full_model no_mala
restore

*---------------------------------------------*
* 4. Interaction Tests (Effect Modification)
*---------------------------------------------*

* -- Hookworm × HIV --
streg i.hookworm##i.hivchild i.mansonella i.malaria ///
      ... [rest same as full_model]
estimates store int_hook_hiv
lrtest full_model int_hook_hiv

* -- Hookworm × SES --
streg i.hookworm##i.ses4 i.mansonella i.malaria ///
      ... 
estimates store int_hook_ses
lrtest full_model int_hook_ses

* -- Mansonella × HIV --
streg i.hookworm i.mansonella##i.hivchild i.malaria ///
      ... 
estimates store int_manso_hiv
lrtest full_model int_manso_hiv

* -- Mansonella × SES --
streg i.hookworm i.mansonella##i.ses4 i.malaria ///
      ... 
estimates store int_manso_ses
lrtest full_model int_manso_ses

* -- Malaria × HIV --
streg i.hookworm i.mansonella i.malaria##i.hivchild ///
      ... 
estimates store int_mala_hiv
lrtest full_model int_mala_hiv

* -- Malaria × SES --
streg i.hookworm i.mansonella i.malaria##i.ses4 ///
      ... 
estimates store int_mala_ses
lrtest full_model int_mala_ses

* Marginal effects (Malaria by SES group)
lincom 1.malaria, eform                    // Low SES
lincom 1.malaria + 1.malaria#1.ses4, eform // Lower-middle
lincom 1.malaria + 1.malaria#2.ses4, eform // Upper-middle
lincom 1.malaria + 1.malaria#3.ses4, eform // High

*******************************************************
* END OF FILE
*******************************************************
