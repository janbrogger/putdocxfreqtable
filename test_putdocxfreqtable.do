capture program drop putdocxfreqtable
sysuse auto , clear
egen pricecat = cut(price), at(0,5000,10000,999999) label
*egen pricecat = cut(price), at(0,5000,10000,999999) 
label variable pricecat "Price (categorical)"
tab pricecat

putdocx clear
putdocx begin
putdocxfreqtable pricecat 
putdocxfreqtable pricecat , nosum
putdocxfreqtable pricecat , nocum
putdocxfreqtable pricecat , nocum nosum

putdocx save "auto.docx", replace
