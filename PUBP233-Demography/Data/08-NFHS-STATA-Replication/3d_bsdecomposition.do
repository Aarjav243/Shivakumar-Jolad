
/*                                                         

notes:
- this do-file does the following:
  . this dofile does bootstrap for the reweighted life table estimates in a loop
  . uses a nested dofile to do the repetitive tasks of life tables
  . appends bootstrap estimates in new datasets (one for each type of life table)
*/


* USER WILL NEED TO INPUT YOUR OWN PATH HERE
clear
cd "D:\Projects\AHS-Coffey\Users\Life expectancy project\working\public"



* KEEP THE RESAMPLED DATA ONLY -------------------------------------------------
forvalues rs=1(1)1000 {
clear
use personrs.dta
drop if group==.
keep cluster-district w`rs'
drop if w`rs'==0
gen newwt=wt*w`rs'
replace wt=newwt
drop newwt
*-------------------------------------------------------------------------------


* CALCULATE NEW WEIGHTS --------------------------------------------------------
local g "group" 
local basevar "female agegroup" 
local p "rural"
local cw "wealthqt land"
local cenv "sf psuodsplit"
local aw "wealthqt land"
local aenv "sf"
local ed "hhlit"

bysort `g' `basevar': egen wtg=total(wt)
bysort `g' `basevar' `p': egen wtp=total(wt)

*for children
bysort `g' `basevar' `p' `cw': egen wtcw=total(wt)
bysort `g' `basevar' `p' `cw' `cenv': egen wtcenv=total(wt)
bysort `g' `basevar' `p' `cw' `cenv' `ed': egen wtced=total(wt)

*for adults
bysort `g' `basevar' `p' `aw': egen wtaw=total(wt)
bysort `g' `basevar' `p' `aw' `aenv': egen wtaenv=total(wt)
bysort `g' `basevar' `p' `aw' `aenv' `ed': egen wtaed=total(wt)

keep `g' `basevar' rural wealthqt land sf psuodsplit hhlit wtg wtp ///
	wtcw wtcenv wtced wtaw wtaenv wtaed

duplicates drop

gen wtgref=wtg if group==3
bysort `basevar': egen wtg3=mean(wtgref)
gen wtpref=wtp if group==3
bysort `basevar' `p': egen wtp3=mean(wtpref)
gen wtcwref=wtcw if group==3
bysort `basevar' `p' `cw': egen wtcw3=mean(wtcwref)
gen wtcenvref=wtcenv if group==3
bysort `basevar' `p' `cw' `cenv': egen wtcenv3=mean(wtcenvref)
gen wtcedref=wtced if group==3
bysort `basevar' `p' `cw' `cenv' `ed': egen wtced3=mean(wtcedref)
gen wtawref=wtaw if group==3
bysort `basevar' `p' `aw': egen wtaw3=mean(wtawref)
gen wtaenvref=wtaenv if group==3
bysort `basevar' `p' `aw' `aenv': egen wtaenv3=mean(wtaenvref)
gen wtaedref=wtaed if group==3
bysort `basevar' `p' `aw' `aenv' `ed': egen wtaed3=mean(wtaedref)

drop wtgref wtpref wtcwref wtcenvref wtcedref wtawref wtaenvref wtaedref

sort `g' `basevar' `p' 
save newwtsrs.dta, replace

use newwtsrs.dta
keep if agegroup<5
keep `g' `basevar' `p' `cw' wtcw wtcw3 
duplicates drop
save newwtscwrs.dta, replace

use newwtsrs.dta
keep if agegroup<5
keep `g' `basevar' `p' `cw' `cenv' wtcenv wtcenv3 
duplicates drop
save newwtscenvrs.dta, replace

use newwtsrs.dta
keep if agegroup<5
keep `g' `basevar' `p' `cw' `cenv' `ed' wtced wtced3 
duplicates drop
save newwtscedrs.dta, replace


use newwtsrs.dta
keep if agegroup>=5
keep `g' `basevar' `p' `aw' wtaw wtaw3 
duplicates drop
save newwtsawrs.dta, replace

use newwtsrs.dta
keep if agegroup>=5
keep `g' `basevar' `p' `aw' `aenv' wtaenv wtaenv3 
duplicates drop
save newwtsaenvrs.dta, replace

use newwtsrs.dta
keep if agegroup>=5
keep `g' `basevar' `p' `aw' `aenv' `ed' wtaed wtaed3 
duplicates drop
save newwtsaedrs.dta, replace

*-------------------------------------------------------------------------------

* MERGE DECOMP WEIGHTS WITH PY DATASET -----------------------------------------

use personyearrs.dta
drop if group==.
keep cluster-district w`rs'
drop if w`rs'==0
gen newwt=wt*w`rs'
replace wt=newwt
drop newwt
keep state group female agegroup rural wealthqt land sf psuodsplit hhlit wt py death

sort `g' `basevar' `p'
merge m:m `g' `basevar' `p' using newwtsrs.dta, keepusing(wtg wtp wtg3 wtp3)
drop _merge

join, from(newwtscwrs) by(`g' `basevar' `p' `cw') 
drop _merge

join, from(newwtscenvrs) by(`g' `basevar' `p' `cw' `cenv')
drop _merge

join, from(newwtscedrs) by(`g' `basevar' `p' `cw' `cenv' `ed')
drop _merge

join, from(newwtsawrs) by(`g' `basevar' `p' `aw') 
drop _merge

join, from(newwtsaenvrs) by(`g' `basevar' `p' `aw' `aenv')
drop _merge

join, from(newwtsaedrs) by(`g' `basevar' `p' `aw' `aenv' `ed')
drop _merge


*-------------------------------------------------------------------------------

* REWEIGHTED LIFE TABLES -------------------------------------------------------

* weight the person-years and deaths
gen rwtp=(wtp3/wtg3)/(wtp/wtg)
gen rwtw=(wtcw3/wtg3)/(wtcw/wtg)
replace rwtw=(wtaw3/wtg3)/(wtaw/wtg) if agegroup>=5
gen rwtenv=(wtcenv3/wtg3)/(wtcenv/wtg)
replace rwtenv=(wtaenv3/wtg3)/(wtaenv/wtg) if agegroup>=5
gen rwted=(wtced3/wtg3)/(wtced/wtg)
replace rwted=(wtaed3/wtg3)/(wtaed/wtg) if agegroup>=5

foreach v in p w env ed {
gen wpy`v'=wt*rwt`v'*py
gen wdeath`v'=wt*rwt`v'*death
}

* collapse and save smaller dataset
fcollapse (sum) wpy* wdeath*, by(state group female agegroup) fast

* merge with SRS nax values for each state-sex
sort state female agegroup
join, from(srs_nax) by(state female agegroup)
drop _merge

save collapsepersonyeardecomprs.dta, replace

* age-specific mortality rates

foreach v in p w env ed {
clear
use collapsepersonyeardecomprs.dta
rename wpy`v' py
rename wdeath`v' death
keep state group female agegroup nax py death

global char "group female agegroup"

do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\2b_callinlifetable"

gen reweight="`v'"
gen rs=`rs'
append using decomp_bs
save decomp_bs, replace
}


*-------------------------------------------------------------------------------
}