clear all
set more off
set matsize 8000
set maxvar 10000

local home "\HOME"

cd "`home'"

local logpath "`home'Log files\"

capture log close
log using "`logpath'nels_els_destinationlogit_log.txt", text replace

local resultspath "`home'Results\"

* The local intdatapath is where the cleaned NELS:88 and ELS:2002 data file is. *
local intdatapath "`home'Intermediate data\"


/*************************************************
Destination choice logits using NELS:88 and ELS:2002 (Table A11)
	for "Import Competition and Internal Migration"
	by Andy Greenland, John Lopresti, and Peter McHenry

History: 
	2/19/2018: Formatted for posted replication files

This program estimates destination choice logit specifications using NELS:88 and 
ELS:2002 data.  The data include geocoded respondent locations and use is 
restricted.  The restricted-access versions of the data sets can be used
with a license from the U.S. Department of Education.  Researchers with 
institutional affiliations can apply for a license.

*************************************************/


** Locals for control variable inclusion **
local czsize "cz_small_town_a26 cz_small_urb_a26 cz_large_urb_a26 cz_small_metro_a26 cz_med_metro_a26"
local czdivision "cz_reg_midatl_a26 cz_reg_encen_a26 cz_reg_wncen_a26 cz_reg_satl_a26 cz_reg_escen_a26 cz_reg_wscen_a26 cz_reg_mount_a26 cz_reg_pacif_a26"


use "`intdatapath'nels_els_cleandata_logit"

** Keep only the ELS:2002 **
keep if els2002==1

** Keep a subset of variables **
/* Notes on variable meanings
	id: respondent identifier
	g10_cz: Commuting Zone (number code) of residence at grade 10
	a26_cz: Commuting Zone (number code) of residence at age 26 
	ntr_gap_g10: NTR Gap of 10th-grade commuting zone of residence
*/
keep id g10_cz a26_cz ntr_gap_g10 cz_latitude_g10 cz_longitude_g10

** NOTE: This list of CZs omits Alaska and Hawaii areas, 34101(1)34115 and 34701(1)34703 35600 **
#delimit;
foreach cz of numlist 100 200 301 302 401 402 500 601 602 700(100)900 1001 1002 1100 1201(1)1204 
	1301 1302 1400(100)1600 1701 1702 1800(100)2900 3001(1)3003 3101 3102 3201(1)3203
	3300(100)3800 3901 3902 4001(1)4004 4101(1)4103 4200 4301 4302 4401 4402 4501 4502 
	4601 4602 4701 4702 4800 4901(1)4903 5000 5100 5201 5202 5300 5401 5402 5500(100)6200 
	6301 6302 6401 6402 6501 6502 6600(100)8100 8201 8202 8300 8401 8402 8501(1)8503 
	8601 8602 8701 8702 8800 8900 9001(1)9003 9100 9200 9301 9302 9400(100)9600 9701 9702 
	9800(100)10000 10101 10102 10200 10301 10302 10400 10501 10502 10600 10700 10801 10802 
	10900 11001 11002 11101 11102 11201(1)11203 11301(1)11304 11401(1)11403 11500(100)11900
	12001 12002 12100 12200 12301 12302 12401 12402 12501 12502 12600 12701 12702 12800
	12901(1)12903 13000 13101(1)13103 13200(100)13400 13501 13502 13600(100)14700 14801 14802
	14900(100)16600 16701(1)16703 16801 16802 16901 16902 17000(100)17400 17501 17502
	17600(100)18100 18201 18202 18300(100)19800 19901(1)19903 20001(1)20003 20100 20200 
	20301 20302 20401(1)20403 20500(100)20800 20901 20902 21001(1)21004 21101 21102 21201 
	21202 21301 21302 21400 21501 21502 21600 21701 21702 21801 21802 21900 22001 22002
	22100(100)22500 22601 22602 22700(100)23200 23301 23302 23400(100)23700 23801 23802
	23900(100)24600 24701 24702 24801 24802 24900 25000 25101(1)25105 25200 25300 25401 25402 
	25500 25601 25602 25701 25702 25800 25900 26001(1)26004 26101(1)26107 26201(1)26204 
	26301(1)26305 26401(1)26412 26501(1)26504 26601(1)26605 26701(1)26704 26801(1)26804 
	26901 26902 27001(1)27012 27101 27102 27201 27202 27301 27302 27401 27402 27501(1)27504
	27601(1)27605 27701(1)27704 27801 27802 27901(1)27903 28001 28002 28101 28102 28201 28202 
	28301(1)28306 28401 28402 28501(1)28504 28601(1)28609 28701(1)28704 28800 28900 
	29001(1)29008 29101(1)29104 29201(1)29204 29301(1)29303 29401(1)29403 29501(1)29506 
	29601 29602 29700 29800 29901 29902 30000(100)30300 30401(1)30403 30501 30502 30601(1)30605 
	30701 30702 30801 30802 30901(1)30908 31001(1)31007 31101(1)31103 31201 31202 31301(1)31304
	31401(1)31404 31501(1)31503 31600(100)32100 32201 32202 32301(1)32306 32401(1)32403
	32501(1)32503 32601(1)32604 32701 32702 32801 32802 32900(100)33500 33601(1)33603 33700 
	33801(1)33803 33901 33902 34001 34002 34201(1)34204 34301(1)34309 
	34401(1)34404 34501(1)34504 34601(1)34604 34801(1)34805 34901 34902 
	35001 35002 35100 35201 35202 35300 35401 35402 35500 35701 35702 35801(1)35803
	35901(1)35905 36000(100)36200 36301(1)36303 36401(1)36404 36501(1)36503 36600(100)36800 
	36901 36902 37000(100)37500 37601(1)37604 37700 37800 37901(1)37903 38000(100)38300 
	38401 38402 38501 38502 38601 38602 38700 38801 38802 38901 38902 39000 39100 39201(1)39205 
	39301(1)39303 39400	{;
		gen byte a26_cz_`cz'=0;
		replace a26_cz_`cz'=1 if a26_cz==`cz';
};
#delimit cr

