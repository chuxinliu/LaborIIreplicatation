/*
//======================== Trade and Migration IPUMS ==========================|
////////////////////////////////////////////////////////////////////////////////
1. Census Share Control
2. IPUMS: pop by 12 edu*age groups
3. NTR Gap
4. CZ controls
////////////////////////////////////////////////////////////////////////////////
*/

clear*
set more off, perm
global datadir "F:\GitHub\LaborIIreplicatation\Data"
global outdir  "F:\GitHub\LaborIIreplicatation\Result"

////////////////////////// 1. Census Share Control /////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

use "$datadir\working_data\censuspop7010.dta", clear
drop if year == 2007
drop natl_*

rename cz90 czone
rename cz_pop_1564 age1564
rename cz_pop      totpop
rename cz_pop_1524 under_25
*keep year czone totpop age1534 age1564 under_25 hisp asian amind black other white age* f_*_age* m_*_age* male female

/////////////////////////// 3. NTR Gap  ////////////////////////////////////////
merge m:1 czone using "$datadir\working_data\NTR GAP.dta"
	keep if _merge == 3
	drop if year == 1989 | year == 1999 | year == 2009
	drop _merge

///////////////////////// 4. CZ Controls ///////////////////////////////////////
merge m:1 czone using "$datadir\working_data\1990 CZ Controls.dta" 
	keep if _merge ==3
	drop _merge
	sort czone year
	
/*Get controls from CENSUS*/
merge 1:1  czone year using "$datadir\working_data\Census_1990Share_Controls.dta"
drop if _merge !=3
erase "$datadir\working_data\Census_1990Share_Controls.dta"

*Post 2001 interactions
global controls
foreach var in ntr_gap cz_pop_under25share1990 cz_pop_hisshare1990 cz_pop_asianshare1990 cz_pop_amindshare1990 cz_pop_blackshare1990 cap_labor skill_int fem_lf_share l_sh_popedu_c l_sh_routine33 l_task_outsource neighbor_fx break_estimate debt_to_income {
	gen `var'_post = `var'*(year>2000)
}
tab year, gen(yeardum)
local vlist reg_midatl reg_encen reg_wncen reg_satl reg_escen reg_wscen reg_mount reg_pacif 
foreach v in `vlist'{
	gen `v'_2000 = `v'*(year==2000)
	gen `v'_2010 = `v'*(year==2010)
}

//-----------------------------------------------------------------------------|
///////////////////2. IPUMS: pop by 12 edu*age groups /////////////////////////|
//-----------------------------------------------------------------------------|

gen underhs  = cz_pop_lshs
gen hs_scol  = cz_pop_hssc
gen col_mor  = cz_pop_cg

global edage
foreach yyyy in 2534 3544 4554 5564 {
	gen underhs_age`yyyy' = cz_pop_`yyyy'_lshs
	gen hs_scol_age`yyyy' = cz_pop_`yyyy'_hssc
	gen col_mor_age`yyyy' = cz_pop_`yyyy'_cg
	global edage $edage underhs_age`yyyy' hs_scol_age`yyyy' col_mor_age`yyyy'
}

//////////////////////////////// Panel Data ////////////////////////////////////
xtset czone year, delta(10)

gen cz_pop_other = totpop - cz_pop_white - cz_pop_black - cz_pop_asian - cz_pop_amind
rename cz_pop_male male
rename cz_pop_female female
rename cz_pop_his hispanic
rename cz_pop_black black
rename cz_pop_asian asian
rename cz_pop_white white
rename cz_pop_other other
rename cz_pop_amind amind

local dvars $edage male female hispanic black asian white other amind underhs hs_scol col_mor 
	foreach y in `dvars'{
		gen `y'_weight_1980 = `y'*(year == 1980)
		gen `y'_weight_1990 = `y'*(year == 1990)
		bys czone: egen `y'weight_1990 = max(`y'_weight_1990)
		bys czone: egen `y'weight_1980 = max(`y'_weight_1980)
		drop `y'_weight_1990 `y'_weight_1980
		gen ln`y' = log(`y')
		gen lc`y' =d.ln`y'
	}
