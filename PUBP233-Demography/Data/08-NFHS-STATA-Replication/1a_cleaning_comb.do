
/*                                                         

notes:
- this do-file does the following:
  . starts with a dataset that has already combined all of the raw COMB .csv datasets for each state downloaded from the here (user will need to do this part herself: https://nrhm-mis.nic.in/hmisreports/AHSReports.aspx
  . cleans combined COMB dataset
  . to create a modified final dataset with the variables we need, dofile does:
    . resolves psu identifiers, including the PSU fix that MOSPI contact suggested
    . removes administrative variables,
    . cleans dates,
    . deletes duplicates,
    . cleans erroneous values,
    . adds a convenient household identifier,
    . and calls another do-file for labelling.
*/

* USER WILL NEED TO INPUT YOUR OWN PATH HERE
clear
cd "D:\Projects\AHS-Coffey\Users\Life expectancy project\working\public"


* open raw verion USER WILL NEED TO INPUT YOUR OWN PATH HERE
use "D:\Projects\AHS-Coffey\ahs\output data\comb\raw\comb_raw_all", clear

* drop a few (15) records with bad delimiting
drop if ! missing(v104)

* drop redundant variables (from other modules)
drop hh_id-hl_id currently_dead_or_out_migrated ///
     status-client_hl_id building_no hl_expall_status isdeadmigrated ///
     rtelephoneno-schedule_id id v104

*compress
compress

* extract psu from fid variables
gen tempid=fid
replace tempid="" if ! inlist(length(tempid),12,13)
replace tempid="0"+tempid if length(tempid)==12
tostring fidx, gen(tempidx) format("%18.0f") force
replace tempidx="" if length(tempidx)<8
gen psu=real(substr(tempid,5,3))
replace psu=real(substr(tempidx,-3,.)) if missing(psu) | psu==0
replace psu=.z if psu==0

* there are many psus that are missing still (~2 million obs)
sort state psu_id
order psu_id fid fidh fidx psu
gen psu1=psu
replace psu1=psu1[_n-1] if psu1>=. & stratum_code==stratum_code[_n-1]
gen psu11=psu
replace psu11=psu11[_n-1] if psu11>=.
gsort state -psu_id
gen psu2=psu
replace psu2=psu2[_n-1] if psu2>=. & stratum_code==stratum_code[_n-1]
gen psu22=psu
replace psu22=psu22[_n-1] if psu22>=.
replace psu=psu1 if psu>=. & psu1==psu2
replace psu=psu1 if psu>=. & psu2==.
replace psu=psu2 if psu>=. & psu1==.
gen conflict=(psu1!=psu2) if psu1!=. & psu2!=.
gen conflict2=(psu1==. & psu2==.)
sort state district psu1 psu2
by state district psu1 psu2: egen totconf=total(conflict) if conflict==1
by state district psu1 psu2: egen totconf2=total(conflict2) if conflict2==1
sort state psu_id
gen order=1 if conflict==1 & conflict[_n-1]==0
replace order=order[_n-1]+1 if conflict==1 & order==.
set seed 1957
gen rand=round(totconf*runiform()) if order==1
replace rand=rand[_n-1] if rand==. & conflict==1
replace psu=psu1 if rand>=order & conflict==1
replace psu=psu2 if rand<order & conflict==1

gen order2=1 if conflict2==1 & conflict2[_n-1]==0
replace order2=order2[_n-1]+1 if conflict2==1 & order2==.
gen rand2=round(totconf2*runiform()) if order2==1
replace rand2=rand2[_n-1] if rand2==. & conflict2==1
replace psu=psu11 if rand2>=order2 & conflict2==1
replace psu=psu22 if rand2<order2 & conflict2==1

drop psu1* psu2* conflict* totconf* order order2 rand* 

sort state district psu
by state district psu: egen newstratum=mode(stratum_code)
by state district psu: egen minstratum=min(stratum_code) if newstratum==.
by state district psu: egen maxstratum=max(stratum_code) if newstratum==.
replace newstratum=maxstratum if newstratum==.

drop tempid* fid*

* clean key dates and ages
recode date_of_birth (0=.z)
replace date_of_birth=.x if ! inrange(date_of_birth,1,31) & ///
                            ! missing(date_of_birth)
