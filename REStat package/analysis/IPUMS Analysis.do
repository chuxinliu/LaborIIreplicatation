//================================== Trade and Migration IPUMS =====================================|
////////////////////////////////////////////////////////////////////////////////////////////////////|
clear*
set more off, perm
global datadir "C:/Users/agreenland/Dropbox/Trade shocks and migration/Replication data and programs/data"
global outdir  "C:/Users/agreenland/Dropbox/Trade shocks and migration/Replication data and programs/results"
cd "$datadir"
////////////////////////////////////////////////////////////////////////////////////////////////////|
use "Census Population Data 1970-2010.dta", clear
	keep year czone whitepop blackpop amindpop asianpop hisppop totpop under_25
	keep if mod(year,10)==0
	 foreach pop in under_25 hisp asian amind black  white{
		gen `pop'share = (`pop'/totpop)*(year == 1990)
		bys czone : egen `pop'share1990 = max(`pop'share)
		drop `pop'share
	}
	keep year czone *share1990
save "Census_1990Share_Controls.dta",replace

use "IPUMS_CZ_1564_7010_withGQ.dta", clear
drop if year == 2007
	drop tpop_after_collapse nat_*
	rename pop1564 age1564
	rename cz_pop totpop
	rename age1524 under_25
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

tab year, gen(yeardum)
local vlist  reg_midatl reg_encen reg_wncen reg_satl reg_escen reg_wscen reg_mount reg_pacif 
foreach v in `vlist'{
	gen `v'_2000 = `v'*(year==2000)
	gen `v'_2010 = `v'*(year==2010)
}
////////////////////////////////////////////////////////////////////////////////////////////////////|
//___________________________________________Section 4______________________________________________|
//	4.1 Focusing on Under Age and Education															|
//	------------------------------------------------------------------------------------------------|
*variables are of the format  m_ed1_1524   males ages 15-24 underhs education
*education: 1 UnderHS, 2 HS Only, 3 Some Coll, 4 College, 5 More
egen underhs = rowtotal(m_ed1_age2534 m_ed1_age3544 m_ed1_age4554 m_ed1_age5564 f_ed1_age2534 f_ed1_age3544 f_ed1_age4554 f_ed1_age5564)
egen hsonly  = rowtotal(m_ed2_age2534 m_ed2_age3544 m_ed2_age4554 m_ed2_age5564 f_ed2_age2534 f_ed2_age3544 f_ed2_age4554 f_ed2_age5564)
egen somecol = rowtotal(m_ed3_age2534 m_ed3_age3544 m_ed3_age4554 m_ed3_age5564 f_ed3_age2534 f_ed3_age3544 f_ed3_age4554 f_ed3_age5564)
egen college = rowtotal(m_ed4_age2534 m_ed4_age3544 m_ed4_age4554 m_ed4_age5564 f_ed4_age2534 f_ed4_age3544 f_ed4_age4554 f_ed4_age5564)
egen morecol = rowtotal(m_ed5_age2534 m_ed5_age3544 m_ed5_age4554 m_ed5_age5564 f_ed5_age2534 f_ed5_age3544 f_ed5_age4554 f_ed5_age5564)

gen hs_scol  = hsonly + somecol
gen col_mor  = college + morecol

global edage
foreach yyyy in 2534 3544 4554 5564{
	gen underhs_age`yyyy' = 0
	gen hs_scol_age`yyyy' = 0
	gen col_mor_age`yyyy' = 0 
	foreach g in m f{
		gen `g'_underhs_age`yyyy' = `g'_ed1_age`yyyy'
		gen `g'_hs_scol_age`yyyy' = `g'_ed2_age`yyyy' + `g'_ed3_age`yyyy'
		gen `g'_col_mor_age`yyyy' = `g'_ed4_age`yyyy' + `g'_ed5_age`yyyy'
		replace underhs_age`yyyy' = underhs_age`yyyy' + `g'_underhs_age`yyyy'
		replace hs_scol_age`yyyy' = hs_scol_age`yyyy' + `g'_hs_scol_age`yyyy'
		replace col_mor_age`yyyy' = col_mor_age`yyyy' + `g'_col_mor_age`yyyy'
		global edage $edage `g'_underhs_age`yyyy' `g'_hs_scol_age`yyyy' `g'_col_mor_age`yyyy'
	}	
	global edage $edage underhs_age`yyyy' hs_scol_age`yyyy' col_mor_age`yyyy'
}

xtset czone year, delta(10)
local dvars $edage male female hispanic black asian white other amind underhs hsonly somecol college col_mor morecol hs_scol 
	foreach y in `dvars'{
		gen `y'_weight_1980 = `y'*(year == 1980)
		gen `y'_weight_1990 = `y'*(year == 1990)
		bys czone: egen `y'weight_1990 = max(`y'_weight_1990)
		bys czone: egen `y'weight_1980 = max(`y'_weight_1980)
		drop `y'_weight_1990 `y'_weight_1980
		gen ln`y' = log(`y')
		gen lc`y' =d.ln`y'
	}
	
