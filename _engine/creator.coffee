###

Materia
It's a thing

Widget  : Hangman, Creator
Authors : Brandon Stull, Micheal Parks
Updated : 11/13

###

# Create an angular module to import the animation module and house our controller.
HangmanCreator = angular.module 'HangmanCreator', ['ngAnimate', 'ngTouch']

# Set the controller for the scope of the document body.
HangmanCreator.controller 'HangmanCreatorCtrl', ['$scope', ($scope) ->
	$scope.title = ""
	$scope.items = []
	$scope.partial = false
	$scope.attempts = 5

	$scope.addItem = (ques = "", ans = "") ->
		$scope.items.push {ques:ques, ans:ans, foc:false}

	$scope.removeItem = (index) ->
		$scope.items.splice index, 1
]

Namespace('Hangman').Creator = do () ->
	_title = _qset = _scope = null

	initNewWidget = (widget, baseUrl) ->
		_scope = angular.element($('body')).scope()
		_scope.$apply -> _scope.addItem()

		if not Modernizr.input.placeholder then _polyfill()

	initExistingWidget = (title, widget, qset, version, baseUrl) ->
		_items = qset.items[0].items
		_scope = angular.element($('body')).scope()
		_scope.$apply ->
			_scope.title = title
			_scope.attempts = qset.options.attempts
			_scope.partial = qset.options.partial
		onQuestionImportComplete _items

		if not Modernizr.input.placeholder then _polyfill()

	onSaveClicked = (mode = 'save') ->
		if _buildSaveData() is true
			Materia.CreatorCore.save _title, _qset 

	onSaveComplete = (title, widget, qset, version) -> true

	onQuestionImportComplete = (items) ->
		_scope.$apply ->
			_scope.addItem items[i].questions[0].text, items[i].answers[0].text for i in [0..items.length-1]

	onMediaImportComplete = (media) -> true

	_buildSaveData = () ->
		_title     = _escapeHTML _scope.title
		scopeItems = _scope.items
		qsetItems  = []

		# Decide if it is ok to save.
		if _title is '' then return Materia.CreatorCore.cancelSave 'Please enter a title.'
		else
			for i in [0..scopeItems.length-1]
				if scopeItems[i].ans.length > 34
					return Materia.CreatorCore.cancelSave 'Please reduce the number of characters in word #'+(i+1)+'.'

		if !_qset? then _qset = {}
		_qset.options = { partial : _scope.partial, attempts : _scope.attempts }
		_qset.assets  = []
		_qset.rand    = false
		_qset.name    = _title

		qsetItems.push _processQsetItem scopeItems[i] for i in [0..scopeItems.length-1]
		_qset.items = [{ items : qsetItems }]

		true

	# Get each card's data from the controller and organize it into Qset form.
	_processQsetItem = (item) ->
		item.ques = _escapeHTML item.ques
		item.ans  = item.ans

		qsetItem        = {}
		qsetItem.assets = []

		qsetItem.materiaType = "question"
		qsetItem.id          = ""
		qsetItem.type        = 'QA'
		qsetItem.questions   = [{text : item.ques}]
		qsetItem.answers     = [{value : '100', text : item.ans}]

		qsetItem

	# Escapes >, <, "", '',\ since they are UNSAFE!
	_escapeHTML = (string) -> 
		string
			.replace(/</g,'&lt;')
			.replace(/>/g,'&gt;')
			.replace(/"/g,'&quot')
			.replace(/'/g,'&#x27')
			.replace(/\//g,'&#x2F')

	# Adds input placeholder functionality in browsers that are more aged like fine wines.
	_polyfill = () ->
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

	_trace = () -> if console? && console.log? then console.log.apply console, arguments

	# Public.
	manualResize             : true
	initNewWidget            : initNewWidget
	initExistingWidget       : initExistingWidget
	onSaveClicked            : onSaveClicked
	onMediaImportComplete    : onMediaImportComplete
	onQuestionImportComplete : onQuestionImportComplete
	onSaveComplete           : onSaveComplete

# Load Materia Dependencies and start.
do () -> require ['creatorcore'], (util) -> Materia.CreatorCore.start Hangman.Creator
