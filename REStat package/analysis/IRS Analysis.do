/*This file contains the code for the following figures and tables in the body 
of the text and appendix, employing IRS county-to-county migration data
Table A12 -- 10-Year log population changes
Figure 1-- Unconstrained Distributed Lag Estimates
Figure A5 -- Constrained Distributed Lag Esimates
*/

clear*
set more off, perm
capture log close

global datadir "/Users/johnlopresti/Dropbox/Trade shocks and migration/Replication data and programs/data"
global outdir  "/Users/johnlopresti/Dropbox/Trade shocks and migration/Replication data and programs/results"
cd "$datadir"


log using "$outdir/IRS Analysis", replace text



////////////////////////////////////////////////////////////////////////////////////////////////////|
//___________________________________________Section 1______________________________________________|
//	1.1 This section will set up variables for analysis.											|
//	------------------------------------------------------------------------------------------------|

*Creating Demographic Measures
use "Census Population Data 1970-2010", clear
keep if year == 1990 

*Creating measures of various demographic shares
gen hispanic_share = hisppop/totpop
gen black_share = blackpop/totpop
gen under25_share = under_25/totpop
gen amind_share = amindpop/totpop
gen asian_share = asianpop/totpop
keep hispanic_share black_share under25_share amind_share asian_share czone
save "1990 Demographics", replace


*MIGRATION OUTCOMES
use "CZ_IRS_MIGRATION.dta", clear
	xtset cz year
		foreach d in ex ret{  // once for both exemptions and total returns filed	
			gen `d'_pop = `d'_nonmig_cz + `d'_outmig_cz // Population is equal to sum of outmigrants and non-migrants
			gen f_`d'_pop = f.`d'_pop
			gen net_pop_`d'_rate = ln(f_`d'_pop/`d'_pop)
			gen lnet_pop_`d'_rate = l.net_pop_`d'_rate //Lagged population change
		}
		
////////////////////////////////////////////////////////////////////////////////////////////////////|
//___________________________________________Section 2______________________________________________|
//	2.1 This section will merge to CZ variables														|
//	------------------------------------------------------------------------------------------------|
	merge m:1 czone using "NTR Gap"
	keep if _merge == 3
	drop _merge
		
	gen ntr_gap_change = 0
	replace ntr_gap_change = ntr_gap if year == 2000
		
	gen pop_temp_ex = 0
	replace pop_temp_ex = ex_pop if year == 1990
	egen population_weight_ex = max(pop_temp_ex), by(czone)
	drop pop_temp_ex
		
	gen pop_temp_ret = 0
	replace pop_temp_ret = ret_pop if year == 1990
	egen population_weight_ret = max(pop_temp_ret), by(czone)
	drop pop_temp_ret

	merge m:1 czone using "1990 CZ Controls"
	keep if _merge == 3
	drop _merge
	
	merge m:1 czone using "1990 Demographics"
	keep if _merge == 3
	drop _merge

	*Control variables will be allowed to have a differential effect post-2001
	foreach x of varlist  neighbor_fx l_sh_popedu_c l_sh_popfborn l_sh_routine33 l_task_outsource fem_lf_share debt_to_income hpi_change break_estimate mfg_share cap_labor skill_int hispanic_share black_share under25_share amind_share asian_share break_estimate debt_to_income {
	replace `x' = 0 if year < 2000
	}
	
********************************************************************************
*Create region-year dummy variables*********************************************
********************************************************************************
*Creating a Census region dummy for New England, which is omitted 
	gen reg_newe = 0
	replace reg_newe = 1 if (reg_midatl + reg_encen + reg_wncen + reg_satl + reg_escen + reg_wscen + reg_mount + reg_pacif) == 0
	tab year, gen(yeardum)

	foreach x of varlist reg_midatl reg_encen reg_wncen reg_satl reg_escen reg_wscen reg_mount reg_pacif reg_newe {
		forvalues y = 1/24 {
		gen reg_year_`x'_`y' = `x'*yeardum`y'
			}
		}
	
	
	
