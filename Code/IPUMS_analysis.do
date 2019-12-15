//================================== Trade and Migration IPUMS =====================================|
////////////////////////////////////////////////////////////////////////////////////////////////////|
clear*
set more off, perm
global datadir "F:\GitHub\LaborIIreplicatation\Data"
global outdir  "F:\GitHub\LaborIIreplicatation\Result"

////////////////////////////////////////////////////////////////////////////////////////////////////|
use "$datadir\working_data\censuspop7010.dta", clear
keep year cz*
rename cz90 czone

foreach pop in cz_pop_under25 cz_pop_his cz_pop_asian cz_pop_amind cz_pop_black cz_pop_white{
		gen `pop'share = (`pop'/cz_pop)*(year == 1990)
		bys czone : egen `pop'share1990 = max(`pop'share)
		drop `pop'share
}
keep year czone *share1990
save "$datadir\working_data\Census_1990Share_Controls.dta", replace

use "$datadir\working_data\censuspop7010.dta", clear
drop if year == 2007
	drop nat_*
	rename cz_pop_1564 age1564
	rename cz_pop totpop
	rename cz_pop_1524 under_25
	keep year czone totpop age1534 age1564 under_25 hisp asian amind black other white age* f_*_age* m_*_age* male female
	rename other other
merge m:1 czone using "NTR GAP.dta"
	keep if _merge == 3
	drop if year == 1989 | year == 1999 | year == 2009
	drop _merge
merge m:1 czone using "1990 CZ Controls.dta" 
	keep if _merge ==3
	drop _merge
	sort czone year
/*Get controls from CENSUS*/
merge 1:1  czone year using  "Census_1990Share_Controls.dta"
assert _merge ==3
erase "Census_1990Share_Controls.dta"
*Post 2001 interactions
global controls
foreach var in ntr_gap under_25share1990 hispshare1990 asianshare1990 amindshare1990 blackshare1990 cap_labor skill_int fem_lf_share l_sh_popedu_c l_sh_routine33 l_task_outsource neighbor_fx break_estimate debt_to_income {
	gen `var'_post = `var'*(year>2000)
}
