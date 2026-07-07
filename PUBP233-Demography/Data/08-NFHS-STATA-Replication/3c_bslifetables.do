/*                                                         

notes:
- this do-file does the following:
  . this dofile does bootstrap for the life table estimates in a loop
  . uses a nested dofile to do the repetitive tasks of life tables
  . appends bootstrap estimates in new datasets (one for each type of life table
- BEFORE RUNNING THIS DOFILE USER WILL NEED TO CREATE EMPTY DATASETS FOR
	- lifetable_state_bs
	- lifetable_group_bs
	- lifetable__bs
	- lifetable_state_group_bs
	- lifetable_wealth_bs
	- lifetable_wealth_group_bs
	- lifetable_hhlit_group_bs
	- lifetable_nouk_bs

*/

* USER WILL NEED TO INPUT YOUR OWN PATH HERE
clear
cd "D:\Projects\AHS-Coffey\Users\Life expectancy project\working\public"


* KEEP THE RESAMPLED DATA ONLY -------------------------------------------------
forvalues rs=1(1)1000 {
clear
use personyearrs.dta
keep cluster-district w`rs'
drop if w`rs'==0
gen newwt=wt*w`rs'
replace wt=newwt
drop newwt
*-------------------------------------------------------------------------------

* APPLY WEIGHTS, COLLAPSE, SAVE ------------------------------------------------

* weight the person-years
gen wpy=wt*py

* weight the deaths
gen wdeath=wt*death

* collapse and save smaller dataset
fcollapse (sum) wpy wdeath, by(state group wealthdc female agegroup) fast
rename wpy py
rename wdeath deaths

* merge with SRS nax values for each state-sex
sort state female agegroup
join, from(srs_nax) by(state female agegroup)
drop _merge

save collapsepersonyearrs.dta, replace
*-------------------------------------------------------------------------------

* STATE BY SEX LIFE TABLE ------------------------------------------------------

* define for life table dofile
clear
use collapsepersonyearrs.dta
global char "state female agegroup"

do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\2b_callinlifetable"

gen rs=`rs'
append using lifetable_state_bs
save lifetable_state_bs, replace
*-------------------------------------------------------------------------------

* GROUP BY SEX LIFE TABLE ------------------------------------------------------

* define for life table dofile
clear
use collapsepersonyearrs.dta
global char "group female agegroup"

do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\2b_callinlifetable"

gen rs=`rs'
append using lifetable_group_bs
save lifetable_group_bs, replace
*-------------------------------------------------------------------------------

* ALL STATES BY SEX LIFE TABLE -------------------------------------------------

* define for life table dofile
clear
use collapsepersonyearrs.dta
global char "female agegroup"

do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\2b_callinlifetable"

gen rs=`rs'
append using lifetable__bs
save lifetable__bs, replace
*-------------------------------------------------------------------------------

*STATES BY SOCIAL GROUP LIFE TABLE ---------------------------------------------

* define for life table dofile
clear
use collapsepersonyearrs.dta
global char "state group female agegroup"

do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\2b_callinlifetable"

gen rs=`rs'
append using lifetable_state_group_bs
save lifetable_state_group_bs, replace
*-------------------------------------------------------------------------------


* WEALTH DECILE BY SEX LIFE TABLE ----------------------------------------------
* define for life table dofile
clear
use collapsepersonyearrs.dta
global char "wealthdc female agegroup"

do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\2b_callinlifetable"

gen rs=`rs'
append using lifetable_wealth_bs
save lifetable_wealth_bs, replace
*-------------------------------------------------------------------------------

* WEALTH DECILE BY GROUP BY SEX LIFE TABLE -------------------------------------
* define for life table dofile
clear
use collapsepersonyearrs.dta
global char "group wealthdc female agegroup"

do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\2b_callinlifetable"

gen rs=`rs'
append using lifetable_wealth_group_bs
save lifetable_wealth_group_bs, replace
*-------------------------------------------------------------------------------


* HHLIT BY GROUP BY SEX LIFE TABLE -------------------------------------
* define for life table dofile
clear
use collapsepersonyearrs.dta
global char "group hhlit female agegroup"

do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\2b_callinlifetable"

gen rs=`rs'
append using lifetable_hhlit_group_bs
save lifetable_hhlit_group_bs, replace
*-------------------------------------------------------------------------------


* ALL STATES MINUS UTTARAKHAND BY SEX LIFE TABLE -------------------------------
clear
use collapsepersonyearrs.dta
drop if state==5
global char "female agegroup"

do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\2b_callinlifetable"

gen rs=`rs'
append using lifetable_nouk_bs
save lifetable_nouk_bs, replace
}

