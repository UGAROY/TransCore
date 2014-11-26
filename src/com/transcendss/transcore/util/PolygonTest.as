package  com.transcendss.transcore.util
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Miguel
	 */
	public class PolygonTest extends Sprite
	{
		private var _pointList:Array;
		private var _lineContainer:Sprite;
		
		public function PolygonTest() 
		{
			super();
			_pointList = new Array();
			_lineContainer = new Sprite();
			addChild(_lineContainer);
			createPoints();
			
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function enterFrameHandler(e:Event):void 
		{
			var mp:Point = new Point(parent.mouseX, parent.mouseY);
			drawLines();
			//trace(insidePolygon(_pointList, mp));
			status.text = (insidePolygon(_pointList, mp)) ? "Inside" : "Outside";
		}
		
		private function createPoints():void
		{
			var aPoints:Array = new Array( { x:100, y:100 }, { x:400, y:100 }, { x:400, y:250 }, { x:100, y:250 } );
			var p:PointTest;
			for each(var i:Object in aPoints) 
			{
				p = new PointTest();
				p.x = i.x;
				p.y = i.y;
				_pointList.push(p);
				addChild(p);
			}
		}
		
		private function drawLines():void
		{
			var g:Graphics = _lineContainer.graphics;
			g.clear();
			g.lineStyle(1, 0xff0000);
			g.moveTo(_pointList[0].x, _pointList[0].y);
			for each(var p:PointTest in _pointList)
			{
				g.lineTo(p.x, p.y);
			}
			g.lineTo(_pointList[0].x, _pointList[0].y);
		}
		
		
		private function insidePolygon(pointList:Array, p:Point):Boolean
		{
			var counter:int = 0;
			var i:int;
			var xinters:Number;
			var p1:PointTest;
			var p2:PointTest;
			var n:int = pointList.length;
			
			p1 = pointList[0];
			for (i = 1; i <= n; i++)
			{
				p2 = pointList[i % n];
				if (p.y > Math.min(p1.y, p2.y))
				{
					if (p.y <= Math.max(p1.y, p2.y))
					{
						if (p.x <= Math.max(p1.x, p2.x))
						{
							if (p1.y != p2.y) {
								xinters = (p.y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y) + p1.x;
								if (p1.x == p2.x || p.x <= xinters)
									counter++;
							}
						}
					}
				}
				p1 = p2;
			}
			if (counter % 2 == 0)
			{
				return(false);
			}
			else
			{
				return(true);
			}
		}
		
		
	}

}