package
{
	import events.HangmanEvent;
	import events.HangmanSpeechBubbleEvent;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class HangmanAnimationManager
	{
		private var _screen:Engine;
		private var _host:GameShowHost;
		private var _anvil:HangmanAnvil;
		private var _speechBubble:HangmanFullTextSpeechBubble;
		private var _keyboard:MovieClip;
		private var _putCardAwayTimer:Timer;
		private var _fallTimer:Timer;
		private var _waitTimer:Timer;
		private var _pullingCard:Boolean = false;
		
		public function set screen(screen:Engine):void
		{
			_screen = screen;
			_screen.addEventListener(HangmanEvent.NEW_CLUE, newClue, false, 0, true);
			_screen.addEventListener(HangmanEvent.QUESTION_CORRECT, questionAnswered, false, 0, true);
			_screen.addEventListener(HangmanEvent.QUESTION_INCORRECT, questionAnswered, false, 0, true);
			_screen.addEventListener(MouseEvent.MOUSE_MOVE, userActive, false, 0, true);
			_screen.addEventListener(KeyboardEvent.KEY_DOWN, userActive, false, 0, true);
		}
		
		private function test(e:KeyboardEvent):void
		{
			stopReadingCardFast();
		}
		
		public function set host(host:GameShowHost):void
		{
			_host = host;
		}
		
		public function set anvil(anvil:HangmanAnvil):void
		{
			_anvil = anvil;
		}
		
		public function set speechBubble(speechBubble:HangmanFullTextSpeechBubble):void
		{
			if(_speechBubble)
			{
				_speechBubble.removeEventListener(HangmanSpeechBubbleEvent.CLUE_START, speechBubbleHandler, false);
				_speechBubble.removeEventListener(HangmanSpeechBubbleEvent.CLUE_DONE, speechBubbleHandler, false);
				_speechBubble.removeEventListener(HangmanSpeechBubbleEvent.SKIP_PRESSED, speechBubbleHandler, false);
			}
			
			_speechBubble = speechBubble;
			
			_speechBubble.addEventListener(HangmanSpeechBubbleEvent.CLUE_START, speechBubbleHandler, false, 0, true);
			_speechBubble.addEventListener(HangmanSpeechBubbleEvent.CLUE_DONE, speechBubbleHandler, false, 0, true);
			_speechBubble.addEventListener(HangmanSpeechBubbleEvent.SKIP_PRESSED, speechBubbleHandler, false, 0, true);
		}
		
		public function set keyboard(keyboard:MovieClip):void
		{
			_keyboard = keyboard;
			_screen.addEventListener(KeyboardEvent.KEY_DOWN, keyBoardPressed, false, 0, true);
			_screen.addEventListener(MouseEvent.MOUSE_DOWN, keyBoardPressed, false, 0, true);
		}
		
		private function keyBoardPressed(e:Event):void
		{
			stopReadingCardFast();
		}
		
		private function newClue(e:HangmanEvent):void
		{
			hostPutAwayCardCancel();
			_host.action(GameShowHost.ACTION_IDLE);
			_anvil.reset();
			
			pullCard();
		}
		
		private function pullCard(e:HangmanSpeechBubbleEvent=null):void
		{
			_pullingCard = true;
			_host.action(GameShowHost.ACTION_PULL_CARD);
			_host.addEventListener(GameShowHost.END_ACTION_PULL_CARD, readCard, false, 0, true);
		}
		
		private function readCard(e:Event = null):void
		{
			_pullingCard = false;
			_host.removeEventListener(GameShowHost.END_ACTION_PULL_CARD, readCard);
			_speechBubble.readCard();
			
			_screen.enableKeyboard();
		}
		
		private function speechBubbleHandler(e:HangmanSpeechBubbleEvent):void
		{
			if(e.type == HangmanSpeechBubbleEvent.CLUE_START)
			{
				_host.action(GameShowHost.ACTION_READ_CARD);
			}
			else if(e.type == HangmanSpeechBubbleEvent.SKIP_PRESSED)
			{
				showStopReadingFastAnimation();
			}
			else if(e.type == HangmanSpeechBubbleEvent.CLUE_DONE)
			{
				_host.endAction(GameShowHost.ACTION_READ_CARD);
				_host.action(GameShowHost.ACTION_HOLD_CARD);
				
				if(!_putCardAwayTimer)
				{
					_putCardAwayTimer = new Timer(100, 1);
					_putCardAwayTimer.addEventListener(TimerEvent.TIMER_COMPLETE, putCardAway, false, 0, true);
				}
				_putCardAwayTimer.delay = Math.floor(Math.random() * (1 + 1000 - 4000)) + 4000;
				_putCardAwayTimer.reset();
				_putCardAwayTimer.start();
			}
		}
		
		public function stopReadingCardFast():void
		{
			if(_pullingCard)
			{
				readCard();	
			}
			
			if(!_speechBubble.finishedReading)
			{
				showStopReadingFastAnimation();
			}
			
			
			
			_speechBubble.finishReadingCard();
		}
		
		private function showStopReadingFastAnimation():void
		{
			_host.endAction(GameShowHost.ACTION_READ_CARD);
			_host.action(GameShowHost.ACTION_PUT_AWAY_CARD_FAST);
		}
		
		private function questionAnswered(e:HangmanEvent):void
		{
			if(e.type == HangmanEvent.QUESTION_CORRECT)
			{
				hostPutAwayCardCancel();
				_host.action(GameShowHost.ACTION_PANDER);
				putAwayAnvil();
			}
			else if(e.type == HangmanEvent.QUESTION_INCORRECT)
			{
				_anvil.snap();
				
				if(!_fallTimer)
				{
					_fallTimer = new Timer(10, 1);
					_fallTimer.addEventListener(TimerEvent.TIMER_COMPLETE, hostFallNow);
				}
				_fallTimer.reset();
				_fallTimer.start();
			}
		}
		
		private function userActive(e:Event = null):void
		{
			if(_waitTimer != null)
			{
				_waitTimer.removeEventListener(TimerEvent.TIMER, hostBored);
			}
			_waitTimer = new Timer(Math.floor(Math.random() * (1 + 120000 - 80000)) + 80000);
			_waitTimer.addEventListener(TimerEvent.TIMER, hostBored, false, 0, true);
			_waitTimer.start();
		}
		
		/* Host Specific Animations/Handlers */
		private function hostFallNow(e:TimerEvent):void
		{
			_fallTimer.reset();
			_host.action(GameShowHost.ACTION_FALL);
		}
		
		private function putAwayAnvil(e:TimerEvent=null):void
		{
			_host.removeEventListener(GameShowHost.ACTION_PANDER, putAwayAnvil);
			_anvil.retractAnvil();
		}
		
		private function putCardAway(e:TimerEvent):void
		{
			_host.action(GameShowHost.ACTION_PUT_AWAY_CARD);
		}
		
		private function hostPutAwayCardCancel():void
		{
			if(_putCardAwayTimer)
			{
				_putCardAwayTimer.reset();
			}
		}
		
		private function hostBored(e:Event=null):void
		{
			if(_waitTimer != null)
			{
				_waitTimer.stop();
				_waitTimer.removeEventListener(TimerEvent.TIMER, hostBored);
			}
			if(_host.animating == false)
			{
				_host.action(GameShowHost.ACTION_SLOUCH);
				_screen.addEventListener(MouseEvent.MOUSE_DOWN, hostWakeUp, false, 0, true);
				_screen.addEventListener(KeyboardEvent.KEY_DOWN, hostWakeUp, false, 0, true);
			}
		}
		
		private function hostWakeUp(e:Event):void
		{
			_screen.removeEventListener(MouseEvent.MOUSE_DOWN, hostWakeUp);
			_screen.removeEventListener(KeyboardEvent.KEY_DOWN, hostWakeUp);
			_host.action(GameShowHost.ACTION_WAKE_UP);
			_waitTimer.start();
		}
	}
}