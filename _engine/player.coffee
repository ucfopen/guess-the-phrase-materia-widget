###

Materia
It's a thing

Widget  : Hangman, Creator
Authors : Micheal Parks
Updated : 11/13

###

Namespace('Hangman').Engine = do () ->
	_qset = _scope = null

	start = (instance, qset, version = '1') ->
		_qset = qset
		total = _qset.items[0].items.length

		_scope = angular.element($('body')).scope()
		_scope.$apply -> _scope.init(qset)

		# TODO GET RID OF
		window.localStorage.clear()

		# Add title and total number of questions.
		document.getElementsByClassName('title')[0].innerHTML = instance.name
		document.getElementsByClassName('total-questions')[0].innerHTML = 'of '+total

		Hangman.Draw.initCanvas()

		document.getElementById('start').focus()

	_getStorage = (key) ->
		if not window.localStorage then return false
		window.localStorage[key]

	_setStorage = (key, value) ->
		if not window.localStorage then return false
		window.localStorage[key] = value

	submitQuestion = (id, ans) ->
		Materia.Score.submitQuestionForScoring id, ans

	start: start
	qset: _qset
	submitQuestion: submitQuestion

# Load Materia Dependencies and start.
do () -> require ['enginecore', 'score'], (util) -> Materia.Engine.start Hangman.Engine


