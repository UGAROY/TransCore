package com.transcendss.transcore.util
{
	import com.asfusion.mate.events.Listener;
	import com.transcendss.transcore.sld.models.components.BaseAsset;
	import com.transcendss.transcore.vlog.TSSImage;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import mx.utils.ObjectUtil;
	
	import spark.components.Image;
	
	public class AssetSymbol extends Sprite
	{
		private var _baseAsset:BaseAsset;
		private var _stdHeight:int;
		private var _stdWidth:int;
		private var _centerV:Boolean;
		private var _centerH:Boolean;
		private var _placement_y:int;
		private var _usesPic:Boolean; // for highlighting outlines of non-image-based symbols
		public static const SELECTION_ALPHA:Number = 0.5;
		private var currentAlpha:Number;
		private var timer:Timer;
		private var _fading:Boolean = false; // for reselection of item during deselection fade process
		private var _fadeOK:Boolean = true;
		private var _selectRect:Sprite;
		private var _timeListener:Listener;
		private var _useScaling:Boolean;
		
		public function AssetSymbol(baseAsset:BaseAsset)
		{
			super();
			this._baseAsset = baseAsset;
			//this.name = baseAsset.id.toString();
			_selectRect = new Sprite();
//			this.addChild(_selectRect);
//			drawSelectRect();
		}
		
		public function get baseAsset():BaseAsset
		{
			return _baseAsset;
		}
		
		public function set baseAsset(value:BaseAsset):void
		{
			_baseAsset = value;
			this.name = _baseAsset.id.toString();
		}
		
		public function drawSelectRect(a:Number = 0):void
		{
			// Invisible rectangle to assist with tapping
			if(this.contains(_selectRect))
				this.removeChild(_selectRect);
			_selectRect.graphics.clear();
			_selectRect.graphics.beginFill(0x736F6E,a);
			_selectRect.graphics.lineStyle(0,0x000000,a);
			if(this.rotation != 0)
				_selectRect.graphics.drawRect(0,0,this.stdHeight, this.stdWidth);
			else
				_selectRect.graphics.drawRect(0,0,this.stdWidth,this.stdHeight);
			_selectRect.graphics.endFill();	
			this.addChild(_selectRect);
		}
		
		public function selectAsset():void
		{
			this.drawSelectRect(SELECTION_ALPHA);
			currentAlpha = SELECTION_ALPHA;
			timer = new Timer(30);
			timer.addEventListener(TimerEvent.TIMER, fadeAsset);
		}
		
		public function deselectAsset():void
		{
			/*
			 * Timer != null when item is selected 
			 */
			if(timer != null)
				timer.start();
			
		}
		
		private function fadeAsset(event:Event):void{
			if(event.target != timer)
			{
				(event.target as Timer).stop();
				return;
			}
				
			if(currentAlpha > 0)
			{
				currentAlpha -= 0.01;
				this.drawSelectRect(currentAlpha);
			}
			else
			{
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, fadeAsset);
				timer = null;
			}
		}
		
		public function get stdHeight():int
		{
			return _stdHeight;
		}

		public function set stdHeight(value:int):void
		{
			_stdHeight = value;
		}

		public function get stdWidth():int
		{
			return _stdWidth;
		}

		public function set stdWidth(value:int):void
		{
			_stdWidth = value;
		}
		
		/**
		 * Specifies the y placement the symbol should have in the diagram as a percentage of the diagram's height.
		 *  
		 */
		public function get placement_y():int
		{
			return _placement_y;
		}
		
		/**
		 * Sets the y placement the symbol should have in the diagram. This value should be a percentage.
		 *  
		 */
		public function set placement_y(value:int):void
		{
			_placement_y = value;
		}
		
		/**
		 * True if asset should be centered vertically
		 */ 
		public function get centerV():Boolean
		{
			return _centerV;
		}
		
		/**
		 * Returns true if the item should be centered vertically.
		 */
		public function set centerV(value:Boolean):void
		{
			_centerV = value;
		}
		
		/**
		 * True if asset should be centered horizontally.
		 */ 
		public function get centerH():Boolean
		{
			return _centerH;
		}
		
		/**
		 * Returns true if the item should be centered horizontally.
		 */
		public function set centerH(value:Boolean):void
		{
			_centerH = value;
		}
		public function get useScaling():Boolean
		{
			return _useScaling;
		}
		
		public function set useScaling(u:Boolean):void
		{
			_useScaling =u;
		}

		public function get usesPic():Boolean
		{
			return _usesPic;
		}

		public function set usesPic(value:Boolean):void
		{
			_usesPic = value;
		}

		public function get fading():Boolean
		{
			return _fading;
		}

		public function set fading(value:Boolean):void
		{
			_fading = value;
		}

		public function get fadeOK():Boolean
		{
			return _fadeOK;
		}

		public function set fadeOK(value:Boolean):void
		{
			_fadeOK = value;
		}

		public function get selectRect():Sprite
		{
			return _selectRect;
		}

		public function set selectRect(value:Sprite):void
		{
			_selectRect = value;
		}
		
		public static function clone(symbol:AssetSymbol):AssetSymbol
		{
			var clone:AssetSymbol = new AssetSymbol(symbol._baseAsset);
			var array:Array = new Array();
			symbol.visible = true;
			clone._centerH = symbol._centerH;
			clone._centerV = symbol._centerV;
			clone._placement_y = symbol.placement_y;
			clone._stdHeight = symbol._stdHeight;
			clone._stdWidth = symbol._stdWidth;
			clone.graphics.copyFrom(symbol.graphics);
			
			for(var i:int = 0; i < symbol.numChildren;i++)
			{
				array.push(symbol.getChildAt(i));
			}
			
			var bd:BitmapData = new BitmapData(symbol.width, symbol.height, true, 0xFFFFFF);
			bd.draw(symbol);
			var b:Bitmap = new Bitmap(bd);
			clone.addChild(b);
			
//			for(var i:int = 0; i < symbol.numChildren; i++)
//			{
//				if(symbol.getChildAt(i) is Bitmap)
//				{
//					clone.addChild(ObjectUtil.clone(symbol.getChildAt(i)) as Bitmap);
//				}	
//				else if(symbol.getChildAt(i) is TextField)
//				{
//					var f:TextField = symbol.getChildAt(i) as TextField;
//					clone.addText(f.text, f.textColor);
//				}
//				else if(symbol.getChildAt(i) is Sprite)
//				{
//					clone.addChild(symbol.getChildAt(i));
//					i--;
//				}
//				else if(symbol.getChildAt(i) is Shape)
//				{
//					trace("Shape obj: already copied (hopefully)");
//				}
//				else if(symbol.getChildAt(i) is Image)
//				{
//					trace("Hey, we got an image here!");
//				}
//				else if(symbol.getChildAt(i) is TSSImage)
//				{
//					trace("It's a tss pic");
//				}
//			}
			return clone;
		}
		
		/**
		 * Adds text to the center of the symbol.
		 */
		public function addText(text:String, color:uint = 0x000000):void
		{
			var field:TextField = new TextField();
			field.text = text;
			field.textColor= color
			field.visible = true;
			field.background = true;
			field.backgroundColor = 0xffffff;
			field.width = field.textWidth + 3;
			field.height = field.textHeight + 3;
			field.x = this.stdWidth /2 - field.width / 2;
			field.y = this.stdHeight/2 - field.height/2;
			addChild(field);
		}
		
		/**
		 * Scales the symbol using the scaleX and scaleY properties
		 * and adjusts the standard width and height values accordingly.
		 * @param A number between 0 and 1.0
		 */
		public function scaleStd(fraction:Number):void
		{
			this.scaleX = fraction;
			this.scaleY = fraction;
			this.stdHeight *=fraction;
			this.stdWidth *= fraction;
		}
		
	}
}