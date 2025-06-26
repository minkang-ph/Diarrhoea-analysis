*******************************************************
* 03_timetrends.do - Time Trends in Diarrhoea Incidence
* Author: Min Kang
* Date: [26 Jun 2025]
* Description: Examines how diarrhoea incidence varies
*   by age, calendar year, and season.
*******************************************************

* --------------------------------------------
* TIME TREND ANALYSIS: AGE
* --------------------------------------------
use "data/uganda_multipleevents.dta", clear
stset timeout, fail(diarrhoea) id(bidno) origin(dob) enter(timein) exit(time .) scale(365.25)

stsplit ageband, at(0 0.5 1 2 3 4 5)
recode ageband 0.5=1 1=2 2=3 3=4 4=5
label define agebandlbl 0 "aged <0.5 years" 1 "aged 0.5 to <1 year" 2 "aged 1 to <2 years" 3 "aged 2 to <3 years" 4 "aged 3 to <4 years" 5 "aged 4 to <5 years"
label values ageband agebandlbl

streg i.ageband, dist(exp) frailty(gamma) shared(bidno) forceshared base
estimates store A
streg c.ageband, dist(exp) frailty(gamma) shared(bidno) forceshared base
estimates store B
lrtest A B // categorical better (p<0.0001)

* --------------------------------------------
* TIME TREND ANALYSIS: CALENDAR YEAR
* --------------------------------------------
stset timeout, fail(diarrhoea) id(bidno) origin(time 0) enter(timein) exit(time .) scale(365.25)
stsplit calyear, at(45 46 47 48 49)
recode calyear 45=1 46=2 47=3 48=4 49=5
label define cy 0 "2003–2004" 1 "2005" 2 "2006" 3 "2007" 4 "2008" 5 "2009–2011"
label values calyear cy

streg i.calyear, dist(exp) frailty(gamma) shared(bidno) forceshared base
estimate store A
streg c.calyear, dist(exp) frailty(gamma) shared(bidno) forceshared base
estimate store B
lrtest A B // categorical better (p<0.0001)

* --------------------------------------------
* TIME TREND ANALYSIS: SEASON
* --------------------------------------------
stset timeout, fail(diarrhoea) id(bidno) origin(time 0) enter(timein) exit(time .) scale(365.25)
stsplit calmonth, at(43(0.08333)52)
replace calmonth = calmonth - int(calmonth)

recode calmonth min/0.0833=1 0.0833/0.1667=2 0.1667/0.25=3 0.25/0.3333=4 0.3333/0.4167=5 0.4167/0.5=6 0.5/0.5833=7 0.5833/0.6666=8 0.6666/0.75=9 0.75/0.8333=10 0.8333/0.9166=11 0.9166/max=12

gen season = calmonth
replace season = 0 if inlist(calmonth, 3,4,5,9,10,11,12)
replace season = 1 if inlist(calmonth, 1,2,6,7,8)
label define seasonlbl 0 "Wet" 1 "Dry"
label values season seasonlbl

streg i.season, dist(exp) frailty(gamma) shared(bidno) forceshared base

* --------------------------------------------
* MUTUAL ADJUSTMENT: AGE & CALENDAR YEAR
* --------------------------------------------
streg i.ageband i.calyear, dist(exp) frailty(gamma) shared(bidno) forceshared base
estimates store A 
streg i.ageband, dist(exp) frailty(gamma) shared(bidno) forceshared base
estimates store B
streg i.calyear, dist(exp) frailty(gamma) shared(bidno) forceshared base
estimates store C
lrtest A B
lrtest A C

* --------------------------------------------
* GRAPH: AGE TREND (Crude & Adjusted)
* --------------------------------------------
clear
input str20 ageband_label hr lb ub order str10 model
"aged <0.5 years"        1.00 1.00 1.00 0 "crude"
"aged 0.5 to <1 year"    1.72 1.59 1.86 1 "crude"
"aged 1 to <2 years"     0.96 0.89 1.04 3 "crude"
"aged 2 to <3 years"     0.40 0.37 0.44 5 "crude"
"aged 3 to <4 years"     0.22 0.19 0.24 7 "crude"
"aged 4 to <5 years"     0.15 0.13 0.18 9 "crude"
"aged <0.5 years"        1.00 1.00 1.00 0 "adjusted"
"aged 0.5 to <1 year"    1.83 1.69 1.98 1 "adjusted"
"aged 1 to <2 years"     1.12 1.02 1.23 3 "adjusted"
"aged 2 to <3 years"     0.53 0.46 0.60 5 "adjusted"
"aged 3 to <4 years"     0.30 0.25 0.36 7 "adjusted"
"aged 4 to <5 years"     0.21 0.17 0.27 9 "adjusted"
end

