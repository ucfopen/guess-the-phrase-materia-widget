HangmanEngine = angular.module 'HangmanEngine'

HangmanEngine.factory 'Input', ->
	isMatch: (key, answer) ->
		# Store matching column, row indices in array
		matches = []
		for i in [0...answer.length]
			for j in [0...answer[i].length]
				# Push matching coordinates
				match = (answer[i][j].letter.toLowerCase() is key.toLowerCase())
				if match then matches.push [i, j]
		matches

	incorrect: (max) ->
		# Find the current attempt the user is on
		for i in [0...max.length]
			if max[i].fail is true
				continue
			else
				max[i].fail = true
				break

		# Update the host's sense of impending doom
		Hangman.Draw.incorrectGuess i+1, max.length

		max

	correct: (matches, input, guessed) ->
		# Bind the user's input to the answer board
		for i in [0...matches.length]
			guessed[matches[i][0]][matches[i][1]] = input

		# Give that user some of dat positive affirmation
		Hangman.Draw.playAnimation 'heads', 'nod'

		guessed

	cannotContinue: (max, guessed) ->
		# Check to see if attempts are exhausted
		for i in [0...max.length]
			if max[i].fail is true then continue
			else break
		if i is max.length
			# Represents exhausted attempts
			return 1

		# Return false if the entire word hasn't been guessed
		for i in [0...guessed.length]
			empty = guessed[i].indexOf ''
			if empty isnt -1
				return false

		# Represents all letters correctly guessed
		return 2
