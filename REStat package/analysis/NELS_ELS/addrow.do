local resultspath "$resultspath"
local tablename "$tablename"
local rowtitle "$rowtitle"
scalar b=_b[ntr_gap_g10]
scalar se=_se[ntr_gap_g10]
if abs(scalar(b)/scalar(se))>2.576	{
	local ast="***"
}
else if abs(scalar(b)/scalar(se))>1.96	{
	local ast="**"
}
else if abs(scalar(b)/scalar(se))>1.645	{
	local ast="*"
}
else	{
	local ast=""
}
local b: display %6.0gc =scalar(b)
local se: display %6.0gc =scalar(se)
local N: display %9.0gc =round(e(N),10)
*local N: display %9.0gc =e(N)
file open myfile using "`resultspath'table`tablename'.tex", write append
file write myfile ///
 "`rowtitle' & `b'`ast' & (`se') & `N' \\ " _n
file close myfile

