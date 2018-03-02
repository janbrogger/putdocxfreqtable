*! Original author : Jan Brogger (jan@brogger.no)
*! Description     : Produces frequency oneway tables with putdocx.
*! Maintained at   : https://github.com/janbrogger/putdocxfreqtable
capture program drop putdocxfreqtable
program define putdocxfreqtable
	version 15.1
	syntax varlist(min=1 max=1) , [noCUM] [noSUM]
	capture putdocx describe
	if _rc {
		di in smcl as error "ERROR: No active docx."
		exit = 119
	}
		
	preserve	
	tempname freq percent cumcount cumpercent
	contract `varlist' , freq(`freq')
			
	//Add sum row
	if "`sum'"!="nosum" {
		qui count
		local newobs= `r(N)'+1
		qui set obs `newobs'
		capture confirm numeric variable `varlist'
		if !_rc {
			qui replace `varlist'=. if _n==_N
		}
		else {
			qui replace `varlist'="" if _n==_N
		}
		qui summ `freq'
		qui replace `freq'=`r(sum)' if _n==_N		
	}
	
	order `varlist'
	qui summ `freq' if _n<_N
	gen `percent'=`freq'/`r(sum)'*100
	gen `cumcount' = sum(`freq')	
	qui summ `freq' if _n<_N
	gen `cumpercent'= `cumcount'/`r(sum)'*100	
	drop `cumcount'
	format `percent' `cumpercent' %3.1f
	label variable `freq' "Count"
	label variable `percent' "%"
	label variable `cumpercent' "Cumulative %"
	
	if "`sum'"!="nosum" {
		qui replace `cumpercent'=. if _n==_N
	}
	
	

	if "`cum'"=="nocum" {
		local matvars `freq' `percent' 
		local colnames `""Count" "%" "'
	}
	else {
		local matvars `freq' `percent' `cumpercent' 
		local colnames `""Count" "%" "Cum. %""'
	}
	
	mkmat `matvars' , mat(data)	
			
	//Fix rownames
	local lbe : value label `varlist'
	qui levelsof `varlist' , local(levels)
	local rownames ""
	
	
	foreach l of local levels {
		if "`lbe'"!="" {
			local vallab : label `lbe' `l'			
			local rownames `"`rownames' "`vallab'" "'
		}
		else {
			local rownames `"`rownames' "`l'" "'
		}		
	}
	
	//Add sum rowname if present
	if "`sum'"!="nosum" {
		local rownames `"`rownames' "SUM" "'
	}	
	
	matrix rownames data = `rownames'

	//Fix column names
	local varlab : variable label `varlist'
	if `"`varlab'"'=="" {
		local varlab `"`varlist'"'
	}
	matrix colnames data = `colnames'
	
	local title `"Frequency table for `varlab'"'
	di `"`title'"'
	matlist data 

	tempname mytable
	putdocx table `mytable' = matrix(data), width(70%) title(`"`title'"') nformat(%4.0f) rownames  colnames 
	restore
	
	
end
