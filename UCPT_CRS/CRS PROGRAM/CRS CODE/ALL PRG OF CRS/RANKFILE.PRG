#Include "Inkey.Ch"
#Include "Sixcdx.Ch"
#Include "Grumpr.Ch"
#Include "Grump.Ch"
#Include "Grumpm.Ch"
function Rank_file()
local anavmdbf:={},anavddbf:={},cterm:=space(4)
if !file("C999rank.dbf")
    aadd(anavmdbf,{"idno",c,8,0})
    aadd(anavmdbf,{"term",c,4,0})
    aadd(anavmdbf,{"rankc",c,4,0})
    aadd(anavmdbf,{"bo_date",d,8,0})
    dbcreate("C999rank.dbf",anvndbf)
endif
return(nil)
