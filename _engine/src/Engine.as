package
{
	import com.gskinner.motion.*;
	import com.gskinner.motion.easing.*;
	
	import events.HangmanEvent;
	
	import flash.accessibility.Accessibility;
	import flash.accessibility.AccessibilityProperties;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import nm.gameServ.engines.EngineCore;

//Stage Size: 800x600
	public class Engine extends EngineCore
	{
		private const LETTER_SIDE_PADDING:int = 5;
		private const LETTER_TOP_PADDING:int = 12;
		private const LETTER_HEIGHT:int = 55;
		private const LETTER_WIDTH:int = 35;
		private const QUESTION_MAX_CHARS_PER_LINE:int = 12;
		private const QUESTION_MAX_LINES:int = 3;
		private const QUESTION_MAX_CHARS:int = 3;
		private const ANVIL_X:int = 655;
		private const ANVIL_Y:int = -20;
		private const HOST_X:int = 505;
		private const HOST_Y:int = 178;
		private const CLUE_BUBBLE_X:int = 84;
		private const BUBBLE_BOTTOM_Y:int = 430;
		
		private var _screen:MainScreen;
		private var _pane:MovieClip;
		private var _gameBoard:MovieClip;
		private var _host:GameShowHost;
		private var _marquee:TextField;
		private var _clueBubble:HangmanFullTextSpeechBubble;
		private var _anvil:HangmanAnvil;
		private var _finishedPane:MovieClip;
		private var _wordNum:TextField;
		private var _keyboard:MovieClip;
		private var _wordArea:MovieClip;
		private var _hostLayer:MovieClip;
		private var _finishedButton:MovieClip;
		private var _nextButton:MovieClip;
		private var _progressBar:MovieClip;
		private var _remainingNum:TextField;
		private var _titleScreen:TitleScreen;
		private var _animationManager:HangmanAnimationManager;
		private var _animationTimer:Timer;
		private var myTimeline:*
		private var clue_bubble_height:int;
		private var clue_bubble_width:int;
		private var word_area_height:Number;
		private var word_area_width:Number;
		private var total_questions:Number;
		private var keyboardArray:Array;
		private var inputEnabled:Boolean = false;
		private var curWord:Array;
		private var curQuestion:Number;
		private var attemptsPerQuestion:Number;
		private var attemptsRemaining:Number;
		private var lettersGuessed:Array;
		private var curAttempts:Number;
		private var _partialScoring:Boolean = false;
		private var _scorePerLetter:Number;
		private var _keys:Vector.<MovieClip>
		private var _readerTarget:MovieClip;
		private var _currentQuestion:String;
		private var _helpSprite:Sprite;
		
		private function init():void
		{
			_screen = new MainScreen();
			_pane = _screen.pane;
			_gameBoard = _screen.gameboard;
			_host = new GameShowHost(this);
			_marquee = _screen.marquee.title;
			_clueBubble = new HangmanFullTextSpeechBubble();
			_titleScreen = new TitleScreen();
			_titleScreen.buttonMode = true;
			_anvil = new HangmanAnvil(this);
			_finishedPane = _pane.finished;
			_finishedButton = _finishedPane.button;
			_readerTarget = _screen.wordNum;
			_wordNum = _screen.wordNum.num;
			_readerTarget.accessibilityProperties = new AccessibilityProperties(); //can't focus on textfields
			_readerTarget.tabIndex = 1;
			_readerTarget.focusRect = false;
			_keyboard = _pane.keyboard;
			_nextButton = _pane.next;
			_nextButton.buttonMode = true;
			_nextButton.accessibilityProperties = new AccessibilityProperties();
			_nextButton.tabIndex = 2;
			_nextButton.focusRect = false;
			_progressBar = _pane.progressBar;
			_remainingNum = _screen.wordNum.remainingNum;
			_wordArea = _screen.wordGrid;
			_hostLayer = _screen.hostLayer;
			word_area_height = _wordArea.width;
			word_area_width = _wordArea.height;
			this.addChild(_screen);
			_screen.addChild(_clueBubble);
			_clueBubble.x = CLUE_BUBBLE_X;
			clue_bubble_height = _clueBubble.height;
			clue_bubble_width = _clueBubble.width;
			_screen.addChildAt(_anvil, 14);
			_anvil.x = ANVIL_X;
			_anvil.y = ANVIL_Y;
			_screen.addChildAt(_host, 15);
			_host.x = HOST_X;
			_host.y = HOST_Y;
			_animationManager = new HangmanAnimationManager();
			_animationManager.screen = this;
			_animationManager.host = _host;
			_animationManager.speechBubble = _clueBubble;
			_animationManager.anvil = _anvil;
			_animationManager.keyboard = _keyboard;
			this.addChild(_titleScreen);
			_titleScreen.addEventListener(MouseEvent.MOUSE_UP, hideTitleScreen, false, 0, true);
			
			if(Accessibility.active)
			{
				_titleScreen.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP));
				_helpSprite = new Sprite();
				_helpSprite.accessibilityProperties = new AccessibilityProperties();
				_helpSprite.accessibilityProperties.name = "Use tab to toggle between word information and the word clue. Type letters to guess them.";
				_helpSprite.tabIndex = 0;
				var helpText:TextField = new TextField();
				helpText.autoSize = TextFieldAutoSize.LEFT;
				helpText.text = "Help";
				_helpSprite.graphics.beginFill(0xFF4800);
				_helpSprite.graphics.drawRoundRect(0,0,helpText.width+5,helpText.height+5,10);
				_helpSprite.graphics.endFill();
				_helpSprite.addChild(helpText);
				helpText.x = (_helpSprite.width-helpText.width)/2;
				helpText.y = (_helpSprite.height-helpText.height)/2;
				_helpSprite.x = _helpSprite.y = 5;
				this.addChild(_helpSprite);
			}
		}
		
		protected override function startEngine():void
		{
			this.init();
			super.startEngine();
			_marquee.text = inst.name;
			attemptsRemaining = 5;
			
			if(qSetData.options != null && qSetData.options.attempts != null)
			{
				attemptsRemaining = int(qSetData.options.attempts);
			}
			
			if(qSetData.options != null && qSetData.options.partial != null)
			{
				_partialScoring = Boolean(qSetData.options.partial);
			}
			
			attemptsPerQuestion = attemptsRemaining;
			total_questions = qSetData.items[0].items.length;
			curQuestion = 0;
			lettersGuessed = [];
			initKeyboard();
			_keyboard.visible = true;
			_finishedPane.visible = false;
			_nextButton.visible = false;
			_remainingNum.text = String(total_questions);
				
			if(Accessibility.active)
			{
				Accessibility.updateProperties();
				addEventListener(MouseEvent.CLICK, focusHelpInitially);
				addEventListener(KeyboardEvent.KEY_DOWN, focusHelpInitially);
			}
			else
			{
				stage.focus = stage;
			}
		}
		
		private function focusHelpInitially(event:Event = null):void
		{
			removeEventListener(MouseEvent.CLICK, focusHelpInitially);
			removeEventListener(KeyboardEvent.KEY_DOWN, focusHelpInitially);
			stage.focus = _helpSprite;
			addEventListener(MouseEvent.CLICK, removeHelpInitially);
			addEventListener(KeyboardEvent.KEY_DOWN, removeHelpInitially);
		}
		
		private function removeHelpInitially(event:Event = null):void
		{
			removeEventListener(MouseEvent.CLICK, removeHelpInitially);
			removeEventListener(KeyboardEvent.KEY_DOWN, removeHelpInitially);
			stage.focus = _helpSprite;
		}
		
		private function hideTitleScreen(e:MouseEvent):void
		{
			_titleScreen.removeEventListener(MouseEvent.MOUSE_UP, hideTitleScreen);
			_titleScreen.gotoAndPlay("fadeOut");
			_titleScreen.addEventListener("done_fadeOut", removeTitleScreen, false, 0, true);
		}
		
		private function removeTitleScreen(e:Event):void
		{
			_titleScreen.removeEventListener("done_fadeOut", removeTitleScreen);
			this.removeChild(_titleScreen);
			nextQuestion();
		}
		
		private function get qSetCurQuestion():*
		{
			return qSetData.items[0].items[curQuestion-1];
		}
		
		public function get curClue():String
		{
			return qSetCurQuestion.questions[0].text;
		}
		
		private function nextQuestion():void
		{
			_keyboard.visible = true;
			_finishedPane.visible = false;
			_nextButton.visible = false;
			attemptsRemaining = attemptsPerQuestion;
			lettersGuessed = [];
			curQuestion++;
			_wordNum.text = String(curQuestion);
			this.dispatchEvent(new HangmanEvent(HangmanEvent.NEW_CLUE, true));
			_currentQuestion = qSetCurQuestion.answers[0].text;
			
			var formattedQuestion:String = formatQuestion(_currentQuestion);
			// remove the current letters on the screen
			if(curWord != null)
			{
				for(var f:Number = 0; f < curWord.length; f++)
				{
					_wordArea.removeChild(curWord[f].mc);
				}
			}
			// build the new letters on the screen
			curWord = [];
			var numRows:Number = 1;
			var curHeight:Number = 0;
			var curLineCount:Number = 0;
			var scoreLetter:Boolean = true;
			var totalLetters:Number = 0;
			_scorePerLetter = 0;
			updateReaderTarget();
			for(var i:Number = 0; i < formattedQuestion.length; i++)
			{
				var boardLetter:BoardLetter = new BoardLetter();
				boardLetter.x = curLineCount * (boardLetter.letterContainer.letterBackground.width+LETTER_SIDE_PADDING);
				boardLetter.y = curHeight;
				curLineCount++;
				boardLetter.letterContainer.letter.text = formattedQuestion.charAt(i);
				boardLetter.letterContainer.letter.visible = false;
				scoreLetter = true;
				var curCode:int = formattedQuestion.charCodeAt(i);
				if(curCode == 32) /* Space */
				{
					boardLetter.letterContainer.letterBackground.visible = false;
					scoreLetter = false;
				}
				else if(formattedQuestion.charAt(i) == "\n")
				{
					boardLetter.visible = false;
					curHeight += LETTER_HEIGHT + LETTER_TOP_PADDING;
					numRows++;
					curLineCount = 0;
					scoreLetter = false;
					continue;
				}
				else if(!(curCode>64 && curCode<91) /* [A-Z] */ && !(curCode>96 && curCode<123) /* [a-z] */ && !(curCode>47 && curCode<58) /* [0-9] */ )
				{
					boardLetter.letterContainer.letterBackground.visible = false;
					boardLetter.letterContainer.letter.visible = true;
					scoreLetter = false;
				}
				_wordArea.addChild(boardLetter);
				if(scoreLetter)
				{
					totalLetters++;
				}
				
				curWord.push({
					"char": formattedQuestion.charAt(i),
					"mc": boardLetter,
					"score":scoreLetter
				});
			}
			_scorePerLetter = 100/totalLetters;
			_clueBubble.setText(curClue, BUBBLE_BOTTOM_Y, _wordArea.localToGlobal(new Point(0, numRows * LETTER_HEIGHT + 25)).y);
			
		}
		
		private function formatQuestion(question:String):String
		{
			var qString:String = '';
			
			// split the words onto new lines depending on their lengths
			if (question != null)
			{
				var words:Array = question.split(" ");
				var lString:String = "";
				var nextWordLength:Number = 0;
				// loops through each word
				for(var i:Number = 0; i < words.length; i++)
				{
					lString += words[i];
					// check to see if the current line (lString) is longer than the max line value.
					if(lString.length > QUESTION_MAX_CHARS_PER_LINE)
					{
						// ...it is greater, so let's loop through each character...
						for(var s:Number = 0; s < lString.length; s++)
						{
							qString += lString.charAt(s);
							// use modulus here so that it will potentially add a - and \n multiple times per word
							if((s+1)%(QUESTION_MAX_CHARS_PER_LINE-1) == 0)
							{
								if(s != (lString.length - 2))
								{
									// add the -\n if we aren't two chars from the end (otherwise, just let the word fill the line)
									qString += "-\n";
								}
							}
						}
						// continue adding spaces if we aren't on the last word
						// and set the line string to blank to reset the line
						if((i+1) != words.length)
						{
							qString += " ";
						}
						lString = "";
					}
					// if the word is not longer than the line
					else
					{
						// if we aren't on the last word, keep track of the next word'd length
						nextWordLength = 0
						if((i+1) != words.length)
						{
							nextWordLength = words[i+1].length;
						}
						// if the next word will be greater than the max characters allowed per line,
						// add a \n and set the line string to a blank string to start the line
						if((lString.length + nextWordLength + 1) > QUESTION_MAX_CHARS_PER_LINE)
						{
							qString += words[i] + "\n";
							lString = "";
						}
						// otherwise, add a space to the line
						else
						{
							qString += words[i];
							if((i+1) != words.length)
							{
								qString += " ";
								lString += " ";
							}
						}
					}
				}
			}
			
			// trim off any trailing new lines:
			if(qString.charAt(qString.length - 1) == "\n")
			{
				qString = qString.substr(0, qString.length - 1);
			}
			// trim off any trailing dashes:
			if(qString.charAt(qString.length - 1) == "-")
			{
				qString = qString.substr(0, qString.length - 1);
			}

			return qString;
		}
		
		private function letterGuessed(letter:String):void
		{
			_animationManager.stopReadingCardFast();
			
			letter = letter.toLowerCase();
			if((_keyboard["key_"+letter] != null) && (alreadyGuessed(letter) == false))
			{
				lettersGuessed.push(letter);
				if(letterGuessCorrect(letter))
				{
					showLetter(letter);
					_host.action(GameShowHost.ACTION_NOD_APPROVINGLY);
				}
				else
				{
					attemptsRemaining--;
					if(attemptsRemaining < 1)
					{
						this.dispatchEvent(new HangmanEvent(HangmanEvent.QUESTION_INCORRECT, true));
						var questionScore:Number = 0;
						if(_partialScoring)
						{
							for each(var letterGuessed:String in lettersGuessed)
							{
								for(var i:int = 0; i < curWord.length; i++)
								{
									if(curWord[i].char.toLowerCase() == letterGuessed.toLowerCase())
									{
										questionScore += _scorePerLetter;
										continue;
									}
								}
							}
							questionScore = Math.round(questionScore);
						}
						scoring.submitQuestionForScoring(String(qSetCurQuestion.id), lettersGuessed.join());
						endQuestion(false);
						return; //prevent the usual screen reader updating
					}
					else
					{
						_anvil.lower();
						if(attemptsRemaining < 3)
						{
							_host.action(GameShowHost.ACTION_SWEAT);
						}
						if(attemptsRemaining < 2)
						{
							_host.action(GameShowHost.ACTION_LOOK_UP);
						}
					}
				}
				_keyboard["key_"+letter].alpha = .2
			}
			if(isWordComplete())
			{
				this.dispatchEvent(new HangmanEvent(HangmanEvent.QUESTION_CORRECT, true));
				scoring.submitQuestionForScoring(String(qSetCurQuestion.id), lettersGuessed.join());
				endQuestion(true);
			}
			else
			{
				updateReaderTarget();
			}
		}
		
		private function letterGuessCorrect(letter:String):Boolean
		{
			for (var i:int = 0; i < curWord.length; i++)
			{
				if (curWord[i].char.toLowerCase() == letter.toLowerCase())
				{
					return true;
				}
			}
			return false;
		}
		
		private function isWordComplete():Boolean
		{
			var isComplete:Boolean = true;
			for(var i:Number = 0; i < curWord.length; i++)
			{
				if(curWord[i].mc.letterContainer.letter.visible == false && curWord[i].mc.letterContainer.letterBackground.visible == true)
				{
					isComplete = false;
				}
			}
			return isComplete;
		}
		
		private function alreadyGuessed(letter:String):Boolean
		{
			for(var i:Number = 0; i < lettersGuessed.length; i++)
			{
				if(letter == lettersGuessed[i])
				{
					return true;
				}
			}
			
			return false;
		}
		
		private function showLetter(letter:String):Boolean
		{
			var found:Boolean = false;
			for(var i:Number = 0; i < curWord.length; i++)
			{
				if(curWord[i]["char"].toLowerCase() == letter.toLowerCase())
				{
					curWord[i].mc.letterContainer.letter.visible = true;
					found = true;
				}
			}
			return found;
		}
		
		private function endQuestion(correct:Boolean):void //true means screen reader can speak answer
		{
			disableKeyBoard();
			resetKeyboard();
			
			_keyboard.visible = false;
			attemptsRemaining = attemptsPerQuestion;
			if((curQuestion) >= total_questions)
			{
				showFinalScreen(correct);
			}
			else
			{
				_nextButton.visible = true;
				_nextButton.addEventListener(MouseEvent.MOUSE_UP, nextButtonHandler, false, 0, true);
				stage.addEventListener(KeyboardEvent.KEY_UP, nextButtonHandler, false, 0, true);
				if(Accessibility.active)
				{
					if(correct)
					{
						_nextButton.accessibilityProperties.name = "Word was: " + _currentQuestion + ". ";
					}
					_nextButton.accessibilityProperties.name += "Press any key to continue.";
					hackRefocus(_nextButton);
				}
			}
		}
		
		private function nextButtonHandler(e:Event):void
		{
			if(e is KeyboardEvent)
			{
				if(KeyboardEvent(e).keyCode != Keyboard.ENTER && KeyboardEvent(e).keyCode != Keyboard.SPACE)
				{
					return;
				}
			}
			
			_nextButton.removeEventListener(MouseEvent.MOUSE_UP, nextButtonHandler);
			stage.removeEventListener(KeyboardEvent.KEY_UP, nextButtonHandler);
			nextQuestion();
		}
		
		private function disableKeyBoard():void
		{
			inputEnabled = false;
		}
		
		public function resetKeyboard():void
		{
			for each(var key:MovieClip in _keys)
			{
				key.used.visible = false;
				key.alpha = 1;
			}
		}
		
		public function enableKeyboard():void
		{
			inputEnabled = true;
		}
		
		private function initKeyboard():void
		{
			_keys = new Vector.<MovieClip>;
			// set up numbers 0-10
			for(var i:Number = 0; i < 10; i++)
			{
				initKeyboardKey(String(i));
			}
			// set up a-z
			for(i = 97; i < 123; i++)
			{
				initKeyboardKey(String.fromCharCode(i));
			}
			
			for each(var key:MovieClip in _keys)
			{
				key.addEventListener(MouseEvent.MOUSE_DOWN, keyPressed, false, 0, true);
				key.addEventListener(MouseEvent.MOUSE_UP, keyPressed, false, 0, true);
			}
			
			stage.addEventListener(KeyboardEvent.KEY_UP, keyClicked, false, 0, true);
			//stage.addEventListener(KeyboardEvent.KEY_DOWN, keyClicked, false, 0, true);
			
			disableKeyBoard();
		}
		
		private function initKeyboardKey(char:String):void
		{
			var key:MovieClip = _keyboard["key_"+char]; // store reference to movieclip for each key
			key.used.visible = false;
			key.buttonMode = true;
			key["key"] = char;
			key.addEventListener(MouseEvent.MOUSE_DOWN, keyPressed, false, 0, true);
			key.addEventListener(MouseEvent.MOUSE_UP, keyPressed, false, 0, true);
			key.addEventListener(MouseEvent.MOUSE_OVER, keyHover, false, 0, true);
			key.addEventListener(MouseEvent.MOUSE_OUT, keyHover, false, 0, true);
			_keys.push(key)
		}
		
		private function keyHover(e:MouseEvent):void
		{
			if (e.type == MouseEvent.MOUSE_OVER)
			{
				e.target.parent.used.visible = true;
			}
			else if (e.type == MouseEvent.MOUSE_OUT)
			{
				e.target.parent.used.visible = false;
			}
		}
		
		private function keyPressed(e:MouseEvent):void
		{
			if(inputEnabled)
			{
				if (e.type == MouseEvent.MOUSE_DOWN)
				{
					e.target.alpha = .60;
				}
				else if (e.type == MouseEvent.MOUSE_UP)
				{
					letterGuessed(e.target.parent.key);
				}
			}
		}
		
		private function keyClicked(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.SPACE)
			{
				_animationManager.stopReadingCardFast();
			}
			else if(inputEnabled)
			{
				// make sure the key pressed is one of the letter keys or number keys
				var letter:String = String.fromCharCode(e.charCode);
				var pattern:RegExp = /^[a-zA-Z0-9]+$/;
				if(letter.match(pattern))
				{
					if(e.type == KeyboardEvent.KEY_UP)
					{
						letterGuessed(letter);
					}
					else if(e.type == KeyboardEvent.KEY_DOWN)
					{
						if(_keyboard["key_"+letter] != null)
						{
							_keyboard["key_"+letter].bounds.visible = true;
						}
					}
				}
			}
		}
		
		public function get clueBubble():HangmanFullTextSpeechBubble
		{
			return _clueBubble;
		}
		
		private function showFinalScreen(correct:Boolean):void
		{
			curQuestion++;
			_pane.finished.visible = true;
			_pane.finished.buttonMode = true;
			_pane.finished.addEventListener(MouseEvent.MOUSE_UP, endGame, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_UP, endGame, false, 0, true);
			if(Accessibility.active)
			{
				_pane.finished.accessibilityProperties = new AccessibilityProperties();
				_pane.finished.tabIndex = 2;
				_pane.finished.focusRect = false;
				if(correct)
				{
					_pane.finished.accessibilityProperties.name = "Word was: " + _currentQuestion + ". ";
				}
				_pane.finished.accessibilityProperties.name += "Game completed. Press any key to finish.";
				hackRefocus(_pane.finished);
			}
		}
		
		private function endGame(e:Event):void
		{
			if(e is KeyboardEvent)
			{
				if(KeyboardEvent(e).keyCode != Keyboard.ENTER && KeyboardEvent(e).keyCode != Keyboard.SPACE)
				{
					return;
				}
			}
			stage.removeEventListener(KeyboardEvent.KEY_UP, endGame);
			_pane.finished.removeEventListener(MouseEvent.MOUSE_UP, endGame);
			end();
		}
		private function updateReaderTarget():void
		{
			if(Accessibility.active)
			{
				_readerTarget.accessibilityProperties.name = "Word " + _wordNum.text + " of " + _remainingNum.text + ". ";
				_readerTarget.accessibilityProperties.name += "Letters used: ";
				for each(var letter:String in lettersGuessed)
				{
					_readerTarget.accessibilityProperties.name += letter + ", ";
				}
				
				if(lettersGuessed.length == 0)
				{
					_readerTarget.accessibilityProperties.name += "none. ";
				}
				if(curWord.length > 0)
				{
					_readerTarget.accessibilityProperties.name += "Word so far: ";
					var len:uint = curWord.length;
					for(var a:int = 0; a < len; a++)
					{
						if(curWord[a].mc.letterContainer.letter.visible)
						{
							_readerTarget.accessibilityProperties.name += curWord[a]["char"] + ", ";
						}
						else
						{
							_readerTarget.accessibilityProperties.name += "blank, ";
						}
					}
				}
				_readerTarget.accessibilityProperties.name += "Attempts remaining: " + attemptsRemaining;
				hackRefocus(_readerTarget);
			}
		}
		
		private function hackRefocus(target:MovieClip):void
		{
			Accessibility.updateProperties();
			var hack:Timer = new Timer(250,1);
			hack.addEventListener(TimerEvent.TIMER_COMPLETE, refocus, false, 0, true);
			hack.start();
			function refocus(e:TimerEvent):void
			{
				hack.removeEventListener(TimerEvent.TIMER_COMPLETE, refocus);
				stage.focus = target;
			}
		}
	}
}