drop a26_cz

reshape long a26_cz_, i(id) j(a26_cz)
gen home=(a26_cz==g10_cz)

/* Merge Normal Trade Relations tariff gaps.  This merge is to potential destination CZs. */
rename a26_cz czone
merge m:1 czone using "`intdatapath'NTR Gap", keep(match master)
drop _merge
rename czone a26_cz

** Interaction with HOME **
gen homeXntr_gap=home*ntr_gap

** Merge CZ controls **
rename a26_cz cz90
merge m:1 cz90 using "`intdatapath'CZchars", keep(match master) keepusing(name classnum classname type region south midwest northeast west latitude longitude)
tab cz90 if _merge==1
drop _merge
rename cz90 a26_cz
foreach var of varlist name classnum classname type region south midwest northeast west latitude longitude	{
	rename `var' cz_`var'_a26
}

** Controls for CZ size **
gen byte cz_small_town_a26=(cz_classnum_a26==1)
gen byte cz_small_urb_a26=(cz_classnum_a26==2)
gen byte cz_large_urb_a26=(cz_classnum_a26==3)
gen byte cz_small_metro_a26=(cz_classnum_a26==4)
gen byte cz_med_metro_a26=(cz_classnum_a26==5)

** Merge CZ Census division controls **
rename a26_cz czone
merge m:1 czone using "`intdatapath'1990 CZ Controls", keep(match master)
tab czone if _merge==1
drop _merge
rename czone a26_cz

foreach var of varlist reg_midatl reg_encen reg_wncen reg_satl reg_escen reg_wscen reg_mount reg_pacif	{
	rename `var' cz_`var'_a26
}

/** Calculate distances between destination CZ options and origin CZ.  The latitudes and 
	longitudes of CZs I have are rough measures, midpoints between max and min latitudes
	and longitudes of zip codes within CZs. **/
/** I got this distance formula at 
   		http://www.mathforum.com/library/drmath/view/51711.html	
   	It gets results that are the same as those calculated at 
   		http://www.movable-type.co.uk/scripts/latlong.html 
   	The distance measure is in kilometers. **/
gen by_latrad=cz_latitude_g10*_pi/180
gen by_longrad=cz_longitude_g10*_pi/180
gen dest_latrad=cz_latitude_a26*_pi/180
gen dest_longrad=cz_longitude_a26*_pi/180
scalar earthrad=6371
gen distance=acos(cos(by_latrad)*cos(by_longrad)*cos(dest_latrad)*cos(dest_longrad) ///
	+ cos(by_latrad)*sin(by_longrad)*cos(dest_latrad)*sin(dest_longrad) ///
	+ sin(by_latrad)*sin(dest_latrad))*earthrad

drop by_latrad by_longrad dest_latrad dest_longrad
* There is some rounding error that makes very small numbers for comparisons between the same CZ. *
replace distance=0 if a26_cz==g10_cz
* Make a version of the distance variable in 1,000s of kilometers *
gen distance_1000=distance/1000
gen distance_1000sq=distance_1000^2
drop distance

** Label variables for table output **
label var home "Home"
label var ntr_gap "NTR gap"
label var distance_1000 "Distance from home (1,000 km)"
label var distance_1000sq "Distance squared"
label var cz_small_town_a26 "Small town"
label var cz_small_urb_a26 "Small urban (non-metro)"
label var cz_large_urb_a26 "Larger urban (non-metro)"
label var cz_small_metro_a26 "Small metro"
label var cz_med_metro_a26 "Medium metro"
label var cz_reg_midatl_a26 "Middle Atlantic"
label var cz_reg_encen_a26 "East North Central"
label var cz_reg_wncen_a26 "West North Central"
label var cz_reg_satl_a26 "South Atlantic"
label var cz_reg_escen_a26 "East South Central"
label var cz_reg_wscen_a26 "West South Central"
label var cz_reg_mount_a26 "Mountain"
label var cz_reg_pacif_a26 "Pacific"

