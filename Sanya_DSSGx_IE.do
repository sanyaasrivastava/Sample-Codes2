/*******************************
*Author : Sanya Srivastava 
*Contact :sanya.srivastava@sociometrik.org
*Date: 14 September 2021
*Description: GE Chhaa Jhaa Endline Analysis 
Targets of the Code 
1. Input 
2. Weighting 
3. Tabulations
4. Analysis (Probit Regression)
*******************************/

/******************************
Table of contents: 
Section 1: Import Endline data & Data Cleaning
Section 2: Tabulations
Section 3: Computation of Outcome and Control vars (Endline)
Section 4: Cross Tabulations (Endline)
Section 5: Import Baseline and data cleaning
Section 6: Computation of Outcome and Control vars (Baseline) & Append with Endline
Section 7: Probit Regression (w and w/o controls at 90%)
Section 8: Import Midline data & Data Cleaning
Section 9: Computation of Outcome and Control vars (Midline) & Append with Endline
Section 10: Probit Regression (w and w/o controls at 90%); export graph commands have been commented out
Section 11: Sample Balance Test
Section 12: Subgroup Analysis at Endline (Heard of Chhaa Jaa)
*******************************/

***************************************************************************************************************************************************************************************************************************
***************************************************************************************************************************************************************************************************************************
clear all
set more off
set matsize 800
macro drop _all
graph drop _all
set emptycells drop
*Install user written package for tabs
*ssc install fre
set scheme idinsight_csf
//set trace on 

local inpath "C:\Users\sanya\OneDrive\Desktop\GE_Endline\Input\"
local outpath "C:\Users\sanya\OneDrive\Desktop\GE_Endline\Output\"

**********************************************************************************************************************************************************************************************
*********************************************************************************************************************************************************************************************
clear
***Section 1 : Data Cleaning
import delimited "`inpath'GE_endline.csv" , clear

*Vars- 449 Obs- 1993

******************  Tarul's Cleaning Codes*******************************************************
*date
split starttime , p(",")
split submissiondate , p(",")

drop if duration== . 
*1 obs
drop if starttime1 == "Jul 29" | starttime1 == "Jul 30" | starttime1 == "Aug 6" | starttime1 == "Aug 7" | starttime1 == "Aug 30" | key == ""
drop if submissiondate1 == "Jul 29" | submissiondate1 == "Jul 30" | submissiondate1 == "Aug 6" | submissiondate1 == "Aug 7" | submissiondate1 == "Aug 30" | key == "" 
*52 obs

destring observer , replace 
label define supervisor 1	"Mr. Nand Kumar Gupta" 2	"Ms. Poonam Sonvani" 3	"Ms. Avartika Srivastava" 4	"Ms. Pooja" 5	"Ms. Anjani Savita" 6	"Ms. Pooja Yadav" 7	"Ms. Sunita Giri" 8	"Ms .Suman dixit" 9	"Ms.Sunaina Singh" 10	"Ms. Anita devi" 11	"Ms.Neha Gupta" 12	"Ms Sangeeta" 13	"Ms Sayogita" 14	"Ms. Mamta Mathur" 15	"Ms. Arti Singh" 16	"Ms. Kavita" 17	"Ms, Kumari Veena" 18	"Ms. Khushi" 19	"Ms. Seema Shukla" 20	"Ms Reetika Patel" 21	"Ms Renuka" 22	"Ms. Deepti Rana" 23	"Ms. Ruby" 24	"Ms. Deepa Solanki" 25	"Mr. Vikas singh" 26	"Mr. Arvind kumar"
label value observer supervisor 

label define block 1 "JN-1" 2	"AK-2" 3	"KN-3" 4	"GG-4" 5	"NK-5" 6	"SK-6" 7	"BB-7" 8	"SN-8" 9	"GK-9" 10	"MS-10" 11	"JG-11" 12	"AR-12" 13	"JD-13" 14	"MD-14" 15	"RN-15" 16	"BN-16" 17	"MN-17" 18	"CB-18" 19	"BK-19" 20	"BJ-20" 21	"HD-21" 22	"HK-22" 23	"JK-23" 24	"SV-24" 25	"SN-25" 26	"NR-26" 27	"BN-27" 28	"KR-28" 29	"CB-29" 30	"HR-30" 31	"RB-31" 32	"GP-32" 33	"SB-33" 34	"GB-34" 35	"NN-35" 36	"JN-36" 37	"KK-37" 38	"MG-38" 39	"AN-39" 40	"BP-40" 41	"SC-41" 42	"RR-42" 43	"MP-43" 44	"NK-44" 45	"TN-45" 46	"MM-46" 47	"SN-47" 48	"GG-48" 49	"IT-49" 50	"MD-50"
label value psucode block 

*cleaning of some mismatched PSU codes 
replace psucode = 1 if psucode == 36 & observer == 8 & starttime1 == "Aug 8" 
replace psucode = 29 if psucode == 18 & observer == 19 & starttime1 == "Aug 14" 
replace psucode = 29 if psucode == 18 & observer == 20 & starttime1 == "Aug 14" 

replace psucode = 42 if psucode == 14 & observer == 8 & starttime1 == "Aug 14" 
replace psucode = 42 if psucode == 14 & observer == 23 & starttime1 == "Aug 14" 


keep if q4_consent_yesno == 1

gen totalCount = 1
gen consent = 1 if q4_consent_yesno == 1

drop if q610a_facebook == .

*drop forms whihc have a duration of less than 10 minutes
replace duration=(duration/60)
drop if duration < 10 

*average household expenditure 
sum qvi_household_exp if qvi_household_exp > 25
replace qvi_household_exp = 1583 if qvi_household_exp < 26 

*number of members in the family 
sum q109_fam_members_number if q109_fam_members_number < 25 
replace q109_fam_members_number = 6 if q109_fam_members_number == 15000

*section 2: private part problem - replacing husband from others to it's actual option 13 
replace q201_pvt_part_problem_13 = 1 if q201_pvt_part_problem_other == "Boyfriend" |q201_pvt_part_problem_other == "Husband" | q201_pvt_part_problem_other == "Hasband" | q201_pvt_part_problem_other == "Pati"
replace q201_pvt_part_problem_88 = 0 if q201_pvt_part_problem_other == "Boyfriend" |q201_pvt_part_problem_other == "Husband" | q201_pvt_part_problem_other == "Hasband" | q201_pvt_part_problem_other == "Pati"
replace q201_pvt_part_problem_other = "" if q201_pvt_part_problem_88 == 0

*section 2: marriage problems - replace husband from others to it's actual option 8 
replace q203_marriage_problems_88 = 2 if q203_marriage_problems_other == "Bhabhi" | q203_marriage_problems_other ==  "Bhabhi ko" | q203_marriage_problems_other == "Nani"
replace q203_marriage_problems_8 = 1 if q203_marriage_problems_88 == 1 
replace q203_marriage_problems_88 = 0 if q203_marriage_problems_88 == 1 
replace q203_marriage_problems_88 = 1 if q203_marriage_problems_88 == 2 
replace q203_marriage_problems_other = "" if q203_marriage_problems_88 == 0 

*section 2 : number of friends 
replace q204_friends_number = 2 if number_friends == 0 
replace number_friends = . if number_friends == 0 

*Section 3 : discussed contraception with whom 
replace q314_with_whom_discussed_17 = 1 if q314_with_whom_discussed_88 == 1 & q314_with_whom_discussed_other != "Bhabhi"
replace q314_with_whom_discussed_88 = 0 if q314_with_whom_discussed_88 == 1 & q314_with_whom_discussed_other != "Bhabhi"
replace q314_with_whom_discussed_other = "" if q314_with_whom_discussed_88 == 0 

*section 3 : generated a new variable for adult information source 
rename q329_adult_info_source_88 (q329_adult_info_source_24)
drop q329_adult_info_source_other

*section 3 : age for sex education 
replace age = 0 if age == 2 | age == 173 | age == 15000 
sum age 
replace age = 16 if age == 0 

*section 3 : best mechanism to recieve information on sex education - adding a variable for FAMILY
gen q332_best_mechanism_7 = 0 if q330_sex_edu_opinion == 1 
replace q332_best_mechanism_7 = 1 if q332_best_mechanism_88 == 1 
replace q332_best_mechanism_7 = 0 if q332_best_mechanism_other == "AWC" | q332_best_mechanism_other == "Boyfriend" | q332_best_mechanism_other == "Couching me" | ///
q332_best_mechanism_other == "Dost" | q332_best_mechanism_other == "friend" | q332_best_mechanism_other == "Friends"
replace q332_best_mechanism_88 = 0 if q332_best_mechanism_7 == 1 
replace q332_best_mechanism_other = "" if q332_best_mechanism_88 == 0 

*section 5 : *504- reason for no treatment: adding a variable for "IT WAS NOT SEVERE/MANAGEABLE AT HOME" 
gen q404_reason_no_treatment_7 = 0 if q502_treatment == 2 
replace q404_reason_no_treatment_7 = 1 if q404_reason_no_treatment_88 == 1 
replace q404_reason_no_treatment_7 = 0 if q504_barriers_access_services_ot == "Time nahi milta" | q504_barriers_access_services_ot == "Time nhi milta"
replace q404_reason_no_treatment_88 = 0 if q404_reason_no_treatment_7 == 1 
replace q504_barriers_access_services_ot = "" if q404_reason_no_treatment_88 == 0 

*section 5 : *507- consider v334(other) as "IT WAS NOT SEVERE/MANAGEABLE AT HOME"  

drop q407_other 

*section 5 : *511- reason for no treatment - adding a variable for "IT WAS NOT SEVERE/MANAGEABLE AT HOME" 

gen q411_reason_for_not_accessing_7 = 0 if q409_sought_treatment_six_months == 2 
replace q411_reason_for_not_accessing_7 = 1 if q411_reason_for_not_accessing_88 == 1 
replace q411_reason_for_not_accessing_7 = 0 if q411_other == "Time nahi milta" | q411_other == "Maine Mummy Ko bataya nhi" 
replace q411_reason_for_not_accessing_88 = 0 if q411_reason_for_not_accessing_7 == 1 
replace q411_other = "" if q411_reason_for_not_accessing_88 == 0

*section 5 : *514- reason for no treatment- adding a vaiable for "IT WAS NOT SEVERE/MANAGEABLE AT HOME"  

gen q414_no_treatment_reason_7 = 0 if q412_future_period_problem == 2 
replace q414_no_treatment_reason_7 = 1 if q414_no_treatment_reason_88 == 1 
replace q414_no_treatment_reason_7 = 0 if q414_other == "Pta nhi"
replace q414_no_treatment_reason_88 = 0 if q414_no_treatment_reason_7 == 1 
replace q414_other = "" if q414_no_treatment_reason_88 == 0 


*section 5 : *528- reason for no treatment - adding a vaiable for "IT WAS NOT SEVERE/MANAGEABLE AT HOME"  

gen v428 = 0 if q423_future_sex_problem == 2 | q423_future_sex_problem == 99 
replace v428 = 1 if v427 == 1 
replace v428 = 0 if q425_other == "Pta nhi" | q425_other == "Sarm mahsoos hogi"
replace v427 = 0 if v428 == 1 
replace q425_other = "" if v427 == 0 