////////////////////////////////////////////////////////////////////////////////////////////////////|
//___________________________________________Section 3______________________________________________|
//	3.1 This section will create the distributed lag variables for the constrained regression		|
//	------------------------------------------------------------------------------------------------|
	
xtset czone year
forvalues j = 1/12{
gen lntr_gap_change`j' = l`j'.ntr_gap_change
replace lntr_gap_change`j'= 0 if year <= 2000
}

replace lntr_gap_change12 = 0 if year == 2001

*We want to fit a cubic lag function.  That is, we run a regression of the form:
*y = A_0 + B_0*X + B_1*X_lag1 + B_2*X_lag2 + B_3*X_lag3 + ... + B_12*X_lag12

*Where the B coefficients are restricted as follows:
*B_k = E_0 + E_1*k + E_2*k^2 + E_3*k^3

*Example:
*B_0 = E_0
*B_1 = E_0 + E_1 + E_2 + E_3
*B_2 = E_0 + 2E_1 + 4E_2 + 8*E_3
*B_3 = E_0 + 3E_1 + 9E_2 + 27*E_3
*...
*B_12 = E_0 +12*E_1 + 144*E_2 + 1728*E_3

*This can be rewritten as:

*y = A_0 + E_0*(X + X_lag1 + ... + X_lag12) + E_1(X_lag1 + 2Xlag_2 + 3Xlag_3 + ... + 12Xlag_12)
*	+ E_2(X_lag1 + 4X_lag2 + 9X_lag3 + 16X_lag4 + ... + 144X_lag12)
* 	+ E_3(X_lag1 + 8X_lag2 + 27X_lag3 + 64X_lag4 + ... + 1728X_lag12)

*Thus, I need to create variables
*X + X_lag1 + ... + X_lag12
*X_lag1 + 2Xlag_2 + 3Xlag_3 + ... + 12Xlag_12
*X_lag1 + 4X_lag2 + 9X_lag3 + 16X_lag4 + ... + 144X_lag12
*X_lag1 + 8X_lag2 + 27X_lag3 + 64X_lag4 + ... + 1728X_lag12

*More generally:
*X + X_lag1 + ... + X_lagk
*1*X_lag1 + 2*X_lag2 + ... + k*X_lagk
*(1^2)*X_lag1 + (2^2)*X_lag2 + ... + (k^2)*X_lagk
*(1^3)*X_lag1 + (2^3)*X_lag2 + ... + (k^3)*X_lagk

gen created_ols_1 = ntr_gap_change
gen created_ols_2 = 0
gen created_ols_3 = 0
gen created_ols_4 = 0

forvalues j = 1/12{
replace created_ols_1 = created_ols_1 + lntr_gap_change`j'
replace created_ols_2 = created_ols_2 + `j'*lntr_gap_change`j'
replace created_ols_3 = created_ols_3 + (`j'^2)*lntr_gap_change`j'
replace created_ols_4 = created_ols_4 + (`j'^3)*lntr_gap_change`j'
}


*We then regress y on the created variables, retrieving A_0, E_0, E_1, and E_2

*Creating variables that will be used to create figures
*tab year, gen(yeardum)
xtset czone year
gen lag = _n-1

gen marg_ex = 0
gen marg_ex_up = 0
gen marg_ex_low = 0

gen marg_ret = 0
gen marg_ret_up = 0
gen marg_ret_low = 0

gen agg_ex = 0
gen agg_ex_up = 0
gen agg_ex_low = 0

gen agg_ret = 0
gen agg_ret_up = 0
gen agg_ret_low = 0


////////////////////////////////////////////////////////////////////////////////////////////////////|
//___________________________________________Section 4______________________________________________|
//	4.1 This section will run the regressions											 			|
//	------------------------------------------------------------------------------------------------|
foreach d in ex ret {
reg net_pop_`d'_rate created_ols_1 created_ols_2 created_ols_3 created_ols_4 cap_labor skill_int fem_lf_share l_sh_popedu_c l_sh_routine33 hispanic_share black_share under25_share amind_share asian_share neighbor_fx l_task_outsource break_estimate debt_to_income reg_year_* lnet_pop_`d'_rate [aw=population_weight_`d'], cluster(czone) 


*Create matrices to store point estimates, standard errors
matrix beta_`d' = J(1,13,0)
matrix se_`d' = J(1,13,0)
matrix agg_beta_`d' = J(1,13,0)
matrix agg_se_`d' = J(1,13,0)

gen count1 = 0
gen count2 = 0
gen count3 = 0

forvalues j = 0/12 {
local k = `j' + 1

local hold1 = `j'^2
local hold2 = `j'^3

*The implied marginal coefficient for the jth lag is created_ols_1 + j*created_ols_2 + (j^2)*created_ols_3 + (j^3)*created_ols_4
lincom created_ols_1 + `j'*created_ols_2 + `hold1'*created_ols_3 + `hold2'*created_ols_4
matrix beta_`d'[1,`k'] = r(estimate)
matrix se_`d'[1,`k'] = r(se)


////here
*The implied aggregate coefficient for the jth lag is the sum of the marginals
*B_0 = E_0
*B_1 = E_0 + E_1 + E_2 + E_3
* ==> B_0+B_1 = E_0+E_0 + E_1 + E_2 + E_3
* = 2*E_0  E_1 + E_2 + E_3


*B_2 = E_0 + 2E_1 + 4E_2 + 8*E_3
* ==> B_0+B_1+B_2 = E_0 + E_0 + E_0 + E_1 + 2*E_1 + E_2 + 4*E_2 + E_3 + 8*E_3
* = 3*E_0 + 3*E_1 + 5*E_2 + 9*E_3

*B_3 = E_0 + 3E_1 + 9E_2 + 27*E_3
* ==> B_0+B_1+B_2 + B_3 = E_0 + E_0 + E_0 + E_0+ E_1 + 2*E_1 + 3*E_1 + E_2 + 4*E_2 + 9*E_2 + E_3 + 8*E_3 + 27*E_3
* = 4*E_0 + 6*E_1 + 14*E_2 + 36*E_3

*for the kth lag
*(k+1)*created_ols_1 + (k + (k-1) + (k-2) + ... + 1)**created_ols_2 +(k^2 +(k-1)^2 +... +1^2)*created_ols_3 + ((k^3) +(k-1)^3 +... +1^3)*created_ols_4


/*
At j = 0
	j+1 = 1
	count1 = 0
	count2 = 0
	count3 = 0
	
At j = 1
	j+1 = 2
	count1 = 1
	count2 = 1
	count3 = 1

At j = 2
	j+1 = 3
	count1 = 3
	count2 = 5
	count3 = 9
	
At j = 3
	j+1 = 4
	count1 = 6
	count2 = 14
	count3 = 36
...
*/

local count1 = `count1' + `j'
local count2 = `count2' + `j'^2
local count3 = `count3' + `j'^3

lincom (`j'+1)*created_ols_1 + `count1'*created_ols_2 + `count2'*created_ols_3 + `count3'*created_ols_4
matrix agg_beta_`d'[1,`k'] = r(estimate)
matrix agg_se_`d'[1,`k'] = r(se)

replace marg_`d' = beta_`d'[1,`k'] if lag == `j'
replace marg_`d'_up = marg_`d' + 1.96*se_`d'[1,`k'] if lag == `j'
replace marg_`d'_low = marg_`d' - 1.96*se_`d'[1,`k'] if lag == `j'

replace agg_`d' =  agg_beta_`d'[1,`k'] if lag == `j'
replace agg_`d'_up = agg_`d' + 1.96*agg_se_`d'[1,`k'] if lag == `j'
replace agg_`d'_low = agg_`d' - 1.96*agg_se_`d'[1,`k'] if lag == `j'

}

drop count*
local count1 = 0
local count2 = 0
local count3 = 0

}


