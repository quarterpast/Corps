σ = require \highland
qs = require \qs

# body-params :: (String → Stream Params) → Request → Stream Params
exports.body-params = (parser, req)-->
	σ req .flat-map parser

exports.json-parse  = σ . ([] ++) . JSON.parse
exports.query-parse = σ . ([] ++) . qs.parse

exports.json  = exports.body-params exports.json-parse
exports.query = exports.body-params exports.query-parse
exports.raw   = exports.body-params -> σ [it]