count
*1787 (Should be 1788 as per Tarul's email) 
**************************************** FIN*****************************************************************************************************************************************
*** Screening Question***
keep if qii_age_last_bday>17 & qii_age_last_bday<=21
*45 obs 
keep if qiii_respondnet_sex ==1
*1 obs 
keep if qiv_study_status==1 | qv_intend_to==1
*0 obs 
keep if resp_phone==1 |  resp_internet==1
*0 obs 

count
* 1,741
rename psucode block_code
/*
drop submissiondate starttime endtime deviceid subscriberid ///
simid device phonenum username duration caseid
*/

* Endline Time Period Dummy 
gen timePd = 1

*Weighting
bys block_code: gen totalHouseholds = _N
hist totalHouseholds, percent kden
tab totalHouseholds, m
* 24 blocks have 34; 12 have 35; 2 for 36,37,38 and 39; 3 for 40; 2 for 42; 1 for 57 (50 blocks in total)
** Basically everywhere its either equal to ot more than the required number
gen weightBlock = (34/totalHouseholds)
gen weightBlockRound = round((weightBlock*100),1)

drop submissiondate starttime endtime deviceid subscriberid simid devicephonenum ///
username duration caseid q4_consent_yesno q5_refusal_reason q5_refusal_reason_other /// 
observer locationlatitude phone locationlongitude locationaltitude locationaccuracy ///
q3_start_time resp_name instanceid formdef_version key starttime1 starttime2 /// 
submissiondate* totalCount consent

**********************************************************************************************************************************************************************************************
*********************************************************************************************************************************************************************************************

*** Section 2 : Tabulations 
*Age (18-21)
fre qii_age_last_bday [aw=weightBlock]
*Sex
fre qiii_respondnet_sex [aw=weightBlock]
*Currently studying or not
fre qiv_study_status [aw=weightBlock]
*Intend to study or not
fre qv_intend_to [aw=weightBlock]
*Household Expenses 
fre qvi_household_exp [aw=weightBlock]
drop if qvi_household_exp==-15000
gen hhs_income = 1 if qvi_household_exp < 10000
replace hhs_income = 2 if qvi_household_exp >= 10000 & qvi_household_exp < 30000
replace hhs_income = 3 if qvi_household_exp >= 30000
label define income 1 "<10000" 2 "10000-less than 30000" 3 "Greater than 30000"
label value hhs_income income
tab hhs_income [aw=weightBlock], m
*Do you own/ have access to a mobile phone/Smartphone?
fre resp_phone [aw=weightBlock]
*Do you have access to or use the internet? 
fre resp_internet [aw=weightBlock]

gen fam_member = 1 if q109_fam_members_number <6
replace fam_member = 2 if q109_fam_members_number>= 6 & qvi_household_exp < 16
replace fam_member = 3 if q109_fam_members_number >= 16
tab fam_member [aw=weightBlock], m


/*
RESPONDENT AND HOUSEHOLD CHARACTERISTICS 
101. Are you currently married?
101a. If no, are you currently in a relationship or dating anyone?
101b. How long have you been in the most recent relationship or dating?
102. Are you currently studying
102a. If yes, what are you currently studying
102b. If not studying, what is highest level of education you have completed?
103. If not studying, are you currently employed? 
104. What is your religion? 
105. Do you belong to general caste or a scheduled caste, a scheduled tribe, other backward class, or none of these? 
106. Is Jaipur your native city?  
107. Do you live with your immediate family in Jaipur?
108. With whom do you live in Jaipur?
109. How many members are there in your family? 
110. Are you the only child of your parents?
111. How many siblings do you have? 
*/

foreach v of varlist q101_marriage_status q101a_relationship_status ///
q101b_relationship_duration q102_study_yesorno q102a_study_what ///
q102a_study_what_other q102b_education_level q102b_education_level_other ///
q103_employment_status q103_employment_status_other q104_religion ///
q104_religion_other q105_scstobc q106_native_city q107_live_immediate_fam ///
q108_live_withwhom q108_live_withwhom_other q109_fam_members_number ///
q110_only_child q111a_siblings1 q111b_siblings2 q111c_siblings3 ///
q111d_siblings4 q111e_siblings5 q111f_siblings_others {
	fre `v' [aw=weightBlock]
}
* 201: Suppose you have a menstrual health-related issue or a problem in your private parts, or reproductive health issue who are you most likely to talk to about this?
fre q201_pvt_part_problem [aw=weightBlock]
foreach v of varlist q201_pvt_part_problem_* {
	fre `v'[aw=weightBlock]
}
*202: If unmarried, if you are in a relationship, who are you most likely to talk about your relationship
fre q202_talk_relationship [aw=weightBlock]
foreach v of varlist q202_talk_relationship_* {
	fre `v'[aw=weightBlock]
}
*203:If married, are you most likely to talk to about a problem in your married life
fre q203_marriage_problems [aw=weightBlock]
foreach v of varlist q203_marriage_problems_* {
	fre `v'[aw=weightBlock]
}
*204-How many closest friends do you have
fre q204_friends_number [aw=weightBlock]
fre number_friends [aw=weightBlock]
*205: How often do you meet and spend time with your closest friends? Would you say never, sometimes or often?
fre q205_spend_time [aw=weightBlock]

*206. Where do you usually meet them? 
foreach v of varlist q206_where_meet q206_where_meet_* {
	fre `v'[aw=weightBlock]
}
*207. In the last 3 months have you spoken to your friends about the following topics
*A. Relationship(s) and sex
*B. Using contraception or avoiding pregnancy
*C. Sexually transmitted infection (STI)
*D. HIV Infection
foreach v of varlist q207 q207a_relationships q207b_contraception_use ///
q207c_sti q207d_hiv {
	fre `v'[aw=weightBlock]
}
*208. Have you spoken to your partner  about the following 
*A. Future of your relationship
*B. Using contraception or avoiding pregnancy
*C. Sexually transmitted infection (STI)
*D. HIV Infection
foreach v of varlist q208 q208a_future_relationship q208b_contraception_use ///
q208c_sti q208d_hiv {
	fre `v'[aw=weightBlock]
}
drop text01
*AWARENESS OF SEXUAL & REPRODUCTIVE MATTERS 
*301. A woman can get pregnant on the very first time she has sexual intercourse
*302. A woman is most likely to get pregnant if she has sexual intercourse halfway between her periods
*303. When a woman has intercourse for the first time, she has to bleed
*304. Pregnancy can occur after kissing or hugging
*305. To avoid pregnancy, a man can withdraw just before climax
foreach v of varlist q301_preg_first_time_sex q302_sex_between_periods_preg ///
q305_climax_withdraw  {
	fre `v'[aw=weightBlock]
}
*306a. Oral Pills- A woman can swallow oral pills to prevent pregnancy.
*306b. How often should a woman take oral pills?
*307a. Emergency contraceptive pills- A woman can consume pills after she has unprotected sexual intercourse in order to prevent pregnancy. 
*307b. How soon after sexual intercourse should these pills be taken?
*308a. Condom- A man can put a rubber sheath on his penis before sexual intercourse, which is called condom. 
*309a. IUD (Clue: CuT- a device which can be put inside a woman to avoid pregnancy)
*309b. Where is the IUD placed?
foreach v of varlist q306c_oralpill_prompt q306c_knowledge q306c_oralpill_other /// 
q307c_ecp_prompt q307c_knowledge q307c_ecp_other  q308c_condom_prompt q308c_knowledge ///
q308c_condom_other q309c_iud_prompt q309c_knowledge q309b_iud_other {
	fre `v'[aw=weightBlock]
}
*310. Other methods - There are other methods of contraception that have not been mentioned so far. Which other methods have you heard of?
foreach v of varlist q310_other_contraceptive q310_other_contraceptive_*{
	fre `v'[aw=weightBlock]
}

*311. Who/what are your sources of information on contraception? 
foreach v of varlist q311_info_source q311_info_source_* {
	fre `v'[aw=weightBlock]
}
*312. People have different opinions about condoms. I will read out some opinions. For each one, I want you to tell me whether you agree or disagree.
*A. Condom is a suitable method for preventing pregnancy
*B. Condoms reduce sexual pleasure
*C. Condom can slip off the man and disappear inside the woman’s body 
*D. Condoms can be used more than once 
*E. Condoms are an effective way of protecting against HIV/AIDS
foreach v of varlist q312_condom_opinion q312a_suitable_method ///
q312b_reduced_sexual_pleasure q312c_condom_can_slipoff ///
q312d_used_more_than_once q312e_effective_protection_hiv {
	fre `v'[aw=weightBlock]
}
*313. Have you ever discussed contraception with anyone?
*314. With whom have you discussed contraception? 
foreach v of varlist q313_contraceptive_discussion ///
q314_with_whom_discussed q314_with_whom_discussed_* {
	fre `v'[aw=weightBlock]
}
*315. Is it possible to do a medical test to know the sex of the baby before the baby is born?
*316. Knowledge about abortion: Now I would like to ask you a few questions about abortion. Please answer following:
*A. Is it legal for a married woman to terminate a pregnancy?
*B. Is it legal for an unmarried girl to get the pregnancy terminated if she becomes pregnant?
*C. Is it legal to have the pregnancy terminated if the foetus is female but couple want a son?
*D. Are there any pills that a woman can swallow soon after she misses her periods, for an abortion if she wants to terminate a pregnancy?
foreach v of varlist q315_sex_determination q316_abortion q316a_abortion_legal ///
q316b_unmarried_abortion_legal /// 
q316c_want_son q316d_abortion_pills {
	fre `v'[aw=weightBlock]
}
*317. Have you heard of HIV/AIDS?
*318. Can people reduce their chances of getting the AIDS virus by having just one sex partner?
*319. Can people get the AIDS virus from mosquito bites?
*320. Can people reduce their chances of getting the AIDS virus by using a condom every time they have sex?
*321. Can people get the AIDS virus by sharing food with a person who has AIDS?
*322. Can people get the AIDS virus by hugging someone who has AIDS?
*323. Can you tell by looking at a person whether s/he has HIV?
*324. Should a boy be tested for HIV before he gets married?
*325. Should a girl be tested for HIV before she gets married?
*326. I do not want to know the results, but, have you ever had an HIV test done?
*327. Apart from HIV/AIDS, have you heard about any infections that people can get from sexual contacts?
fre hiv_questions
drop hiv_questions
foreach v of varlist q317_heard_of_hiv q318_reduce_chance_hiv_one_partn ///
q319_hiv_from_mosquito q320_reduce_chance_condom ///
q321_hiv_from_food q322_hiv_from_hug q323_hiv_identification_by_looki ///
q324_hiv_test_before_marriage_bo q325_hiv_test_before_marriage_gi ///
q326_your_hiv_test q327_other_sti {
	fre `v'[aw=weightBlock]
}
*328. Can you describe any symptoms of infections that people can get from sexual contacts? 
foreach v of varlist q328_infection_symptoms_sex q328_infection_symptoms_sex_* {
	fre `v'[aw=weightBlock]
}
*329. Adult people get information about sexual and reproductive health matters from many sources. What are your sources of information?
*330. Do you think it is important for young people to receive family life education or sex education, i.e., about their bodies, growing up, male-female relationship and sexual matters?foreach v of varlist q329_adult_info_source q329_adult_info_source_1 ///
*331. From what age do you think young people should receive family life/sex education?
foreach v of varlist q329_adult_info_source q329_adult_info_source_* ///
q330_sex_edu_opinion q331_sed_edu_what_age {
	fre `v'[aw=weightBlock]
}
*Age at education (ASK WHAT THIS IS)
fre age 
*drop age

*332. In your view, what is the best mechanism to provide this information   
foreach v of varlist q332_best_mechanism q332_best_mechanism_* {
	fre `v'[aw=weightBlock]
}
*333. Have you ever received any family life/ sex education?
*334. Where did you receive that? 
foreach v of varlist q333_recieved_any_sex_edu q334_source q334_source_* {
	fre `v'[aw=weightBlock]
}
foreach v of varlist q401_opinion q401a_only_boy_decide q401b_no_contraception_sex ///
q401c_promiscuity q401d_couples_talk_contraceptive q401e_girl_buys_condom ///
q401f_girl_talk_sex q401g_girl_male_friend q401h_girl_decide_marriage {
	fre `v'[aw=weightBlock]
}
foreach v of varlist q501_symptoms q501a_genital_itching q501b_dysuria /// 
q501c_white_urethral_discharge {
	fre `v'[aw=weightBlock]
}
foreach v of varlist q502_treatment q503_treatment_where q503_treatment_where_other {
	fre `v'[aw=weightBlock]
}
foreach v of varlist q503_treatment_where q503_treatment_where_other {
    fre `v'[aw=weightBlock]
}
foreach v of varlist q404_reason_no_treatment q404_reason_no_treatment_* {
    fre `v'[aw=weightBlock]
}
foreach v of varlist q405_future_problem_private_part ///
q406_treatment_location_future q406_other {
    fre `v'[aw=weightBlock]
}
rename q407_reason_no_treatment_future_  q407_1
rename v329 q407_2
rename v330 q407_3
rename v331 q407_4
rename v332 q407_5
rename v333 q407_6
rename v334 q407_88

foreach v of varlist q407_reason_no_treatment_future q407_* {
    fre `v'[aw=weightBlock]
}
foreach v of varlist q408_period_related_concern ///
q409_sought_treatment_six_months q410_treatment_where_six_months q410_other {
    fre `v'[aw=weightBlock]
}
foreach v of varlist q411_reason_for_not_accessing ///
q411_reason_for_not_accessing_* {
    fre `v'[aw=weightBlock]
}
foreach v of varlist q412_future_period_problem q413_period_treatment_where ///
q413_other  {
    fre `v'[aw=weightBlock]
}
foreach v of varlist q414_no_treatment_reason q414_no_treatment_reason_* {
    fre `v'[aw=weightBlock]
}
foreach v of varlist q505_shy_doctor q506_shy_chemist q507_last_sex  {
    fre `v'[aw=weightBlock]
}
foreach v of varlist q508_preg_avoid_method q508_preg_avoid_method_* {
    fre `v'[aw=weightBlock]
}
foreach v of varlist q509_who_purchased q509_who_purchased_other ///
q417_problem_after_sex q418_any_treatment q419_treatment_location_for_sex_ ///
q419_other  {
    fre `v'[aw=weightBlock]
}
foreach v of varlist q420_reason_for_no_treatment q420_reason_for_no_treatment_* {
    fre `v'[aw=weightBlock]
}
foreach v of varlist q510_next_sex_contraceptives q511_what_method q511_what_method_* {
    fre `v'[aw=weightBlock]
}
*rename v428
foreach v of varlist q423_future_sex_problem q424_treatment_location_for_futu ///
q424_other {
    fre `v'[aw=weightBlock]
}
rename v421 q425_1
rename v422 q425_2
rename v423 q425_3
rename v424 q425_4
rename v425 q425_5
rename v426 q425_6
rename v428 q425_7
rename v427 q425_88

foreach v of varlist q425_reason_for_no_future_treatm q425_* {
    fre `v'[aw=weightBlock]
}
foreach v of varlist q610_active_account q609_social_media q610a_facebook q610b_yt ///
q610c_whatsapp q610d_snapchat q610e_snarechat q610f_musically ///
q610g_insta q610i_hike q610j_others   {
    fre `v'[aw=weightBlock]
}
foreach v of varlist q611_chaa_ja q612_any_episode q613_which_platform ///
q613_which_platform_other q504_chaa_jaa_chat q614_mtv_nishedh q615_any_episode {
    fre `v'[aw=weightBlock]
}
**Knowledge of 3 contraceptives (Binary/ Spont + Prompt)
*Heard about OCPs - Spont (==1) and Pompt(==2)/Binary
gen heard_oral = 1 if q306c_oralpill_prompt == 1 | q306c_oralpill_prompt == 2
replace heard_oral = 0 if q306c_oralpill_prompt == 3
fre heard_oral [aw=weightBlock]

*Heard about ECPs - Spont (==1) and Pompt(==2)/Binary
gen heard_ecp = 1 if q307c_ecp_prompt  == 1 | q307c_ecp_prompt  == 2
replace heard_ecp = 0 if q307c_ecp_prompt  == 3
fre heard_ecp [aw=weightBlock]

*Heard about Condoms - Spont (==1) and Pompt(==2)/ Binary
gen heard_condom = 1 if q308c_condom_prompt  == 1 | q308c_condom_prompt  == 2
replace heard_condom = 0 if q308c_condom_prompt == 3
fre heard_condom [aw=weightBlock]

*Heard of all 3 contraceptives (binary)
gen con = 0
replace con = 1 if heard_oral == 1 & heard_ecp == 1 &  heard_condom == 1
fre con[aw=weightBlock]

**Knowledge of 3 contraceptives (Spont and Prompt seperate)
gen con_3 = 0
replace con_3= 1 if q306c_oralpill_prompt == 1 & q307c_ecp_prompt == 1 & q307c_ecp_prompt == 1
replace con_3 = 2 if q306c_oralpill_prompt == 2 & q307c_ecp_prompt == 2 & q307c_ecp_prompt == 2
fre con_3 [aw=weightBlock]

**********************************************************************************************************************************************************************************************************************************
**********************************************************************************************************************************************************************************************************************************

***Section 3 : Computation of Outcome and Control vars
*1. Proportion of girls know that they are more likely to get pregnant halfway between their periods
fre q302_sex_between_periods_preg [aw=weightBlock]
gen preg_period = 1 if q302_sex_between_periods_preg ==1 
replace preg_period = 0 if q302_sex_between_periods_preg==2 |q302_sex_between_periods_preg==77 | q302_sex_between_periods_preg ==99
fre preg_period [aw=weightBlock]

*2. Proportion of girls who know a condom is suitable method to prevent pregnancy
fre q312a_suitable_method [aw=weightBlock]
gen condom_suitable= 1 if q312a_suitable_method ==1 
replace condom_suitable = 0 if q312a_suitable_method==2 | q312a_suitable_method==77 | q312a_suitable_method==99
fre condom_suitable [aw=weightBlock]

*3. Proportion of girls who think condoms are an effective way of protecting against HIV/AIDs
fre q312e_effective_protection_hiv [aw=weightBlock]
gen condom_protect= 1 if q312e_effective_protection_hiv==1 
replace condom_protect = 0 if q312e_effective_protection_hiv==2 | q312e_effective_protection_hiv==77 | q312e_effective_protection_hiv==99
fre condom_protect [aw=weightBlock]

*4. Proportion of girls intend to use contraception at next/first sex
fre q510_next_sex_contraceptives [aw=weightBlock]
gen contra_nextsex= 1 if q510_next_sex_contraceptives==1 
replace contra_nextsex = 0 if q510_next_sex_contraceptives==2 | q510_next_sex_contraceptives==3 | q510_next_sex_contraceptives==77 | q510_next_sex_contraceptives==99
fre contra_nextsex [aw=weightBlock]

*5. Proportion of girls (who are sexually active) report using contraception at last sex
fre q508_preg_avoid_method [aw=weightBlock]
gen contra_lastsex= 0 if q508_preg_avoid_method_1==1 | q508_preg_avoid_method_77==1
replace contra_lastsex = 1 if q508_preg_avoid_method_2==1| ///
q508_preg_avoid_method_3==1 | q508_preg_avoid_method_4==1| ///
q508_preg_avoid_method_5==1 | q508_preg_avoid_method_6==1| ///
q508_preg_avoid_method_7==1 | q508_preg_avoid_method_8==1| ///
q508_preg_avoid_method_9==1 | q508_preg_avoid_method_10==1| ///
q508_preg_avoid_method_11==1 | q508_preg_avoid_method_12==1| ///
q508_preg_avoid_method_13==1 | q508_preg_avoid_method_14==1| ///
q508_preg_avoid_method_15==1 | q508_preg_avoid_method_88==1
fre contra_lastsex [aw=weightBlock]

*6 Proportion of girls access an SRH service in the last 6 months SRH problems (CHECK AGAIN)
fre q501a_genital_itching [aw=weightBlock]
fre q501b_dysuria [aw=weightBlock]
fre q501c_white_urethral_discharge[aw=weightBlock]
fre q408_period_related_concern[aw=weightBlock]

fre q409_sought_treatment_six_months[aw=weightBlock]
fre q502_treatment[aw=weightBlock]

gen acc_serv_SRH = 0 if q501a_genital_itching ==1|q501b_dysuria ==1| ///
q501c_white_urethral_discharge==1|q408_period_related_concern==1
replace acc_serv_SRH =1 if q409_sought_treatment_six_months==1|q502_treatment==1
fre acc_serv_SRH[aw=weightBlock]

//For comparison with Midline
*7.Proportion of girls intend to access SRH services 
//if experiencing ulcers, infections, or pain in their private parts
fre q405_future_problem_private_part [aw=weightBlock]
gen future_pvt= 1 if q405_future_problem_private_part==1
replace future_pvt= 0 if q405_future_problem_private_part==2| ///
q405_future_problem_private_part==77|q405_future_problem_private_part==99
fre future_pvt [aw=weightBlock]

*8.Proportion of girls intend to access SRH services 
//if experiencing any menstruation-related issues
fre q412_future_period_problem [aw=weightBlock]
gen future_period = 1 if q412_future_period_problem==1
replace future_period = 0 if q412_future_period_problem==2| ///
q412_future_period_problem==77|q412_future_period_problem==99
fre future_period [aw=weightBlock]

*9.Proportion of girls intend to access SRH services 
//if experiencing any menstruation-related issues
fre q423_future_sex_problem [aw=weightBlock]
gen future_sexprob = 1 if q423_future_sex_problem==1
replace future_sexprob= 0 if q423_future_sex_problem==2| ///
q423_future_sex_problem==77|q423_future_sex_problem==99
fre future_sexprob  [aw=weightBlock]

*Computation of controls vars 
*1.Age
fre qii_age_last_bday [aw=weightBlock]

*2. Education
gen education = 1 if q102_study_yesorno==1
replace education =0 if q102_study_yesorno==2
fre education

*3. Household Income 
fre qvi_household_exp

*4 marital status
fre q101_marriage_status
gen marriage_status = 1 if q101_marriage_status==1
replace marriage_status =0 if q101_marriage_status==2
fre marriage_status

*5. Heard of CJ
fre q611_chaa_ja
gen heard_cj = 1 if q611_chaa_ja==1
replace heard_cj =0 if q611_chaa_ja==2
fre heard_cj

*6. Heard of MTV Nishedh
fre q614_mtv_nishedh
gen heard_mtv = 1 if q614_mtv_nishedh==1
replace heard_mtv =0 if q614_mtv_nishedh==2
fre heard_mtv

*7. Social Media
fre q610_active_account
foreach v of varlist q610a_facebook q610b_yt ///
q610c_whatsapp q610d_snapchat q610e_snarechat ///
q610f_musically q610g_insta q610i_hike {
    replace `v' = 0 if `v'==2|`v'==77|`v'==99
}
*Binary Var for Social Media
gen sm_habits = 0
replace sm_habits=1 if q610a_facebook==1|q610b_yt==1|q610c_whatsapp==1| ///
q610d_snapchat==1| q610e_snarechat==1 | q610f_musically==1 | ///
q610g_insta==1 | q610i_hike==1
fre sm_habits

**********************************************************************************************************************************************************************************************************************************
**********************************************************************************************************************************************************************************************************************************

*SECTION 4 : CROSS TABULATIONS 

*•Intend to access SRH services if experiencing issues after sex across age groups
tab q423_future_sex_problem qii_age_last_bday [aw=weightBlock], m
*•Intend to access SRH services if experiencing ulcers, infections, or pain in their private part across age groups 
tab q405_future_problem_private_part qii_age_last_bday [aw=weightBlock], m
*•Intend to access SRH services if experiencing any menstruation-related issues across age groups
tab q412_future_period_problem qii_age_last_bday [aw=weightBlock], m
*•Accessed SRH service/info in the last 6 months across age groups (ASK)
tab q418_any_treatment qii_age_last_bday [aw=weightBlock], m
*•Girls know that they are more likely to get pregnant halfway between their periods across age 
tab q302_sex_between_periods_preg qii_age_last_bday [aw=weightBlock], m
*•Girls who know a condom is suitable method to prevent pregnancy across age groups
tab q312a_suitable_method qii_age_last_bday [aw=weightBlock], m
*•Girls who think condoms are an effective way of protecting against HIV/AIDs across age 
tab q312e_effective_protection_hiv qii_age_last_bday [aw=weightBlock], m
*•Intend to use contraception at next/first sex across age 
tab q510_next_sex_contraceptives qii_age_last_bday [aw=weightBlock], m
*•Knowledge of Condoms (Spontaneous/Prompt show separately) across had sexual intercourse in the last 6 months
tab q308c_condom_prompt q507_last_sex [aw=weightBlock], m
*•Knowledge of 3 contraceptives Spontaneous/Prompt show separately) across age groups 
tab con_3 qii_age_last_bday [aw=weightBlock], m
*•Knowledge of 3 contraceptives Spontaneous/Prompt show separately) across had sexual intercourse in the last 6 months
tab q507_last_sex con_3 [aw=weightBlock], m
*•Sex in the last 6 months across age groups (NA)
tab q507_last_sex qii_age_last_bday [aw=weightBlock], m
*•Sex in the last 6 across marital status
tab q507_last_sex q101_marriage_status  [aw=weightBlock], m
*•Sex in the last 6 acrossrelationship status 
tab q507_last_sex q101a_relationship_status [aw=weightBlock], m
*•Girls (who are sexually active) report using contraception at last sex across age group
tab contra_lastsex qii_age_last_bday [aw=weightBlock], m
*•Girls (who are sexually active) report using contraception at last sex across marital and relationship status 
tab contra_lastsex q101_marriage_status [aw=weightBlock], m
*•Girls (who are sexually active) report using contraception at last sex across relationship status 
tab contra_lastsex q101a_relationship_status [aw=weightBlock], m
*•Intend to use contraception at next/first sex across marital status 
tab q510_next_sex_contraceptives q101_marriage_status [aw=weightBlock], m
*•Intend to use contraception at next/first sex across relationship status
tab q510_next_sex_contraceptives q101a_relationship_status [aw=weightBlock], m
*•Intend to use contraception at next/first sex across relationship status
tab q510_next_sex_contraceptives hhs_income [aw=weightBlock], m

