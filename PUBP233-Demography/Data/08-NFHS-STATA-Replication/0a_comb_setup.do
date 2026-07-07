/*                                                          annual health survey
                                                        constructing comb module
notes:
- this do-file does the following:
  . imports and saves each state;
  . builds a variable listing by state;
  . stacks and saves raw data;
- this do-file must be run before the other modules
																				*/

* set directory ----------------------------------------------------------------
* USER WILL NEED TO INPUT YOUR OWN PATH HERE
cd "D:\Projects\AHS-Coffey"

* ------------------------------------------------------------------------------


* set globals ------------------------------------------------------------------
* USER WILL NEED TO INPUT YOUR OWN PATH HERE
global inpt="input data"
global outp="Users/Life expectancy project/dofiles/public_dofiles"
global states 5 8 9 10 18 20 21 22 23

* ------------------------------------------------------------------------------



* import and save each state ---------------------------------------------------

foreach i of numlist $states {
  display "loading state `i'..."
  import delimited "./${inpt}/comb/`i'.csv", clear ///
                   delimiter("|") varnames(1) encoding(ISO-8859-1)
  quietly ds, has(type string)
  local strings `r(varlist)'
  foreach j of varlist `strings' {
    replace `j'="" if strpos(`j',"NULL")
	destring `j', replace
  }
  quietly ds, has(type numeric)
  local numbers `r(varlist)'
  foreach j of varlist `numbers' {
    replace `j'=.n if `j'==-999
  }
  label data "comb - raw (state `i')"
  save "./${outp}/comb_raw_`i'", replace
}

* ------------------------------------------------------------------------------


* create variable listing ------------------------------------------------------

foreach i of numlist $states {
  use "./${outp}/comb_raw_`i'" in 1, clear
  desc, replace clear
  gen string`i'=1-isnumeric
  drop format vallab varlab isnumeric
  rename (position type) (pos`i' type`i')
  order name
  tempfile state`i'
  save `state`i''
}
foreach i of numlist $states {
  if `i'==5 use `state5', clear
  else merge 1:1 name using `state`i'', gen(_m`i')
}
egen string=rowmax(string*)
egen consistent=rowsd(string*)
replace consistent=(consistent==0)
gen module="comb"
order module name string consistent
label data "comb - variable list"
save "./${outp}/comb_varlist", replace

* ------------------------------------------------------------------------------


* stack states and save unedited version ---------------------------------------

tempfile stack
foreach i of numlist $states {
  use "./${outp}/comb_varlist", clear
  levelsof name if string & ! string`i', local(need2fix) clean
  use "./${outp}/comb_raw_`i'", clear
  if ! missing("`need2fix'") {
    foreach j in `need2fix' {
      if strpos("`j'","fid")>0 tostring `j', replace format("%18.0f") force
      else tostring `j', replace
    }
  }
  if `i'>5 append using `stack'
  save `stack', replace
}
label data "comb - raw (all)"
save "./${outp}/comb_raw_all", replace

* ------------------------------------------------------------------------------