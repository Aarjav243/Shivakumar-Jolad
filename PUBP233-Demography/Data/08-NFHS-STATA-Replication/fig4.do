
/*                                                         
notes:
- this do-file does the following:
  . makes figure for gender differences by group
*/



* USER WILL NEED TO INPUT YOUR OWN PATH HERE
clear
cd "D:\Projects\AHS-Coffey\Users\Life expectancy project\working\public"

*bring in estimates 

	use lifetable_group_bs.dta, clear 
	
*drops 
	
	keep if agegroup == 0 
	keep group female ex rs 
	
*reshape 
	
	rename ex ex_
	reshape wide ex, i(rs group) j(female)

	gen difference = ex_1 - ex_0
	
	bysort group: egen sd_dif =sd(difference) if rs!=.
	
	sort rs group
	
	bysort group: egen sd_dif2 = mean(sd_dif)
	sort rs group
	
	keep if rs == .
	gen lci = difference - 1.96*sd_dif2
	gen uci = difference + 1.96*sd_dif2
	
	gen sgroup = . 
	replace sgroup = 2 if group == 1 
	replace sgroup = 1 if group == 2 
	replace sgroup = 3 if group == 4 
	replace sgroup = 4 if group == 3
	
	*gen position for ci scatter 
	cap drop ci_pos
	gen ci_pos=0.22
	
	gen pos = 0.48
	
	*gen ci label 
	gen ci_ex_label = "[" + string(lci, "%3.2f") + "-" + string(uci, "%3.2f") + "]"

	drop if group == 5
	
	*bar 
	graph twoway ///
	(bar difference sgroup if sgroup==1, ///
		barwidth(.8) fcolor(maroon*.75) lcolor(maroon)) ///
	(bar difference sgroup if sgroup==2, ///
		barwidth(.8) fcolor(navy*.75) lcolor(navy)) ///
	(bar difference sgroup if sgroup==3, ///
		barwidth(.8) fcolor(dkgreen*.75) lcolor(dkgreen)) ///
	(bar difference sgroup if sgroup==4, ///
		barwidth(.8) fcolor(orange*.75) lcolor(orange)) ///
	(rcap uci lci sgroup, ///
		lcolor(black) lwidth(thin)) ///
	(scatter pos difference sgroup, ///
		ms(none ..) mlab(difference) mlabcolor(white) mlabpos(0) mlabsize(*2) mlabf(%2.1f)) ///
	(scatter ci_pos difference sgroup, ///
		ms(none ..) mlab(ci_ex_label) mlabcolor(white) mlabpos(0) mlabsize(*1.5) mlabf(%3.2f)) ///
	, ///
	graphregion(lcolor(white) fcolor(white)) ///
	note("") ///
	legend(off) ///
	ylabel(0(1)4, nogrid) ///
	xlabel(1 "Adivasi" 2 "Dalit"  3 "Muslim" 4 `" "OBC/high-" "caste Hindu" "', labsize(*1.4)) ///
	xtitle("") ytitle("female-male difference in" ///
	"life expectancy at birth (years): e{sub:0}{sup:f-m}", size(*1.35)) 
	graph export "bar_e0dif_allstate_male_female.pdf", replace
	