graph twoway connected (marg_ret marg_ret_up marg_ret_low)lag if [_n] <= 13, msymbol(X X X) lpattern(solid dash dash) mcolor(blue blue blue) lcolor(blue blue blue) xlabel(0 (2) 12) ytitle("Marginal Lag Effect") xtitle("Lag") legend(off) graphregion(color(white)) yscale(range(-.15(.05).05)) ytick(-.15(.05).05) ylabel(-.15(.05).05) xtitle("Lag (Years)") saving(FigA5_pana)
graph twoway connected (marg_ex marg_ex_up marg_ex_low)lag if [_n] <= 13, msymbol(X X X) lpattern(solid dash dash) mcolor(blue blue blue) lcolor(blue blue blue) xlabel(0 (2) 12) ytitle("Marginal Lag Effect") xtitle("Lag") legend(off) graphregion(color(white)) yscale(range(-.15(.05).05)) ytick(-.15(.05).05) ylabel(-.15(.05).05) xtitle("Lag (Years)") saving(FigA5_panb)
graph twoway connected (agg_ret agg_ret_up agg_ret_low)lag if [_n] <= 13, msymbol(X X X) lpattern(solid dash dash) mcolor(blue blue blue) lcolor(blue blue blue) xlabel(0 (2) 12) ytitle("Aggregate Lag Effect") xtitle("Lag") legend(off) graphregion(color(white)) yscale(range(-.8(.1).1)) ytick(-.8(.1).1) ylabel(-.8(.1).1) xtitle("Lag (Years)") saving(FigA5_panc)
graph twoway connected (agg_ex agg_ex_up agg_ex_low)lag if [_n] <= 13, msymbol(X X X) lpattern(solid dash dash) mcolor(blue blue blue) lcolor(blue blue blue) xlabel(0 (2) 12) ytitle("Aggregate Lag Effect") xtitle("Lag") legend(off) graphregion(color(white)) yscale(range(-.8(.1).1)) ytick(-.8(.1).1) ylabel(-.8(.1).1) xtitle("Lag (Years)") saving(FigA5_pand)

