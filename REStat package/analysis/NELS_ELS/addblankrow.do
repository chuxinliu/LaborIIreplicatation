local resultspath "$resultspath"
local tablename "$tablename"
file open myfile using "`resultspath'table`tablename'.tex", write append
file write myfile ///
 "& & & \\ " _n
file close myfile

