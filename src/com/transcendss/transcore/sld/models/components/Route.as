package com.transcendss.transcore.sld.models.components
{
	import com.transcendss.transcore.util.*;
	import com.transcendss.transcore.util.Converter;
	import com.transcendss.transcore.util.Tooltip;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GraphicsPath;
	import flash.display.IGraphicsData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	
	import spark.components.Image;
	import spark.primitives.BitmapImage;
	
	
	
	[Bindable]
	public class Route extends Tippable
	{
		private var rteName:String;
		private var rteNumber:int;
		private var beginMile:Number;
		private var endMile:Number;
		private var routeDistance:Number;	
		private var _rteFullName:String;
		public var beginMilepost:Number;
		public var endMilepost:Number;
		
		// Images used to fill the bitmap space for a roadway.  One image is for an even number of lanes and the other
		// is for an odd number of lanes.  This was needed because of the way the fill is done so the lanes loook right.
		[Embed(source="../../../../../../images/RouteImages/MAVRIC Lane Images/01-lane.jpg") ]
		public var lane_1:Class;
		
		[Embed(source="../../../../../../images/RouteImages/MAVRIC Lane Images/01-lane-odd.jpg") ]
		public var lane_1_odd:Class;
		
		public function Route(rteName:String, bm:Number, em:Number, rteNo:int=0,rteFullName:String="")
		{
			super(Tippable.SLD);
			clearContainer();
			name = "route";
			routeName = rteName;
			_rteFullName = rteFullName;
			routeNumber = rteNo;				
			beginMile = bm;
			endMile = em;
			routeDistance = Math.abs(endMile - beginMile);
			tipText = rteName;
		}
		
		public function draw(diagramWidth:int, diagramHeight:int, rColor:uint = 0x000000,sColor:uint =0xFFF544, offsetValue:Number = 508):void
		{
			//clearContainer();  // must clear to draw/redraw
			var img:Bitmap = new lane_1();
			
			var routeLine:Shape = new Shape();
			var rdWidth:int = img.height;
			// calculate and store path
			var x1:int = 0 + offsetValue;
			var y1:int = (diagramHeight/2)-(rdWidth/2)-3;
			var x2:int = diagramWidth + offsetValue;
			var y2:int = (diagramHeight/2)+(rdWidth/2)-7;
			var routeDivLine:GraphicsPath; // not used?
			var drawing:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
			
			
			// draw graphic path
			routeLine.graphics.beginBitmapFill(img.bitmapData,null,true,true);
			routeLine.graphics.drawPath(
				Vector.<int>([1,2,2,2]),
				Vector.<Number>([x1,y1, x2,y1, x2,y2, x1,y2]));	
			routeLine.graphics.endFill();
			
			this.addChild(routeLine);
		}		
		
		// Draw the roadway image reflecting number of lanes.  Default is to draw a 2-lane roadway.
		public function drawMultiLanes(segmentWidth:int, height:int, scale:Number, numLanes:int, rColor:uint = 0x000000,
									   sColor:uint =0xFFF544, offsetValue:Number = 508, featureAC:ArrayCollection=null):void
		{
			clearContainer();  // must clear to draw/redraw
			var img:Bitmap = new lane_1;
			var routeLine:Shape;
			var rdWidth:int;
			var yAdjust1:int;
			var yAdjust2:int;
			var x1:Number;
			var y1:int;
			var x2:Number;
			var y2:int;
			var segWidth:Number = 0;
			var tmpOffset:Number = offsetValue;
			var tmpBeginMile:Number;
			var tmpEndMile:Number;
			var tmpx1:int;
			var tmpx2:int;
			var tmpStart:Number = 0;
			var tmpEnd:Number = 0;
			var drawing:Vector.<IGraphicsData>;
			var startPt:Number;
			var endPt:Number;
			var nextStartPt:Number;
			var featuresLength:int = 0;
			var useFeaturesAC:ArrayCollection = new ArrayCollection();
			
			var featureType:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.roadwayLanesEventType;
			var barElemFrmFieldNm:String = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getBarElementFromMeasure(featureType);
			var barElemToFieldNm:String = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getBarElementToMeasure(featureType);
			var barElemValFieldNm:String = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getBarElementValueField(featureType);
			
			
			// Get the array of elements that are to be used, and find the begin/end milepoint for the requested route
			if(featureAC != null && featureAC[0].hasOwnProperty("DATA") && featureAC[0].DATA.length > 0)
			{
				featuresLength = featureAC[0].DATA.length;
				
				// Eliminate any data that has start point > end point
				for(var j:int=0; j<featuresLength; j++)
				{
					if(parseFloat(featureAC[0].DATA[j][barElemFrmFieldNm]) < parseFloat(featureAC[0].DATA[j][barElemToFieldNm]))
						useFeaturesAC.addItem(featureAC[0].DATA[j]);
				}
				
				
			}
			
			featuresLength = useFeaturesAC.length;
			if(featuresLength>0)
			{
				useFeaturesAC.source.sortOn(barElemFrmFieldNm);
				
				tmpBeginMile = Math.max(useFeaturesAC[0][barElemFrmFieldNm],this.beginMile);
				tmpEndMile = Math.min(useFeaturesAC[featuresLength-1][barElemToFieldNm], this.endMile);
				segWidth = Math.round(Converter.scaleMileToPixel(tmpEndMile-tmpBeginMile,scale));
				
			}
			else
				segWidth = segmentWidth;
			// Always draw a single roadway as a default to cover the entire route
			//segWidth = segWidth == 0 ? segmentWidth : segWidth;
			img = getRoadwayImg(numLanes);
			rdWidth = img.height;
			// calculate and store path
			x1 = 0 + offsetValue;
			y1 = (height/2)-(rdWidth/2) - 5;
			x2 = segWidth + offsetValue;
			y2 = (height/2)+(rdWidth/2) - 5;
			drawing = new Vector.<IGraphicsData>();
			
			// draw graphic path
			routeLine = new Shape();
			routeLine.name ="routeLine";
			routeLine.graphics.beginBitmapFill(img.bitmapData,null,true,true);
			routeLine.graphics.drawPath(
				Vector.<int>([1,2,2,2]),
				Vector.<Number>([x1,y1, x2,y1, x2,y2, x1,y2]));	
			routeLine.graphics.endFill();
			
			this.addChild(routeLine);
			
			// If users have turned off displaying the number of lanes for this route, stop here
			if(!FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.roadwayLanesSwitch)
				return;
			
			// If there are specified roadway lanes, then draw those as well
			if(featureAC != null && featureAC[0].DATA.length > 0)
			{				
				// Process the remaining records
				for(var i:int=0; i<featuresLength; i++)
				{
					if(i == 0)
						startPt = tmpBeginMile;
					else
						startPt = useFeaturesAC[i][barElemFrmFieldNm];
					
					if(i == featuresLength-1)
						endPt = tmpEndMile;
					else
						endPt = useFeaturesAC[i][barElemToFieldNm];
					
					tmpStart = Converter.scaleMileToPixel(startPt,scale);
					// If the first number of lanes value does not start at the beginning of the route segment, calculate
					// the difference and add that offset to the first x value
					if(i == 0 && startPt > this.beginMile)
					{
						var diff = Converter.scaleMileToPixel(startPt,scale) - Converter.scaleMileToPixel(this.beginMile,scale);
						tmpOffset += diff;
					}
					
					tmpEnd = Converter.scaleMileToPixel(endPt,scale);
					segWidth = Math.round(tmpEnd - tmpStart);
					img = getRoadwayImg(useFeaturesAC[i][barElemValFieldNm]);
					yAdjust1 = 0;
					yAdjust2 = 0;
					if((numLanes % 2) == 0)
					{
						img.height += 2;
						yAdjust1 = -3;
						yAdjust2 = -7;
					}
					rdWidth = img.height;
					x1 = tmpOffset;
					y1 = (height/2)-(rdWidth/2) + yAdjust1;
					x2 = x1 + segWidth;
					y2 = (height/2)+(rdWidth/2) + yAdjust2;
					drawing = new Vector.<IGraphicsData>();
					
					// draw graphic path
					routeLine = new Shape();
					routeLine.name ="routeLine";
					routeLine.graphics.beginBitmapFill(img.bitmapData,null,true,true);
					routeLine.graphics.drawPath(
						Vector.<int>([1,2,2,2]),
						Vector.<Number>([x1,y1, x2,y1, x2,y2, x1,y2]));	
					routeLine.graphics.endFill();
					
					this.addChild(routeLine);
					
					// Add the gaps to the offset for any milepoint ranges that have no number of lanes specified
					tmpOffset = x2;
					if(i < featuresLength-1)
					{
						nextStartPt = useFeaturesAC[i+1][barElemFrmFieldNm];
						if(endPt != nextStartPt)
						{
							tmpx1 = Converter.scaleMileToPixel(endPt, scale);
							tmpx2 = Converter.scaleMileToPixel(nextStartPt, scale);
							var diff = Math.round(tmpx2 - tmpx1);
							tmpOffset += diff;
						}
					}
				}
			}
		}
		
		// Create an image based on the given number of lanes
		private function getRoadwayImg(numLanes:int):Bitmap
		{
			var img:Bitmap;
			
			// Valid number of lane values are 1-9.  Default to 1 if there is any other value.
			if(numLanes < 2 || numLanes > 9)
				numLanes = 1;
			
			// Use the appropriate image for even or odd number of lanes
			if((numLanes % 2) == 0)
				img = new lane_1;
			else
				img = new lane_1_odd;
			
			// Set the height of the image, based on a 10-pixel single lane.
			img.height = 10 * numLanes;
			
			return img;
		}
		
		public function clearContainer():void{
			// clear all children of container
			while (this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
		}
		
		public function get routeName():String
		{
			return rteName;
		}
		public function set routeName(name:String):void
		{
			rteName = name;
		}
		public function get routeFullName():String
		{
			return _rteFullName;
		}
		public function set routeFullName(name:String):void
		{
			_rteFullName = name;
		}
		
		public function get routeNumber():int
		{
			return rteNumber;
		}	
		public function set routeNumber(rteNo:int):void
		{
			rteNumber = rteNo;
		}
		
		public function get beginMi():Number
		{
			return beginMile;
		}
		public function set beginMi(bm:Number):void
		{
			beginMile = bm;
			routeDistance = Math.abs(endMile - beginMile);
		}	
		
		public function get endMi():Number
		{
			return endMile;
		}
		public function set endMi(em:Number):void
		{
			endMile = em;
			routeDistance = Math.abs(endMile - beginMile);
		}				
		
		public function get distance():Number
		{
			return routeDistance;
		}		
		
	}
	
	
}