//================================== Figures A1 and A2: Histogram and Map ============================|
clear*
set more off, perm
version 11.0
global datadir "/Users/johnlopresti/Dropbox/Trade shocks and migration/Replication data and programs/data"
global outdir  "/Users/johnlopresti/Dropbox/Trade shocks and migration/Replication data and programs/results"
cd "$datadir"

*ssc install spmap
*ssc install shp2dta
/*https://www.sciencebase.gov/catalog/item/581d051be4b08da350d523b2*/
*ssc install maptile
*maptile_install using "http://files.michaelstepner.com/geo_cz1990.zip"
*maptile_install using "http://files.michaelstepner.com/geo_state.zip"	
////////////////////////////////////////////////////////////////////////////////////////////////////|


use "NTR GAP.dta", clear
	rename cz cz
merge 1:1 cz using "cz1990_database.dta", keep(3)
*Drop Hawaii
drop if cz == 35600

cd "$outdir"
********************************************************************************
*Figure A1 -- NTR Gap Histogram ************************************************
********************************************************************************
hist ntr_gap, graphregion(color(white)) frac xtitle(NTR GAP)
graph export "Figure_A1.pdf", replace

********************************************************************************
*Figure A2 -- NTR Gap Map ******************************************************
********************************************************************************
cd "$datadir"
spmap ntr_gap using cz1990_coords, id(id) fcolor(Blues)
cd "$outdir"
graph export "Figure_A2.pdf", replace
	
	
	
