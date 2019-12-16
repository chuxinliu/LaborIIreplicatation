//================================== Figures A1 and A2: Histogram and Map ============================|
clear*
set more off, perm
version 11.0
global datadir "F:\GitHub\LaborIIreplicatation"
global outdir  "F:\GitHub\LaborIIreplicatation\Result"
/*
ssc install spmap
ssc install shp2dta
/*https://www.sciencebase.gov/catalog/item/581d051be4b08da350d523b2*/
ssc install maptile
maptile_install using "http://files.michaelstepner.com/geo_cz1990.zip"
maptile_install using "http://files.michaelstepner.com/geo_state.zip"	
*/
////////////////////////////////////////////////////////////////////////////////////////////////////|
use "$datadir\REStat package\data\NTR GAP.dta", clear

********************************************************************************
*Figure A1 -- NTR Gap Histogram ************************************************
********************************************************************************
hist ntr_gap, graphregion(color(white)) frac xtitle(NTR GAP)
graph save Graph "$outdir\Figure_A1.gph", replace
graph export "$outdir\Figure_A1.png", replace
graph export "$outdir\Figure_A1.pdf", replace

********************************************************************************
*Figure A2 -- NTR Gap Map ******************************************************
********************************************************************************
rename czone cz
merge 1:1 cz using "$datadir\REStat package\data\cz1990_database.dta", keep(3)
*Drop Hawaii
drop if cz == 35600
spmap ntr_gap using "$datadir\REStat package\data\cz1990_coords.dta", id(id) fcolor(Greens2) title((d) NTR Gap)  title(, size(medium))
graph save Graph "$outdir\Figure_A2.gph", replace
graph export "$outdir\Figure_A2.png", replace
graph export "$outdir\Figure_A2.pdf", replace


********************************************************************************
*Draft Figure 2(B) -- Log Population Change Map ********************************
********************************************************************************
use "$datadir\Data\working_data\censuspop7010.dta", clear
rename cz90 czone

gen lcz_pop=ln(cz_pop)
merge 1:1 czone year using "$datadir\Data\working_data\REScensus_totpop.dta"
tab _merge,m 
* drop 1970, drop Alaska and Hawaii
drop if _merge!=3
drop _merge

keep czone lcz_pop year
gen l80 = lcz_pop if year == 1980
gen l90 = lcz_pop if year == 1990
gen l00 = lcz_pop if year == 2000
gen l10 = lcz_pop if year == 2010

by czone, sort : egen lp80 = mean(l80)
by czone, sort : egen lp90 = mean(l90)
by czone, sort : egen lp00 = mean(l00)
by czone, sort : egen lp10 = mean(l10)

drop l80 l90 l00 l10

gen trend = lp00-lp80
gen change = lp10- lp00
gen dd=(lp10-lp00)-(lp00-lp90)

drop if year != 1980
drop year

rename czone cz
merge 1:1 cz using "$datadir\REStat package\data\cz1990_database.dta", keep(3)
rename cz czone

spmap trend using "$datadir\REStat package\data\cz1990_coords.dta", id(id) fcolor(Blues2) title((a) Pre China Shock (1980-2000))  title(, size(medium))
graph save Graph "$outdir\Figure_2B1.gph", replace
graph export "$outdir\Figure_2B1.png", replace
graph export "$outdir\Figure_2B1.pdf", replace

spmap change using "$datadir\REStat package\data\cz1990_coords.dta", id(id) fcolor(Blues2) title((b) Post China Shock (2000-2010))  title(, size(medium))
graph save Graph "$outdir\Figure_2B2.gph", replace
graph export "$outdir\Figure_2B2.png", replace
graph export "$outdir\Figure_2B2.pdf", replace

spmap dd using "$datadir\REStat package\data\cz1990_coords.dta", id(id) fcolor(Greens2) title((c) Difference of Log Population Change (00s minus 90s))  title(, size(small))
graph save Graph "$outdir\Figure_2B3.gph", replace

graph combine "$outdir\Figure_2B1.gph" "$outdir\Figure_2B2.gph" "$outdir\Figure_2B3.gph" "$outdir\Figure_A2.gph"
graph save Graph "$outdir\popNTR.gph", replace
graph export "$outdir\popNTR.png", replace
graph export "$outdir\popNTR.pdf", replace









	
