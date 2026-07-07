/*                                                          annual health survey
                                                           labelling mort module
notes:
- this nested do-file applies variable and value labels for mort_dataset      */


notes drop _all

lab def l_yesno 1 "yes" 2 "no", replace
lab def l_yesnodk 1 "yes" 2 "no" 3 "don't know", replace

lab var state "state"
lab def l_state  5 "uttarakhand" ///
                 8 "rajasthan" ///
                 9 "uttar pradesh" ///
                10 "bihar" ///
                18 "assam" ///
                20 "jharkhand" ///
                21 "odisha" ///
                22 "chhattisgarh" ///
                23 "madhya pradesh", replace
lab val state l_state
notes state: 1st component of household identifier (hhld_id)

lab var district "district"
notes district: 2nd component of household identifier (hhld_id)
notes district: codes begin with 1 for each state

lab var rural "sector"
lab def l_rural 1 "rural" ///
                2 "urban", replace
lab val rural l_rural

lab var stratum_code "stratum"
lab def l_stratum 0 "urban" ///
                  1 "rural (smaller)" ///
                  2 "rural (larger)", replace
lab val stratum l_stratum
notes stratum_code: smaller is population less than 2,000

lab var psu "primary sampling unit"
notes psu: 3rd component of household identifier (hhld_id)

lab var house_no "house number"
notes house_no: 4th component of household identifier (hhld_id)

lab var house_hold_no "household number"
notes house_hold_no: 5th and final component of household identifier (hhld_id)

lab var hhld_id "household identifier"
notes hhld_id: generated field
notes hhld_id: use for household-level merges
notes hhld_id: =state-district-psu-house_no-house_hold_no
notes hhld_id: missing if any component is missing

lab var round "interview round"
lab def l_round 1 "baseline" ///
                2 "1st update" ///
                3 "2nd update", replace
lab val round l_round
notes round: round not explicitly collected (generated from dates)

lab var m_serial_no "death index"
notes m_serial_no: "no linking capacity"

lab var deceased_sex "sex of deceased"
lab def l_sex 1 "male" ///
              2 "female", replace
lab val deceased_sex l_sex

lab var date_of_death "date of death: day"

lab var month_of_death "date of death: month"

lab var year_of_death "date of death: year"

lab var death_yrmo "date of death: year-month (sif)"
notes death_yrmo: generated field

lab var age_of_death_below_one_month "age at death: less than 1 month"
notes age_of_death_below_one_month: unit is days

lab var age_of_death_below_eleven_month "age at death: less than 1 year"
notes age_of_death_below_eleven_month: unit is completed months

lab var age_of_death_above_one_year "age at death: at least 1 year"
notes age_of_death_above_one_year: unit is completed years

lab var treatment_source "source of medical attention before death"
lab def l_treatsource  0 "no medical attention" ///
                       1 "govt: sub center" ///
                       2 "govt: phc" ///
                       3 "govt: chc" ///
                       4 "govt: uhc/uhp/ufwc" ///
                       5 "govt: dispensary/clinic" ///
                       6 "govt: hospital" ///
                       7 "govt: ayush hospital/clinic" ///
                       8 "private: dispensary/clinic" ///
                       9 "private: hospital" ///
                      10 "private: ayush hospital/clinic" ///
                      11 "ngo or trust hospital/clinic" ///
                      12 "at home" ///
                      99 "other source", replace
lab val treatment_source l_treatsource

lab var place_of_death "place of death"
lab def l_placedeath 1 "at home" ///
                     2 "in transit" ///
                     3 "in health facility" ///
                     4 "other place", replace
lab val place_of_death l_placedeath

lab var is_death_reg "is death registered?"
lab val is_death_reg l_yesnodk

lab var is_death_cert "was death certificate received?"
lab val is_death_cert l_yesno

lab var serial_num_of_inf "member (mother of infant) index"
notes serial_num_of_inf: link hhld_id-serial_num_of_infant_mother ///
                         to hhld_id-serial_no

lab var order_of_birth "birth order"

