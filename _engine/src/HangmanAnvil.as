package
{
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweenTimeline;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import gs.TweenLite;
	import gs.easing.*;
	public class HangmanAnvil extends MovieClip
	{
		private var _anvil:Anvil;
		private var _parent:Engine;
		private var gTimeline:GTweenTimeline;
		private var anvil_rotation:int;
		private var anvil_rotation_time:int;
		private var _lowerCount:int;
		private var anvil_fall_time:int;
		private var anvil_initial_y:Number;
		private var anvil_initial_x:Number;
		private var anvil_container_initial_y:Number;
		private var anvil_and_rope_initial_y:Number;
		private var rope_initial_y:Number;
		private var anvil_shift_x:Number;
		private var stopSwinging:Boolean;
		private var ropeAndAnvilSwingTween:GTween;
		private var anvilFallTween:GTween;
		public var ropeRetractTween:GTween;
		public var lowerRopeAndAnvilTween:GTween
		public function HangmanAnvil(parent:Engine)
		{
			_parent = parent;
			_anvil = new Anvil();
			var dropShadow:DropShadowFilter = new DropShadowFilter();
			dropShadow.distance = 17;
			dropShadow.angle = 45;
			dropShadow.color = 0x000000;
			dropShadow.alpha = 1;
			dropShadow.blurX = 24;
			dropShadow.blurY = 24;
			dropShadow.strength = .28;
			dropShadow.quality = 2;
			dropShadow.inner = false;
			dropShadow.knockout = false;
			dropShadow.hideObject = false;
			_anvil.filters = new Array(dropShadow);
			anvil_rotation = 6;
			anvil_rotation_time = 3;
			anvil_fall_time = .5;
			gTimeline = new GTweenTimeline();
			_lowerCount = 0;
			stopSwinging = false;
			anvil_initial_y = _anvil.anvil.anvil.y
			anvil_initial_x = _anvil.anvil.anvil.x
			anvil_container_initial_y = _anvil.y
			rope_initial_y = _anvil.anvil.rope.y
			anvil_and_rope_initial_y = _anvil.anvil.y;
			_anvil.anvil.y -= 150;
		}
		public function initialize():void
		{
			if (!this.contains(_anvil))
			{
				addChild(_anvil);
			}
			stopSwinging = false;
			swing();
		}
		public function remove():void
		{
			if (ropeAndAnvilSwingTween != null)
			{
				ropeAndAnvilSwingTween.end();
			}
			if (this.contains(_anvil))
			{
				this.removeChild(_anvil);
			}
			this.stopSwinging = true;
		}
		public function swing(tween:GTween = null):void
		{
			adjustTime();
			_anvil.rotation = -anvil_rotation;
			if(ropeAndAnvilSwingTween == null)
			{
				ropeAndAnvilSwingTween = new GTween(_anvil, anvil_rotation_time, {rotation:anvil_rotation}, {ease:Sine.easeInOut})
				ropeAndAnvilSwingTween.reflect = true
				ropeAndAnvilSwingTween.repeatCount = 0
			}
			ropeAndAnvilSwingTween.duration = anvil_rotation_time
			ropeAndAnvilSwingTween.paused = false
		}
		private function adjustTime():void
		{
			if (Math.random() > .5)
			{
				anvil_rotation_time += Math.floor(Math.random()*(2)+1)
			}
			else
			{
				anvil_rotation_time -= Math.floor(Math.random()*(2)+1)
			}
			if (anvil_rotation_time > 6)
			{
				anvil_rotation_time = 6;
			}
			if (anvil_rotation_time < 3)
			{
				anvil_rotation_time = 3;
			}
		}
		public function snap():void
		{
			_anvil.anvil.gotoAndStop("separated");
			_anvil.anvil.anvil.gotoAndStop("falling");
			anvilFallTween.duration = .5
			anvilFallTween.proxy.y = anvil_initial_y+700
			ropeRetractTween = new GTween(_anvil.anvil.rope, 6, {y:rope_initial_y-200}, {ease:Sine.easeInOut})
			ropeRetractTween.delay = .5
			//ropeRetractTween.onComplete = resetAnvil;
		}
		public function retractAnvil():void
		{
			if(lowerRopeAndAnvilTween)
			{
				lowerRopeAndAnvilTween.duration = 4
				lowerRopeAndAnvilTween.proxy.y = anvil_and_rope_initial_y - 150
			}
		}
		public function reset():void
		{
			resetAnvil();
		}
		private  function resetAnvil(tween:GTween = null):void
		{
			_anvil.anvil.y = anvil_and_rope_initial_y - 150;
			_anvil.anvil.anvil.y = anvil_initial_y
			_anvil.anvil.anvil.x = anvil_initial_x
			_anvil.anvil.rope.y = rope_initial_y
			_anvil.anvil.gotoAndStop("normal");
			_anvil.anvil.anvil.gotoAndStop("normal");
			_anvil.anvil.anvil.rotation = 0
			_lowerCount = 0;
			if(ropeRetractTween)
			{
				ropeRetractTween.end();
			}
			remove();
		}
		public function lower():void
		{
			_lowerCount++;
			switch(_lowerCount)
			{
				case 1: // lower from off screen
					this.initialize();
					if(lowerRopeAndAnvilTween)
					{
						lowerRopeAndAnvilTween.duration = 1
						lowerRopeAndAnvilTween.proxy.y = anvil_and_rope_initial_y
					}
					else
					{
						lowerRopeAndAnvilTween = new GTween(_anvil.anvil, 1, {y:anvil_and_rope_initial_y}, {ease:Sine.easeOut})
					}
					anvilFallTween = new GTween(_anvil.anvil.anvil, .3, {y:anvil_initial_y}, {ease:customEase})
					_anvil.anvil.rope.gotoAndStop("normal");
					break;
				case 2: // first tear
					anvilFallTween.proxy.y = anvil_initial_y + 10
					_anvil.anvil.rope.gotoAndStop("torn");
					break;
				case 3: // second tear
					anvilFallTween.proxy.y = anvil_initial_y + 20
					_anvil.anvil.rope.gotoAndStop("moreTorn");
					break;
				default: // third tear +
					anvilFallTween.proxy.y = anvil_initial_y + 30
					_anvil.anvil.rope.gotoAndStop("evenMoreTorn");
					break;
			}
		}
		// made using the easing explorer found at http://www.madeinflex.com/img/entries/2007/05/customeasingexplorer.html
		private function customEase(t:Number, b:Number, c:Number, d:Number):Number
		{
			  var ts:Number=(t/=d)*t;
			  var tc:Number=ts*t;
			  return b+c*(-25.558441558441555*tc*ts + 84.38311688311688*ts*ts + -92.14285714285715*tc + 34.02597402597403*ts + 0.2922077922077922*t);
		}
	}
}