recode month_of_birth (0=.z)
replace month_of_birth=.x if ! inrange(month_of_birth,1,12) & ///
                             ! missing(month_of_birth)
recode year_of_birth (0=.z) (2204=2004) (20007=2007) (20009=2009) (20087=2008)
replace year_of_birth=.x if ! inrange(year_of_birth,1910,2011) & ///
                            ! missing(year_of_birth)
gen birth_yrmo=ym(year_of_birth,month_of_birth)
format birth_yrmo %tm
order birth_yrmo, after(year_of_birth)
recode date_of_marriage (0=.z)
replace date_of_marriage=.x if ! inrange(date_of_marriage,1,31) & ///
                               ! missing(date_of_marriage)
recode month_of_marriage (0=.z)
replace month_of_marriage=.x if ! inrange(month_of_marriage,1,12) & ///
                                ! missing(month_of_marriage)
recode year_of_marriage (0=.z)
replace year_of_marriage=.x if ! inrange(year_of_marriage,1910,2011) & ///
                               ! missing(year_of_marriage)
gen marry_yrmo=ym(year_of_marriage,month_of_marriage)
format marry_yrmo %tm
order marry_yrmo, after(year_of_marriage)

*generate round
gen round=year
replace round=.x if ! inlist(round,1,2,3) & ! missing(round)
drop year

* organize the identifiers
rename serial_no bldg_serial_no
rename hh_serial_no serial_no
order state district rural stratum_code psu house_no house_hold_no ///
      round serial_no member_identity

* remove duplicate records
drop psu_id
duplicates drop

* other cleaning
destring sex, replace
recode sex (22=2)
replace sex=.x if ! inrange(sex,1,2) & ///
                  ! missing(sex)
recode usual_residance (11=1)
replace usual_residance=.x if ! inrange(usual_residance,1,2) & ///
                              ! missing(usual_residance)
recode relation_to_head (0=.z)
replace relation_to_head=.x if ! inrange(relation_to_head,1,13) & ///
                               ! missing(relation_to_head)
replace age=.x if ! inrange(age,0,110) & ! missing(age)
replace currently_attending_school=.x ///
        if ! inrange(currently_attending_school,1,3) & ///
           ! missing(currently_attending_school)
replace reason_for_not_attending_school=.x ///
        if ! inrange(reason_for_not_attending_school,1,10) & ///
           ! missing(reason_for_not_attending_school)
replace highest_qualification=.x if ! inrange(highest_qualification,0,9) & ///
                                    ! missing(highest_qualification)
replace occupation_status=.x if ! inrange(occupation_status,1,16) & ///
                                ! missing(occupation_status)
replace disability_status=.x if ! inrange(disability_status,0,7) & ///
                                ! missing(disability_status)
replace injury_treatment_type=.x if ! inrange(injury_treatment_type,0,7) & ///
                                    ! missing(injury_treatment_type)
replace illness_type=.x if ! inrange(illness_type,0,9) & ///
                           ! missing(illness_type)
replace treatment_source=.x if ! (inrange(treatment_source,0,11) | ///
                                  inlist(treatment_source,13,99)) & ///
                               ! missing(treatment_source)
replace symptoms_pertaining_illness=.x ///
        if ! (inrange(symptoms_pertaining_illness,1,13) | ///
              symptoms_pertaining_illness==99) & ///
           ! missing(symptoms_pertaining_illness)
recode symptoms_pertaining_illness (10=13) (11=99) if round==1
replace symptoms_pertaining_illness=.x ///
        if inrange(symptoms_pertaining_illness,10,11) & missing(round)
recode sought_medical_care (0=.z)
replace sought_medical_care=.x if ! inrange(sought_medical_care,1,3) & ///
                                  ! missing(sought_medical_care)
recode diagnosed_for (21=99) if round==1
replace diagnosed_for=.x if diagnosed_for==21 & missing(round)
replace diagnosis_source=.x if ! (inrange(diagnosis_source,0,11) | ///
                                  inlist(diagnosis_source,13,99)) & ///
                               ! missing(diagnosis_source)
replace regular_treatment=.x if ! inrange(regular_treatment,1,3) & ///
                                ! missing(regular_treatment)
replace regular_treatment_source=.x ///
        if ! (inrange(regular_treatment_source,0,13) | ///
              regular_treatment_source==99) & ///
           ! missing(regular_treatment_source)
