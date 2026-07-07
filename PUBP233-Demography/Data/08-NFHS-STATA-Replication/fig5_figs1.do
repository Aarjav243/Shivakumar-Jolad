
/*                                                         
notes:
- this do-file does the following:
  . makes figure for wealth-group life expectancies
  . makes figure for by group histogram across wealth
*/


* USER WILL NEED TO INPUT YOUR OWN PATH HERE
clear
cd "D:\Projects\AHS-Coffey\Users\Life expectancy project\working\public"




* HISTOGRAM ACROSS WEALTH ------------------------------------------------------
clear
use person.dta
keep if round==1 
sort group wealthdc
by group wealthdc: egen wgsum=total(wt)
by group: egen gsum=total(wt)
gen prop=wgsum/gsum
egen tag=tag(group wealthdc)
replace wealthdc=wealthdc+.99 if tag==1 
drop tag
egen tag=tag(group wealthdc)
keep if tag==1
sort group wealthdc

twoway (line prop wealthdc if group==2 & tag==1, lcolor(maroon) lpattern(longdash)) ///
(line prop wealthdc if group==1 & tag==1, lcolor(navy) lpattern(dash)) ///
(line prop wealthdc if group==4 & tag==1, lcolor(dkgreen) lpattern(shortdash)) ///
(line prop wealthdc if group==3 & tag==1, lcolor(orange) lpattern(shortdash_dot)) ///
, ///
xscale(range(.5(1)10.65)) xlabel(1 "poorest" 2(1)9 10 "wealthiest") ///
yscale(range(0(.05).25)) ylabel(0(.05).25) ///
ytitle("fraction of individuals in social group") ylabel(,nogrid) ///
legend(order(1 "Adivasi" 2 "Dalit" 3 "Muslim" 4 "OBC/high-caste Hindu") size(small) rows(1) ///
region(lcolor(white))) ///
xtitle("wealth decile") ///
bgcolor(white) graphregion(color(white))
graph export "histogram_wealth.pdf", as(pdf) replace

* WEALTH-GROUP FIGURE ----------------------------------------------------------
clear
use lifetable_wealth_group_se
append using lifetable_wealth_se
drop if wealthdc>10
*keep if agegroup==0

sort female group wealthdc agegroup

*define female label for graph 
	lab def female 0 "male" 1 "female"
	lab val female female 
	
	gen male = female == 0
	lab def male 0 "a. female" 1 "b. male"
	lab val male male 
	
gen hci=ex+1.96*se_ex
gen lci=ex-1.96*se_ex

gen x=.
replace x=wealthdc+.05 if group==2
replace x=wealthdc-.05 if group==1
replace x=wealthdc+.05 if group==4
replace x=wealthdc-.05 if group==3


twoway (connected ex x if group==2, msymbol(Dh) lcolor(maroon) mcolor(maroon) msize(small)) ///
(rarea hci lci x if group==2, color(maroon%20) lwidth(none)) ///
(connected ex x if group==1, msymbol(Oh) lcolor(navy) mcolor(navy) msize(small)) ///
(rarea hci lci x if group==1, color(navy%20) lwidth(none)) ///
(connected ex x if group==4, msymbol(Sh) lcolor(dkgreen) mcolor(dkgreen) msize(small)) ///
(rarea hci lci x if group==4, color(dkgreen%20) lwidth(none)) ///
(connected ex x if group==3, msymbol(Th) lcolor(orange) mcolor(orange) msize(small)) ///
(rarea hci lci x if group==3, color(orange%20) lwidth(none)) ///
if agegroup==0 ///
, ///
by(male, ///
	bgcolor(white) graphregion(color(white)) ///
	note("") ///
	row(2)) ///
subtitle(, fcolor(none) ///
		lcolor(white) ) ///
legend(order(1 "Adivasi" 3 "Dalit" 5 "Muslim" 7 "OBC/high-caste Hindu") ///
	size(small) rows(1) region(lcolor(white)) stack symp(0) symx(*1.1)) ///
ytitle("life expectancy at birth: e{sub:0} (years)") ///
xtitle("wealth decile") ///
xscale(range(.5(1)10.5)) xlabel(1 "poorest" 2(1)9 10 "richest") ///
yscale(range(58(2)72)) ylabel(58(2)72) ///
bgcolor(white) graphregion(color(white)) ///
xsize(2) ysize(3)
graph export "e0_wealthgroup.pdf", as(pdf) replace