lab var death_symptoms "symptoms leading to death (infants)"
lab def l_deathsympt  1 "asphyxia" ///
                      2 "hypothermia" ///
                      3 "infections" ///
                      4 "birth injuries" ///
                      5 "convulsions soon after birth" ///
                      6 "jaundice" ///
                      7 "bleeding from umbilicus/elsewhere" ///
                      8 "congenital/birth defects" ///
                      9 "preterm birth or low birth weight" ///
                     10 "respiratory infection" ///
                     11 "diarrhoea/dysentery" ///
                     12 "fever with rash" ///
                     13 "fever with convulsions" ///
                     14 "fever with jaundice" ///
                     15 "other symptom", replace
lab val death_symptoms l_deathsympt
notes death_symptoms: codes 1-9 & 15 for nmr; codes 8-15 for pnmr

lab var is_death_assoc "was death associated with pregnancy?"
lab val is_death_assoc l_yesno
notes is_death_assoc: asked only of women age 15-49

lab var death_period "period when death occurred"
lab def l_deathper 1 "during antenatal period" ///
                   2 "during delivery" ///
                   3 "during abortion" ///
                   4 "within 42 days of delivery" ///
                   5 "after 42 days of delivery" ///
                   6 "within 42 days of abortion" ///
                   7 "after 42 days of abortion", replace
lab val death_period l_deathper

lab var months_of_pregnancy "months pregnant at death"

lab var factors_contributing_death "1st factor contributing to death"
lab def l_factordeath 1 "delay in receiving health care at facility" ///
                      2 "inadequate care at health facility" ///
                      3 "lack of support in getting to facility" ///
                      4 "lack of funds" ///
                      5 "seriousness of condition not realized" ///
                      6 "seriousness realized but no decision rendered" ///
                      7 "other factor", replace
lab val factors_contributing_death l_factordeath

lab var factors_contributing_death_2 "2nd factor contributing to death"
lab val factors_contributing_death_2 l_factordeath

lab var symptoms_of_death "symptoms leading to death (pregnancy)"
lab def l_deathsymptpreg  1 "excess bleeding" ///
                          2 "sepsis" ///
                          3 "pregnancy-induced hypertension" ///
                          4 "prolonged/obstructed labor" ///
                          5 "injury to uterus or other organ" ///
                          6 "anemia" ///
                          7 "jaundice" ///
                          8 "malaria" ///
                          9 "other medical conditions in pregnancy" ///
                         10 "conditions unrelated to pregnancy", replace
lab val symptoms_of_death l_deathsymptpreg
notes symptoms_of_death: code 10 assumed to be unrelated category instead of 0

lab var time_between "time between onset of complications and death"
lab def l_timebetween  1 "less than 2 hours" ///
                       2 "2-24 hours" ///
                       3 "24 hours - 2 days" ///
                       4 "2-7 days" ///
                       5 "7-14 days" ///
                       6 "14 days or more", replace
lab val time_between l_timebetween

lab var nearest_medical "nearest medical facility (km)"

* label variable with details of household head
lab var house_status "status of house (baseline)"
lab def l_housestatusbase 1 "residential or partly residential" ///
                          2 "non-residential" ///
                          3 "vacant" ///
                          4 "new house", replace
lab val house_status l_housestatusbase

lab var sex "sex of household head"
label define l_sex 1 "male" ///
                   2 "female", replace
lab val sex l_sex

lab var usual_residance "is household head usual resident?"
lab val usual_residance l_yesno
notes usual_residance: round 1 only
notes usual_residance: generated from residancial_status for rounds 2/3

lab var residancial_status "residential status of household head"
lab def l_residentstatus  1 "usual resident: continues in same household" ///
                          2 "usual resident: died or out-migrated" ///
                          3 "usual resident: in-migrated from outside house" ///
                          4 "usual resident: shifted household within house" ///
                          5 "usual resident: newly born" ///
                          6 "usual resident: temporary absentee" ///
                          7 "out-migrated" ///
                          8 "shifted out of household within house" ///
                          9 "died" ///
                         10 "newborn died" ///
                         11 "not usual resident", replace
lab val residancial_status l_residentstatus
notes residancial_status: rounds 2/3 only

