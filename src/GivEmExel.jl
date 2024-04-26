module GivEmExel
using Unitful, DataFrames, XLSX, Preferences
using NativeFileDialog: pick_file, pick_multi_file, pick_folder

include("InternalArgParse/InternalArgParse.jl")

using .InternalArgParse
# using SimpleArgParse


export InternalArgParse
export full_interact, merge_params
export prepare_xl

export read_xl_paramtables, exper_paramsets

include("process_data.jl")
include("get_files.jl")
include("interact.jl")
include("df_export.jl")

end