graph combine FigA5_pana.gph FigA5_panb.gph FigA5_panc.gph FigA5_pand.gph

graph export "$outdir/Figure_A5.pdf", replace

foreach x in a b c d {
rm "FigA5_pan`x'.gph"
}




********************************************************************************
*Unconstrained Regressions *****************************************************
********************************************************************************

foreach d in ex ret {

*Main Regression
reg net_pop_`d'_rate ntr_gap_change lntr_gap_change* cap_labor skill_int fem_lf_share l_sh_popedu_c l_sh_routine33 hispanic_share black_share under25_share amind_share asian_share neighbor_fx l_task_outsource break_estimate debt_to_income lnet_pop_`d'_rate reg_year_* [aw=population_weight_`d'], cluster(czone)

*Beta hold 
matrix beta_hold = e(b)
matrix var_hold = e(V)

*Point Esimtates and Standard Errors on Aggregate Lag Terms
lincom ntr_gap_change
matrix agg_se_`d'[1,1] = r(se)
matrix agg_beta_`d'[1,1] = r(estimate)

lincom ntr_gap_change + lntr_gap_change1
matrix agg_se_`d'[1,2] = r(se)
matrix agg_beta_`d'[1,2] = r(estimate)

lincom ntr_gap_change + lntr_gap_change1 + lntr_gap_change2
matrix agg_se_`d'[1,3] = r(se)
matrix agg_beta_`d'[1,3] = r(estimate)

lincom ntr_gap_change + lntr_gap_change1 + lntr_gap_change2 + lntr_gap_change3
matrix agg_se_`d'[1,4] = r(se)
matrix agg_beta_`d'[1,4] = r(estimate)

lincom ntr_gap_change + lntr_gap_change1 + lntr_gap_change2 + lntr_gap_change3 + lntr_gap_change4
matrix agg_se_`d'[1,5] = r(se)
matrix agg_beta_`d'[1,5] = r(estimate)

