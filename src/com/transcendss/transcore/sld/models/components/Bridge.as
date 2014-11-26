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
	
	public class Bridge extends Sprite
	{
		// bridge struct type
		public static const TWOLANE:int = 1;
		public static const FOURLANE:int = 2;
		// bridge dir type
		public static const ONBRIDGE:int = 1;
		public static const OVERBRIDGE:int = 2;
		public static const UNDERBRIDGE:int = 3;
		
		private var bridgeType:int;
		private var bridgeLanes:int;
		
		private var bridgeWidth:int = 20;
		private var bridgeHeight:int = 40;
		private var bridgeLenPx:Number = 0;
		private var bridgeID:Number;
		private var bridgeLabels:Sprite;
		
		private var brdgLineColl:ArrayCollection = new ArrayCollection();
		private var routeName:String;
		private var beginMile:Number;
		private var endMile:Number;
		private var milePoint:Number;
		private var brdgBeginMile:Number;
		private var brdgEndMile:Number;
		private var featureName:String;
		private var coLocStr:String;
		private var dispatcher:Dispatcher = new Dispatcher();
		private var featureLength:Number;
		private var clusterPoint:Number;
		private var clusterLength:Number;
		//private var fLenUnits:String;
		
		private var brdgArray:Array;
		//private var brdgLableArray:Array;
		private var featureConst:String;
		private var rteFullName:String="";
		
		public function Bridge(ftConst:String,rteName:String, rteBeg:Number, rteEnd:Number, rteFullNm:String="")
		{
			super();
			clearContainer();
			
			bridgeLabels = new Sprite();
			name= "BRIDGE";
			beginMile=rteBeg;
			endMile=rteEnd;
			routeName = rteName;
			rteFullName = rteFullNm;
			featureConst = ftConst;
			brdgArray = /* bridges */ [];
		}
		public function getBridges():void{
		
			//call service and obtain array of countylines
			var ftEvent:FeatureEvent = new FeatureEvent( FeatureEvent.FEATURE_REQUEST,featureConst);
			ftEvent.routeName = routeName;
			ftEvent.routeFullName = rteFullName;
			ftEvent.begMile = beginMile;
			ftEvent.endMile = endMile;
			ftEvent.serviceURL = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL +"XingFeatures/"+featureConst+"/"+routeName+"/"+beginMile+"/"+endMile;
			dispatcher.dispatchEvent(ftEvent);
		
		}
		public function draw(ac:ArrayCollection, diagramScale:Number, diagramHeight:Number,rteBeginMi:Number,type:int=1,numLanes:int=1,cluster:Boolean=false):void
		{
			clearContainer();  // must clear to draw/redraw
			brdgArray = []; // clear bridge array
			
			var i:int;
			bridgeType = type;
			bridgeLanes = numLanes;
			brdgLineColl = ac;
			
			// store
			for(i=0; i < brdgLineColl.length; i++)
			{
				// store values into bridge array
				bridgeID = new Number(String(brdgLineColl.getItemAt(i).ID));
				milePoint = new Number(String(brdgLineColl.getItemAt(i).REFPT));
				featureName = String(brdgLineColl.getItemAt(i).FEATURE_NAME);
				featureLength = Converter.meterToMiles(new Number(String(brdgLineColl.getItemAt(i).FEATURE_LENGTH)));
				brdgBeginMile = milePoint - (featureLength/2);
				brdgEndMile = brdgBeginMile + featureLength;
				brdgArray.push({id:null, parentId:null,coLoc:null,bID:bridgeID,atMile: milePoint, begMile: brdgBeginMile, endMile: brdgEndMile, name: featureName, length: featureLength, clusterAtMile: 0, clusterLength: 0});
			}
			// sort by the begin mile of each bridge
//			brdgArray.sortOn("begMile", Array.NUMERIC);
			
			if(brdgArray.length > 0)
			{
				// process
				if(cluster){
					//cluster bridges
					brdgArray = processBridgesByScale(diagramScale);
				}
	
				// draw 
				for(i=0; i < brdgArray.length; i++)
				{
					if (brdgArray[i].parentId != null && cluster) continue; // print single and clustered bridges
					
					milePoint = new Number(brdgArray[i].atMile);
					featureName = String(brdgArray[i].name);
					coLocStr = String(brdgArray[i].coLoc);
					featureLength = new Number(brdgArray[i].length);
					bridgeID = new Number(brdgArray[i].bID);
//					brdgBeginMile = new Number(brdgArray[i].begMile);
//					brdgEndMile = new Number(brdgArray[i].endMile);
					clusterPoint = new Number(brdgArray[i].clusterAtMile);
					clusterLength = new Number(brdgArray[i].clusterLength);
					drawBridge(Converter.scaleMileToPixel(milePoint-rteBeginMi,diagramScale), diagramScale, diagramHeight, featureName, coLocStr, featureLength, clusterPoint, clusterLength,bridgeID);
				}
			}
		}

		
		public function drawBridge(atPixel:Number, diagramScale:Number, diagramHeight:Number, fName:String,  coLabel:String, bLen:Number, cPt:Number, cLen:Number, bID:Number, xAngle:Number=90):void{
			graphics.beginFill(0xffffff,1);
			var brdgLen:Number;
			var bridgeSprite:Tippable = new Tippable(Tippable.SLD);
			var bridgeShp:Shape = new Shape();
			var path:GraphicsPath;	
			var drawing:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
			var vCmds:Vector.<int> = new Vector.<int>();
			var vCoords:Vector.<Number> = new Vector.<Number>();
			
			var tooltip:TextField = new TextField();
			tooltip.text = fName;
			bridgeSprite.name = String(bID);
			bridgeSprite.tipText = fName;
	
			// convert and scale bridge length
			if (cLen > 0){
				// clustered bridges use a combined/clustered length
				brdgLen = Converter.scaleMileToPixel(cLen,diagramScale);
				// use cluster center pt.
				atPixel = Converter.scaleMileToPixel(cPt,diagramScale);
			} 
			else brdgLen = Converter.scaleMileToPixel(bLen,diagramScale);
			

			// set bridge attributes			
			if(bridgeType == Bridge.ONBRIDGE){
				xAngle = 90;
				bridgeLenPx = bridgeHeight = brdgLen;
			} 
			else
			{
				xAngle = 0;
				bridgeLenPx = bridgeWidth = brdgLen;
			}			
			
			//add the 2 sides of bridge shape
			
			var leftX1:Number = atPixel - (bridgeWidth/2);
			var leftY1:Number = (diagramHeight/2) - (bridgeHeight/2);
			var leftX2:Number = leftX1;
			var leftY2:Number = leftY1 + bridgeHeight;
			
			var rightX1:Number = leftX1 + bridgeWidth;
			var rightY1:Number = leftY1;
			var rightX2:Number = leftX2 + bridgeWidth;
			var rightY2:Number = leftY2;
			
			vCmds.push(1,2,2,2,1,2,2,2);
			vCoords.push(
				leftX1-3, leftY1-4,
				leftX1, leftY1, 
				leftX2, leftY2, 
				leftX1-3,leftY2+4,
				rightX1+3, rightY1-4,
				rightX1, rightY1, 
				rightX2, rightY2,
				rightX1+3, rightY2+4);
			
			bridgeShp.graphics.lineStyle(2,0xA54200,1,true);
			path = new GraphicsPath(vCmds,vCoords);
			drawing.push(path);
			//draw rail and sleeper lines
			bridgeShp.graphics.drawGraphicsData(drawing);				
			bridgeShp = Graphics.addGlow(bridgeShp,0xdfdfdf,0.4);

			
			bridgeShp.graphics.lineStyle(1,0x0,0);
			bridgeShp.graphics.beginFill(0xffffff,0);
			bridgeShp.graphics.drawRect(leftX1-7, leftY1-8,bridgeWidth+14,bridgeHeight+16);
			bridgeShp.graphics.endFill();			
			
			// call util to rotate sprite at its xing point
			var m:Matrix = bridgeShp.transform.matrix;
			FlexMatrixTransformer.rotateAroundInternalPoint(m, atPixel, (diagramHeight/2), xAngle);
			bridgeShp.transform.matrix = m;
			bridgeSprite.addChild(bridgeShp);  // add shape to sprite
			// call to label cluster - if label is not null
			if(coLabel != "null")
			{
				// create and add label to sprite
				bridgeSprite.addChild(drawClusterLabel(coLabel,atPixel,(diagramHeight/2)));
			}
			bridgeSprite.buttonMode = true;
			bridgeSprite.useHandCursor = true;
			bridgeSprite.addEventListener(MouseEvent.CLICK,onBridgeClick);
			addChild(bridgeSprite);
		}
		
		private function onBridgeClick(event:MouseEvent):void{
			var clickX:Number = event.target.mouseX;
			var bridgeSprite:Sprite = event.target as Sprite;
			
			var name:String = bridgeSprite.name;
//			var milePoint:Number = Converter.scalePixelToMile(clickX,elementScale) + curRoute.beginMi ;
//			//			getAttributes(id, milePoint);
//			var attrEvent:AttributeEvent = new AttributeEvent(AttributeEvent.ATTRIBUTE_REQUEST, milePoint,null,elementYOffset-1);
//			attrEvent.serviceURL = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL + "Attributes/"+id+"/"+curRoute.routeName+"/"+milePoint;
//			dispatcher.dispatchEvent(attrEvent);
		}
		
		private function processBridgesByScale(diagramScale:Number):Array{

			var scaleDistFactor:Number = getClusterDistance(diagramScale);
			var typeArray:Array = brdgArray;
			var minBrdgMi:Number;
			var maxBrddMi:Number;
			
			if (scaleDistFactor <= 0) return typeArray;
			
			//set first cntr
			typeArray[0].id = 0;
			
			
			for (var i:int=1;i<typeArray.length;i++){
				var coLoc:int = 0;
				typeArray[i].id = i; // set cntr
				var pIdx:int = i-1;
				var nIdx:int = i +1;
				
				var pMile:Number = typeArray[pIdx].atMile;
				// get begin and end points of previous bridge
				var pBrdgLen:Number = typeArray[pIdx].length;// bridge length
				var pMileBegin:Number = typeArray[pIdx].begMile;
				var pMileEnd:Number = typeArray[pIdx].endMile;
				
				var cMile:Number = typeArray[i].atMile;
				// get begin and end points of current bridge
				var cBrdgLen:Number = typeArray[i].length;// bridge length
				var cMileBegin:Number = typeArray[i].begMile; 
				var cMileEnd:Number = typeArray[i].endMile;
							
				var distBWBridges:Number = cMileBegin - pMileEnd;
				
				if(distBWBridges <= scaleDistFactor)
				{
					typeArray[i].parentId = typeArray[i-1].id;  // set current 'parent id' to previous crossing 'id'
					
					//store min/max bridge miles
					minBrdgMi = (pMileBegin < cMileBegin)?pMileBegin:cMileBegin;
					maxBrddMi = (pMileEnd > cMileEnd)?pMileEnd:cMileEnd;
					
					coLoc++;
					
					for (var j:int=i+1;j<typeArray.length;j++){
						// look to next item
						
						var nMile:Number = typeArray[j].atMile;
						// calc to get begin and end points of next bridge
						var nBrdgLen:Number = typeArray[j].length; // bridge length
						var nMiBegin:Number = typeArray[j].begMile; 
						var nMiEnd:Number = typeArray[j].endMile; 
						
						var distBWChildBridges:Number = nMiBegin - cMileEnd;
						
						if(distBWChildBridges <= scaleDistFactor){
							typeArray[j].id = j; // set cntr
							typeArray[j].parentId = typeArray[i].parentId;  // set next 'parent id' to current 'parent id'
							
							//store min/max bridge miles
							minBrdgMi = (minBrdgMi < nMiBegin)?minBrdgMi:nMiBegin;
							maxBrddMi = (maxBrddMi > nMiEnd)?maxBrddMi:nMiEnd;
							i++;  // inc i
							coLoc++;
						}
						else break;
					}
					
					if (coLoc > 0){
						typeArray[pIdx].coLoc = coLoc+1;
						var clusterDist:Number = maxBrddMi - minBrdgMi;  //dist in miles
						typeArray[pIdx].clusterLength = clusterDist;
						typeArray[pIdx].clusterAtMile = minBrdgMi + (clusterDist/2);
					} 
				}
			}

			return typeArray;
		}		
		
		public function drawClusterLabel(coLabel:String,xPos:Number,yPos:Number):Sprite{
			// add coLo # symbol
			var bSprite:Sprite = new Sprite();
			if(coLabel != null)
			{
				//draw green circle
				var bShape:Shape = new Shape();
				bShape.graphics.beginFill(0x000080,0.70);
				if(coLabel.length == 1){
					bShape.graphics.drawCircle(xPos,yPos,10);	
				}
				else{
					bShape.graphics.drawEllipse(xPos-15,yPos-10,30,20);
				}
				bSprite.addChild(bShape);
				// create text
				var text:TextField = new TextField();
				text.text = coLabel;
				text.backgroundColor = 	0xFF0000;
				text.filters = [new GlowFilter(0xdfdfdf,0.6)];
				text.autoSize = TextFieldAutoSize.CENTER   
				text.selectable = false;
				text.mouseEnabled = false;
				text.x = xPos-(text.textWidth/2)-1;
				text.y = yPos-11;
				var txtFormat:TextFormat = new TextFormat(); 
				txtFormat.color = 0xFFFFFF; 
				txtFormat.font = "Arial";
				txtFormat.size = 15;
				txtFormat.bold = true;
				txtFormat.letterSpacing = 2;
				
				text.setTextFormat(txtFormat);
				bSprite.addChild(text);

				
			}
			return bSprite;
		}
		//ToDO fix with the new scale values
		private function getClusterDistance(scale:Number):Number{
			// todo: break out into settings
			if (scale < 5000) return 0;
			if (scale <= 10000) return 0.125;
			if (scale <= 50000) return 0.25;
			if (scale <= 75000) return 0.6;
			if (scale <= 100000) return 0.9;
			if (scale <= 250000) return 3;
			else return 5;
		}
		
		public function get labels():Sprite
		{
			return bridgeLabels;
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