*Awareness CJ
tab q611_chaa_ja qii_age_last_bday [aw=weightBlock], m
tab q611_chaa_ja hhs_income [aw=weightBlock], m

tab q405_future_problem_private_part hhs_income[aw=weightBlock], m
tab q412_future_period_problem hhs_income [aw=weightBlock], m
tab q423_future_sex_problem hhs_income [aw=weightBlock] , m

tab acc_serv_SRH q101_marriage_status [aw=weightBlock], m
tab acc_serv_SRH q101a_relationship_status [aw=weightBlock], m
tab acc_serv_SRH  hhs_income [aw=weightBlock], m

*Tempfile Data
tempfile GEData_e
save `GEData_e', replace

*SUBGROUP CROSS TABS
u `GEData_e'
*Exposed - 433
keep if q611_chaa_ja==1
tab q302_sex_between_periods_preg acc_serv_SRH [aw=weightBlock],m
tab q312a_suitable_method acc_serv_SRH [aw=weightBlock],m
tab q312e_effective_protection_hiv acc_serv_SRH [aw=weightBlock],m

clear
u `GEData_e'
*Not Exposed 
keep if q611_chaa_ja==2
tab q302_sex_between_periods_preg acc_serv_SRH [aw=weightBlock],m
tab q312a_suitable_method acc_serv_SRH [aw=weightBlock],m
tab q312e_effective_protection_hiv acc_serv_SRH [aw=weightBlock],m



/*
Baseline analysis for outcome vars present in both Baseline and Endline
Outcome vars
1. q302_sex_between_periods_preg (302. A woman is most likely to get pregnant if she has sexual intercourse halfway between her periods)
2. q312a_suitable_method (A. Condom is a suitable method for preventing pregnancy)
3. q312e_effective_protection_hiv (E. Condoms are an effective way of protecting against HIV/AIDS)
4. q510_next_sex_contraceptives (524. The next time that you have sexual intercourse, do you intend/ plan to use contraceptives? )
5. q508_preg_avoid_method (518. If yes, did you use a method to avoid pregnancy or infection? If yes, what method)
6. q502_treatment 
502. Did you seek treatment for this complaint- itching/burbibg/discharge) + 
q409_sought_treatment_six_months (509. Did you seek treatment for this complaint?)

Controls (Endline/Baseline)
1. Age - qII_age_last_bday//qii_age_last_bday 
2. Education - q102_study_yesorno //q102_study_yesorno 
3. Household Income -qVI_household_exp//
4. Marital Status -q101_marriage_status //q101_marriage_status 
5. Heard of CJ - q611_chaa_ja//q611_chaa_ja 
6. Heard of MTV - q614_mtv_nishedh//q614_mtv_nishedh 
7. Social Media - q610_active_account 610_ //q610_active_account 610_ 
601. Please let us know the platforms you have an active account; 
by active account I mean you Share OR Like OR Comment on content 
available on the platform.// Convert to Binary var)//
*/


clear

**********************************************************************************************************************************************************************************************************************************
**********************************************************************************************************************************************************************************************************************************

** SECTION 5: IMPORT BASELINE AND CLEANING 
*Import Baseline
import delimited "`inpath'GE_baseline.csv" , clear

