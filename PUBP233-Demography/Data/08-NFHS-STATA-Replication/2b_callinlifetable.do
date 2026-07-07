/*                                                          
notes:
- this nested do-file calculates life table estimates    	                  */

bysort $char: egen totalpy = total(py)
bysort $char: egen totaldeaths = total(death)
gen nmx = totaldeaths/totalpy

* do a weighted average of nax, weighted by deaths in each state-group
gen wnax=(death/totaldeaths)*nax
bysort $char: egen newnax=total(wnax)
drop nax wnax
rename newnax nax
replace nax=. if agegroup==85

keep $char nmx nax
duplicates drop

* run life table
sort $char

gen n=1 if agegroup==0
replace n=4 if agegroup==1
replace n=5 if agegroup>1

gen nqx=(n*nmx)/(1+(n-nax)*nmx)
replace nqx=1 if agegroup==85
gen npx=1-nqx

gen l=100000 if agegroup==0
replace l=l[_n-1]*npx[_n-1] if agegroup>0

gen ndx=nqx*l

gen nLx=n*l[_n+1]+nax*ndx if agegroup<85
replace nLx=l/(nmx) if agegroup==85

gen Tx=nLx if agegroup==85
forvalues i=1(1)18 {
	replace Tx=Tx[_n+1]+nLx if agegroup<85
}

gen ex=Tx/l