lab var relation_to_head "relation to head of household"
lab def l_reltohead  1 "head" ///
                     2 "wife/husband" ///
                     3 "son/daughter" ///
                     4 "son/daughter in law" ///
                     5 "grandchild" ///
                     6 "parent" ///
                     7 "parent in law" ///
                     8 "brother/sister" ///
                     9 "brother/sister in law" ///
                    10 "niece/nephew" ///
                    11 "other relatives" ///
                    12 "adopted/foster child" ///
                    13 "not related", replace
lab val relation_to_head l_reltohead

lab var member_identity "household head member identifier"
notes member_identity: preferred member-level linkage
notes member_identity: link members by hhld_id-member_identity

lab var father_serial_no "member (father of household head) index"
notes father_serial_no: link hhld_id-father_serial_no to hhld_id-serial_no

lab var mother_serial_no "member (mother of household head) index"
notes mother_serial_no: link hhld_id-mother_serial_no to hhld_id-serial_no

lab var date_of_birth "household head's dob: day"

lab var month_of_birth "household head's dob: month"

lab var year_of_birth "household head's dob: year"

lab var birth_yrmo "household head's dob: year-month (sif)"
notes birth_yrmo: generated field

lab var age "household head's age"

lab var religion "household head's religion"
lab def l_religion 1 "hindu" ///
                   2 "muslim" ///
                   3 "christian" ///
                   4 "sikh" ///
                   5 "buddhist" ///
                   6 "jain" ///
                   7 "other religion" ///
                   8 "no religion", replace
lab val religion l_religion

lab var social_group_code "household head's social group"
lab def l_socialgroup 1 "sc" ///
                      2 "st" ///
                      3 "other group", replace
lab val social_group_code l_socialgroup

lab var marital_status "household head's marital status"
lab def l_maritalstat1 1 "never married" ///
                       2 "married, no gauna" ///
                       3 "married, gauna" ///
                       4 "remarried" ///
                       5 "widow/widower" ///
                       6 "divorced" ///
                       7 "separated" ///
                       8 "not stated", replace
lab val marital_status l_maritalstat1

lab var date_of_marriage "household head's date of marriage: day"

lab var month_of_marriage "household head's date of marriage: month"

lab var year_of_marriage "household head's date of marriage: year"

lab var marry_yrmo "household head's date of marriage: year-month (sif)"
notes marry_yrmo: generated field

lab var currently_attending_school "is household head currently attending school?"
lab def l_currschool 1 "yes" ///
                     2 "no, attended before" ///
                     3 "no, never attended", replace
lab val currently_attending_school l_currschool

lab var reason_for_not_attending_school "main reason for not household head attending school"
lab def l_reasonnoattend 1 "school too far" ///
                         2 "further education not considered necessary" ///
                         3 "required for family activities/farm/business" ///
                         4 "required for outside work" ///
                         5 "not interested in studies" ///
                         6 "costs too much" ///
                         7 "repeated failures" ///
                         8 "got married" ///
                         9 "other reason", replace
lab val reason_for_not_attending_school l_reasonnoattend

lab var highest_qualification "household head's highest educational qualification attained"
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
lab val highest_qualification l_highestqual
notes highest_qualification: asked only if age 7 or older

lab var occupation_status "household head's occupation/activity status during past year"
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
lab val occupation_status l_occstatus
notes occupation_status: asked only if age 5 or older

lab var disability_status "household head's disability status"
lab def l_disabilitystat 0 "no disability" ///
                         1 "mental" ///
                         2 "visual" ///
                         3 "hearing" ///
                         4 "speech" ///
                         5 "motor skills" ///
                         6 "multiple" ///
                         7 "other disability", replace
lab val disability_status l_disabilitystat
notes disability_status: other option added for rounds 2/3

lab var injury_treatment_type "household head's type of treatment for injury in past year"
lab def l_injtreattype 0 "no injury" ///
                       1 "icu" ///
                       2 "in-patient, 2 weeks or longer" ///
                       3 "in-patient, 1-2 weeks" ///
                       4 "in-patient, less than 1 week" ///
                       5 "out-patient" ///
                       6 "traditional healer" ///
                       7 "treated at home", replace
lab val injury_treatment_type l_injtreattype

