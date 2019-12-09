
/*This file contains the code for the following tables in the body 
of the text and appendix, exploring the Autor et al. (2013) approach
Figure A4 -- Kernel Density plot of pre-existing population growth in low and high exposure ADH CZs
Table 6 -- Population effects under variations of the Autor et al. (2013) approach
Table A3 -- Pre-existing population trends and the Autor et al. (2013) measure
*/

clear*
set more off, perm
capture log close

global datadir "F:\GitHub\LaborIIreplicatation\REStat package\data"
global outdir  "F:\GitHub\LaborIIreplicatation\Result"
cd "$datadir"

*log using "$outdir/ADH Analysis", replace text


********************************************************************************
*Opening IPUMS Data, Creating Population Change Measures************************
********************************************************************************
use "IPUMS_CZ_1664_7010_ADH.dta", clear

keep if year == 1980 | year == 1990 | year == 2000 | year == 2007

xtset czone year

*Non College 15-64
egen noncollege = rowtotal(*_ed1_* *_ed2_*)
*College 15-64
egen college = rowtotal(*_ed3_*  *_ed4_* *_ed5_*)

*Creating 10-year contemporaneous and lagged changes for each population group
foreach x of varlist pop1664 noncollege college age1634 age3549 age5064{
gen f`x' = f10.`x'
replace f`x' = f7.`x' if year == 2000
gen ln_`x'_change = ln(f`x') - ln(`x')
replace ln_`x'_change = ln_`x'_change/.7 if year == 2000
replace ln_`x'_change = ln_`x'_change*100
gen lag_ln_`x'_change = l10.ln_`x'_change
}

keep if year == 1990 | year == 2000
rename year yr

*Merging to Autor et al. (2013) controls
merge 1:1 czone yr using "workfile_china.dta"
keep if _merge == 3
drop _merge


lab var ln_pop1664_change "Change in Log Population, 16-64"
lab var ln_college_change "Change in Log Population, College Graduates"
lab var ln_noncollege_change "Change in Log Population, Non College Graduate"
lab var ln_age1634_change "Change in Log Population, 16-34"
lab var ln_age3549_change "Change in Log Population, 35-49"
lab var ln_age5064_change "Change in Log Population, 50-64"
lab var d_tradeusch_pw "Imports per Worker"





********************************************************************************
*Table 6, Row 1 ****************************************************************
********************************************************************************
*Row 1 replicates Autor et al. (2013) Table 4, Panel C
eststo clear
foreach x in pop1664 college noncollege age1634 age3549 age5064 {
eststo: ivregress 2sls ln_`x'_change (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 reg* [aw=timepwt48], cluster(statefip)
}

esttab using "$outdir/Table_6_Row1.tex", replace label se starlevels(* .1 ** 0.05 *** 0.01) r2 keep(d_trade*)  noobs nonotes


********************************************************************************
*Table 6, Row 2 ****************************************************************
********************************************************************************
*Row 2 replicates Autor et al. (2013) Table 4, Panel C, 
*but introduces lag population changes and drops region FE.
eststo clear
foreach x in pop1664 college noncollege age1634 age3549 age5064 {
eststo: ivregress 2sls ln_`x'_change (d_tradeusch_pw=d_tradeotch_pw_lag)  lag_ln_`x'_change l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip)
}
esttab using "$outdir/Table_6_Row2.tex", replace se label  starlevels(* .1 ** 0.05 *** 0.01) r2 keep(d_trade*)  noobs nonotes


********************************************************************************
*Repeating the above, using the 2000-2010 period instead of 2000-2007***********
********************************************************************************
use "IPUMS_CZ_1664_7010_ADH", clear
keep if year == 1980 | year == 1990 | year == 2000 | year == 2010
xtset czone year


*Non College 16-64
egen noncollege = rowtotal(*_ed1_* *_ed2_*)

*College 16-64
egen college = rowtotal(*_ed3_*  *_ed4_* *_ed5_*)

*Creating 10-year contemporaneous and lagged changes for each population group
foreach x in pop1664 noncollege college age1634 age3549 age5064 {
gen f`x' = f10.`x'
gen ln_`x'_change = ln(f`x') - ln(`x')
replace ln_`x'_change = ln_`x'_change*100
gen lag_ln_`x'_change = l10.ln_`x'_change
}

keep if year == 1990 | year == 2000
rename year yr

*Merging to Autor et al. (2013) controls
merge 1:1 czone yr using "workfile_china.dta"
keep if _merge == 3
drop _merge
drop d_tradeusch_pw d_tradeotch_pw_lag

*Merging to 2000-2010 import competition shock
merge 1:1 czone yr using "ADH Import Competition 1990 2010.dta"
keep if _merge == 3
drop _merge

lab var ln_pop1664_change "Change in Log Population, 16-64"
lab var ln_college_change "Change in Log Population, College Graduates"
lab var ln_noncollege_change "Change in Log Population, Non College Graduate"
lab var ln_age1634_change "Change in Log Population, 16-34"
lab var ln_age3549_change "Change in Log Population, 35-49"
lab var ln_age5064_change "Change in Log Population, 50-64"
lab var d_tradeusch_pw "Imports per Worker"



