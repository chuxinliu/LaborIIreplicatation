* Use Crosswalk to generate desired variables in CZs

* Population within each CZs in 1990
* Data I use: usa_00003.dta (1990 5% state, IPUMS)

use "F:\GitHub\LaborIIreplicatation\Data\usa_00003.dta", clear
gen pop=1
collapse (sum) pop [pw=perwt], by(statefip puma)
merge 1:m statefip puma using "F:\GitHub\LaborIIreplicatation\Data\PUMA_CZ_crosswalks\puma_cz_cross_1990.dta"
bysort cz90: egen cz_N_pop=sum(county_prop_inpuma*pop)
by cz90: keep if _n==_N
egen natl_N_pop=sum(cz_N_pop)
keep cz90 cz_N_pop natl_N_pop
save "F:\GitHub\LaborIIreplicatation\Data\PUMA_CZ_crosswalks\census1990cz_N_pop", replace
