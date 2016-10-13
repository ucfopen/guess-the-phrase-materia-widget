HangmanEngine = angular.module 'HangmanEngine'

HangmanEngine.factory 'Resource', ['$sanitize', ($sanitize) ->
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
