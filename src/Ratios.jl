module Ratios

import Base: convert, promote_rule, +, -, *, /, ^, ==

export SimpleRatio

immutable SimpleRatio{T<:Integer} <: Real
    num::T
    den::T
end

import Base: checked_add, checked_sub, checked_mul, divgcd

const ⊞ = checked_add
const ⊟ = checked_sub
const ⊠ = checked_mul
const ⊗ = widemul


convert{S}(::Type{BigFloat}, r::SimpleRatio{S}) = BigFloat(r.num)/r.den
function convert{T<:AbstractFloat,S}(::Type{T}, r::SimpleRatio{S})
    P = promote_type(T,S)
    convert(T, convert(P, r.num)/convert(P, r.den))
end
convert{T<:Integer}(::Type{SimpleRatio{T}}, i::Integer) = SimpleRatio{T}(convert(T, i), one(T))

convert{T<:Integer}(::Type{SimpleRatio{T}},x::SimpleRatio) = SimpleRatio(convert(T,x.num),convert(T,x.den))


function *{T}(x::SimpleRatio{T}, y::SimpleRatio{T})
    try
        SimpleRatio(x.num ⊠ y.num, x.den ⊠ y.den)
    catch e
        isa(e, OverflowError) || rethrow(e)
        num = x.num ⊗ y.num
        den = x.den ⊗ y.den
        num, den = divgcd(num, den)
        typemin(T) <= num <= typemax(T) && typemin(T) <= den <= typemax(T) || rethrow(e)
        SimpleRatio(num % T, den % T)
    end
end
#*(x::SimpleRatio, y::SimpleRatio) = *(promote(x,y)...)

*{T}(x::SimpleRatio{T}, y::Bool) = SimpleRatio(x.num*y, x.den)
*{T}(x::Bool, y::SimpleRatio{T}) = SimpleRatio(x*y.num, y.den)

function *{T}(x::SimpleRatio{T}, y::Integer)
    try
        SimpleRatio(x.num ⊠ y, x.den)
    catch e
        isa(e, OverflowError) || rethrow(e)
        num = x.num ⊗ y
        num, den = divgcd(num, x.den)
        typemin(T) <= num <= typemax(T) || rethrow(e)
        SimpleRatio(num % T, den % T)
    end
end
*{T}(x::Integer, y::SimpleRatio{T}) = *(y,x)

    
function /{T}(x::SimpleRatio{T}, y::SimpleRatio{T})
    try
        SimpleRatio(x.num ⊠ y.den, x.den ⊠ y.num)
    catch e
        isa(e, OverflowError) || rethrow(e)
        num = x.num ⊗ y.den
        den = x.den ⊗ y.num
        num, den = divgcd(num, den)
        typemin(T) <= num <= typemax(T) && typemin(T) <= den <= typemax(T) || rethrow(e)
        SimpleRatio(num % T, den % T)
    end
end
#/(x::SimpleRatio, y::SimpleRatio) = /(promote(x,y)...)

function /{T}(x::SimpleRatio{T}, y::Integer)
    try
        SimpleRatio(x.num, x.den ⊠ y)
    catch e
        isa(e, OverflowError) || rethrow(e)
        den = x.den ⊗ y
        num, den = divgcd(x.num, den)
        typemin(T) <= den <= typemax(T) || rethrow(e)
        SimpleRatio(num % T, den % T)
    end
end

function /{T}(x::Integer, y::SimpleRatio{T})
    try
        SimpleRatio(x ⊠ y.den, y.num)
    catch e
        isa(e, OverflowError) || rethrow(e)
        num = x ⊗ y.den
        num, den = divgcd(num, y.num)
        typemin(T) <= num <= typemax(T) || rethrow(e)
        SimpleRatio(num % T, den % T)
    end
end
    
function +{T}(x::Integer, y::SimpleRatio{T})
    try
        SimpleRatio(x ⊠ y.den ⊞ y.num, y.den)
    catch e
        isa(e, OverflowError) || rethrow(e)
        num = x ⊗ y.den ⊞ y.num
        num, den = divgcd(num, y.den)
        typemin(T) <= num <= typemax(T) || rethrow(e)
        SimpleRatio(num % T, den % T)
    end
end
+{T}(x::SimpleRatio{T}, y::Integer) = +(y,x)


function -{T}(x::Integer, y::SimpleRatio{T})
    try
        SimpleRatio(x ⊠ y.den ⊟ y.num, y.den)
    catch e
        isa(e, OverflowError) || rethrow(e)
        num = x ⊗ y.den ⊟ y.num
        num, den = divgcd(num, y.den)
        typemin(T) <= num <= typemax(T) || rethrow(e)
        SimpleRatio(num % T, den % T)
    end
end
function -{T}(x::SimpleRatio{T}, y::Integer)
    try
        SimpleRatio(x.num ⊟ y ⊠ x.den, x.den)
    catch e
        isa(e, OverflowError) || rethrow(e)
        num = x.num ⊟ y ⊗ x.den
        num, den = divgcd(num, x.den)
        typemin(T) <= num <= typemax(T) || rethrow(e)
        SimpleRatio(num % T, den % T)
    end
end

function +{T}(x::SimpleRatio{T}, y::SimpleRatio{T})
    try
        if x.den == y.den
            SimpleRatio(x.num ⊞ y.num, x.den)
        else
            SimpleRatio(x.num ⊠ y.den ⊞ x.den ⊠ y.num, x.den ⊠ y.den)
        end
    catch e
        isa(e, OverflowError) || rethrow(e)
        num = x.num ⊗ y.den ⊞ x.den ⊗ y.num
        den = x.den ⊗ y.den
        num, den = divgcd(num, den)
        typemin(T) <= num <= typemax(T) && typemin(T) <= den <= typemax(T) || rethrow(e)
        SimpleRatio(num % T, den % T)
    end
end
#+(x::SimpleRatio, y::SimpleRatio) = +(promote(x,y)...)

function -{T}(x::SimpleRatio{T}, y::SimpleRatio{T})
    try
        if x.den == y.den
            SimpleRatio(x.num ⊟ y.num, x.den)
        else
            SimpleRatio(x.num ⊠ y.den ⊟ x.den ⊠ y.num, x.den ⊠ y.den)
        end
    catch e
        isa(e, OverflowError) || rethrow(e)
        num = x.num ⊗ y.den ⊟ x.den ⊗ y.num
        den = x.den ⊗ y.den
        num, den = divgcd(num, den)
        typemin(T) <= num <= typemax(T) && typemin(T) <= den <= typemax(T) || rethrow(e)
        SimpleRatio(num % T, den % T)
    end
end
#-(x::SimpleRatio, y::SimpleRatio) = -(promote(x,y)...)

^(x::SimpleRatio, y::Integer) = Base.power_by_squaring(x,y)

-{T<:Signed}(x::SimpleRatio{T}) = SimpleRatio(-x.num, x.den)
-{T<:Unsigned}(x::SimpleRatio{T}) = throw(OverflowError())

promote_rule{T<:Integer,S<:Integer}(::Type{SimpleRatio{T}}, ::Type{S}) = SimpleRatio{promote_type(T,S)}
promote_rule{T<:Integer,S<:Integer}(::Type{SimpleRatio{T}}, ::Type{SimpleRatio{S}}) = SimpleRatio{promote_type(T,S)}
promote_rule{T<:Integer,S<:AbstractFloat}(::Type{SimpleRatio{T}}, ::Type{S}) = promote_type(T,S)

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
