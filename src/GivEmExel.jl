module GivEmExel
using Unitful, DataFrames, XLSX, Preferences
using NativeFileDialog: pick_file, pick_multi_file, pick_folder

include("InternalArgParse/InternalArgParse.jl")

using .InternalArgParse
# using SimpleArgParse


export InternalArgParse
export full_interact

include("process_data.jl")
include("get_files.jl")
include("interact.jl")

end