*** Targets from cleaning -- need to input data, drop relevant cases, dropping based on screener questions to come up with final usable sample.
count
*2,029
** Changes based on Vinays email -- phase 1 and phase 2 codes
split submissiondate, p(",")
drop if submissiondate4=="uuid:54d6d90f-c9f4-4a15-ae50-6663cd31ad14" | submissiondate1=="Sep 16" | key==""
** 36 observations deleted

*** Applying the screener questions for GE

*** Consent 
keep if q4_consent_yesno==1
** 5 observations deleted

*** Age (16-19)
keep if qii_age_last_bday>15 & qii_age_last_bday<=19
** 1 observations deleted

*** Gender (female)
keep if qiii_respondnet_sex==1
** 3 observations deleted

*** Study status
keep if qiv_study_status==1 | qv_intend_to==1
** 68 observations dropped

*** Access to mobile
keep if q604_own_mobile==1 | q605_access_to_mobile==1
** 48 observations dropped

count
** 1868 observations 

* Baseline Time Period Dummy 
gen timePd = 0


drop submissiondate1 submissiondate2 submissiondate3 submissiondate4

bys block_code: gen totalHouseholds = _N
tab totalHouseholds, m
** 24 blocks have 34; 12 have 35; 2 for 36,37,38 and 39; 3 for 40; 2 for 42; 1 for 57 (50 blocks in total)
** Basically everywhere its either equal to ot more than the required number
*** Weighting -- Need 34/ block for GE. Weight will be at block level -- will be inverse of the same (34/no cases per block)
gen weightBlock = (34/totalHouseholds)
gen weightBlockRound = round((weightBlock*100),1)

fre qii_age_last_bday - q615_any_episode [aw=weightBlock]

gen fam_member = 1 if q109_fam_members_number <6
replace fam_member = 2 if q109_fam_members_number>= 6 & qvi_household_exp < 16
replace fam_member = 3 if q109_fam_members_number >= 16
tab fam_member [aw=weightBlock], m

keep weightBlock block_code q302_sex_between_periods_preg q312a_suitable_method ///
q312e_effective_protection_hiv q510_next_sex_contraceptives ///
q508_preg_avoid_method q508_preg_avoid_method_1 q101_marriage_status ///
q101a_relationship_status   q103_employment_status q604_own_mobile ///
q605_access_to_mobile /// 
q102_study_yesorno q102a_study_what q102b_education_level ///
q508_preg_avoid_method_2 q508_preg_avoid_method_3 ///
q508_preg_avoid_method_4 q508_preg_avoid_method_5 ///
q508_preg_avoid_method_6 q508_preg_avoid_method_7 ///
q508_preg_avoid_method_8 q508_preg_avoid_method_9 ///
q508_preg_avoid_method_10 q508_preg_avoid_method_11 ///
q508_preg_avoid_method_12 q508_preg_avoid_method_13 ///
q508_preg_avoid_method_14 q508_preg_avoid_method_15 ///
q508_preg_avoid_method_88 q508_preg_avoid_method_77 ///
q508_preg_avoid_method_other q502_treatment timePd ///
qii_age_last_bday qvi_household_exp q101_marriage_status q102_study_yesorno ///
q611_chaa_ja q614_mtv_nishedh q610_active_account q610a_facebook ///
q610b_yt q610c_whatsapp q610d_snapchat q610e_snarechat ///
q610f_musically q610g_insta q610h_tiktok q610i_hike q610j_others

*Household Expenses
fre qvi_household_exp[aw=weightBlock] 
drop if qvi_household_exp==-20000 | qvi_household_exp==-8000| qvi_household_exp==-8000 |qvi_household_exp==-441

*Household expenses categories
gen hhs_income = 1 if qvi_household_exp < 10000
replace hhs_income = 2 if qvi_household_exp>= 10000 & qvi_household_exp < 30000
replace hhs_income = 3 if qvi_household_exp >= 30000
label define income 1 "<1000" 2 "10000-less than 30000" 3 "Greater than 30000"
label value hhs_income income
tab hhs_income [aw=weightBlock], m

**********************************************************************************************************************************************************************************************************************************
**********************************************************************************************************************************************************************************************************************************


*SECTION 6: Computation of utcome and control variables 

*Computation of outcome vars 
*1. Proportion of girls know that they are more likely to get pregnant halfway between their periods

fre q302_sex_between_periods_preg [aw=weightBlock]
gen preg_period = 1 if q302_sex_between_periods_preg ==1 
replace preg_period = 0 if q302_sex_between_periods_preg==2 | q302_sex_between_periods_preg==77 | q302_sex_between_periods_preg ==99
fre preg_period [aw=weightBlock]

*2. Proportion of girls who know a condom is suitable method to prevent pregnancy
fre q312a_suitable_method [aw=weightBlock]
gen condom_suitable= 1 if q312a_suitable_method ==1 
replace condom_suitable = 0 if q312a_suitable_method==2 | q312a_suitable_method==77 | q312a_suitable_method==99
fre condom_suitable

*3. Proportion of girls who think condoms are an effective way of protecting against HIV/AIDs
fre q312e_effective_protection_hiv [aw=weightBlock]
gen condom_protect= 1 if q312e_effective_protection_hiv==1 
replace condom_protect = 0 if q312e_effective_protection_hiv==2 | q312e_effective_protection_hiv==77 | q312e_effective_protection_hiv==99
fre condom_protect

*4. Proportion of girls intend to use contraception at next/first sex
fre q510_next_sex_contraceptives [aw=weightBlock]
gen contra_nextsex= 1 if q510_next_sex_contraceptives==1 
replace contra_nextsex = 0 if q510_next_sex_contraceptives==2 | q510_next_sex_contraceptives==3 | q510_next_sex_contraceptives==77 | q510_next_sex_contraceptives==99
fre contra_nextsex

*5. Proportion of girls (who are sexually active) report using contraception at last sex
fre q508_preg_avoid_method [aw=weightBlock]
gen contra_lastsex= 0 if q508_preg_avoid_method_1==1 | q508_preg_avoid_method_77==1
replace contra_lastsex = 1 if q508_preg_avoid_method_2==1| ///
q508_preg_avoid_method_3==1 | q508_preg_avoid_method_4==1| ///
q508_preg_avoid_method_5==1 | q508_preg_avoid_method_6==1| ///
q508_preg_avoid_method_7==1 | q508_preg_avoid_method_8==1| ///
q508_preg_avoid_method_9==1 | q508_preg_avoid_method_10==1| ///
q508_preg_avoid_method_11==1 | q508_preg_avoid_method_12==1| ///
q508_preg_avoid_method_13==1 | q508_preg_avoid_method_14==1| ///
q508_preg_avoid_method_15==1 | q508_preg_avoid_method_88==1
fre contra_lastsex [aw=weightBlock]

*6 Proportion of girls access an SRH service in the last 6 months SRH problems
fre q502_treatment [aw=weightBlock]
gen acc_serv_SRH =1 if q502_treatment==1
replace acc_serv_SRH=0 if q502_treatment==2|q502_treatment==99
fre acc_serv_SRH [aw=weightBlock]

*Computation of controls vars 
*1.Age
fre qii_age_last_bday

*2. Education
fre q102_study_yesorno
gen education = 1 if q102_study_yesorno==1
replace education =0 if q102_study_yesorno==2 | q102_study_yesorno==2
fre education

*3. Household Income 
fre qvi_household_exp

*4 marital status
fre q101_marriage_status
gen marriage_status = 1 if q101_marriage_status==1
replace marriage_status =0 if q101_marriage_status==2| q101_marriage_status==99
fre marriage_status

*5. Heard of CJ
fre q611_chaa_ja
gen heard_cj = 1 if q611_chaa_ja==1
replace heard_cj =0 if q611_chaa_ja==2|q611_chaa_ja==2==99
fre heard_cj

*6. Heard of MTV Nishedh
fre q614_mtv_nishedh
gen heard_mtv = 1 if q614_mtv_nishedh==1
replace heard_mtv =0 if q614_mtv_nishedh==2|q614_mtv_nishedh==77|q614_mtv_nishedh==99
fre heard_mtv

