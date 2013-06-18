package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class GameShowHost extends MovieClip
	{
		public static const ACTION_PANDER:String = "pander";
		public static const END_ACTION_PANDER:String = "done_pander";
		public static const ACTION_PULL_CARD:String = "pullCard";
		public static const END_ACTION_PULL_CARD:String = "done_pullCard";
		public static const ACTION_GRAB_CARD:String = "grabCardQuickly";
		public static const END_ACTION_GRAB_CARD:String = "done_grabCardQuickly";
		public static const ACTION_UPSET:String = "upset";
		public static const END_ACTION_UPSET:String = "done_upset";
		public static const ACTION_PUT_AWAY_CARD:String = "putCardAway";
		public static const END_ACTION_PUT_AWAY_CARD:String = "done_putCardAway";
		public static const ACTION_PUT_AWAY_CARD_FAST:String = "putCardAwayFast";
		public static const END_ACTION_PUT_AWAY_CARD_FAST:String = "done_putCardAwayFast";
		public static const ACTION_READ_CARD:String = "speak";
		public static const END_ACTION_READ_CARD:String = "done_speak";
		public static const ACTION_SLOUCH:String = "slouchBored";
		public static const END_ACTION_SLOUCH:String = "done_slouchBored";
		public static const ACTION_NORMAL_EYES:String = "smugEyes";
		public static const END_ACTION_NORMAL_EYES:String = "done_smugEyes";
		public static const ACTION_SIT_UP:String = "sitUp";
		public static const END_ACTION_SIT_UP:String = "done_sitUp";
		public static const ACTION_FALL_ASLEEP:String = "fallAsleep";
		public static const END_ACTION_FALL_ASLEEP:String = "done_fallAsleep";
		public static const ACTION_WAKE_UP:String = "wakeUp";
		public static const END_ACTION_WAKE_UP:String = "done_wakeUp";
		public static const ACTION_IDLE:String = "idle";
		public static const END_ACTION_IDLE:String = "done_idle";
		public static const ACTION_SWEAT:String = "sweat";
		public static const END_ACTION_SWEAT:String = "done_sweat";
		public static const ACTION_HOLD_CARD:String = "holdingCard";
		public static const ACTION_FACE_STILL:String = "still";
		public static const END_ACTION_FACE_STILL:String = "done_still";
		public static const ACTION_FALL:String = "fall";
		public static const END_ACTION_FALL:String = "done_fall";
		public static const ACTION_LOOK_UP:String = "lookUp";
		public static const END_ACTION_LOOK_UP:String = "done_lookUp";
		public static const ACTION_CLIMB:String = "climb";
		public static const END_ACTION_CLIMB:String = "done_climb";
		public static const ACTION_FIX_GLASSES:String = "fixGlasses";
		public static const END_ACTION_FIX_GLASSES:String = "done_fixGlasses";
		public static const ACTION_NOD_APPROVINGLY:String = "correctNod";
		public static const END_ACTION_NOD_APPROVINGLY:String = "done_correctNod";
		
		private var _hostAndPodium:MovieClip;
		private var _host:MovieClip;
		private var _head:MovieClip;
		private var _parent:Sprite;
		private var _getUp:Timer;
		private var _fixGlassesTimer:Timer;
		private var _eyeChangeTimer:Timer;
		private var _randEyes:Boolean;
		private var _lookUpTimer:Timer;
		private var _eyeTimer:Timer;
		private var _isGettingUp:Boolean;
		private var _isAnimating:Boolean;
		private var _isReading:Boolean;
		
		function GameShowHost(parent:Sprite)
		{
			_parent = parent;
			_hostAndPodium = new HangmanHost();
			_host = _hostAndPodium.host;
			_head = _host.head;
			_isGettingUp = false;
			_head.head.sweat.visible = false;
			this.addChild(_hostAndPodium);
			_head.head.bump.visible = false;
			_head.head.blackEye.visible = false;
			_head.head.moustache.alpha = 0;
			_head.head.jaw.beard.alpha = 0;
			_host.addEventListener(END_ACTION_FALL, getBackUp, false, 0, true);
			_host.addEventListener(END_ACTION_CLIMB, fixGlasses, false, 0, true);
			_host.addEventListener(END_ACTION_FIX_GLASSES, hostIdle, false, 0, true);
		}
		
		public function action(action:String):void
		{
			switch(action)
			{
				case ACTION_PANDER:
					_host.gotoAndPlay("pander");
					_head.head.gotoAndStop("idle");
					_head.gotoAndStop("still");
					_isAnimating = true;
					if(_lookUpTimer != null)
					{
						_lookUpTimer.removeEventListener(TimerEvent.TIMER, changeLookUp);
						_lookUpTimer.removeEventListener(TimerEvent.TIMER, lookBackDown);
					}
					endAction(ACTION_SWEAT);
					this.addEventListener(GameShowHost.END_ACTION_PANDER, donePandering, false, 0, true);
					break;
				case ACTION_PULL_CARD:
					_host.gotoAndPlay("pullCard");
					break;
				case ACTION_GRAB_CARD:
					_host.gotoAndPlay("grabCardQuickly");
					break;
				case ACTION_PUT_AWAY_CARD:
					_host.gotoAndPlay("putCardAway");
					break;
				case ACTION_PUT_AWAY_CARD_FAST:
					_host.gotoAndPlay("putCardAwayFast");
					break;
				case ACTION_READ_CARD:
					clearSmugEyeChange();
					_head.gotoAndPlay("speak");
					_head.head.gotoAndPlay("reading");
					break;
				case ACTION_HOLD_CARD:
					_host.gotoAndStop("holdingCard");
					break;
				case ACTION_UPSET:
					_host.gotoAndPlay("upset");
					break;
				case ACTION_SLOUCH:
					_head.gotoAndStop("still");
					_host.gotoAndPlay("slouchBored");
					changeSmugEyes();
					this.addEventListener(GameShowHost.END_ACTION_SLOUCH, endSlouch, false, 0, true);
					break;
				case ACTION_SIT_UP:
					_host.gotoAndPlay("sitUp");
					break;
				case ACTION_FALL_ASLEEP:
					_host.gotoAndPlay("fallAsleep");
					break;
				case ACTION_WAKE_UP:
					clearSmugEyeChange();
					_host.gotoAndPlay("wakeUp");
					_head.head.gotoAndStop("idle");
					clearSmugEyeChange();
					_head.head.gotoAndPlay("wokenUp");
					this.addEventListener(GameShowHost.END_ACTION_WAKE_UP, wakeUp, false, 0, true);
					break;
				case ACTION_IDLE:
					endAnimations();
					_host.gotoAndStop("idle");
					_head.gotoAndStop("still");
					_head.head.gotoAndStop("idle");
					_head.head.sweat.visible = false;
					_hostAndPodium.gotoAndStop("idle");
					break;
				case ACTION_SWEAT:
					_head.head.sweat.visible = true;
					_host.gotoAndPlay("breatheHeavilyLoop");
					_head.head.sweat.gotoAndPlay(1);
					break;
				case ACTION_FALL:
					_hostAndPodium.gotoAndPlay("fall");
					_host.gotoAndPlay("fall");
					_head.head.gotoAndStop("surprised");
					_lookUpTimer.stop();
					break;
				case ACTION_CLIMB:
					_head.head.sweat.visible = false;
					_hostAndPodium.gotoAndPlay("climb");
					_host.gotoAndPlay("idle");
					_host.gotoAndPlay("climb");
					_isGettingUp = true;
					break;
				case ACTION_LOOK_UP:
					changeLookUp();
					break;
				case ACTION_FIX_GLASSES:
					_host.gotoAndPlay("fixGlasses");
					break;
				case ACTION_NOD_APPROVINGLY:
					_head.gotoAndPlay("correctNod");
					break;
				default:
					_host.gotoAndPlay("idle");
					break;
			}
		}
		
		public function endAction(action:String):void
		{
			switch(action)
			{
				case ACTION_SWEAT:
					_head.head.sweat.visible = false;
					break;
				case ACTION_READ_CARD:
					_head.gotoAndStop("idle");
					_head.head.gotoAndStop("idle");
				default:
					_host.gotoAndStop("idle");
					break;
			}
		}
		
		public function get animating():Boolean
		{
			return _isAnimating;
		}
		
		public function get reading():Boolean
		{
			return _isReading;
		}
		
		public function get gettingUp():Boolean
		{
			return _isGettingUp;
		}
		
		private function endAnimations():void
		{
			if(_lookUpTimer != null)
			{
				_lookUpTimer.removeEventListener(TimerEvent.TIMER, changeLookUp);
				_lookUpTimer.removeEventListener(TimerEvent.TIMER, lookBackDown);
				_lookUpTimer.removeEventListener(TimerEvent.TIMER, lookBackDown);
			}
			if(_getUp != null)
			{
				_getUp.reset();
			}
			if(_fixGlassesTimer != null)
			{
				_fixGlassesTimer.reset();
			}
			clearSmugEyeChange()
		}
		
		private function donePandering(e:Event=null):void
		{
			this.removeEventListener(GameShowHost.END_ACTION_PANDER, donePandering);
			_isAnimating = false;
			if(_lookUpTimer != null)
			{
				_lookUpTimer.removeEventListener(TimerEvent.TIMER, lookBackDown);
			}
		}
		
		private function changeSmugEyes(e:TimerEvent=null):void
		{
			_randEyes = Boolean(Math.round(Math.random()));
			if(_randEyes)
			{
				_head.head.gotoAndStop("smugEyesAlt");
			}
			else
			{
				_head.head.gotoAndStop("smugEyes");
			}
			if(_eyeChangeTimer != null)
			{
				_eyeChangeTimer.removeEventListener(TimerEvent.TIMER, changeSmugEyes);
			}
			_eyeChangeTimer = new Timer(Math.floor(Math.random()*(1+7000-4000))+4000);
			_eyeChangeTimer.addEventListener(TimerEvent.TIMER, closeSmugEyes);
			_eyeChangeTimer.start();
		}
		
		private function closeSmugEyes(e:TimerEvent=null):void
		{
			_head.head.gotoAndStop("closedEyes");
			_eyeChangeTimer.removeEventListener(TimerEvent.TIMER, closeSmugEyes);
			_eyeChangeTimer = new Timer(Math.floor(Math.random()*(1+1000-500))+500);
			_eyeChangeTimer.addEventListener(TimerEvent.TIMER, changeSmugEyes);
			_eyeChangeTimer.start();
		}
		
		private function clearSmugEyeChange():void
		{
			if(_eyeChangeTimer != null) {
				_eyeChangeTimer.stop();
				_eyeChangeTimer.removeEventListener(TimerEvent.TIMER, closeSmugEyes);
				_eyeChangeTimer.removeEventListener(TimerEvent.TIMER, changeSmugEyes);
			}
		}
		
		private function getBackUp(e:Event=null):void
		{
			_head.head.sweat.visible = false;
			_head.gotoAndStop("still");
			if(_head.head.bump.visible == false)
			{
				_head.head.bump.visible = true;
			}
			else if(_head.head.bump.visible)
			{
				_head.head.blackEye.visible = true;
			}
			if(!_getUp)
			{
				_getUp = new Timer(10, 1);
				_getUp.addEventListener(TimerEvent.TIMER_COMPLETE, getBackUpNow);
			}
			_getUp.delay = Math.floor(Math.random() * (1 + 2000 - 500)) + 500;
			_getUp.reset();
			_getUp.start();
		}
		
		private function getBackUpNow(e:Event=null):void
		{
			_getUp.reset();
			action(ACTION_CLIMB);
		}
		
		private function fixGlasses(e:Event=null):void
		{
			if(_isReading == false)
			{
				if(!_fixGlassesTimer)
				{
					_fixGlassesTimer = new Timer(10, 1);
					_fixGlassesTimer.addEventListener(TimerEvent.TIMER_COMPLETE, fixGlassesNow);
				}
				_fixGlassesTimer.delay = Math.floor(Math.random() * (1 + 1000 - 500)) + 1000;
				_fixGlassesTimer.reset();
				_fixGlassesTimer.start();
			}
			else
			{
				_head.gotoAndPlay("idle");
			}
		}
		
		private function fixGlassesNow(e:Event=null):void
		{
			_fixGlassesTimer.reset();
			action(ACTION_FIX_GLASSES);
			_isAnimating = false;
		}
		
		private function hostIdle(e:Event=null):void
		{
			_isGettingUp = false;
			action(ACTION_IDLE);
		}
		
		private function wakeUp(e:Event = null):void
		{
			_head.head.removeEventListener(GameShowHost.END_ACTION_WAKE_UP, wakeUp);
			_eyeTimer = new Timer(Math.floor(Math.random()*(1+1000-500))+500);
			_eyeTimer.addEventListener(TimerEvent.TIMER, wakeUpNow);
			_eyeTimer.start();
		}
		
		private function wakeUpNow(e:TimerEvent = null):void
		{
			_eyeTimer.removeEventListener(TimerEvent.TIMER, wakeUpNow);
			_head.head.gotoAndPlay("idle");
			_eyeTimer = new Timer(Math.floor(Math.random()*(1+500-500))+500);
			_eyeTimer.addEventListener(TimerEvent.TIMER, putAwayCard);
			_eyeTimer.start();
		}
		
		private function putAwayCard(e:TimerEvent):void
		{
			_eyeTimer.removeEventListener(TimerEvent.TIMER, putAwayCard);
			action(GameShowHost.ACTION_PUT_AWAY_CARD);
		}
		
		private function changeLookUp(e:Event=null):void
		{
			_isAnimating = true;
			_head.gotoAndPlay("lookUp");
			if(_lookUpTimer != null)
			{
				_lookUpTimer.removeEventListener(TimerEvent.TIMER, changeLookUp);
			}
			_lookUpTimer = new Timer(Math.floor(Math.random()*(1+7000-4000))+4000)
			_lookUpTimer.addEventListener(TimerEvent.TIMER, lookBackDown);
			_lookUpTimer.start();
		}
		
		private function lookBackDown(e:TimerEvent = null):void
		{
			_head.gotoAndPlay("lookDown");
			_head.head.gotoAndStop("wokenUp");
			if(_lookUpTimer != null)
			{
				_lookUpTimer.removeEventListener(TimerEvent.TIMER, lookBackDown);
			}
			_lookUpTimer = new Timer(Math.floor(Math.random()*(1+7000-4000))+4000)
			_lookUpTimer.addEventListener(TimerEvent.TIMER, changeLookUp);
			_lookUpTimer.start();
		}
		
		private function endSlouch(e:Event):void
		{
			this.removeEventListener(GameShowHost.END_ACTION_SLOUCH, endSlouch);
		}
	}
}