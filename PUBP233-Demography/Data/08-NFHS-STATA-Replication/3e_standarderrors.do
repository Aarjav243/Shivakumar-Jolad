
/*                                                         
notes:
- this do-file does the following:
  . estimates standard errors based on completed bootstraps using a loop through files
*/


* USER WILL NEED TO INPUT YOUR OWN PATH HERE
clear
cd "D:\Projects\AHS-Coffey\Users\Life expectancy project\working\public"



foreach n in state group wealth "" {
use lifetable_`n'_bs
bysort `n' female agegroup: egen sd_rs_nmx=sd(nmx) if rs!=.
bysort `n' female agegroup: egen sd_rs_ex=sd(ex) if rs!=.
bysort `n' female agegroup: egen se_nmx=mean(sd_rs_nmx)
bysort `n' female agegroup: egen se_ex=mean(sd_rs_ex)
bysort `n' female agegroup: egen n_rs=count(rs)
keep if rs==.
drop rs sd_*
save lifetable_`n'_se, replace
}

foreach n in state wealth {
use lifetable_`n'_group_bs
bysort `n' group female agegroup: egen sd_rs_nmx=sd(nmx) if rs!=.
bysort `n' group female agegroup: egen sd_rs_ex=sd(ex) if rs!=.
bysort `n' group female agegroup: egen se_nmx=mean(sd_rs_nmx)
bysort `n' group female agegroup: egen se_ex=mean(sd_rs_ex)
bysort `n' group female agegroup: egen n_rs=count(rs)
keep if rs==.
drop rs sd_*
save lifetable_`n'_group_se, replace
}

use lifetable_nouk_bs
bysort female agegroup: egen sd_rs_nmx=sd(nmx) if rs!=.
bysort female agegroup: egen sd_rs_ex=sd(ex) if rs!=.
bysort female agegroup: egen se_nmx=mean(sd_rs_nmx)
bysort female agegroup: egen se_ex=mean(sd_rs_ex)
bysort female agegroup: egen n_rs=count(rs)
keep if rs==.
drop rs sd_*
save lifetable_nouk_se, replace
