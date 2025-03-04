/* Overleaf updating exercise
3/4/25
*/
clear all
global wd "/Users/jimenakiser/liegroup Dropbox/Jimena Villanueva Kiser/"
cd "$wd/env_permitting/"

use "data/project_dodge_SEPA", clear
keep if !missing(value_000s)
gen value_B = value_000s/1000000
collapse (sum) value_B, by(state first_year)

twoway (hist value_B, frequency), xtitle("") ytitle("") title("Construction Investment (B) by State and Year")
graph export "/Users/jimenakiser/liegroup Dropbox/Jimena Villanueva Kiser/cfr_xml/histinv.jpg", replace

* store mean of distribution
cap file close sumstat
file open sumstat using "/Users/jimenakiser/liegroup Dropbox/Jimena Villanueva Kiser/cfr_xml/mean1.tex", write replace
sum value_B
local valuemean = r(mean)
file write sumstat "`valuemean'" _n
file close sumstat
