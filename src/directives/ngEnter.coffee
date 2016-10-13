HangmanEngine = angular.module 'HangmanEngine'

HangmanEngine.directive('ngEnter', ->
	return (scope, element, attrs) ->
		element.bind("keydown keypress", (event) ->
			if(event.which == 13)
				scope.$apply ->
					scope.$eval(attrs.ngEnter)
				event.preventDefault()
		)
)
