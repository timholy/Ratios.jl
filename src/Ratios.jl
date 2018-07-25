__precompile__()

module Ratios

import Base: convert, promote_rule, *, /, +, -, ^, ==

export SimpleRatio

struct SimpleRatio{T<:Integer} <: Real
    num::T
    den::T
end

convert(::Type{BigFloat}, r::SimpleRatio{S}) where {S} = BigFloat(r.num)/r.den
function convert(::Type{T}, r::SimpleRatio{S}) where {T<:AbstractFloat,S}
    P = promote_type(T,S)
    convert(T, convert(P, r.num)/convert(P, r.den))
end
convert(::Type{SimpleRatio{T}}, i::Integer) where {T<:Integer} = SimpleRatio{T}(convert(T, i), one(T))
convert(::Type{SimpleRatio{T}}, r::Rational{S}) where {T<:Integer, S<:Integer} = SimpleRatio(convert(T, r.num), convert(T, r.den))
convert(::Type{Rational{T}}, r::SimpleRatio{S}) where {T<:Integer, S<:Integer} = convert(T, r.num) // convert(T, r.den)

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
+(x::SimpleRatio, y::SimpleRatio) = SimpleRatio(x.num*y.den + x.den*y.num, x.den*y.den)
-(x::SimpleRatio, y::SimpleRatio) = SimpleRatio(x.num*y.den - x.den*y.num, x.den*y.den)
^(x::SimpleRatio, y::Integer) = SimpleRatio(x.num^y, x.den^y)

-(x::SimpleRatio{T}) where {T<:Signed} = SimpleRatio(-x.num, x.den)
-(x::SimpleRatio{T}) where {T<:Unsigned} = throw(OverflowError())

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

end
