/*                                                         
notes:
- this do-file does the following:
  . this dofile is used for the resampling (bootstrap) procedure
  . generates a dataset that lists, for each cluster, how many times the cluster appears in a particular resample (of 1000 resamples)
*/

* USER WILL NEED TO INPUT YOUR OWN PATH HERE
clear
cd "D:\Projects\AHS-Coffey\Users\Life expectancy project\working\public"


clear all
set mem 5500m

use person.dta, clear

*keep only first round of data
keep if round==1

*keep only one observation per household
generate order = _n
by hhld_id (order), sort: generate y = _n == 1
tab y
keep if y==1

*keep only variables needed for resampling
keep state district newstratum cluster hhld_id


*generate resampling dataset
set seed 23456

gen weight=.

forvalues i = 1/1000 {
	qui gen w`i' = .
	bsample, cluster(cluster) strata(newstratum district state) weight(w`i')
}

drop hhld_id weight
duplicates drop
duplicates drop state district cluster, force
sort cluster

save resampling.dta, replace
