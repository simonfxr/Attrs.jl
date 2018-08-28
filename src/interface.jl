
struct NoSuchAttr end

struct Attr{S} end

function getattr end

function setattr! end

@inline literal_getattr(x, ::Attr{F}) where F = getproperty(x, F)

@inline literal_setattr!(x, ::Attr{F}, y) where F = setproperty!(x, F, y)

@generated function trygetfield(x, ::Attr{F}) where F
    hasfield = F in fieldnames(x)
    quote
        $(Expr(:meta, :inline))
        $(hasfield ? :(getfield(x, $(Meta.quot(F)))) : :(NoSuchAttr()))
    end
end

@generated function trysetfield!(x, ::Attr{F}, y) where F
    hasfield = F in fieldnames(x)
    quote
        $(Expr(:meta, :inline))
        $(hasfield ? :(setfield!(x, $(Meta.quot(F)), y)) : :(NoSuchAttr()))
    end
end

function attrnames(::Type{T}) where T
    fields = collect(fieldnames(T))
    fieldset = Set{Symbol}(fields)
    for m in methods(getattr, (T, Attr)).ms
        sig = m.sig
        while isa(sig, UnionAll)
            sig = sig.body
        end
        field = sig.parameters[3].parameters[1]
        if !(field isa TypeVar)
            field::Symbol
            if !(field in fieldset)
                push!(fieldset, field)
                push!(fields, field)
            end
        end
    end
    Tuple(fields)
end

@inline attrnames(x) = attrnames(typeof(x))

@inline function default_literal_getattr(x, f::Attr)
    res = trygetfield(x, f)
    if res ≡ NoSuchAttr()
        getattr(x, f)
    else
        res
    end
end

@inline function default_literal_setattr!(x, f::Attr, y)
    res = trysetfield!(x, f, y)
    if res ≡ NoSuchAttr()
        setattr!(x, f, y)
    else
        res
    end
end

@inline default_getproperty(x, f::Symbol) =
    default_literal_getattr(x, Attr{f}())

@inline default_setproperty!(x, f::Symbol, y) =
    default_literal_setattr!(x, Attr{f}(), y)
