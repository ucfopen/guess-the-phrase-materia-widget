HangmanEngine = angular.module 'HangmanEngine'

# filter for use with paginating ng-repeat lists
HangmanEngine.filter 'startFrom', ->
	(input, start) ->
		start = +start # make sure 'start' is a number
		input.slice start # return only the items after the index given as 'start'
