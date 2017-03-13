
immutable Ontology
    header::Dict{String, Vector{String}}
    prefix::String
    terms::Dict{String, Term}
    typedefs::Dict{String, Typedef}
end

function load(fn, prefix::AbstractString)
    header, stanzas = parseOBO(fn)
    terms = getterms(stanzas)
    typedefs = gettypedefs(stanzas)
    Ontology(header, prefix, terms, typedefs)
end

function gettermbyname(ontology::Ontology, name)
    lname = lowercase(name)
    for term in allterms(ontology)
        (lowercase(term.name) == lname) && return term
    end
    error("Term not found: $name")
end

gettermid(ontology::Ontology, id::Integer) = @sprintf("%s:%07d", ontology.prefix, id)

gettermbyid(ontology::Ontology, id::AbstractString) = ontology.terms[id]
gettermbyid(ontology::Ontology, id::Integer) = gettermbyid(ontology, gettermid(ontology, id))

allterms(ontology::Ontology) = values(ontology.terms)

Base.length(ontology::Ontology) = length(ontology.terms)

parents(ontology::Ontology, term::Term, rel::Symbol = :is_a) = relationship(term, rel)

children(ontology::Ontology, term::Term, rel::Symbol = :is_a) = Term[filter(t -> t != term && term in parents(ontology, t, rel), allterms(ontology))...]

descendants(ontology::Ontology, term::Term, rel::Symbol = :is_a) = Term[filter(t -> t != term && satisfies(ontology, t, rel, term), allterms(ontology))...]

ancestors(ontology::Ontology, term::Term, rel::Symbol = :is_a) = Term[filter(t -> t != term && satisfies(ontology, term, rel, t), allterms(ontology))...]


function satisfies(ontology::Ontology, term1::Term, rel::Symbol, term2::Term)
    if term1 == term2
        return true # TODO: should check if relationship is is_reflexive
    end

    if term2 in relationship(term1, rel)
      return true
    end

    # TODO: check if transitive & non-cyclical before doing so
    for p in relationship(term1, rel)
        if satisfies(ontology, p, rel, term2)
            return true
        end
    end

    return false
end

is_a(ontology::Ontology, term1::Term, term2::Term) = satisfies(ontology, term1, :is_a, term2)
