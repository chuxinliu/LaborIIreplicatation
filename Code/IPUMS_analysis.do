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
