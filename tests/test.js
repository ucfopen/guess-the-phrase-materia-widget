describe('Hangman Widget', function () {

	// grab the demo widget for easy reference
	var widgetInfo = window.__demo__['build/demo'];
	var qset = widgetInfo.qset;

	var $scope = {};
	var ctrl = {};
	var parse, reset;

	describe('Player Controller', function() {
		//grab the 'HangmanEngine' module for use in upcoming tests
		module.sharedInjector();
		beforeAll(module('HangmanEngine'));

		//set up the controller/scope prior to these tests
		beforeAll(inject(function($rootScope, $controller, Parse, Reset){
			//instantiate $scope with all of the generic $scope methods/properties
			$scope = $rootScope.$new();
			parse = Parse;
			reset = Reset;
			//pass $scope through the 'HangmanEngineCtrl' controller
			ctrl = $controller('HangmanEngineCtrl', { $scope: $scope });
		}));

		beforeEach(function(){
			var stage, browserFailure;
			var stageExists, browserFailureExists;

			//spy on Materia.Engine.end()
			spyOn(Materia.Engine, 'end');
			spyOn(Hangman.Draw, 'breakBoredom');
			spyOn(Hangman.Draw, 'playAnimation');

			// Referesh the DOM elements needed in testing to avoid test
			//  interdependency
			stage = document.createElement('canvas');
			stage.setAttribute("id", "stage");

			browserFailure = document.createElement('div');
			browserFailure.setAttribute("id", "browserfailure");

			loadbar = document.createElement('div');
			loadbar.setAttribute("class", "bar");

			stageExists = document.getElementById("stage");
			browserFailureExists = document.getElementById("browserfailure");
			loadbarExists = document.getElementsByClassName("bar")[0];

			if(stageExists)
    		document.body.removeChild(stageExists);

			if(browserFailureExists)
				document.body.removeChild(browserFailureExists);

			if(loadbarExists)
				document.body.removeChild(loadbarExists);

			document.body.appendChild(stage);
			document.body.appendChild(browserFailure);
			document.body.appendChild(loadbar);
		});

		// Status: Finished
		it('starts the game without randomizing questions', function(){
			$scope.start(widgetInfo, qset.data);

			expect(document.getElementById("browserfailure").style.display)
				.toEqual('');

		 	expect(qset.data.options.attempts).toEqual(5);
			expect($scope.total).toEqual(6);

			expect($scope.title).toBe("Parts of a Cell");

			expect($scope.max).toEqual(reset.attempts(qset.data.options.attempts));
			expect($scope.keyboard).toEqual(reset.keyboard());
		});

		// Status: Finished
		it('correctly initializes number of attempts when not explicitly set', function(){
			qset.data.options.attempts = null;

			$scope.start(widgetInfo, qset.data);

		 	expect(qset.data.options.attempts).toEqual(5);
		});

		// Status: Finished
		it('notifies browser failure when stage has no context', function(){
			stage = document.getElementById('stage').getContext = false;

			$scope.start(widgetInfo, qset.data);

			expect(document.getElementById('browserfailure').style.display)
				.toEqual('block');
		});

		// Status: In Progress
		// TODO: verify that the questions obtain a new order with each shuffle
		it('should shuffle answer order when the randomize option is on', function(){
			// this will make the output of Math.random() predictable, for the purpose
			//  of shuffling answers
			spyOn(Math, 'random').and.returnValue(0);

			// Set the id each question that will later be used for comparison
			function setIds(q)
			{
					for(var i in q)
					{
						q[i].id = i;
					}
			}

			//get a list of the answer ids for the supplied question - used to see which order the answers are in
			function listOfIds(q) {
				var list = [];
				for(var i in q) {
					list.push(q[i].id);
				}

				return list;
			}

			//check the first question - in this case it has 4 items in it
			setIds(qset.data.items[0].items);

			var list1 = listOfIds(qset.data.items[0].items);
			qset.data.options.random = true;
			$scope.start(widgetInfo, qset.data);
			//make sure we're checking the same question - use the first question's id
			var list2 = listOfIds(qset.data.items[0].items);
			expect(list1).not.toEqual(list2);
		});

		// // Status: Not Started
		// // TODO:
		// it('toggles a game off correctly', function(){
		// 	expect(Materia.Engine.end).toHaveBeenCalled();
		// });

		// Status: Finished
		it('instantiates a game correctly', inject(function($timeout){
			$scope.startGame();

			expect($scope.curItem).toEqual(0);
			expect($scope.anvilStage).toEqual(1);
			expect($scope.inGame).toBe(true);
			expect($scope.inQues).toBe(true);
			expect($scope.readyForInput).toBe(true);

			expect($scope.ques).toEqual(qset.data.items[0].items[$scope.curItem]
				.questions[0].text);

			expect($scope.answer).toEqual(parse.forBoard(qset.data.items[0].items
				[$scope.curItem].answers[0].text));

			$timeout.flush();
			$timeout.verifyNoPendingTasks();

			expect(Hangman.Draw.playAnimation).toHaveBeenCalled();
		}));

		// Status: Finished
		it('does not instantiate a game already in progress', function(){
			expect(function(){
    			$scope.startGame();
				}).toThrow(new Error('Game has already been initialized'));
		});

		// Status: Finished
		it('starts a question correctly', inject(function($timeout){
			// used to ensure the curItem is incremented currectly
			var prevItem = $scope.curItem;

			$scope.startQuestion();

			expect($scope.inQues).toBe(true);
			expect($scope.curItem).toEqual(prevItem + 1);

			$timeout.flush();
			$timeout.verifyNoPendingTasks();

			expect($scope.answer).toEqual(parse.forBoard(qset.data.items[0]
				.items[$scope.curItem].answers[0].text));

			expect($scope.ques).toEqual(qset.data.items[0].items[$scope.curItem]
				.questions[0].text);

			expect($scope.readyForInput).toBe(true);

			expect(Hangman.Draw.playAnimation).toHaveBeenCalled();
		}));

		// Status: In Progress
		// TODO:
		it('ends a question correctly', function(){
			$scope.endQuestion();
			expect(Hangman.Draw.breakBoredom).toHaveBeenCalled();

			// Stop all input from user
			expect($scope.inQues).toBe(false);
			expect($scope.readyForInput).toBe(false);

			// Make sure the game is not ended
			expect($scope.inGame).toBe(true);
			expect($scope.gameDone).toBe(false);

			expect($scope.max).toEqual(reset.attempts(qset.data.options.attempts));
			expect($scope.keyboard).toEqual(reset.keyboard());
		});

		// Status: In Progress
		// TODO:
		it('ends the last question correctly', function(){
			$scope.curItem = $scope.total - 1
			$scope.endQuestion();

			expect(Hangman.Draw.breakBoredom).toHaveBeenCalled();

			// Stop all input from user
			expect($scope.inQues).toBe(false);
			expect($scope.readyForInput).toBe(false);

			// Make sure the game is ended
			expect($scope.inGame).toBe(false);
			expect($scope.gameDone).toBe(true);
			expect(Materia.Engine.end).toHaveBeenCalled();
		});

		// Status: Finished
		it('ends the widget properly', function(){
			$scope.endGame();
			expect(Materia.Engine.end).toHaveBeenCalled();
		});

		// Status: Finished
		it('knows how to identify a valid letter', function(){
			var validLetters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"+
				"0123456789";

			for(var i=0; i<validLetters.length; i++)
				expect($scope.isLetter(validLetters.charAt(i))[0])
					.toEqual(validLetters.charAt(i));
		});

		// Status: Finished
		// TODO: Checking how the app reacts to emojis could be helpful
		it('knows how to identify an invalid letter', function(){
			// this is only a sample of invalid characters
			var invalidLetters = '~`!@#$%^&*()_+=-?><,./:;}{[]}\'\"{}|\][';

			for(var i=0; i<invalidLetters.length; i++)
				expect($scope.isLetter(invalidLetters.charAt(i))).toBe(null);
		});
	});

	// describe('Creator Controller', function(){
	// 	//grab the 'helloWidgetCreator' module for use in upcoming tests
	// 	module.sharedInjector();
	// 	beforeAll(module('helloWidget'));
	// 	//set up the controller/scope prior to these tests
	// 	beforeAll(inject(function($rootScope, $controller){
	// 		//instantiate $scope with all of the generic $scope methods/properties
	// 		$scope = $rootScope.$new();
	// 		//pass $scope through the 'helloWidgetCreatorCtrl' controller
	// 		ctrl = $controller('helloWidgetCreatorCtrl', { $scope: $scope });
	// 	}));

		// beforeEach(function(){
		// 	//lets us check which arguments are passed to this function when it's called
		// 	spyOn(Materia.CreatorCore, 'alert').and.callThrough();
		// 	spyOn(Materia.CreatorCore, 'save').and.callFake(function(title, qset){
		// 		//the creator core calls this on the creator when saving is successful
		// 		$scope.onSaveComplete();
		// 		return {title: title, qset: qset};
		// 	});
		// 	spyOn(Materia.CreatorCore, 'cancelSave').and.callFake(function(msg){
		// 		throw new Error(msg);
		// 	});
		// });
	// });
});