********************************************************************************
*Table 6, Row 4 ****************************************************************
********************************************************************************
*Row 4 repeats ADH Table 4 Panel C, but examines changes between 2000 and 2010,
*rather than between 2000 and 2007
eststo clear
foreach x in pop1664 college noncollege age1634 age3549 age5064 {
eststo: ivregress 2sls ln_`x'_change (d_tradeusch_pw=d_tradeotch_pw_lag) l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 reg* [aw=timepwt48], cluster(statefip)
}
esttab using "$outdir/Table_6_Row4.tex", replace se starlevels(* .1 ** 0.05 *** 0.01) r2 keep(d_trade*) label  noobs nonotes


********************************************************************************
*Table 6, Row 5 ****************************************************************
********************************************************************************
*Row 5 also examines 2000-2010, but introduces lag population changes and drops region FE.
eststo clear
foreach x in pop1664 college noncollege age1634 age3549 age5064 {
eststo: ivregress 2sls ln_`x'_change (d_tradeusch_pw=d_tradeotch_pw_lag) lag_ln_`x'_change l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip)
}
esttab using "$outdir/Table_6_Row5.tex", replace se starlevels(* .1 ** 0.05 *** 0.01) r2 keep(d_trade*) label  noobs nonotes




********************************************************************************
*Repeat Row 2 and 5 with Census Data********************************************
********************************************************************************

use "1980_2010_Intercensal_ADH", clear
keep if year == 1980 | year == 1990 | year == 2000 | year == 2007

xtset czone year

foreach x of varlist age1564 age1534 age3549 age5064 {
gen f`x' = f10.`x'
replace f`x' = f7.`x' if year == 2000
gen ln_`x'_change = ln(f`x') - ln(`x')
replace ln_`x'_change = ln_`x'_change/.7 if year == 2000
replace ln_`x'_change = ln_`x'_change*100
gen lag_ln_`x'_change = l10.ln_`x'_change
}


keep if year == 1990 | year == 2000
rename year yr

*Merging to Autor et al. (2013) controls
merge 1:1 czone yr using "workfile_china.dta"
keep if _merge == 3
drop _merge

********************************************************************************
*Table 6, Row 3 ****************************************************************
********************************************************************************
*Row 3 repeats Row 2 with Census data instead of IPUMS
eststo clear
foreach x in age1564 age1534 age3549 age5064 {
eststo: ivregress 2sls ln_`x'_change (d_tradeusch_pw=d_tradeotch_pw_lag) lag_ln_`x'_change l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip)
}
esttab using "$outdir/Table_6_Row3.tex", replace se label  starlevels(* .1 ** 0.05 *** 0.01) r2 keep(d_trade*)  noobs nonotes




use "1980_2010_Intercensal_ADH", clear

keep if year == 1980 | year == 1990 | year == 2000 | year == 2010
xtset czone year
foreach x in age1564 age1534 age3549 age5064{
gen f`x' = f10.`x'
gen ln_`x'_change = ln(f`x') - ln(`x')
replace ln_`x'_change = ln_`x'_change*100
gen lag_ln_`x'_change = l10.ln_`x'_change
}


keep if year == 1990 | year == 2000
rename year yr
merge 1:1 czone yr using "workfile_china.dta"
keep if _merge == 3
drop _merge 
drop d_tradeusch_pw d_tradeotch_pw_lag
merge 1:1 czone yr using "ADH Import Competition 1990 2010.dta"


********************************************************************************
*Table 6, Row 6 ****************************************************************
********************************************************************************
*Row 6 repeats Row5 with Census data instead of IPUMS
eststo clear
foreach x in age1564 age1534 age3549 age5064{
eststo: ivregress 2sls ln_`x'_change (d_tradeusch_pw=d_tradeotch_pw_lag) lag_ln_`x'_change l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 [aw=timepwt48], cluster(statefip)
}

esttab using "$outdir/Table_6_Row6.tex", replace se starlevels(* .1 ** 0.05 *** 0.01) r2 keep(d_trade*) label  noobs nonotes








********************************************************************************
*Table A3****************************************************************
********************************************************************************
use "IPUMS_CZ_1664_7010_ADH", clear

keep if year == 1980 | year == 1990 | year == 2000 | year == 2007
xtset czone year

*Non College 15-64
egen noncollege = rowtotal(*_ed1_* *_ed2_*)
*College 15-64
egen college = rowtotal(*_ed3_*  *_ed4_* *_ed5_*)


*Creating 10-year contemporaneous and lagged changes for 16-64 year-olds
foreach x of varlist pop1664 {
gen f`x' = f10.`x'
replace f`x' = f7.`x' if year == 2000
gen ln_`x'_change = ln(f`x') - ln(`x')
replace ln_`x'_change = ln_`x'_change/.7 if year == 2000
replace ln_`x'_change = ln_`x'_change*100
gen lag_ln_`x'_change = l10.ln_`x'_change
}


keep if year == 1990 | year == 2000
rename year yr

