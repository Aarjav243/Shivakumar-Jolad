/*                                                         

notes:
- this do-file does the following:
  . uses a nested dofile to do the repetitive tasks of life tables
  . generates life table estimates for state by sex
  . generates life table estimates for group by sex
  . generates life table estimates for all by sex
  . generates life table estimates for wealth decile by sex
  . generates life table estimates for wealth decile by group by sex
*/

* USER WILL NEED TO INPUT YOUR OWN PATH HERE
clear
cd "D:\Projects\AHS-Coffey\Users\Life expectancy project\working\public"


* APPLY WEIGHTS, COLLAPSE, SAVE ------------------------------------------------

use personyear.dta
keep if round==1

* weight the person-years
gen wpy=wt*py

* weight the deaths
gen wdeath=wt*death

* collapse and save smaller dataset
fcollapse (sum) wpy wdeath, by(state group wealthdc hhlit female agegroup) fast
rename wpy py
rename wdeath deaths

* merge with SRS nax values for each state-sex
sort state female agegroup
merge m:1 state female agegroup using srs_nax.dta
drop _merge

save collapsepersonyear.dta, replace
*-------------------------------------------------------------------------------

* STATE BY SEX LIFE TABLE ------------------------------------------------------

* define for life table dofile
clear
use collapsepersonyear.dta
global char "state female agegroup"

* USER WILL NEED TO INPUT YOUR OWN PATH HERE
do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\2b_callinlifetable"

save lifetable_state, replace

*-------------------------------------------------------------------------------

* GROUP BY SEX LIFE TABLE ------------------------------------------------------

* define for life table dofile
clear
use collapsepersonyear.dta
global char "group female agegroup"

* USER WILL NEED TO INPUT YOUR OWN PATH HERE
do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\2b_callinlifetable"

save lifetable_group, replace

*-------------------------------------------------------------------------------

* ALL STATES BY SEX LIFE TABLE -------------------------------------------------

* define for life table dofile
clear
use collapsepersonyear.dta
global char "female agegroup"

* USER WILL NEED TO INPUT YOUR OWN PATH HERE
do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\2b_callinlifetable"

save lifetable_, replace
*-------------------------------------------------------------------------------

*STATES BY SOCIAL GROUP LIFE TABLE ---------------------------------------------

* define for life table dofile
clear
use collapsepersonyear.dta
global char "state group female agegroup"

* USER WILL NEED TO INPUT YOUR OWN PATH HERE
do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\2b_callinlifetable"

save lifetable_state_group, replace
*-------------------------------------------------------------------------------


* WEALTH DECILE BY SEX LIFE TABLE ----------------------------------------------
* define for life table dofile
clear
use collapsepersonyear.dta
global char "wealthdc female agegroup"

* USER WILL NEED TO INPUT YOUR OWN PATH HERE
do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\2b_callinlifetable"

save lifetable_wealth, replace
*-------------------------------------------------------------------------------

* WEALTH DECILE BY GROUP BY SEX LIFE TABLE -------------------------------------
* define for life table dofile
clear
use collapsepersonyear.dta
global char "group wealthdc female agegroup"

* USER WILL NEED TO INPUT YOUR OWN PATH HERE
do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\2b_callinlifetable"

save lifetable_wealth_group, replace

*-------------------------------------------------------------------------------

* HHLIT BY GROUP BY SEX LIFE TABLE ---------------------------------------------
* define for life table dofile
clear
use collapsepersonyear.dta
global char "group hhlit female agegroup"

* USER WILL NEED TO INPUT YOUR OWN PATH HERE
do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\2b_callinlifetable"

save lifetable_hhlit_group, replace
*-------------------------------------------------------------------------------

* ALL STATES MINUS UTTARAKHAND BY SEX LIFE TABLE -------------------------------

* define for life table dofile
clear
use collapsepersonyear.dta
drop if state==5
global char "female agegroup"

* USER WILL NEED TO INPUT YOUR OWN PATH HERE
do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\2b_callinlifetable"

save lifetable_nouk, replace
