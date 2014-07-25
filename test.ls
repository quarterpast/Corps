require! {
	'expect.js'
	body: './index.js'
	σ: highland
}

Stream = σ!constructor # sigh
err = (e)-> σ (<| e)

export
	"Body parser":
		"returns a stream": ->
			expect (body.raw σ ["hello"]) .to.be.a Stream
		"resolves to the body": (done)->
			body.raw σ ["hello"]
			.to-array (xs)->
				expect xs .to.eql <[hello]>
				done!
		"resolves to the parsed body": (done)->
			body.json σ [JSON.stringify a:1]
			.to-array (xs)->
				expect xs.0 .to.have.property \a 1
				done!
		"passes stream errors to the stream": (done)->
			body.json err new Error "hello"
			.stop-on-error (err)->
				expect err.message .to.be "hello"
				done!
			.each ->
		"passes parse errors to the stream": (done)->
			(body.json σ ["not json"])
			.stop-on-error (err)->
				expect err .to.be.a SyntaxError
				done!
			.each ->

	"json parser":
		"streams parsed json": (done)->
			body.json-parse '{"a":1}' .to-array (xs)->
				expect xs.0 .to.have.property \a 1
				done!
		"passes parse errors to the stream": (done)->
			body.json-parse 'not json'
			.stop-on-error (err)->
				expect err .to.be.a SyntaxError
				done!
			.each ->

	"query parser":
		"streams parsed query strings": (done)->
			body.query-parse 'a=1' .to-array (xs)->
				expect xs.0 .to.have.property \a '1'
				done!

	"auto":
		"parses json for application/json": (done)->
			req = σ [JSON.stringify a:1]
			req.headers = 'content-type': \application/json

			body.auto req .to-array (xs)->
				expect xs.0 .to.have.property \a 1
				done!

		"parses querystring for application/x-www-form-urlencoded": (done)->
			req = σ ['a=1']
			req.headers = 'content-type': \application/x-www-form-urlencoded

			body.auto req .to-array (xs)->
				expect xs.0 .to.have.property \a '1'
				done!

		"parses raw for other content types": (done)->
			req = σ ['hello']
			req.headers = 'content-type': \text/plain

			body.auto req .to-array (xs)->
				expect xs.0 .to.be 'hello'
				done!
