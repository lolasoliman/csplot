{smcl}

{title:Title}

{pstd}
{cmd:csplot} - Graphing the curse of dimensionality in Stata


{title:Syntax}

{phang2}
	{cmd:csplot} {help varname:indepvar} , xvars({help varname:varlist}) [{it:{help twoway_options:twoway_options}}]
{p_end}

{phang2}
	{cmd:csperc} {help varname:indepvar} , xvars({help varname:varlist})
{p_end}

{pstd}
  where {it:indepvar} is the treatment-variable and {it:varlist} are the control variables.
{p_end}


{title:Description}

{pstd}
{cmd:csplot} simply plots the amount of common support,
declining with each consecutively added control variable out of {it:varlist}.
{p_end}
{pstd}
The results are also returned in the matrix {it:r(results)}.
{p_end}

{pstd}
  {cmd:csperc} calculates common support and returns the result in {it:r(cs_perc)}. (Might help someone as there was no easy way to do that before.)
{p_end}

{title:Examples}

{phang}
{cmd:. sysuse auto}
{p_end}
{pstd}
(1978 Automobile Data)
{p_end}

{phang}
{cmd:. csplot foreign, xvars(mpg rep78 trunk headroom)}


{title:Acknowledgements}

{pstd}
This program was inspired by a conversation with Maik Hamjediers (HU Berlin).
{p_end}

{pstd}
Thanks, Maik ;-)


{title:Author}

{pstd}
Omar Soliman (she/her), {browse "mailto:omar.soliman@hu-berlin.de":omar.soliman@hu-berlin.de}
{p_end}
{pstd}
Department of Social Sciences,
{p_end}
{pstd}
Humboldt-Universität zu Berlin
{p_end}

