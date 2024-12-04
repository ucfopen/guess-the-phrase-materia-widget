HangmanEngine = angular.module 'HangmanEngine', ['ngAnimate', 'hammer']

HangmanEngine.factory 'Host', ->

HangmanEngine.factory 'Parse', ->
	forBoard: (ans) ->
		# Question-specific data
		dashes = []
		guessed = []
		answer = []

		# This parsing is only necessary for multi-row answers
		if ans.length >= 13
			ans = ans.split ' '
			i = 0
			while i < ans.length
				# Add as many words as we can to a row
				j = i
				while ans[i+1]? and ans[i].length + ans[i+1].length < 12
					temp = ans.slice i+1, i+2
					ans.splice i+1, 1
					ans[i] += ' '+temp
				# Check to see if a word is too long for a row
				if ans[i]? and ans[i].length > 12
					temp = ans[i].slice 11, ans[i].length
					ans[i] = ans[i].substr 0, 11
					dashes[i] = true
					ans.push()
					ans[i+1] = temp+' '+ if ans[i+1]? then ans[i+1] else ''
				i++

			if ans.length > 3
				# we're out of bounds on the board and should cram things in there
				i = 0
				while i < ans.length
					# Add as many words as we can to a row
					j = i
					temp = ans.slice i+1, i+2
					ans.splice i+1, 1
					ans[i] += ' '+temp
					# Check to see if a word is too long for a row
					if ans[i]? and ans[i].length > 12
						temp = ans[i].slice 11, ans[i].length
						ans[i] = ans[i].substr 0, 11
						dashes[i] = true
						ans.push()
						ans[i+1] = temp+' '+ if ans[i+1]? then ans[i+1] else ''
					i++

			# trim ending spaces
			for j in [0...ans.length]
				while ans[j].substr(ans[j].length-1) == ' '
					ans[j] = ans[j].substr(0, ans[j].length - 1)

		else
			# If the answer wasn't split then insert it into a row
			ans = [ans]

		# Now that the answer string is ready, data-bind it to the DOM
		for i in [0...ans.length]
			guessed.push []
			answer.push []
			for j in [0...ans[i].length]
				# Pre-fill punctuation or spaces so that the DOM shows them
				if ans[i][j] is ' ' or ans[i][j] is '-' or not ans[i][j].match /[A-Za-z0-9]/g
					guessed[i].push ans[i][j]
				else
					guessed[i].push ''
				answer[i].push {letter: ans[i][j]}

		# Return the parsed answer's relevant data
		{dashes:dashes, guessed:guessed, string:answer}

	forScoring: (ans) ->
		# Insert spaces at the end of each row
		if ans.length > 1
			for i in [0..ans.length-2]
				ans[i][ans[i].length] = ' '

		# Flatten the answer array and join it into a string
		ans = [].concat ans...
		ans = ans.join ''
		ans

HangmanEngine.factory 'Reset', ->
	keyboard: ->
		# Return a new keyboard object literal
		'0':{hit:0},'1':{hit:0},'2':{hit:0},'3':{hit:0},'4':{hit:0},'5':{hit:0},'6':{hit:0},'7':{hit:0},'8':{hit:0},'9':{hit:0},
		'q':{hit:0},'w':{hit:0},'e':{hit:0},'r':{hit:0},'t':{hit:0},'y':{hit:0},'u':{hit:0},'i':{hit:0},'o':{hit:0},'p':{hit:0},
		'a':{hit:0},'s':{hit:0},'d':{hit:0},'f':{hit:0},'g':{hit:0},'h':{hit:0},'j':{hit:0},'k':{hit:0},'l':{hit:0},
		'z':{hit:0},'x':{hit:0},'c':{hit:0},'v':{hit:0},'b':{hit:0},'n':{hit:0},'m':{hit:0}

	attempts: (numAttempts) ->
		# This array of anon objects is bound to the attempt boxes on the DOM
		attempts = []
		attempts.push {fail: false} for i in [0...numAttempts]
		attempts

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

