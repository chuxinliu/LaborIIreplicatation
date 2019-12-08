clear all
set more off
set matsize 8000
set maxvar 10000

local home "\HOME"

cd "`home'"

local logpath "`home'Log files\"

capture log close
log using "`logpath'nels_els_regressions_log.txt", text replace


* The global resultpath path is for the nearby programs addrow.do and addblankrow.do *
local resultspath "`home'Results\"
global resultspath "`home'Results\"

* The local intdatapath is where the cleaned NELS:88 and ELS:2002 data file is. *
local intdatapath "`home'Intermediate data\"


/*************************************************
Summary statistics and regressions using NELS:88 and ELS:2002
	for "Import Competition and Internal Migration"
	by Andy Greenland, John Lopresti, and Peter McHenry

History: 
	2/17/2018: Formatted for posted replication files

This program estimates summary statistics and regressions using NELS:88 and 
ELS:2002 data.  The data include geocoded respondent locations and use is 
restricted.  The restricted-access versions of the data sets can be used
with a license from the U.S. Department of Education.  Researchers with 
institutional affiliations can apply for a license.

*************************************************/


use "`intdatapath'nels_els_cleandata"


* Set 10th grade commuting zone as panel variable *
xtset g10_cz


* Local for list of CZ control variables *
local reg_year_fe "reg_midatl_g10 reg_encen_g10 reg_wncen_g10 reg_satl_g10 reg_escen_g10 reg_wscen_g10 reg_mount_g10 reg_pacif_g10"

* Locals for variable titles *
local hsdiploma_title "High School Diploma Receipt"
local pse_anyattend_title "Any Post-secondary Education Attendance"
local attend_2or4yrcol_title "Attendance at a 2-year or 4-year College"
local czmove_g10_g12_title "Migration between Grades 10 and 12"
local czmove_g10_a26_title "Migration between Grade 10 and Age 26"
local notfacetofacejob_title "Job Not Face-to-Face"
local notonsitejob_title "Job Not On-Site"

* Labels for regressors *
local czmove_g10_a26_lab "Migration rate (10th grade to age 26)"
local ntr_gap_g10_lab "NTR Gap"
local neighbor_fx_g10_lab "Neighbor NTR Gap" 
local els2002_lab "ELS2002" 
local male_lab "Male" 
local hispanic_lab "Hispanic" 
local black_lab "Black" 
local asian_lab "Asian" 
local testread_ptile_wt_lab "Reading test" 
local testmath_ptile_wt_lab "Math test" 
local parHS_lab "Parent high school"
local parSome_lab "Parent some college"
local parBA_lab "Parent bachelor's degree"
local parMAplus_lab "Parent master's or more"
local faminc_imp_2002d_lab "Family income (2002 dol.)" 
local momborn_foreign_lab "Mother foreign-born" 
local mom_imm_15yrsless_lab "Mother immigrant less than 15 years" 
local dadborn_foreign_lab "Father foreign-born" 
local dad_imm_15yrsless_lab "Father immigrant less than 15 years" 
local born_foreign_lab "Foreign born"

local cap_labor_g10_lab "1990 CZ capital-labor ratio" 
local skill_int_g10_lab "1990 CZ skill intensity" 
local l_sh_routine33_g10_lab "1990 CZ task routineness" 
local l_task_outsource_g10_lab "1990 CZ task offshorability" 
local fem_lf_share_g10_lab "1990 CZ female LF share"

local mfg_share_g10_lab "1990 CZ manufacturing share"
local break_estimate_g10_lab "CZ house price trend break"
local debt_to_income_g10_lab "CZ debt to income ratio"
local l_sh_popfborn_g10_lab "1990 CZ foreign-born share"
local l_sh_popedu_c_g10_lab "1990 CZ college share"
local mfg_share_g10_lab "1990 CZ  share"

local blackshare_g10_lab "1990 CZ black share"
local hispshare_g10_lab "1990 CZ Hispanic share"
local amindshare_g10_lab "1990 CZ Am. Ind. share"
local asianshare_g10_lab "1990 CZ Asian share"
local under_25share_g10_lab "1990 CZ under 25 share"

local reg_midatl_g10_lab "Middle Atlantic"
local reg_encen_g10_lab "East North Central"
local reg_wncen_g10_lab "West North Central"
local reg_satl_g10_lab "South Atlantic"
local reg_escen_g10_lab "East South Central"
local reg_wscen_g10_lab "West South Central"
local reg_mount_g10_lab "Mountain"
local reg_pacif_g10_lab "Pacific"



***********************************************************************
******** TABLE A6: Summary Statistics for NELS:88 and ELS:2002 ********
***********************************************************************

file open myfile using "`resultspath'tableA4_sumstats_nelsels.tex", write replace
file write myfile ///
	"\begin{table}[htbp]\centering" _n ///
	"\scriptsize" _n ///
	"\caption{Summary Statistics for NELS:88 and ELS:2002 \label{sumstats_nelsels}}" _n ///
	"\begin{tabular}{l*{2}{c}}" _n ///
	"\toprule" _n ///
	"& (1) & (2) \\" _n ///
	"& NELS:88 & ELS:2002 \\" _n ///
	"\midrule" _n
