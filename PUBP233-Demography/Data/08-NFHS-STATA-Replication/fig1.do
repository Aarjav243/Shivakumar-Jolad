
/*                                                         
notes:
- this do-file does the following:
  . makes figure for mortality rates
  . NFHS mortality rates have been estimated in Gupta, Sudhsarshan (2020) "Large and persistent life expectancy disparities among India's social groups"
  . SRS data from 2007-2009, available here: https://censusindia.gov.in/vital_statistics/Appendix_SRS_Based_Life_Table.html
		- SRS data have been pooled across states by the authors, taking weighted average across each state, where average is based on the states' Census2011 populations
*/


* USER WILL NEED TO INPUT YOUR OWN PATH HERE
clear
cd "D:\Projects\AHS-Coffey\Users\Life expectancy project\working\public"

***********************bring in and clean data

*merge nmx for NFHS, SRS, and AHS USER WILL NEED TO INPUT YOUR OWN PATH HERE
use "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\data\srsave_nmx_pooled_nouk_bysexage.dta", clear

rename frac_nmx SRS
rename age agegroup

merge 1:1 female agegroup using lifetable_nouk_se.dta

rename nmx AHS
rename se_nmx se_AHS
drop nax n nqx npx l ndx nLx Tx ex se_ex n_rs _merge

*USER WILL NEED TO INPUT YOUR OWN PATH HERE
merge 1:1 female agegroup using "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\data\nfhs4_lifetable_nouk_se.dta"

rename nmx NFHS
rename se_nmx se_NFHS
*rename nmx_lci nfhs_nmx_lci
*rename nmx_uci nfhs_nmx_uci

drop deaths person_years nqx lx ex se_ex _merge ex_lci ex_uci nmx_lci nmx_uci
*drop deaths person_years nqx lx ex se_ex _merge ex_lci ex_uci 

*labels etc 
gen male = female == 0 
lab def male 0 "a. female" 1 "b. male"
lab val male male 

*generate nmx per 1000
gen ahs_1000 = AHS*1000
gen ahs_nmx_uci = ahs_1000 + (2*se_AHS*1000)
gen ahs_nmx_lci = ahs_1000 - (2*se_AHS*1000)
gen nfhs_1000 = NFHS*1000
gen nfhs_nmx_uci2 = nfhs_1000 + (2*se_NFHS*1000)
gen nfhs_nmx_lci2 = nfhs_1000 - (2*se_NFHS*1000)
gen srs_1000 = SRS*1000

*******************graph

*with CIs
graph twoway ///
		(connected ahs_1000 agegroup, msymbol(smcircle_hollow) mcolor(navy)) ///
		(connected srs_1000 agegroup,  msymbol(smtriangle_hollow) lcolor(maroon%50) mcolor(maroon%50)) ///
		(connected nfhs_1000 agegroup,  msymbol(smsquare_hollow) lcolor(dkgreen%50) mcolor(dkgreen%50)) ///
		(rarea ahs_nmx_uci ahs_nmx_lci agegroup, color(navy%10)) ///
		(rarea nfhs_nmx_uci nfhs_nmx_lci agegroup, color(dkgreen%10)), ///
		by(male, col(1) graphregion(lcolor(white) fcolor(white)) note("")) ///
		xlabel(0(10)80) yscale(log r(.2 2 20 200)) ylabel(.2 2 20 200) ///
		xsize(2) ysize(3) ///
		subtitle(, size(medium) fcolor(white) lcolor(white)) ///
		legend(order(1 "AHS (2007-09)" 2 "SRS (2007-09)" 3 "NFHS (2012-16)") region(color(none)) row(1) size(small) stack) ///
		xtitle("abridged life table age-groups (years)") ///
		ytitle("age-specific mortality rates ({sub:n}m{sub:x}) per 1000")

graph export "ahs_srsave_nfhs_nmx_pooled_nouk_with_ci.pdf", replace

	
