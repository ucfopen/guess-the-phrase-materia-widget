client = {}

hangmanTypeWord = (string) ->
	i = 0
	f = ->
		code = string.charCodeAt(i)
		hangmanKeyInput(code)
		if i < string.length
			setTimeout f, 1
			i++
	f()

hangmanKeyInput = (code) ->
	client.execute("scope.getKeyInput({ keyCode: " + code + "});scope.$apply()")

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
				expect(text).toContain("Hangman")
				done()
	it 'should let me press start', (done) ->
		client.waitForVisible '#start', 5000
		client.click '#start'
		client.pause 2000
		done()
	it 'should let me type the first word', (done) ->
		setTimeout ->
			hangmanTypeWord "CELL MEMBRANE"
			client.pause 500
			client.waitForVisible ".next", 1000
			client.getAttribute '.next', 'class', (err, classes) ->
				expect(classes).not.toContain('ng-hide')
				done()
		, 1500

	it 'should move on to the next page', (done) ->
		client.click '.next'
		client.pause 200
		done()

	it 'should give me an X when I get something wrong', (done) ->
		setTimeout ->
			hangmanTypeWord "Q"
			client.waitForVisible ".icon-close.shown"
			client.getAttribute '.icon-close.shown', 'class', (err, classes) ->
				expect(classes).toContain('shown')
				done()
		, 1500

	it 'should drop an anvil when I run out of chances', (done) ->
		hangmanTypeWord "NAXZM"
		client.waitFor ".stage-final-add-active", 5000
		client.getAttribute '.stage-final-add-active', 'class', (err, classes) ->
			expect(classes).toContain('anvil-container')
			client.pause 500
			client.waitForVisible ".next", 1000
			client.click '.next'
			done()

	it 'should be able to complete mitochondria with partials', (done) ->
		setTimeout ->
			hangmanTypeWord "MITOCHNDRA"
			client.pause 500
			client.waitForVisible ".next"
			client.getAttribute '.next', 'class', (err, classes) ->
				expect(classes).not.toContain('ng-hide')
				client.waitForVisible ".next"
				client.click '.next'
				client.pause 500
				done()
		, 2000

	it 'should be able to complete chloroplasts with partial credit', (done) ->
		setTimeout ->
			hangmanTypeWord "ZXYCHLOROPLASTS"
			client.pause 500
			client.waitForVisible ".next"
			client.getAttribute '.next', 'class', (err, classes) ->
				expect(classes).not.toContain('ng-hide')
				client.waitForVisible ".next"
				client.click '.next'
				client.pause 500
				done()
		, 1500

	it 'should be able to type in arbitrary order', (done) ->
		setTimeout ->
			hangmanTypeWord "PLASMCYTO"
			client.pause 500
			client.waitForVisible ".next"
			client.getAttribute '.next', 'class', (err, classes) ->
				expect(classes).not.toContain('ng-hide')
				client.waitForVisible ".next"
				client.click '.next'
				client.pause 500
				done()
		, 1500

	it 'should pass final check', (done) ->
		setTimeout ->
			hangmanTypeWord "TYCSKLENTO"
			client.pause 700
			client.waitForVisible ".finished"
			client.getAttribute '.finished', 'class', (err, classes) ->
				expect(classes).not.toContain('ng-hide')
				client.execute('window.scope.endGame()')
				done()
		, 1500

describe 'Score page', ->
	it 'should get a 83', (done) ->
		client.pause(3000)
		client.getTitle (err, title) ->
			expect(title).toBe('Score Results | Materia')
			client
				.waitForVisible('.overall-score, .overall_score')
				.getText '.overall-score, .overall_score', (err, text) ->
					expect(text).toBe('83%')
					client.call(done)
					client.end()

