type Term
    id::String
    name::String

    obsolete::Bool
    namespace::String
    def::String
    synonyms::Vector{String}
    tagvalues::Dict{String, Vector{String}}

    relationships::Dict{Symbol, Vector{Term}}
    Term(id) = new(id, "", false, "", "", String[], Dict{String, Vector{String}}(), Dict{Symbol, Vector{Term}}())
end


Base.isless(term1::Term, term2::Term) = isless(term1.id, term2.id)
Base.show(io::IO, term::Term) = @printf io "Term(\"%s\", \"%s\")" term.id term.name
Base.showcompact(io::IO, term::Term) = print(io, term.id)

isobsolete(term::Term) = term.obsolete

relationship(term::Term, sym::Symbol) = get!(() -> Term[], term.relationships, sym)
