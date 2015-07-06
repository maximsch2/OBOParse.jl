type Term
    id::UTF8String
    name::UTF8String

    obsolete::Bool
    namespace::UTF8String
    def::UTF8String
    isa::Vector{Term}
    synonyms::Vector{UTF8String}
    tagvalues::Dict{UTF8String, Array{UTF8String, 1}}

    Term(id) = new(id, "", false, "", "", Term[], UTF8String[], Dict{UTF8String, Array{UTF8String, 1}}())
end

import Base: ==

Base.isequal(term1::Term, term2::Term) = term1.id == term2.id
==(term1::Term, term2::Term) = isequal(term1, term2)
Base.isless(term1::Term, term2::Term) = isless(term1.id, term2.id)
Base.hash(term::Term) = hash(term.id)
Base.show(io::IO, term::Term) = @printf io "Term(\"%s\", \"%s\")" term.id term.name
Base.showcompact(io::IO, term::Term) = print(io, term.id)

isobsolete(term::Term) = term.obsolete


function is_a(term1::Term, term2::Term)
    if term1 == term2
        return true
    end
    if length(term1.isa) == 0
        return false
    end
    for parent in term1.isa
        if is_a(parent, term2)
            return true
        end
    end
    return false
end