gen label_adj = string(hr, "%4.2f") + " (" + string(lb, "%4.2f") + "-" + string(ub, "%4.2f") + ")"
gen label_crude = label_adj
replace label_crude = "" if model != "crude"
replace label_adj = "" if model != "adjusted"
replace label_crude = "" if order == 0
replace label_adj   = "" if order == 0

twoway ///
  (rcap ub lb order if model == "crude", lcolor(blue)) ///
  (scatter hr order if model == "crude", msymbol(Oh) mcolor(blue)) ///
  (rcap ub lb order if model == "adjusted", lcolor(red)) ///
  (scatter hr order if model == "adjusted", msymbol(Dh) mcolor(red)) ///
  (scatter hr order if model == "crude", mlabel(label_crude) mlabcolor(blue) mlabpos(3) mlabsize(small) msymbol(i)) ///
  (scatter hr order if model == "adjusted", mlabel(label_adj) mlabcolor(red) mlabpos(3) mlabsize(small) msymbol(i)), ///
  xlabel(0 "<0.5 years" 1 "0.5 to <1 year" 3 "1 to <2 years" 5 "2 to <3 years" 7 "3 to <4 years" 9 "4 to <5 years", angle(45)) ///
  ylabel(0(0.2)2) yscale(range(0 2)) yline(1, lpattern(dash) lcolor(gs8)) ///
  ytitle("Rate Ratio") xtitle("Age band") ///
  title("Crude vs Adjusted Rate Ratios by Age Band") ///
  legend(order(2 "Crude" 4 "Adjusted") pos(2) ring(0) cols(1)) ///
  plotregion(margin(zero)) aspect(0.75)

* --------------------------------------------
* GRAPH: CALENDAR YEAR (with labels)
* --------------------------------------------
clear
input str12 calyear_label hr lb ub order str10 model
"2003–2004" 1.00 1.00 1.00 0 "crude"
"2005"      0.83 0.76 0.90 1 "crude"
"2006"      0.56 0.52 0.61 2 "crude"
"2007"      0.32 0.29 0.35 3 "crude"
"2008"      0.15 0.13 0.17 4 "crude"
"2009–2011" 0.10 0.09 0.12 5 "crude"
"2003–2004" 1.00 1.00 1.00 0 "adjusted"
"2005"      0.89 0.82 0.98 1 "adjusted"
"2006"      0.75 0.67 0.83 2 "adjusted"
"2007"      0.70 0.61 0.81 3 "adjusted"
"2008"      0.60 0.50 0.74 4 "adjusted"
"2009–2011" 0.67 0.52 0.87 5 "adjusted"
end

gen label_adj = string(hr, "%4.2f") + " (" + string(lb, "%4.2f") + "-" + string(ub, "%4.2f") + ")"
gen label_crude = label_adj
replace label_crude = "" if model != "crude"
replace label_adj = "" if model != "adjusted"
replace label_crude = "" if order == 0
replace label_adj   = "" if order == 0

twoway ///
  (rcap ub lb order if model == "crude", lcolor(blue)) ///
  (scatter hr order if model == "crude", msymbol(Oh) mcolor(blue)) ///
  (rcap ub lb order if model == "adjusted", lcolor(red)) ///
  (scatter hr order if model == "adjusted", msymbol(Dh) mcolor(red)) ///
  (scatter hr order if model == "crude", mlabel(label_crude) mlabcolor(blue) mlabpos(3) mlabsize(small) msymbol(i)) ///
  (scatter hr order if model == "adjusted", mlabel(label_adj) mlabcolor(red) mlabpos(3) mlabsize(small) msymbol(i)), ///
  xlabel(0 "2003–2004" 1 "2005" 2 "2006" 3 "2007" 4 "2008" 5 "2009–2011") ///
  ylabel(0(0.2)1.2) yscale(range(0 1.2)) yline(1, lpattern(dash) lcolor(gs8)) ///
  ytitle("Hazard Ratio") xtitle("Calendar Year") ///
  title("Crude vs Adjusted Hazard Ratios by Calendar Year") ///
  legend(order(2 "Crude" 4 "Adjusted") pos(2) ring(0) cols(1)) ///
  plotregion(margin(0 10 0 0)) aspect(0.7)

*******************************************************
* END OF FILE
*******************************************************