lab var illness_type "household head's type of acute illness"
lab def l_illnesstype 0 "no illness" ///
                      1 "diarrhoea" ///
                      2 "dysentery" ///
                      3 "ari" ///
                      4 "jaundice with fever" ///
                      5 "fever with chills (inc. malaria)" ///
                      6 "brief fever with rash" ///
                      7 "other fevers" ///
                      8 "rti" ///
                      9 "other type ", replace
lab val illness_type l_illnesstype

lab var treatment_source "household head's source of treatment for acute illness"
lab def l_treatacuteill  0 "no illness" ///
                         1 "govt: sub center" ///
                         2 "govt: phc" ///
                         3 "govt: chc" ///
                         4 "govt: uhc/uhp/ufwc" ///
                         5 "govt: dispensary/clinic" ///
                         6 "govt: hospital" ///
                         7 "govt: ayush hospital/clinic" ///
                         8 "private: dispensary/clinic" ///
                         9 "private: hospital" ///
                        10 "private: ayush hospital/clinic" ///
                        11 "ngo or trust hospital/clinic" ///
                        13 "at home" ///
                        99 "other source", replace
lab val treatment_source l_treatacuteill

lab var symptoms_pertaining_illness "household head's symptoms from chronic illness"
lab def l_symptomschron  1 "diseases of respiratory system" ///
                         2 "diseases of cardiovascular system" ///
                         3 "diseases of nervous system" ///
                         4 "diseases of musculo-skeletal system" ///
                         5 "diseases of gastrointestinal system" ///
                         6 "diseases of genitourinary system" ///
                         7 "skin diseases" ///
                         8 "goitre" ///
                         9 "elephantiasis" ///
                        10 "eye problem/disease" ///
                        11 "ent problem/disease" ///
                        12 "mouth and dental problems" ///
                        13 "other symptom" ///
                        99 "no symptoms", replace
lab val symptoms_pertaining_illness l_symptomschron
notes symptoms_pertaining_illness: recoded to harmonize rounds

lab var sought_medical_care "has household head sought medical care for chronic illness?"
lab def l_soughtcarechron 1 "yes, details available" ///
                          2 "yes, details not available" ///
                          3 "no", replace
lab val sought_medical_care l_soughtcarechron

lab var diagnosed_for "household head's diagnosis of chronic illness"
lab def l_diagnosis  0 "not diagnosed" ///
                     1 "diabetes" ///
                     2 "hypertension" ///
                     3 "chronic heart disease" ///
                     4 "myocardial infarction (heart attack)" ///
                     5 "stroke or cerebrovascular accident" ///
                     6 "epilepsy" ///
                     7 "asthma or chronic respiratory disease" ///
                     8 "goitre or thryoid disorder" ///
                     9 "tuberculosis" ///
                    10 "leprosy" ///
                    11 "cancer, respiratory system" ///
                    12 "cancer, gastrointestinal system" ///
                    13 "cancer, genitourinary system" ///
                    14 "cancer, breast" ///
                    15 "renal stone" ///
                    16 "chronic renal disease" ///
                    17 "gall stone or cholecystitis" ///
                    18 "chronic liver disease" ///
                    19 "rheumatoid/osteo arthritis" ///
                    20 "chronic skin disease or psoriasis" ///
                    21 "cataract" ///
                    22 "glaucoma" ///
                    23 "sinusitis or tonsilitis" ///
                    24 "fluorosis" ///
                    25 "pyorrhea" ///
                    26 "rheumatic fever/disease" ///
                    27 "tumor" ///
                    28 "leukemia (blood cancer)" ///
                    29 "skin cancer" ///
                    30 "piles or anal fissure/fistula" ///
                    31 "anaemia" ///
                    99 "other diagnosis", replace
lab val diagnosed_for l_diagnosis
notes diagnosed_for: recoded to harmonize rounds

