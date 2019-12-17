set more off
cap log close

global datadir "F:\GitHub\LaborIIreplicatation\REStat package\data"
global outdir  "F:\GitHub\LaborIIreplicatation\Result"
cd "$datadir"

*cap log close
*log using "$outdir/Census Analysis", replace text

********************************************************************************
*Opening Census Data, Creating Population Change Measures***********************
********************************************************************************
use "Census Population Data 1970-2010", clear
keep if year==1970 | year == 1980 | year == 1990 | year == 2000 | year == 2010

*Creating 1990 CZ population weights for regressions
foreach x of varlist age1564 age1534  {
gen weight_`x'_90 = `x' if year == 1990
egen min_weight_`x'_90 = min(weight_`x'_90), by(czone)
drop weight_`x'_90
rename min_weight_`x'_90 weight_`x'_90
}


*Creating demographic shares
gen hispanic_share = hisppop/totpop
gen black_share = blackpop/totpop
gen under25_share = under_25/totpop
gen amind_share = amindpop/totpop
gen asian_share = asianpop/totpop

xtset czone year, delta(10)
*Creating 10-year contemporaneous and lagged changes in each age group
foreach x of varlist age1564 age1534 {
replace `x' = ln(`x')

*10 year changes in log population
gen l10_`x' = l.`x'
gen `x'_10_change = `x' - l10_`x'
drop l10_`x'

*10 year changes in log population, lagged 10 years.
*That is, for 2000-2010 this will be the 1990-2000 change in log population
*For 1990-2000, this will be the 1980-1990 change
gen l10_`x'_10_change = l.`x'_10_change
}

********************************************************************************
*Demographic Controls***********************************************************
********************************************************************************
local demo_controls = "hispanic_share under25_share black_share amind_share asian_share"

*We fix Census demographic shares in 1990, and allow for the effect to operate post-2000
foreach x of varlist `demo_controls' {
replace `x' = 0 if year != 1990
egen max_`x' = max(`x'), by(czone)
replace `x' = max_`x'
drop max_`x'
replace `x' = 0 if year != 2010
}


********************************************************************************
*Merge to NTR Gap Measures******************************************************
********************************************************************************
merge m:1 czone using "NTR Gap"
keep if _merge == 3
drop _merge


********************************************************************************
*Merging to  CZ Controls********************************************************
*All of the following are fixed at a given point in time, usually 1990**********
********************************************************************************
merge m:1 czone using "1990 CZ Controls"
keep if _merge == 3
drop _merge


*All of the trade measures and controls turn on for 2000-2010
foreach x of varlist ntr_gap ntr_kovak cap_labor skill_int fem_lf_share l_sh_popedu_c l_sh_routine33 l_task_outsource debt_to_income break_estimate mfg_share neighbor_fx l_sh_popfborn {
replace `x' = 0 if year != 2010
}

********************************************************************************
*Create region-year dummy variables*********************************************
********************************************************************************
*Creating a Census region dummy for New England, which is omitted
gen reg_newe = 0
replace reg_newe = 1 if (reg_midatl + reg_encen + reg_wncen + reg_satl + reg_escen + reg_wscen + reg_mount + reg_pacif) == 0

tab year, gen(yeardum)
foreach x of varlist reg_midatl reg_encen reg_wncen reg_satl reg_escen reg_wscen reg_mount reg_pacif {
	forvalues y = 4/5 {
		gen reg_year_`x'_`y' = `x'*yeardum`y'
		}
	}



lab var ntr_gap "NTR Gap"
lab var debt_to_income "Debt to Income"
lab var break_estimate "HPI Break"
lab var neighbor_fx "Neighbor CZ Effect"
lab var l_sh_routine33 "Routineness"
lab var l_task_outsource "Offshorability"
lab var cap_labor "Capital-Labor Ratio"
lab var skill_int "Skill Intensity"
lab var fem_lf_share "Female Labor Force Share"
lab var l_sh_popedu_c  "College Educated Share"
lab var under25_share "Under 25 Share "
lab var hispanic_share "Hispanic Share"
lab var black_share "Black Share"
lab var amind_share "American Indian Share"
lab var asian_share "Asian Share"
lab var l10_age1564_10_change "Lag 15-64 Change"
lab var l10_age1534_10_change "Lag 15-34 Change"
lab var age1564_10_change "Change in Log Population, 15-64"
lab var age1534_10_change "Change in Log Population, 15-34"


