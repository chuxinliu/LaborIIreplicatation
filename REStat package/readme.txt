readme for replication files
Import Competition and Internal Migration
Andrew Greenland, John Lopresti, and Peter McHenry
March 2018

The nearby files are intended to facilitate the replication of results from 
the paper.  Stata programs (.do files) are in the "analysis" folder.  Those 
programs use data from the "data" folder and generate table and figure files
 that we collect in the "results" folder. 

Our paper uses four main data sets: Census, IPUMS, IRS, and NELS:88/ELS:2002.
The Census, IPUMS, and IRS data are publicly accessible, and the "data" folder
includes cleaned versions of them.  Our analysis uses geocoded respondent 
locations in the NELS:88 and ELS:2002.  Use of those data is restricted, and 
we are not allowed to post them publicly.  We post our Stata programs for 
NELS:88 and ELS:2002 analysis but not the source data.  The restricted-access 
versions of the NELS:88 and ELS:2002 can be used with a license from the U.S. 
Department of Education.  Researchers with institutional affiliations can apply 
for a license.  Contact information is:

	IES Data Security Office
	Department of Education/IES/NCES
	550 12th Street, SW, Room 4060
	Washington, DC 20202
	202-245-7674
	IESData.Security@ed.gov


Software and Operating System
	Programs in the NELS_ELS directory ran on Stata 12 in the Windows Vista 
		operating system (yes, Windows Vista in 2018; it's a non-networked 
		desktop computer with a long service record)
	"IPUMS Analysis.do" ran on Stata 15 in the Windows 7 64 bit operating system 	"NTR Map Histogram.do", “Census Analysis.do”, “IRS Analysis.do”, and 
		“ADH Analysis.do” ran on Stata MP 14.2 in the Mac OS X 10.11.6


Contents of the "data" folder

	"Census Population Data 1970-2010.dta"		Census populations at the CZ level

	"IPUMS_CZ_1564_7010_withGQ.dta"		IPUMS populations at the CZ level	"CZ_IRS_Migration.dta"
		IRS populations at the CZ level		

	[NOT THE NELS:88/ELS:2002, which are restricted]
	
	"IPUMS_CZ_1664_7010_ADH.dta"		IPUMS populations at the CZ level (to match Autor et al., 2013 sampling methods)

	"1980_2010_Intercensal_ADH.dta"		Intercensal population estimates used in Table 7

	"NTR Gap.dta"		NTR gap measures at the CZ level

	"1990 CZ Controls.dta"		CZ level controls used in the paper

	"ADH Import Competition 1990 2010.dta"		Autor et al. (2013) import competition measure for the 1990-2010 period

	"workfile_china.dta"
		Autor et al. (2013) data set

	“cz1990_database.dta”, “cz1990_coords.dta”
		1990 CZ geographies used in creation of NTR Gap map.  Provided by 
			https://michaelstepner.com/maptile/geographies/


