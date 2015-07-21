
type Ontology
    header
    prefix
    terms::Dict{UTF8String, Term}
end

function loadOBO(fn::String, prefix)
    header, stanzas = parseOBO(fn)
    terms = getterms(stanzas)
    Ontology(header, prefix, terms)
end

function gettermbyname(ontology::Ontology, name::String)
    lname = lowercase(name)
    for term in values(ontology.terms)
        if lowercase(term.name) == lname
            return term
        end
    end
    error("Term not found: $name")
end

gettermid(ontology::Ontology, id::Integer) = @sprintf("%s:%07d", ontology.prefix, id)

gettermbyid(ontology::Ontology, id::String) = ontology.terms[id]
gettermbyid(ontology::Ontology, id::Integer) = gettermbyid(ontology, gettermid(ontology, id))

import Base.length
length(ontology::Ontology) =  length(ontology.terms)
