/*----------------------------------------------------
Clean USC Citation count and merge to RegData
for all years 1997-2022 permitting statutes
02/24/25
----------------------------------------------------*/
clear all
cd "/Users/jimenakiser/liegroup Dropbox/Jimena Villanueva Kiser/cfr_xml/"


import delimited using "USC1997_2022perm.csv", clear varnames(1)

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
save "USC_count_1997_2022perm", replace

/*--------2022--------*/
use "USC_count_1997_2022perm", clear 
collapse (sum) citcount, by(title part year )
keep if year ==2022
tab year //8,111 in 2022

tab citcount 
count if citcount>0  // about (778 parts) 9.6% of documents have some mention of an environmental act citation
isid title part year
tempfile uscdocs2022
save `uscdocs2022', replace

use if year==2022 using "/Users/jimenakiser/liegroup Dropbox/Jimena Villanueva Kiser/NEPA/crosswalk250207/naics_docs_1970_2022.dta"
drop if strpos(document_reference, "Partition")!=0

egen docyrtag = tag( document_reference year)
tab docyrtag //8,621 unique documents in 2022

merge m:1 title part year using `uscdocs2022'
ereplace docyrtag = tag( document_reference year _m )
tab docyrtag _m
keep if _m==3
tab citcount if docyrtag == 1 //(776) 19.58% have some citation

/*--------1997-2022--------*/
use "USC_count_1997_2022perm", clear 
collapse (sum) citcount, by(title part year )
tab year //198,189 from 1997-2022
isid title part year
tempfile uscdocs
save `uscdocs', replace

use if year<=2022 & year>=1997 using "/Users/jimenakiser/liegroup Dropbox/Jimena Villanueva Kiser/NEPA/crosswalk250207/naics_docs_1970_2022.dta"
drop if strpos(document_reference, "Partition")!=0

egen docyrtag = tag( document_reference year)
tab docyrtag // 205,265 from 1997-2022

merge m:1 title part year using `uscdocs'
ereplace docyrtag = tag( document_reference year _m )
tab docyrtag _m
keep if _m==3
count //197,345 matched
tab citcount if docyrtag == 1 //(18,738) 9.5% have some citation



use "USC_count_1997_2022perm", clear 
collapse (sum) citcount, by(ActNumber)
sort citcount
