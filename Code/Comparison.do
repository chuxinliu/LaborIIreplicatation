******************************************************************
**** Comparing Datasets between Replication and Original Work ****
/*
Author: Chuxin Liu
Update: 12/15/2019, 2:15PM
*/
******************************************************************

clear*
set more off, perm
global datadir "F:\GitHub\LaborIIreplicatation"
global outdir  "F:\GitHub\LaborIIreplicatation\Result"

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
gen diff = ltotpop - lcz_pop
foreach year of numlist 1980 1990 2000 2010{
kdensity diff if year == `year',  xlabel(, labsize(vsmall)) xtitle(log population) title(KDensity Plot in `year') xscale(range(-0.3 0.2)) legend(off)
graph save Graph $outdir\KDtotpop_`year'.gph, replace
}
graph combine $outdir\KDtotpop_1980.gph $outdir\KDtotpop_1990.gph $outdir\KDtotpop_2000.gph $outdir\KDtotpop_2010.gph
graph export $outdir\KDtotpop_all.png, replace
graph save Graph $outdir\KDtotpop_all.gph, replace
/* graph the difference
kdensity diff, xtitle(log population) title(KDensity Plot of Difference)
graph export $outdir\KDtotpop_diff.gph, replace






