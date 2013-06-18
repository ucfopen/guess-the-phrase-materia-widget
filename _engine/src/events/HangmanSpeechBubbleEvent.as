package events
{
	import flash.events.Event;
	/**
	 * ...
	 * @author DefaultUser (Tools -> Custom Arguments...)
	 */
	public class HangmanSpeechBubbleEvent extends Event
	{
		public static const CLUE_START:String = "clueStart";
		public static const SKIP_PRESSED:String = "skipPressed";
		public static const CLUE_DONE:String = "clueDone";
		public static const POPPED_IN:String = "poppedIn";
		public static const REPEAT_CLUE:String = "repeatClue";
		private var key:String;
		public var data:Object;
		public function HangmanSpeechBubbleEvent(type:String, /*key:String=null, */bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.key = key;
			super(type, bubbles, cancelable);
		}
		public override function toString():String
		{
			return formatToString("HangmanSpeechBubbleEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}