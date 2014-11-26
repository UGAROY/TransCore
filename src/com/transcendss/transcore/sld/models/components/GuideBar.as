package com.transcendss.transcore.sld.models.components
{
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.transcore.util.Graphics;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GraphicsPath;
	import flash.display.IGraphicsData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.*;
	import flash.ui.Mouse;
	
	public class GuideBar extends Sprite
	{
		
		private var minY:Number = 0;
		private var maxY:Number = 0;
		private var minX:Number = 0;
		private var maxX:Number =0;
		public var parentN:String;
		private var dispatcher:Dispatcher = new Dispatcher();
		private var guideBarSprite:Sprite = new Sprite();
		public function GuideBar(parentName:String)
		{
			super();
			parentN = parentName;
			clearContainer();
		}
		
		public function draw(atPixel:Number, lineLen:Number, dWidth:Number, xAngle:Number=90, buttonMode:Boolean=false, useHandCursor:Boolean = false, dragStartEventListner:Function = null, dragStopEventListner:Function =null):void
		{
			clearContainer();  // must clear to draw/redraw
			graphics.beginFill(0xffffff,1);
			
			var guideBarShp:Shape = new Shape();
			var drawing:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
			
			var path:GraphicsPath;
			
			var tipBuffer:int = 7;
			var x:int = atPixel;
			var y1:Number = 0;
			var y2:Number = lineLen;
			maxY = lineLen;
			maxX = dWidth;
			var labelYOffset:Number = 30;

			guideBarShp.graphics.lineStyle(1, 0);
			path = new GraphicsPath(Vector.<int>([1,2]),
				Vector.<Number>([x,y1, x,y2]));
			drawing.push(path);
			guideBarShp.graphics.drawGraphicsData(drawing);
			
			guideBarShp.graphics.lineStyle(1,0xFFFF00,.5);
			guideBarShp.graphics.beginFill(0xFFFF00,.5);
			guideBarShp.graphics.drawRect(x-tipBuffer,y1,tipBuffer*2,lineLen);
			guideBarShp.graphics.endFill();
			
			guideBarSprite.addChild(guideBarShp);
			guideBarSprite.buttonMode = buttonMode;
			guideBarSprite.useHandCursor = useHandCursor;
			
			addChild(guideBarSprite);
			this.mouseEnabled = false;
			this.mouseChildren = false;
			
			if (dragStartEventListner != null)
			{
				this.addEventListener(MouseEvent.MOUSE_DOWN, dragStartEventListner, false);
				this.addEventListener(MouseEvent.MOUSE_DOWN, dragStartEventListner, false);
			}
			
			if (dragStopEventListner != null)
			{
				this.addEventListener(MouseEvent.MOUSE_UP, dragStopEventListner, false);
				this.addEventListener(MouseEvent.MOUSE_UP, dragStopEventListner, false);
			}
		}
		
		public function moveGuideBar(xPos:Number):void{
			guideBarSprite.x=xPos;
		}
		
		public function getXPosition():Number
		{
			return guideBarSprite.x;
		}
	
		
		public function clearContainer():void{
			while (guideBarSprite.numChildren > 0)
			{
				guideBarSprite.removeChildAt(0);
			}
			// clear all children of container
			while (this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
		}
		
	}
}

