const TermId = String
const TagDict = Dict{String, Vector{String}}
const RelDict = Dict{Symbol, Set{TermId}}

struct Term
    id::TermId
    name::String

    obsolete::Bool
    namespace::String
    def::String
    synonyms::Vector{String}
    tagvalues::TagDict

    relationships::RelDict
    rev_relationships::RelDict # reverse relationships

    Term(id::AbstractString, name::AbstractString="", obsolete::Bool=false,
         namespace::AbstractString="", def::AbstractString="") =
        new(id, name, obsolete, namespace, def, String[],
            TagDict(), RelDict(), RelDict())
    Term(term::Term, name::AbstractString=term.name, obsolete::Bool=term.obsolete,
         namespace::AbstractString=term.namespace, def::AbstractString=term.def) =
        new(term.id, name, obsolete, namespace, def, term.synonyms,
            term.tagvalues, term.relationships, term.rev_relationships)
end


Base.isless(term1::Term, term2::Term) = isless(term1.id, term2.id)
Base.show(io::IO, term::Term) = @printf io "Term(\"%s\", \"%s\")" term.id term.name
Base.showcompact(io::IO, term::Term) = print(io, term.id)

isobsolete(term::Term) = term.obsolete

relationship(term::Term, sym::Symbol) = get!(() -> Set{TermId}(), term.relationships, sym)
rev_relationship(term::Term, sym::Symbol) = get!(() -> Set{TermId}(), term.rev_relationships, sym)
