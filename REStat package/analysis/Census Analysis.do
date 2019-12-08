
/*This file contains the code for the following figures and tables in the body 
of the text and appendix, using Census population data:
Figure A3 -- Kernel Density plot of pre-existing population growth in low and high exposure CZs
Figure A6 -- Housing Price Breaks and HPI Estimates
Table 1, Table A5 -- Population effects for the 15-64 and 15-34 age groups
Table A1 -- Repeating Table 1 using the alternative NTR gap suggested by Kovak (2013)
Table A2 -- Pre-existing population trends and the relationship to the NTR Gap
Table A4 -- Repeating Table 1 using the 1980-1990 population growth in both periods
*/


set more off
cap log close

global datadir "/Users/johnlopresti/Dropbox/Trade shocks and migration/Replication data and programs/data"
global outdir  "/Users/johnlopresti/Dropbox/Trade shocks and migration/Replication data and programs/results"
cd "$datadir"

cap log close
log using "$outdir/Census Analysis", replace text

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


	
	
********************************************************************************
*Table 1************************************************************************
********************************************************************************
eststo clear
eststo: reg age1564_10_change ntr_gap l10_age1564_10_change yeardum* reg_year_* [aw = weight_age1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1564_10_change ntr_gap l10_age1564_10_change `demo_controls' yeardum* reg_year_*[aw = weight_age1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1564_10_change ntr_gap l10_age1564_10_change `demo_controls' neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1564_10_change ntr_gap l10_age1564_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_gap l10_age1534_10_change yeardum* reg_year_* [aw = weight_age1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_gap l10_age1534_10_change `demo_controls' yeardum* reg_year_* [aw = weight_age1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_gap l10_age1534_10_change `demo_controls' neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_gap l10_age1534_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
esttab using "$outdir/Table_1", replace se starlevels(* .1 ** 0.05 *** 0.01) r2 label ///
compress title("Log CZ Population Changes") booktabs b(3) se(3) varwidth(20) keep(ntr_gap `demo_controls' l10_age* debt_to_income break_estimate neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int l_sh_popedu_c fem_lf_share) scalars("YFE Region-Year FE")
eststo clear


********************************************************************************
*Table A1***********************************************************************
********************************************************************************
eststo clear
eststo: reg age1564_10_change ntr_kovak l10_age1564_10_change yeardum* reg_year_* [aw = weight_age1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1564_10_change ntr_kovak l10_age1564_10_change `demo_controls' yeardum* reg_year_* [aw = weight_age1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1564_10_change ntr_kovak l10_age1564_10_change `demo_controls' neighbor_fx* l_sh_routine33* l_task_outsource* cap_labor* skill_int* fem_lf_share* l_sh_popedu_c* yeardum* reg_year_* [aw = weight_age1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1564_10_change ntr_kovak l10_age1564_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx* l_sh_routine33* l_task_outsource* cap_labor* skill_int* fem_lf_share* l_sh_popedu_c* yeardum* reg_year_* [aw = weight_age1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_kovak l10_age1534_10_change yeardum* reg_year_*[aw = weight_age1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_kovak l10_age1534_10_change `demo_controls' yeardum* reg_year_*[aw = weight_age1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_kovak l10_age1534_10_change `demo_controls' neighbor_fx* l_sh_routine33* l_task_outsource* cap_labor* skill_int* fem_lf_share* l_sh_popedu_c* yeardum* reg_year_* [aw = weight_age1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_kovak l10_age1534_10_change `demo_controls' debt_to_income break_estimate  neighbor_fx* l_sh_routine33* l_task_outsource* cap_labor* skill_int* fem_lf_share* l_sh_popedu_c* yeardum* reg_year_* [aw = weight_age1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
esttab using "$outdir/Table_A1", replace se starlevels(* .1 ** 0.05 *** 0.01) r2 keep(ntr_kovak `demo_controls' l10_age* debt_to_income break_estimate neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int l_sh_popedu_c fem_lf_share) label ///
compress title("Table 2 Kovak") booktabs b(3) se(3) varwidth(20) scalars("YFE Region-Year FE")
eststo clear






********************************************************************************
*Fixing the pre-existing trends to the 1980-1990 period*************************
********************************************************************************
gen l10_age1564_8090_1 = l10_age1564_10_change if year == 2000
egen l10_age1564_8090_2 = min(l10_age1564_8090_1), by(czone)
replace l10_age1564_8090_2 = 0 if year == 2000
replace l10_age1564_8090_1 = 0 if year == 2010


gen l10_age1534_8090_1 = l10_age1534_10_change if year == 2000
egen l10_age1534_8090_2 = min(l10_age1534_8090_1), by(czone)
replace l10_age1534_8090_2 = 0 if year == 2000
replace l10_age1534_8090_1 = 0 if year == 2010

********************************************************************************
*Table A4***********************************************************************
********************************************************************************

eststo clear
eststo: reg age1564_10_change ntr_gap l10_age1564_8090_*  yeardum* reg_year_* [aw = weight_age1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1564_10_change ntr_gap l10_age1564_8090_* `demo_controls' yeardum* reg_year_* [aw = weight_age1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1564_10_change ntr_gap l10_age1564_8090_* `demo_controls' neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1564_10_change ntr_gap l10_age1564_8090_* `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1564_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_gap l10_age1534_8090_* yeardum* reg_year_* [aw = weight_age1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_gap l10_age1534_8090_* `demo_controls' yeardum* reg_year_* [aw = weight_age1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_gap l10_age1534_8090_* `demo_controls' neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
eststo: reg age1534_10_change ntr_gap l10_age1534_8090_* `demo_controls' debt_to_income break_estimate  neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int fem_lf_share l_sh_popedu_c yeardum* reg_year_* [aw = weight_age1534_90] if year == 2000 | year == 2010, cluster(czone)
estadd local YFE "Y"
esttab using "$outdir/Table_A4", replace se starlevels(* .1 ** 0.05 *** 0.01) r2 keep(ntr_gap `demo_controls' l10_age* debt_to_income break_estimate neighbor_fx l_sh_routine33 l_task_outsource cap_labor skill_int l_sh_popedu_c fem_lf_share) label ///
compress title("Log CZ Population Changes") booktabs b(3) se(3) varwidth(20) scalars("YFE Region-Year FE")
eststo clear



*Assiging the CZ controls to each year for the pre-existing population trend regressions
foreach x of varlist `demo_controls' cap_labor skill_int fem_lf_share l_sh_popedu_c l_sh_routine33 {
egen `x'_all = max(`x'), by(czone)
} 

replace l_task_outsource = . if year ~= 2010
egen l_task_outsource_all = min(l_task_outsource), by(czone)
egen ntr_gap_max = max(ntr_gap), by(czone)
egen neighbor_fx_max = max(neighbor_fx), by(czone)


********************************************************************************
*Table A2***********************************************************************
********************************************************************************
eststo: reg ntr_gap_max l10_age1564_10_change *_all neighbor_fx_max reg_year* [aw = weight_age1564_90] if year == 2000, cluster(czone)
estadd local RegFE "Y"

eststo: reg ntr_gap_max l10_age1564_10_change *_all neighbor_fx_max reg_year* [aw = weight_age1564_90] if year == 2010, cluster(czone)
estadd local RegFE "Y"


esttab using "$outdir/Table_A2", replace se starlevels(* .1 ** 0.05 *** 0.01) r2 label ///
nomtitles collabel( "\shortstack{NTR Gap}")  compress title("Pre Trends, NTR Gap") booktabs b(3) se(3) varwidth(20) scalars("RegFE Region FE")
eststo clear



********************************************************************************
*Figure A6**********************************************************************
********************************************************************************
keep if year == 2010		
twoway scatter hpi_change break_estimate, msymbol(oh) mcolor(blue) lcolor(blue) ytitle("2000-2007 HPI Change") xtitle("Housing Price Break") legend(off) graphregion(color(white))
graph export "$outdir/Figure_A6.pdf", replace
*graph2tex, epsfile(HPI_Break)
		


********************************************************************************
*Figure A3**********************************************************************
********************************************************************************
use "Census Population Data 1970-2010.dta", clear
	drop if year == 2007
merge m:1 czone using "NTR GAP.dta", keepusing(ntr_gap)
	drop _merge	
	xtset czone year, delta(10)
*Change in Log Population
	gen ln_age1564 = log(age1564)
	gen l_lnc_age1564 = d.ln_age1564
*High Low Bins
	gen p1564_wgt_1990 = age1564*(year==1990)
	bys cz : egen age1564_wgt_1990 = max(p1564_wgt_1990)
	quantiles ntr_gap [aw=age1564_wgt_1990], nq(2) gen(age1564_quant)	
	drop p1564_wgt_1990
	keep if year == 1990 | year == 2000
//^^^^ figure A3^^^^^^^//
 	twoway kdensity l_lnc_age1564  [fw=age1564_wgt_1990] if year == 2000 & age1564_quant == 1, n(1000) bwidth(.05) lw(thick) lcolor(eltblue) xlab(-.4(.2).6) kernel(epanechnikov) /// 
		|| kdensity l_lnc_age1564  [fw=age1564_wgt_1990] if year == 2000 & age1564_quant == 2, n(1000) bwidth(.05) lw(thick) lcolor(gs8)     xlab(-.4(.2).6) kernel(epanechnikov) /// 
		legend(label(1 "Low Exposure") label(2 "High Exposure")) ytitle("Density")  title("Kernel Density Plots of {&Delta}Ln(Population)") subtitle("High vs Low PNTR Exposure")  xtitle("{&Delta}Ln(Population) 1990-2000") ///
		note("Weighted by 1990 share of national population of among persons 15-64") saving(age1564_kdensity_9000, replace)	
	twoway kdensity l_lnc_age1564  [fw=age1564_wgt_1990] if year == 1990 & age1564_quant == 1, n(1000) bwidth(.05) lw(thick) lcolor(eltblue) xlab(-.4(.2).6) kernel(epanechnikov) /// 
		|| kdensity l_lnc_age1564  [fw=age1564_wgt_1990] if year == 1990 & age1564_quant == 2, n(1000) bwidth(.05) lw(thick) lcolor(gs8)     xlab(-.4(.2).6) kernel(epanechnikov) /// 
		legend(label(1 "Low Exposure") label(2 "High Exposure")) ytitle("Density")  title("Kernel Density Plots of {&Delta}Ln(Population)") subtitle("High vs Low PNTR Exposure")  xtitle("{&Delta}Ln(Population) 1980-1990") ///
		note("Weighted by 1990 share of national population of among persons 15-64") saving(age1564_kdensity_8090, replace)
	graph combine age1564_kdensity_8090.gph age1564_kdensity_9000.gph,  col(2) scale(1) 
		graph export "$outdir/Figure_A3.png",  replace	width(1600) height(600)


rm "age1564_kdensity_9000.gph"
rm "age1564_kdensity_8090.gph"
	
log close
