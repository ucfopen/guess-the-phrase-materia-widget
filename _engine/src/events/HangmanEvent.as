package events
{
	import flash.events.Event;
	public class HangmanEvent extends Event
	{
		public static const NEW_CLUE:String = "newClue";
		public static const REPEAT_CLUE:String = "repeatClue";
		public static const QUESTION_CORRECT:String = "questionCorrect";
		public static const QUESTION_INCORRECT:String = "questionIncorrect";
		public var data:Object;
		public function HangmanEvent(type:String, /*key:String=null, */bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		public override function toString():String
		{
			return formatToString("GameShowHostEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}