local all_controls i.year cap_labor_post skill_int_post fem_lf_share_post l_sh_routine33_post l_task_outsource_post neighbor_fx_post reg_*_*
*Table 2	
	eststo clear
	*SubPopulations
		eststo: reg  lcmale     ntr_gap_post l.lcmale     `all_controls' cz_pop_under25share1990_post cz_pop_hisshare1990_post  cz_pop_blackshare1990_post cz_pop_amindshare1990_post cz_pop_asianshare1990_post  l_sh_popedu_c_post [aw=maleweight_1990] 	 if year >1990,	cluster(czone)
		eststo: reg  lcfemale   ntr_gap_post l.lcfemale   `all_controls' cz_pop_under25share1990_post cz_pop_hisshare1990_post  cz_pop_blackshare1990_post cz_pop_amindshare1990_post cz_pop_asianshare1990_post  l_sh_popedu_c_post [aw=femaleweight_1990]   if year >1990,	cluster(czone)
		eststo: reg  lchispanic ntr_gap_post l.lchispanic `all_controls' cz_pop_under25share1990_post 							 cz_pop_blackshare1990_post cz_pop_amindshare1990_post cz_pop_asianshare1990_post  l_sh_popedu_c_post [aw=hispanicweight_1990] if year >1990,	cluster(czone)
		eststo: reg  lcblack    ntr_gap_post l.lcblack    `all_controls' cz_pop_under25share1990_post cz_pop_hisshare1990_post  							cz_pop_amindshare1990_post cz_pop_asianshare1990_post  l_sh_popedu_c_post [aw=blackweight_1990] 	 if year >1990,	cluster(czone)
		eststo: reg  lcwhite    ntr_gap_post l.lcwhite    `all_controls' cz_pop_under25share1990_post cz_pop_hisshare1990_post  cz_pop_blackshare1990_post cz_pop_amindshare1990_post cz_pop_asianshare1990_post  l_sh_popedu_c_post [aw=whiteweight_1990] 	 if year >1990,	cluster(czone)
		eststo: reg  lcasian    ntr_gap_post l.lcasian    `all_controls' cz_pop_under25share1990_post cz_pop_hisshare1990_post  cz_pop_blackshare1990_post cz_pop_amindshare1990_post 					 		   l_sh_popedu_c_post [aw=asianweight_1990] 	 if year >1990,	cluster(czone)
	esttab using "$outdir/Table_2a", replace se starlevels(* .1 ** 0.05 *** 0.01) r2  label  nomtitles  keep(ntr* *lc*)  compress booktabs b(3) se(3) varwidth(20)
	esttab using "$outdir/Table_2a", replace se starlevels(* .1 ** 0.05 *** 0.01) r2  label  nomtitles  keep(ntr* *lc*)  compress html b(3) se(3) varwidth(20)
	eststo clear
	
	eststo clear	
	*Education Levels
		eststo: reg  lcunderhs  ntr_gap_post l.lcunderhs  `all_controls' cz_pop_under25share1990_post cz_pop_hisshare1990_post  cz_pop_blackshare1990_post cz_pop_amindshare1990_post cz_pop_asianshare1990_post  [aw=underhsweight_1990] if year >1990,	cluster(czone)
		eststo: reg  lchs_scol  ntr_gap_post l.lchs_scol  `all_controls' cz_pop_under25share1990_post cz_pop_hisshare1990_post  cz_pop_blackshare1990_post cz_pop_amindshare1990_post cz_pop_asianshare1990_post  [aw=hs_scolweight_1990] if year >1990,	cluster(czone)
		eststo: reg  lccol_mor  ntr_gap_post l.lccol_mor  `all_controls' cz_pop_under25share1990_post cz_pop_hisshare1990_post  cz_pop_blackshare1990_post cz_pop_amindshare1990_post cz_pop_asianshare1990_post  [aw=col_morweight_1990] if year >1990,	cluster(czone)
	esttab using "$outdir/Table_2b", replace se starlevels(* .1 ** 0.05 *** 0.01) r2  label  nomtitles  keep(ntr* *lc*)  compress booktabs b(3) se(3) varwidth(20)
	esttab using "$outdir/Table_2b", replace se starlevels(* .1 ** 0.05 *** 0.01) r2  label  nomtitles  keep(ntr* *lc*)  compress html b(3) se(3) varwidth(20)
	eststo clear

*Table 3
capture erase "$outdir/Table_3.tex"
	*Education x Age 
	local all_controls  i.year cap_labor_post skill_int_post  fem_lf_share_post  l_sh_routine33_post l_task_outsource_post  neighbor_fx_post reg_*_*
	foreach age in 2534 3544 4554 5564{
	loc j = 1
		rename ntr_gap_post ntr_gap_post_`age'
			foreach ed in underhs hs_scol col_mor{
				eststo: reg lc`ed'_age`age' ntr_gap_post l.lc`ed'_age`age'  `all_controls' cz_pop_under25share1990_post cz_pop_hisshare1990_post  cz_pop_blackshare1990_post cz_pop_amindshare1990_post cz_pop_asianshare1990_post  [aw=`ed'_age`age'weight_1990] if year >1990,	cluster(czone)
			}
		if "`j'" == "1" {
			loc titles  `"mtitles("UnderHS" "HS - Some College" "College More")"'
		}
		else if "`j'"!="1" {
			loc titles nomtitles
		}

		esttab using "$outdir/Table_3.tex", append se star(* 0.10 ** 0.05 *** 0.01)	r2(4) label keep(ntr_gap_post_`age') `titles' nogaps collabels(none) noobs  ///
		compress booktabs b(3) se(3) varwidth(20)
		eststo clear
		local j = 0
	}
	eststo clear
	