** Estimate the location choice logit model **
clogit a26_cz_ home ntr_gap distance_1000 distance_1000sq `czsize' `czdivision', group(id) vce(cluster g10_cz)
outreg2 using "`resultspath'dest_logit", bfmt(gc) label tex(fragment) ctitle(ELS:2002) addnote(\parbox{3in}{Conditional logit models of location choice--age 26 destination.  Standard errors clustered at origin--10th grade--CZ level.}) replace



/** Estimate the relationship between 2001-era trade shock and destination choices
	by 2000 of NELS:88 cohort (like a placebo test). **/
use "`intdatapath'nels_els_cleandata_logit", clear

** Keep only the ELS:2002 **
keep if nels88==1

** Keep a subset of variables **
keep id g10_cz a26_cz cz_latitude_g10 cz_longitude_g10

** NOTE: This list of CZs omits Alaska and Hawaii areas, 34101(1)34115 and 34701(1)34703 35600 **
#delimit;
foreach cz of numlist 100 200 301 302 401 402 500 601 602 700(100)900 1001 1002 1100 1201(1)1204 
	1301 1302 1400(100)1600 1701 1702 1800(100)2900 3001(1)3003 3101 3102 3201(1)3203
	3300(100)3800 3901 3902 4001(1)4004 4101(1)4103 4200 4301 4302 4401 4402 4501 4502 
	4601 4602 4701 4702 4800 4901(1)4903 5000 5100 5201 5202 5300 5401 5402 5500(100)6200 
	6301 6302 6401 6402 6501 6502 6600(100)8100 8201 8202 8300 8401 8402 8501(1)8503 
	8601 8602 8701 8702 8800 8900 9001(1)9003 9100 9200 9301 9302 9400(100)9600 9701 9702 
	9800(100)10000 10101 10102 10200 10301 10302 10400 10501 10502 10600 10700 10801 10802 
	10900 11001 11002 11101 11102 11201(1)11203 11301(1)11304 11401(1)11403 11500(100)11900
	12001 12002 12100 12200 12301 12302 12401 12402 12501 12502 12600 12701 12702 12800
	12901(1)12903 13000 13101(1)13103 13200(100)13400 13501 13502 13600(100)14700 14801 14802
	14900(100)16600 16701(1)16703 16801 16802 16901 16902 17000(100)17400 17501 17502
	17600(100)18100 18201 18202 18300(100)19800 19901(1)19903 20001(1)20003 20100 20200 
	20301 20302 20401(1)20403 20500(100)20800 20901 20902 21001(1)21004 21101 21102 21201 
	21202 21301 21302 21400 21501 21502 21600 21701 21702 21801 21802 21900 22001 22002
	22100(100)22500 22601 22602 22700(100)23200 23301 23302 23400(100)23700 23801 23802
	23900(100)24600 24701 24702 24801 24802 24900 25000 25101(1)25105 25200 25300 25401 25402 
	25500 25601 25602 25701 25702 25800 25900 26001(1)26004 26101(1)26107 26201(1)26204 
	26301(1)26305 26401(1)26412 26501(1)26504 26601(1)26605 26701(1)26704 26801(1)26804 
	26901 26902 27001(1)27012 27101 27102 27201 27202 27301 27302 27401 27402 27501(1)27504
	27601(1)27605 27701(1)27704 27801 27802 27901(1)27903 28001 28002 28101 28102 28201 28202 
	28301(1)28306 28401 28402 28501(1)28504 28601(1)28609 28701(1)28704 28800 28900 
	29001(1)29008 29101(1)29104 29201(1)29204 29301(1)29303 29401(1)29403 29501(1)29506 
	29601 29602 29700 29800 29901 29902 30000(100)30300 30401(1)30403 30501 30502 30601(1)30605 
	30701 30702 30801 30802 30901(1)30908 31001(1)31007 31101(1)31103 31201 31202 31301(1)31304
	31401(1)31404 31501(1)31503 31600(100)32100 32201 32202 32301(1)32306 32401(1)32403
	32501(1)32503 32601(1)32604 32701 32702 32801 32802 32900(100)33500 33601(1)33603 33700 
	33801(1)33803 33901 33902 34001 34002 34201(1)34204 34301(1)34309 
	34401(1)34404 34501(1)34504 34601(1)34604 34801(1)34805 34901 34902 
	35001 35002 35100 35201 35202 35300 35401 35402 35500 35701 35702 35801(1)35803
	35901(1)35905 36000(100)36200 36301(1)36303 36401(1)36404 36501(1)36503 36600(100)36800 
	36901 36902 37000(100)37500 37601(1)37604 37700 37800 37901(1)37903 38000(100)38300 
	38401 38402 38501 38502 38601 38602 38700 38801 38802 38901 38902 39000 39100 39201(1)39205 
	39301(1)39303 39400	{;
		gen byte a26_cz_`cz'=0;
		replace a26_cz_`cz'=1 if a26_cz==`cz';
};
#delimit cr

