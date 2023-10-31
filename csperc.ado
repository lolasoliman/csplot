// csplot - Graphing the curse of dimensionality in Stata

// Author: Omar Soliman (Humboldt-Universität zu Berlin)
// Date: 2023 10 25
// Version: 1.0

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

*sysuse auto
*csperc foreign, xvars(mpg rep78 trunk headroom)