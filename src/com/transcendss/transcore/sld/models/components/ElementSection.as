package com.transcendss.transcore.sld.models.components
{
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.transcore.events.AttributeEvent;
	import com.transcendss.transcore.events.ElementEditEvent;
	import com.transcendss.transcore.sld.models.managers.LRMManager;
	import com.transcendss.transcore.util.Converter;
	import com.transcendss.transcore.util.Tippable;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GraphicsPath;
	import flash.display.IGraphicsData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import mx.core.FlexGlobals;
	import mx.rpc.Responder;
	
	import spark.components.Label;
	
	public class ElementSection extends Tippable
	{
		public static const LONG_CLICK_TIME:int = 1000;
		public var scale:Number;
		public var curRoute:Route;
		public var diagramHgt:Number;
		public var begOffsetDistance:Number;
		
		public var secID:Number;
		public var secBegMile:Number;
		public var secEndMile:Number;
		public var value:String;
		
		
		public var elemHeight:Number;
		public var elemTypeID:Number;
		public var elemDesc:String;
		public var elemLbl:String;
		public var elemPlacementY:Number;
		public var isRange:Boolean = true;
		//		public var ddSource:Array = [];
		
		private var lastClick:Number;
		private var txtSize:int = 13;
		private var txtFont:String = "Arial";
		private var dispatcher:Dispatcher= new Dispatcher();
		private var secColor:uint =0xFFFFFF;
		private var secLblColor:uint =0x000000;
		private var elemLabelWidth:Number = 60;
		private var backgroundShp:Shape;
		private var lineWeight:int = 4;
		private var _x1:int;
		private var _y1:int;
		private var _x2:int;
		private var _y2:int;

		public function ElementSection(elemTypeLabel:String, elemDescP:String, elementTypeIDP:Number,elemeObjIDP:Number, elemBegMileP:Number,
									   elemEndMileP:Number, elemValueP:String, elemHieghtP:Number,elemPlacementYP:Number, scaleP:Number, 
									   curRouteP:Route,offsetDistance:Number, diagramHgtP:Number,isRangeP:Boolean=true, txtSizeP:Number=13, 
									   txtFontP:String="Arial", secColorP:uint=0xFFFFFF, secLblColorP:uint=0x000000)
		{
			super(Tippable.INVENTORY)
			elemLbl = elemTypeLabel;
			elemDesc = elemDescP;
			elemHeight= elemHieghtP;
			scale=scaleP;
			curRoute = curRouteP;
			secBegMile=elemBegMileP;
			secEndMile=elemEndMileP;
			diagramHgt=diagramHgtP;
			value=elemValueP;
			elemTypeID=elementTypeIDP;
			secID=elemeObjIDP;
			isRange=isRangeP;
			elemPlacementY = elemPlacementYP;
			begOffsetDistance=offsetDistance;
			txtSize = txtSizeP;
			txtFont = txtFontP;
			secColor = secColorP;
			secLblColor = secLblColorP;
			draw();
		}
		
		public function get y2():int
		{
			return _y2;
		}

		public function set y2(value:int):void
		{
			_y2 = value;
		}

		public function get x2():int
		{
			return _x2;
		}

		public function set x2(value:int):void
		{
			_x2 = value;
		}

		public function get y1():int
		{
			return _y1;
		}

		public function set y1(value:int):void
		{
			_y1 = value;
		}

		public function get x1():int
		{
			return _x1;
		}

		public function set x1(value:int):void
		{
			_x1 = value;
		}

		public function draw():void
		{
			var drawing:Vector.<IGraphicsData> = new Vector.<IGraphicsData>();
			
			//var elemComp:Tippable = new Tippable(Tippable.INVENTORY);
			var path:GraphicsPath;
			
			var distBegin:Number = Math.abs(secBegMile-curRoute.beginMi); 
			var distEnd:Number = Math.abs(secEndMile-curRoute.beginMi);
			x1 =Converter.scaleMileToPixel(distBegin,scale) + begOffsetDistance;
			y1 = elemPlacementY;
			x2 = Converter.scaleMileToPixel(distEnd,scale) + begOffsetDistance;
			y2 = elemPlacementY;
			
			//draw backgroud rect to act as border
			backgroundShp = new Shape();
			this.addChild(backgroundShp);
			
			//draw the element 
			var featureShp:Shape = new Shape();
			featureShp.graphics.beginFill(secColor);
			
			featureShp.graphics.drawPath(Vector.<int>([1,2,2,2]),
				Vector.<Number>([x1+1,y1,x2,y2, x2,y2 + elemHeight, x1+1, y1+elemHeight]));
			featureShp.graphics.endFill();
			this.tipText = elemLbl + " : " + value;
			addChild(featureShp);
			
			this.width = featureShp.width;
			this.height = featureShp.height ;
			this.name = elemTypeID + "_" + secID + "_"+secBegMile + "_" + secEndMile;
			
			// Add labels along the bar so they are visible as bar is scrolled
			var elemWidth:Number = this.width;
			
			//initialize to obtain width
			var lblX:Number=x1+10;
			
			//place labels every 800 px 
			while(lblX+ elemLabelWidth < x2)
			{
				addLabel(lblX);
				lblX += 800; 
			}
			//add event listner only if editing is enabled
			if(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.linearEditingSwitch)
			{
				this.addEventListener(MouseEvent.MOUSE_DOWN, processElementClick);
				this.addEventListener(MouseEvent.MOUSE_UP, processElementClick);
				this.buttonMode = true;
				this.useHandCursor = true;
			}
		}
		
		// Process a click event on the bar element, for single click and long click
		public function processElementClick(e:Event):void
		{
			if((e as MouseEvent).type === MouseEvent.MOUSE_DOWN)
				lastClick = getTimer();
			else
			{
				if(getTimer() - lastClick > LONG_CLICK_TIME)
					onElementLongClick(e as MouseEvent);
				else
					onElementClick(e as MouseEvent);
			}			
		}
		
		private function addLabel(x:Number):void
		{
			var lbl:TextField = new TextField();
			lbl.text = value;	
			lbl.textColor = this.secLblColor;
			lbl.cacheAsBitmap = true;
			lbl.mouseEnabled = false;
			lbl.width=elemLabelWidth;
			lbl.height = 20;
			lbl.y = Math.abs(elemPlacementY+2);
			lbl.x = x;
			this.addChild(lbl);
		}
		
		// Single click (or tap) handler
		private function onElementClick(event:MouseEvent):void{
			var clickX:Number = event.target.mouseX;
			var id:Number = this.secID;
			var eventX:int;
			var milePoint:Number = Converter.scalePixelToMile(clickX- begOffsetDistance,scale) + curRoute.beginMi ;
			var _delResp:Responder;
			
			eventX = event.stageX;
			
			// If the control key is on, this is a bar element merge operation, so send an event
			if(FlexGlobals.topLevelApplication.mergeInProgress)
			{
				var desc:String = FlexGlobals.topLevelApplication.elementsToMerge[0].elemDesc;
				
				if(this.elemDesc != desc)
				{
					FlexGlobals.topLevelApplication.TSSAlert("Merge in Progress...Please select an element from the " + desc + " bar");
					return;
				}

				if(!elementIsContiguous())
				{
					FlexGlobals.topLevelApplication.TSSAlert("This element is not contiguous...Please select an adjoining element");
					return;
				}					
				
				this.highlight();
				FlexGlobals.topLevelApplication.elementsToMerge.push(this);
				FlexGlobals.topLevelApplication.elementsToMerge.sortOn("secBegMile","secEndMile");

				// Display a finish merge prompt until the user clicks on it.  If yes, then the merge is done.  If no, then display
				// another prompt until yes.
				if(!FlexGlobals.topLevelApplication.finishMergePromptDisplayed)
				{
					_delResp = new Responder(finishMerge, fault);
					FlexGlobals.topLevelApplication.YesNoPrompt("Finish Merging?", "Element Merge", _delResp);
					FlexGlobals.topLevelApplication.finishMergePromptDisplayed = true;
				}
				
				function finishMerge(data:Object):void
				{
					FlexGlobals.topLevelApplication.finishMergePromptDisplayed = false;

					if(data)
					{
						// Make sure the merged elements are in order by begin milepoint and then end milepoint
						//FlexGlobals.topLevelApplication.elementsToMerge.sortOn("secBegMile","secEndMile");

						var editEvent:ElementEditEvent = new ElementEditEvent(ElementEditEvent.COMPLETE_ELEMENT_MERGE, milePoint);
						dispatcher.dispatchEvent(editEvent);
					}
				}

			}
			else
			{
				// If the element exists in the local db, use that record
				var barElement:BaseAsset = new BaseAsset();
				barElement = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getBarElementById(this.secID, this.elemDesc);
				if(barElement != null)
				{
					var elem:Object = new Object();
					elem["REFPT"] = barElement.invProperties.REFPT.value;
					elem["ENDREFPT"] = barElement.invProperties.ENDREFPT.value;
					elem["ID"] = barElement.invProperties.ID.value;
					elem["ELEM_VALUE"] = barElement.invProperties.ELEM_VALUE.value;
					elem["ELEM_DESC"] = barElement.invProperties.ELEM_DESC.value;
					elem["ROUTE"] = barElement.invProperties.ROUTE.value;
					elem["ROUTE_NAME"] = barElement.invProperties.ROUTE_NAME.value;
					elem["STATUS"] = barElement.invProperties.STATUS.value;
					FlexGlobals.topLevelApplication.showBarElementDetails(elem, milePoint, eventX, event.stageY);
				}
				
				// If it does not exist in the local db, get the element from the main db
				else
				{
					var attrEvent:AttributeEvent = new AttributeEvent(AttributeEvent.ATTRIBUTE_REQUEST, milePoint,null,event.stageY,eventX);
					attrEvent.attrType = String(this.elemTypeID);
					attrEvent.routeName = curRoute.routeName;
					attrEvent.attrid = this.secID;
					
					AttrObj(FlexGlobals.topLevelApplication.currAttrObj).attrType = String(elemTypeID);
					AttrObj(FlexGlobals.topLevelApplication.currAttrObj).Route_Name = curRoute.routeName;
					AttrObj(FlexGlobals.topLevelApplication.currAttrObj).RouteFullName = curRoute.routeFullName;
					AttrObj(FlexGlobals.topLevelApplication.currAttrObj).Clicked_Milepoint = milePoint;
					AttrObj(FlexGlobals.topLevelApplication.currAttrObj).route_Begin_Mile = curRoute.beginMi;
					AttrObj(FlexGlobals.topLevelApplication.currAttrObj).route_End_Mile = curRoute.endMi;
					
					attrEvent.serviceURL = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL + "Attributes/"+elemTypeID+"/"+curRoute.routeName+"/"+milePoint;
					dispatcher.dispatchEvent(attrEvent);
				}
			}
			
			function fault(data:Object):void
			{	
				FlexGlobals.topLevelApplication.TSSAlert("Error in Merging Elements.");
			}
		}

		// Check that a selected bar segment to be merged is contiguous with the others that have been selected
		private function elementIsContiguous():Boolean
		{
			var isContiguous:Boolean = false;
			var tmpArray:Array = FlexGlobals.topLevelApplication.elementsToMerge;
			for(var i:int=0; i<tmpArray.length; i++)
			{
				if(this.secBegMile == tmpArray[i].secEndMile || this.secEndMile == tmpArray[i].secBegMile)
				{
					isContiguous = true;
					break;
				}
			}
			return isContiguous;
		}
		
		// Long click (or tap) handler.  Currently, this is used for bar element merge operations.
		private function onElementLongClick(event:MouseEvent):void{
			if(FlexGlobals.topLevelApplication.mergeInProgress)
			{
				FlexGlobals.topLevelApplication.mergeInProgress = false;
				FlexGlobals.topLevelApplication.TSSAlert("Long Click detected--Merge in Progress canceled");
				return;
			}
			
			var clickX:Number = event.stageX;
			var clickY:Number = event.stageY;
			var milePoint:Number = Converter.scalePixelToMile(event.target.mouseX- begOffsetDistance,scale) + curRoute.beginMi ;
			var editEvent:ElementEditEvent = new ElementEditEvent(ElementEditEvent.EDIT_ELEMENT, milePoint, clickX, clickY, this);
			dispatcher.dispatchEvent(editEvent);
		}
		

//		private function getBitMap(label:String, bitMapName:String, bitMapHeight:Number):Bitmap
//		{
//			var spacer:Number = 0;
//			var txtLabel:TextField = new TextField();
//			//txtLabel.autoSize = TextFieldAutoSize.CENTER;
//			var mtrxPos:int= 2;
//			var bitMapWidth:int = 0;
//			txtLabel.text = label;
//			txtLabel.mouseEnabled = false;
//			txtLabel.selectable = false;
//			
//			var txtFormat:TextFormat = new TextFormat(); 
//			txtFormat.font = txtFont; 
//			txtFormat.size = txtSize;
//			txtFormat.bold = true;
//			txtFormat.letterSpacing = 1.5;
//			
//			txtFormat.color = secLblColor;	
//			txtLabel.setTextFormat(txtFormat); 
//			//txtLabel.backgroundColor = 0xffffcc;
//			
//			bitMapWidth = txtLabel.textWidth;
//			
//			var bmd:BitmapData = new BitmapData( bitMapWidth + 10, bitMapHeight);
//			
//			spacer = 2;
//			bmd.floodFill(0,0,0xffffcc);
//			bmd.draw(txtLabel, new Matrix(1,0,0,1,mtrxPos,0));
//			mtrxPos = mtrxPos +(txtLabel.textWidth + spacer);
//			
//			
//			var bm:Bitmap = new Bitmap(bmd,"auto",true);
//			
//			bm.name = bitMapName;
//			
//			return bm;
//		}
		
		public function highlight():void
		{
			backgroundShp.graphics.clear();
			backgroundShp.graphics.beginFill(0x00FF00);
			backgroundShp.graphics.drawPath(Vector.<int>([1,2,2,2]),
				Vector.<Number>([x1,y1-3,x2+3,y2-3, x2+3,y2 + elemHeight+3, x1, y1+elemHeight+3]));
			backgroundShp.graphics.endFill();
			//this.addChild(backgroundShp);
		}
		
		public function unhighlight():void
		{
			backgroundShp.graphics.clear();
			backgroundShp.graphics.beginFill(0xB0B0B0);
			backgroundShp.graphics.drawPath(Vector.<int>([1,2,2,2]),
				Vector.<Number>([x1,y1-1,x2+1,y2-1, x2+1,y2 + elemHeight+1, x1, y1+elemHeight+1]));
			backgroundShp.graphics.endFill();
			//this.addChild(backgroundShp);
		}

	}
}