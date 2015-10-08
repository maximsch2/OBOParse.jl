__precompile__()

module OBOParse

export
    # term
    isobsolete, is_a,

    # parser
    loadOBO,
    gettermbyid, gettermbyname,
    parents, children,
    descendants, ancestors, relationship,
    Ontology, Term


include("term.jl")
include("typedef.jl")
include("parser.jl")
include("ontology.jl")


end # OBOParse module
