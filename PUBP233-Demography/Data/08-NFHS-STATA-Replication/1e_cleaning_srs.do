/*                                                         

notes:
- this do-file does the following:
  . imports nax data from the SRS (this has been calculated by authors from the SRS 2007-2011 data available here: https://censusindia.gov.in/vital_statistics/Appendix_SRS_Based_Life_Table.html)
  . prepares the datset to be merged with the AHS data
*/

* USER WILL NEED TO INPUT YOUR OWN PATH HERE
clear
cd "D:\Projects\AHS-Coffey\Users\Life expectancy project\working\public"



* USER WILL NEED TO INPUT YOUR OWN PATH HERE
import excel using "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\data\srs_nax_2007_2011", firstrow


* EXPAND THE STATES WE WILL NEED MULTIPLES OF ----------------------------------

expand 2 if place=="india", generate(exp1)
expand 2 if place=="bihar", generate(exp2)
expand 2 if place=="madhya pradesh", generate(exp3)

gen exp=exp1+exp2+exp3
drop exp1 exp2 exp3
*-------------------------------------------------------------------------------

* GIVE STATES AHS LABELS -------------------------------------------------------

gen state=.
replace state=5 if place=="india" & exp==1
replace state=8 if place=="rajasthan"
replace state=9 if place=="uttar pradesh"
replace state=10 if place=="bihar" & exp==0
replace state=18 if place=="assam"
replace state=20 if place=="bihar" & exp==1
replace state=21 if place=="odisha"
replace state=22 if place=="madhya pradesh" & exp==0
replace state=23 if place=="madhya pradesh" & exp==1

drop exp
*-------------------------------------------------------------------------------

* RESHAPE DATA TO MERGE --------------------------------------------------------

keep state age male_nax female_nax
drop if state==.
rename male_nax nax0
rename female_nax nax1
egen obs=group(state age)
reshape long nax, i(obs) j(female)
drop obs
order state female age
rename age agegroup
sort state female age

save srs_nax.dta, replace