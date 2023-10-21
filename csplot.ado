** Common Support Werte als Returns
cap program drop csperc
program define csperc, rclass
    syntax varname, xvars(varlist)
	
	*Entferne Options-Komma aus erstem Argument
	local 1 = subinstr("`1'", ",", "", 1)
	
    *Notiere alle möglichen Kombinationen
	cap drop match_group *_exists
    qui egen match_group = group(`xvars')
	
	*Notiere ob die Kombination in Treatment-/Kontrollgruppe vorkommt
    qui bysort match_group: egen treat_exists = max(`1') // `1' = varname
    qui bysort match_group: egen control_exists = max(1-`1')
	
    *Zähle Beobachtungen der Kombination wenn sie in beiden Gruppen vorkommt
    qui count if treat_exists == 1 & control_exists == 1
    local in_common = r(N)
	
	*Zähle alles
    qui count
    local total = r(N)
    
	*Rechne Verhältnis
    local percentage = (`in_common' / `total') * 100
    
    *Returne Ergebnis
    return scalar cs_perc = `percentage'
	
	*Aufräumen
	qui cap drop match_group *_exists
	
	*Printe Ergebnis
	di _newline as text "Treatment-Variable: " as result "`1'"
	di as text "Kontrollvariablen: " as result "`xvars'"
	di as text "N in Common Support: " as result `in_common'
	di as text "N insgesamt: " as result `total'
    di as text "Anteil in Common Support: " as result %5.2f `percentage' "%"
	
end
*Test:
*csperc berabk1_2, xvars(F020d01r F020d02r F020d03r F020d04r F020d06r F020d07r)

** Common Support plotten
capture program drop csplot
program define csplot, rclass
    syntax varname, xvars(varlist)
	
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
		subtitle("Common support with increasing dimensionality")
	restore	
	
	*Matrix ausspucken
	return matrix results = results
	
end