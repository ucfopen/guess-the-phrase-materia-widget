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
			browserFailure.setAttribute("id", "browserFailure");

			loadbar = document.createElement('div');
			loadbar.setAttribute("class", "bar");

			stageExists = document.getElementById("stage");
			browserFailureExists = document.getElementById("browserFailure");
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

		// Status: In Progress
		//TODO: Test the $scope.max and $scope.keyboard variables
		it('starts properly', function(){
			$scope.start(widgetInfo, qset.data);

			expect(document.getElementById("browserFailure").style.display)
				.toEqual('');

		 	expect(qset.data.options.attempts).toEqual(5);
			expect($scope.total).toEqual(6);

			expect($scope.title).toBe("Parts of a Cell");

			expect($scope.keyboard).toEqual(reset.keyboard());
			fail("Test not complete.");
		});

		// Status: Not Started
		// TODO:
		// it('toggles a game on correctly', function(){
		// 	$scope.gameDone = false;
		// 	expect($scope.startGame).toHaveBeenCalled();
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

		// Status: In progress
		// TODO: figure out how to test a function that returns no specific value
		// 	such as a void function
		it('does not instantiate a game already in progress', inject(function($timeout){
			$scope.startGame();
			fail("Test not complete");
		}));

		// Status: Finished
		it('should end the widget properly', function(){
			$scope.endGame();
			expect(Materia.Engine.end).toHaveBeenCalled();
		});

		// // Status: Not Started
		// // TODO:
		// 	fail("Test not completed");
		// });

		// // Status: Not Started
		// // TODO:
		// it('start a question correctly', function(){
		// 	fail("Test not completed");
		// });

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
		});

		// // Status: Not Started
		// // TODO:
		// it('shuffle a question correctly', function(){
		// 	fail("Test not completed");
		// });

		// // Status: Not Started
		// // TODO:
		// it('knows how to identify a letter', function(){
		//
		// });
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
