type Term
    id::UTF8String
    name::UTF8String

    obsolete::Bool
    namespace::UTF8String
    def::UTF8String
    synonyms::Vector{UTF8String}
    tagvalues::Dict{UTF8String, Vector{UTF8String}}

    relationships::Dict{Symbol, Vector{Term}}
    Term(id) = new(id, "", false, "", "", UTF8String[], Dict{UTF8String, Vector{UTF8String}}(), Dict{Symbol, Vector{Term}}())
end


Base.isless(term1::Term, term2::Term) = isless(term1.id, term2.id)
Base.hash(term::Term) = hash(term.id)
Base.show(io::IO, term::Term) = @printf io "Term(\"%s\", \"%s\")" term.id term.name
Base.showcompact(io::IO, term::Term) = print(io, term.id)

isobsolete(term::Term) = term.obsolete

function relationship(term::Term, sym::Symbol)
  if !haskey(term.relationships, sym)
    term.relationships[sym] = Term[]
  end
  term.relationships[sym]
end
