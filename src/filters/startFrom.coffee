# filter for use with paginating ng-repeat lists
Hangman.filter 'startFrom', ->
	(input, start) ->
		start = +start # make sure 'start' is a number
		input.slice start # return only the items after the index given as 'start'
