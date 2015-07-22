# The OBO Flat File parser

type Stanza
    Typ::UTF8String # Official ones are: "Term", "Typedef" and "Instance"
    id::UTF8String
    tagvalues::Dict{UTF8String, Vector{UTF8String}}
end

function find_first_nonescaped(s, ch)
    i = searchindex(s, ch)
    while i > 0
        numescapes = 0
        j = i - 1
        while j > 0 && s[j] == '\\'
            numescapes += 1
            j -= 1
        end

        if numescapes % 2 == 0 # this is not escaped
            return i
        else
            i = searchindex(s, ch, i+1)
        end
    end
    return i
end

function removecomments(line)
    i = find_first_nonescaped(line, "!")
    if i == 0
        return line[1:end]
    end
    return line[1:i-1]
end

const id_tag = "id"

function parseOBO(stream::IO)
    # first set of tag values is a header
    header, nextstanza = parsetagvalues(stream)
    stanzas = Stanza[]
    while nextstanza != ""
        prevstanza = nextstanza
        vals, nextstanza = parsetagvalues(stream)
        if !haskey(vals, id_tag)
            error("Stanza is missing ID tag")
        end
        id = vals[id_tag][1]
        push!(stanzas, Stanza(prevstanza, id, vals))
    end

    return header, stanzas
end


function parseOBO(filepath::String)
    open(filepath, "r") do f
        parseOBO(f)
    end
end

const r_stanza = r"^\[(.*)\]$"

function parsetagvalues(s)
    vals = Dict{ASCIIString, Vector{UTF8String}}()

    for line in eachline(s)
        line = strip(removecomments(line))
        m = match(r_stanza, line)
        if m != nothing
            return vals, m.captures[1]
        end

        isempty(line) && continue

        tag, value, ok = tagvalue(line)
        ok || error("cannot find a tag (position: $(position(s))), empty: $(isempty(line)), line: `$(line)`")
        if haskey(vals, tag)
            push!(vals[tag], value)
        else
            vals[tag] = [value]
        end
    end

    return vals, ""
end


function tagvalue(line)
    # TODO: what an ad hoc parser!
    i = searchindex(line, ": ")
    if i == 0
        # empty tag value
        if endswith(line, ":")
            return line, "", true
        end

        # empty strings are dummy
        return "", "", false
    end

    j = searchindex(line, " !")
    tag = line[1:i-1]
    if j == 0
        value = line[i+2:end]
    else
        value = line[i+2:j-1]
    end

    return tag, value, true
end

function getuniqueval(st::Stanza, tagname)
    arr = get(st.tagvalues, tagname, UTF8String[""])
    if length(arr) > 1
        error("Expect unique tag named $tagname")
    end
    return arr[1]
end


function trysetuniqueval(st, term, tag, field)
    tmp = getuniqueval(st, tag)
    termval = getfield(term, field)
    if tmp != "" && termval != "" && termval != tmp
        error("Different values of $tag specified for $term")
    end
    setfield!(term, field, tmp)
end


function getterms(arr::Vector{Stanza})
    result = Dict{UTF8String, Term}()

    for st in arr
        st.Typ == "Term" || continue

        term = get!(result, st.id) do
            Term(st.id)
        end

        for id in get(st.tagvalues, "is_a", UTF8String[])
            otherterm = get!(result, id) do
                Term(id)
            end
            push!(term.isa, otherterm)
        end

        term.obsolete = getuniqueval(st, "is_obsolete") == "true"
        if term.obsolete && length(term.isa) > 0
            error("Obsolete term $term contains is_a relationship")
        end


        trysetuniqueval(st, term, "name", :name)
        trysetuniqueval(st, term, "def", :def)
        trysetuniqueval(st, term, "namespace", :namespace)

        append!(term.synonyms, get(st.tagvalues, "synonym", UTF8String[""]))
        for (k, v) in st.tagvalues
            if haskey(term.tagvalues, k)
                append!(term.tagvalues[k], v)
            else
                term.tagvalues[k] = v
            end
        end
    end
    result
end

function gettypedefs(arr::Vector{Stanza})
  result = Dict{UTF8String, Typedef}()

  result
end
