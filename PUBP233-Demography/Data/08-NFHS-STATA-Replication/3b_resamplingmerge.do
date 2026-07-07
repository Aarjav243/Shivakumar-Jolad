/*                                                         

notes:
- this do-file does the following:
  . generates a dataset with resamples merged to personyears
  . generates a dataset with resamples merged to person
*/

* USER WILL NEED TO INPUT YOUR OWN PATH HERE
clear
cd "D:\Projects\AHS-Coffey\Users\Life expectancy project\working\public"


* MERGE PERSONYEAR WITH RESAMPLING ---------------------------------------------

use personyear.dta
keep if round==1
keep group female agegroup rural wealthqt wealthdc sf psuodsplit land hhlit ///
	wt ///
	state district psu cluster ///
	py death
fcollapse (sum) py death (mean) wt state, by(cluster group female agegroup rural wealthdc wealthqt sf psuodsplit land hhlit) fast

*save into 9 different files 

	foreach state in 5 8 9 10 18 20 21 22 23 {
	preserve

	keep if state == `state'
	
	compress 
	save personyear_`state'.dta, replace

	
	restore 

	}

*split resampling file 

	use resampling.dta, clear
	
	foreach state in 5 8 9 10 18 20 21 22 23 {
	preserve

	keep if state == `state'
	
	save resampling_`state'.dta, replace 


	restore 

	}
	
	
*merge by state 
	
	foreach state in 5 8 9 10 18 20 21 22 23 {

	use personyear_`state'.dta, clear 
	
	drop state
	
	join, from(resampling_`state') by(cluster)
	
	drop _merge 
	
	save personyearrs_`state'.dta, replace 
	
	}
	
	
*append the statewise files 

	use personyearrs_5.dta, clear
	
	foreach state in 8 9 10 18 20 21 22 23 {
	
	append using personyearrs_`state'.dta
	
	}
	
*save 
	
	save personyearrs.dta, replace 
	
	
	
*-------------------------------------------------------------------------------

* MERGE PERSON WITH RESAMPLING -------------------------------------------------

use person.dta
keep if round==1
keep group female agegroup rural wealthdc wealthqt sf psuodsplit land hhlit ///
	wt ///
	state district psu cluster
fcollapse (sum) wt, by(cluster group female agegroup rural wealthdc wealthqt sf psuodsplit land hhlit) fast
compress
join, from(resampling) by(cluster)

save personrs.dta, replace
*-------------------------------------------------------------------------------
