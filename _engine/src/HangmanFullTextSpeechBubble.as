package
{
	import events.HangmanSpeechBubbleEvent;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import nm.ui.ScrollText;

	public class HangmanFullTextSpeechBubble extends Sprite
	{
		private static const DEFAULT_NUM_LINES:int = 3;
		private static const READ_CHAR_DELAY:int = 40;
		private static const TF_PADDING:int = 15;
		private static const BUBBLE_W:int = 468;
		private static const BUBBLE_R:int = 50;
		private static const POINTER_GLOBAL_Y:int = 320;
		
		private var font:Font;
		private var format:TextFormat;
		private var measureTF:TextField;
		private var scrollText:ScrollText;
		private var curCharIndex:int;
		private var pointer:SpeechBubblePointer;
		
		private var readTimer:Timer;
		
		private var clueText:String = '';
		private var bottomYLocation:Number;
		private var topMaxYLocation:Number;
		private var measuredTextFieldHeight:Number;
		private var measuredTextLineHeight:Number;
		private var maxTextLinesBeforeScroll:int;
		private var maxLinesReached:Boolean;
		private var isFinishedReading:Boolean;
		private var lastNumLinesDrawn:int = -1;
		
		public function HangmanFullTextSpeechBubble()
		{
			font = new Designers();
			format = new TextFormat(font.fontName, 19, 0x0);
			
			measureTF = new TextField();
			measureTF.embedFonts = true;
			measureTF.wordWrap = true;
			measureTF.multiline = true;
			measureTF.autoSize = TextFieldAutoSize.LEFT;
			measureTF.selectable = false;
			measureTF.border = true;
			measureTF.alpha = 0;
			measureTF.width = BUBBLE_W - TF_PADDING - TF_PADDING;
			measureTF.defaultTextFormat = format;
			
			scrollText = new ScrollText(BUBBLE_W - TF_PADDING - TF_PADDING, 100, 'hello', format);
			scrollText.move(TF_PADDING, TF_PADDING);
			scrollText.setStyle('showBorder', false);
			scrollText.setStyle('embedFonts', true);
			scrollText.redraw();
			//@HACK:
			scrollText.tf.border = false;
			scrollText.tf.background = false;
			scrollText.tf.antiAliasType = AntiAliasType.ADVANCED;
			scrollText.tf.selectable = false;
			scrollText.tf.type = TextFieldType.DYNAMIC;
			
			pointer = new SpeechBubblePointer();
			pointer.visible = false;
			
			addChild(measureTF);
			addChild(scrollText);
			addChild(pointer);
			
			readTimer = new Timer(READ_CHAR_DELAY);
			readTimer.addEventListener(TimerEvent.TIMER, handleReadTimerTick);
			
			addEventListener(MouseEvent.CLICK, handleClick, false, 0, true);
			
			filters = [new DropShadowFilter(17, 45, 0x0, 1, 24, 24, 0.28, 2)];
			
			if(stage)
			{
				drawBubbleAndText();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
			}
		}
		
		private function handleAddedToStage(event:Event):void
		{
			drawBubbleAndText();
		}
		
		public function resetBubble():void
		{
			scrollText.text = '';
			maxLinesReached = false;
			curCharIndex = 0;
			lastNumLinesDrawn = -1;
			
			drawBubbleAndText();
		}
		
		public function setText(s:String, bottomYLocation:int, topMaxYLocation:int):void
		{
			resetBubble();
			
			clueText = s;
			this.bottomYLocation = bottomYLocation;
			this.topMaxYLocation = topMaxYLocation;
			
			measureText();
			drawBubbleAndText();
		}
		
		private function handleClick(event:MouseEvent):void
		{
			if(!finishedReading)
			{
				finishReadingCard();
				dispatchEvent(new HangmanSpeechBubbleEvent(HangmanSpeechBubbleEvent.SKIP_PRESSED));
			}
		}
		
		public function readCard():void
		{
			readTimer.start();
			isFinishedReading = false;
			
			dispatchEvent(new HangmanSpeechBubbleEvent(HangmanSpeechBubbleEvent.CLUE_START));
		}
		
		public function get finishedReading():Boolean
		{
			return isFinishedReading;
		}
		
		public function finishReadingCard():void
		{
			readTimer.reset();
			
			if(!finishedReading)
			{
				drawBubbleAndText(maxTextLinesBeforeScroll);
				scrollText.text = clueText;
				scrollText.scroll = 100;
				
				isFinishedReading = true;
			}
		}
		
		private function handleReadTimerTick(event:TimerEvent):void
		{
			if(curCharIndex >= clueText.length - 2)
			{
				finishReadingCard();
				
				dispatchEvent(new HangmanSpeechBubbleEvent(HangmanSpeechBubbleEvent.CLUE_DONE));
			}
			else
			{
				var curChar:String = clueText.charAt(curCharIndex);
				scrollText.tf.appendText(curChar);
				scrollText.tf.scrollV = scrollText.tf.numLines;
				
				// evaluate if we need to expand
				if(!maxLinesReached && scrollText.tf.numLines > DEFAULT_NUM_LINES)
				{
					if(scrollText.tf.numLines != lastNumLinesDrawn)
					{
						if(canNumLinesFit(scrollText.tf.numLines))
						{
							drawBubbleAndText(scrollText.tf.numLines);
							lastNumLinesDrawn = scrollText.tf.numLines;
						}
						else
						{
							maxLinesReached = true;
						}
					}
				}
				
				curCharIndex++;
			}
		}
		
		private function measureText():void
		{
			// If we don't have any clue text we want to base our measurements on three lines of text (default)
			if(clueText == '')
			{
				measureTF.text = " \n \n ";
			}
			else
			{
				measureTF.text = clueText;
			}
			
			measuredTextFieldHeight = measureTF.height;
			measuredTextLineHeight = Math.ceil(measuredTextFieldHeight / Number(measureTF.numLines)) + 1;
			maxTextLinesBeforeScroll = Math.min(Math.max(DEFAULT_NUM_LINES, measureTF.numLines), (-topMaxYLocation + bottomYLocation - TF_PADDING - TF_PADDING) / measuredTextLineHeight);
			
			measureTF.text = '';
		}
		
		private function canNumLinesFit(numLines:int):Boolean
		{
			var proposedNewScrollTextHeight:Number = measuredTextLineHeight * numLines;
			var bubbleH:int = proposedNewScrollTextHeight + TF_PADDING + TF_PADDING;
			var proposedNewY:Number = bottomYLocation - bubbleH;
			
			return proposedNewY >= topMaxYLocation;
		}
		
		private function drawBubbleAndText(numLines:int = DEFAULT_NUM_LINES):void
		{
			scrollText.height = measuredTextLineHeight * numLines;
			var bubbleH:int = scrollText.height + TF_PADDING + TF_PADDING;
			
			var g:Graphics = graphics;
			g.clear();
			g.beginBitmapFill(new Texture(), null, true, false);
			g.drawRoundRect(0, 0, BUBBLE_W, bubbleH, BUBBLE_R);
			g.endFill();
			
			pointer.visible = bubbleH > 0;
			
			y = parent.globalToLocal(new Point(0, bottomYLocation)).y - bubbleH;
			
			pointer.x = BUBBLE_W - 1;
			pointer.y = globalToLocal(new Point(0, POINTER_GLOBAL_Y)).y;
		}
	}
}