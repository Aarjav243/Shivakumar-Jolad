
/*                                                         
notes:
- this do-file does the following:
  . makes figure for decomposition results
*/



* USER WILL NEED TO INPUT YOUR OWN PATH HERE
clear
cd "D:\Projects\AHS-Coffey\Users\Life expectancy project\working\public"



use decomp_bs
drop if rs==. & reweight==""
append using lifetable_group_bs
drop if group>4

gen type=.
replace type=1 if reweight=="p"
replace type=2 if reweight=="w"
replace type=3 if reweight=="env"
replace type=4 if reweight=="ed"
*replace type=5 if reweight=="dr"
replace type=0 if reweight==""

*calculate e5-20, and e20-e50
gen Tfifty=Tx if agegroup==50
gen Ttwenty=Tx if agegroup==20
bysort type female rs group: egen T50=mean(Tfifty)
bysort type female rs group: egen T20=mean(Ttwenty)

gen ereport= ex if agegroup==0 | agegroup==50 | agegroup==15 | agegroup==60
replace ereport=(Tx-T20)/l if agegroup==5
replace ereport=(Tx-T50)/l if agegroup==20

gen ref=ereport if group==3
bysort type female agegroup rs: egen exref=mean(ref)
gen diff=exref-ereport

gen refnmx=nmx if group==3
bysort type female agegroup rs: egen exrefnmx=mean(refnmx)
gen rationmx=(nmx/exrefnmx)

*calculate standard errors
bysort type female agegroup group: egen sd_rs_diff=sd(diff) if rs!=.
bysort type female agegroup group: egen se_diff=mean(sd_rs_diff)

bysort type female agegroup group: egen sd_rs_rationmx=sd(rationmx) if rs!=.
bysort type female agegroup group: egen se_rationmx=mean(sd_rs_rationmx)

bysort type female agegroup: egen n_rs=count(rs)
keep if rs==.
drop rs sd_*
save decomp_se, replace

*define female label for graph 
lab def female 0 "male" 1 "female"
lab val female female 
	
gen male = female == 0
lab def male 0 "a. female" 1 "b. male"
lab val male male 

*define sgroup label for graph
gen sgroup=.
replace sgroup=1 if group==2
replace sgroup=2 if group==1
replace sgroup=3 if group==4
lab def sgroup 1 "Adivasi" 2 "Dalit" 3 "Muslim"
lab val sgroup sgroup

*define age label for graph
gen age=.
replace age=1 if agegroup==0
replace age=2 if agegroup==5
replace age=3 if agegroup==20
replace age=4 if agegroup==50
lab def age 1 "age 0" 2 "age 5" 3 "age 20" 4 "age 50"
lab val age age

gen hci=diff+1.96*se_diff
gen lci=diff-1.96*se_diff

gen hcinmx=rationmx+1.96*se_rationmx
gen lcinmx=rationmx-1.96*se_rationmx
	
*gaps in e0, e5-20, e20-50, e50 after reweighting

gen label=""
replace label="e{sub:0}" if agegroup==0
replace label="e{sub:5-20}" if agegroup==5
replace label="e{sub:15}" if agegroup==15
replace label="e{sub:20-50}" if agegroup==20
replace label="e{sub:50}" if agegroup==50
replace label="e{sub:60}" if agegroup==60

gen type2=type

replace type=type-.05 if agegroup==0
replace type=type+.05 if agegroup==50
replace type=type-.05 if agegroup==20
replace type=type+.05 if agegroup==50
replace type=type+.05 if agegroup==60

*reweighted e0
keep if agegroup== 0


*for paper 
twoway ///
(connected diff type if group==2 & agegroup==0 & type < 3.5, yline(0, lcolor(gray) lpattern(dash)) msymbol(Dh) mcolor(maroon) lcolor(maroon) msize(*1.1)) ///
(rcap hci lci type if group==2 & agegroup==0 & type < 3.5, lcolor(maroon) msize(vtiny)) ///
(connected diff type if group==1 & agegroup==0 & type < 3.5, yline(0, lcolor(gray) lpattern(dash)) msymbol(Oh) mcolor(navy) lcolor(navy) msize(*1.1)) ///
(rcap hci lci type if group==1 & agegroup==0 & type < 3.5, lcolor(navy) msize(vtiny)) ///
(connected diff type if group==4 & agegroup==0 & type < 3.5, yline(0, lcolor(gray) lpattern(dash)) msymbol(Sh) mcolor(dkgreen) lcolor(dkgreen) msize(*1.1)) ///
(rcap hci lci type if group==4 & agegroup==0 & type < 3.5, lcolor(dkgreen) msize(vtiny)), ///
by(male, ///
	bgcolor(white) graphregion(color(white)) ///
	note("") ///
	row(2) imargin(medium)) ///
subtitle(, fcolor(none) ///
		lcolor(white) ) ///
	legend(order(1 "Adivasi" 3 "Dalit" 5 "Muslim") row(1) region(lcolor(white)) stack) ///
ytitle("gaps in life expectancy at birth (e{sub:0}) between" ///
"OBC/high-caste Hindus and each social group") ///
xlabel(0 `""full" "difference""' 1 `""unexplained" "by rural""' 2 `""+ economic" "status""' 3 `""+ environ-" "mental" "factors""', labsize(*.95)) ///
xtitle("") ///
xsize(2) ysize(3)

graph export "decomposition_e0.pdf", replace
