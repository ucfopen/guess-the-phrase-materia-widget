HangmanEngine = angular.module 'HangmanEngine', ['ngAnimate']

# Adds physical keyboard functionality
HangmanEngine.directive 'onKeyup', () ->
	(scope, elm) ->
		elm.bind 'keyup', (event) ->
			if scope.inQues
				# Parse the letter
				letter = String.fromCharCode(event.keyCode).toLowerCase()

				# Search the keyboard's keys for the input
				if scope.keyboard.hasOwnProperty letter
					# Start a digest cycle for user input
					scope.$apply -> scope.getUserInput letter
			else
				if event.keyCode is 13
					# The user hit enter to move on to another question
					if scope.inGame and !scope.inQues
						return scope.$apply -> scope.startQuestion()

# Add Hammer support for mobile
HangmanEngine.directive 'hammerTap', () ->
	(scope, element, attrs) ->
		Hammer(element[0]).on 'tap', (event) ->
			scope.$apply attrs['onTap']

HangmanEngine.controller 'HangmanEngineCtrl', ['$scope', '$timeout', ($scope, $timeout) ->
	_qset = null

	isFirefox = /firefox/i.test navigator.userAgent
	isIE = /MSIE (\d+\.\d+);/.test navigator.userAgent
	if isFirefox then $scope.cssQuirks = true

	$scope.loading = true
	$scope.total = null # Total questions
	$scope.inGame = false
	$scope.inQues = false # Handles what appears on DOM
	$scope.curItem = -1 # The current qset item index
	$scope.curAns = [] # 2D array of parsed answer string, made to fit on the board
	$scope.ques = null # current question.
	$scope.added = [] # Correctly guessed letters with indices matching $scope.curAns
	$scope.dash = []
	$scope.max = [] # Maximum amount of failed attempts
	$scope.anvilStage = 0
	$scope.keyboard = null # Bound to onscreen keyboard, hit prop fades out key when 1

	_resetKeyboard = () ->
		# Return a new keyboard object literal
		'0':{hit:0},'1':{hit:0},'2':{hit:0},'3':{hit:0},'4':{hit:0},'5':{hit:0},'6':{hit:0},'7':{hit:0},'8':{hit:0},'9':{hit:0},
		'q':{hit:0},'w':{hit:0},'e':{hit:0},'r':{hit:0},'t':{hit:0},'y':{hit:0},'u':{hit:0},'i':{hit:0},'o':{hit:0},'p':{hit:0},
		'a':{hit:0},'s':{hit:0},'d':{hit:0},'f':{hit:0},'g':{hit:0},'h':{hit:0},'j':{hit:0},'k':{hit:0},'l':{hit:0},
		'z':{hit:0},'x':{hit:0},'c':{hit:0},'v':{hit:0},'b':{hit:0},'n':{hit:0},'m':{hit:0}

	_resetAttempts = () ->
		attempts = []
		for i in [0.._qset.options.attempts]
			attempts.push { fail: false }
		attempts

	_parseAnsForBoard = () ->
		# Reset question-specific data
		$scope.dash = []
		$scope.added = []
		$scope.curAns = []
		# We're going to pound this string into the board format
		str = _qset.items[0].items[$scope.curItem].answers[0].text

		# This parsing is only necessary for multi-row answers
		if str.length >= 13
			str = str.split ' '
			i = null
			for i in [0..str.length-1]
				# Add as many words as we can to a row
				j = i
				while str[i+1]? and str[i].length + str[i+1].length < 12
					temp = str.slice i+1, i+2
					str.splice i+1, 1
					str[i] += ' '+temp
				# Check to see if a word is too long for a row
				if str[i]? and str[i].length > 12
					temp = str[i].slice 11, str[i].length
					str[i] = str[i].substr 0, 11
					$scope.dash[i] = true
					str[i+1] = temp+' '+ if str[i+1]? then str[i+1] else ''
		else
			# If the answer wasn't split then insert it into a row
			str = [str]

		# Now that the string is ready, data-bind it to the DOM
		for i in [0..str.length-1]
			$scope.added.push []
			$scope.curAns.push []
			for j in [0..str[i].length-1]
				if str[i][j] is ' ' or str[i][j].match /[\.,-\/#!?$%\^&\*;:{}=\-_`~()]/g
					$scope.added[i].push str[i][j]
				else
					$scope.added[i].push ''
				$scope.curAns[i].push { letter: str[i][j] }

	_parseAnsForScoring = (ans) ->
		# Insert spaces at the end of each row
		if ans.length > 1
			for i in [0..ans.length-2]
				ans[i][ans[i].length] = ' '

		# Flatten the answer array and join it into a string
		ans = [].concat ans...
		ans = ans.join ''
		ans

	_isMatch = (key) ->
		# Store matching column, row indices in array
		matches = []
		for i in [0..$scope.curAns.length-1]
			for j in [0..$scope.curAns[i].length-1]
				# Push matching coordinates
				match = ($scope.curAns[i][j].letter.toLowerCase() == key.toLowerCase())
				if match then matches.push [i, j]
		matches

	# Register an incorrect answer
	_wrongGuess = () ->
		for i in [0..$scope.max.length-1]
			if $scope.max[i].fail is true
				continue
			else
				$scope.max[i].fail = true
				break

		_updateAnvil()

		# Update the host's sense of impending doom
		Hangman.Draw.incorrectGuess i+1, $scope.max.length

		# Return whether to end the question or not
		if i+1 is $scope.max.length then true
		else false

	_rightGuess = (matches, value) ->
		# Give that user some of dat positive affirmation
		Hangman.Draw.playAnimation 'heads', 'nod'

		# Bind the user's input to the answer board
		for i in [0..matches.length-1]
			$scope.added[matches[i][0]][matches[i][1]] = value

		# Return false if the entire word hasn't been guessed
		for i in [0..$scope.added.length-1]
			empty = $scope.added[i].indexOf ''
			if empty isnt -1 then return false

		# If the user guessed the entire answer then applaud
		Hangman.Draw.playAnimation 'torso', 'pander'
		$scope.anvilStage = 1
		true

	_updateAnvil =  ->
		# Get number of entered attempts
		for i in [0..$scope.max.length-1]
			if $scope.max[i].fail is true
				continue
			else
				break

		# Update the anvil's class
		$scope.anvilStage = i+1

		# If the anvil fell, return it for the next question
		if $scope.anvilStage is 7
			$timeout ->
				$scope.anvilStage = 0
			, 500

	$scope.init = (qset) ->
		_qset = qset
		$scope.total = _qset.items[0].items.length
		$scope.keyboard = _resetKeyboard()
		$scope.max = _resetAttempts()

	$scope.startQuestion = () ->
		$scope.inQues = true
		$scope.curItem++
		$timeout ->
			_parseAnsForBoard()
		, 500
		$timeout ->
			$scope.ques = _qset.items[0].items[$scope.curItem].questions[0].text
		, 700

		Hangman.Draw.playAnimation 'torso', 'pull-card'

	$scope.getUserInput = (value) ->
		# Don't process keys that have been entered
		if $scope.keyboard[value].hit is 1 then return

		Hangman.Draw.breakBoredom true

		$scope.keyboard[value].hit = 1
		matches = _isMatch value

		# No matches were returned, the user guessed incorrectly
		if matches.length is 0
			# _wrongGuess returns if all attempts have been exhausted
			if _wrongGuess value
				$scope.endQuestion()
		else
			# _rightGuess returns if all letters have been guessed
			if _rightGuess matches, value
				$scope.endQuestion()

	$scope.endQuestion = () ->
		Hangman.Draw.breakBoredom false

		if $scope.curItem is $scope.total-1
			$scope.inGame = false

		else
			# Hide DOM elements relevant to a question
			$scope.inQues = false

			# Prepare elements for the next question
			$scope.max = _resetAttempts()
			$scope.keyboard = _resetKeyboard()

			# Submit the user's answer to Materia
			ans = _parseAnsForScoring $scope.added
			Hangman.Engine.submitQuestion _qset.items[0].items[$scope.curItem].id, ans

	$scope.startGame = () ->
		$scope.curItem++
		$scope.inGame = true
		$scope.inQues = true
		$scope.ques = _qset.items[0].items[$scope.curItem].questions[0].text
		_parseAnsForBoard()
		$timeout ->
			Hangman.Draw.playAnimation 'torso', 'pull-card'
		, 800

	$scope.endGame = () ->
		window.localStorage.clear()
		Materia.Engine.end()
]