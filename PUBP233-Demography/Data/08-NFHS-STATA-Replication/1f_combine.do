
/*                                                         

notes:
- this do-file does the following:
  . drops 
	- the people that are not usual residents in the household in that round
	- people who don't have sex
	- people who don't have age or birth year

  . keeps the variables that we want to keep from the comb dataset
  . appends the comb and mort files
  . prepares the variables that we will use in analysis
  . calculates exact ages for live and dead people
  . outputs a person-level dataset for regression purposes
  . expands dataset to be at the person-year level
  . outputs a person-year-level dataset for life table purposes
*/


* USER WILL NEED TO INPUT YOUR OWN PATH HERE
clear
cd "D:\Projects\AHS-Coffey\Users\Life expectancy project\working\public"


use combclean.dta

* DROP OBS,VARS & APPEND - -----------------------------------------------------

* drop non-usual residents in combclean, and those for whom we do not know round
drop if usual_residance!=1 & round==1 
drop if residancial_status>6 & (round==2 | round==3)

* drop unnecessary variables in combclean
drop healthscheme_1-healthscheme_2 date_of_marriage-reason_for_not_attending_school /// 
	disability_status-regular_treatment_source

* append and save combined dataset
append using mortclean, generate(died)

* drop people for whom we cannot identify round
drop if round>=.
save combined.dta, replace

*-------------------------------------------------------------------------------


* PREPARE COVARIATES -----------------------------------------------------------

* prepare variables that we will use in analysis
gen female = sex==2 if sex<.
replace female = deceased_sex==2 if deceased_sex<. & died==1

gen group = social_group_code
replace group = 4 if social_group_code==3 & religion==2
replace group = 5 if social_group_code==3 & religion>2 & religion<10

replace rural=0 if rural==2

drop if female>=.

* randomly assign people with missing group to a group based on distribution across groups in population
tab group, gen(sg)
forvalues i=1(1)5 {
sum sg`i' [aweight=wt]
global frac`i'=r(mean)
}

set seed 2934823
gen rand=runiform() if group==.
replace group=1 if rand<=$frac1
replace group=2 if rand>$frac1 & rand<=$frac1+$frac2
replace group=3 if rand>$frac1+$frac2 & rand<=$frac1+$frac2+$frac3
replace group=4 if rand>$frac1+$frac2+$frac3 & rand<=$frac1+$frac2+$frac3+$frac4
replace group=5 if rand>$frac1+$frac2+$frac3+$frac4 & rand<=1

* for assets, exclude computer, washing machine, and car because they are hardly owned
drop as as_binned

gen elec = household_have_electricity==1 if household_have_electricity<.
gen kaccha = house_structure==3 if house_structure<4

gen radio = is_radio==1 if is_radio<.
gen tv = is_television==1 if is_television<.
gen computer = is_computer<=2 if is_computer<.
gen landline = (is_telephone==1 | is_telephone==3) if is_telephone<.
gen mobile = (is_telephone==2 | is_telephone==3) if is_telephone<.
gen washer = is_washing_machine==1 if is_washing_machine<.
gen fridge = is_refrigerator==1 if is_refrigerator<.
gen sewing = is_sewing_machine==1 if is_sewing_machine<.
gen cycle = is_bicycle==1 if is_bicycle<.
gen moto = is_scooter==1 if is_scooter<.
gen car = is_car==1 if is_car<.
gen tractor = is_tractor==1 if is_tractor<.
gen pump = is_water_pump==1 if is_water_pump<.

gen land = land_possessed<6 if land_possessed<.

gen od = toilet_used==0 if toilet_used<.
gen sf = (cooking_fuel>0 & cooking_fuel<6) if cooking_fuel<.

sort state district psu round
by state district psu round: egen psuod=mean(od)
by state district psu round: egen psusf=mean(sf)

pca radio tv computer landline mobile washer fridge sewing cycle moto car tractor pump ///
	[aweight=wt]
*screeplot, yline(1)
*loadingplot
*estat loadings
predict pca1, score
*estat kmo
xtile wealthpt = pca1 [aw=wt], nq(100)
rename pca1 pcashort
rename wealthpt wealthptshort

pca radio tv computer landline mobile washer fridge sewing cycle moto car tractor pump ///
	no_of_dwelling_rooms kitchen_availability house_structure ///
	[aweight=wt]
