cap prog drop mimixpre
program define mimixpre, rclass 
version 13.0

*use "C:\Users\rmjlkm0\Documents\nstage code\asthma.dta", clear
syntax varlist, time(varname) id(varname) [ COVariates(varlist) methodvar(varname) METHOD(string) refgroupvar(varname) REFgroup(str) SAVing(string) clear m(integer 5) BURNin(integer 100) BURNBetween(integer 100) seed(integer 0) interim(string) iref(str) mixed regress]

preserve
*PRE-PROCESSING AND ERROR CHECKING
tempfile orig_data add_data mimix_d1 my_treat my_time mimix_d2 treat_code  int_out mimix_mj0 id_code
tempvar  flag1  mimix_method pattern indicator dupcheck  miss_ind mimix_time mimix_treat  nvals nobs mimix_intern_req numerical_id
*NOTE: refgroupvar methodvar mimix_refgroupvar ARE TEMPVAR's CREATED LATER ON


if `seed' > 0 set seed `seed'
local state = c(seed)
return local rseed `state'
if "`saving'" == "" & "`clear'" == "" {
	display as error "saving() and/or clear required"
	exit 100
}
if "`saving'" != "" {
	tokenize "`saving'", parse(",")
	local filename `1'
	local replace `3'
	if "`replace'" == "" {
		confirm new file `filename'.dta
	}
	if "`replace'" != "" {
		if "`replace'" != "replace" {
		display as error "option saving, `replace' not allowed"
		exit 198
		}
	}
}

cap confirm numeric variable `id' 
local id_num =  _rc
confirm numeric variable `time'
qui summ `time'
local maxtime=r(max)
qui inspect `time'
local ntime=r(N_unique)

	
*SAVE THE ORIGINAL DATA
qui save `orig_data'
local order ""
foreach var of varlist * {
	local order `order' `var' 
}
	
*SAVE THE DATA THAT WILL NOT BE SENT INTO MATA TO ADD TO IMPUTED DATA AT END
qui {
    capture drop `varlist'
    capture drop `covariates'
    sort `id' `time'
    save `add_data'
    use `orig_data' , clear
}

*PROCESS COVARIATES: TOKENIZE THEN CHECK COMPLETENESS
tokenize `covariates'
if "`*'" != "" {
    confirm numeric variable `1'
	local i = 1
	local cov`i' `1'
	macro shift
	while "`*'" != "" {
		confirm numeric variable `1'
		local i = `i' + 1
		local cov`i' `1'
		macro shift
	}
	local ncov `i'
	mata: mata_covflag = J(`ncov',1,0)
	mata: mata_covflag_nm = J(`ncov',1,1)
}

*VARIABLES TO BE IMPUTED IN mi impute mvn 
local mi_impute = ""
local res_list = ""
forvalues i = 1/`ntime' {
	local mi_impute = "`mi_impute' `response'`i'"
	if `i'!=`ntime'{
		local res_list = "`res_list' `response'`i'==. |"
	}
	else {
		local res_list = "`res_list' `response'`i'==."
	}
}	
if "`covariates'"!=""	{
	local mi_impute = "`mi_impute' `covariates'"
}
di "`mi_impute'"


end
* end mimixpre