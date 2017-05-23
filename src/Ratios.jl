module Ratios

import Base: convert, promote_rule, *, /, +, -, ^, ==

export SimpleRatio

immutable SimpleRatio{T<:Integer} <: Real
    num::T
    den::T
end

convert{S}(::Type{BigFloat}, r::SimpleRatio{S}) = BigFloat(r.num)/r.den
function convert{T<:AbstractFloat,S}(::Type{T}, r::SimpleRatio{S})
    P = promote_type(T,S)
    convert(T, convert(P, r.num)/convert(P, r.den))
end
convert{T<:Integer}(::Type{SimpleRatio{T}}, i::Integer) = SimpleRatio{T}(convert(T, i), one(T))
convert{T<:Integer, S<:Integer}(::Type{SimpleRatio{T}}, r::Rational{S}) = SimpleRatio(convert(T, r.num), convert(T, r.den))
convert{T<:Integer, S<:Integer}(::Type{Rational{T}}, r::SimpleRatio{S}) = convert(T, r.num) // convert(T, r.den)

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

-{T<:Signed}(x::SimpleRatio{T}) = SimpleRatio(-x.num, x.den)
-{T<:Unsigned}(x::SimpleRatio{T}) = throw(OverflowError())

promote_rule{T<:Integer,S<:Integer}(::Type{SimpleRatio{T}}, ::Type{S}) = SimpleRatio{promote_type(T,S)}
promote_rule{T<:Integer,S<:Integer}(::Type{SimpleRatio{T}}, ::Type{SimpleRatio{S}}) = SimpleRatio{promote_type(T,S)}
promote_rule{T<:Integer,S<:AbstractFloat}(::Type{SimpleRatio{T}}, ::Type{S}) = promote_type(T,S)
promote_rule{T<:Integer,S<:Integer}(::Type{SimpleRatio{T}}, ::Type{Rational{S}}) = Rational{promote_type(T,S)}

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