file close myfile

* Preliminary regression for e(sample) *
reg czmove_g10_a26 ntr_gap_g10 els2002 male hispanic black asian, cluster(g10_cz)
gen byte mainsamp=e(sample)
tab mainsamp, m

sum ntr_gap_g10 if (els2002==1)&(mainsamp==1), detail

foreach var of varlist male hispanic black asian testread_ptile_wt testmath_ptile_wt parHS parSome parBA parMAplus faminc_imp_2002d momborn_foreign dadborn_foreign born_foreign ntr_gap_g10 czmove_g10_a26	{

	sum `var' if (nels88==1)&(mainsamp==1)
	if "`var'"=="faminc_imp_2002d"	{
		local m_nels = trim("`: display %8.0gc =r(mean)'")
	}
	else	{
		local m_nels = trim("`: display %5.0gc =r(mean)'")
	}
	local n_nels = trim("`: display %8.0gc =round(r(N),10)'")
	
	sum `var' if (els2002==1)&(mainsamp==1)
	if "`var'"=="faminc_imp_2002d"	{
		local m_els = trim("`: display %8.0gc =r(mean)'")
	}
	else {
		local m_els = trim("`: display %5.0gc =r(mean)'")
	}
		local n_els = trim("`: display %8.0gc =round(r(N),10)'")
	
	file open myfile using "`resultspath'tableA4_sumstats_nelsels.tex", write append
	file write myfile ///
	 "``var'_lab' & `m_nels' & `m_els' \\" _n ///
	 "\addlinespace" _n
	file close myfile

}
* Count commuting zones (clusters) *
reg czmove_g10_a26 ntr_gap_g10 els2002 male hispanic black asian if (nels88==1)&(mainsamp==1), cluster(g10_cz)
local ncz_nels = trim("`: display %8.0gc =round(e(N_clust),10)'")
reg czmove_g10_a26 ntr_gap_g10 els2002 male hispanic black asian if (els2002==1)&(mainsamp==1), cluster(g10_cz)
local ncz_els = trim("`: display %8.0gc =round(e(N_clust),10)'")
* Count commuting zones that are in both samples (NELS:88 and ELS:2002) *
bysort g10_cz: egen nels_cz_sum=sum(nels88*mainsamp)
by g10_cz: egen els_cz_sum=sum(els2002*mainsamp)
gen flag=0
by g10_cz: replace flag=1 if (_n==1)&(nels_cz_sum>0)&(nels_cz_sum<.)&(els_cz_sum>0)&(els_cz_sum<.)
replace flag=0 if g10_cz==.
egen both_cz_sum=sum(flag)
sum both_cz_sum
local ncz_both = trim("`: display %8.0gc =round(r(mean),10)'")

* Double-check code that counts CZs in the NELS:88 (should match number of clusters in the above regression)
gen flag_nels=0
by g10_cz: replace flag_nels=1 if (_n==1)&(nels_cz_sum>0)&(nels_cz_sum<.)
replace flag_nels=0 if g10_cz==.
egen cz_sum_nels=sum(flag_nels)
sum cz_sum_nels

* Double-check code that counts CZs in the ELS:2002 (should match number of clusters in the above regression)
gen flag_els=0
by g10_cz: replace flag_els=1 if (_n==1)&(els_cz_sum>0)&(els_cz_sum<.)
replace flag_els=0 if g10_cz==.
egen cz_sum_els=sum(flag_els)
sum cz_sum_els

file open myfile using "`resultspath'tableA4_sumstats_nelsels.tex", write append
file write myfile ///
"\midrule" _n ///
"Observations & `n_nels' & `n_els' \\" _n ///
"Commuting Zones & `ncz_nels' & `ncz_els' \\" _n ///
"\midrule" _n ///
"\multicolumn{3}{l}{\parbox{.5\textwidth}{NOTES: Data from NELS:88 and ELS:2002.  Each cell presents a sample average, except for observations rows, which show sample sizes.  Approximately `ncz_both' commuting zones are represented in both the NELS:88 and ELS:2002 samples.  Sample sizes rounded to the nearest ten for confidentiality.}}\\" _n ///
"\bottomrule" _n ///
"\end{tabular}" _n ///
"\end{table}"
file close myfile

drop mainsamp flag nels_cz_sum els_cz_sum both_cz_sum flag_nels cz_sum_nels flag_els cz_sum_els



***************************************************************************************
******** TABLE 4: Import Competition and Migration between Grade 10 and Age 26 ********
******** (TABLE A7 is a version showing more controls)                         ********
***************************************************************************************

file open myfile using "`resultspath'table4_mig_indivcntrls.tex", write replace
file write myfile ///
 "\begin{table}[htbp]\centering" _n ///
 "\scriptsize" _n ///
 "\caption{Import Competition and Migration between Grade 10 and Age 26 \label{mig_indivcntrls}}" _n ///
 "\begin{tabular}{l*{5}{c}}" _n ///
 "\toprule" _n ///
 " & (1) & (2) & (3) & (4) & (5) \\" _n ///
 " & Migrate & Migrate & Migrate & Migrate & Migrate \\" _n ///
 " \midrule" _n
