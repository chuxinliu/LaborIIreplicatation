// === Construct Census Population Data 1980-2010 using IPUMS === // 
* Using Datasets: usa_00005, crosswalks files from PUMA to CZs
/* Outcomes:
$datadir\working_data\1980census_pop.dta
$datadir\working_data\1990census_pop.dta
$datadir\working_data\2000census_pop.dta
$datadir\working_data\2010census_pop.dta

*/
//////////////////////////////////////////////////////////////////

clear*
set more off, perm
version 11.0
global datadir "F:\GitHub\LaborIIreplicatation\Data"
global outdir  "F:\GitHub\LaborIIreplicatation\Result"

////////////////////////////////////////////////////////////////////////////////////////////////////|


/*1, 1980
use "$datadir\usa_00005.dta", clear
tab year, m
keep if year == 1980
*create different population categories
gen pop=1
*gender
gen pop_male=1 if sex==1
gen pop_female=1 if sex==2
*race
gen pop_white=1 if race==1
gen pop_black=1 if race==2
gen pop_amind=1 if race==3
gen pop_asian=1 if race==4 | race==5 | race==6
gen pop_his=1 if hispan!=0
*age
gen pop_1564=1 if age>=15 & age<=64
gen pop_1534=1 if age>=15 & age<=34
gen pop_1524=1 if age>=15 & age<=24
gen pop_2534=1 if age>=25 & age<=34
gen pop_3544=1 if age>=35 & age<=44
gen pop_4554=1 if age>=45 & age<=54
gen pop_5564=1 if age>=55 & age<=64
gen pop_under25=1 if age<25
*education
gen pop_lshs=1 if educd<62
gen pop_hssc=1 if educd>=62 & educd<=100
gen pop_cg=1 if educd>=101
*age*education (for Tabel 3)
gen pop_2534_lshs=1 if age>=25 & age<=34 & educd<62
gen pop_2534_hssc=1 if age>=25 & age<=34 & educd>=62 & educd<=100
gen pop_2534_cg=1 if age>=25 & age<=34 & educd>=101
gen pop_3544_lshs=1 if age>=35 & age<=44 & educd<62
gen pop_3544_hssc=1 if age>=35 & age<=44 & educd>=62 & educd<=100
gen pop_3544_cg=1 if age>=35 & age<=44 & educd>=101
gen pop_4554_lshs=1 if age>=45 & age<=54 & educd<62
gen pop_4554_hssc=1 if age>=45 & age<=54 & educd>=62 & educd<=100
gen pop_4554_cg=1 if age>=45 & age<=54 & educd>=101
gen pop_5564_lshs=1 if age>=55 & age<=64 & educd<62
gen pop_5564_hssc=1 if age>=55 & age<=64 & educd>=62 & educd<=100
gen pop_5564_cg=1 if age>=55 & age<=64 & educd>=101

collapse (sum) pop* [pw=perwt], by(statefip cntygp98)
merge 1:m statefip cntygp98 using "$datadir\PUMA_CZ_crosswalks\puma_cz_cross_1980.dta"

foreach i of varlist pop*{
bysort cz90: egen cz_`i'=sum(county_prop_incntygp*`i')
}
by cz90: keep if _n==_N
foreach i of varlist pop*{
egen natl_`i'=sum(cz_`i')
}
drop cz_pop1980 natl_pop1980 _merge
save "$datadir\working_data\1980census_pop.dta", replace


*2, 1990
use "$datadir\usa_00005.dta", clear
tab year, m
keep if year == 1990
*create different population categories
gen pop=1
*gender
gen pop_male=1 if sex==1
gen pop_female=1 if sex==2
*race
gen pop_white=1 if race==1
gen pop_black=1 if race==2
gen pop_amind=1 if race==3
gen pop_asian=1 if race==4 | race==5 | race==6
gen pop_his=1 if hispan!=0
*age
gen pop_1564=1 if age>=15 & age<=64
gen pop_1534=1 if age>=15 & age<=34
gen pop_1524=1 if age>=15 & age<=24
gen pop_2534=1 if age>=25 & age<=34
gen pop_3544=1 if age>=35 & age<=44
gen pop_4554=1 if age>=45 & age<=54
gen pop_5564=1 if age>=55 & age<=64
gen pop_under25=1 if age<25
*education
gen pop_lshs=1 if educd<62
gen pop_hssc=1 if educd>=62 & educd<=100
gen pop_cg=1 if educd>=101
*age*education (for Tabel 3)
gen pop_2534_lshs=1 if age>=25 & age<=34 & educd<62
gen pop_2534_hssc=1 if age>=25 & age<=34 & educd>=62 & educd<=100
gen pop_2534_cg=1 if age>=25 & age<=34 & educd>=101
gen pop_3544_lshs=1 if age>=35 & age<=44 & educd<62
gen pop_3544_hssc=1 if age>=35 & age<=44 & educd>=62 & educd<=100
gen pop_3544_cg=1 if age>=35 & age<=44 & educd>=101
gen pop_4554_lshs=1 if age>=45 & age<=54 & educd<62
gen pop_4554_hssc=1 if age>=45 & age<=54 & educd>=62 & educd<=100
gen pop_4554_cg=1 if age>=45 & age<=54 & educd>=101
gen pop_5564_lshs=1 if age>=55 & age<=64 & educd<62
gen pop_5564_hssc=1 if age>=55 & age<=64 & educd>=62 & educd<=100
gen pop_5564_cg=1 if age>=55 & age<=64 & educd>=101

collapse (sum) pop* [pw=perwt], by(statefip puma)
merge 1:m statefip puma using "$datadir\PUMA_CZ_crosswalks\puma_cz_cross_1990.dta"

foreach i of varlist pop*{
bysort cz90: egen cz_`i'=sum(county_prop_inpuma*`i')
}
by cz90: keep if _n==_N
foreach i of varlist pop*{
egen natl_`i'=sum(cz_`i')
}
drop cz_pop1990 natl_pop1990 _merge
save "$datadir\working_data\1990census_pop.dta", replace


*3, 2000
use "$datadir\usa_00005.dta", clear
tab year, m
keep if year == 2000
*create different population categories
gen pop=1
*gender
gen pop_male=1 if sex==1
gen pop_female=1 if sex==2
*race
gen pop_white=1 if race==1
gen pop_black=1 if race==2
gen pop_amind=1 if race==3
gen pop_asian=1 if race==4 | race==5 | race==6
gen pop_his=1 if hispan!=0
*age
gen pop_1564=1 if age>=15 & age<=64
gen pop_1534=1 if age>=15 & age<=34
gen pop_1524=1 if age>=15 & age<=24
gen pop_2534=1 if age>=25 & age<=34
gen pop_3544=1 if age>=35 & age<=44
gen pop_4554=1 if age>=45 & age<=54
gen pop_5564=1 if age>=55 & age<=64
gen pop_under25=1 if age<25
*education
gen pop_lshs=1 if educd<62
gen pop_hssc=1 if educd>=62 & educd<=100
gen pop_cg=1 if educd>=101
*age*education (for Tabel 3)
gen pop_2534_lshs=1 if age>=25 & age<=34 & educd<62
gen pop_2534_hssc=1 if age>=25 & age<=34 & educd>=62 & educd<=100
gen pop_2534_cg=1 if age>=25 & age<=34 & educd>=101
gen pop_3544_lshs=1 if age>=35 & age<=44 & educd<62
gen pop_3544_hssc=1 if age>=35 & age<=44 & educd>=62 & educd<=100
gen pop_3544_cg=1 if age>=35 & age<=44 & educd>=101
gen pop_4554_lshs=1 if age>=45 & age<=54 & educd<62
gen pop_4554_hssc=1 if age>=45 & age<=54 & educd>=62 & educd<=100
gen pop_4554_cg=1 if age>=45 & age<=54 & educd>=101
gen pop_5564_lshs=1 if age>=55 & age<=64 & educd<62
gen pop_5564_hssc=1 if age>=55 & age<=64 & educd>=62 & educd<=100
gen pop_5564_cg=1 if age>=55 & age<=64 & educd>=101

collapse (sum) pop* [pw=perwt], by(statefip puma)
merge 1:m statefip puma using "$datadir\PUMA_CZ_crosswalks\puma_cz_cross_2000.dta"

foreach i of varlist pop*{
bysort cz90: egen cz_`i'=sum(county_prop_inpuma*`i')
}
by cz90: keep if _n==_N
foreach i of varlist pop*{
egen natl_`i'=sum(cz_`i')
}
drop cz_pop2000 natl_pop2000 _merge
save "$datadir\working_data\2000census_pop.dta", replace

*4. 2010: keep only 2010
use "$datadir\usa_00005.dta", clear
tab year, m
keep if year == 2011
drop multyear sample serial cbserial hhwt 
*create different population categories
gen pop=1
*gender
gen pop_male=1 if sex==1
gen pop_female=1 if sex==2
*race
gen pop_white=1 if race==1
gen pop_black=1 if race==2
gen pop_amind=1 if race==3
gen pop_asian=1 if race==4 | race==5 | race==6
gen pop_his=1 if hispan!=0
*age
gen pop_1564=1 if age>=15 & age<=64
gen pop_1534=1 if age>=15 & age<=34
gen pop_1524=1 if age>=15 & age<=24
gen pop_2534=1 if age>=25 & age<=34
gen pop_3544=1 if age>=35 & age<=44
gen pop_4554=1 if age>=45 & age<=54
gen pop_5564=1 if age>=55 & age<=64
gen pop_under25=1 if age<25
*education
gen pop_lshs=1 if educd<62
gen pop_hssc=1 if educd>=62 & educd<=100
gen pop_cg=1 if educd>=101
*age*education (for Tabel 3)
gen pop_2534_lshs=1 if age>=25 & age<=34 & educd<62
gen pop_2534_hssc=1 if age>=25 & age<=34 & educd>=62 & educd<=100
gen pop_2534_cg=1 if age>=25 & age<=34 & educd>=101
gen pop_3544_lshs=1 if age>=35 & age<=44 & educd<62
gen pop_3544_hssc=1 if age>=35 & age<=44 & educd>=62 & educd<=100
gen pop_3544_cg=1 if age>=35 & age<=44 & educd>=101
gen pop_4554_lshs=1 if age>=45 & age<=54 & educd<62
gen pop_4554_hssc=1 if age>=45 & age<=54 & educd>=62 & educd<=100
gen pop_4554_cg=1 if age>=45 & age<=54 & educd>=101
gen pop_5564_lshs=1 if age>=55 & age<=64 & educd<62
gen pop_5564_hssc=1 if age>=55 & age<=64 & educd>=62 & educd<=100
gen pop_5564_cg=1 if age>=55 & age<=64 & educd>=101

/* puma==77777 will not be matched due to insufficient size */
/* crosswalk file is still puma_cz_cross_2000.dta according to Peter McHenry's website */