drop a26_cz

reshape long a26_cz_, i(id) j(a26_cz)
gen home=(a26_cz==g10_cz)

/* Merge Normal Trade Relations tariff gaps.  This merge is to potential destination CZs. */
rename a26_cz czone
merge m:1 czone using "`intdatapath'NTR Gap", keep(match master)
drop _merge
rename czone a26_cz

** Interaction with HOME **
gen homeXntr_gap=home*ntr_gap

** Merge CZ controls **
rename a26_cz cz90
merge m:1 cz90 using "`intdatapath'CZchars", keep(match master) keepusing(name classnum classname type region south midwest northeast west latitude longitude)
tab cz90 if _merge==1
drop _merge
rename cz90 a26_cz
foreach var of varlist name classnum classname type region south midwest northeast west latitude longitude	{
	rename `var' cz_`var'_a26
}

** Controls for CZ size **
gen byte cz_small_town_a26=(cz_classnum_a26==1)
gen byte cz_small_urb_a26=(cz_classnum_a26==2)
gen byte cz_large_urb_a26=(cz_classnum_a26==3)
gen byte cz_small_metro_a26=(cz_classnum_a26==4)
gen byte cz_med_metro_a26=(cz_classnum_a26==5)

** Merge CZ Census division controls **
rename a26_cz czone
merge m:1 czone using "`intdatapath'1990 CZ Controls", keep(match master)
tab czone if _merge==1
drop _merge
rename czone a26_cz

foreach var of varlist reg_midatl reg_encen reg_wncen reg_satl reg_escen reg_wscen reg_mount reg_pacif	{
	rename `var' cz_`var'_a26
}

/** Calculate distances between destination CZ options and origin CZ.  The latitudes and 
	longitudes of CZs I have are rough measures, midpoints between max and min latitudes
	and longitudes of zip codes within CZs. **/
/** I got this distance formula at 
   		http://www.mathforum.com/library/drmath/view/51711.html	
   	It gets results that are the same as those calculated at 
   		http://www.movable-type.co.uk/scripts/latlong.html 
   	The distance measure is in kilometers. **/
gen by_latrad=cz_latitude_g10*_pi/180
gen by_longrad=cz_longitude_g10*_pi/180
gen dest_latrad=cz_latitude_a26*_pi/180
gen dest_longrad=cz_longitude_a26*_pi/180
scalar earthrad=6371
gen distance=acos(cos(by_latrad)*cos(by_longrad)*cos(dest_latrad)*cos(dest_longrad) ///
	+ cos(by_latrad)*sin(by_longrad)*cos(dest_latrad)*sin(dest_longrad) ///
	+ sin(by_latrad)*sin(dest_latrad))*earthrad

drop by_latrad by_longrad dest_latrad dest_longrad
* There is some rounding error that makes very small numbers for comparisons between the same CZ. *
replace distance=0 if a26_cz==g10_cz
* Make a version of the distance variable in 1,000s of kilometers *
gen distance_1000=distance/1000
gen distance_1000sq=distance_1000^2
drop distance

** Label variables for table output **
label var home "Home"
label var ntr_gap "NTR gap"
label var distance_1000 "Distance from home (1,000 km)"
label var distance_1000sq "Distance squared"
label var cz_small_town_a26 "Small town"
label var cz_small_urb_a26 "Small urban (non-metro)"
label var cz_large_urb_a26 "Larger urban (non-metro)"
label var cz_small_metro_a26 "Small metro"
label var cz_med_metro_a26 "Medium metro"
label var cz_reg_midatl_a26 "Middle Atlantic"
label var cz_reg_encen_a26 "East North Central"
label var cz_reg_wncen_a26 "West North Central"
label var cz_reg_satl_a26 "South Atlantic"
label var cz_reg_escen_a26 "East South Central"
label var cz_reg_wscen_a26 "West South Central"
label var cz_reg_mount_a26 "Mountain"
label var cz_reg_pacif_a26 "Pacific"

** Estimate the location choice logit model **
clogit a26_cz_ home ntr_gap distance_1000 distance_1000sq `czsize' `czdivision', group(id) vce(cluster g10_cz)
outreg2 using "`resultspath'dest_logit", bfmt(gc) label tex(fragment) ctitle(NELS:88) append



log close

