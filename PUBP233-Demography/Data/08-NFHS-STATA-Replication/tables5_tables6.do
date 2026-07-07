

* USER WILL NEED TO INPUT YOUR OWN PATH HERE
clear
cd "D:\Projects\AHS-Coffey\Users\Life expectancy project\working\public"


/*                                                         
notes:
- this do-file does the following:
  . regressions predicting mortality
*/

* SET UP DATASET ---------------------------------------------------------------

use person.dta
keep if round==1

* create lenghth of potential exposure
gen end=mdy(1,1,2010)
gen exposure=3 if begage>0
replace exposure=exactage if died==0 & begage==0
replace exposure=(end-dob)/365 if died==1 & begage==0

gen expgroup=0 if exposure<1/12
forvalues i=0(1)36 {
replace expgroup=`i' if exposure<(`i'+1)/12 & expgroup==.
}


* rescale died
replace died=1000 if died==1

*district
egen distid=group(state district)

* other variables (insurance is not available for dead people in round 1)
gen hheduc=0 if hh_highest_qualification==0
replace hheduc=1 if hh_highest_qualification>0 & hh_highest_qualification<=4
replace hheduc=2 if hh_highest_qualification>4 & hh_highest_qualification<.
gen hh_age2=hh_age^2
gen wealthdc2=wealthdc^2

sort hhld_id
egen tag=tag(hhld_id)
gen helec=elec if tag==1
sort state district psu round
by state district psu round: egen psuelec=mean(helec)

*------------------------------------------------------------------------------*

* REGRESSIONS FOR UNDER 5S -----------------------------------------------------

*limit sample to indivs that have values for all characteristics included in regs
preserve

keep if group!=. & wealthdc!=. & rural!=. & psuod!=. & psusf!=. & od!=. & sf!=. & land!=. & agegroup<5


reg died b3.group ///
	b36.expgroup i.agegroup##i.female ///
	if agegroup<5  [aweight=wt], cluster(psu)
dis e(r2_a)
estadd ysumm, replace
est store ca
	
reg died b3.group rural ///
	b36.expgroup i.agegroup##i.female ///
	if agegroup<5  [aweight=wt], cluster(psu)
dis e(r2_a)
estadd ysumm, replace
est store cb

reg died b3.group rural ///
	wealthdc land ///
	b36.expgroup i.agegroup##i.female ///
	if agegroup<5  [aweight=wt], cluster(psu)
dis e(r2_a)
estadd ysumm, replace
est store cc

reg died b3.group rural ///
	wealthdc land ///
	psuod psusf od sf ///
	b36.expgroup i.agegroup##i.female ///
	if agegroup<5  [aweight=wt], cluster(psu)
dis e(r2_a)
estadd ysumm, replace
est store cd

reghdfe died b3.group ///
	b36.expgroup i.agegroup##i.female ///
	if agegroup<5  [aweight=wt], ///
	a(expgroup i.agegroup##i.female	state distid) cluster(psu)
dis e(r2_a)
estadd ysumm, replace
est store ce


esttab ca cb cc cd ce using regs_child2_short, se stats(N ymean) csv replace ///
keep(1.group 2.group 4.group wealthdc rural psuod psusf od sf land) ///
order(1.group 2.group 4.group rural wealthdc land psuod psusf od sf) ///
star(+ 0.1 * 0.05 ** 0.01)

restore

* for <5s decomposition should control for wealthdc, elec, psuod, od, sf.

*------------------------------------------------------------------------------*

* REGRESSIONS FOR OVER 5S -----------------------------------------------------

*limit sample to indivs that have values for all characteristics included in regs
preserve

keep if group!=. & wealthdc!=. & rural!=. & psusf!=. & sf!=. & land!=. & agegroup>=5

reg died b3.group ///
	i.agegroup##i.female ///
	if agegroup>=5 [aweight=wt], cluster(psu)
dis e(r2_a)
est store aa
estadd ysumm, replace

reg died b3.group rural ///
	i.agegroup##i.female ///
	if agegroup>=5 [aweight=wt], cluster(psu)
dis e(r2_a)
est store ab
estadd ysumm, replace

reg died b3.group rural ///
	wealthdc land ///
	i.agegroup##i.female ///
	if agegroup>=5 [aweight=wt], cluster(psu)
dis e(r2_a)
est store ac
estadd ysumm, replace
	
reg died b3.group rural ///
	wealthdc land ///
	psusf sf ///
	i.agegroup##i.female ///
	if agegroup>=5 [aweight=wt], cluster(psu)
dis e(r2_a)
est store ad
estadd ysumm, replace

reghdfe died b3.group ///
	if agegroup>=5 [aweight=wt], ///
	a(i.agegroup##i.female state distid) cluster(psu)
dis e(r2_a)
est store ae
estadd ysumm, replace

esttab aa ab ac ad ae using regs_adult2_short, se stats(N ymean) csv replace ///
keep(1.group 2.group 4.group wealthdc rural psusf sf land) ///
order(1.group 2.group 4.group rural wealthdc land psusf sf) ///
star(+ 0.1 * 0.05 ** 0.01)

restore

