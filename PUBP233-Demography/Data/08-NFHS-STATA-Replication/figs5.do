
/*                                                         
notes:
- this do-file does the following:
  . makes graphs for group-wise  e15
  and overall
*/

* USER WILL NEED TO INPUT YOUR OWN PATH HERE
clear
cd "D:\Projects\AHS-Coffey\Users\Life expectancy project\working\public"



*  ----------------------------------------------------------

	*bring in data 
	use "lifetable_group_se.dta", clear
	
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
	
	
	*gen se variable 
	gen lci = ex - 1.96*se_ex
	gen uci = ex + 1.96*se_ex 
	
	
	*gen position for label scatter 
	cap drop pos
	gen pos=50.75
	
	*gen position for ci scatter 
	cap drop ci_pos
	gen ci_pos=50.5
	
	*gen ci label 
	gen ci_ex_label = "[" + string(lci, "%3.1f") + "-" + string(uci, "%3.1f") + "]"

	
	*bar 
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
		ms(none ..) mlab(ex) mlabcolor(white) mlabpos(0) mlabsize(small) mlabf(%2.1f)) ///
	(scatter ci_pos ex sgroup, ///
		ms(none ..) mlab(ci_ex_label) mlabcolor(white) mlabpos(0) mlabsize(vsmall) mlabf(%2.1f)) ///
	if agegroup==15, ///
	by(male, ///
		graphregion(lcolor(white) fcolor(white)) ///
		note("") ///
		legend(off)) ///
	graphregion(lcolor(white) fcolor(white)) ///
	subtitle(, fcolor(white) ///
		lcolor(white)) ///
	ylabel(50(3)59, nogrid) ///
	xlabel(1 "Adivasi" 2 "Dalit"  3 "Muslim" 4 `" "OBC/high-" "caste Hindu" "') ///
	xtitle("") ytitle("life expectancy at age 15: e{sub:15} (years)") 
	graph export "bar_e15_allstate_male_female.pdf", replace
	