local all_controls  i.year cap_labor_post skill_int_post  fem_lf_share_post  l_sh_routine33_post	l_task_outsource_post  neighbor_fx_post reg_*_*
*Table 2	
	eststo clear
	*SubPopulations
		eststo: reg  lcmale     ntr_gap_post l.lcmale     `all_controls' under_25share1990_post hispshare1990_post  blackshare1990_post amindshare1990_post asianshare1990_post  l_sh_popedu_c_post [aw=maleweight_1990] 	 if year >1990,	cluster(czone)
		eststo: reg  lcfemale   ntr_gap_post l.lcfemale   `all_controls' under_25share1990_post hispshare1990_post  blackshare1990_post amindshare1990_post asianshare1990_post  l_sh_popedu_c_post [aw=femaleweight_1990]   if year >1990,	cluster(czone)
		eststo: reg  lchispanic ntr_gap_post l.lchispanic `all_controls' under_25share1990_post 					blackshare1990_post amindshare1990_post asianshare1990_post  l_sh_popedu_c_post [aw=hispanicweight_1990] if year >1990,	cluster(czone)
		eststo: reg  lcblack    ntr_gap_post l.lcblack    `all_controls' under_25share1990_post hispshare1990_post  					amindshare1990_post asianshare1990_post  l_sh_popedu_c_post [aw=blackweight_1990] 	 if year >1990,	cluster(czone)
		eststo: reg  lcwhite    ntr_gap_post l.lcwhite    `all_controls' under_25share1990_post hispshare1990_post  blackshare1990_post amindshare1990_post asianshare1990_post  l_sh_popedu_c_post [aw=whiteweight_1990] 	 if year >1990,	cluster(czone)
		eststo: reg  lcasian    ntr_gap_post l.lcasian    `all_controls' under_25share1990_post hispshare1990_post  blackshare1990_post amindshare1990_post 					 l_sh_popedu_c_post [aw=asianweight_1990] 	 if year >1990,	cluster(czone)
	*Education Levels
		eststo: reg  lcunderhs  ntr_gap_post l.lcunderhs  `all_controls' under_25share1990_post hispshare1990_post  blackshare1990_post amindshare1990_post asianshare1990_post  [aw=underhsweight_1990] if year >1990,	cluster(czone)
		eststo: reg  lchs_scol  ntr_gap_post l.lchs_scol  `all_controls' under_25share1990_post hispshare1990_post  blackshare1990_post amindshare1990_post asianshare1990_post  [aw=hs_scolweight_1990] if year >1990,	cluster(czone)
		eststo: reg  lccol_mor  ntr_gap_post l.lccol_mor  `all_controls' under_25share1990_post hispshare1990_post  blackshare1990_post amindshare1990_post asianshare1990_post  [aw=col_morweight_1990] if year >1990,	cluster(czone)
	esttab using "$outdir/Table_2", replace se starlevels(* .1 ** 0.05 *** 0.01) r2  label ///
	nomtitles   compress title("Table 2") booktabs b(3) se(3) varwidth(20)
	eststo clear

*Table 3
capture erase "$outdir/Table_3"
	*Education x Age 
	local all_controls  i.year cap_labor_post skill_int_post  fem_lf_share_post  l_sh_routine33_post	l_task_outsource_post  neighbor_fx_post reg_*_*
	foreach age in 2534 3544 4554 5564{
	loc j = 1
		rename ntr_gap_post ntr_gap_post_`age'
			foreach ed in underhs hs_scol col_mor{
				eststo: reg lc`ed'_age`age' ntr_gap_post l.lc`ed'_age`age'  `all_controls' under_25share1990_post hispshare1990_post  blackshare1990_post amindshare1990_post asianshare1990_post  [aw=`ed'_age`age'weight_1990] if year >1990,	cluster(czone)
			}
		if "`j'" == "1" {
			loc titles  `"mtitles("UnderHS" "HS - Some College" "College More")"'
		}
		else if "`j'"!="1" {
			loc titles nomtitles
		}

		esttab using "$outdir/Table_3", append se star(* 0.10 ** 0.05 *** 0.01)	r2(4)  keep(ntr_gap_post_`age') `titles' nogaps collabels(none)	noobs  ///
		compress title("Table 3") booktabs b(3) se(3) varwidth(20)
		eststo clear
		local j = 0
	}
	eststo clear
	
