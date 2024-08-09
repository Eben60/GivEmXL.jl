const HEADERS = ["Datum-Zeit", 
    "Betriebsstundenzähler", 
    "rF Dry IN", 
    "rF Dry OUT", 
    "rF Wet IN", 
    "rF Wet OUT", 
    "T Dry IN", 
    "T Dry OUT", 
    "T Wet IN", 
    "T Wet OUT", 
    "Str Dry IN", 
    "Str Dry OUT", 
    "Str Wet IN", 
    "Str Wet OUT", 
    "dP Dry", 
    "dP Wet", 
    "p Abs dry IN", 
    "p Abs dry OUT", 
    "p Abs Wet IN", 
    "p Abs wet OUT"]

const SUBHEADERS = ["Time", 
    "B020.OT_h:m", 
    "B001.Ax", 
    "B002.Ax", 
    "B003.Ax", 
    "B004.Ax", 
    "B005.Ax", 
    "B006.Ax", 
    "B007.Ax", 
    "B008.Ax", 
    "B009.Ax", 
    "B010.Ax", 
    "B011.Ax", 
    "B012.Ax", 
    "B013.Ax", 
    "B014.Ax", 
    "B022.AQ", 
    "B017.Ax", 
    "B023.AQ", 
    "B018.Ax"]

const COLTYPES = append!([DateTime], fill(Int64, length(HEADERS)-1))

const c_water = 4185u"J/kg"