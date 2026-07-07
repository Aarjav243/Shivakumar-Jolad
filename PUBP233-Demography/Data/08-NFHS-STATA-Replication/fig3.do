/*                                                         
notes:
- this do-file does the following:
  . makes graphs for state-wise group-wise  e0
  and overall
*/


* USER WILL NEED TO INPUT YOUR OWN PATH HERE
clear
cd "D:\Projects\AHS-Coffey\Users\Life expectancy project\working\public"


*  ----------------------------------------------------------

	*bring in data 
	use "lifetable_state_group_se.dta", clear
	
	keep if agegroup == 0
	
	*keep and drops 
	drop if group == 5 
	drop if group == .

	
	*labels etc 
	gen male = female == 0 
	lab def male 0 "a. female" 1 "b. male"
	lab val male male 
	
	
	*let's generate label values so that we can produce a graph
	
	*make hc highest value 
	gen sgroup = . 
	replace sgroup = 2 if group == 1 
	replace sgroup = 1 if group == 2 
	replace sgroup = 3 if group == 4 
	replace sgroup = 4 if group == 3

	*make missing those groups which are less than 5 percent of the pop in states 
		
		*uttarakhand adivasi 
		replace ex = . if sgroup == 1 & state == 5
	
		*up adivasi
		replace ex = . if sgroup == 1 & state == 9
		
		*bihar adivasi 
		replace ex = . if sgroup == 1 & state == 10
		
		*chattisgarh muslim 
		replace ex = . if sgroup == 3 & state == 22
		
		*odisha muslim
		replace ex = . if sgroup == 3 & state == 21 
	
	*gen CIs 
	gen lci = ex - 1.96*se_ex
	gen uci = ex + 1.96*se_ex 
	
	gen statex=.
	replace statex=1 if state==5
	replace statex=2 if state==8
	replace statex=3 if state==9
	replace statex=4 if state==10
	replace statex=5 if state==18
	replace statex=6 if state==20
	replace statex=7 if state==21
	replace statex=8 if state==22
	replace statex=9 if state==23
	
	*displace groups so that ex does not overlap
	replace statex=statex-.07*3 if sgroup==1
	replace statex=statex-.07*1 if sgroup==2
	replace statex=statex+.07*1 if sgroup==3
	replace statex=statex+.07*3 if sgroup==4
	
	*gen position for label scatter 
	cap drop pos
	gen pos=56.3

*female
	*preserve 
	preserve 
	keep if male == 0 
	
	graph twoway ///
	(bar ex sgroup if sgroup==1, ///
		barwidth(.8) fcolor(maroon*.75) lcolor(maroon)) ///
	(bar ex sgroup if sgroup==2, ///
		barwidth(.8) fcolor(navy*.75) lcolor(navy)) ///
	(bar ex sgroup if sgroup==3, ///
		barwidth(.8) fcolor(dkgreen*.75) lcolor(dkgreen)) ///
	(bar ex sgroup if sgroup==4, ///
		barwidth(.8) fcolor(orange*.75) lcolor(orange)) ///
	(rcap uci lci sgroup, ///
		lcolor(black) lwidth(thin)) ///
	(scatter pos ex sgroup, ///
		ms(none ..) mlab(ex) mlabcolor(white) mlabpos(0) mlabsize(*1.3) mlabf(%2.1f)), ///
	by(state, ///
		row(3) ///
		graphregion(lcolor(white) fcolor(white)) ///
		note("") ///
		legend(off) ///
		compact ///
		imargin(tiny) ///
		subtitle("a. female", size(*1.3))) ///
		subtitle(, fcolor(white) ///
		lcolor(black) size(*1.1))  ///
	ylabel(55(10)75, nogrid labsize(*1)) ///
	xlabel(1 "Adivasi" 2 "Dalit"  3 "Muslim" 4 `""OBC/" "HCH""', labsize(*.9)) ///
	xtitle("") ///
	ytitle("", size(vsmall)) ///
	xsize(3) ysize(2)
	graph save "bar_e0_state_female.gph", replace
		
	restore

*male 
	preserve 
	keep if male == 1
	
	graph twoway ///
	(bar ex sgroup if sgroup==1, ///
		barwidth(.8) fcolor(maroon*.75) lcolor(maroon)) ///
	(bar ex sgroup if sgroup==2, ///
		barwidth(.8) fcolor(navy*.75) lcolor(navy)) ///
	(bar ex sgroup if sgroup==3, ///
		barwidth(.8) fcolor(dkgreen*.75) lcolor(dkgreen)) ///
	(bar ex sgroup if sgroup==4, ///
		barwidth(.8) fcolor(orange*.75) lcolor(orange)) ///
	(rcap uci lci sgroup, ///
		lcolor(black) lwidth(thin)) ///
	(scatter pos ex sgroup, ///
		ms(none ..) mlab(ex) mlabcolor(white) mlabpos(0) mlabsize(*1.3) mlabf(%2.1f)), ///
	by(state, ///
		row(3) ///
		graphregion(lcolor(white) fcolor(white)) ///
		note("") ///
		legend(off) ///
		compact ///
		imargin(tiny) ///
		subtitle("b. male", size(*1.3))) ///
		subtitle(, fcolor(white) ///
		lcolor(black) size(*1.1))  ///
	ylabel(55(10)75, nogrid labsize(*1)) ///
	xlabel(1 "Adivasi" 2 "Dalit"  3 "Muslim" 4 `""OBC/" "HCH""', labsize(*.9)) ///
	xtitle("") ///
	ytitle("", size(vsmall)) ///
	xsize(3) ysize(2)
	graph save "bar_e0_state_male.gph", replace
	
*combine 

	graph combine /// 
	"bar_e0_state_female.gph" ///
	"bar_e0_state_male.gph", ///
	row(2) xsize(2) ysize(3) ///
	graphregion(lcolor(white) fcolor(white)) ///
	imargin(small) ///
	caption("life expectacy at birth: e{sub:0} (years)", ///
		pos(9) orientation(vertical) size(*.8))
	graph export "bar_e0_state_male_female.pdf", replace

	*present combine 
	graph combine /// 
	"bar_e0_state_female.gph" ///
	"bar_e0_state_male.gph", ///
	row(1) xsize(2) ysize(1) ///
	graphregion(lcolor(white) fcolor(white)) ///
	imargin(small) ///
	caption("life expectacy at birth: e{sub:0} (years)", ///
		pos(9) orientation(vertical) size(*.8))
	graph export "bar_e0_state_male_female_present.pdf", replace