file close myfile

local controls1 "els2002 male hispanic black asian testread_ptile_wt testmath_ptile_wt `reg_year_fe'"
local controls2 "els2002 male hispanic black asian parHS parSome parBA parMAplus faminc_imp_2002d `reg_year_fe'"
local controls3 "els2002 male hispanic black asian momborn_foreign dadborn_foreign born_foreign `reg_year_fe'"
local controls4 "els2002 male hispanic black asian parHS parSome parBA parMAplus faminc_imp_2002d momborn_foreign dadborn_foreign born_foreign `reg_year_fe'"
local controls5 "els2002 male hispanic black asian testread_ptile_wt testmath_ptile_wt parHS parSome parBA parMAplus faminc_imp_2002d momborn_foreign dadborn_foreign born_foreign `reg_year_fe'"

	forvalues c=1(1)5	{
	
		xtreg czmove_g10_a26 ntr_gap_g10 `controls`c'', fe cluster(g10_cz)

		foreach stub in ntr_gap_g10 `controls`c''	{
			scalar b`c'`stub'=_b[`stub']
			scalar se`c'`stub'=_se[`stub']
			if abs(scalar(b`c'`stub')/scalar(se`c'`stub'))>2.576	{
				local ast`c'`stub'="***"
			}
			else if abs(scalar(b`c'`stub')/scalar(se`c'`stub'))>1.96	{
				local ast`c'`stub'="**"
			}
			else if abs(scalar(b`c'`stub')/scalar(se`c'`stub'))>1.645	{
				local ast`c'`stub'="*"
			}
			else	{
				local ast`c'`stub'=""
			}
			local b`c'`stub': display %6.0gc =scalar(b`c'`stub')
			local se`c'`stub': display %6.0gc =scalar(se`c'`stub')
			local lp`c'`stub' "("
			local rp`c'`stub' ")"
		}
		local N`c': display %9.0gc =round(e(N),10)
		*local N`c': display %9.0gc =e(N)
		local r2_a`c': display %6.0gc =e(r2_a)
	}
	
	foreach stub in ntr_gap_g10 els2002 male hispanic black asian testread_ptile_wt testmath_ptile_wt parHS parSome parBA parMAplus faminc_imp_2002d momborn_foreign dadborn_foreign born_foreign	{
		file open myfile using "`resultspath'table4_mig_indivcntrls.tex", write append
		file write myfile ///
		 "``stub'_lab' &`b1`stub''`ast1`stub'' & `b2`stub''`ast2`stub'' & `b3`stub''`ast3`stub'' & `b4`stub''`ast4`stub'' & `b5`stub''`ast5`stub'' \\" _n ///
		 " & `lp1`stub''`se1`stub''`rp1`stub'' & `lp2`stub''`se2`stub''`rp2`stub'' & `lp3`stub''`se3`stub''`rp3`stub'' & `lp4`stub''`se4`stub''`rp4`stub'' & `lp5`stub''`se5`stub''`rp5`stub'' \\" _n ///
		 "\addlinespace" _n
		file close myfile	
	}
	file open myfile using "`resultspath'table4_mig_indivcntrls.tex", write append
	file write myfile ///
		 "\midrule" _n ///
		 "Observations & `N1' & `N2' & `N3' & `N4' & `N5' \\" _n ///
		 "\(R^{2}\) & `r2_a1' & `r2_a2' & `r2_a3' & `r2_a4' & `r2_a5' \\" _n ///
		 "\addlinespace" _n
	file close myfile

file open myfile using "`resultspath'table4_mig_indivcntrls.tex", write append
file write myfile ///
 "\midrule" _n ///
 "\multicolumn{6}{l}{\parbox{.75\textwidth}{NOTES: Data from NELS:88 and ELS:2002.  Dependent variable in all specifications is an indicator for living at age 26 in a different commuting zone from 10th grade residence.  All specifications include commuting zone fixed effects and Census division (9 categories) by year effects.  Standard errors clustered at 10th grade CZ level in parentheses where ***,**,* indicates significance at 1\%, 5\%, 10\% level respectively.}}\\" _n ///
 "\bottomrule" _n ///
 "\end{tabular}" _n ///
 "\end{table}"
file close myfile



**********************************************************************************
******** TABLE 5: Import Competition and Migration by Respondents' Traits ********
**********************************************************************************

file open myfile using "`resultspath'table5_mig_bychar.tex", write replace
file write myfile ///
 "\begin{table}[htbp]\centering" _n ///
 "\scriptsize" _n ///
 "\caption{Import Competition and Migration by Respondents' Traits \label{mig_bychar}}" _n ///
 "\begin{tabular}{llll}" _n ///
 "\toprule" _n ///
 " & (1) & (2) & (3) \\" _n ///
 " & Coef. & St.Err. & N \\" _n ///
 " \midrule" _n
file close myfile

global tablename "5_mig_bychar"

* By sex *
global rowtitle "Male"
xtreg czmove_g10_a26 ntr_gap_g10 els2002 hispanic black asian `reg_year_fe' if (male==1), fe cluster(g10_cz)
do addrow
global rowtitle "Female"
xtreg czmove_g10_a26 ntr_gap_g10 els2002 hispanic black asian `reg_year_fe' if (male==0), fe cluster(g10_cz)
do addrow
do addblankrow

* By race/ethnicity *
bysort els2002: tab hispanic black
by els2002: tab hispanic asian
by els2002: tab black asian
global rowtitle "Black, non-Hispanic"
xtreg czmove_g10_a26 ntr_gap_g10 els2002 male `reg_year_fe' if (black==1), fe cluster(g10_cz)
do addrow
global rowtitle "Hispanic"
xtreg czmove_g10_a26 ntr_gap_g10 els2002 male `reg_year_fe' if (hispanic==1), fe cluster(g10_cz)
do addrow
global rowtitle "Asian"
xtreg czmove_g10_a26 ntr_gap_g10 els2002 male `reg_year_fe' if (asian==1), fe cluster(g10_cz)
do addrow
global rowtitle "White, non-Hispanic"
xtreg czmove_g10_a26 ntr_gap_g10 els2002 male `reg_year_fe' if (black==0)&(hispanic==0)&(asian==0), fe cluster(g10_cz)
do addrow
do addblankrow

* By foreign born status *
bysort els2002: tab momborn_foreign dadborn_foreign
by els2002: tab momborn_foreign born_foreign
by els2002: tab dadborn_foreign born_foreign
gen parborn_foreign=0 if (momborn_foreign==0)&(dadborn_foreign==0)
replace parborn_foreign=1 if (momborn_foreign==1)|(dadborn_foreign==1)
global rowtitle "Foreign born"
xtreg czmove_g10_a26 ntr_gap_g10 els2002 male hispanic black asian `reg_year_fe' if (born_foreign==1), fe cluster(g10_cz)
do addrow
global rowtitle "Foreign born parent"
xtreg czmove_g10_a26 ntr_gap_g10 els2002 male hispanic black asian `reg_year_fe' if (parborn_foreign==1), fe cluster(g10_cz)
do addrow
do addblankrow

* By parents' education *
global rowtitle "Parents no PSE"
xtreg czmove_g10_a26 ntr_gap_g10 els2002 male hispanic black asian `reg_year_fe' if (parSome==0)&(parBA==0)&(parMAplus==0), fe cluster(g10_cz)
do addrow
global rowtitle "Parents some PSE"
xtreg czmove_g10_a26 ntr_gap_g10 els2002 male hispanic black asian `reg_year_fe' if (parSome==1), fe cluster(g10_cz)
do addrow
global rowtitle "Parents BA"
xtreg czmove_g10_a26 ntr_gap_g10 els2002 male hispanic black asian `reg_year_fe' if (parBA==1)|(parMAplus==1), fe cluster(g10_cz)
do addrow
do addblankrow

* By parents' income *
tab faminc_imp_2002d els2002
global rowtitle "Family income less than 40,000 (2002D)"
xtreg czmove_g10_a26 ntr_gap_g10 els2002 male hispanic black asian `reg_year_fe' if (faminc_imp_2002d<40000), fe cluster(g10_cz)
do addrow
global rowtitle "Family income more than 40,000 (2002D)"
xtreg czmove_g10_a26 ntr_gap_g10 els2002 male hispanic black asian `reg_year_fe' if (faminc_imp_2002d>=40000)&(faminc_imp_2002d<.), fe cluster(g10_cz)
do addrow
do addblankrow
xtreg czmove_g10_a26 ntr_gap_g10 els2002 male hispanic black asian `reg_year_fe' if (faminc_imp_2002d<70000), fe cluster(g10_cz)
xtreg czmove_g10_a26 ntr_gap_g10 els2002 male hispanic black asian `reg_year_fe' if (faminc_imp_2002d>=70000)&(faminc_imp_2002d<.), fe cluster(g10_cz)

* By high school test scores *
bysort els2002: sum testread_ptile_wt testmath_ptile_wt
global rowtitle "Below median reading test"
xtreg czmove_g10_a26 ntr_gap_g10 els2002 male hispanic black asian `reg_year_fe' if (testread_ptile_wt<=50), fe cluster(g10_cz)
do addrow
global rowtitle "Above median reading test"
xtreg czmove_g10_a26 ntr_gap_g10 els2002 male hispanic black asian `reg_year_fe' if (testread_ptile_wt>50)&(testread_ptile_wt<.), fe cluster(g10_cz)
do addrow
global rowtitle "Below median math test"
xtreg czmove_g10_a26 ntr_gap_g10 els2002 male hispanic black asian `reg_year_fe' if (testmath_ptile_wt<=50), fe cluster(g10_cz)
do addrow
global rowtitle "Above median math test"
xtreg czmove_g10_a26 ntr_gap_g10 els2002 male hispanic black asian `reg_year_fe' if (testmath_ptile_wt>50)&(testmath_ptile_wt<.), fe cluster(g10_cz)
do addrow
do addblankrow

file open myfile using "`resultspath'table5_mig_bychar.tex", write append
file write myfile ///
 "\midrule" _n ///
 "\multicolumn{4}{l}{\parbox{.6\textwidth}{NOTES: Data from NELS:88 and ELS:2002.  Dependent variable in all specifications is an indicator for living at age 26 in a different commuting zone from 10th grade residence.  Table only shows the coefficient on tariff gap (import competition) at the CZ level interacted with an indicator for ELS:2002 respondents.  All models also include a constant, indicators for being in the ELS:2002 (rather than NELS:88), sex, and race/ethnicity.  Parents' education is maximum of father and mother.  All specifications including commuting zone fixed effects and Census division (9 categories) by year effects.  Standard errors clustered at 10th grade CZ level in parentheses where ***,**,* indicates significance at 1\%, 5\%, 10\% level respectively.}}\\" _n ///
 "\bottomrule" _n ///
 "\end{tabular}" _n ///
 "\end{table}"
file close myfile
	


*************************************************************************************************************
******** TABLE A8: Import Competition and Migration between Grade 10 and Age 26, Varying CZ Controls ********
*************************************************************************************************************

file open myfile using "`resultspath'tableA5_mig_czcntrls.tex", write replace
file write myfile ///
 "\begin{table}[htbp]\centering" _n ///
 "\scriptsize" _n ///
 "\caption{Import Competition and Migration between Grade 10 and Age 26 \label{mig_czcntrls}}" _n ///
 "\begin{tabular}{l*{4}{c}}" _n ///
 "\toprule" _n ///
 " & (1) & (2) & (3) & (4) \\" _n ///
 " & Migrate & Migrate & Migrate & Migrate \\" _n ///
 " \midrule" _n
file close myfile

local controls1 "els2002 male hispanic black asian `reg_year_fe'"
local controls2 "els2002 male hispanic black asian `reg_year_fe' blackshare_g10 hispshare_g10 amindshare_g10 asianshare_g10 under_25share_g10"
local controls3 "els2002 male hispanic black asian `reg_year_fe' blackshare_g10 hispshare_g10 amindshare_g10 asianshare_g10 under_25share_g10 neighbor_fx_g10 l_task_outsource_g10 l_sh_routine33_g10 l_sh_popedu_c_g10 fem_lf_share_g10 skill_int_g10 cap_labor_g10"
local controls4 "els2002 male hispanic black asian `reg_year_fe' blackshare_g10 hispshare_g10 amindshare_g10 asianshare_g10 under_25share_g10 neighbor_fx_g10 l_task_outsource_g10 l_sh_routine33_g10 l_sh_popedu_c_g10 fem_lf_share_g10 skill_int_g10 cap_labor_g10 break_estimate_g10 debt_to_income_g10"

	forvalues c=1(1)4	{
	
		xtreg czmove_g10_a26 ntr_gap_g10 `controls`c'', fe cluster(g10_cz)

		foreach stub in ntr_gap_g10 `controls`c''	{
			scalar b`c'`stub'=_b[`stub']
			scalar se`c'`stub'=_se[`stub']
			if abs(scalar(b`c'`stub')/scalar(se`c'`stub'))>2.576	{
				local ast`c'`stub'="***"
			}
			else if abs(scalar(b`c'`stub')/scalar(se`c'`stub'))>1.96	{
				local ast`c'`stub'="**"
			}
			else if abs(scalar(b`c'`stub')/scalar(se`c'`stub'))>1.645	{
				local ast`c'`stub'="*"
			}
			else	{
				local ast`c'`stub'=""
			}
			local b`c'`stub': display %6.0gc =scalar(b`c'`stub')
			local se`c'`stub': display %6.0gc =scalar(se`c'`stub')
			local lp`c'`stub' "("
			local rp`c'`stub' ")"
		}
		local N`c': display %9.0gc =round(e(N),10)
		*local N`c': display %9.0gc =e(N)
		local r2_a`c': display %6.0gc =e(r2_a)
	}
	
	foreach stub in ntr_gap_g10 els2002 male hispanic black asian blackshare_g10 hispshare_g10 amindshare_g10 asianshare_g10 under_25share_g10 neighbor_fx_g10 l_task_outsource_g10 l_sh_routine33_g10 l_sh_popedu_c_g10 fem_lf_share_g10 skill_int_g10 cap_labor_g10 break_estimate_g10 debt_to_income_g10	{
		file open myfile using "`resultspath'tableA5_mig_czcntrls.tex", write append
		file write myfile ///
		 "``stub'_lab' &`b1`stub''`ast1`stub'' & `b2`stub''`ast2`stub'' & `b3`stub''`ast3`stub'' & `b4`stub''`ast4`stub'' \\" _n ///
		 " & `lp1`stub''`se1`stub''`rp1`stub'' & `lp2`stub''`se2`stub''`rp2`stub'' & `lp3`stub''`se3`stub''`rp3`stub'' & `lp4`stub''`se4`stub''`rp4`stub'' \\" _n ///
		 "\addlinespace" _n
		file close myfile	
	}
	file open myfile using "`resultspath'tableA5_mig_czcntrls.tex", write append
	file write myfile ///
		 "\midrule" _n ///
		 "Observations & `N1' & `N2' & `N3' & `N4' \\" _n ///
		 "\(R^{2}\) & `r2_a1' & `r2_a2' & `r2_a3' & `r2_a4' \\" _n ///
		 "\addlinespace" _n
	file close myfile

file open myfile using "`resultspath'tableA5_mig_czcntrls.tex", write append
file write myfile ///
 "\midrule" _n ///
 "\multicolumn{5}{l}{\parbox{.65\textwidth}{NOTES: Data from NELS:88 and ELS:2002.  Dependent variable in all specifications is an indicator for living at age 26 in a different commuting zone from 10th grade residence.  All specifications include commuting zone fixed effects and Census division (9 categories) by year effects.  Standard errors clustered at 10th grade CZ level in parentheses where ***,**,* indicates significance at 1\%, 5\%, 10\% level respectively.}}\\" _n ///
 "\bottomrule" _n ///
 "\end{tabular}" _n ///
 "\end{table}"
file close myfile



*************************************************************************************
******** TABLE A9: Import Competition and Migration between Grades 10 and 12 ********
*************************************************************************************

foreach var in czmove_g10_g12	{

	file open myfile using "`resultspath'tableA6_`var'.tex", write replace
	file write myfile ///
	 "\begin{table}[htbp]\centering" _n ///
	 "\scriptsize" _n ///
	 "\caption{Import Competition and ``var'_title' \label{`var'}}" _n ///
	 "\begin{threeparttable}" _n ///
	 "\begin{tabular}{*{2}{c}}" _n ///
	 "\toprule" _n ///
	 "(1) & (2) \\" _n ///
	 "\shortstack{Pooled} & \shortstack{CZ Fixed Effects} \\" _n ///
	 " \midrule" _n
	file close myfile

	* Baseline *
	forvalues c=1(1)2	{
	
		if `c'==1	{
			reg `var' ntr_gap_g10 els2002 `reg_year_fe' male hispanic black asian, cluster(g10_cz)
		}
		else if `c'==2	{
			xtreg `var' ntr_gap_g10 els2002 `reg_year_fe' male hispanic black asian, fe cluster(g10_cz)
		}
	
		scalar b`c'=_b[ntr_gap_g10]
		scalar se`c'=_se[ntr_gap_g10]
		if abs(scalar(b`c')/scalar(se`c'))>2.576	{
			local ast`c'="***"
		}
		else if abs(scalar(b`c')/scalar(se`c'))>1.96	{
			local ast`c'="**"
		}
		else if abs(scalar(b`c')/scalar(se`c'))>1.645	{
			local ast`c'="*"
		}
		else	{
			local ast`c'=""
		}
		local b`c': display %6.0gc =scalar(b`c')
		local se`c': display %6.0gc =scalar(se`c')
		local N`c': display %9.0gc =round(e(N),10)
		*local N`c': display %9.0gc =e(N)
	}
	
	file open myfile using "`resultspath'tableA6_`var'.tex", write append
	file write myfile ///
	 "\multicolumn{2}{c}{\emph{Baseline specifications}} \\" _n ///
	 "`b1'`ast1' & `b2'`ast2' \\ " _n ///
	 "(`se1')    & (`se2')    \\ " _n ///
	 "`N1'       & `N2'       \\ " _n ///
	 "\addlinespace" _n
	file close myfile	
	
	* Parent education controls *
	forvalues c=1(1)2	{
		if `c'==1	{
			reg `var' ntr_gap_g10 els2002 `reg_year_fe' male hispanic black asian parHS parSome parBA parMAplus, cluster(g10_cz)
		}
		else if `c'==2	{
			xtreg `var' ntr_gap_g10 els2002 `reg_year_fe' male hispanic black asian parHS parSome parBA parMAplus, fe cluster(g10_cz)
		}
		scalar b`c'=_b[ntr_gap_g10]
		scalar se`c'=_se[ntr_gap_g10]
		if abs(scalar(b`c')/scalar(se`c'))>2.576	{
			local ast`c'="***"
		}
		else if abs(scalar(b`c')/scalar(se`c'))>1.96	{
			local ast`c'="**"
		}
		else if abs(scalar(b`c')/scalar(se`c'))>1.645	{
			local ast`c'="*"
		}
		else	{
			local ast`c'=""
		}
		local b`c': display %6.0gc =scalar(b`c')
		local se`c': display %6.0gc =scalar(se`c')
		local N`c': display %9.0gc =round(e(N),10)
		*local N`c': display %9.0gc =e(N)
	}
	
	file open myfile using "`resultspath'tableA6_`var'.tex", write append
	file write myfile ///
	 "\multicolumn{2}{c}{\emph{Including Controls for Parents' Education}} \\" _n ///
	 "`b1'`ast1' & `b2'`ast2' \\ " _n ///
	 "(`se1')    & (`se2')    \\ " _n ///
	 "`N1'       & `N2'       \\ " _n ///
	 "\addlinespace" _n
	file close myfile
	
	* Subset of respondents with parents with no college *
	forvalues c=1(1)2	{
		if `c'==1	{
			reg `var' ntr_gap_g10 els2002 `reg_year_fe' male hispanic black asian if (parSome==0)&(parBA==0)&(parMAplus==0), cluster(g10_cz)
		}
		else if `c'==2	{
			xtreg `var' ntr_gap_g10 els2002 `reg_year_fe' male hispanic black asian if (parSome==0)&(parBA==0)&(parMAplus==0), fe cluster(g10_cz)
		}
		scalar b`c'=_b[ntr_gap_g10]
		scalar se`c'=_se[ntr_gap_g10]
		if abs(scalar(b`c')/scalar(se`c'))>2.576	{
			local ast`c'="***"
		}
		else if abs(scalar(b`c')/scalar(se`c'))>1.96	{
			local ast`c'="**"
		}
		else if abs(scalar(b`c')/scalar(se`c'))>1.645	{
			local ast`c'="*"
		}
		else	{
			local ast`c'=""
		}
		local b`c': display %6.0gc =scalar(b`c')
		local se`c': display %6.0gc =scalar(se`c')
		local N`c': display %9.0gc =round(e(N),10)
		*local N`c': display %9.0gc =e(N)
	}
	
	file open myfile using "`resultspath'tableA6_`var'.tex", write append
	file write myfile ///
	 "\multicolumn{2}{c}{\emph{Only Respondents with Less-Educated Parents}} \\" _n ///
	 "`b1'`ast1' & `b2'`ast2' \\ " _n ///
	 "(`se1')    & (`se2')    \\ " _n ///
	 "`N1'       & `N2'       \\ " _n ///
	 "\addlinespace" _n
	file close myfile

	file open myfile using "`resultspath'tableA6_`var'.tex", write append
	file write myfile ///
	 "\bottomrule" _n ///
	 "\end{tabular}" _n ///
	 "\begin{tablenotes}[para,flushleft]" _n ///
	 "NOTES: ***p$<$0.01 **p$<$0.05 *p$<$0.1.  Data from NELS:88 and ELS:2002.  Dependent variable in all specifications is an indicator for ``var'_title'.  Table only shows the coefficient on NTR tariff gap at the CZ level (zero for all NELS:88 respondents).  All models also include a constant, indicators for being in the ELS:2002 (rather than NELS:88), sex, race/ethnicity, and interactions between cohort membership (ELS:2002 or NELS:88) and Census division (9 categories).  Parents' education is maximum of father and mother, and controls are indicators for high school graduate, some college, BA, and post-BA degree.  Less-educated parents are those with no college education.  Standard errors clustered at 10th grade CZ level." _n ///
	 "\end{tablenotes}" _n ///
	 "\end{threeparttable}" _n ///
	 "\end{table}"
	file close myfile
	

}