lab var diagnosis_source "source of diagnosis for household head's chronic illness"
lab def l_diagchronill  0 "no source" ///
                        1 "govt: sub center" ///
                        2 "govt: phc" ///
                        3 "govt: chc" ///
                        4 "govt: uhc/uhp/ufwc" ///
                        5 "govt: dispensary/clinic" ///
                        6 "govt: hospital" ///
                        7 "govt: ayush hospital/clinic" ///
                        8 "private: dispensary/clinic" ///
                        9 "private: hospital" ///
                       10 "private: ayush hospital/clinic" ///
                       11 "ngo or trust hospital/clinic" ///
                       13 "at home" ///
                       99 "other source", replace
lab val diagnosis_source l_diagchronill

lab var regular_treatment "is household head getting treatment for chronic illness?"
lab def l_regulartreat 1 "yes, not regularly" ///
                       2 "yes, regularly" ///
                       3 "no", replace
lab val regular_treatment l_regulartreat

lab var regular_treatment_source "source of treatment for household head's chronic illness"
lab def l_treatchronill  0 "no treatment" ///
                         1 "govt: sub center" ///
                         2 "govt: phc" ///
                         3 "govt: chc" ///
                         4 "govt: uhc/uhp/ufwc" ///
                         5 "govt: dispensary/clinic" ///
                         6 "govt: hospital" ///
                         7 "govt: ayush hospital/clinic" ///
                         8 "private: dispensary/clinic" ///
                         9 "private: hospital" ///
                        10 "private: ayush hospital/clinic" ///
                        11 "ngo or trust hospital/clinic" ///
                        12 "dot center" ///
                        13 "at home" ///
                        99 "other treatment", replace
lab val regular_treatment_source l_treatchronill

lab var chew "household head's habits: chew?"
lab def l_chew 0 "not known" ///
               1 "pan with tobacco" ///
               2 "pan without tobacco" ///
               3 "gutka or pan masala with tobacco" ///
               4 "gutka or pan masala without tobacco" ///
               5 "tobacco only" ///
               6 "ex-chewer" ///
               7 "never chewed", replace
lab val chew l_chew
notes chew: round 1 only
notes chew: auto-populated for rounds 2/3

lab var smoke "household head's habits: smoke?"
lab def l_smoke 0 "not known" ///
                1 "usual smoker" ///
                2 "occassional smoker" ///
                3 "ex-smoker" ///
                4 "never smoked", replace
lab val smoke l_smoke
notes smoke: round 1 only
notes smoke: auto-populated for rounds 2/3

lab var alcohol "household head's habits: drink?"
lab def l_alcohol 0 "not known" ///
                  1 "usual drinker" ///
                  2 "occassional drinker" ///
                  3 "ex-drinker" ///
                  4 "never drank", replace
lab val alcohol l_alcohol
notes alcohol: round 1 only
notes alcohol: auto-populated for rounds 2/3

lab var house_structure "type of house structure where household lives"
lab def l_housestructure 1 "pucca" ///
                         2 "semi-pucca" ///
                         3 "kuccha" ///
                         4 "other", replace
lab val house_structure l_housestructure

lab var owner_status "ownership of house structure where household lives"
lab def l_ownerstatus 1 "owned" ///
                      2 "rented" ///
                      3 "other arrangement", replace
lab val owner_status l_ownerstatus

lab var drinking_water_source "household's drinking water source"
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

lab var water_filteration "how is household's water treated?"
lab def l_waterfilter 1 "boil" ///
                      2 "bleach/chlorine tablets" ///
                      3 "aluminum sulfate (alum)" ///
                      4 "strain through cloth" ///
                      5 "water filters (ceramics, sand, etc.)" ///
                      6 "electronic filters (ro, uv, etc.)" ///
                      7 "let it stand and settle" ///
                      8 "other treatment", replace
lab val water_filteration l_waterfilter

lab var toilet_used "type of toilet facility household primarily uses"
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

lab var is_toilet_shared "is household's toilet shared?"
lab val is_toilet_shared l_yesno

lab var household_have_electricity "does household have electricity?"
lab val household_have_electricity l_yesno

lab var lighting_source "household's main source of lighting"
lab def l_lightsource 1 "electricity" ///
                      2 "kerosene" ///
                      3 "solar" ///
                      4 "other oils" ///
                      5 "other source" ///
                      6 "no lighting", replace
lab val lighting_source l_lightsource

