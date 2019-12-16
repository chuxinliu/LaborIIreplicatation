/*This file contains the code for the following figures and tables in the body 
of the text and appendix, using Census population data:
Table 1  -- Population effects for the 15-64 and 15-34 age groups
Table A1 -- Repeating Table 1 using the alternative NTR gap suggested by Kovak (2013)
*/

set more off
cap log close

global datadir "F:\GitHub\LaborIIreplicatation\Data"
global outdir  "F:\GitHub\LaborIIreplicatation\Result"
global logdir  "F:\GitHub\LaborIIreplicatation\Log"

cap log close
log using "$logdir\Census Analysis.log", replace text

********************************************************************************
************** Open Census Data, Creat Population Change Measures **************
********************************************************************************

use "$datadir\working_data\censuspop7010.dta", clear
rename cz90 czone

*Creating 1990 CZ population weights for regressions
foreach x of varlist cz_pop_1564 cz_pop_1534  {
gen weight_`x'_90 = `x' if year == 1990
egen min_weight_`x'_90 = min(weight_`x'_90), by(czone)
drop weight_`x'_90
rename min_weight_`x'_90 weight_`x'_90
}

*Creating demographic shares
gen hispanic_share = cz_pop_his/cz_pop
gen black_share = cz_pop_black/cz_pop
gen under25_share = cz_pop_under25/cz_pop
gen amind_share = cz_pop_amind/cz_pop
gen asian_share = cz_pop_asian/cz_pop

xtset czone year, delta(10)
*Creating 10-year contemporaneous and lagged changes in each age group
foreach x of varlist cz_pop_1564 cz_pop_1534 {
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
*"move 1990 value to 2010 value"
foreach x of varlist `demo_controls' {
replace `x' = 0 if year != 1990
egen max_`x' = max(`x'), by(czone)
replace `x' = max_`x'
drop max_`x'
replace `x' = 0 if year!= 2010
}

********************************************************************************
*Merge to NTR Gap Measures******************************************************
********************************************************************************
merge m:1 czone using "$datadir\REStat\NTR Gap.dta"
keep if _merge == 3
drop _merge

********************************************************************************
*Merging to  CZ Controls********************************************************
*All of the following are fixed at a given point in time, usually 1990**********
********************************************************************************
merge m:1 czone using "$datadir\REStat\1990 CZ Controls.dta"
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
	forvalues y = 3/4 {
		gen reg_year_`x'_`y' = `x'*yeardum`y'
		}
	}
	
*Label variables
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
lab var l10_cz_pop_1564_10_change "Lag 15-64 Change"
lab var l10_cz_pop_1534_10_change "Lag 15-34 Change"
lab var cz_pop_1564_10_change "Change in Log Population, 15-64"
lab var cz_pop_1534_10_change "Change in Log Population, 15-34"


********************************************************************************
*Table 1 (a) *******************************************************************
********************************************************************************
eststo clear
eststo: reg cz_pop_1564_10_change ntr_gap l10_cz_pop_1564_10_change yeardum* reg_year_* [aw = weight_cz_pop_1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg cz_pop_1564_10_change ntr_gap l10_cz_pop_1564_10_change `demo_controls' yeardum* reg_year_*[aw = weight_cz_pop_1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg cz_pop_1564_10_change ntr_gap l10_cz_pop_1564_10_change `demo_controls' neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_cz_pop_1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg cz_pop_1564_10_change ntr_gap l10_cz_pop_1564_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_cz_pop_1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
esttab using "$outdir/Table_1a", replace se starlevels(* .1 ** 0.05 *** 0.01) r2 label ///
	compress title("Import Competition and 10-year Changes in Log CZ Population (aged 15-64), Census") booktabs b(3) se(3) varwidth(20) ///
	keep(ntr_gap `demo_controls' l10_cz_pop_* debt_to_income break_estimate neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int l_sh_popedu_c fem_lf_share) scalars("YFE Region-Year FE")
eststo clear

eststo clear
eststo: reg cz_pop_1534_10_change ntr_gap l10_cz_pop_1534_10_change yeardum* reg_year_* [aw = weight_cz_pop_1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg cz_pop_1534_10_change ntr_gap l10_cz_pop_1534_10_change `demo_controls' yeardum* reg_year_* [aw = weight_cz_pop_1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg cz_pop_1534_10_change ntr_gap l10_cz_pop_1534_10_change `demo_controls' neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_cz_pop_1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg cz_pop_1534_10_change ntr_gap l10_cz_pop_1534_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_cz_pop_1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
esttab using "$outdir/Table_1b", replace se starlevels(* .1 ** 0.05 *** 0.01) r2 label ///
	compress title("Import Competition and 10-year Changes in Log CZ Population (aged 15-34), Census") booktabs b(3) se(3) varwidth(20) ///
	keep(ntr_gap `demo_controls' l10_cz_pop_* debt_to_income break_estimate neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int l_sh_popedu_c fem_lf_share) scalars("YFE Region-Year FE")
eststo clear


********************************************************************************
*Table A1***********************************************************************
********************************************************************************
eststo clear
eststo: reg cz_pop_1564_10_change ntr_kovak l10_cz_pop_1564_10_change yeardum* reg_year_* [aw = weight_cz_pop_1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg cz_pop_1564_10_change ntr_kovak l10_cz_pop_1564_10_change `demo_controls' yeardum* reg_year_*[aw = weight_cz_pop_1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg cz_pop_1564_10_change ntr_kovak l10_cz_pop_1564_10_change `demo_controls' neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_cz_pop_1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg cz_pop_1564_10_change ntr_kovak l10_cz_pop_1564_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_cz_pop_1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
esttab using "$outdir/Table_A1a", replace se starlevels(* .1 ** 0.05 *** 0.01) r2 label ///
	compress title("Import Competition Following Kovak (2013)") booktabs b(3) se(3) varwidth(20) ///
	keep(ntr_kovak `demo_controls' l10_cz_pop_* debt_to_income break_estimate neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int l_sh_popedu_c fem_lf_share) scalars("YFE Region-Year FE")
eststo clear


eststo: reg cz_pop_1534_10_change ntr_kovak l10_cz_pop_1534_10_change yeardum* reg_year_* [aw = weight_cz_pop_1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg cz_pop_1534_10_change ntr_kovak l10_cz_pop_1534_10_change `demo_controls' yeardum* reg_year_* [aw = weight_cz_pop_1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg cz_pop_1534_10_change ntr_kovak l10_cz_pop_1534_10_change `demo_controls' neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_cz_pop_1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg cz_pop_1534_10_change ntr_kovak l10_cz_pop_1534_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_cz_pop_1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
esttab using "$outdir/Table_A1b", replace se starlevels(* .1 ** 0.05 *** 0.01) r2 label ///
	compress title("Import Competition Following Kovak (2013)") booktabs b(3) se(3) varwidth(20) ///
	keep(ntr_kovak `demo_controls' l10_cz_pop_* debt_to_income break_estimate neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int l_sh_popedu_c fem_lf_share) scalars("YFE Region-Year FE")
eststo clear



log close
