module Attrs

export @literalattrs, @defattrs, Attr, getattr, setattr!, attrnames

include("interface.jl")
include("macros.jl")

end # module