Contents of the "analysis" folder

	"NTR Map Histogram.do"
		Imports "NTR Gap.dta" and generates figures that show the distribution of NTR Gap.
		Output: Figures A1 and A2


 	"Census Analysis.do"
		Imports "Census Population Data 1970-2010.dta" and merges "NTR Gap.dta" and "1990 CZ Controls.dta"
		Generates main and auxiliary results with Census counts data
		Output:
			Tables 1, A1, A2, A4, and A5 (Table A5 is a version of Table 1 with more controls shown)						Figures A3 and A6

	"NELS_ELS/nels_els_regressions.do"
		(auxiliary files addblankrow.do and addrow.do help make tables)
		Imports NELS:88 and ELS:2002 data (which are restricted and not posted) 
		Generates micro-data results on migration
		Output:
			Tables 4, 5, A6, A7, A8, A9, and A10  (Table A7 is a version of Table 4 with more controls shown)


	"NELS_ELS/nels_els_destinationlogit.do"
		Imports NELS:88 and ELS:2002 data (which are restricted and not posted)
		Estimates a multinomial logit model of destination choice conditional on NTR gap and other local traits
		Output: Table A11


	"IPUMS Analysis.do"
		Imports "IPUMS_CZ_1564_7010_withGQ.dta" and merges "NTR Gap.dta" and "1990 CZ Controls.dta"
		Generates and merges CZ population shares from "Census Population Data 1970-2010.dta"
		Generates results with IPUMS data
		Output:
			Tables 2 and 3
	
	"IRS analysis.do"
		Imports "CZ_IRS_Migration.dta" and merges "NTR Gap.dta" and "1990 CZ Controls.dta"
		Generates and merges CZ demographic controls from "Census Population Data 1970-2010.dta"
		Estimates distributed lag models of population changes
		Output:
			Figures 1 and A5
			Table A12

	"ADH Analysis.do"
		Imports "IPUMS_CZ_1664_7010_ADH.dta" and merges "workfile_china.dta" controls from Autor et al. (2013)
		Estimates the relationship between population changes and imports per worker
		Imports "1980_2010_Intercensal_ADH.dta" and merges "workfile_china.dta" controls from Autor et al. (2013)
		Estimates the relationship between population changes and imports per worker
		Output:
			Table 6
			Table A3
			Figure A4		


Contents of the "results" folder
	Figure_1.pdf: 
		Figure 1: Unconstrained Distributed Lag Model of NTR Gap and Log Population	Figure_A1.pdf: 
		Figure A1: Distribution of CZ NTR Gaps	Figure_A2.pdf: 
		Figure A2: Geographic Distribution of CZ NTR Gap	Figure_A3.pdf: 
		Figure A3: Distributions of CZ Population Changes by PNTR Exposure	Figure_A4.pdf: 
		Figure A4: Distributions of CZ Population Changes by Imports Per Worker Exposure	Figure_A5.pdf: 
		Figure A5: Constrained Distributed Lag Model of NTR Gap and Log Population	Figure_A6.pdf: 
		Figure A6: CZ Housing Price Break Estimates	Table_1.tex: 
		Table 1: Import Competition and 10-Year Changes in Log CZ Population, Census
		and Table A5: Import Competition and 10-Year Changes in Log CZ Population, Census (Main Results Showing Controls)	Table_2.tex: 
		Table 2: Import Competition and 10-Year Changes in Log CZ Population by Demographic Group, IPUMS	Table_3.tex: 
		Table 3: Import Competition and 10-Year Changes in Log CZ Population by Age and Education, IPUMS	Table_6_Row1.tex: 
		part of Table 6: Import Competition and Changes in Log CZ Population, Autor et al. (2013) Method	Table_6_Row2.tex: 
		part of Table 6: Import Competition and Changes in Log CZ Population, Autor et al. (2013) Method	Table_6_Row3.tex: 
		part of Table 6: Import Competition and Changes in Log CZ Population, Autor et al. (2013) Method	Table_6_Row4.tex: 
		part of Table 6: Import Competition and Changes in Log CZ Population, Autor et al. (2013) Method	Table_6_Row5.tex: 
		part of Table 6: Import Competition and Changes in Log CZ Population, Autor et al. (2013) Method	Table_6_Row6.tex: 
		part of Table 6: Import Competition and Changes in Log CZ Population, Autor et al. (2013) Method	Table_A1.tex: 
		Table A1: Import Competition (Following Kovak (2013)) and 10-Year Changes in Log CZ Population, Census	Table_A2.tex: 
		Table A2: Pre-Trends, NTR Gap	Table_A3.tex: 
		Table A3: Pre-Trends, ADH Approach	Table_A4.tex: 
		Table A4: Log CZ Population Changes, Fixed Pre-Trends	Table_A12.tex: 
		Table A12: Import Competition and 10-Year Changes in Log CZ Population, IRS

























