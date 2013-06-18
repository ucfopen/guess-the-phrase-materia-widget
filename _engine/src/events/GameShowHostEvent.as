package events
{
	import flash.events.Event;
	public class GameShowHostEvent extends Event
	{
		//private var key:String;
		public var data:Object;
		public function GameShowHostEvent(type:String, /*key:String=null, */bubbles:Boolean=false, cancelable:Boolean=false)
		{
			//this.key = key;
			super(type, bubbles, cancelable);
		}
		/*public override function clone():Event
		{
		return new HangmanSpeechBubbleEvent(type, data, bubbles, cancelable);
		} */
		public override function toString():String
		{
			return formatToString("GameShowHostEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}