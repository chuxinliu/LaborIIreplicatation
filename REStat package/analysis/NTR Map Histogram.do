//================================== Figures A1 and A2: Histogram and Map ============================|
clear*
set more off, perm
version 11.0
global datadir "F:\GitHub\LaborIIreplicatation\REStat package\data"
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
use "$datadir\NTR GAP.dta", clear

********************************************************************************
*Figure A1 -- NTR Gap Histogram ************************************************
********************************************************************************
hist ntr_gap, graphregion(color(white)) frac xtitle(NTR GAP)
graph export "$outdir\Figure_A1.pdf", replace

********************************************************************************
*Figure A2 -- NTR Gap Map ******************************************************
********************************************************************************
rename czone cz
merge 1:1 cz using "$datadir\cz1990_database.dta", keep(3)
*Drop Hawaii
drop if cz == 35600
spmap ntr_gap using "$datadir\cz1990_coords.dta", id(id) fcolor(Blues2)
graph export "$outdir\Figure_A2.pdf", replace
	
	
	
