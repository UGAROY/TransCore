package com.transcendss.transcore.util
{
	import com.transcendss.transcore.util.BaseSymbol;
	
	public class SymbolStyle
	{
		// From RedLine style
		private var _fillcolor:uint;
		private var _lineweight:Number;
		private var _color:uint = 0x000000;
		
		// From SymbolLabel style
		private var _txtSize:Number;
		private var _font:String;
		private var _txtAlign:String;
		private var _txtColor:Number;
		
		public function SymbolStyle(symbol:BaseSymbol)
		{
			if(symbol is RedLineSymbol)
			{
				var tmpRedLine:RedLineSymbol = symbol as RedLineSymbol;
				_fillcolor = tmpRedLine.fillcolor;
				_lineweight = tmpRedLine.lineweight;
				_color = tmpRedLine.color;
			}
			//			else if(symbol is SymbolLabel)
			//			{
			//				var tmpSymbolLabel = symbol as SymbolLabel;
			//				_txtSize = tmpSymbolLabel.txtSize;
			//				_font = tmpSymbolLabel.font;
			//				_txtAlign = tmpSymbolLabel.txtAlign;
			//				_txtColor = tmpSymbolLabel.txtColor;
			//			}
			
		}
		
		public function get color():uint
		{
			return _color;
		}
		
		public function set color(value:uint):void
		{
			_color = value;
		}
		
		public function get lineweight():Number
		{
			return _lineweight;
		}
		
		public function set lineweight(value:Number):void
		{
			_lineweight = value;
		}
		
		public function get fillcolor():uint
		{
			return _fillcolor;
		}
		
		public function set fillcolor(value:uint):void
		{
			_fillcolor = value;
		}
		
		public function get txtColor():Number
		{
			return _txtColor;
		}
		
		public function set txtColor(value:Number):void
		{
			_txtColor = value;
		}
		
		public function get txtAlign():String
		{
			return _txtAlign;
		}
		
		public function set txtAlign(value:String):void
		{
			_txtAlign = value;
		}
		
		public function get font():String
		{
			return _font;
		}
		
		public function set font(value:String):void
		{
			_font = value;
		}
		
		public function get txtSize():Number
		{
			return _txtSize;
		}
		
		public function set txtSize(value:Number):void
		{
			_txtSize = value;
		}
		
	}
}