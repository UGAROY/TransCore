package com.transcendss.transcore.util
{
	import flash.display.DisplayObjectContainer;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public final class TextFieldUtils
	{
		
		public function TextFieldUtils() 
		{
			throw new Error("TextFieldUtils must not be instantiated");
		}
		/**
		 * Create a textField instance
		 * @param	parent Parent of textField
		 * @param	text Text of textField (htmlText)
		 * @param	font Font name to be used in textField
		 * @param	embed
		 * @param	size
		 * @param	color
		 * @param	width
		 * @param	height
		 * @param	autoSize
		 * @param	multiline
		 * @param	wordWrap
		 * @param	cacheAsBitmap
		 * @param	align
		 * @param	leading
		 * @param	letterSpacing
		 * @param	type
		 * @param	selectable
		 * @param	sharpness
		 * @param	border
		 * @return
		 */
		public static function textField(parent:DisplayObjectContainer, text:String, font:*, embed:Boolean = true, size:Number = NaN, color:Number = 0xFFFFFF, width:Number = NaN, height:Number = NaN, autoSize:String = "none", multiline:Boolean = false, wordWrap:Boolean = false, cacheAsBitmap:Boolean = false, align:String = "center", leading:Number = NaN, letterSpacing:Number = NaN, type:String = "dynamic", selectable:Boolean = false, sharpness:Number = NaN, border:Boolean = false):TextField
		{
			var t:TextField = new TextField();
			var tf:TextFormat = new TextFormat();
			
			parent.addChild(t);
			
			tf.align = TextFormatAlign.LEFT;
			tf.font = font;
			if(size) tf.size = size;
			tf.color = color;
			tf.leading = leading;
			if (letterSpacing) tf.letterSpacing = letterSpacing;
			
			switch(align.toLowerCase())
			{
				case "left":
					tf.align = TextFormatAlign.LEFT;
					break;
				case "center":
					tf.align = TextFormatAlign.CENTER;
					break;
				case "right":
					tf.align = TextFormatAlign.RIGHT;
					break;
				case "justify":
					tf.align = TextFormatAlign.JUSTIFY;
					break;
				default:
					tf.align = TextFormatAlign.LEFT;
					break;
			}
			
			t.antiAliasType = AntiAliasType.ADVANCED;
			t.type = (type == "dynamic") ? TextFieldType.DYNAMIC : TextFieldType.INPUT; 
			t.defaultTextFormat = tf;
			t.embedFonts = embed;
			t.cacheAsBitmap = cacheAsBitmap;
			t.mouseEnabled = selectable;
			t.selectable = selectable;
			t.multiline = multiline;
			t.border = border;
			t.wordWrap = wordWrap;
			if (sharpness) t.sharpness = sharpness;
			t.htmlText = text;
			t.width = (width) ? width : t.textWidth + 5;
			t.height = (height) ? height : t.textHeight + 5;
			
			switch(autoSize.toLowerCase())
			{
				case "left":
					t.autoSize = TextFieldAutoSize.LEFT;
					break;
				case "center":
					t.autoSize = TextFieldAutoSize.CENTER;
					break;
				case "right":
					t.autoSize = TextFieldAutoSize.RIGHT;
					break;
			}
			
			return t;
		}
	}
}