# directive to handle click events during the transition between questions
HangmanEngine.directive 'transitionManager', () ->
	restrict: 'A',
	link: ($scope, $element, $attrs) ->

		$scope.inTransition = false

		$element.on "transitionend", () ->
			if $scope.inTransition
				$scope.inTransition = false
				$scope.startQuestion()

		$scope.preStartQuestion = ->
			unless $scope.inTransition then $scope.inQues = $scope.inTransition = true


HangmanEngine.controller 'HangmanEngineCtrl', ['$scope', '$timeout', 'Parse', 'Reset', 'Input', ($scope, $timeout, Parse, Reset, Input) ->
	_qset = null

	isFirefox = /firefox/i.test navigator.userAgent
	isIE = /MSIE (\d+\.\d+);/.test navigator.userAgent
	if isFirefox then $scope.cssQuirks = true

	$scope.loading = true
	$scope.total = null # Total questions
	$scope.inGame = false
	$scope.inQues = false # Handles what appears on DOM
	$scope.readyForInput = false
	$scope.curItem = -1 # The current qset item index
	$scope.gameDone = false # Whether or not to show the game completed text
	$scope.ques = null # current question.
	$scope.answer = null

	$scope.max = [] # Maximum amount of failed attempts
	$scope.anvilStage = 0
	$scope.keyboard = null # Bound to onscreen keyboard, hit prop fades out key when 1

	$scope.focusTitleMessage = ''
	$scope.focusAnswerMessage = ''
	$scope.focusQuestionMessage = ''
	$scope.focusKeyboardMessage = ''

	_updateAnvil =  ->
		# Get number of entered attempts
		for i in [0...$scope.max.length]
			if $scope.max[i].fail is true
				continue
			else
				break

		# Update the anvil's class
		$scope.anvilStage = i+1

		# If the anvil fell, return it for the next question
		if $scope.anvilStage is $scope.max.length+1
			# The anvil drops
			$scope.anvilStage = 'final'
			$timeout ->
				# The anvil loses all css transitions and is moved to top
				$scope.anvilStage = 0
				$timeout ->
					# The anvil regains transitions
					$scope.anvilStage = 1
				, 50
			, 500

	$scope.toggleGame = ->
		if $scope.gameDone
			$scope.endGame()
		else if not $scope.loading
			$scope.startGame()

	$scope.startGame =  ->
		return if $scope.inGame



		liveRegionUpdate(("The game has begun! Your topic is " +
		document.getElementsByClassName('title')[0].innerHTML +
		" with " + $scope.total + " questions."), assertive )

		$scope.focusTitleMessage = document.getElementsByClassName('title')[0].innerHTML + " with " + $scope.total + " questions."

		$scope.curItem++
		$scope.anvilStage = 1
		$scope.inGame = true
		$scope.inQues = true
		$scope.readyForInput = true
		$scope.ques = _qset.items[0].items[$scope.curItem].questions[0].text
		$scope.answer = Parse.forBoard _qset.items[0].items[$scope.curItem].answers[0].text


		$scope.focusAnswerMessage = "The correct answer is: " + condenseBlanks($scope.answer.guessed)
		$scope.focusKeyboardMessage = "You have " + ($scope.max.length - $scope.anvilStage + 1) + " guesses. Press or type a letter."

		liveRegionUpdate("Question 1: " + $scope.ques + condenseBlanks($scope.answer.guessed))

		$timeout ->
			$scope.focusQuestionMessage = "Question " + ($scope.curItem + 1) + ": " + $scope.ques
			Hangman.Draw.playAnimation 'torso', 'pull-card'
		, 800



	$scope.endGame = ->
		Materia.Engine.end()

	$scope.getKeyInput = (event) ->
		if $scope.inQues and $scope.readyForInput
			key = event.keyCode

			# Correct for numpad
			if key >= 97
				key -= 48
			# Parse the incoming keycode
			letter = String.fromCharCode(key).toLowerCase()

			# Search the keyboard's keys for the input
			if $scope.keyboard.hasOwnProperty letter
				# send the input to be processed
				$scope.getUserInput letter
		else
			if event.keyCode is 13
				# The user hit enter to move on to another question
				if $scope.inGame and !$scope.inQues
					$timeout ->
						$scope.startQuestion()
				else
					$scope.toggleGame()


	assertive = 'assertive'
	polite = 'polite'


	liveRegionUpdate = (message, priority = polite) ->

		liveRegionId = if priority == assertive then 'ariaLiveAssertive' else 'ariaLivePolite'
		liveRegion = document.getElementById(liveRegionId)

		if liveRegion?
			liveRegion.textContent = ''
			setTimeout((->
			liveRegion.textContent = message), 100)
		else
			console.error("Live region with ID '#{liveRegionId}' not found.")


	addBlanksForLiveRegion = (guessed) ->
		# Takes the user's current answer and adds "blank" where there are blanks so the screen reader will read them out loud
		# Used to tell screen reader users what their current board looks like
		message = ''
		words = 0
		maxWords = 0
		for word in guessed
			maxWords += 1
		for word in guessed
			words += 1
			for letter in word
				if letter == ''
					message = message.concat('blank, ')
				else
					message = message.concat(letter, ', ')
			if words < maxWords
				message = message.concat('new word, ')

		return message

	guessedToString = (guessed) ->
		# Converts the user's current answer to a string to be read by the screen reader
		# Used to read the final answer in full words so the player knows what they got
		message = ''
		for word in guessed
			for letter in word
				message = message.concat(letter)
			message = message.concat(' ')
		return message

	usedKeysToString = () ->
		# Converts the user's previously guessed letters to a string to be read by the screen reader
		# Used to tell the player which letters they've already guessed, both correct and incorrect
		message = ''
		for index, letter of $scope.keyboard
			if letter.hit == 1
				message += index + ', '
		return message

	condenseBlanks = (guessed) ->
		# Counts the words in the answer and the letters in each word and turns them into a string
		# Used to tell the player how many words and letters are in the answer at the beginning of a question
		message = ''
		words = 0
		for word in guessed
			words += 1
		message = message.concat(words + " words. ")
		words = 0
		for word in guessed
			letters = 0
			words += 1
			message = message.concat("Word " + words + ": ")
			for letter in word
				letters += 1
			message = message.concat(letters + " letters. ")
		return message

	$scope.getUserInput = (input) ->
		# Keyboard appears slightly before question transition is complete, so ignore early inputs
		if $scope.inTransition then return
		# Don't process keys that have been entered
		if $scope.keyboard[input].hit is 1 then return

		# If the hangman was bored, he'll now snap out of it
		Hangman.Draw.breakBoredom true

		$scope.keyboard[input].hit = 1
		matches = Input.isMatch input, $scope.answer.string

		# User entered an incorrect guess
		totalGuesses = ($scope.max.length - 1) - $scope.anvilStage + 1



		if matches.length is 0
			$scope.max = Input.incorrect $scope.max
			_updateAnvil()
			liveRegionUpdate((input + " is incorrect. " + (totalGuesses) + " guesses remaining."), assertive)
			$scope.focusKeyboardMessage = (totalGuesses) + " guesses remaining. Letters guessed: " + usedKeysToString() + "You must guess all the letters in the answer or run out of guesses before moving on to the next question."

		# User entered a correct guess
		else
			$scope.answer.guessed = Input.correct matches, input, $scope.answer.guessed
			liveRegionUpdate(input + " is correct! Current answer: " + addBlanksForLiveRegion($scope.answer.guessed) + " Press or type another letter.", assertive)
			$scope.focusAnswerMessage = "Your current answer is displayed here. It is: " + addBlanksForLiveRegion($scope.answer.guessed) + " Guess another letter by pressing the corresponding key on the keyboard."
			$scope.focusKeyboardMessage = (totalGuesses) + " guesses remaining. Letters guessed: " + usedKeysToString() + "You must guess all the letters in the answer or run out of guesses before moving on to the next question."


		# Find out if the user can continue to submit guesses
		result = Input.cannotContinue $scope.max, $scope.answer.guessed
		if result
			liveRegionUpdate(("Out of guesses. Press Enter to go to the next question."), assertive)
			$scope.endQuestion()

			# The user can't continue because they won and are awesomesauce
			if result is 2
				Hangman.Draw.playAnimation 'torso', 'pander'
				$scope.anvilStage = 1
				liveRegionUpdate(guessedToString($scope.answer.guessed) + " is correct! Press Enter to go to the next question.")

	$scope.startQuestion = ->

		$scope.$apply ->
			$scope.inQues = true
			$scope.curItem++

			$scope.answer = Parse.forBoard _qset.items[0].items[$scope.curItem].answers[0].text
			$scope.ques = _qset.items[0].items[$scope.curItem].questions[0].text

			$scope.readyForInput = true

		liveRegionUpdate("Question " + ($scope.curItem + 1) + ": " + $scope.ques + condenseBlanks($scope.answer.guessed))
		$scope.focusQuestionMessage = "Question " + ($scope.curItem + 1) + ": " + $scope.ques
		$scope.focusAnswerMessage = "Current answer: " + condenseBlanks($scope.answer.guessed)
		$scope.focusKeyboardMessage = "You have " + ($scope.max.length - $scope.anvilStage + 1) + " guesses. Press or type a letter."

		Hangman.Draw.playAnimation 'torso', 'pull-card'

	$scope.endQuestion = ->
		Hangman.Draw.breakBoredom false

		# Submit the user's answer to Materia
		ans = Parse.forScoring $scope.answer.guessed
		Materia.Score.submitQuestionForScoring _qset.items[0].items[$scope.curItem].id, ans

		# Hide DOM elements relevant to a question
		$scope.inQues = false
		# Stop the user from typing
		$scope.readyForInput = false

		if $scope.curItem >= $scope.total-1 # >= for the rare instance where the index skips ahead unexpectedly (should be fixed though)
			$scope.inGame = false
			liveRegionUpdate(("The game has ended. Press Enter to view your score."),assertive)
			# Assigning this triggers the finish button's visibility
			$scope.gameDone = true
			# Push the score but don't redirect yet
			Materia.Engine.end no

		else
			# Prepare elements for the next question
			$timeout (() ->
				$scope.max = Reset.attempts ~~_qset.options.attempts
				$scope.keyboard = Reset.keyboard()
			), 500


	_shuffle = (a) ->
		for i in [1...a.length]
			j = Math.floor Math.random() * (a.length)
			[a[i], a[j]] = [a[j], a[i]]
		a

	$scope.start = (instance, qset, version = '1') ->
		# expose scope to test engine
		window.scope = $scope

		if (!document.getElementById('stage').getContext)
			document.getElementById('browserfailure').style.display = 'block'

		qset.options.attempts = 5 if not qset.options.attempts
		_qset = qset

		if _qset.options.random
			_qset.items[0].items = _shuffle _qset.items[0].items

		$scope.total = _qset.items[0].items.length
		$scope.max = Reset.attempts ~~_qset.options.attempts
		$scope.keyboard = Reset.keyboard()

		# Add title and total number of questions.
		document.getElementsByClassName('title')[0].innerHTML = instance.name
		document.getElementsByClassName('total-questions')[0].innerHTML = 'of ' + $scope.total
		document.getElementById('start').focus()

		$scope.focused = () =>
			startButton = document.getElementById('start');


		Hangman.Draw.initCanvas()

	$scope.isLetter = (letter) ->
		!letter or letter.match(/[a-zA-Z0-9]/)

	Materia.Engine.start($scope)

]