lincom ntr_gap_change + lntr_gap_change1 + lntr_gap_change2 + lntr_gap_change3 + lntr_gap_change4 + lntr_gap_change5
matrix agg_se_`d'[1,6] = r(se)
matrix agg_beta_`d'[1,6] = r(estimate)

lincom ntr_gap_change + lntr_gap_change1 + lntr_gap_change2 + lntr_gap_change3 + lntr_gap_change4 + lntr_gap_change5 + lntr_gap_change6
matrix agg_se_`d'[1,7] = r(se)
matrix agg_beta_`d'[1,7] = r(estimate)

lincom ntr_gap_change + lntr_gap_change1 + lntr_gap_change2 + lntr_gap_change3 + lntr_gap_change4 + lntr_gap_change5 + lntr_gap_change6 + lntr_gap_change7
matrix agg_se_`d'[1,8] = r(se)
matrix agg_beta_`d'[1,8] = r(estimate)

lincom ntr_gap_change + lntr_gap_change1 + lntr_gap_change2 + lntr_gap_change3 + lntr_gap_change4 + lntr_gap_change5 + lntr_gap_change6 + lntr_gap_change7 + lntr_gap_change8
matrix agg_se_`d'[1,9] = r(se)
matrix agg_beta_`d'[1,9] = r(estimate)

lincom ntr_gap_change + lntr_gap_change1 + lntr_gap_change2 + lntr_gap_change3 + lntr_gap_change4 + lntr_gap_change5 + lntr_gap_change6 + lntr_gap_change7 + lntr_gap_change8 + lntr_gap_change9
matrix agg_se_`d'[1,10] = r(se)
matrix agg_beta_`d'[1,10] = r(estimate)

lincom ntr_gap_change + lntr_gap_change1 + lntr_gap_change2 + lntr_gap_change3 + lntr_gap_change4 + lntr_gap_change5 + lntr_gap_change6 + lntr_gap_change7 + lntr_gap_change8 + lntr_gap_change9 + lntr_gap_change10
matrix agg_se_`d'[1,11] = r(se)
matrix agg_beta_`d'[1,11] = r(estimate)

lincom ntr_gap_change + lntr_gap_change1 + lntr_gap_change2 + lntr_gap_change3 + lntr_gap_change4 + lntr_gap_change5 + lntr_gap_change6 + lntr_gap_change7 + lntr_gap_change8 + lntr_gap_change9 + lntr_gap_change10 + lntr_gap_change11
matrix agg_se_`d'[1,12] = r(se)
matrix agg_beta_`d'[1,12] = r(estimate)

lincom ntr_gap_change + lntr_gap_change1 + lntr_gap_change2 + lntr_gap_change3 + lntr_gap_change4 + lntr_gap_change5 + lntr_gap_change6 + lntr_gap_change7 + lntr_gap_change8 + lntr_gap_change9 + lntr_gap_change10 + lntr_gap_change11 + lntr_gap_change12
matrix agg_se_`d'[1,13] = r(se)
matrix agg_beta_`d'[1,13] = r(estimate)


matrix beta_`d' = J(1,13,0)
matrix se_`d' = J(1,13,0)


forval j = 1/13 {
local k = `j' - 1

*This pulls the point estimates and standard errors from the main regression
matrix beta_`d'[1,`j'] = beta_hold[1,`j']
matrix se_`d'[1,`j'] = sqrt(var_hold[`j',`j'])

*marg_ex and marg_ret hold the point estimates from the regressions as well as
*the confidence intervals
replace marg_`d' = beta_`d'[1,`j'] if lag == `k'
replace marg_`d'_up = marg_`d' + 1.96*se_`d'[1,`j'] if lag == `k'
replace marg_`d'_low = marg_`d' - 1.96*se_`d'[1,`j'] if lag == `k'

*agg_ex and agg_ret hold the implied aggregate point estimates and confidence
*intervals from the regression
replace agg_`d' =  agg_beta_`d'[1,`j'] if lag == `k'
replace agg_`d'_up = agg_`d' + 1.96*agg_se_`d'[1,`j'] if lag == `k'
replace agg_`d'_low = agg_`d' - 1.96*agg_se_`d'[1,`j'] if lag == `k'
}

}
cd "$outdir"

