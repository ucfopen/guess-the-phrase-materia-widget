# Create an angular module to import the animation module and house our controller.
Hangman = angular.module 'HangmanCreator', ['ngAnimate', 'ngSanitize', 'hammer']

# filter for use with paginating ng-repeat lists
Hangman.filter 'startFrom', ->
	(input, start) ->
		start = +start # make sure 'start' is a number
		input.slice start # return only the items after the index given as 'start'

Hangman.directive('ngEnter', ->
	return (scope, element, attrs) ->
		element.bind("keydown keypress", (event) ->
			if(event.which == 13)
				scope.$apply ->
					scope.$eval(attrs.ngEnter)
				event.preventDefault()
		)
)

Hangman.directive('focusMe', ['$timeout', '$parse', ($timeout, $parse) ->
	link: (scope, element, attrs) ->
		model = $parse(attrs.focusMe)
		scope.$watch model, (value) ->
			if value
				$timeout ->
					element[0].focus()
			value
])

Hangman.factory 'Resource', ['$sanitize', ($sanitize) ->
	buildQset: (title, items, partial, attempts, random) ->
		qsetItems = []
		qset = {}

		# Decide if it is ok to save.
		if title is ''
			Materia.CreatorCore.cancelSave 'Please enter a title.'
			return false
		else
			for i in [0..items.length-1]
				if items[i].answer and items[i].answer.string.length > 3
					Materia.CreatorCore.cancelSave '#'+(i+1)+' will not fit on the gameboard.'
					return false
				# letters, numbers, spaces, periods, commas, dashes and underscores only
				# prevent characters from being used that cannot be input by the user
				if not /[a-zA-Z0-9]/.test(items[i].ans)
					Materia.CreatorCore.cancelSave 'Word #'+(i+1)+' needs to contain at least one letter or number.'
					return false

		qset.options = {partial: partial, attempts: attempts, random: random}
		qset.assets = []
		qset.rand = false
		qset.name = title

		for i in [0..items.length-1]
			item = @processQsetItem items[i]
			qsetItems.push item if item
		qset.items = [{items: qsetItems}]

		qset

	processQsetItem: (item) ->
		return false if item.ans == ''

		item.ques = item.ques
		item.ans = item.ans

		assets: []
		materiaType: "question"
		id: item.id
		type: 'QA'
		questions: [{text : item.ques}]
		answers: [{value : '100', text : item.ans}]

	# IE8/IE9 are super special and need this
	placeholderPolyfill: () ->
		$('[placeholder]')
		.focus ->
			if this.value is this.placeholder
				this.value = ''
				this.className = ''
		.blur ->
			if this.value is '' or this.value is this.placeholder
				this.className = 'placeholder'
				this.value = this.placeholder

		$('form').submit ->
			$(this).find('[placeholder]').each ->
				if this.value is this.placeholder then this.value = ''
]

# Set the controller for the scope of the document body.
Hangman.controller 'HangmanCreatorCtrl', ['$scope', '$sanitize', 'Resource',
($scope, $sanitize, Resource) ->
	$scope.title = "My Hangman widget"
	$scope.items = []
	$scope.partial = false
	$scope.random = false
	$scope.attempts = 5

	# for use with paginating results
	$scope.currentPage = 0;
	$scope.pageSize = 20;

	# determine how many pages of questions we have
	$scope.numberOfPages = ->
		Math.ceil $scope.items.length/$scope.pageSize

	$scope.updateForBoard = (item) ->
		if item.ans
			item.answer = $scope.forBoard(item.ans.toString())

	$scope.forBoard = (ans) ->
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
					dashes[j] = false
					ans[j] = ans[j].substr(0, ans[j].length - 1)
				if ans[j] == ''
					dashes.splice(j,1)
					ans.splice(j,1)
			if dashes[dashes.length-1]
				dashes[dashes.length-1] = false

		else
			# If the answer wasn't split then insert it into a row
			ans = [ans]

		# Now that the answer string is ready, data-bind it to the DOM
		for i in [0..ans.length-1]
			guessed.push []
			answer.push []
			for j in [0..ans[i].length-1]
				# Pre-fill punctuation or spaces so that the DOM shows them
				if ans[i][j] is ' ' or ans[i][j]? and ans[i][j].match /[\.,-\/#!?$%\^&\*;:{}=\-_`~()']/g
					guessed[i].push ans[i][j]
				else
					guessed[i].push ''
				answer[i].push {letter: ans[i][j]}

		# Return the parsed answer's relevant data
		{dashes:dashes, guessed:guessed, string:answer}

	# View actions
	$scope.setTitle = ->
		$scope.title = $scope.introTitle or $scope.title
		$scope.step = 1
		$scope.hideCover()

	$scope.hideCover = ->
		$scope.showTitleDialog = $scope.showIntroDialog = false

	$scope.initNewWidget = (widget, baseUrl) ->
		$scope.$apply ->
			$scope.showIntroDialog = true

	$scope.initExistingWidget = (title, widget, qset, version, baseUrl) ->
		$scope.title = title
		$scope.attempts = ~~qset.options.attempts or 5
		$scope.partial = qset.options.partial
		$scope.random = qset.options.random
		$scope.onQuestionImportComplete qset.items[0].items

		$scope.$apply()

	$scope.onSaveClicked = (mode = 'save') ->
		qset = Resource.buildQset $sanitize($scope.title), $scope.items, $scope.partial, $scope.attempts, $scope.random
		if qset then Materia.CreatorCore.save $sanitize($scope.title), qset

	$scope.onSaveComplete = (title, widget, qset, version) -> true

	$scope.onQuestionImportComplete = (items) ->
		$scope.addItem items[i].questions[0].text, items[i].answers[0].text, items[i].id for i in [0..items.length-1]
		$scope.$apply()

	$scope.onMediaImportComplete = (media) -> true

	$scope.addItem = (ques = "", ans = "", id = "") ->
		pages = $scope.numberOfPages()
		$scope.items.push {ques:ques, ans:ans, foc:false, id: id }
		# if adding this item makes a new page, go to that new page
		if pages > 0 and pages < $scope.numberOfPages()
			$scope.currentPage++
		console.log("add")


	$scope.removeItem = (index) ->
		console.log("remove")
		# Note: ng-repeat's $index will not take into account pagination
		# Offset the index based on the current page & page size
		itemsIndex = $scope.currentPage * $scope.pageSize + index
		$scope.items.splice itemsIndex, 1

		# If removing this item empties the page, paginate backwards
		pages = $scope.numberOfPages()
		if $scope.currentPage > 0 and $scope.currentPage > (pages - 1) then $scope.currentPage--

	$scope.setAttempts = (num) ->
		$scope.attempts = num

	$scope.setPartial = (bool) ->
		$scope.partial = bool

	$scope.editItem = (item,index) ->
		item.editing = true

	$scope.isLetter = (letter) ->
		letter.match(/[a-zA-Z0-9]/)

	$scope.moveItemDown = (index) ->
		if(index != $scope.items.length-1)
			temp = $scope.items[index+1]
			$scope.items[index+1] = $scope.items[index]
			$scope.items[index] = temp

	$scope.moveItemUp = (index) ->
		if(index != 0)
			temp = $scope.items[index-1]
			$scope.items[index-1] = $scope.items[index]
			$scope.items[index] = temp

	Materia.CreatorCore.start $scope
]
