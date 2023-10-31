// csplot - Graphing the curse of dimensionality in Stata

// Author: Omar Soliman (Humboldt-Universität zu Berlin)
// Date: 2023 10 25
// Version: 1.0

** Common Support plotten
capture program drop csplot
program define csplot, rclass
    syntax varname, xvars(varlist) [*]
	
	*Entferne Options-Komma aus erstem Argument
	local 1 = subinstr("`1'", ",", "", 1)
	 
	*Varlist initialisieren
	local cumul_xvars ""
	
	local nvars : word count `xvars' //Kontrollvariablen zählen
	matrix results = J(`nvars', 1, .) //Matrix initialisieren
	
	*Common Support iterativ auslesen
	local i = 1
	foreach x in `xvars' { 
		local cumul_xvars "`cumul_xvars' `x'" //Variablen dazunehmen
		qui csperc `1', xvars(`cumul_xvars')  //csperc callen
		matrix results[`i', 1] = r(cs_perc)   //Ergebnis speichern
		local i = `i' + 1
	}
	
	*Matrix in Datensatz umwandeln
	preserve
		clear
		qui svmat results, name(cs) //Matrix in Datensatz umwandeln
		local N = _N
		qui gen varname = "" //Variablenname
		qui gen varno = .    //Variablenrang
		forvalues i=1/`N' {  //Werte verbinden
			local val: word `i' of `cumul_xvars'
			qui replace varname = "`val'" if _n == `i'
			qui replace varno = `i' if _n == `i'
		}
		
		*Plot it!
		local xlabel_option
		local numlabels = wordcount("`cumul_xvars'")
		forvalues i=1/`numlabels' {
			local this_label: word `i' of `cumul_xvars'
			local xlabel_option "`xlabel_option' `i' `"`this_label'"' "
		}
		
		twoway connected cs1 varno, ///
		ytitle("Percentage in Common Support") xtitle("Treatment-variable: `1'") ///
		xlabel(`xlabel_option', angle(45)) ///
		subtitle("Common support with increasing dimensionality") `options'
	restore	
	
	*Matrix ausspucken
	return matrix results = results
	
end