gen ltotpop = log(totpop)
su ltotpop if year==1990,  detail
gen u50=1 if year==1990 & ltotpop>r(p50)
gen l50=1 if year==1990 & ltotpop<r(p50)
gen l25=1 if year==1990 & ltotpop<r(p25)
gen u25=1 if year==1990 & ltotpop>r(p75)
list u*50 u*25 l*50 l*25 if czone==100
bys czone: egen u_25 = max(u25)
bys czone: egen u_50 = max(u50)
bys czone: egen l_25 = max(l25)
bys czone: egen l_50 = max(l50)
list u*50 u*25 l*50 l*25 if czone==100


********************************************************************************
*Table E1************************************************************************
********************************************************************************
eststo clear
eststo: reg age1564_10_change ntr_gap l10_age1564_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1564_10_change ntr_gap l10_age1564_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1564_90] if u_50 == 1 & year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1564_10_change ntr_gap l10_age1564_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1564_90] if l_50 == 1 & year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_gap l10_age1534_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_gap l10_age1534_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1564_90] if u_50 == 1 & year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_gap l10_age1534_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1564_90] if l_50 == 1 & year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
esttab using "$outdir/Table_E1", replace se starlevels(* .1 ** 0.05 *** 0.01) r2 label ///
compress title("Log CZ Population Changes") booktabs b(3) se(3) varwidth(20) keep(ntr_gap l10_age* ) scalars("YFE Region-Year FE")
eststo clear

********************************************************************************
*Table E2************************************************************************
********************************************************************************
eststo clear
eststo: reg age1564_10_change ntr_gap l10_age1564_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1564_90] if u_25 == 1 & year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1564_10_change ntr_gap l10_age1564_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1564_90] if u_25 != 1 & u_50==1 & year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1564_10_change ntr_gap l10_age1564_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1564_90] if l_25 != 1 & l_50==1 & year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1564_10_change ntr_gap l10_age1564_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1564_90] if l_25 == 1 & year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
esttab using "$outdir/Table_E2", replace se starlevels(* .1 ** 0.05 *** 0.01) r2 label ///
compress title("Log CZ Population Changes") booktabs b(3) se(3) varwidth(20) keep(ntr_gap l10_age* ) scalars("YFE Region-Year FE")
eststo clear

********************************************************************************
*Table E3************************************************************************
********************************************************************************
eststo clear
eststo: reg age1534_10_change ntr_gap l10_age1534_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1564_90] if u_25 == 1 & year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_gap l10_age1534_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1564_90] if u_25 != 1 & u_50==1 & year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_gap l10_age1534_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1564_90] if l_25 != 1 & l_50==1 & year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_gap l10_age1534_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1564_90] if l_25 == 1 & year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
esttab using "$outdir/Table_E3", replace se starlevels(* .1 ** 0.05 *** 0.01) r2 label ///
compress title("Log CZ Population Changes") booktabs b(3) se(3) varwidth(20) keep(ntr_gap l10_age* ) scalars("YFE Region-Year FE")
eststo clear

********************************************************************************
*Table E4***********************************************************************
********************************************************************************
gen ntr_lpop = ntr_gap*ltotpop
eststo clear
eststo: reg age1564_10_change ntr_gap l10_age1564_10_change ltotpop ntr_lpop yeardum* reg_year_* [aw = weight_age1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1564_10_change ntr_gap l10_age1564_10_change ltotpop ntr_lpop `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_gap l10_age1534_10_change ltotpop ntr_lpop yeardum* reg_year_* [aw = weight_age1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_gap l10_age1534_10_change ltotpop ntr_lpop `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
esttab using "$outdir/Table_E4", replace se starlevels(* .1 ** 0.05 *** 0.01) r2 label ///
compress title("Log CZ Population Changes") booktabs b(3) se(3) varwidth(20) keep(ntr_gap ltotpop ntr_lpop l10_age* ) scalars("YFE Region-Year FE")
eststo clear