*7. Social Media
drop q610h_tiktok
fre q610_active_account
foreach v of varlist q610a_facebook q610b_yt ///
q610c_whatsapp q610d_snapchat q610e_snarechat ///
q610f_musically q610g_insta q610i_hike {
    replace `v' = 0 if `v'==2|`v'==77|`v'==99
}
*Binary Var for Social Media
gen sm_habits = 0
replace sm_habits=1 if q610a_facebook==1|q610b_yt==1|q610c_whatsapp==1| ///
q610d_snapchat==1| q610e_snarechat==1 | q610f_musically==1 | ///
q610g_insta==1 | q610i_hike==1
fre sm_habits

/*
qii_age_last_bday
sm_habits
heard_mtv
heard_cj
marriage_status
qvi_household_exp
education
*/
****** Appending Baseline and Endline data
append using `GEData_e',force

fre qvi_household_exp
drop if qvi_household_exp==1.00e+08 | qvi_household_exp==2.00e+08

*Tempfile Data
tempfile GEData_be
save `GEData_be', replace

**********************************************************************************************************************************************************************************************************************************
**********************************************************************************************************************************************************************************************************************************

******SECTION 7: Probit Regression***********
*1. Without controls 
  //1. girls intend to use contraception at next/first sex
probit contra_nextsex timePd [pw=weightBlock], cluster(block_code) level(90)
margins, dydx(*) level(90)
marginsplot, plotr(margin(bargraph)) ytick(#5) recast(bar) ///
	ytitle("{it: Average marginal effects of baseline-endline variable}", height(5)) ///
	xtitle("") ///
	title("{bf:Marginal effects imputed from Probit Regression}" , position (12) span) ///
	subtitle("{bf:Dependent variable: Intend to use contraception at next/first sex}" ///
	" " ///
	"{it: Specification does not include controls; bars reflect 90% CI}",  position (12) span) ///
	ciopts(recast(cap) msize(small)) ///
	plotopts(barwidth(0.5) color(navy*.6)) ///
	b1title("{it:Time Period Dummy: Baseline/Endline}", height(5) size(mediumsmall))

// Save
graph export "`outpath'Graph/GE_contraceptive_nextsex_WC.png", as(png) replace
	
	//2. girls know that they are more likely to get pregnant halfway between their periods 
probit preg_period timePd [pw=weightBlock], cluster(block_code) level(90)
margins, dydx(*) level(90)
marginsplot, plotr(margin(bargraph)) ytick(#5) recast(bar) ///
	ytitle("{it: Average marginal effects of baseline-endline variable}", height(5)) ///
	xtitle("") ///
	title("{bf:Marginal effects imputed from Probit Regression}" ,  position (12) span) ///
	subtitle("{bf:Dependent variable: Likely to get pregnant between periods}" ///
	" " ///
	"{it: Specification does not include controls; bars reflect 90% CI}",  position (12) span) ///
	ciopts(recast(cap) msize(small)) ///
	plotopts(barwidth(0.5) color(navy*.6)) ///
	b1title("{it:Time Period Dummy: Baseline/Endline}", height(5) size(mediumsmall))

// Save
graph export "`outpath'Graph/GE_preg_period_WC.png", as(png) replace

    //3. girls who know a condom is suitable method to prevent pregnancy suitable_method
probit condom_suitable timePd [pw=weightBlock], cluster(block_code) level(90)
margins, dydx(*) level(90)
marginsplot, plotr(margin(bargraph)) ytick(#5) recast(bar) ///
	ytitle("{it: Average marginal effects of baseline-endline variable}", height(5)) ///
	xtitle("") ///
	title("{bf:Marginal effects imputed from Probit Regression}" ,  position (12) span) ///
	subtitle("{bf:Dependent variable: Condom can prevent pregnancy}" ///
	" " ///
	"{it: Specification does not include controls; bars reflect 90% CI}",  position (12) span) ///
	ciopts(recast(cap) msize(small)) ///
	plotopts(barwidth(0.5) color(navy*.6)) ///
	b1title("{it:Time Period Dummy: Baseline/Endline}", height(5) size(mediumsmall))
	
// Save 
graph export "`outpath'Graph/GE_condoms_preg_WC.png", as(png) replace

     //4. girls who think condoms are an effective way of protecting against HIV/AIDs
probit condom_protect timePd [pw=weightBlock], cluster(block_code) level(90)
margins, dydx(*) level(90)
marginsplot, plotr(margin(bargraph)) ytick(#5) recast(bar) ///
	ytitle("{it: Average marginal effects of baseline-endline variable}", height(5)) ///
	xtitle("") ///
	title("{bf:Marginal effects imputed from Probit Regression}" ,  position (12) span) ///
	subtitle("{bf:Dependent variable: Condoms can protect against HIV/AIDS}" ///
	" " ///
	"{it: Specification does not include controls; bars reflect 90% CI}", position (12) span) ///
	ciopts(recast(cap) msize(small)) ///
	plotopts(barwidth(0.5) color(navy*.6)) ///
	b1title("{it:Time Period Dummy: Baseline/Endline}", height(5) size(mediumsmall))
	
// Save
graph export "`outpath'Graph/GE_condoms_HIV_WC.png", as(png) replace
	
     //5. girls access an SRH service in the last 6 months
probit acc_serv_SRH timePd [pw=weightBlock], cluster(block_code) level(90)
margins, dydx(*) level(90)
marginsplot, plotr(margin(bargraph)) ytick(#5) recast(bar) ///
	ytitle("{it: Average marginal effects of baseline-endline variable}", height(5)) ///
	xtitle("") ///
	title("{bf:Marginal effects imputed from Probit Regression}" , position (12) span) ///
	subtitle("{bf:Dependent variable: Access to SRH services/Info}" ///
	" " ///
	"{it: Specification does not include controls; bars reflect 90% CI}", position (12) span) ///
	ciopts(recast(cap) msize(small)) ///
	plotopts(barwidth(0.5) color(navy*.6)) ///
	b1title("{it:Time Period Dummy: Baseline/Endline}", height(5) size(mediumsmall))
// Save
graph export "`outpath'Graph/GE_SRH_service_WC.png", as(png) replace

      //6. girls (who are sexually active) report using contraception at last sex 
probit contra_lastsex timePd [pw=weightBlock], cluster(block_code) level(90)
margins, dydx(*) level(90)
marginsplot, plotr(margin(bargraph)) ytick(#5) recast(bar) ///
	ytitle("{it: Average marginal effects of baseline-endline variable}", height(5)) ///
	xtitle("") ///
	title("{bf:Marginal effects imputed from Probit Regression}" , position (12) span) ///
	subtitle("{bf:Dependent variable: Used contraception at last sex}" ///
	" " ///
	"{it: Specification does not include controls; bars reflect 90% CI}", position (12) span) ///
	ciopts(recast(cap) msize(small)) ///
	plotopts(barwidth(0.5) color(navy*.6)) ///
	b1title("{it:Time Period Dummy: Baseline/Endline}", height(5) size(mediumsmall))

// Save
graph export "`outpath'Graph/GE_contraception_lastsex_WC.png", as(png) replace


* 2. With controls

/*	
**Controls 
**Demographic
•	Age 
•	Household income 
•	Marital Status 
•	Education Status
•	Access to a mobile phone and/or internet 
**Knowledge Controls 
•	Heard of Chhaa Jaa 
•	Heard of MTV Nished 
*/

/*
qii_age_last_bday
sm_habits
heard_mtv
heard_cj
marriage_status
qvi_household_exp
education
*/

   //1. girls intend to use contraception at next/first sex	
probit contra_nextsex timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj [pw=weightBlock], cluster(block_code) level(90)
margins, dydx(*) level(90)
marginsplot, plotr(margin(bargraph)) ytick(#5) xlabel(1 "B/E" 2 "Age" 3 "Household Expense" 4 "Marital Status" 5"Education" ///
 6 "Exposure to MTV Nishedh" 7"Exposure to Chhaa Jaa" , labels angle(30)labsize(*0.8) tstyle(show_ticks(yes))) recast(bar) ///
	ytitle("{it: Average marginal effects of baseline-endline variable}", height(4) margin(tiny)) ///
	xtitle("") ///
	title("{bf: Marginal effects imputed from Probit Regression}" , position (12) span) ///
	subtitle("{bf:Dependent variable: Intend to use contraception at next/first sex}" ///
	" " ///
	"{it: Specification includes controls; bars reflect 90% CI}" , position (12) span) ///
	ciopts(recast(cap) msize(small)) ///
	plotopts(barwidth(0.5) color(navy*.6)) ///
	b1title("{it:Time Period Dummy: Baseline/Endline}", height(5) size(mediumsmall))
	
// Save
graph export "`outpath'Graph/GE_contraceptive_nextsex_C.png", as(png) replace

reg contra_nextsex timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj [aw=weightBlock], cluster(block_code) level(90)

reg contra_nextsex timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj [aw=weightBlock], cluster(block_code)

    //2. girls know that they are more likely to get pregnant halfway between their periods 	
probit preg_period timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj sm_habits [pw=weightBlock], cluster(block_code) level(90)
margins, dydx(*) level(90)
marginsplot, plotr(margin(bargraph)) ytick(#5) xlabel(1 "B/E" 2 "Age" 3 "Household Expense" 4 "Marital Status" 5"Education" ///
 6 "Exposure to MTV Nishedh" 7"Exposure to Chhaa Jaa" , labels angle(30)labsize(*0.8) tstyle(show_ticks(yes))) recast(bar) ///
	ytitle("{it: Average marginal effects of baseline-endline variable}", height(4) margin(tiny)) ///
	xtitle("") ///
	title("{bf: Marginal effects imputed from Probit Regression}" , position (12) span) ///
	subtitle("{bf:Dependent variable: Likely to get pregnant b/w periods}" ///
	" " ///
	"{it: Specification includes controls; bars reflect 90% CI}" , position (12) span) ///
	ciopts(recast(cap) msize(small)) ///
	plotopts(barwidth(0.5) color(navy*.6)) ///
	b1title("{it:Time Period Dummy: Baseline/Endline}", height(5) size(mediumsmall))

reg preg_period timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj [pw=weightBlock], cluster(block_code) level(90)

reg contra_nextsex timePd [pw=weightBlock], cluster(block_code) level(90)


// Save
graph export "`outpath'Graph/GE_preg_period_C.png", as(png) replace
   
   //3. girls who know a condom is suitable method to prevent pregnancy suitable_method
probit condom_suitable timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj sm_habits [pw=weightBlock], cluster(block_code)  level(90)
margins, dydx(*)  level(90)
marginsplot, plotr(margin(bargraph)) ytick(#5) xlabel(1 "B/E" 2 "Age" 3 "Household Expense" 4 "Marital Status" 5"Education" ///
 6 "Exposure to MTV Nishedh" 7"Exposure to Chhaa Jaa" , labels angle(30)labsize(*0.8) tstyle(show_ticks(yes))) recast(bar) ///
	ytitle("{it: Average marginal effects of baseline-endline variable}", height(4) margin(tiny)) ///
	xtitle("") ///
	title("{bf: Marginal effects imputed from Probit Regression}" , position (12) span) ///
	subtitle("{bf:Dependent variable:Condoms can prevent pregnancy}" ///
	" " ///
	"{it: Specification includes controls; bars reflect 90% CI}" , position (12) span) ///
	ciopts(recast(cap) msize(small)) ///
	plotopts(barwidth(0.5) color(navy*.6)) ///
	b1title("{it:Time Period Dummy: Baseline/Endline}", height(5) size(mediumsmall))

	
reg condom_suitable timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj [pw=weightBlock], cluster(block_code) level(90)

// Save
graph export "`outpath'Graph/GE_condom_preg_C.png", as(png) replace
	
    //4. girls who think condoms are an effective way of protecting against HIV/AIDs
probit condom_protect timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj [pw=weightBlock], cluster(block_code) level(90)
margins, dydx(*) level(90)
marginsplot, plotr(margin(bargraph)) ytick(#5) xlabel(1 "B/E" 2 "Age" 3 "Household Expense" 4 "Marital Status" 5"Education" ///
 6 "Exposure to MTV Nishedh" 7 "Exposure to Chhaa Jaa" , labels angle(30)labsize(*0.8) tstyle(show_ticks(yes))) recast(bar) ///
	ytitle("{it: Average marginal effects of baseline-endline variable}", height(4) margin(tiny)) ///
	xtitle("") ///
	title("{bf: Marginal effects imputed from Probit Regression}" , position (12) span) ///
	subtitle("{bf:Dependent variable:Condoms can protect against HIV/AIDS}" ///
	" " ///
	"{it: Specification includes controls; bars reflect 90% CI}" , position (12) span) ///
	ciopts(recast(cap) msize(small)) ///
	plotopts(barwidth(0.5) color(navy*.6)) ///
	b1title("{it:Time Period Dummy: Baseline/Endline}", height(5) size(mediumsmall))
// Save
graph export "`outpath'Graph/GE_Condoms_HIV_C.png", as(png) replace	

reg condom_protect timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj [pw=weightBlock], cluster(block_code) level(90)

	
    //5. girls access an SRH service in the last 6 months
probit acc_serv_SRH timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj [pw=weightBlock], cluster(block_code) level(90)
margins, dydx(*) level(90)
marginsplot, plotr(margin(bargraph)) ytick(#5) xlabel(1 "B/E" 2 "Age" 3 "Household Expense" 4 "Marital Status" 5"Education" ///
 6"Exposure to MTV Nishedh" 7"Exposure to Chhaa Jaa" , labels angle(30)labsize(*0.8) tstyle(show_ticks(yes))) recast(bar) ///
	ytitle("{it: Average marginal effects of baseline-endline variable}", height(4) margin(tiny)) ///
	xtitle("") ///
	title("{bf: Marginal effects imputed from Probit Regression}" , position (12) span) ///
	subtitle("{bf:Dependent variable: Access to SRH Services}" ///
	" " ///
	"{it: Specification includes controls; bars reflect 90% CI}" , position (12) span) ///
	ciopts(recast(cap) msize(small)) ///
	plotopts(barwidth(0.5) color(navy*.6)) ///
	b1title("{it:Time Period Dummy: Baseline/Endline}", height(5) size(mediumsmall))
// Save
graph export "`outpath'Graph/GE_SRH_service_C.png", as(png) replace	

reg acc_serv_SRH timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj [pw=weightBlock], cluster(block_code) level(90)
   
	//6. percentage of girls (who are sexually active) report using contraception at last sex 
probit contra_lastsex timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj [pw=weightBlock], cluster(block_code) level(90)
margins, dydx(*) level(90)
marginsplot, plotr(margin(bargraph)) ytick(#5) xlabel(1 "B/E" 2 "Age" 3 "Household Expense" 4 "Marital Status" 5"Education" ///
 6 "Exposure to MTV Nishedh" 7 "Exposure to Chhaa Jaa" , labels angle(30)labsize(*0.8) tstyle(show_ticks(yes))) recast(bar) ///
	ytitle("{it: Average marginal effects of baseline-endline variable}", height(4) margin(tiny)) ///
	xtitle("") ///
	title("{bf: Marginal effects imputed from Probit Regression}" , position (12) span) ///
	subtitle("{bf:Dependent variable: Used contraception at last sex}" ///
	" " ///
	"{it: Specification includes controls; bars reflect 90% CI}" , position (12) span) ///
	ciopts(recast(cap) msize(small)) ///
	plotopts(barwidth(0.5) color(navy*.6)) ///
	b1title("{it:Time Period Dummy: Baseline/Endline}", height(5) size(mediumsmall))
// Save
graph export "`outpath'Graph/GE_Contraception_lastsex_C.png", as(png) replace	

reg contra_lastsex timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj [pw=weightBlock], cluster(block_code) level(90)


clear 

**********************************************************************************************************************************************************************************************************************************
**********************************************************************************************************************************************************************************************************************************

*SECTION 8: Import Midline Data and data cleaning 
************Midline Data****************************************
import delimited "`inpath'GE_midline.csv" , clear

count
*1693

keep block q6_demo_hh_income resp_age q101_marriage_yes_no q102_studying ///
q501_heard_of_chaa_jaa q505_mtv_nishedh q423_future_sex_problem ///
q412_future_period_problem q405_future_problem_private_part ///
q101a_dating_or_not q102a_studying_what q102b_highest_education ///
q103_currently_employed

*Renaming basis Endline
rename resp_age qii_age_last_bday
rename q6_demo_hh_income qvi_household_exp
rename q101_marriage_yes_no q101_marriage_status
rename q101a_dating_or_not q101a_relationship_status
rename q102_studying q102_study_yesorno
rename q102a_studying_what q102a_study_what
rename q102b_highest_education q102b_education_level
rename q103_currently_employed q103_employment_status 

gen timePd = 0

*Weighting
bys block: gen totalHouseholds = _N
hist totalHouseholds, percent kden
tab totalHouseholds, m
* 24 blocks have 34; 12 have 35; 2 for 36,37,38 and 39; 3 for 40; 2 for 42; 1 for 57 (50 blocks in total)
** Basically everywhere its either equal to ot more than the required number
gen weightBlock = (34/totalHouseholds)
gen weightBlockRound = round((weightBlock*100),1)

*Splitting bloack for block numbers (needed for clustering SE's) 
split block, p("-")
drop block block1
rename block2 block_code
destring block, replace

gen hhs_income = 1 if qvi_household_exp < 10000
replace hhs_income = 2 if qvi_household_exp >= 10000 & qvi_household_exp < 30000
replace hhs_income = 3 if qvi_household_exp >= 30000
label define income 1 "<1000" 2 "10000-less than 30000" 3 "Greater than 30000"
label value hhs_income income
tab hhs_income [aw=weightBlock], m

/*
Outcome vars 
Midline    
1. q423_future_sex_problem : If in the future you experience any issues/ health concerns post sexual intercourse, would you seek care/ treatment? 
2. q412_future_period_problem: In the future if you experience any menstruation related health concerns - such as irregular periods, excessive bleeding, pain etc. would you consider seeking treatment? 
3. q405_future_problem_private_part : In the future if you experience any itching or infection or pain in your genitals/ private parts, would you consider seeking treatment? 

Controls 
1. Age
2. Education
3. Marital Status
4. Household Income
5. Heard of Chhaa Jaa
6. Heard of MTV Nishedh
*/

**********************************************************************************************************************************************************************************************************************************
**********************************************************************************************************************************************************************************************************************************


*Section 9 : Computation of Outcome and Control Vars  (Midline)

*1. Intend to access SRH services for any problem in private parts in the future
fre q405_future_problem_private_part [aw=weightBlock]
gen future_pvt= 1 if q405_future_problem_private_part==1
replace future_pvt= 0 if q405_future_problem_private_part==2| ///
q405_future_problem_private_part==77|q405_future_problem_private_part==99
fre future_pvt [aw=weightBlock]

*2. Intend to access SRH services for any menstrual related problem in the future
fre q412_future_period_problem [aw=weightBlock]
gen future_period = 1 if q412_future_period_problem==1
replace future_period = 0 if q412_future_period_problem==2| ///
q412_future_period_problem==77|q412_future_period_problem==99
fre future_period [aw=weightBlock]

*3. Intend to access SRH services for any menstrual related problem in the future
fre q423_future_sex_problem [aw=weightBlock]
gen future_sexprob = 1 if q423_future_sex_problem==1
replace future_sexprob= 0 if q423_future_sex_problem==2| ///
q423_future_sex_problem==77|q423_future_sex_problem==99
fre future_sexprob [aw=weightBlock]

*Computations of control vars 

*3. Marital Status
fre q101_marriage_status
gen marriage_status =1 if q101_marriage_status==1
replace marriage_status =0 if q101_marriage_status==2
fre marriage_status

*4. Education Status
fre q102_study_yesorno
gen education =1 if q102_study_yesorno==1|q102_study_yesorno==88
replace education=0 if q102_study_yesorno==2
fre education

*5. Heard of CJ
fre q501_heard_of_chaa_jaa
gen heard_cj = 1 if q501_heard_of_chaa_jaa==1
replace heard_cj =0 if q501_heard_of_chaa_jaa==2
fre heard_cj

*6. Heard of MTV Nishedh
fre q505_mtv_nishedh
gen heard_mtv = 1 if q505_mtv_nishedh==1
replace heard_mtv =0 if q505_mtv_nishedh==2
fre heard_mtv


append using `GEData_e',force
*Tempfile Data
tempfile GEData_me
save `GEData_me', replace


**********************************************************************************************************************************************************************************************************************************
**********************************************************************************************************************************************************************************************************************************

*SECTION 10: Probit Regression at 90% CI for Outcomes vars in Midline and Endline 

**** Without Controls *****
//1. Proportion of girls intend to access SRH services 
// if experiencing ulcers, infections, or pain in their private parts
probit future_pvt timePd [pw=weightBlock], cluster(block_code) level(90)
margins, dydx(*) level(90)
marginsplot, plotr(margin(bargraph)) ytick(#5) recast(bar) ///
	ytitle("{it: Average marginal effects of midline-endline variable}", height(5)) ///
	xtitle("") ///
	title("{bf:Marginal effects imputed from Probit Regression}" , position (12) span) ///
	subtitle("{bf:Dependent variable: Intend to access SRH services for infections}" ///
	" " ///
	"{it: Specification does not include controls; bars reflect 90% CI}", position (12) span) ///
	ciopts(recast(cap) msize(small)) ///
	plotopts(barwidth(0.5) color(navy*.6)) ///
	b1title("{it:Time Period Dummy: Midline/Endline}", height(5) size(mediumsmall))
  graph export "`outpath'Graph/GE_intend_accesspain_WC.png", as(png) replace	

  
 
//2. Proportion of girls intend to access SRH services 
// if experiencing any menstruation-related issues
probit future_period timePd [pw=weightBlock], cluster(block_code) level(90)
margins, dydx(*) level(90)
marginsplot, plotr(margin(bargraph)) ytick(#5) recast(bar) ///
	ytitle("{it: Average marginal effects of midline-endline variable}", height(5)) ///
	xtitle("") ///
	title("{bf:Marginal effects imputed from Probit Regression}" , position (12) span) ///
	subtitle("{bf:Dependent variable: Intend to access SRH services for menstrual issues}" ///
	" " ///
	"{it: Specification does not include controls; bars reflect 90% CI}", position (12) span) ///
	ciopts(recast(cap) msize(small)) ///
	plotopts(barwidth(0.5) color(navy*.6)) ///
	b1title("{it:Time Period Dummy: Midline/Endline}", height(5) size(mediumsmall))
  graph export "`outpath'Graph/GE_intend_accessperiod_WC.png", as(png) replace	
	
//3. Proportion of girls intend to access SRH services 
// if experiencing issues after sex
probit future_sexprob timePd [pw=weightBlock], cluster(block_code) level(90)
margins, dydx(*) level(90)
marginsplot, plotr(margin(bargraph)) ytick(#5) recast(bar) ///
	ytitle("{it: Average marginal effects of midline-endline variable}", height(5)) ///
	xtitle("") ///
	title("{bf:Marginal effects imputed from Probit Regression}" , position (12) span) ///
	subtitle("{bf:Dependent variable: Intend to access SRH services for issues post sex}" ///
	" " ///
	"{it: Specification does not include controls; bars reflect 90% CI}", position (12) span) ///
	ciopts(recast(cap) msize(small)) ///
	plotopts(barwidth(0.5) color(navy*.6)) ///
	b1title("{it:Time Period Dummy: Midline/Endline}", height(5) size(mediumsmall))
  graph export "`outpath'Graph/GE_intend_accesssex_WC.png", as(png) replace	


*With Controls


//1. Proportion of girls intend to access SRH   services 
// if experiencing ulcers, infections, or pain in their private parts	
probit future_pvt timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj [pw=weightBlock], cluster(block_code) level(90)
margins, dydx(*) level(90)
marginsplot, plotr(margin(bargraph)) ytick(#5) xlabel(1 "M/E" 2 "Age" 3 "Household Expense" 4 "Marital Status" 5"Education" ///
 6 "Exposure to MTV Nishedh" 7"Exposure to Chhaa Jaa" , labels angle(30)labsize(*0.8) tstyle(show_ticks(yes))) recast(bar) ///
	ytitle("{it: Average marginal effects of midline-endline variable}", height(4) margin(tiny)) ///
	xtitle("") ///
	title("{bf: Marginal effects imputed from Probit Regression}" , position (12) span) ///
	subtitle("{bf:Dependent variable: Intend to access SRH services for infections}" ///
	" " ///
	"{it: Specification includes controls; bars reflect 90% CI}" , position (12) span) ///
	ciopts(recast(cap) msize(small)) ///
	plotopts(barwidth(0.5) color(navy*.6)) ///
	b1title("{it:Time Period Dummy: Midline/Endline}", height(5) size(mediumsmall))
  graph export "`outpath'Graph/GE_intend_accesspain_C.png", as(png) replace	

reg future_pvt timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj [pw=weightBlock], cluster(block_code) level(90)

//2. Proportion of girls intend to access SRH services 
// if experiencing any menstruation-related issues
probit future_period timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj [pw=weightBlock], cluster(block_code) level(90)
margins, dydx(*) level(90)
marginsplot, plotr(margin(bargraph)) ytick(#5) xlabel(1 "M/E" 2 "Age" 3 "Household Expense" 4 "Marital Status" 5"Education" ///
 6 "Exposure to MTV Nishedh" 7"Exposure to Chhaa Jaa" , labels angle(30)labsize(*0.8) tstyle(show_ticks(yes))) recast(bar) ///
	ytitle("{it: Average marginal effects of midline-endline variable}", height(4) margin(tiny)) ///
	xtitle("") ///
	title("{bf: Marginal effects imputed from Probit Regression}" , position (12) span) ///
	subtitle("{bf:Dependent variable: Intend to access SRH services for menstrual issues}" ///
	" " ///
	"{it: Specification includes controls; bars reflect 90% CI}" , position (12) span) ///
	ciopts(recast(cap) msize(small)) ///
	plotopts(barwidth(0.5) color(navy*.6)) ///
	b1title("{it:Time Period Dummy: Midline/Endline}", height(5) size(mediumsmall))
  graph export "`outpath'Graph/GE_intend_accessperiod_C.png", as(png) replace	
reg future_period timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj [pw=weightBlock], cluster(block_code) level(90)


//3. Proportion of girls intend to access SRH services 
// if experiencing issues after sex
probit future_sexprob timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj [pw=weightBlock], cluster(block_code) level(90)
margins, dydx(*) level(90)
marginsplot, plotr(margin(bargraph)) ytick(#5) xlabel(1 "M/E" 2 "Age" 3 "Household Expense" 4 "Marital Status" 5"Education" ///
 6 "Exposure to MTV Nishedh" 7"Exposure to Chhaa Jaa" , labels angle(30)labsize(*0.8) tstyle(show_ticks(yes))) recast(bar) ///
	ytitle("{it: Average marginal effects of midline-endline variable}", height(4) margin(tiny)) ///
	xtitle("") ///
	title("{bf: Marginal effects imputed from Probit Regression}" , position (12) span) ///
	subtitle("{bf:Dependent variable: Intend to access SRH services for issues post sex}" ///
	" " ///
	"{it: Specification includes controls; bars reflect 90% CI}" , position (12) span) ///
	ciopts(recast(cap) msize(small)) ///
	plotopts(barwidth(0.5) color(navy*.6)) ///
	b1title("{it:Time Period Dummy: Midline/Endline}", height(5) size(mediumsmall))
  graph export "`outpath'Graph/GE_intend_accesssex_C.png", as(png) replace	

reg future_sexprob timePd qii_age_last_bday qvi_household_exp marriage_status ///
education heard_mtv heard_cj [pw=weightBlock], cluster(block_code) level(90)
 
 
**********************************************************************************************************************************************************************************************************************************
**********************************************************************************************************************************************************************************************************************************

****** SECTION 11: SAMPLE BALANCE TESTS************
*For Baseline and Endline 
u `GEData_be', clear

**Chi-square test for Categorical Vars
tab qii_age_last_bday  timePd , m  chi2
tab q102_study_yesorno timePd ,m chi2
tab q102a_study_what timePd , m chi2
tab q102b_education_level timePd , m chi2
tab q103_employment_status timePd , m chi2
tab hhs_income timePd , m  chi2
tab q101a_relationship_status timePd , m  chi2


** T -Test for Binary Vars
replace q101_marriage_status= 2 if q101_marriage_status== 99
ttest q101_marriage_status, by(timePd)

*For Midline and Endline 
**Chi-square test for Categorical Vars
u `GEData_me', clear
tab qii_age_last_bday  timePd , m  chi2
tab q102_study_yesorno timePd ,m chi2
tab q102a_study_what timePd , m chi2
tab q102b_education_level timePd , m chi2
tab q103_employment_status timePd , m chi2
tab hhs_income timePd , m  chi2

** T -Test for Binary Vars
ttest q101_marriage_status, by(timePd)
ttest q101a_relationship_status, by(timePd)

clear

**********************************************************************************************************************************************************************************************************************************
**********************************************************************************************************************************************************************************************************************************

*SECTION 12 :SUB GROUP ANALYSIS 
*REFERENCE: https://stats.idre.ucla.edu/stata/faq/how-can-i-make-a-bar-graph-with-error-bars/

*1.	Girls know that they are more likely to get pregnant halfway between their periods 
u `GEData_e', clear

*Calculate mean & sd by heard of CJ
collapse (mean) meanpreg_period= preg_period (sd) sdpreg_period=preg_period (count) n=preg_period, by(heard_cj)

*Generate upper & lower bounds of confidence interval  (at 90%)
generate himeanpreg_period = meanpreg_period + invttail(n-1,0.05)*(sdpreg_period / sqrt(n))
generate lowmeanpreg_period = meanpreg_period - invttail(n-1,0.05)*(sdpreg_period / sqrt(n))

replace meanpreg_period=meanpreg_period*100
replace himeanpreg_period=himeanpreg_period*100
replace lowmeanpreg_period=lowmeanpreg_period*100

su himeanpreg_period if heard_cj==0
return list
local m `r(max)'

su n if heard_cj==0
return list
local n1 `r(sum)'

su n if heard_cj==1
return list
local n2 `r(sum)'

list himeanpreg_period if heard_cj==0
list lowmeanpreg_period if heard_cj==0
*36.91-41.44

list himeanpreg_period if heard_cj==1
list lowmeanpreg_period if heard_cj==1
*41.55-49.45

*Significant (CI's are not overlapping)

*Create graph
twoway (bar meanpreg_period heard_cj if heard_cj == 1, bcolor(orange*0.9) barwidth(0.5)) ///
(bar meanpreg_period heard_cj if heard_cj == 0, bcolor(blue*0.9) barwidth(0.5)) ///
(rcap himeanpreg_period lowmeanpreg_period heard_cj, color(red)), ///
legend(off) ///
xlabel( -1 " " 0 "Not Aware of CJ(N=`n1')" 1 "Aware of CJ(N=`n2')" 2 " ", noticks) ///
b1title("") ///
yscale(range(0, .1 )) ylabel(#10) plotregion(margin(0)) ///
xtitle(" ")ytitle("Proportion of respondents who agree") ///
title("{bf:Proportion of Respondents across exposure to Chhaa Jhaa}" , position (12) span) ///
subtitle("{it:Question: Likely to get pregnant b/w periods}") || scatteri `m' -1 `m' 2 , recast(line) lpattern(dot) lcolor(black)

*Save Graph 
graph export "`outpath'SBGraph1/preg_period.png", as(png) replace


clear 

u `GEData_e', clear

*2. Girls intend to use contraception at next/first sex
*Calculate mean & sd by heard of CJ 
collapse (mean) meancontra_nextsex= contra_nextsex (sd) sdcontra_nextsex=contra_nextsex (count) n=contra_nextsex, by(heard_cj)

*Generate upper & lower bounds of confidence interval  (at 90%)
generate himeancontra_nextsex = meancontra_nextsex + invttail(n-1,0.05)*(sdcontra_nextsex/ sqrt(n))
generate lowmeancontra_nextsex = meancontra_nextsex - invttail(n-1,0.05)*(sdcontra_nextsex / sqrt(n))

replace meancontra_nextsex=meancontra_nextsex*100
replace himeancontra_nextsex=himeancontra_nextsex*100
replace lowmeancontra_nextsex=lowmeancontra_nextsex*100

su himeancontra_nextsex if heard_cj==0
return list
local m `r(max)'

su n if heard_cj==0
return list
local n1 `r(sum)'

su n if heard_cj==1
return list
local n2 `r(sum)'

list himeancontra_nextsex if heard_cj==0
list lowmeancontra_nextsex if heard_cj==0
*22.28 - 26.19

list himeancontra_nextsex if heard_cj==1
list lowmeancontra_nextsex if heard_cj==1
*26.17-33.42

*Insignificant (CI's are overlapping)

*Create graph
twoway (bar meancontra_nextsex heard_cj if heard_cj == 1, bcolor(orange*0.9) barwidth(0.5)) ///
(bar meancontra_nextsex heard_cj if heard_cj == 0, bcolor(blue*0.9) barwidth(0.5)) ///
(rcap himeancontra_nextsex lowmeancontra_nextsex heard_cj, color(red)), ///
legend(off) ///
xlabel( -1 " " 0 "Not Aware of CJ(N=`n1')" 1 "Aware of CJ(N=`n2')" 2 " ", noticks) ///
b1title("") ///
yscale(range(0, .1 )) ylabel(#10) plotregion(margin(0)) ///
xtitle(" ")ytitle("Proportion of respondents who agree") ///
title("{bf: Proportion of Respondents across exposure to Chhaa Jhaa}" , position (12) span) ///
subtitle("{it:Question: Contraception for next/first Sex}") || scatteri `m' -1 `m' 2 , recast(line) lpattern(dot) lcolor(black)

*Save Graph 
graph export "`outpath'SBGraph1/contra_nextsex.png", as(png) replace


*3. Girls who know a condom is suitable method to prevent pregnancy suitable_method
*Calculate mean & sd by heard of CJ

u `GEData_e', clear

collapse (mean) meancondom_suitable= condom_suitable (sd) sdcondom_suitable=condom_suitable (count) n=condom_suitable, by(heard_cj)

*Generate upper & lower bounds of confidence interval  (at 90%)
generate himeancondom_suitable = meancondom_suitable + invttail(n-1,0.05)*(sdcondom_suitable/ sqrt(n))
generate lowmeancondom_suitable = meancondom_suitable- invttail(n-1,0.05)*(sdcondom_suitable / sqrt(n))

replace meancondom_suitable=meancondom_suitable*100
replace himeancondom_suitable=himeancondom_suitable*100
replace lowmeancondom_suitable=lowmeancondom_suitable*100

su himeancondom_suitable if heard_cj==0
return list
local m `r(max)'

su n if heard_cj==0
return list
local n1 `r(sum)'

su n if heard_cj==1
return list
local n2 `r(sum)'

list himeancondom_suitable if heard_cj==0
list lowmeancondom if heard_cj==0

list himeancondom_suitable if heard_cj==1
list lowmeancondom if heard_cj==1


*Create graph
twoway (bar meancondom_suitable heard_cj if heard_cj == 1, bcolor(orange*0.9) barwidth(0.5)) ///
(bar meancondom_suitable heard_cj if heard_cj == 0, bcolor(blue*0.9) barwidth(0.5)) ///
(rcap himeancondom_suitable lowmeancondom_suitable heard_cj, color(red)), ///
legend(off) ///
xlabel( -1 " " 0 "Not Aware of CJ(N=`n1')" 1 "Aware of CJ(N=`n2')" 2 " ", noticks) ///
b1title("") ///
yscale(range(0, .1 )) ylabel(#10) plotregion(margin(0)) ///
xtitle(" ")ytitle("Proportion of respondents who agree") ///
title("{bf: Proportion of Respondents across exposure to Chhaa Jhaa}" , position (12) span) ///
subtitle("{it:Question: Condom is suitable to prevent pregnancy}") || scatteri `m' -1 `m' 2 , recast(line) lpattern(dot) lcolor(black)

*Save Graph 
graph export "`outpath'SBGraph1/condom_suitable.png", as(png) replace
 

*4.girls who think condoms are an effective way of protecting against HIV/AIDs

u `GEData_e', clear

*Calculate mean & sd by heard of CJ
collapse (mean) meancondom_protect= condom_protect (sd) sdcondom_protect=condom_protect (count) n=condom_protect, by(heard_cj)

*Generate upper & lower bounds of confidence interval  (at 90%)
generate himeancondom_protect = meancondom_protect + invttail(n-1,0.05)*(sdcondom_protect/ sqrt(n))
generate lowmeancondom_protect = meancondom_protect- invttail(n-1,0.05)*(sdcondom_protect / sqrt(n))

replace meancondom_protect=meancondom_protect*100
replace himeancondom_protect=himeancondom_protect*100
replace lowmeancondom_protect=lowmeancondom_protect*100

su himeancondom_protect if heard_cj==0
return list
local m `r(max)'

su n if heard_cj==0
return list
local n1 `r(sum)'

su n if heard_cj==1
return list
local n2 `r(sum)'

list himeancondom_protect if heard_cj==0
list lowmeancondom_protect if heard_cj==0

list himeancondom_protect if heard_cj==1
list lowmeancondom_protect if heard_cj==1



*Create graph
twoway (bar meancondom_protect heard_cj if heard_cj == 1, bcolor(orange*0.9) barwidth(0.5)) ///
(bar meancondom_protect heard_cj if heard_cj == 0, bcolor(blue*0.9) barwidth(0.5)) ///
(rcap himeancondom_protect lowmeancondom_protect heard_cj, color(red)), ///
legend(off) ///
xlabel( -1 " " 0 "Not Aware of CJ(N=`n1')" 1 "Aware of CJ(N=`n2')" 2 " ", noticks) ///
b1title("") ///
yscale(range(0, .1 )) ylabel(#10) plotregion(margin(0)) ///
xtitle(" ")ytitle("Proportion of respondents who agree") ///
title("{bf: Proportion of Respondents across exposure to Chhaa Jhaa}" , position (12) span) ///
subtitle("{it:Question: Condom can protect against HIV/STI}") || scatteri `m' -1 `m' 2 , recast(line) lpattern(dot) lcolor(black)

*Save Graph 
graph export "`outpath'SBGraph1/condom_protect.png", as(png) replace
 
*5. girls access an SRH service in the last 6 months
u `GEData_e', clear

*Calculate mean & sd by heard of CJ
collapse (mean) meanacc_serv_SRH= acc_serv_SRH (sd) sdacc_serv_SRH=acc_serv_SRH (count) n=acc_serv_SRH, by(heard_cj)

*Generate upper & lower bounds of confidence interval  (at 90%)
generate himeanacc_serv_SRH = meanacc_serv_SRH + invttail(n-1,0.05)*(sdacc_serv_SRH/ sqrt(n))
generate lowmeanacc_serv_SRH = meanacc_serv_SRH - invttail(n-1,0.05)*(sdacc_serv_SRH / sqrt(n))

replace meanacc_serv_SRH=meanacc_serv_SRH*100
replace himeanacc_serv_SRH=himeanacc_serv_SRH*100
replace lowmeanacc_serv_SRH=lowmeanacc_serv_SRH*100

su himeanacc_serv_SRH if heard_cj==0
return list
local m `r(max)'

su n if heard_cj==0
return list
local n1 `r(sum)'

su n if heard_cj==1
return list
local n2 `r(sum)'


list himeanacc_serv_SRH if heard_cj==0
list lowmeanacc_serv_SRH if heard_cj==0
*82.43- 87.98

list himeanacc_serv_SRH if heard_cj==1
list lowmeanacc_serv_SRH if heard_cj==1
*87.99-94.97

*Significant (CI's are not overlapping)

*Create graph
twoway (bar meanacc_serv_SRH heard_cj if heard_cj == 1, bcolor(orange*0.9) barwidth(0.5)) ///
(bar meanacc_serv_SRH heard_cj if heard_cj == 0, bcolor(blue*0.9) barwidth(0.5)) ///
(rcap himeanacc_serv_SRH lowmeanacc_serv_SRH heard_cj, color(red)), ///
legend(off) ///
xlabel( -1 " " 0 "Not Aware of CJ (N=`n1')" 1 "Aware of CJ(N=`n2')" 2 " ", noticks) ///
b1title("") ///
yscale(range(0, .1 )) ylabel(#10) plotregion(margin(0)) ///
xtitle(" ")ytitle("Proportion of respondents who agree") ///
title("{bf: Proportion of Respondents across exposure to Chhaa Jhaa}" , position (12) span) ///
subtitle("{it:Question: Access SRH Services in the last 6 months}") || scatteri `m' -1 `m' 2 , recast(line) lpattern(dot) lcolor(black)

*Save Graph 
graph export "`outpath'SBGraph1/acc_serv_SRH.png", as(png) replace



*6. Girls who used contraception at last sex
u `GEData_e', clear

*Calculate mean & sd by heard of CJ
collapse (mean) meancontra_lastsex= contra_lastsex (sd) sdcontra_lastsex=contra_lastsex (count) n=contra_lastsex, by(heard_cj)

*Generate upper & lower bounds of confidence interval  (at 90%)
generate himeancontra_lastsex = meancontra_lastsex + invttail(n-1,0.05)*(sdcontra_lastsex/ sqrt(n))
generate lowmeancontra_lastsex = meancontra_lastsex- invttail(n-1,0.05)*(sdcontra_lastsex / sqrt(n))

replace meancontra_lastsex=meancontra_lastsex*100
replace himeancontra_lastsex=himeancontra_lastsex*100
replace lowmeancontra_lastsex=lowmeancontra_lastsex*100

su himeancontra_lastsex if heard_cj==0
return list
local m `r(max)'

su n if heard_cj==0
return list
local n1 `r(sum)'

su n if heard_cj==1
return list
local n2 `r(sum)'

list himeancontra_lastsex if heard_cj==0
list lowmeancontra_lastsex if heard_cj==0
*82.43- 87.98

list himeancontra_lastsex if heard_cj==1
list lowmeancontra_lastsex if heard_cj==1


*Create graph
twoway (bar meancontra_lastsex heard_cj if heard_cj == 1, bcolor(orange*0.9) barwidth(0.5)) ///
(bar meancontra_lastsex heard_cj if heard_cj == 0, bcolor(blue*0.9)barwidth(0.5)) ///
(rcap himeancontra_lastsex lowmeancontra_lastsex heard_cj, color(red)), ///
legend(off) ///
xlabel( -1 " " 0 "Not Aware of CJ(N=`n1')" 1 "Aware of CJ(N=`n2')" 2 " ", noticks) ///
b1title("") ///
yscale(range(0, .1 )) ylabel(#10) plotregion(margin(0)) ///
xtitle(" ")ytitle("Proportion of respondents who agree") ///
title("{bf: Proportion of Respondents across exposure to Chhaa Jhaa}" , position (12) span) ///
subtitle("{it:Question:Used contraception last sex}") || scatteri `m' -1 `m' 2 , recast(line) lpattern(dot) lcolor(black)

*Save Graph 
graph export "`outpath'SBGraph1/contra_lastsex.png", as(png) replace


*7. Proportion of girls intend to access SRH   services 
// if experiencing ulcers, infections, or pain in their private parts

u `GEData_e', clear

*Calculate mean & sd by heard of CJ
collapse (mean) meanfuture_pvt= future_pvt (sd) sdfuture_pvt=future_pvt (count) n=future_pvt, by(heard_cj)

*Generate upper & lower bounds of confidence interval  (at 90%)
generate himeanfuture_pvt = meanfuture_pvt + invttail(n-1,0.05)*(sdfuture_pvt / sqrt(n))
generate lowmeanfuture_pvt = meanfuture_pvt- invttail(n-1,0.05)*(sdfuture_pvt / sqrt(n))

replace meanfuture_pvt=meanfuture_pvt*100
replace himeanfuture_pvt=himeanfuture_pvt*100
replace lowmeanfuture_pvt=lowmeanfuture_pvt*100


su himeanfuture_pvt if heard_cj==0
return list
local m `r(max)'

su n if heard_cj==0
return list
local n1 `r(sum)'

su n if heard_cj==1
return list
local n2 `r(sum)'

list himeanfuture_pvt if heard_cj==0
list lowmeanfuture_pvt if heard_cj==0
*94.21 - 96.16

list himeanfuture_pvt if heard_cj==1
list lowmeanfuture_pvt if heard_cj==1
*96.5-98.88

*Insignificant (CI's are overlapping)


*Create graph
twoway (bar meanfuture_pvt heard_cj if heard_cj == 1, bcolor(orange*0.9) barwidth(0.5)) ///
(bar meanfuture_pvt heard_cj if heard_cj == 0, bcolor(blue*0.9) barwidth(0.5)) ///
(rcap himeanfuture_pvt lowmeanfuture_pvt heard_cj, color(red)), ///
legend(off) ///
xlabel( -1 " " 0 "Not Aware of CJ(N=`n1')" 1 "Aware of CJ(N=`n2')" 2 " ", noticks) ///
b1title("") ///
yscale(range(0, .1 )) ylabel(#10) plotregion(margin(0)) ///
xtitle(" ")ytitle("Proportion of respondents who agree") ///
title("{bf: Proportion of Respondents across exposure to Chhaa Jhaa}" , position (12) span) ///
subtitle("{it:Question:Intend to access SRH services for infections}") || scatteri `m' -1 `m' 2 , recast(line) lpattern(dot) lcolor(black)

*Save Graph 
graph export "`outpath'SBGraph1/GE_accSRH_inf.png", as(png) replace

*8.Proportion of girls intend to access SRH services 
//if experiencing any menstruation-related issues

u `GEData_e', clear

*Calculate mean & sd by heard of CJ
collapse (mean) meanfuture_period= future_period (sd) sdfuture_period=future_period (count) n=future_period, by(heard_cj)

*Generate upper & lower bounds of confidence interval (at 90%)
generate himeanfuture_period = meanfuture_period + invttail(n-1,0.05)*(sdfuture_period / sqrt(n))
generate lowmeanfuture_period = meanfuture_period- invttail(n-1,0.05)*(sdfuture_period / sqrt(n))

replace meanfuture_period=meanfuture_period*100
replace himeanfuture_period=himeanfuture_period*100
replace lowmeanfuture_period=lowmeanfuture_period*100

su himeanfuture_period  if heard_cj==0
return list
local m `r(max)'

su n if heard_cj==0
return list
local n1 `r(sum)'

su n if heard_cj==1
return list
local n2 `r(sum)'

list himeanfuture_period if heard_cj==0
list lowmeanfuture_period if heard_cj==0


list himeanfuture_period if heard_cj==1
list lowmeanfuture_period if heard_cj==1



*Create graph
twoway (bar meanfuture_period heard_cj if heard_cj == 1, bcolor(orange*0.9) barwidth(0.5)) ///
(bar meanfuture_period heard_cj if heard_cj == 0, bcolor(blue*0.9) barwidth(0.5)) ///
(rcap himeanfuture_period lowmeanfuture_period heard_cj, color(red)), ///
legend(off) ///
xlabel( -1 " " 0 "Not Aware of CJ(N=`n1')" 1 "Aware of CJ(N=`n2')" 2 " ", noticks) ///
b1title("") ///
yscale(range(0, .1 )) ylabel(#10) plotregion(margin(0)) ///
xtitle(" ")ytitle("Proportion of respondents who agree") ///
title("{bf: Proportion of Respondents across exposure to Chhaa Jhaa}" , position (12) span) ///
subtitle("{it:Question:Intend to access SRH services for menstural issues}") || scatteri `m' -1 `m' 2 , recast(line) lpattern(dot) lcolor(black)

*Save Graph 
*graph export "`outpath'SBGraph1/GE_accSRH_period.png", as(png) replace


*9.Proportion of girls intend to access SRH services 
// if experiencing issues after sex

u `GEData_e', clear

*Calculate mean & sd by heard of CJ
collapse (mean) meanfuture_sexprob= future_sexprob (sd) sdfuture_sexprob=future_sexprob (count) n=future_sexprob, by(heard_cj)

*Generate upper & lower bounds of confidence interval (at 90%)
generate himeanfuture_sexprob = meanfuture_sexprob + invttail(n-1,0.05)*(sdfuture_sexprob / sqrt(n))
generate lowmeanfuture_sexprob = meanfuture_sexprob- invttail(n-1,0.05)*(sdfuture_sexprob / sqrt(n))

replace meanfuture_sexprob=meanfuture_sexprob*100
replace himeanfuture_sexprob=himeanfuture_sexprob*100
replace lowmeanfuture_sexprob=lowmeanfuture_sexprob*100

su himeanfuture_sexprob if heard_cj==0
return list
local m `r(max)'

su n if heard_cj==0
return list
local n1 `r(sum)'

su n if heard_cj==1
return list
local n2 `r(sum)'

list himeanfuture_sexprob if heard_cj==0
list lowmeanfuture_sexprob if heard_cj==0


list himeanfuture_sexprob if heard_cj==1
list lowmeanfuture_sexprob if heard_cj==1

*Create graph
twoway (bar meanfuture_sexprob heard_cj if heard_cj == 1, bcolor(orange*0.9) barwidth(0.5)) ///
(bar meanfuture_sexprob heard_cj if heard_cj == 0, bcolor(blue*0.9) barwidth(0.5)) ///
(rcap himeanfuture_sexprob lowmeanfuture_sexprob heard_cj, color(red)), ///
legend(off) ///
xlabel( -1 " " 0 "Not Aware of CJ(N=`n1')" 1 "Aware of CJ(N=`n2')" 2 " ", noticks) ///
b1title("") ///
yscale(range(0, .1 )) ylabel(#10) plotregion(margin(0)) ///
xtitle(" ")ytitle("Proportion of respondents who agree") ///
title("{bf:Proportion of Respondents across exposure to Chhaa Jhaa }" , position (12) span) ///
subtitle("{it:Question: Intend to access SRH services for issues post sex:}") || scatteri `m' -1 `m' 2 , recast(line) lpattern(dot) lcolor(black)

*Save Graph 
*graph export "`outpath'SBGraph1/GE_accSRH_sex.png", as(png) replace
























	