*Merging to Autor et al. (2013) controls
merge 1:1 czone yr using "workfile_china.dta"
keep if _merge == 3
drop _merge

lab var ln_pop1664_change "Change in Log Population, 16-64"
lab var d_tradeusch_pw "Imports per Worker"


eststo clear

*Creating predicted imports per worker from a regression of OLS measure
*against Autor et al. (2013) controls and IV measure.  Doing this first for
*the 1990-2000 and 2000-2007 years.
reg d_tradeusch_pw d_tradeotch_pw_lag l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 reg* [aw=timepwt48], cluster(statefip) 
predict fitted_ipw
eststo: reg fitted_ipw lag_ln_pop1664_change l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 reg* [aw=timepwt48], cluster(statefip)

*1990-2000 only
reg d_tradeusch_pw d_tradeotch_pw_lag l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 reg* [aw=timepwt48] if yr == 1990, cluster(statefip) 
predict fitted_ipw_1990
eststo: reg fitted_ipw_1990 lag_ln_pop1664_change l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 reg* [aw=timepwt48] if yr == 1990, cluster(statefip)

*2000-2007 only
reg d_tradeusch_pw d_tradeotch_pw_lag l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 reg* [aw=timepwt48] if yr == 2000, cluster(statefip) 
predict fitted_ipw_2000
eststo: reg fitted_ipw_2000 lag_ln_pop1664_change l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource t2 reg* [aw=timepwt48] if yr == 2000, cluster(statefip)


esttab using "$outdir/Table_A3", replace se starlevels(* .1 ** 0.05 *** 0.01) r2 keep(lag_ln_* l_shind_manuf_cbp l_sh_popedu_c l_sh_popfborn l_sh_empl_f l_sh_routine33 l_task_outsource) label ///
nomtitles collabel( "\shortstack{Fitted IPW}")  compress title("Pre-Trends ADH Weighted") booktabs b(3) se(3) varwidth(20) scalars("RegFE Region-Year FE")



********************************************************************************
*Figure A4**********************************************************************
********************************************************************************
use "workfile_china.dta", clear
	keep d_tradeusch_pw  timepwt48 statefip cz yr
merge 1:1 czone yr using "ADH Import Competition 1990 2010"
	drop _merge
	rename yr year
*High Low Bins
	gen dipw_quant = 1
	sum d_tradeusch_pw if year == 1990 [aw=timepwt48],d
	replace dipw_quant = 2 if year == 1990 & d_tradeusch_pw >= `r(p50)'
	sum d_tradeusch_pw if year == 2000 [aw=timepwt48],d
	replace dipw_quant = 2 if year == 2000 & d_tradeusch_pw >= `r(p50)'
*Merging in Population Data from IPUMS
merge 1:1 czone year using "IPUMS_CZ_1664_7010_ADH.dta", keepusing(pop1664 czone year)
	drop if year == 2007
	drop _merge
	rename pop1664 age1664
	*Change in Log Population
	xtset czone year, delta(10)
	gen ln_age1664 = log(age1664)
	gen l_lnc_age1664 = d.ln_age1664
	sort czone year
	keep if year == 1990 | year == 2000		
//^^^^ figure A4 ^^^^^^^//
 	twoway kdensity l_lnc_age1664 [aw = timepwt48] if year == 2000 & dipw_quant == 1, n(1000) bwidth(.05) lw(thick) lcolor(eltblue)  kernel(epanechnikov) /// 
		|| kdensity l_lnc_age1664 [aw = timepwt48] if year == 2000 & dipw_quant == 2, n(1000) bwidth(.05) lw(thick) lcolor(gs8)      kernel(epanechnikov) /// 
		legend(label(1 "Low Exposure") label(2 "High Exposure")) ytitle("Density")  title("Kernel Density Plots of {&Delta}Ln(Population)") subtitle("High vs Low {&Delta}IPW")  xtitle("{&Delta}Ln(Population) 1990-2000") ///
		note("Weighted by start of period share of national population") 	saving(age1664_kdensity_9000, replace)	
 	twoway kdensity l_lnc_age1664 [aw = timepwt48] if year == 1990 & dipw_quant == 1, n(1000) bwidth(.05) lw(thick) lcolor(eltblue)  kernel(epanechnikov) /// 
		|| kdensity l_lnc_age1664 [aw = timepwt48] if year == 1990 & dipw_quant == 2, n(1000) bwidth(.05) lw(thick) lcolor(gs8)      kernel(epanechnikov) /// 
		legend(label(1 "Low Exposure") label(2 "High Exposure")) ytitle("Density")  title("Kernel Density Plots of {&Delta}Ln(Population)") subtitle("High vs Low {&Delta}IPW")  xtitle("{&Delta}Ln(Population) 1980-1990") ///
		note("Weighted by start of period share of national population") saving(age1664_kdensity_8090, replace)
	graph combine age1664_kdensity_8090.gph age1664_kdensity_9000.gph,  col(2) scale(1) xcommon ycommon
		graph export "$outdir/Figure_A4.png",  replace	width(1600) height(600)

rm "age1664_kdensity_8090.gph"
rm "age1664_kdensity_9000.gph"
		

*log close





