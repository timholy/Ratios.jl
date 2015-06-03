module Ratios

import Base: convert, promote_rule

export SimpleRatio

typealias SimpleRatio{T} Rational{T}
end
