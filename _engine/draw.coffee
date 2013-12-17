Namespace('Hangman').Draw = do () ->
	_canvas = null
	_stage = null
	_loadBar = null
	_queue = null
	_host = {heads: [], torso: null}
	_headState = 0
	_bored = false
	_expressionTimer = null
	_boredTimer = null
	_breatheTimer = null
	_scope = null

	initCanvas = () ->
		_scope = angular.element($('body')).scope()
		_loadBar = document.getElementsByClassName('bar')[0]
		_canvas = document.getElementById 'stage'
		_stage = new createjs.Stage _canvas
		stage.snapToPixelsEnabled = true

		createjs.Ticker.setFPS 45
		# Use request animation frame when available.
		createjs.Ticker.useRAF = true

		_queue = new createjs.LoadQueue true
		_queue.addEventListener 'complete', _initSprites
		_queue.addEventListener 'progress', _animateProgress
		_queue.loadManifest [
			{src: "assets/img/background.png"}
			{src: "assets/img/finish.png"}
			{src: "assets/img/keyboard-bg.png"}
			{src: "assets/img/next.png"}
			{src: "assets/img/podium.png"}
			{src: "assets/img/anvil.png"}
			{src: "assets/spritesheets/head-fine.png"}
			{src: "assets/spritesheets/head-hurt.png"}
			{src: "assets/spritesheets/torso_0.png"}
			{src: "assets/spritesheets/torso_1.png"}
			{src: "assets/spritesheets/torso_2.png"}
			{src: "assets/spritesheets/torso_3.png"}
			{src: "assets/spritesheets/head-fine.json", id: "head-0"}
			{src: "assets/spritesheets/head-hurt.json", id: "head-1"}
			{src: "assets/spritesheets/torso.json", id: "torso"}
		]

	_animateProgress = (event) ->
		_loadBar.style.webkitTransform = 'scale('+event.loaded+', 1)'
		_loadBar.style.transform = 'scale('+event.loaded+', 1)'
		if event.loaded is 1
			# Fade out the progress bar when all assets are loaded
			setTimeout ->
				_scope.$apply -> _scope.loading = false
			, 400

	_initSprites = () ->
		# Create heads
		for i in [0..1]
			_host.heads.push new createjs.Sprite new createjs.SpriteSheet _queue.getResult 'head-'+i
			_host.heads[i].x = _canvas.width/2 - 15
			_host.heads[i].y = _canvas.height/4 - 65
			_host.heads[i].addEventListener 'animationend', _headsAnimationEnd

		# The hurt head should be hidden
		_host.heads[1].visible = false
				
		# Create torso
		_host.torso = new createjs.Sprite new createjs.SpriteSheet _queue.getResult 'torso'
		_host.torso.x = _canvas.width/2 + 20
		_host.torso.y = _canvas.height/4 - 50
		_host.torso.addEventListener 'animationend', _torsoAnimationEnd

		# Add the sprites to the stage.
		_stage.addChild _host.heads[0]
		_stage.addChild _host.heads[1]
		_stage.addChild _host.torso
		setTimeout ->
			_update()
		, 200

	_update = () ->
		_stage.update()

	_headsAnimationEnd = (event) ->
		# Stop the ticker
		createjs.Ticker.removeEventListener _update

		switch event.name
			when 'nod', 'bored1', 'bored2', 'bored3'
				_host.heads[_headState].stop()

	# 20 Seconds elapse before the host gets bored
	_boredTime = 20000
	_torsoAnimationEnd = (event) ->
		# Stop the animation and the ticker
		_host.heads[_headState].uncache()
		createjs.Ticker.removeEventListener _update

		switch event.name
			when 'pull-card'
				_host.torso.stop()
				# The host reads the card after pulling it out
				_host.heads[_headState].gotoAndPlay 'talk'
				setTimeout ->
					_host.heads[_headState].stop()
					if _scope.inQues
						_host.torso.gotoAndPlay 'put-away-card'
				, 2200
				_boredTimer = setTimeout _getBored, _boredTime
			when 'pander', 'put-away-card', 'fall', 'fix-glasses', 'sit-up-post'
				_host.torso.stop()
			when 'fall'
				_host.torso.stop()
				_host.torso.gotoAndStop 243
			when 'get-up'
				_host.torso.stop()
				_host.torso.gotoAndPlay 'fix-glasses'
				setTimeout ->
					_host.heads[_headState].gotoAndStop 0
				, 500

	_getBored = () ->
		# Save the interval ID to cancel it later
		_expressionTimer = window.setInterval _changeBoredom, 1000

		# The host eventually slouches from utter boredom
		setTimeout ->
			_host.torso.gotoAndPlay 'slouch-post'
			setTimeout ->
				_host.torso.stop()
			, 1000
			_bored = true
		, 10000

	_changeBoredom = () ->
		rand = Math.ceil Math.random()*3
		_host.heads[_headState].gotoAndPlay 'bored'+rand

	breakBoredom = (reset) ->
		_host.heads[_headState].stop()
		window.clearInterval _boredTimer
		window.clearInterval _expressionTimer

		if _bored
			_host.torso.gotoAndPlay 'sit-up-post'

		_bored = false
		if reset
			_boredTimer = setTimeout _getBored, _boredTime

	incorrectGuess = (num, max) ->
		breakBoredom false
		if num is 2 then _host.torso.gotoAndPlay 'breathe-heavily'
		if num is 3 then _host.heads[_headState].gotoAndPlay 'scared'
		if num is 4 then _host.heads[_headState].gotoAndPlay 'scared-up'
		if num is max
			_host.heads[_headState].gotoAndPlay 'ouch'
			_host.torso.gotoAndPlay 'fall'
			_canvas.classList.add 'anvil-struck'
			setTimeout ->
				_host.heads[_headState].visible = false
				_headState = 1
				_host.heads[_headState].visible = true
				_host.heads[_headState].gotoAndPlay 'dizzy'
				setTimeout ->
					_host.torso.gotoAndPlay 'get-up'
					setTimeout ->
						_canvas.classList.remove 'anvil-struck'
					, 1000
				, 1000
			, 1000

	updateAnvil = (max, stage) ->
		for i in [0..max.length-1]
			if max[i].fail then continue
			else break

			if stage is max
				stage = 7
				return setTimeout ->
					return 0
					setTimeout ->
						return 1
					, 50
				, 500
			else
				return stage+1

	# Extends ability to play animations to other modules
	playAnimation = (section, animation) ->
		# Ticker starts with animation
		createjs.Ticker.addEventListener 'tick', _update
		if section is 'torso'
			_host.heads[_headState].cache 0, 0, _canvas.width, _canvas.height
			_host.torso.stop()
			_host.torso.gotoAndPlay animation
		else
			_host.heads[_headState].gotoAndPlay animation

	initCanvas: initCanvas
	breakBoredom: breakBoredom
	incorrectGuess: incorrectGuess
	updateAnvil: updateAnvil
	playAnimation: playAnimation