****************************************************************************************************
******** TABLE A10: Import Competition and Migration between Grade 10 and Age 26 (weighted) ********
****************************************************************************************************

foreach var in czmove_g10_a26	{

	file open myfile using "`resultspath'tableA7_`var'_wt.tex", write replace
	file write myfile ///
	 "\begin{table}[htbp]\centering" _n ///
	 "\scriptsize" _n ///
	 "\caption{Import Competition and ``var'_title' (weighted) \label{`var'_wt}}" _n ///
	 "\begin{threeparttable}" _n ///
	 "\begin{tabular}{*{2}{c}}" _n ///
	 "\toprule" _n ///
	 "(1) & (2) \\" _n ///
	 "\shortstack{Pooled} & \shortstack{CZ Fixed Effects} \\" _n ///
	 " \midrule" _n
	file close myfile

	* Baseline *
	forvalues c=1(1)2	{
	
		if `c'==1	{
			reg `var' ntr_gap_g10 els2002 `reg_year_fe' male hispanic black asian [w=weight], cluster(g10_cz)
		}
		else if `c'==2	{
			reg `var' ntr_gap_g10 els2002 `reg_year_fe' male hispanic black asian i.g10_cz [w=weight], cluster(g10_cz)
		}
	
		scalar b`c'=_b[ntr_gap_g10]
		scalar se`c'=_se[ntr_gap_g10]
		if abs(scalar(b`c')/scalar(se`c'))>2.576	{
			local ast`c'="***"
		}
		else if abs(scalar(b`c')/scalar(se`c'))>1.96	{
			local ast`c'="**"
		}
		else if abs(scalar(b`c')/scalar(se`c'))>1.645	{
			local ast`c'="*"
		}
		else	{
			local ast`c'=""
		}
		local b`c': display %6.0gc =scalar(b`c')
		local se`c': display %6.0gc =scalar(se`c')
		local N`c': display %9.0gc =round(e(N),10)
		*local N`c': display %9.0gc =e(N)
	}
	
	file open myfile using "`resultspath'tableA7_`var'_wt.tex", write append
	file write myfile ///
	 "\multicolumn{2}{c}{\emph{Baseline specifications}} \\" _n ///
	 "`b1'`ast1' & `b2'`ast2' \\ " _n ///
	 "(`se1')    & (`se2')    \\ " _n ///
	 "`N1'       & `N2'       \\ " _n ///
	 "\addlinespace" _n
	file close myfile	
	
	* Parent education controls *
	forvalues c=1(1)2	{
		if `c'==1	{
			reg `var' ntr_gap_g10 els2002 `reg_year_fe' male hispanic black asian parHS parSome parBA parMAplus [w=weight], cluster(g10_cz)
		}
		else if `c'==2	{
			reg `var' ntr_gap_g10 els2002 `reg_year_fe' male hispanic black asian parHS parSome parBA parMAplus i.g10_cz [w=weight], cluster(g10_cz)
		}
		scalar b`c'=_b[ntr_gap_g10]
		scalar se`c'=_se[ntr_gap_g10]
		if abs(scalar(b`c')/scalar(se`c'))>2.576	{
			local ast`c'="***"
		}
		else if abs(scalar(b`c')/scalar(se`c'))>1.96	{
			local ast`c'="**"
		}
		else if abs(scalar(b`c')/scalar(se`c'))>1.645	{
			local ast`c'="*"
		}
		else	{
			local ast`c'=""
		}
		local b`c': display %6.0gc =scalar(b`c')
		local se`c': display %6.0gc =scalar(se`c')
		local N`c': display %9.0gc =round(e(N),10)
		*local N`c': display %9.0gc =e(N)
	}
	
	file open myfile using "`resultspath'tableA7_`var'_wt.tex", write append
	file write myfile ///
	 "\multicolumn{2}{c}{\emph{Including Controls for Parents' Education}} \\" _n ///
	 "`b1'`ast1' & `b2'`ast2' \\ " _n ///
	 "(`se1')    & (`se2')    \\ " _n ///
	 "`N1'       & `N2'       \\ " _n ///
	 "\addlinespace" _n
	file close myfile
	
	* Subset of respondents with parents with no college *
	forvalues c=1(1)2	{
		if `c'==1	{
			reg `var' ntr_gap_g10 els2002 `reg_year_fe' male hispanic black asian [w=weight] if (parSome==0)&(parBA==0)&(parMAplus==0), cluster(g10_cz)
		}
		else if `c'==2	{
			reg `var' ntr_gap_g10 els2002 `reg_year_fe' male hispanic black asian i.g10_cz [w=weight] if (parSome==0)&(parBA==0)&(parMAplus==0), cluster(g10_cz)
		}
		scalar b`c'=_b[ntr_gap_g10]
		scalar se`c'=_se[ntr_gap_g10]
		if abs(scalar(b`c')/scalar(se`c'))>2.576	{
			local ast`c'="***"
		}
		else if abs(scalar(b`c')/scalar(se`c'))>1.96	{
			local ast`c'="**"
		}
		else if abs(scalar(b`c')/scalar(se`c'))>1.645	{
			local ast`c'="*"
		}
		else	{
			local ast`c'=""
		}
		local b`c': display %6.0gc =scalar(b`c')
		local se`c': display %6.0gc =scalar(se`c')
		local N`c': display %9.0gc =round(e(N),10)
		*local N`c': display %9.0gc =e(N)
	}
	
	file open myfile using "`resultspath'tableA7_`var'_wt.tex", write append
	file write myfile ///
	 "\multicolumn{2}{c}{\emph{Only Respondents with Less-Educated Parents}} \\" _n ///
	 "`b1'`ast1' & `b2'`ast2' \\ " _n ///
	 "(`se1')    & (`se2')    \\ " _n ///
	 "`N1'       & `N2'       \\ " _n ///
	 "\addlinespace" _n
	file close myfile

	file open myfile using "`resultspath'tableA7_`var'_wt.tex", write append
	file write myfile ///
	 "\bottomrule" _n ///
	 "\end{tabular}" _n ///
	 "\begin{tablenotes}[para,flushleft]" _n ///
	 "NOTES: ***p$<$0.01 **p$<$0.05 *p$<$0.1.  Data from NELS:88 and ELS:2002.  Dependent variable in all specifications is an indicator for ``var'_title'.  Table only shows the coefficient on NTR tariff gap at the CZ level (zero for all NELS:88 respondents).  All models also include a constant, indicators for being in the ELS:2002 (rather than NELS:88), sex, race/ethnicity, and interactions between cohort membership (ELS:2002 or NELS:88) and Census division (9 categories).  Parents' education is maximum of father and mother, and controls are indicators for high school graduate, some college, BA, and post-BA degree.  Less-educated parents are those with no college education.  Standard errors clustered at 10th grade CZ level.  All specifications weighted by panel weights." _n ///
	 "\end{tablenotes}" _n ///
	 "\end{threeparttable}" _n ///
	 "\end{table}"
	file close myfile

}



log close
exit

