use "/Users/osarr/Documents/Econ thesis /Updated Anonymized Weighted FinAccess 2021.dta"

********* Install packages 
ssc install logout 


*********Data Cleaning

* Dropping inviduals without an ID
drop if U22__1 == 2

* distance to the closest agent 
gen distance = 0.25 if T3== 1
replace distance=0 if distance==.
replace distance= 0.75 if T3==2
replace distance= 2.25 if T3==3
replace distance= 4.5 if T3==4
replace distance= 9 if T3==5
drop if distance==0

* Animal Ownership
egen total_animal = rowtotal(U17i U17ii U17iii U17iv U17v)
label var total_animal "number of anaimal owned"
keep if total_animal >=0

* Failure to take a loan or not 
gen loan_failure= 1 if E1== 1
replace loan_failure=0 if loan_failure==.
label var loan_failure " denied to take a loan or not"

*meet regular spendig or not 
gen regular_spending= 1 if R1A== 1
replace regular_spending=0 if regular_spending==.
label var regular_spending " able to meet regular spending need"

* Total loans 
egen total_loan = rowtotal(E1xA E1xB E1xC E1xD E1xE E1xF E1xG E1xH E1xL E1xJ E1xK E1xL E1xM E1xN E1xO E1xP E1xQ E1xR E1xS) 
label var total_loan "amount outstanding on loans"
keep if total_loan >= 0


*Number of mobile money account 
egen total_mobile_money_account = rowtotal(K5i K5ii K5iii K5iv K5v K5vi)
label var total_mobile_money_account "number of mobile money account"
keep if total_mobile_money_account >= 0

***dummy variable for mobile money users
gen mm_dummy= 1 if C1_9 == 1
replace mm_dummy = 0 if mm_dummy == .
label var mm_dummy " dummy variable for mobile money use"

*yearly income
drop if B3I== 98
drop if B3I == 99
gen yearly_income= B3I*12
keep if yearly_income>=0
label var yearly_income "yearly income"

*dummy for monthly income
gen income_average_dummy = 1 if  B3I >  7433.073
replace income_average_dummy=0 if income_average_dummy==.
label var income_average "average income"

*dummy for bank account
gen bank_account = 1 if C1_28 == 1
replace bank_account= 0 if bank_account== .
label var bank_account "has a bank account or not"


*education level
drop if A21== 10
drop if A21== 98
drop if A21== 99
gen education_status = A21
lab var education_status "years of education"
replace education_status = 0 if A21 == 1
replace education_status = 4 if A21 == 2
replace  education_status = 8 if A21 == 3
replace  education_status= 10 if A21 == 4
replace  education_status= 12 if A21 == 5
replace  education_status= 13 if A21 == 6
replace  education_status= 14 if A21 ==7
replace  education_status = 14 if A21 ==8
replace  education_status = 16 if A21 ==9
lab var A21  "Years of education"
gen education_dummy= 1 if education_status>8
replace education_dummy= 0 if education_dummy==.
lab var education_dummy "has more than a primary school education"

*employment status
gen employment_dummy= 1 if B3A__2 == 1
replace employment_dummy =0 if employment_dummy ==.
label var employment_dummy " is employed or not" 

*mobile phone ownership
gen own_mobile = 1 if S1 == 1  
replace own_mobile=0 if own_mobile ==.
label var own_mobile " own a mobile phone or not" 

*knowledge on interest rate 
gen interest_rate =1 if B2F == 1
replace interest_rate =0 if interest_rate==.
label var interest_rate "know what interest rate is or not" 

* Debt to income ratio variable
gen debt_to_income_ratio= total_loan/yearly_income

* time to walk to an agent 
gen time_agent = 5 if T3== 1
replace time_agent=0 if distance==.
replace time_agent= 15 if T3==2
replace time_agent= 45 if T3==3
replace time_agent= 90 if T3==4
replace time_agent= 180 if T3==5
drop if time_agent==0

