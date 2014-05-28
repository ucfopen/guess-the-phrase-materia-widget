client = {}

describe 'Testing framework', ->
	it 'should load widget', (done) ->
		require('./widgets.coffee') 'hangman', ->
			client = this
			client.pause 5000
			done()
	, 25000

describe 'Main page', ->
	it 'should have a title', (done) ->
		client.getText '.portal h1', (err, text) ->
				expect(err).toBeNull()
				expect(text).toContain("Hangman")
				done()
	it 'should let me press start', (done) ->
		client.click '#start'
		done()
