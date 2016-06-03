client = {}

describe 'Testing framework', ->
	it 'should load widget', (done) ->
		require('./widgets.coffee') 'hangman', ->
			client = this
			done()
	, 45000

hangmanTypeWord = (string) ->
		hangmanKeyInput string, 0

hangmanKeyInput = (string, i) ->

	if i < string.length
		client.execute("scope.getKeyInput({ keyCode: " + string.charCodeAt(i) + "});scope.$apply()").then ->
			hangmanKeyInput string, i+1


describe 'Main page', ->
	it 'should have a title', (done) ->
		client.getText '.portal h1', (err, text) ->
			expect(text).toContain("Hangman")
			client.call done

	it 'should let me press start', (done) ->
		client.pause 2000
		client.click '#start'
		client.pause 2000
		client.call done

	it 'should let me type the first word', (done) ->
		client.waitFor '.keyboard', 2000
		hangmanTypeWord 'CELL MEMBRANE'
		client.pause 2000
		client.call done

	it 'should move on to the next page', (done) ->
		client.click '.next'
		client.pause 2000
		client.call done

	it 'should give me an X when I get something wrong', (done) ->
		hangmanTypeWord 'Q'
		client.pause 2000
		client.getAttribute '.icon-close.shown', 'class', (err, classes) ->
			expect(classes).toContain('shown')
			client.call done

	it 'should drop an anvil when I run out of chances', (done) ->
		hangmanTypeWord 'NAXZM'
		client.pause 2000
		client.getAttribute '.stage-final-add-active', 'class', (err, classes) ->
			expect(classes).toContain('anvil-container')
			client.click '.next'
			client.call done

	it 'should be able to complete mitochondria with partials', (done) ->
		client.pause 2000
		hangmanTypeWord 'MITOCHNDRA'
		client.pause 2000
		client.click '.next'
		client.call done

	it 'should be able to complete chloroplasts with partial credit', (done) ->
		client.pause 2000
		hangmanTypeWord "ZXYCHLOROPLASTS"
		client.pause 2000
		client.click '.next'
		client.call done

	it 'should be able to type in arbitrary order', (done) ->
		client.pause 2000
		hangmanTypeWord "PLASMCYTO"
		client.pause 2000
		client.click '.next'
		client.call done

	it 'should pass final check', (done) ->
		client.pause 2000
		hangmanTypeWord "TYCSKLENTO"
		client.pause 2000
		client.waitFor '.finished', 3000
		client.execute('window.scope.endGame()')
		client.call done

describe 'Score page', ->
	it 'should get a 83', (done) ->
		client.pause 10000
		client.getTitle (err, title) ->
			expect(title).toBe('Score Results | Materia')
			client
				.getText '.overall-score, .overall_score', (err, text) ->
					expect(text).toBe('83%')
					client.call(done)
					client.end()
	, 40000