collapse (sum) pop* [pw=perwt], by(statefip puma)
merge 1:m statefip puma using "$datadir\PUMA_CZ_crosswalks\puma_cz_cross_2000.dta"

drop if puma==77777

foreach i of varlist pop*{
bysort cz90: egen cz_`i'=sum(county_prop_inpuma*`i')
}
by cz90: keep if _n==_N
foreach i of varlist pop*{
egen natl_`i'=sum(cz_`i')
}

drop cz_pop2000 natl_pop2000 _merge
save "$datadir\working_data\2010census_pop.dta", replace
*/

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

/*    Merge 1980, 1990, 2000, 2010 into Census Population Data1970-2010       */

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

*generate year for each year and get ready for append

use 1980census_pop.dta, clear
append using 1990census_pop.dta
append using 2000census_pop.dta
append using 2010census_pop.dta

////// variables that are not fully appended //////
*1980: cntygp98 pop1980 cntygpp~1980 czpop1980 county_prop_incntygp 
*1990+2000+2010: puma county_prop_inpuma
*1990: pop1990 pumapop1990 czpop1990 
*2000+2010: pop2000 pumapop2000 czpop2000
///////////////////////////////////////////////////

drop cntygp98 pop1980 cntygpp~1980 czpop1980 county_prop_incntygp 
drop puma county_prop_inpuma
drop pop1990 pumapop1990 czpop1990
drop pop2000 pumapop2000 czpop2000

save "$datadir\working_data\censuspop7010.dta", replace