*screeplot, yline(1)
*loadingplot
*estat loadings
predict pca1, score
*estat kmo
xtile wealthpt = pca1 [aw=wt], nq(100)
rename pca1 pcalong
rename wealthpt wealthptlong
gen wealthdc=.
forvalues i=1(1)10 {
replace wealthdc=`i' if wealthptlong<=`i'0 & wealthdc==.
}

pca radio tv computer landline mobile washer fridge sewing cycle moto car tractor pump ///
	no_of_dwelling_rooms kitchen_availability house_structure ///
	if rural==0 [aweight=wt]
*screeplot, yline(1)
*loadingplot
*estat loadings
predict pca1 if rural==0, score
*estat kmo
rename pca1 pcaurban

pca radio tv computer landline mobile washer fridge sewing cycle moto car tractor pump ///
	no_of_dwelling_rooms kitchen_availability house_structure ///
	if rural==1 [aweight=wt]
*screeplot, yline(1)
*loadingplot
*estat loadings
predict pca1 if rural==1, score
*estat kmo
rename pca1 pcarural

gen occupation=occupation_status if relation_to_head==1 & died==0
gen qualification=highest_qualification if relation_to_head==1 & died==0
gen healthscheme=iscoveredbyhealthscheme if relation_to_head==1 & died==0
gen headage=age if relation_to_head==1 & died==0
gen headsex=sex if relation_to_head==1 & died==0
gen headchew=chew if relation_to_head==1 & died==0
gen headsmoke=smoke if relation_to_head==1 & died==0
gen headalcohol=alcohol if relation_to_head==1 & died==0
sort hhld_id
by hhld_id: egen hh_occupation=max(occupation) if died==0
by hhld_id: egen hh_qualification=max(qualification) if died==0
by hhld_id: egen hh_healthscheme=min(healthscheme) if died==0
by hhld_id: egen hhage=max(headage) if died==0
by hhld_id: egen hhsex=max(headsex) if died==0
by hhld_id: egen hhchew=min(headchew) if died==0
by hhld_id: egen hhsmoke=min(headsmoke) if died==0
by hhld_id: egen hhalcohol=min(headalcohol) if died==0
replace hh_occupation_status=hh_occupation if died==0
replace hh_highest_qualification=hh_qualification if died==0
replace hh_iscoveredbyhealthscheme=hh_healthscheme if died==0
replace hh_age=hhage if died==0
replace hh_sex=hhsex if died==0
replace hh_chew=hhchew if died==0
replace hh_smoke=hhsmoke if died==0
replace hh_alcohol=hhalcohol if died==0

drop occupation hh_occupation
drop qualification hh_qualification
drop healthscheme hh_healthscheme
drop headage headsex headchew headsmoke headalcohol hhage hhsex hhchew hhsmoke hhalcohol

gen wealthqt=.
forvalues i=20(20)100 {
replace wealthqt=`i'/20 if wealthptlong<=`i' & wealthqt==.
}

gen hhlit=hh_highest_qualification>0 if hh_highest_qualification<.
gen hhalc=hh_alcohol<4 if hh_alcohol<. & hh_alcohol>0
gen hhsmoke=hh_smoke<4 if hh_smoke<. & hh_smoke>0

gen psuodsplit=.
forvalues i=.25(.25)1 {
replace psuodsplit=`i'/.25 if psuod<=`i' & psuodsplit==.
}

egen cluster=group(state district psu)


*-------------------------------------------------------------------------------

* CALCULATE EXACT AGES FOR LIVE PEOPLE -----------------------------------------

* today's date
gen today = mdy(1,1,2010) if round==1
replace today = mdy(1,1,2011) if round==2
replace today = mdy(1,1,2012) if round==3
format today %td

* assign everyone a random day
* if month is blank, assign person to being born 15 Jan, 15 Feb, ... , 15 Dec.
* if year is blank, give year based on age
set seed 1294

gen newday = 1+int(28*runiform())
gen newmonth = 1 + int(12*runiform())
gen newyear = 2010-age

gen datadob = mdy(month_of_birth,newday,year_of_birth)
format datadob %td

** if month is missing
gen newdob1 = mdy(newmonth,newday,year_of_birth)
format newdob1 %td

** if year is missing
gen newdob2 = mdy(newmonth,newday,newyear)
format newdob2 %td

