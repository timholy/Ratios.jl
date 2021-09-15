module Ratios

import Base: convert, promote_rule, *, /, +, -, ^, ==, decompose

using Requires

export SimpleRatio

struct SimpleRatio{T<:Integer} <: Real
    num::T
    den::T
end

SimpleRatio(num::Integer, den::Integer) = SimpleRatio(promote(num, den)...)

convert(::Type{BigFloat}, r::SimpleRatio{S}) where {S} = BigFloat(r.num)/r.den
function convert(::Type{T}, r::SimpleRatio{S}) where {T<:AbstractFloat,S}
    P = promote_type(T,S)
    convert(T, convert(P, r.num)/convert(P, r.den))
end
SimpleRatio{T}(i::Integer) where {T<:Integer} = SimpleRatio{T}(convert(T, i), oneunit(T))
SimpleRatio{T}(r::Rational{S}) where {T<:Integer, S<:Integer} = SimpleRatio(convert(T, r.num), convert(T, r.den))
Rational{T}(r::SimpleRatio{S}) where {T<:Integer, S<:Integer} = convert(T, r.num) // convert(T, r.den)

*(x::SimpleRatio, y::SimpleRatio) = SimpleRatio(x.num*y.num, x.den*y.den)
*(x::SimpleRatio, y::Bool) = SimpleRatio(x.num*y, x.den)
*(x::SimpleRatio, y::Integer) = SimpleRatio(x.num*y, x.den)
*(x::Bool, y::SimpleRatio) = SimpleRatio(x*y.num, y.den)
*(x::Integer, y::SimpleRatio) = SimpleRatio(x*y.num, y.den)
/(x::SimpleRatio, y::SimpleRatio) = SimpleRatio(x.num*y.den, x.den*y.num)
/(x::SimpleRatio, y::Integer) = SimpleRatio(x.num, x.den*y)
/(x::Integer, y::SimpleRatio) = SimpleRatio(x*y.den, y.num)
+(x::Integer, y::SimpleRatio) = SimpleRatio(x*y.den + y.num, y.den)
-(x::Integer, y::SimpleRatio) = SimpleRatio(x*y.den - y.num, y.den)
+(x::SimpleRatio, y::SimpleRatio) = x.den == y.den ? SimpleRatio(x.num + y.num, x.den) :
                                                     SimpleRatio(x.num*y.den + x.den*y.num, x.den*y.den)
-(x::SimpleRatio, y::SimpleRatio) = x.den == y.den ? SimpleRatio(x.num - y.num, x.den) :
                                                     SimpleRatio(x.num*y.den - x.den*y.num, x.den*y.den)
^(x::SimpleRatio, y::Integer) = SimpleRatio(x.num^y, x.den^y)

-(x::SimpleRatio{T}) where {T<:Signed} = SimpleRatio(-x.num, x.den)
-(x::SimpleRatio{T}) where {T<:Unsigned} = throw(VERSION < v"0.7.0-DEV.1269" ? OverflowError() : OverflowError("cannot negate unsigned number"))

promote_rule(::Type{SimpleRatio{T}}, ::Type{S}) where {T<:Integer,S<:Integer} = SimpleRatio{promote_type(T,S)}
promote_rule(::Type{SimpleRatio{T}}, ::Type{SimpleRatio{S}}) where {T<:Integer,S<:Integer} = SimpleRatio{promote_type(T,S)}
promote_rule(::Type{SimpleRatio{T}}, ::Type{S}) where {T<:Integer,S<:AbstractFloat} = promote_type(T,S)
promote_rule(::Type{SimpleRatio{T}}, ::Type{Rational{S}}) where {T<:Integer,S<:Integer} = Rational{promote_type(T,S)}

==(x::SimpleRatio, y::SimpleRatio) = x.num*y.den == x.den*y.num

==(x::SimpleRatio, y::Integer) = x.num == x.den*y
==(x::Integer, y::SimpleRatio) = x*y.den == y.num

function ==(x::AbstractFloat, q::SimpleRatio)
    if isfinite(x)
        (count_ones(q.den) == 1) & (x*q.den == q.num)
    else
        x == q.num/q.den
    end
end

==(q::SimpleRatio, x::AbstractFloat) = x == q

decompose(x::SimpleRatio) = x.num, 0, x.den

function __init__()
    @require FixedPointNumbers = "53c48c17-4a7d-5ca2-90c5-79b7896eea93" begin
        using .FixedPointNumbers: FixedPoint, Fixed, Normed, rawone
        rawone_noerr(::Type{Fixed{T,f}}) where {T,f} = widen(oneunit(T)) << f
        rawone_noerr(::Type{N}) where N<:Normed = rawone(N)
        rawone_noerr(x::FixedPoint) = rawone_noerr(typeof(x))
        Base.promote_rule(::Type{SimpleRatio{S}}, ::Type{<:FixedPoint{T}}) where {S<:Integer,T<:Integer} = SimpleRatio{promote_type(S, T)}
        SimpleRatio{S}(x::FixedPoint) where S<:Integer = SimpleRatio{S}(reinterpret(x), rawone_noerr(x))
        SimpleRatio(x::FixedPoint) = SimpleRatio(reinterpret(x), rawone_noerr(x))
        Base.convert(::Type{S}, x::FixedPoint) where S<:SimpleRatio = S(x)
    end
end

end
