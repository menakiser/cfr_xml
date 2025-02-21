/*----------------------------------------------------
Clean USC Citation count and merge to RegData
for all years 1997-2009 (for now)
02/21/25
----------------------------------------------------*/
clear all
cd "/Users/jimenakiser/liegroup Dropbox/Jimena Villanueva Kiser/cfr_xml/"


import delimited using "USCtable1997_2022.csv", clear varnames(1)

* verify file only includes only the corresponding year
gen year = substr(filename, 5, 4)
destring year, replace
tab year

drop if strpos(firstline, "NERS AND PARTNERSHIPS")
split firstline, gen(pname) parse(—)
drop pname2 pname3 pname4

split pname, gen(psubnames)
replace pname = psubnames1 if psubnames2!=""
replace pname = "1" if pname1=="1-POSTAL"
drop if pname == "S"

rename pname1 partraw
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

drop psubnames1 psubnames2 psubnames3 psubnames4 subpart1 subpart2 partstr
tab firstline if mi(partraw)
tab year if mi(partraw) & strpos(firstline, "<?xml")==0
drop if mi(partraw) //firstline==<?xml version="1.0" encoding="UTF-8"?> or appendix lines

collapse (sum) uscact* , by(title partraw year)
order title partraw

forval i = 1/9 {
	rename uscact0`i' uscact`i'
}

reshape long uscact , i(title partraw year) j(ActNumber)
rename uscact citcount 

isid title part ActNumber year
sort title part ActNumber
rename partraw part

compress 
save "USC_count_1997_2022", replace

use "USC_count_1997_2022", clear 
collapse (sum) citcount, by(title part year )
tab year //8,111 in 2022

tab citcount
count if citcount>0 // about (687 parts) 8.78% of documents have some mention of an environmental act citation

tempfile uscdocs
save `uscdocs', replace


* pull regdata 1997-2022 
use if year<=2022 & year>=1997 using "/Users/jimenakiser/liegroup Dropbox/Jimena Villanueva Kiser/NEPA/crosswalk250207/naics_docs_1970_2022.dta"
drop if strpos(document_reference, "Partition")!=0

egen docyrtag = tag( document_reference year)
tab docyrtag

merge m:1 title part using `uscdocs'


, nogen keep( 3) //master 75,080, using 5, matched 951,962