gen dob = datadob
replace dob = newdob1 if dob==.
replace dob = newdob2 if dob==.
format dob %td

* drop if no dob, no age
drop if dob>=. & died==0

* now construct exact age on Jan 1 2010
gen exactage = (today-dob)/365.25
drop if exactage<0
*-------------------------------------------------------------------------------

* CALCULATE EXACT AGES FOR DEAD PEOPLE -----------------------------------------

* Keep only those deaths within relevant periods
drop if year_of_death>2009 & year_of_death<. & round==1 & died==1
drop if year_of_death<2010 & round==2 & died==1
drop if year_of_death==2012 & round==3 & died==1
drop if year_of_death>=. & died==1

* Figure out age of death data. There are 0s and .s. 
gen nnm=age_of_death_below_one_month<.
gen pnm=age_of_death_below_eleven_month<.
gen cm=age_of_death_above_one_year>=1 & age_of_death_above_one_year<5
gen am=age_of_death_above_one_year>=5
replace nnm=0 if cm==1 | am==1
replace pnm=0 if cm==1 | am==1
replace nnm=0 if age_of_death_below_eleven_month>0 & age_of_death_below_eleven_month<.
replace pnm=0 if age_of_death_below_one_month>0 & age_of_death_below_one_month<.
gen sum=nnm+pnm+cm+am

* Generate age at death
gen deathage = age_of_death_below_one_month/365 if age_of_death_below_one_month<. & died==1
replace deathage = (age_of_death_below_eleven_month+runiform())/12 if age_of_death_below_eleven_month>0 & age_of_death_below_eleven_month<. & (deathage==. | deathage==0) & died==1
replace deathage = age_of_death_above_one_year+runiform() if age_of_death_above_one_year>0 & age_of_death_above_one_year<. & (deathage==. | deathage==0) & died==1

* Everyone has a death year, but need to assign random death days to people.
* If month is blank, assign person to being born on random day.

gen datadod = mdy(month_of_death,newday,year_of_death) if died==1
format datadod %td

* If day is missing but month is there
gen newdod1 = mdy(month_of_death,newday,year_of_death) if died==1
format newdod1 %td

* If month is missing
gen newdod2 = mdy(newmonth,newday,year_of_death) if died==1
format newdod2 %td

gen dod = datadod if died==1
replace dod = newdod1 if dod==. & died==1
replace dod = newdod2 if dod==. & died==1
format dod %td

* Generate date of birth
replace dob=round(dod-deathage*365) if died==1

* drop if age at death is blank or dod is blank
drop if deathage>=. & died==1
drop if dod>=. & died==1

drop today- newdob2 nnm- sum datadod- newdod2

* create age at the beginning of exposure period (1/1/2007)
gen begage=exactage-3 if died==0
replace begage=0 if begage<0 & died==0

gen start=mdy(1,1,2007)
replace begage=deathage-((dod-start)/365) if died==1
replace begage=0 if begage<0 & died==1

* create agegroups
gen agegroup=0
replace agegroup=1 if begage>=1 & begage<5 
forvalues i = 5(5)85 {
replace agegroup=`i' if begage>=`i' & begage<(`i'+5)
}
replace agegroup=85 if begage>=85

save person.dta, replace

drop begage start agegroup 
*-------------------------------------------------------------------------------

* EXPAND DATASET TO PERSON YEARS (WITH YEARS AS AGES) --------------------------

* first generate unique
gen unique=_n

*expand dataset
expand 2 if round==1, generate(exp)
gen seq=1 if round==1 & exp==0
replace seq=2 if round==1 & exp==1
drop exp
expand 2 if round==1 & seq==2, generate(exp)
replace seq=3 if round==1 & seq==2 & exp==1
drop exp
expand 2 if round==1 & seq==3, generate(exp)
replace seq=4 if round==1 & seq==3 & exp==1
drop exp
expand 2 if round==2, generate(exp)
replace seq=1 if round==2 & exp==0
replace seq=2 if round==2 & exp==1
drop exp
expand 2 if round==3, generate(exp)
replace seq=1 if round==3 & exp==0
replace seq=2 if round==3 & exp==1
drop exp

* now create age and py for each person for live people