replace chew=.x if ! inrange(chew,0,7) & ! missing(chew)
replace smoke=.x if ! inrange(smoke,0,4) & ! missing(smoke)
replace alcohol=.x if ! inrange(alcohol,0,4) & ! missing(alcohol)
replace bldg_serial_no=.x if bldg_serial_no<0
replace house_status=.x if ! inrange(house_status,1,4) & ///
                           ! missing(house_status)
destring house_structure, replace
replace house_structure=.x if ! inrange(house_structure,1,4) & ///
                              ! missing(house_structure)
replace owner_status=.x if ! inrange(owner_status,1,3) & ///
                           ! missing(owner_status)
replace drinking_water_source=.x if ! inrange(drinking_water_source,1,9) & ///
                                    ! missing(drinking_water_source)
replace is_water_filter=.x if ! inrange(is_water_filter,1,2) & ///
                              ! missing(is_water_filter)
replace water_filteration=.x if ! inrange(water_filteration,1,8) & ///
                                ! missing(water_filteration)
replace toilet_used=.x if ! inrange(toilet_used,0,9) & ! missing(toilet_used)
recode is_toilet_shared (10=1)
replace is_toilet_shared=.x if ! inrange(is_toilet_shared,1,2) & ///
                               ! missing(is_toilet_shared)
replace household_have_electricity=.x ///
        if ! inrange(household_have_electricity,1,2) & ///
           ! missing(household_have_electricity)
replace lighting_source=.x if ! inrange(lighting_source,1,6) & ///
                              ! missing(lighting_source)
replace cooking_fuel=.x if ! inrange(cooking_fuel,0,9) & ///
                           ! missing(cooking_fuel)
replace no_of_dwelling_rooms=.x if ! inrange(no_of_dwelling_rooms,0,25) & ///
                                   ! missing(no_of_dwelling_rooms)
replace kitchen_availability=.x if ! inrange(kitchen_availability,1,5) & ///
                                   ! missing(kitchen_availability)
recode is_tractor (22=2)
foreach i of varlist is_radio is_television is_washing_machine-is_water_pump {
  replace `i'=.x if ! inrange(`i',1,2) & ! missing(`i')
}
replace is_computer=.x if ! inrange(is_computer,1,3) & ! missing(is_computer)
replace is_telephone=.x if ! inrange(is_telephone,1,4) & ! missing(is_telephone)
replace cart=.x if ! inrange(cart,1,4) & ! missing(cart)
replace land_poss=.x if ! inrange(land_poss,1,6) & ! missing(land_poss)
recode residancial_status (0=.z)
order residancial_status, after(usual_residance)
recode iscoveredbyhealthscheme (0=.z)
replace iscoveredbyhealthscheme=.x ///
        if ! inrange(iscoveredbyhealthscheme,1,3) & ///
           ! missing(iscoveredbyhealthscheme)
recode healthscheme_1 healthscheme_2 (0=.z)
foreach i of varlist healthscheme_1 healthscheme_2 {
  replace `i'=.x if ! inrange(`i',1,7) & ! missing(`i')
}
replace housestatus=.x if ! inrange(housestatus,0,3) & ! missing(housestatus)
recode householdstatus (0=.z)
replace householdstatus=.x if ! inrange(householdstatus,1,6) & ///
                              ! missing(householdstatus)
recode isheadchanged (0=.z)
replace isheadchanged=.x if ! inrange(isheadchanged,1,2) & ///
                            ! missing(isheadchanged)
order housestatus-isheadchanged, after(house_status)
recode as_binned (0=.z)
order as as_binned, after(land_poss)

* houselisting variables first
order bldg_serial_no-healthscheme_2, after(round)

* fill in missing weights
bysort state district stratum_code: egen tempwt=mode(wt)
replace wt=tempwt if wt!=tempwt & ! missing(state,district,stratum_code)
drop tempwt

* give households a concise identifier where possible
egen hhld_id=concat(state district psu house_no house_hold_no) ///
     if ! missing(state,district,psu,house_no,house_hold_no), punct("-")
order hhld_id, after(house_hold_no)

* label variables USER WILL NEED TO INPUT OWN PATH HERE
do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\1b_label_comb"

* compress and save stata file
compress
sort state district psu house_no house_hold_no member_identity round
save combclean.dta, replace

* ------------------------------------------------------------------------------