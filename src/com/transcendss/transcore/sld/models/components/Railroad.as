package com.transcendss.transcore.sld.models.components
{
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.transcore.events.FeatureEvent;
	import com.transcendss.transcore.util.*;
	import com.transcendss.transcore.util.geom.FlexMatrixTransformer;
	
	import flash.display.GraphicsPath;
	import flash.display.IGraphicsData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.*;
	
	import mx.collections.ArrayCollection;
	import mx.core.*;
	
	public class Railroad extends  Sprite
	{
		public static const SINGLE:int = 1;
		public static const DOUBLE:int = 2;
		
		private var railType:int;
		private var railRdID:Number;
		private var yTopOffset:int = 30;
		private var yBotOffset:int = 40;
		private var ySleeperOffset:int = 35;
		private var distBtwnRails:int = 4;
		private var distBtwnSleepers:int = 6;
		private var sleeperLength:int = 10;	
		private var bedWidth:int = 12;
		
		private var railLabel:Sprite;
		
		private var routeName:String;
		private var beginMile:Number;
		private var endMile:Number;
		private var milePoint:Number;
		private var featureName:String;
		private var crossingAngle:Number;
		private var coLocStr:String;
		private var dispatcher:Dispatcher = new Dispatcher();
		private var rrxngColl:ArrayCollection = new ArrayCollection();
		private var railArray:Array = new Array();
		private var featureConst:String;
		
		public function Railroad(ftConst:String,rteName:String, rteBeg:Number, rteEnd:Number)
		{
			super();
			name = "RRXING";
			clearContainer();
			beginMile=rteBeg;
			endMile=rteEnd;
			routeName = rteName;
			featureConst = ftConst;
			railArray = [];
		}
		
		public function getRRXings():void{
			//call service and obtain array of countylines
			var ftEvent:FeatureEvent = new FeatureEvent( FeatureEvent.FEATURE_REQUEST,featureConst);
			ftEvent.serviceURL = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL +"XingFeatures/"+featureConst+"/"+routeName+"/"+beginMile+"/"+endMile;
			dispatcher.dispatchEvent(ftEvent);
		}
		
		public function draw(ac:ArrayCollection , diagramScale:Number, diagramHeight:Number, rteBeginMi:Number, type:int=1, cluster:Boolean=false):void
		{
			clearContainer();  // must clear to draw/redraw
			railArray = [];  // clear rail array
			var i:int;
			railLabel = new Sprite();
			railType = type;
			rrxngColl = ac;
			
			// store
			for(i=0; i < rrxngColl.length; i++)
			{
				// store values into bridge array
				railRdID = new Number(String(rrxngColl.getItemAt(i).ID));
				milePoint = new Number(String(rrxngColl.getItemAt(i).REFPT));
				featureName = String(rrxngColl.getItemAt(i).FEATURE_NAME);
				crossingAngle = new Number(String(rrxngColl.getItemAt(i).CROSSING_ANGLE));
				crossingAngle = (crossingAngle < 180)?180-crossingAngle:crossingAngle - 180;  // use back-azimuth
				railArray.push({id:null, parentId:null,coLoc:null,rRdID:railRdID,atMile: milePoint, name: featureName, xAngle: crossingAngle});
			}
			
			if(railArray.length>0)
			{
				// process
				if(cluster){
					//cluster bridges
					railArray = processRailByScale(getClusterDistance(diagramScale));
				}			
	
				// draw 
				for(i=0; i < railArray.length; i++)
				{
					if (railArray[i].parentId != null && cluster) continue; // print single and clustered bridges
					railRdID = new Number(railArray[i].rRdID);
					milePoint = new Number(railArray[i].atMile);
					featureName = String(railArray[i].name);
					coLocStr = String(railArray[i].coLoc);
					crossingAngle = new Number(railArray[i].xAngle);
					drawRailroad(Converter.scaleMileToPixel(milePoint-rteBeginMi,diagramScale), diagramScale, diagramHeight, featureName, coLocStr, crossingAngle,railRdID);
	
				}
			}

		}
		
		private function drawRailroad(atPixel:Number, diagramScale:Number, trackLen:Number, railName:String, coLabel:String, xAngle:Number,railRdID:Number):void{
			
			graphics.beginFill(0xffffff,1);
			var railSprite:Tippable = new Tippable(Tippable.SLD);
			var railShp:Shape = new Shape();
			var path:GraphicsPath;	
			var drawing:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
			var vCmds:Vector.<int> = new Vector.<int>();
			var vCoords:Vector.<Number> = new Vector.<Number>();				
			
			// rail bed
			var x1:Number = atPixel - (bedWidth/2);
			var y1:Number = 0+yTopOffset;
			var y2:Number = trackLen - yBotOffset;
			var bedColor:uint = 0xffffff;	
			var bedWd:Number = bedWidth;
			var bedHt:Number = trackLen-yBotOffset-yTopOffset;
			

			
			// atgrade box
			var boxWd:Number = bedWidth;
			var boxHt:Number = 20;
			var boxColor:uint = 0xc0c0c0;		
			var bX1:Number = x1;
			var bY1:Number = (trackLen/2) - (boxHt/2);
			var bY2:Number = bY1 + boxHt;
			
			//draw box
//			railShp.graphics.beginFill(boxColor,1);
//			railShp.graphics.drawRect(bX1,bY1,boxWd,boxHt);
//			railShp.graphics.endFill();
			
			//add the 2 rails
			var leftRailX:Number = atPixel - (distBtwnRails/2);
			var rightRailX:Number = atPixel + (distBtwnRails/2);
			
			vCmds.push(1,2,1,2);
			vCoords.push(
				leftRailX, y1, 
				leftRailX, y2, 
				rightRailX, y1, 
				rightRailX, y2);
			
			//add the rail sleepers 
			var curY:Number = trackLen-yBotOffset;
			var sleeperX1:Number = atPixel - (sleeperLength/2);
			var sleeperX2:Number = atPixel + (sleeperLength/2);
			while(curY>ySleeperOffset)
			{
				curY = curY-distBtwnSleepers;
				if (curY < (bY1-2) || curY > (bY2+2))
				{
					vCmds.push(1);
					vCoords.push(sleeperX1, curY);
					vCmds.push(2);
					vCoords.push(sleeperX2, curY);
				}
			}
			
			railShp.graphics.lineStyle(1,0);
			path = new GraphicsPath(vCmds,vCoords);
			drawing.push(path);
			//draw rail and sleeper lines
			railShp.graphics.drawGraphicsData(drawing);				
			railShp = Graphics.addGlow(railShp,0xdfdfdf,0.4);
			
			// draw bed
			railShp.graphics.lineStyle(1,0x0,0);
			railShp.graphics.beginFill(0xffffff,0);
			railShp.graphics.drawRect(x1-5,y1-5,bedWd+5,bedHt+5);
			railShp.graphics.endFill();
			
			// set maximum allowable crossing angle - nothing within 15 degrees of 90		
			if (xAngle > 65 && xAngle <= 90) xAngle = 65;
			else if (xAngle > 90 && xAngle < 115) xAngle = 115;
			// call util to rotate sprite at its xing point
			var m:Matrix = railShp.transform.matrix;
			FlexMatrixTransformer.rotateAroundInternalPoint(m, atPixel, (trackLen / 2), xAngle);
			railShp.transform.matrix = m;
			railSprite.addChild(railShp);  // add shape to sprite
			
			railSprite.tipText = railName;
			railSprite.tipBGColor = 0xFAFF70;
			// call to label cluster - if label is not null
			if(coLabel != "null"){
				// create and add label to sprite
				railSprite.addChild(drawClusterLabel(coLabel,atPixel,((trackLen/2)-22)));
			}
			railSprite.name = String(railRdID);
			railSprite.buttonMode = true;
			railSprite.useHandCursor = true;
			railSprite.addEventListener(MouseEvent.CLICK,onRailClick);
			addChild(railSprite);
		}
		private function onRailClick(event:MouseEvent ):void{
			
		}
		
		private function processRailByScale(scaleDistFactor:Number):Array{
			var typeArray:Array = railArray;
			//set first cntr
			typeArray[0].id = 0;
			
			for (var i:int=1;i<typeArray.length;i++){
				var coLoc:int = 0;
				typeArray[i].id = i; // set cntr
				var pIdx:int = i-1;
				var pMile:Number = typeArray[pIdx].atMile;
				var cMile:Number = typeArray[i].atMile;
				
				if(Math.abs(cMile - pMile) <= scaleDistFactor)
				{
					typeArray[i].parentId = typeArray[i-1].id;  // set current 'parent id' to previous crossing 'id'
					coLoc++;
					
					for (var j:int=i+1;j<typeArray.length;j++){
						// look to next item
						var nMi:Number = typeArray[j].atMile;
						if(Math.abs(nMi - cMile) <= scaleDistFactor)
						{
							typeArray[j].id = j; // set cntr
							typeArray[j].parentId = typeArray[i].parentId;  // set next 'parent id' to current 'parent id'
							i++;  // inc i
							coLoc++;
						}
						else break;
					}
					if (coLoc > 0){
						typeArray[pIdx].coLoc = coLoc+1;
					} 
				}
			}
			return typeArray;
		}		
		
		public function drawClusterLabel(coLoLabel:String,xPos:Number,yPos:Number):Sprite{
			// add coLo # symbol
			var cSprite:Sprite = new Sprite();
			if(coLoLabel != null)
			{
				//draw green circle
				var gCircle:Shape = new Shape();
				gCircle.graphics.beginFill(0x008000,1);
				gCircle.graphics.drawCircle(xPos,yPos,10);	
				cSprite.addChild(gCircle);
				// create text
				var text:TextField = new TextField();
				text.text = coLoLabel;
				text.backgroundColor = 	0xFFFFFF;
				text.filters = [new GlowFilter(0xdfdfdf,0.6)];
				text.autoSize = TextFieldAutoSize.CENTER;    
				text.selectable = false;
				text.mouseEnabled = false;
				var txtFormat:TextFormat = new TextFormat(); 
				txtFormat.color = 0xFFFFFF; 
				txtFormat.font = "Arial";
				txtFormat.size = 15;
				txtFormat.bold = true;
				txtFormat.letterSpacing = 2;
				
				text.setTextFormat(txtFormat);
				cSprite.addChild(text);
				text.x = xPos-6;
				text.y = yPos-11;
				
			}
			// store label sprite
			return cSprite;
		}
		
		private function getClusterDistance(scale:Number):Number{
			// todo: break out into settings
			if (scale < 5000) return 0;
			if (scale <= 10000) return 0.2;
			if (scale <= 50000) return 0.4;
			if (scale <= 75000) return 0.6;
			if (scale <= 100000) return 0.9;
			if (scale <= 250000) return 3;
			else return 5;
		}		
		
		
		public function get label():Sprite
		{
			return railLabel;
		}
		
		public function clearContainer():void{
			// clear all children of container
			while (this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
		}
	}
}