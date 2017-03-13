immutable Term
    id::String
    name::String

    obsolete::Bool
    namespace::String
    def::String
    synonyms::Vector{String}
    tagvalues::Dict{String, Vector{String}}

    relationships::Dict{Symbol, Set{String}}
    rev_relationships::Dict{Symbol, Set{String}} # reverse relationships

    Term(id::AbstractString, name::AbstractString="", obsolete::Bool=false,
         namespace::AbstractString="", def::AbstractString="") =
        new(id, name, obsolete, namespace, def, String[],
            Dict{String, Vector{String}}(),
            Dict{Symbol, Set{String}}(), Dict{Symbol, Set{String}}())
    Term(term::Term, name::AbstractString=term.name, obsolete::Bool=term.obsolete,
         namespace::AbstractString=term.namespace, def::AbstractString=term.def) =
        new(term.id, term.name, obsolete, term.namespace, term.def, term.synonyms,
            term.tagvalues, term.relationships, term.rev_relationships)
end


Base.isless(term1::Term, term2::Term) = isless(term1.id, term2.id)
Base.show(io::IO, term::Term) = @printf io "Term(\"%s\", \"%s\")" term.id term.name
Base.showcompact(io::IO, term::Term) = print(io, term.id)

isobsolete(term::Term) = term.obsolete

relationship(term::Term, sym::Symbol) = get!(() -> Set{String}(), term.relationships, sym)
rev_relationship(term::Term, sym::Symbol) = get!(() -> Set{String}(), term.rev_relationships, sym)