graph twoway connected (marg_ret marg_ret_up marg_ret_low)lag if [_n] <= 13, msymbol(X X X) lpattern(solid dash dash) mcolor(black black black) lcolor(black black black) xlabel(0 (2) 12) ytitle("Marginal Lag Effect") xtitle("Lag") legend(off) graphregion(color(white)) yscale(range(-.3(.1).2)) ytick(-.3(.1).2) ylabel(-.3(.1).2) xtitle("Lag (Years)") saving(Fig1_pana)
graph twoway connected (marg_ex marg_ex_up marg_ex_low)lag if [_n] <= 13, msymbol(X X X) lpattern(solid dash dash) mcolor(black black black) lcolor(black black black) xlabel(0 (2) 12) ytitle("Marginal Lag Effect") xtitle("Lag") legend(off) graphregion(color(white)) yscale(range(-.3(.1).2)) ytick(-.3(.1).2) ylabel(-.3(.1).2) xtitle("Lag (Years)") saving(Fig1_panb)
graph twoway connected (agg_ret agg_ret_up agg_ret_low)lag if [_n] <= 13, msymbol(X X X) lpattern(solid dash dash) mcolor(black black black) lcolor(black black black) xlabel(0 (2) 12) ytitle("Aggregate Lag Effect") xtitle("Lag") legend(off) graphregion(color(white)) yscale(range(-.8(.2).2)) ytick(-.8(.2).2) ylabel(-.8(.2).2) xtitle("Lag (Years)") saving(Fig1_panc)
graph twoway connected (agg_ex agg_ex_up agg_ex_low)lag if [_n] <= 13, msymbol(X X X) lpattern(solid dash dash) mcolor(black black black) lcolor(black black black) xlabel(0 (2) 12) ytitle("Aggregate Lag Effect") xtitle("Lag") legend(off) graphregion(color(white))  yscale(range(-.8(.2).2)) ytick(-.8(.2).2) ylabel(-.8(.2).2) xtitle("Lag (Years)")saving(Fig1_pand)

graph combine Fig1_pana.gph Fig1_panb.gph Fig1_panc.gph Fig1_pand.gph
graph export "Figure_1.pdf", replace 

foreach x in a b c d {
rm "Fig1_pan`x'.gph"
}
cd "$datadir"



********************************************************************************
*Table A12**********************************************************************
********************************************************************************
*Creating 10-year changes in log population, and lagged 10-year changes
foreach d in ex ret{  // once for both exemptions and total returns filed					
	gen l_`d'_pop_10 = l10.`d'_pop
	gen net_pop_`d'_rate_10 = ln(`d'_pop/l_`d'_pop_10)
	gen lnet_pop_`d'_rate_10 = l10.net_pop_`d'_rate_10
}


eststo clear
keep if year == 2010
foreach d in ex ret {

eststo: reg net_pop_`d'_rate_10 ntr_gap cap_labor skill_int fem_lf_share l_sh_popedu_c l_sh_routine33 hispanic_share black_share under25_share amind_share asian_share neighbor_fx l_task_outsource break_estimate debt_to_income lnet_pop_`d'_rate_10 reg* [aw=population_weight_`d'], cluster(czone)
estadd local RFE "Y"
}
esttab using "$outdir/Table_A12", replace se starlevels(* .1 ** 0.05 *** 0.01) r2 keep(ntr_gap cap_labor skill_int fem_lf_share l_sh_popedu_c l_sh_routine33 hispanic_share black_share under25_share amind_share asian_share neighbor_fx l_task_outsource break_estimate debt_to_income lnet_pop_ex_rate_10 lnet_pop_ret_rate_10) label ///
nomtitles collabel( "\shortstack{Population\\Change}")  compress title("10-Year Population Changes, IRS") booktabs b(3) se(3) varwidth(20) scalars("RFE Region FE")
eststo clear

rm "1990 Demographics.dta"

log close