* for round 1
gen intage1 = int(exactage) if round==1 & died==0 
gen py1 = exactage-intage1 if round==1 & died==0
gen intage2 = intage1-1 if round==1 & died==0
gen py2 = 1 if intage2>-1 & round==1 & died==0
gen intage3 = intage1 - 2 if round==1 & died==0
gen py3 = 1 if intage3>-1 & round==1 & died==0
gen exactage3 = exactage - 3 if round==1 & died==0
gen intage4 = intage1 - 3 if round==1 & died==0
gen py4 = intage3 - exactage3 if intage4>-1 & round==1 & died==0

* for rounds 2 & 3
replace intage1 = int(exactage) if (round==2 | round==3) & died==0
replace py1 = exactage-intage1 if (round==2 | round==3) & died==0
gen exactage1 = exactage - 1 if (round==2 | round==3) & died==0
replace intage2 = intage1 - 1 if (round==2 | round==3) & died==0
replace py2 = intage1 - exactage1 if intage2>-1 & (round==2 | round==3) & died==0

* make one age column, and one py column
gen intage=.
gen py=.
forvalues i=1(1)4 {
replace intage=intage`i' if seq==`i'
replace py=py`i' if seq==`i'
}

drop if intage<0 & died==0
drop intage1 intage2 intage3 intage4 py1 py2 py3 py4 exactage3 exactage1

* now create age and py for each person for dead people
gen begdate = mdy(1,1,2007) if round==1
replace begdate = mdy(1,1,2010) if round==2
replace begdate = mdy(1,1,2011) if round==3
format begdate %td
gen yrlived = (dod - begdate)/365.25 if ((dod - begdate)/365.25)<=deathage & died==1
replace yrlived = deathage if ((dod - begdate)/365.25)>deathage & died==1
gen begage = deathage-yrlived 

* for round 1
gen intage1 = int(deathage) if round==1 & died==1
gen py1 = deathage-intage1 if intage1>=begage & intage1>=0 & round==1 & died==1
replace py1 = deathage-begage if py1==. & (deathage-begage)>=0 & intage1>=0 & round==1 & died==1
gen intage2 = intage1-1 if round==1 & died==1
gen py2 = 1 if intage2>=begage & intage2>=0 & round==1 & died==1
replace py2 = intage1-begage if py2==. & (intage1-begage)>=0 & intage2>=0 & round==1 & died==1
gen intage3 = intage1 - 2 if round==1 & died==1
gen py3 = 1 if intage3>=begage & intage3>=0 & round==1 & died==1
replace py3 = intage2-begage if py3==. & (intage2-begage)>=0 & intage3>=0 & round==1 & died==1
gen intage4 = intage1 - 3 if round==1 & died==1
gen py4 = intage3-begage if (intage3-begage)>=0 & intage4>=0 & round==1 & died==1

* for rounds 2 & 3
replace intage1 = int(deathage) if (round==2 | round==3) & died==1
replace py1 = deathage-intage1 if intage1>=begage & intage1>=0 & (round==2 | round==3) & died==1
replace py1 = deathage-begage if py1==. & (deathage-begage)>=0 & intage1>=0 & (round==2 | round==3) & died==1
replace intage2 = intage1 - 1 if (round==2 | round==3) & died==1
replace py2 = intage1-begage if (intage1-begage)>=0 & intage4>=0 & (round==2 | round==3) & died==1

* make one age column, and one py column
forvalues i=1(1)4 {
replace intage=intage`i' if seq==`i' & died==1
replace py=py`i' if seq==`i' & died==1
}

*-------------------------------------------------------------------------------

* ADD SOME OTHER VARIABLES THAT WILL BE HELPFUL FOR LIFE TABLE -----------------


* make indicator for died at this age
gen death=(intage==intage1) if died==1

drop if intage<0 & died==1
drop if py==. & died==1
drop intage1 intage2 intage3 intage4 py1 py2 py3 py4
drop begdate yrlived begage

* generate age groups
gen agegroup=0
replace agegroup=1 if intage>=1 & intage<5 
forvalues i = 5(5)85 {
replace agegroup=`i' if intage>=`i' & intage<(`i'+5)
}
replace agegroup=85 if intage>=85

* for calculating person years for people who died
sort unique agegroup
by unique agegroup: egen diedingroup=total(death) if died==1
gen deadpy=py if diedingroup==1

*-------------------------------------------------------------------------------
save personyear.dta, replace