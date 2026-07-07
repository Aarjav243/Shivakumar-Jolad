
/*                                                         

notes:
- this do-file does the following:
  . starts with a dataset that has already combined all of the raw MORT .csv datasets for each state downloaded from the here (user will need to do this part herself): https://nrhm-mis.nic.in/hmisreports/AHSReports.aspx 
  . cleans combined MORT dataset
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
use "D:\Projects\AHS-Coffey\ahs\output data\mort\raw\mort_raw_all", clear

* set aside some variables for checking merge quality
order year_of_marriage highest_qualification, last

* drop redundant variables (from other modules)

drop id-hl_id m_expall_status-hh_serial_no usual_residance-year_of_birth marital_status-reason_for_not_attending_school ///
	 disability_status-regular_treatment_source status-house_status owner_status ///
	 hl_expall_status isdeadmigrated-residancial_status healthscheme_1-isheadchanged ///
	 as x-schedule_id v126 year_of_marriage
rename age hh_age
rename sex hh_sex
rename occupation_status hh_occupation_status
rename highest_qualification hh_highest_qualification
rename iscoveredbyhealthscheme hh_iscoveredbyhealthscheme
rename chew hh_chew
rename smoke hh_smoke
rename alcohol hh_alcohol

	 
* extract psu from fid variables
tostring fidh, gen(tempidh) format("%18.0f") force
replace tempidh="" if length(tempidh)<14
replace tempidh="0"+tempidh if length(tempidh)==14
tostring fidx, gen(tempidx) format("%18.0f") force
tostring fid, gen(tempid) format("%18.0f") force
replace tempid="" if length(tempid)<12
replace tempid="0"+tempid if length(tempid)==12
gen psu=real(substr(tempidh,5,3))
recode psu (0=.z)
replace psu=real(substr(tempidx,-3,.)) if missing(psu)
replace psu=real(substr(tempid,5,3)) if missing(psu) & ///
                                        real(substr(tempid,-7,.))>0
										
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
recode date_of_death (0=.z)
replace date_of_death=.x if ! inrange(date_of_death,1,31) & ///
                            ! missing(date_of_death)
recode month_of_death (0=.z)
replace month_of_death=.x if ! inrange(month_of_death,1,12) & ///
                             ! missing(month_of_death)
recode year_of_death (7=2007) (8=2008) (9=2009) ///
                     (209=2009) (1007=2007) (2209=2009)
replace year_of_death=2007 if inrange(year_of_death,2007.01,2007.99)
replace year_of_death=.x if ! inrange(year_of_death,2007,2012) & ///
                            ! missing(year_of_death)
gen death_yrmo=ym(year_of_death,month_of_death)
format death_yrmo %tm
order death_yrmo, after(year_of_death)
replace age_of_death_below_one_month=.x ///
        if ! inrange(age_of_death_below_one_month,0,31) & ///
           ! missing(age_of_death_below_one_month)
replace age_of_death_below_eleven_month=.x ///
        if ! inrange(age_of_death_below_eleven_month,0,11) & ///
           ! missing(age_of_death_below_eleven_month)
replace age_of_death_above_one_year=.x ///
        if ! inrange(age_of_death_above_one_year,0,110) & ///
           ! missing(age_of_death_above_one_year)

* generate round
gen round=year
drop year

* organize the identifiers
replace m_serial_no=2 if inrange(m_serial_no,2.01,2.99)
replace m_serial_no=.x if m_serial_no>=100000
order state district psu rural stratum_code house_no house_hold_no ///
      round m_serial_no

* remove duplicate records
drop psu_id
duplicates drop

* clean other variables
replace rural=1 if rural>2 & inlist(stratum_code,1,2)
replace treatment_source=.x if (! inrange(treatment_source,0,12) ///
                                & treatment_source!=99) & ///
                               ! missing(treatment_source)
recode place_of_death (99=4) (0=.z)
replace place_of_death=.x if ! inrange(place_of_death,1,4) & ///
                             ! missing(place_of_death)
recode is_death_reg (0=.z)
replace is_death_reg=.x if ! inrange(is_death_reg,1,3) & ///
                           ! missing(is_death_reg)
recode is_death_cert (0=.z)
replace is_death_cert=.x if ! inrange(is_death_cert,1,2) & ///
                            ! missing(is_death_cert)
recode death_symptoms (99=15) (0=.z)
replace death_symptoms=.x if ! inrange(death_symptoms,1,15) & ///
                             ! missing(death_symptoms)
recode is_death_assoc (0=.z)
replace is_death_assoc=.x if ! inrange(is_death_assoc,1,2) & ///
                             ! missing(is_death_assoc)
recode death_period (0=.z)
replace death_period=.x if ! inrange(death_period,1,7) & ///
                           ! missing(death_period)
recode months_of_pregnancy (0=.z)
replace months_of_pregnancy=.x if ! inrange(months_of_pregnancy,1,9) & ///
                                  ! missing(months_of_pregnancy)
recode factors_contributing_death (0=.z)
replace factors_contributing_death=.x ///
        if ! inrange(factors_contributing_death,1,7) & ///
           ! missing(factors_contributing_death)
recode factors_contributing_death_2 (0=.z)
replace factors_contributing_death_2=.x ///
        if ! inrange(factors_contributing_death_2,1,7) & ///
           ! missing(factors_contributing_death_2)
recode symptoms_of_death (0=.z)
replace symptoms_of_death=.x if ! inrange(symptoms_of_death,1,10) & ///
                                ! missing(symptoms_of_death)
recode time_between (0=.z)
replace time_between=.x if ! inrange(time_between,1,6) & ///
                           ! missing(time_between)
recode nearest_medical (0=.z)

replace hh_sex=.x if ! inrange(hh_sex,1,2) & ///
                  ! missing(hh_sex)
replace hh_age=.x if ! inrange(hh_age,0,110) & ! missing(hh_age)
replace hh_highest_qualification=.x if ! inrange(hh_highest_qualification,0,9) & ///
                                    ! missing(hh_highest_qualification)
replace hh_chew=.x if ! inrange(hh_chew,0,7) & ! missing(hh_chew)
replace hh_smoke=.x if ! inrange(hh_smoke,0,4) & ! missing(hh_smoke)
replace hh_alcohol=.x if ! inrange(hh_alcohol,0,4) & ! missing(hh_alcohol)
replace hh_occupation_status=.x if ! inrange(hh_occupation_status,1,16) & ///
                                ! missing(hh_occupation_status)
replace house_structure=.x if ! inrange(house_structure,1,4) & ///
                              ! missing(house_structure)
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
foreach i of varlist is_radio is_television is_washing_machine-is_water_pump {
  replace `i'=.x if ! inrange(`i',1,2) & ! missing(`i')
}
replace is_computer=.x if ! inrange(is_computer,1,3) & ! missing(is_computer)
replace is_telephone=.x if ! inrange(is_telephone,1,4) & ! missing(is_telephone)
replace cart=.x if ! inrange(cart,1,4) & ! missing(cart)
replace land_poss=.x if ! inrange(land_poss,1,6) & ! missing(land_poss)
recode hh_iscoveredbyhealthscheme (0=.z)
replace hh_iscoveredbyhealthscheme=.x ///
        if ! inrange(hh_iscoveredbyhealthscheme,1,3) & ///
           ! missing(hh_iscoveredbyhealthscheme)

* fill in missing weights
bysort state district stratum_code: egen tempwt=mode(wt)
replace wt=tempwt if wt!=tempwt & ! missing(state,district,stratum_code)
drop tempwt

* give households a concise identifier where possible
egen hhld_id=concat(state district psu house_no house_hold_no) ///
     if ! missing(state,district,psu,house_no,house_hold_no), punct("-")
order hhld_id, after(house_hold_no)

* label variables USER WILL NEED TO INPUT YOUR OWN PATH HERE
do "D:\Projects\AHS-Coffey\Users\Life expectancy project\dofiles\public_dofiles\1d_label_mort"

lab var hh_age "age"
lab var hh_sex "sex"
label define l_hh_sex 1 "male" ///
                   2 "female", replace
lab val hh_sex l_hh_sex
lab var religion "religion"
lab def l_religion 1 "hindu" ///
                   2 "muslim" ///
                   3 "christian" ///
                   4 "sikh" ///
                   5 "buddhist" ///
                   6 "jain" ///
                   7 "other religion" ///
                   8 "no religion", replace
lab val religion l_religion

lab var social_group_code "social group"
lab def l_socialgroup 1 "sc" ///
                      2 "st" ///
                      3 "other group", replace
lab val social_group_code l_socialgroup

lab var hh_chew "habits: chew?"
lab def l_chew 0 "not known" ///
               1 "pan with tobacco" ///
               2 "pan without tobacco" ///
               3 "gutka or pan masala with tobacco" ///
               4 "gutka or pan masala without tobacco" ///
               5 "tobacco only" ///
               6 "ex-chewer" ///
               7 "never chewed", replace
lab val hh_chew l_chew
notes hh_chew: round 1 only
notes hh_chew: auto-populated for rounds 2/3

lab var hh_smoke "habits: smoke?"
lab def l_smoke 0 "not known" ///
                1 "usual smoker" ///
                2 "occassional smoker" ///
                3 "ex-smoker" ///
                4 "never smoked", replace
lab val hh_smoke l_smoke
notes hh_smoke: round 1 only
notes hh_smoke: auto-populated for rounds 2/3

lab var hh_alcohol "habits: drink?"
lab def l_alcohol 0 "not known" ///
                  1 "usual drinker" ///
                  2 "occassional drinker" ///
                  3 "ex-drinker" ///
                  4 "never drank", replace
lab val hh_alcohol l_alcohol
notes hh_alcohol: round 1 only
notes hh_alcohol: auto-populated for rounds 2/3

lab var hh_highest_qualification "highest educational qualification attained"
lab def l_highestqual 0 "illiterate" ///
                      1 "literate, no formal educ." ///
                      2 "literate, formal educ.: below primary" ///
                      3 "literate, formal educ.: primary" ///
                      4 "literate, formal educ.: middle" ///
                      5 "literate, formal educ.: sec/matric (x)" ///
                      6 "literate, formal educ.: high-sec/pre-univ (xii)" ///
                      7 "literate, formal educ.: grad/btech/bbs/mbbs/etc." ///
                      8 "literate, formal educ.: postgrad/mtech/mba/md/etc." ///
                      9 "literate, formal educ.: diploma/certif.", replace
lab val hh_highest_qualification l_highestqual
notes hh_highest_qualification: asked only if age 7 or older

lab var hh_occupation_status "occupation/activity status during past year"
lab def l_occstatus  1 "cultivator" ///
                     2 "agricultural wage laborer" ///
                     3 "non-agricultural wage laborer" ///
                     4 "self employed: own account worker" ///
                     5 "self employed: employer" ///
                     6 "self employed: unpaid family laborer" ///
                     7 "regular salaried/wage worker" ///
                     8 "unemployed (seeking work, but not working)" ///
                     9 "attending school" ///
                    10 "doing domestic work" ///
                    11 "beggar" ///
                    12 "sex worker" ///
                    13 "rentier, pensioner, or other remittance" ///
                    14 "disability (unable to work)" ///
                    15 "too old to work" ///
                    16 "other occupation", replace
lab val hh_occupation_status l_occstatus
notes hh_occupation_status: asked only if age 5 or older

lab var house_structure "type of house structure where household lives"
lab def l_housestructure 1 "pucca" ///
                         2 "semi-pucca" ///
                         3 "kuccha" ///
                         4 "other", replace
lab val house_structure l_housestructure

lab var drinking_water_source "drinking water source"
lab def l_drinksource 1 "piped into dwelling/yard/plot" ///
                      2 "public tap or standpipe" ///
                      3 "hand pump" ///
                      4 "tubewell or borehole" ///
                      5 "protected dug well" ///
                      6 "unprotected dug well" ///
                      7 "tanker/truck/cart" ///
                      8 "surface water" ///
                      9 "other source", replace
lab val drinking_water_source l_drinksource

lab var is_water_filter "does household treat the water for safe consumption?"
lab val is_water_filter l_yesno

lab var water_filteration "how is water treated?"
lab def l_waterfilter 1 "boil" ///
                      2 "bleach/chlorine tablets" ///
                      3 "aluminum sulfate (alum)" ///
                      4 "strain through cloth" ///
                      5 "water filters (ceramics, sand, etc.)" ///
                      6 "electronic filters (ro, uv, etc.)" ///
                      7 "let it stand and settle" ///
                      8 "other treatment", replace
lab val water_filteration l_waterfilter

lab var toilet_used "type of toilet facility primarily used"
lab def l_toiletused 0 "open defecation" ///
                     1 "pour/flush latrine: connected to piped sewer system" ///
                     2 "pour/flush latrine: connected to septic tank" ///
                     3 "pour/flush latrine: connected to pit latrine" ///
                     4 "pour/flush latrine: connected to something else" ///
                     5 "pit latrine: ventilated improved pit" ///
                     6 "pit latrine: with slab" ///
                     7 "pit latrine: open or without slab" ///
                     8 "service latrine" ///
                     9 "community toilet", replace
lab val toilet_used l_toiletused

lab var is_toilet_shared "is toilet shared?"
lab val is_toilet_shared l_yesno

lab var household_have_electricity "does household have electricity?"
lab val household_have_electricity l_yesno

lab var lighting_source "main source of lighting"
lab def l_lightsource 1 "electricity" ///
                      2 "kerosene" ///
                      3 "solar" ///
                      4 "other oils" ///
                      5 "other source" ///
                      6 "no lighting", replace
lab val lighting_source l_lightsource

lab var cooking_fuel "main source of fuel for cooking"
lab def l_cookingfuel 0 "no cooking" ///
                      1 "firewood" ///
                      2 "crop residue" ///
                      3 "cow dung cake" ///
                      4 "coal/ignite/charcoal" ///
                      5 "kerosene" ///
                      6 "lpg/png" ///
                      7 "electricity" ///
                      8 "biogas" ///
                      9 "other fuel", replace
lab val cooking_fuel l_cookingfuel

lab var no_of_dwelling_rooms "number of rooms in possession of household"
notes no_of_dwelling_rooms: values above 25 rooms set to .x

lab var kitchen_availability "availability of kitchen"
lab def l_kitchavail 1 "cooking inside house: has kitchen" ///
                     2 "cooking inside house: no kitchen" ///
                     3 "cooking outside house: has kitchen" ///
                     4 "cooking outside house: no kitchen" ///
                     5 "no cooking", replace
lab val kitchen_availability l_kitchavail

lab var is_radio "assets: radio?"
lab val is_radio l_yesno

lab var is_television "assets: television?"
lab val is_television l_yesno

lab var is_computer "assets: computer?"
lab def l_computer 1 "yes, with internet" ///
                   2 "yes, without internet" ///
                   3 "no", replace
lab val is_computer l_computer

lab var is_telephone "assets: telephone/mobile?"
lab def l_telephone 1 "telephone only" ///
                    2 "mobile phone only" ///
                    3 "both" ///
                    4 "neither", replace
lab val is_telephone l_telephone

lab var is_washing_machine "assets: washing machine?"
lab val is_washing_machine l_yesno

lab var is_refrigerator "assets: refrigerator?"
lab val is_refrigerator l_yesno

lab var is_sewing_machine "assets: sewing machine?"
lab val is_sewing_machine l_yesno

lab var is_bicycle "assets: bicycle?"
lab val is_bicycle l_yesno

lab var is_scooter "assets: scooter?"
lab val is_scooter l_yesno

lab var is_car "assets: car?"
lab val is_car l_yesno

lab var is_tractor "assets: tractor?"
lab val is_tractor l_yesno

lab var is_water_pump "assets: water pump?"
lab val is_water_pump l_yesno

lab var cart "assets: type of cart"
lab def l_cart 1 "animal-driven" ///
               2 "machine-driven" ///
               3 "other type" ///
               4 "no cart", replace
lab val cart l_cart

lab var land_possessed "assets: land possessed"
lab def l_landposs 1 "less than 0.02 ha" ///
                   2 "0.02-1.00 ha" ///
                   3 "1.00-4.00 ha" ///
                   4 "4.00-10.00 ha" ///
                   5 "10.00 or more ha" ///
                   6 "no land", replace
lab val land l_landposs

lab var hh_iscoveredbyhealthscheme "covered by any health scheme/insurance?"
lab val hh_iscoveredbyhealthscheme l_yesnodk
notes hh_iscoveredbyhealthscheme: rounds 2/3 only


* save stata file
compress
sort state district psu house_no house_hold_no round
save mortclean.dta, replace

* ------------------------------------------------------------------------------

