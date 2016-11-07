HangmanEngine = angular.module 'HangmanEngine'

HangmanEngine.controller 'HangmanEngineCtrl', ['$scope', '$timeout', 'Parse', 'Reset', 'Input', ($scope, $timeout, Parse, Reset, Input) ->
	_qset = null

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
			_endGame()
		else if not $scope.loading
			_startGame()

	_startGame =  ->
		throw new Error 'Game has already been initialized' if $scope.inGame

		$scope.curItem++
		$scope.anvilStage = 1
		$scope.inGame = true
		$scope.inQues = true
		$scope.readyForInput = true
		$scope.ques = _qset.items[0].items[$scope.curItem].questions[0].text
		$scope.answer = Parse.forBoard _qset.items[0].items[$scope.curItem].answers[0].text
		$timeout ->
			Hangman.Draw.playAnimation 'torso', 'pull-card'
		, 800

	_endGame = ->
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
					$scope.startQuestion()
				else
					_endQuestion()

	$scope.getUserInput = (input) ->
		# Don't process keys that have been entered
		if $scope.keyboard[input].hit is 1 then return

		# If the hangman was bored, he'll now snap out of it
		Hangman.Draw.breakBoredom true

		$scope.keyboard[input].hit = 1
		matches = Input.isMatch input, $scope.answer.string

		# User entered an incorrect guess
		if matches.length is 0
			$scope.max = Input.incorrect $scope.max
			_updateAnvil()

		# User entered a correct guess
		else
			$scope.answer.guessed = Input.correct matches, input, $scope.answer.guessed


		# Find out if the user can continue to submit guesses
		result = Input.cannotContinue $scope.max, $scope.answer.guessed

		if result
			_endQuestion()

			# The user can't continue because they won and are awesomesauce
			if result is 2
				Hangman.Draw.playAnimation 'torso', 'pander'
				$scope.anvilStage = 1

	$scope.startQuestion = ->
		$scope.inQues = true
		$scope.curItem++
		$timeout ->
			$scope.answer = Parse.forBoard _qset.items[0].items[$scope.curItem].answers[0].text
		, 500
		$timeout ->
			$scope.ques = _qset.items[0].items[$scope.curItem].questions[0].text
			$scope.readyForInput = true
		, 700

		Hangman.Draw.playAnimation 'torso', 'pull-card'

	_endQuestion = ->
		Hangman.Draw.breakBoredom false

		# Submit the user's answer to Materia
		ans = Parse.forScoring $scope.answer.guessed
		Materia.Score.submitQuestionForScoring _qset.items[0].items[$scope.curItem].id, ans

		# Hide DOM elements relevant to a question
		$scope.inQues = false
		# Stop the user from typing
		$scope.readyForInput = false

		if $scope.curItem is $scope.total-1
			$scope.inGame = false
			# Assigning this triggers the finish button's visibility
			$scope.gameDone = true
			# Push the score but don't redirect yet
			Materia.Engine.end no
		else
			# Prepare elements for the next question
			$scope.max = Reset.attempts ~~_qset.options.attempts
			$scope.keyboard = Reset.keyboard()

	_shuffle = (a) ->
		for i in [1...a.length]
			j = Math.floor Math.random() * (a.length)
			[a[i], a[j]] = [a[j], a[i]]
		a

	$scope.start = (instance, qset) ->
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
		$scope.title = instance.name
		# document.getElementById('start').focus()

		Hangman.Draw.initCanvas()

	$scope.isLetter = (letter) ->
		!letter or letter.match(/[a-zA-Z0-9]/)

	Materia.Engine.start($scope)
]