lab var cooking_fuel "household's main source of fuel for cooking"
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

lab var kitchen_availability "household's availability of kitchen"
lab def l_kitchavail 1 "cooking inside house: has kitchen" ///
                     2 "cooking inside house: no kitchen" ///
                     3 "cooking outside house: has kitchen" ///
                     4 "cooking outside house: no kitchen" ///
                     5 "no cooking", replace
lab val kitchen_availability l_kitchavail

lab var is_radio "household assets: radio?"
lab val is_radio l_yesno

lab var is_television "household assets: television?"
lab val is_television l_yesno

lab var is_computer "household assets: computer?"
lab def l_computer 1 "yes, with internet" ///
                   2 "yes, without internet" ///
                   3 "no", replace
lab val is_computer l_computer

lab var is_telephone "household assets: telephone/mobile?"
lab def l_telephone 1 "telephone only" ///
                    2 "mobile phone only" ///
                    3 "both" ///
                    4 "neither", replace
lab val is_telephone l_telephone

lab var is_washing_machine "household assets: washing machine?"
lab val is_washing_machine l_yesno

lab var is_refrigerator "household assets: refrigerator?"
lab val is_refrigerator l_yesno

lab var is_sewing_machine "household assets: sewing machine?"
lab val is_sewing_machine l_yesno

lab var is_bicycle "household assets: bicycle?"
lab val is_bicycle l_yesno

lab var is_scooter "household assets: scooter?"
lab val is_scooter l_yesno

lab var is_car "household assets: car?"
lab val is_car l_yesno

lab var is_tractor "household assets: tractor?"
lab val is_tractor l_yesno

lab var is_water_pump "household assets: water pump?"
lab val is_water_pump l_yesno

lab var cart "household assets: type of cart"
lab def l_cart 1 "animal-driven" ///
               2 "machine-driven" ///
               3 "other type" ///
               4 "no cart", replace
lab val cart l_cart

lab var land_possessed "household assets: land possessed"
lab def l_landposs 1 "less than 0.02 ha" ///
                   2 "0.02-1.00 ha" ///
                   3 "1.00-4.00 ha" ///
                   4 "4.00-10.00 ha" ///
                   5 "10.00 or more ha" ///
                   6 "no land", replace
lab val land l_landposs

lab var as "household asset score"
notes as: summary of asset questions
notes as: derived from pca (see users guide)

lab var iscoveredbyhealthscheme "household covered by any health scheme/insurance?"
lab val iscoveredbyhealthscheme l_yesnodk
notes iscoveredbyhealthscheme: rounds 2/3 only

lab var healthscheme_1 "household health scheme/insurance (1st priority)"
lab def l_healthscheme 1 "esis" ///
                       2 "rsby" ///
                       3 "govt schemes other than rsby" ///
                       4 "medical reimbursement from employer" ///
                       5 "community health insurance program" ///
                       6 "mediclaim" ///
                       7 "other scheme", replace
lab val healthscheme_1 l_healthscheme
notes healthscheme_1: rounds 2/3 only

lab var healthscheme_2 "household health scheme/insurance (2nd priority)"
lab val healthscheme_2 l_healthscheme
notes healthscheme_2: rounds 2/3 only

lab var housestatus "status of house (updates)"
lab def l_housestatusupdt 0 "no longer exists" ///
                          1 "residential or partly residential" ///
                          2 "non-residential" ///
                          3 "vacant", replace
lab val housestatus l_housestatusupdt
notes housestatus: rounds 2/3 only

lab var householdstatus "status of household (updates)"
lab def l_hhldstatus 1 "household continues in the same house" ///
                     2 "out-migrated (out of the house)" ///
                     3 "shifted within the house" ///
                     4 "in-migrated (from outside the house)" ///
                     5 "split household" ///
                     6 "merged household", replace
lab val householdstatus l_hhldstatus
notes householdstatus: rounds 2/3 only

lab var isheadchanged "did head of household change? (updates)"
lab val isheadchanged l_yesno
notes isheadchanged: rounds 2/3 only

lab var wt "survey weight of household head"
notes wt: weight determined by state and sector
notes wt: consult users guide for weighting methodology