* Marital status
gen marital_status = 1 if A22== 4
replace marital_status=0 if marital_status==.
label var marital_status "maraital status"

* log of income variable
gen log_income= log(B3I)


* log of time to agent 

gen log_time= log(time_agent)

* INVERSE OF THE INSTRUMENT

gen inverse_instrument= 1/time_agent

*log of loans 

gen log_total_loan = log(total_loan)
replace log_total_loan=0 if log_total_loan==.


save, replace

clear
********* Summarry Statistic tables*************
************************************************


*** Categorical data

*mm users and gender  
tab mm_dummy A18, column


*mm users and residence  
tab mm_dummy A9,column

* mm users and average income 
tab income_average mm_dummy, row

** mm users and bank account 
tab mm_dummy bank_account, column

*mm users and completion of primary school 
tab education_dummy mm_dummy, row

* mm users and employment 
tab employment_dummy mm_dummy, row


* mm users and mobile money ownership 
tab own_mobile mm_dummy, row

* mm users and interest rate 
tab interest_rate mm_dummy, row

* mm users and failure to take a loans 
tab mm_dummy loan_failure, column

* mm users and meeting regular spending 
tab mm_dummy regular_spending, column


***** numerical data

*mm users and income 
sum yearly_income
sum yearly_income if mm_dummy==1
sum yearly_income if mm_dummy==0

*mm users and years of education 
sum education_status
sum education_status if mm_dummy==1
sum education_status if mm_dummy==0

*mm users and distance to agent
sum distance
sum distance if mm_dummy==1
sum distance if mm_dummy==0

*mm users and animal ownership
sum total_animal
sum total_animal if mm_dummy==1
sum total_animal if mm_dummy==0

*mm users and outstanding loans
sum total_loan
sum total_loan if mm_dummy==1
sum total_loan if mm_dummy==0

*mm users and time spent to access an agent 
sum time_agent
sum time_agent if mm_dummy==1
sum time_agent if mm_dummy==0

*mm users and debt to income ratio
sum debt_to_income_ratio
sum debt_to_income_ratio if mm_dummy==1
sum debt_to_income_ratio if mm_dummy==0


*EMPIRICAL STRATEGY
use "/Users/osarr/Documents/Econ thesis /Updated Anonymized Weighted FinAccess 2021.dta"
ssc install asdoc
ssc install estout
ssc instal ihstrans
ihstrans total_loan

* first stage IV regression 

****** using Probit model

probit mm_dummy time_agent A19 A18 A9 marital_status education_status B3I own_mobile employment_dummy loan_failure [pw=IndWeight], cluster(ClusterNo) 
eststo: margin, dydx(time_agent A19 A18 A9 marital_status education_status B3I own_mobile employment_dummy loan_failure)

****** using Linear probability model
eststo: regress mm_dummy time_agent A19 A18 A9 marital_status education_status own_mobile employment_dummy log_income loan_failure [pw=IndWeight],cluster(ClusterNo)
predict mm_dummyHat, xb

esttab using tablef.csv, title(table 2: Determinants of mobile money adoption) numbers mtitles("Probit marginal effects" "Linear probability model")
eststo clear

* Second stage regression

************ debt to income ratio

eststo: regress debt_to_income_ratio mm_dummyHat A19 A18 A9 marital_status education_status own_mobile employment_dummy loan_failure [pw= IndWeight], first cluster(ClusterNo)


************ Loans 

eststo: regress ihs_total_loan mm_dummyHat A19 A18 A9 marital_status education_status own_mobile employment_dummy loan_failure [pw= IndWeight], first cluster(ClusterNo)


************** income

eststo: regress log_income mm_dummyHat A19 A18 A9 marital_status education_status own_mobile employment_dummy loan_failure [pw= IndWeight], first cluster(ClusterNo)
 
esttab using table3.csv, keep(mm_dummyHat) title(Table 3: Mobile Money and financial health) numbers mtitles("Debt to income ratio" "loans" "Income")
eststo clear







