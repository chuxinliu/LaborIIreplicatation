******************************************************************
**** Comparing Datasets between Replication and Original Work ****
/*
Author: Chuxin Liu
Update: 12/15/2019, 2:15PM
*/
******************************************************************

clear*
set more off, perm
global datadir "C:\Users\cl3852\Documents\GitHub\LaborIIreplicatation"
global outdir  "C:\Users\cl3852\Documents\GitHub\LaborIIreplicatation\Result"

******************************************************************
* 1. Compare total population within czone
* need to take log
* need map?
* REStat drops Alaska and Hawaii 

////////////////////////////////////////////////////////////////////////////////
use "$datadir\REStat package\data\Census Population Data 1970-2010.dta", clear
keep year czone totpop
drop if year == 2007
gen ltotpop=ln(totpop)
save "$datadir\Data\working_data\REScensus_totpop.dta", replace

use "$datadir\Data\working_data\censuspop7010.dta", clear
keep year cz90 cz_pop
rename cz90 czone
gen lcz_pop=ln(cz_pop)
merge 1:1 czone year using "$datadir\Data\working_data\REScensus_totpop.dta"
tab _merge,m 

* drop 1970, drop Alaska and Hawaii
drop if _merge!=3
drop _merge
foreach year of numlist 1980 1990 2000 2010{
kdensity ltotpop if year == `year', xtitle(log population) addplot((kdensity lcz_pop if year == `year')) title(KDensity Plot in `year') subtitle((blue: REStat; red: IPUMS)) legend(off)
graph save Graph $outdir\KDtotpop_`year'.gph, replace
}
graph combine $outdir\KDtotpop_1980.gph $outdir\KDtotpop_1990.gph $outdir\KDtotpop_2000.gph $outdir\KDtotpop_2010.gph
graph save Graph $outdir\KDtotpop_all.gph, replace
* graph the difference
gen diff_2010 = ltotpop - lcz_pop if year==2010
gen diff_other = ltotpop - lcz_pop if year!=2010
kdensity diff_2010, xtitle(log population) addplot((kdensity diff_other if diff_other!=0)) title(KDensity Plot of Difference) subtitle((blue: 2010; red: other years)) legend(off)
graph save Graph $outdir\KDtotpop_diff.gph, replace






