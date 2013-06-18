package nm.gameServ.engines.enigma.events
{
	import flash.events.Event;
	/**
	* ...
	* @author DefaultUser (Tools -> Custom Arguments...)
	*/
	public class HangmanKeyboardEvent extends Event
	{
		public static const KEY_PRESSED:String = "keyPressed";
		public static const KEY_PRESSED:String = "keyClicked";
		public var data:Object;
		public function HangmanKeyboardEvent(type:String, key:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.key = key;
			super(type, bubbles, cancelable);
		}
		public override function clone():Event
		{
			return new HangmanKeyboardEvent(type, data, bubbles, cancelable);
		}
		public override function toString():String
		{
			return formatToString("HangmanKeyboardEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}