/*----------------------------------------------------
Clean 2022 USC Citation count and merge to RegData

----------------------------------------------------*/
clear all
cd "/Users/jimenakiser/liegroup Dropbox/Jimena Villanueva Kiser/cfr_env/cfr_xml/"

import delimited using "CFR-2022/USCtable2022.csv", clear varnames(1)

drop if strpos(firstline, "NERS AND PARTNERSHIPS")
split firstline, gen(pname) parse(—)
drop pname2 pname3 pname4

split pname, gen(psubnames)
replace pname = psubnames1 if psubnames2!=""
replace pname = "1" if pname1=="1-POSTAL"
drop if pname == "S"

rename pname1 partraw
drop psubnames1 psubnames2 psubnames3 psubnames4
replace partraw = strlower(partraw)
split partraw , gen(subpart) parse(-)
replace partraw = subpart1 if !mi(subpart2)
gen partstr = partraw
forval i = 0/9 {
	replace partstr = subinstr(partstr, "`i'", "", .)
}
replace partraw = subinstr(partraw, partstr, "", .)
destring partraw, replace

gen title = substr(filename, 16, 2)
replace title = subinstr(title, "/", "" ,.)
destring title, replace

drop subpart1 subpart2 partstr

collapse (sum) uscact* , by(title partraw)
order title partraw

forval i = 1/9 {
	rename uscact0`i' uscact`i'
}

reshape long uscact , i(title partraw) j(ActNumber)
rename uscact citcount 

isid title part ActNumber
sort title part ActNumber
gen year = 2022
rename partraw part

compress 
save "2022_USC_count", replace

use "2022_USC_count", clear 
collapse (sum) citcount, by(title part year )

tab citcount
count if citcount>0 // about (644 parts) 8.31% of documents have some mention of an environmental act citation

tempfile uscdocs
save `uscdocs', replace


* pull regdata 2022 
use if year == 2022 using "/Users/jimenakiser/liegroup Dropbox/Jimena Villanueva Kiser/NEPA/crosswalk250207/naics_docs_1970_2022.dta"

merge m:1 title part using `uscdocs', nogen keep( 3) //master 75,080, using 5, matched 951,962







