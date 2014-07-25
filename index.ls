σ = require \highland
qs = require \qs

# body-params :: (String → Stream Params) → Request → Stream Params
export body-params = (parser, req)-->
	σ req .flat-map parser

handle-error = (f, x)--> σ [null] .map -> f x

export json-parse  = handle-error JSON.parse
export query-parse = handle-error qs.parse

export json  = body-params json-parse
export query = body-params query-parse
export raw   = body-params -> σ [it]

export mime-parsers =
	\application/json : json
	\application/x-www-form-urlencoded : query

export auto = (req)->
	req |> mime-parsers[req.headers.'content-type'] ? raw
