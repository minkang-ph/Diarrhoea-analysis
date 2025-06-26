*******************************************************
* 05_prev_episodes.do - Previous Diarrhoea Episodes
* Author: Min Kang
* Date: [26 Jun 2025]
* Description: Tests association between number of previous
* episodes and diarrhoea rates, with adjustment and interaction
*******************************************************

*---------------------------------------------*
* 0. Setup: Group variable and stset
*---------------------------------------------*
use "data/uganda_multipleevents.dta", clear

gen nprevdiar_grp = .
replace nprevdiar_grp = 0 if nprevdiar == 0
replace nprevdiar_grp = 1 if nprevdiar == 1
replace nprevdiar_grp = 2 if nprevdiar == 2
replace nprevdiar_grp = 3 if inrange(nprevdiar, 3, 4)
replace nprevdiar_grp = 4 if nprevdiar >= 5

label define nprev_lbl 0 "0" 1 "1" 2 "2" 3 "3–4" 4 "5+"
label values nprevdiar_grp nprev_lbl

stset timeout, failure(diarrhoea) id(bidno) origin(dob) enter(timein) exit(time .) scale(365.25)

*---------------------------------------------*
* 1. Crude model: Non-linearity test
*---------------------------------------------*
streg c.nprevdiar_grp, dist(exp) frailty(gamma) shared(bidno)
estimates store linear
// Wald p <0.001; LRT p <0.0001

streg i.nprevdiar_grp, dist(exp) frailty(gamma) shared(bidno)
estimates store categorical
// Clear non-linearity: LRT chi2(3)=80.0, p<0.0001
lrtest linear categorical

*---------------------------------------------*
* 2. A priori adjustment
*---------------------------------------------*
streg i.nprevdiar_grp i.calyear i.ageband i.season, dist(exp) frailty(gamma) shared(bidno) forceshared base
estimates store apriori
// 1: HR 1.08 (0.97–1.20), 2: 0.98, 3: 0.95, 4: 0.99

streg i.calyear i.ageband i.season, dist(exp) frailty(gamma) shared(bidno) forceshared base
estimates store apriori_base
lrtest apriori apriori_base // LRT p = 0.08

*---------------------------------------------*
* 3. Fully adjusted model
*---------------------------------------------*
streg i.nprevdiar_grp ///
      i.hookworm i.mansonella i.malaria ///
      i.calyear i.ageband i.season ///
      i.sex c.mage c.mparity c.meduc ///
      i.water i.toilet i.ses4 i.location i.hivchild ///
      i.elec i.wall, ///
      dist(exp) frailty(gamma) shared(bidno) forceshared base
estimates store full_adj
// 1: HR 1.12 (1.01–1.25); 2: 1.04; 3: 1.01; 4: 1.07

streg i.hookworm i.mansonella i.malaria ///
      i.calyear i.ageband i.season ///
      i.sex c.mage c.mparity c.meduc ///
      i.water i.toilet i.ses4 i.location i.hivchild ///
      i.elec i.wall, ///
      dist(exp) frailty(gamma) shared(bidno) forceshared base
estimates store full_base
lrtest full_adj full_base // LRT p = 0.06

*---------------------------------------------*
* 4. Interaction: HIV Status
*---------------------------------------------*
streg i.nprevdiar_grp##i.hivchild ///
      i.hookworm i.mansonella i.malaria ///
      i.calyear i.ageband i.season ///
      i.sex c.mage c.mparity c.meduc ///
      i.water i.toilet i.ses4 i.location ///
      i.elec i.wall, ///
      dist(exp) frailty(gamma) shared(bidno) forceshared base
estimates store int_hiv
lrtest full_adj int_hiv // chi2(4) = 15.58, p = 0.004

* HIV-negative marginal effects
lincom 1.nprevdiar_grp, eform
lincom 2.nprevdiar_grp, eform
lincom 3.nprevdiar_grp, eform
lincom 4.nprevdiar_grp, eform

* HIV-positive marginal effects
lincom 1.hivchild, eform
lincom 1.nprevdiar_grp + 1.nprevdiar_grp#1.hivchild, eform
lincom 2.nprevdiar_grp + 2.nprevdiar_grp#1.hivchild, eform
lincom 3.nprevdiar_grp + 3.nprevdiar_grp#1.hivchild, eform
lincom 4.nprevdiar_grp + 4.nprevdiar_grp#1.hivchild, eform

*---------------------------------------------*
* 5. Interaction: SES
*---------------------------------------------*
streg i.nprevdiar_grp##i.ses4 ///
      i.hookworm i.mansonella i.malaria ///
      i.calyear i.ageband i.season ///
      i.sex c.mage c.mparity c.meduc ///
      i.water i.toilet i.location i.hivchild ///
      i.elec i.wall, ///
      dist(exp) frailty(gamma) shared(bidno) forceshared base
estimates store int_ses
lrtest full_adj int_ses // LRT chi2(df) = 20.17, p = 0.06

*******************************************************
* END OF FILE
*******************************************************
