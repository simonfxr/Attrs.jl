using Attrs
using Test


struct Foo{Tag, T}
    x::T
end

@inline Foo{Tag}(x::T) where {Tag, T} = Foo{Tag, T}(x)

@inline Attrs.literal_getattr(x::Foo, f::Attr) =
    Attrs.default_literal_getattr(x, f)

@inline Attrs.literal_setattr!(x::Foo, f::Attr, y) =
    Attrs.default_literal_setattr!(x, f, y)

@inline Base.getproperty(x::Foo, f::Symbol) = Attrs.default_getproperty(x, f)

@inline Base.setproperty!(x::Foo, f::Symbol, y) =
    Attrs.default_setproperty!(x, f, y)

@inline Attrs.getattr(x::Foo{Tag}, ::Attr{:tag}) where Tag = Tag

@literalattrs Attrs.getattr(x::Foo, ::Attr{:y}) = 2 * x.x

@literalattrs Attrs.getattr(x::Foo, ::Attr{:z}) = 2 * x.x + 1

@literalattrs Attrs.getattr(x::Foo{:even}, ::Attr{:z}) =
    2 * x.x + 2

h(x) = x.x
g(x) = x.y
g1(x) = getextproperty(x, Property{:y}())
k(x) = x.z
k1(x) = getextproperty(x, Property{:z}())

@testset "Attrs" begin

    x = Foo{:foo}(42)
    
    @test h(x) == 42
    @test g(x) == 84
    @test k(x) == 85
    @test g1(x) == 84
    @test k1(x) == 85

    y = Foo{:even}(42)

    @test h(x) == h(y)
    @test g(x) == g(y)
    @test k(x) == 86

end
