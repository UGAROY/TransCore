package com.transcendss.transcore.util
{
	//import com.dncompute.graphics.GraphicsUtil;
	//import com.transcendss.railanalyzer.util.PDFUtil;
	
	
	import com.transcendss.transcore.util.dncompute.graphics.GraphicsUtil;
	
	import flash.display.GraphicsPath;
	import flash.display.IGraphicsData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.net.registerClassAlias;
	
	import mx.utils.ObjectUtil;
	
	import org.alivepdf.colors.Color;
	import org.alivepdf.colors.RGBColor;
	import org.alivepdf.pdf.PDF;
	
	import spark.core.SpriteVisualElement;

	public class RedLineSymbol extends BaseSymbol
	{
		public static const REDLINE_CIRCLE:Number = 1000;
		public static const REDLINE_RECTANGLE:Number = 1001;
		public static const REDLINE_LINE:Number = 1002;
		public static const REDLINE_FREELINE:Number = 1003;
		public static const REDLINE_TEXT:Number = 1005;
		public static const REDLINE_ARROW:Number = 1006;
		
		private var _id:Number;
		private var _redlineType:Number;
		//private var graphicSVE:SpriteVisualElement=new SpriteVisualElement();
		private var _pdfUtil:PDFUtil;
		private var xpos1:Number;
		private var ypos1:Number;
		private var xpos2:Number;
		private var ypos2:Number;
		private var _fillcolor:uint=0x000000;
		private var _fillCode:Number=-1;
		private var _lineweight:Number;
		private var _color:uint = 0x000000;
		private var _radius:Number
		private var arrowProperties:Object;
		private var direction:String;
		private var pdfLineWeight:Number;
		public var redShape:Shape = new Shape();
		
		public function RedLineSymbol(rshape:Shape, stype:Number=0, posx1:Number=0, posy1:Number=0, posx2:Number=0, posy2:Number=0, lWeight:Number=1, pdfutil:PDFUtil=null, radius:Number=0, arrowprop:Object=null, dir:String="", fColor:Number=0,fillCode:Number=-1)
		{
			_fillCode=fillCode;
			_redlineType = stype;
			if (rshape != null)
				redShape = rshape;
			xpos1 = posx1;
			ypos1 = posy1; 
			xpos2 = posx2;
			ypos2 = posy2; 
			_lineweight = lWeight;
			
			if (lineweight == 1)
			{
				pdfLineWeight = .0001;
			} else if (lineweight == 2)
			{
				pdfLineWeight = .015;
			}
			
			_pdfUtil = pdfutil;
			_radius = radius;
			arrowProperties = arrowprop;
			direction = dir;
			_color = fColor;
			if(stype!=0)
				drawRedline();
		}
		
		
	
		public function get color():uint
		{
			return _color;
		}

		public function get lineweight():Number
		{
			return _lineweight;
		}

		public function get fillcolor():uint
		{
			return _fillcolor;
		}
		public function set fillcolor(u:uint):void
		{
			_fillcolor=u;
			
		}

		public function drawRedline():void
		{
			//fillcolor = 0x000000;
			//color = 0x000000;
			//var redShape:Shape = new Shape();
			var path:GraphicsPath;
			var drawing:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
			if(_redlineType == 1005)
			{
	//			SymbolLabel();
			}
			else if(_redlineType == 1000) //Circle
			{				
				/*selectRect.graphics.lineStyle(lineweight + 3, 0xCCCCCC, 0.75);
				selectRect.graphics.drawCircle(xpos1, ypos1, _radius);*/
				if(_fillCode==0 )
					redShape.graphics.beginFill(0x000000);
				redShape.graphics.lineStyle(lineweight, color);
				//redShape.graphics.beginFill(fillcolor);
				redShape.graphics.drawCircle(xpos1, ypos1, _radius);
				//_pdfUtil.drawCircleToPDF(xpos1, ypos1, _radius, pdfLineWeight, "0x000000", "0x000000");
				redShape.graphics.endFill();
			}
			else if(_redlineType == 1001) //Rectangle
			{
				/*selectRect.graphics.lineStyle(lineweight + 3, 0xCCCCCC, 0.75);
				selectRect.graphics.drawRect(xpos1, ypos1, xpos2, ypos2);*/
				
				redShape.graphics.lineStyle(lineweight, color);
				//redShape.graphics.beginFill(fillcolor);
				redShape.graphics.drawRect(xpos1, ypos1, xpos2, ypos2);
				//_pdfUtil.drawRectToPDF(xpos1, ypos1,  xpos2, ypos2, pdfLineWeight, "0x000000", "0x000000");
				redShape.graphics.endFill();
			}
			else if(_redlineType == 1002) //Line
			{
				/*selectRect.graphics.lineStyle(lineweight + 3, 0xCCCCCC, 0.75);
				selectRect.graphics.moveTo(0,0);
				selectRect.graphics.lineTo(xpos2-xpos1, ypos2-ypos1);*/
//				selectRect.graphics.moveTo(xpos1, ypos1);
//				selectRect.graphics.lineTo(xpos2, ypos2);
				
				redShape.graphics.lineStyle(lineweight, color);
				//redShape.graphics.beginFill(fillcolor);
				//redShape.graphics.moveTo(xpos1, ypos1);
				//redShape.graphics.lineTo(xpos2, ypos2);
				//redShape.graphics.endFill();
				path = new GraphicsPath(Vector.<int>([1,2]),
					Vector.<Number>([xpos1,ypos1,xpos2,ypos2]));
				drawing.push(path);
				redShape.graphics.drawGraphicsData(drawing);
				
				//_pdfUtil.drawLineToPDF(xpos1, ypos1, xpos2, ypos2, pdfLineWeight, "0x000000");
			}else if(_redlineType == 1003)
			{
				redShape.graphics.lineStyle(lineweight, color);
				//redShape.graphics.beginFill(fillcolor);
				drawArc(xpos1, ypos1, Math.PI/2, 3*Math.PI/2, _radius,1);
				redShape.graphics.moveTo(xpos1, ypos1-_radius);
				redShape.graphics.lineTo(xpos1, ypos1+_radius);
			}
			else if(_redlineType == 1006) //Arrow
			{
				GraphicsUtil.drawArrowHead(redShape.graphics,
					new Point(xpos1, ypos1), new Point(xpos2, ypos2), 
					{shaftThickness:.1,headWidth:5,headLength:17,
						shaftPosition:0,edgeControlPosition:.5});
				//_pdfUtil.drawArrowToPDF(xpos1, ypos1, xpos2, ypos2, arrowProperties.headLength, arrowProperties.headWidth,
				//	direction, pdfLineWeight, fillcolor.toString(), color.toString());
			}

			/*graphicSVE.addChild(redShape);
			graphicSVE.addChild(selectRect);
			graphicSVE.setChildIndex(selectRect, 0);
			selectRect.visible = false;
			addChild(graphicSVE);*/
			
			symbolSprite.addChild(redShape);
			/*symbolSprite.addChild(selectRect);
			symbolSprite.setChildIndex(selectRect,0);
			selectRect.visible = false;*/
			addChild(symbolSprite);
			//EnableSelection();
		}
		
		/**
		 * Found the code at http://www.actionscript.org/forums/showthread.php3?t=192099.
		 * Currently used to draw an arc for redline code 1003.
		 */ 
		private function drawArc(centerX:Number, centerY:Number, startAngle:Number, endAngle:Number, radius:Number, direction:Number):void
			/* 
			centerX  -- the center X coordinate of the circle the arc is located on
			centerY  -- the center Y coordinate of the circle the arc is located on
			startAngle  -- the starting angle to draw the arc from
			endAngle    -- the ending angle for the arc
			radius    -- the radius of the circle the arc is located on
			direction   -- toggle for going clockwise/counter-clockwise
			*/
		{
			var difference:Number = Math.abs(endAngle - startAngle);
			/* How "far" around we actually have to draw */
			
			var divisions:Number = Math.floor(difference / (Math.PI / 4))+1;
			/* The number of arcs we are going to use to simulate our simulated arc */
			
			var span:Number    = direction * difference / (2 * divisions);
			var controlRadius:Number    = radius / Math.cos(span);
			
			redShape.graphics.moveTo(centerX + (Math.cos(startAngle)*radius), centerY + Math.sin(startAngle)*radius);
			var controlPoint:Point;
			var anchorPoint:Point;
			for(var i:Number=0; i<divisions; ++i)
			{
				endAngle    = startAngle + span;
				startAngle  = endAngle + span;
				
				controlPoint = new Point(centerX+Math.cos(endAngle)*controlRadius, centerY+Math.sin(endAngle)*controlRadius);
				anchorPoint = new Point(centerX+Math.cos(startAngle)*radius, centerY+Math.sin(startAngle)*radius);
				redShape.graphics.curveTo(
					controlPoint.x,
					controlPoint.y,
					anchorPoint.x,
					anchorPoint.y
				);
			}
		}
		
		public override function clone() : BaseSymbol
		{
			registerClassAlias("com.transcendss.railanalyzer.symbols.RedLineSymbol", RedLineSymbol);
			
			var bs1:RedLineSymbol   = new RedLineSymbol(this.redShape, this._redlineType, this.xpos1,this.ypos1, this.xpos2, this.ypos2, this.lineweight, this._pdfUtil, this._radius);
			return bs1 as BaseSymbol;
		}
		
		public function setStyle(symbolStyle:SymbolStyle):void
		{
			_fillcolor = symbolStyle.fillcolor;
			_lineweight = symbolStyle.lineweight;
			_color = symbolStyle.color;
		}
		
		public function highlight():void
		{
			redShape.graphics.lineStyle(lineweight, 0x00FF00, 0.25);
		}
		
		public function unhighlight(a:Number):Boolean
		{
			if(a <= 0)
			{
				redShape.graphics.lineStyle(lineweight, 0x00FF00, 0.00);
				return true;
			}
			else 
			{
				redShape.graphics.lineStyle(lineweight, 0x00FF00, a);
				return false;
			}
				
		}
		
	}
}