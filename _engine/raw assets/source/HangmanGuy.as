package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	public class HangmanGuy extends MovieClip
	{
		public var myPen;
		public static const ANIMATION_STAGE_COMPLETE:String = "animationStageComplete";
		//const ANIMATION_FINAL_COMPLETE:String= "animationFinalComplete"
		public var mc1:MovieClip;
		public var mc2:MovieClip;
		private var previousX:Number, previousY:Number;
		private var switchPic:Boolean;
		private var curStep:Number = 0;
		public function HangmanGuy():void
		{
//			//trace("making hangman guy");
			addEventListener(Event.ENTER_FRAME, continueLine, false, 0, true);
			// make 2 movie clips, and switch between them to get the animation effect
			mc1 = new MovieClip();
			addChild(mc1);
			//setChildIndex(mc,0);
			mc1.graphics.lineStyle(2,0,0.99);
			mc1.graphics.moveTo(myPen.x, myPen.y);
			mc2 = new MovieClip();
			addChild(mc2);
			//setChildIndex(mc2,0);
			mc2.graphics.lineStyle(2,0,0.99);
			mc2.graphics.moveTo(myPen.x, myPen.y);
			previousX = myPen.x;
			previousY = myPen.y;
			switchPic = true;
		}
		public function reset():void
		{
			curStep = 0;
			gotoAndStop(1);
			if(myPen != null)
			{
				if(mc1 != null)
				{
					mc1.graphics.clear();
					mc1.graphics.lineStyle(2,0,0.99);
					mc1.graphics.moveTo(myPen.x, myPen.y);
				}
				if(mc2 != null)
				{
					mc2.graphics.clear();
					mc2.graphics.lineStyle(2,0,0.99);
					mc2.graphics.moveTo(myPen.x, myPen.y);
				}
			}
		}
		public function nextStep():void
		{
			myPen.visible = true;
			curStep++;
			play();
		}
		//protected var testCount:int = 0;
		protected function continueLine(e:Event):void
		{
			//testCount++;
			//if(testCount % 4 != 0)
			//{
			//	return;
			//}
			// switch the pic to get the animation effect
//			//trace("continueLine");
			if(myPen == null)
			{
//				//trace("myPen == null");
				return;
			}
			if(switchPic){
				mc1.visible = true;
				mc2.visiblze = false;
				if(Math.floor(Math.random()*3) == 1) switchPic = false;
			}
			else{
				mc1.visible = false;
				mc2.visible = true;
				if(Math.floor(Math.random()*3) == 1) switchPic = true;
			}
			// draw to both mc's
			//mc1.graphics.clear();
			//mc2.graphics.clear();
			if(! ( previousX == myPen.x && previousY == myPen.y ) )
			{
				if(distance(myPen.x, previousX, myPen.y, previousY) < 20){ // if it is far enough away, consider it a new line
					mc1.graphics.lineTo(myPen.x+r(),myPen.y+r());
					mc2.graphics.lineTo(myPen.x+r(), myPen.y+r());
				}
				else{ // continue drawing the same line
					mc1.graphics.moveTo(myPen.x+r(), myPen.y+r());
					mc2.graphics.moveTo(myPen.x+r(), myPen.y+r());
				}
			}
			previousX = myPen.x;
			previousY = myPen.y;
		}
		protected function r():Number{
			const randOffset:Number = 1.7;
			return Math.random()*randOffset;
		}
		protected function distance(a1:Number,a2:Number,b1:Number,b2:Number):Number{
			var a:Number = Math.abs(a1-a2);
			var b:Number = Math.abs(b1-b2);
			return Math.abs( Math.sqrt(a*a + b*b));
		}
	}
}