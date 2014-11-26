package com.transcendss.transcore.sld.models.components
{
	
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.transcore.events.ElementEvent;
	import com.transcendss.transcore.util.Converter;
	import com.transcendss.transcore.util.PDFUtil;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.List;
	import spark.components.TextInput;
	
	
	public class Element extends Sprite
	{
		private var elementArray:ArrayCollection;
		private var elementName:String;
		public var elementDesc:String;
		public var elementID:Number;
		private var elementScale:Number;
		private var elementDetAC:ArrayCollection;
		public var elementSpacing:int = 36;
		public var elementBarHeight:int = 30;
		private var elementSettings:ArrayCollection;
		private var elementColor:uint =0xFFFFFF;
		private var elementColorStr:String ="0xFFFFFF";
		private var labelColor:uint =0x000000;
		private var labelColorStr:String ="0x000000";
		private var elementYOffset:int ;
		private var txtSize:int = 13;
		private var txtFont:String = "Arial";
		private var dispatcher:Dispatcher= new Dispatcher();
		public var curRoute:Route;
		
		public var isRange:Boolean;
		public var domain:Array;
		private var ElementY:int;
		public var attrDropDown:List = new List();
		private var elemDDSource:Array;
		public var attrTextBox:TextInput = new TextInput();
		public var attrTextBoxBtn:Button = new Button();
		private var elementIDColl:Array;
		private var settingsElemBarHeight:Number;
		private var labelLayer:Group;
		
		private var offsetValue:Number;
		
		[Bindable]
		private var valArray:Array = new Array();
		public function Element(labelLayer:Group)
		{
			clearContainer();
			elementIDColl = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.dataElementValues;
			settingsElemBarHeight=FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.elementBarHeight;
			if (settingsElemBarHeight != 0 && settingsElemBarHeight>elementBarHeight)
			{
				elementBarHeight = settingsElemBarHeight;
			}
			elementSpacing = elementBarHeight*2;
			elementYOffset= elementSpacing;
			this.labelLayer = labelLayer;
			//this.height = 40;
		}
		
		public function getElements(route:Route = null):void
		{
			var event:ElementEvent;
			
			//set the y offset for the first element
			for (var i:int = 0; i< elementIDColl.length ;i++)
			{
				event = new ElementEvent(ElementEvent.ELEMENT_REQUEST);
				FlexGlobals.topLevelApplication.incrementEventStack();
				event.serviceURL = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.serviceURL + "ElementInfo/"+elementIDColl[i]+"/"+route.routeName+"/"+route.beginMi +"/"+ route.endMi;
				event.elementType = String(elementIDColl[i]);
				event.routeName = route.routeName;
				event.routeFullName = route.routeFullName;
				event.begMile = route.beginMi ;
				event.endMile= route.endMi ;
				event.eventLayerID = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.getBarElemEventLayerID(elementIDColl[i]);
				dispatcher.dispatchEvent(event);
			}
			
			
		}
		
		public function draw(elementArrayC:ArrayCollection, diagramHgt:Number, diagramWidth:Number,route:Route = null, scale:Number = .5, offsetVal:Number=508):void
		{
			clearContainer();  // must clear to draw/redraw
			valArray = [];
			var elemBegMi:Number;
			var elemEndMi:Number;
			var elemRteName:String;
			var elemValue:String;
			
			
			offsetValue = offsetVal;
			curRoute = route;
			elementScale = scale;
			elementArray = elementArrayC;
			//foreach element section extract info and draw the element section 
			elementID = new Number(String(elementArray.getItemAt(0).ID));
			elementName = String(elementArray.getItemAt(0).ATT_NAME);
			elementDetAC = elementArray.getItemAt(0).DATA is ArrayCollection ? elementArray.getItemAt(0).DATA : new ArrayCollection(elementArray.getItemAt(0).DATA);
			//elementDetAC = new ArrayCollection(elementArray.getItemAt(0).DATA);
			elementSettings = new ArrayCollection(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.dataElementDetails);
			var attrArray:Array =  elementSettings.source;
			
			var elementDef:Object =  FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.getBarElemDef(elementID);
			
			
			for(var i:int =0; i < elementDetAC.length; i++)
			{
				
				elemBegMi = Math.max(new Number(String(elementDetAC.getItemAt(i)[elementDef.FromMeasureColumn])),route.beginMi);
				elemEndMi = Math.min(new Number(String(elementDetAC.getItemAt(i)[elementDef.ToMeasureColumn])),route.endMi);
				elemRteName = String(elementDetAC.getItemAt(i)[elementDef.RouteIDColumn]);
				elemValue = String(elementDetAC.getItemAt(i)[elementDef.ValueColumn]);
				
				getElementSettings(elemValue);
				
				var elemSec:ElementSection = new ElementSection(elementName, elementDesc, elementID, 
									Number(elementDetAC.getItemAt(i)[elementDef.EventIdFieldName]), elemBegMi, elemEndMi, elemValue, 
									elementBarHeight, elementYOffset, scale, curRoute, offsetValue, diagramHgt, isRange, txtSize, txtFont, 
									this.elementColor, this.labelColor);
				//printFieldsToConsole(elemBegMi, elemEndMi, elemValue);
				addChild(elemSec);
				
			}
			
			if(attrArray !=null && attrArray.length>0 && !isRange )//do this only if the current element has domain
			{
				for(var j:int =0; j<attrArray.length;j++)
				{
					if (attrArray[j].ID == elementID)
						valArray.push(attrArray[j].Value);
				}
				valArray.sort();
				elemDDSource =valArray;
				attrDropDown.dataProvider = new ArrayCollection(valArray);
				
			}
			
			attrDropDown.x = 0;
			attrDropDown.y = elementYOffset-1;
			attrDropDown.width = 100;
			attrDropDown.selectedIndex = 0;
			attrDropDown.height = elementBarHeight-1;
			
			attrTextBox.x =0;
			attrTextBox.y = elementYOffset-1;
			attrTextBox.width = 100;
			attrTextBox.height = 40;
			attrTextBoxBtn.width =100;
			attrTextBoxBtn.label = "Save";
			attrTextBoxBtn.height = 40;
			attrTextBoxBtn.y = elementYOffset-1;
			
			
			var text:TextField = new TextField();
			var txtFormat:TextFormat = new TextFormat(); 
			txtFormat.font = txtFont; 
			txtFormat.size = txtSize;
			txtFormat.letterSpacing = 2;
			text.autoSize = TextFieldAutoSize.LEFT;
			text.text = elementName;
			text.x = 0;
			text.y = elementYOffset-20;
			text.name = "label";
			text.setTextFormat(txtFormat); 
			if(!elementDetAC || !(elementDetAC.length>0))
				text.visible = false;
			addChild(text);

			
		}
		
		
		
		
		private function getElementSettings(elemValue:String):void{
			var i:int;
			var tempOffset:int ;
			for (i=0; i <elementSettings.length;i++)
			{
				
				if (String(elementSettings[i].Value) != "")
				{
					if (String(elementSettings[i].ID) == String(elementID) && String(elementSettings[i].Value) == String(elemValue))
					{
						this.isRange = elementSettings[i].isRange=="true";
						elementColorStr = String(elementSettings[i].Color);
						elementColor = new uint(elementColorStr);
						elementDesc = String(elementSettings[i].Description);

						tempOffset= new int(String(elementSettings[i].Order));
						elementYOffset  = (elementSpacing * tempOffset + 10 * tempOffset )+ 25;
						labelColorStr = String(elementSettings[i].TextColor);
						labelColor = new uint(labelColorStr);
						break;
					}
				}
				else
				{
					var rangeArr:Array = String(elementSettings[i].Range).split("-")
					var rangeBegin:Number = new Number( rangeArr[0]);
					var rangeEnd:Number = new Number(rangeArr[1]);
					var elemValNum:Number = new Number(String(elemValue));
					if (String(elementSettings[i].ID) == String(elementID) && (elemValNum >= rangeBegin) && (elemValNum <= rangeEnd) )
					{
						this.isRange = elementSettings[i].isRange=="true";
						elementColorStr = String(elementSettings[i].Color);
						elementColor = new uint(elementColorStr);
						elementDesc = String(elementSettings[i].Description);
						tempOffset= new int(String(elementSettings[i].Order));
						elementYOffset  = elementSpacing * tempOffset + 10 * tempOffset +25;
						labelColorStr = String(elementSettings[i].TextColor);
						labelColor = new uint(labelColorStr);
						break;
					}
					
				}
			}
		}
		
		public function drawElementToPDF(pdfU:PDFUtil, elementDetails:ArrayCollection, route:Route, startXPx:Number,startYPx:Number, maxPixelsWide:Number,scale:Number = .5):void
		{
			curRoute = route;
			elementScale = scale;
			elementBarHeight = 15;
			//foreach element section extract info and draw the element section 
			elementID = new Number(String(elementDetails.getItemAt(0).ID));
			elementDetAC = new ArrayCollection(elementDetails.getItemAt(0).DATA);
			elementSettings = new ArrayCollection(FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.dataElementDetails);
			
			elementDetAC.filterFunction = filterByBegEndmile;
			elementDetAC.refresh();
			
			if (elementDetAC.length > 0)
			{
				var secBegMilePx:Number =0 ;
				var secMidPx:Number;
				var bValue:String	=String(elementDetAC.getItemAt(0).ELEM_VALUE);
				var elementWidth:Number;
				for(var i:int =0; i < elementDetAC.length; i++)
				{
					
					var elemValue:String = String(elementDetAC.getItemAt(i).ELEM_VALUE);
					var elemBegMi:Number = Math.max(route.beginMi, new Number(String(elementDetAC.getItemAt(i).REFPT)));
					var elemEndMi:Number = Math.min(route.endMi, new Number(String(elementDetAC.getItemAt(i).ENDREFPT)));
					startXPx =  Converter.scaleMileToPixel(Math.abs(route.beginMi-elemBegMi), elementScale);
					
					if(i==0 )
					{
						secBegMilePx = startXPx;
						getElementSettings(elemValue);
					}
					if( i!=0 && bValue != elemValue)
						getElementSettings(elemValue);
					
					elementWidth = Math.min(maxPixelsWide-startXPx, Converter.scaleMileToPixel(Math.abs(elemEndMi-elemBegMi), elementScale));
					
					pdfU.drawRectToPDF(startXPx, startYPx+ elementYOffset/2,elementWidth,elementBarHeight ,.01,elementColorStr, elementColorStr);
					
					if (i!=0 && bValue != elemValue || i+1 == elementDetAC.length)
					{
						secMidPx  = secBegMilePx + ( ( (startXPx +elementWidth) -secBegMilePx)/2);
						pdfU.drawTextToPDF(txtFont,11, bValue,secMidPx, startYPx+ elementYOffset/2-20 , 0, labelColorStr);
						secBegMilePx = startXPx;
					}
					bValue = elemValue;
					
				}
				
			}	
		}
		
		
		
		private function filterByBegEndmile(obj:Object):Boolean{
			
			var bgP:Number = new Number(String(obj.REFPT));
			var endP:Number = new Number(String(obj.ENDREFPT));
			
			return ((bgP>=curRoute.beginMi && bgP<=curRoute.endMi) || (endP >=curRoute.beginMi && endP <=curRoute.endMi));
		}
		public function clearContainer():void{
			
			// clear all children of container
			while (this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
		}
		
		
		
		
		public function get eName():String
		{
			return elementName;
		}
		public function set eName(name:String):void
		{
			elementName = name;
		}
		
		public function get ID():Number
		{
			return elementID;
		}
		
		public function get elementIDNo():Number
		{
			return elementIDColl.length;
		}
		
		public function set ID(id:Number):void
		{
			elementID = id;
		}
		
		public function get elements():ArrayCollection
		{
			return elementDetAC;
		}
		public function set elements(e:ArrayCollection):void
		{
			elementDetAC = e;
		}
		
		private function printFieldsToConsole(elemBegMile:Number, elemEndMile:Number, elemValue:String):void
		{
			trace("elementName: " + this.elementName + ", elementDesc: " + this.elementDesc + ", elementID: " + this.elementID.toString());
			trace("elemBegMile: " + elemBegMile.toString() + ", elemEndMile: " + elemEndMile.toString(), ", elemValue: " + elemValue);
			trace("elementBarHeight: " + this.elementBarHeight.toString() + ", elementYOffset: " + this.elementYOffset.toString() + ", elementScale: " + this.elementScale.toString() + ", offsetValue: " + this.offsetValue.toString());
		}
	}
}