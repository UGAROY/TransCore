package com.transcendss.transcore.sld.models
{
	
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.transcore.events.AttributeEvent;
	import com.transcendss.transcore.events.ElementEditEvent;
	import com.transcendss.transcore.events.ElementEvent;
	import com.transcendss.transcore.sld.models.components.AttrObj;
	import com.transcendss.transcore.sld.models.components.Element;
	import com.transcendss.transcore.sld.models.components.ElementSection;
	import com.transcendss.transcore.sld.models.components.GuideBar;
	import com.transcendss.transcore.sld.models.components.Route;
	import com.transcendss.transcore.util.Converter;
	import com.transcendss.transcore.util.PDFUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.List;
	import spark.components.SkinnablePopUpContainer;
	import spark.components.VGroup;
	import spark.events.IndexChangeEvent;
	
	public class InventoryDiagram extends UIComponent
	{
		private var diagramRoute:Route;
		private var diagramScale:Number;
		private var element:Element;
		private var elementColl:ArrayCollection = new ArrayCollection();
		private var labelArray:Array;
		public  var savedID:Number;
		public var savedElemSec:Route;
		public var savedVal:*;
		public var guideBar:GuideBar;
		
		private var gBarX:Number;
		[Bindable]
		private var attrTextBoxVal:*;
		private var pop:SkinnablePopUpContainer=new SkinnablePopUpContainer();
		private var attrEvent:AttributeEvent;
		private var gbBbuttonMode:Boolean=false;
		private var gbUseHandCursor:Boolean = false;
		private var elementCount:Number=0;
		private var dispatcher:Dispatcher = new Dispatcher();
		private var elementLoadCount:int = 0;
		private var labelLayer:Group;
		private var offsetValue:Number;
		private var elementToEdit:ElementSection;
		
		public function InventoryDiagram(route:Route=null, scale:Number=50000, labelLayer:Group=null ,offsetVal:Number = 508)
		{
			super();
			offsetValue = offsetVal;
			name = "de_graphic";
			diagramScale = scale;
			guideBar = new GuideBar("INV");
			if(route == null){
				diagramRoute = new Route("no_rte",0,100);
			} 
			else{
				//init countyLine
				diagramRoute = route;
				//				draw();
				this.labelLayer = labelLayer;
			}
		}
		
		public function draw(scale:Number=50000,route:Route=null,fromStorage:Boolean=false,guideBarX:Number = 1500/2, buttonMd:Boolean=false, useHandCrsr:Boolean = false):void
		{
			
			labelArray = [];
			clearContainer();
			attrEvent= null;
			gBarX=guideBarX;
			gbBbuttonMode = buttonMd;
			gbUseHandCursor = useHandCrsr;
			elementCount = 0;
			if(route != null) diagramRoute = route; // update route if not null
			diagramScale = scale;
			FlexGlobals.topLevelApplication.GlobalComponents.invDiagram = this;
			//elementColl = new ArrayCollection();
			
			
			
			if(!fromStorage)
			{
				element = new Element(this.labelLayer);
				if((FlexGlobals.topLevelApplication.hasOwnProperty("connected") &&  FlexGlobals.topLevelApplication.connected) || !FlexGlobals.topLevelApplication.hasOwnProperty("connected")) 
					element.getElements(diagramRoute);	
				this.height =0;
				
			}
			else
				drawElemsfrmStore();
			
			
		}
		

		public function drawElemsFrmSrvceResFaultHandler():void
		{
			elementLoadCount++;
			var app:Object = FlexGlobals.topLevelApplication;
			// Draw the roadway lanes for the Stick Panel
			
			//if (elementLoadCount == app.GlobalComponents.ConfigManager.dataElementValues.length)
				app.decrementEventStack();	
		}
		
		
		//draws elements once the service call returns obtaining all the element info
		public function drawElemsFrmSrvceRes(arrayCollection:ArrayCollection=null, drawnot:Boolean=false):void
		{
			try
			{
			if(arrayCollection[0] != null && arrayCollection[0].ATT_NAME != "" && 
				arrayCollection[0].DATA != null && arrayCollection[0].DATA.length > 0)
				arrayCollection = mergeLiveAndLocalBarElements(arrayCollection);
			
			
			element = new Element(this.labelLayer);
			
			// Draw the roadway lanes for the Stick Panel
			if(arrayCollection != null && arrayCollection.length > 0 && arrayCollection[0].ATT_NAME == FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.lanesFieldValue)
			{
				dispatcher.dispatchEvent(new ElementEvent(ElementEvent.DRAW_ROADWAY_LANES, arrayCollection, this.diagramScale));
			}
			
			drawElement(arrayCollection, -1,-1,drawnot);
			elementCount++;
			drawGuideBar();
			if(elementCount==element.elementIDNo)
				dispatcher.dispatchEvent(new ElementEvent(ElementEvent.ELEMENT_LOAD_COMPLETED));
			
			var app:Object = FlexGlobals.topLevelApplication;
			
			elementLoadCount++;
			//if (elementLoadCount == app.GlobalComponents.ConfigManager.dataElementValues.length)
				app.decrementEventStack();	
			}
			catch(e:Error)
			{
				drawElemsFrmSrvceResFaultHandler();
			}
		}
		
		public function mergeLiveAndLocalBarElements(ac:ArrayCollection):ArrayCollection
		{
			var type:String = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getTypeFromAttName(ac[0].ATT_NAME);
			var elemArray:Array = new Array();
			for each(var obj:Object in ac[0].DATA)
			{
				elemArray.push(obj);
			}
			
			var elemArray2:ArrayCollection = new ArrayCollection();
			
			elemArray2 = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getBarElementsByRoute(type, this.diagramRoute);

			if(elemArray2.length == 0)
				elemArray2 = new ArrayCollection(elemArray);
			else
			{
				for (var i:int=0; i<elemArray.length; i++)
				{
					var good:Boolean = true;
					for(var j:int=0; j<elemArray2.length; j++)
					{
						if (elemArray[i].ID == elemArray2[j].ID)
						{
							good = false;
							// Also, if the one in the local db is RETIRED, then remove it from the array
							if(elemArray2[j].STATUS == "RETIRED")
							{
								elemArray2.removeItemAt(j);
								j -= 1;
							}
							break;
						}
					}
					
					if (good)
						elemArray2.addItem(elemArray[i]);
				}
			}
			var arr:ArrayCollection = new ArrayCollection();
			arr.addAll(elemArray2);
			ac[0].DATA = arr;
			return ac;
		}

		//incase of scale change only draws from store
		private function drawElemsfrmStore():void
		{	
			height =0;
			
			for(var i:int =0; i< elementColl.length ; i++)
			{
				drawElement(elementColl[i].AC, -1,i);
				elementCount++;
				// Draw the roadway lanes for the Stick Panel
				if(elementColl[i].AC != null && elementColl[i].AC.length > 0 && elementColl[i].AC[0].ATT_NAME == FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.lanesFieldValue)
				{
					dispatcher.dispatchEvent(new ElementEvent(ElementEvent.DRAW_ROADWAY_LANES, elementColl[i].AC, this.diagramScale));
				}
				
			}
			
			drawGuideBar();
			var app:Object = FlexGlobals.topLevelApplication;
			
			//if (elementLoadCount == app.GlobalComponents.ConfigManager.dataElementValues.length)
			app.decrementEventStack();	
			//dispatcher.dispatchEvent(new ElementEvent(ElementEvent.ELEMENT_LOAD_COMPLETED));
		}
		
		// Draw the roadway lanes from the StickDiagram draw if drawing from storage - so the clearContainer call happens before
		// this method is called.
		public function drawRoadwayLanesFromStorage():void
		{
			// Draw the roadway lanes for the Stick Panel
			for(var j:int=0; j<elementColl.length; j++)
			{
				if(elementColl[j].AC[0] != null && elementColl[j].AC[0].ATT_NAME == FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.lanesFieldValue)
				{
					dispatcher.dispatchEvent(new ElementEvent(ElementEvent.DRAW_ROADWAY_LANES, elementColl[j].AC, this.diagramScale));
					break;
				}
			}
		}
		
		//draw elements to PDF
		public function drawElemsToPDF(pdfU:PDFUtil,begMile:Number, endMile:Number, startX:Number, startY:Number, maxPixelsWide:Number ):void
		{	
			var elemt:Element;
			for(var i:int =0; i< elementColl.length ; i++)
			{
				elemt = new Element(this.labelLayer);
				elemt.drawElementToPDF(pdfU,elementColl[i].AC, new Route(this.diagramRoute.routeName,begMile,endMile) , startX, startY,maxPixelsWide, diagramScale);
			}
		}
		
		//called once the element attribute change is posted to DB and success result is obtained. 
		//Only the element updated will be redrawn
		public function drawSingleElemfrmStore():void
		{
			var sID:Number = new  Number(AttrObj(FlexGlobals.topLevelApplication.currAttrObj).attrType);
			var rName:String = AttrObj(FlexGlobals.topLevelApplication.currAttrObj).Route_Name;
			var rFName:String = AttrObj(FlexGlobals.topLevelApplication.currAttrObj).RouteFullName;
			var mp:Number = AttrObj(FlexGlobals.topLevelApplication.currAttrObj).Clicked_Milepoint;
			var elVal:* = AttrObj(FlexGlobals.topLevelApplication.currAttrObj).Value;
			if (sID != -1)
			{
				
				for(var i:int=0; i<elementColl.length;i++)
				{
					if (elementColl[i].elementObj.ID == sID)
					{
						removeChildRelatedToSingleElem();
						
						for(var j:int=0; j<elementColl[i].AC[0].DATA.length;j++)
						{
							if ((elementColl[i].AC[0].DATA[j].ROUTE_NAME == rName || elementColl[i].AC[0].DATA[j].ROUTE == rFName.replace('-','')) && 
								elementColl[i].AC[0].DATA[j].REFPT <= mp&& 
								elementColl[i].AC[0].DATA[j].ENDREFPT >= mp)
							{
								elementColl[i].AC[0].DATA[j].ELEM_VALUE = elVal;
								break;
							}
						}
						drawElement(elementColl[i].AC,sID, i);
						drawGuideBar();
					}
				}
			}
			
			
		}
		
		public function drawElement(AC:ArrayCollection, ID:Number, elementCollIndex:int, drawnot:Boolean=false):void{
			var elemt:Element = new Element(this.labelLayer);
			if(AC.length>0){
				elemt.draw(AC,height,width,diagramRoute,diagramScale, offsetValue);
				
				if( ID == -1)
					ID= elemt.elementID;
				elemt.name = "Element" + ID;
				
				if (!drawnot) 
					addChild(elemt);
				elemt.x = 0;
				if (!drawnot) 
					labelArray.push(elemt.getChildByName("label"));
				if (!drawnot) 
					this.width = elemt.width;
				
				if(elementCollIndex!=-1)
				{
					elementColl[elementCollIndex].elementObj = elemt;
					
				}
				else
				{
					elementColl.addItem({elementObj:elemt, AC:AC});
					
				}
				
				if (!drawnot)
				{
					height = height +elemt.height + (elemt.elementSpacing-elemt.elementBarHeight) +15;
					//this.parent.parent.height = height;
				}
			}
			
		}
		
		//draws guidebar in the invdiagram
		public function drawGuideBar():void{
			if (FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.guideBarSwitch)
			{
				if (this.getChildByName("GUIDE_BAR_SPRITE") == null)
				{
					guideBar.draw(gBarX,this.height,width,90,gbBbuttonMode,gbUseHandCursor);
					guideBar.name = "GUIDE_BAR_SPRITE";
					guideBar.visible = true;
					this.addChild(guideBar);
					if (!FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.guideBarSwitch)
						guideBar.visible = false;
				}
				else
				{
					//					this.setChildIndex(this.getChildByName("GUIDE_BAR_SPRITE"),this.numChildren-1);
					//					this.getChildByName("GUIDE_BAR_SPRITE").height = this.height;
					
					if (FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.guideBarSwitch)
					{
						guideBar.graphics.clear();
						guideBar.draw(gBarX,this.height,width,90,gbBbuttonMode,gbUseHandCursor);
						guideBar.name = "GUIDE_BAR_SPRITE";
						guideBar.visible = true;
						
						this.setChildIndex(this.getChildByName("GUIDE_BAR_SPRITE"),this.numChildren-1);
						this.getChildByName("GUIDE_BAR_SPRITE").height = this.height;
					}
				}
			}
		}
		
		//when a element is clicked go through the element collection and find the element clicked by comparing ID
		//If the attr drop down has empty data provider then the element has text box and button
		//set the 
		public function displayElementDrop(event:AttributeEvent, scale:Number):void{
			if(!FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.linearEditingSwitch)
				return;
			
			var elemTypeID:int=event.data.getItemAt(0).ID;
			AttrObj(FlexGlobals.topLevelApplication.currAttrObj).ID = event.data.getItemAt(0).DATA[0].ID;
			AttrObj(FlexGlobals.topLevelApplication.currAttrObj).Begin_Mile = event.data.getItemAt(0).DATA[0].REFPT;
			AttrObj(FlexGlobals.topLevelApplication.currAttrObj).End_Mile = event.data.getItemAt(0).DATA[0].ENDREFPT;
			
			var Value:* =event.data.getItemAt(0).DATA[0].ELEM_VALUE;
			//attrEvent = event;
			
			for(var i:int=0; i<elementColl.length;i++)
			{
				if (elementColl[i].elementObj.ID == elemTypeID)//same attr type
				{
					
					if (!elementColl[i].elementObj.isRange && elementColl[i].elementObj.attrDropDown.dataProvider.length>0)
					{
						elementColl[i].elementObj.attrDropDown.x = event.ClickX;
						elementColl[i].elementObj.attrDropDown.visible = true;
						List(elementColl[i].elementObj.attrDropDown).removeEventListener(IndexChangeEvent.CHANGE ,attrDrpDwnChange);
						for(var j:int=0;j< elementColl[i].elementObj.attrDropDown.dataProvider.length;j++)
						{
							if (Value == elementColl[i].elementObj.attrDropDown.dataProvider[j])
							{
								elementColl[i].elementObj.attrDropDown.selectedIndex=j;
							}
						}
						List(elementColl[i].elementObj.attrDropDown).addEventListener(IndexChangeEvent.CHANGE ,attrDrpDwnChange);
						elementColl[i].elementObj.attrDropDown.name = "ElemDropDown";
						
						pop.width=100;
						pop.height=150;
						pop.x=event.ClickX;
						pop.y=event.ClickY;
						var list:List=List(elementColl[i].elementObj.attrDropDown);
						var g:VGroup=new VGroup();
						list.width=100;
						list.height=150
						g.addElement(list);
						pop.addElement(g);
						pop.open(this,false);
					}
					else
					{
						
						elementColl[i].elementObj.attrTextBox.visible = true;
						elementColl[i].elementObj.attrTextBoxBtn.visible = true;
						elementColl[i].elementObj.attrTextBox.text = Value;
						elementColl[i].elementObj.attrTextBoxBtn.id= i;
						Button(elementColl[i].elementObj.attrTextBoxBtn).addEventListener(MouseEvent.CLICK, attrTextChange);
						
						elementColl[i].elementObj.attrTextBox.name = "ElemTextBox";
						elementColl[i].elementObj.attrTextBoxBtn.name = "ElemTextBoxBtn";
						
						var group:HGroup=new HGroup();
						
						group.addElement(elementColl[i].elementObj.attrTextBox);
						group.addElement(elementColl[i].elementObj.attrTextBoxBtn);
						
						pop.width=100;
						pop.height=20;
						pop.addElement(group);
						pop.x=event.ClickX;
						pop.y=event.ClickY;
						pop.open(this,false);
					}
				}
				else
				{
					elementColl[i].elementObj.attrDropDown.visible = false;
					elementColl[i].elementObj.attrTextBox.visible= false;
					elementColl[i].elementObj.attrTextBoxBtn.visible = false;
				}
			}
		}

		//when an element is clicked go through the element collection and find the element clicked by comparing ID
		//Display the element text box and button
		public function displayAttrInput(event:ElementEditEvent, scale:Number, isSplit:Boolean=false):void{
			if(!FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.linearEditingSwitch)
				return;
			
			this.elementToEdit = event.elem as ElementSection;
			
			var elemID:int=event.elem.elemTypeID;
			var elemDesc:String = event.elem.elemDesc;
			AttrObj(FlexGlobals.topLevelApplication.currAttrObj).ID = event.elem.secID;
			AttrObj(FlexGlobals.topLevelApplication.currAttrObj).Begin_Mile = event.elem.secBegMile;
			AttrObj(FlexGlobals.topLevelApplication.currAttrObj).End_Mile = event.elem.secEndMile;
			
			var Value:*;
			if(isSplit)
				Value = event.milepoint;
			else
				Value = event.elem.value;
			
			pop = new SkinnablePopUpContainer();
			
			// Display the attribute text in an input box
			for(var i:int=0; i<elementColl.length; i++)
			{
				if(elementColl[i].elementObj.elementID === elemID)
				{
					if(!isElementAtGuideBar(Value, i))
					{
						FlexGlobals.topLevelApplication.TSSAlert("Guide Bar is not on an element.  Cannot split.");
						return;
					}
					elementColl[i].elementObj.attrTextBox.visible = true;
					elementColl[i].elementObj.attrTextBoxBtn.visible = true;
					elementColl[i].elementObj.attrTextBox.text = Value;
					elementColl[i].elementObj.attrTextBoxBtn.id= i;
					if(!isSplit)
						Button(elementColl[i].elementObj.attrTextBoxBtn).addEventListener(MouseEvent.CLICK, attrTextChange);
					else
						Button(elementColl[i].elementObj.attrTextBoxBtn).addEventListener(MouseEvent.CLICK, attrMPChange);
					
					elementColl[i].elementObj.attrTextBox.name = "ElemTextBox";
					elementColl[i].elementObj.attrTextBoxBtn.name = "ElemTextBoxBtn";
					
					var group:HGroup=new HGroup();
					
					group.addElement(elementColl[i].elementObj.attrTextBox);
					group.addElement(elementColl[i].elementObj.attrTextBoxBtn);
					
					pop.width=100;
					pop.height=20;
					pop.addElement(group);
					pop.x=event.clickX;
					pop.y=event.clickY;
					pop.open(this,false);
				}
				else
				{
					elementColl[i].elementObj.attrDropDown.visible = false;
					elementColl[i].elementObj.attrTextBox.visible= false;
					elementColl[i].elementObj.attrTextBoxBtn.visible = false;
				}
			}
		}

		// Check that the guide mile is on a bar element that can be split
		private function isElementAtGuideBar(milepoint:Number, index:int):Boolean
		{
			var elementFound:Boolean = false;
			for(var i:int=0; i<elementColl[index].AC[0].DATA.length; i++)
			{
				if(milepoint >= elementColl[index].AC[0].DATA[i].REFPT && milepoint <= elementColl[index].AC[0].DATA[i].ENDREFPT)
				{
					elementFound = true;
					break;
				}
			}
			return elementFound;
		}
		
		private function attrDrpDwnChange(event:IndexChangeEvent):void{
			
			//save to database and also to temp variables to redraw
			pop.removeAllElements();
			pop.close(true,null);
			var attrObj:AttrObj = AttrObj(FlexGlobals.topLevelApplication.currAttrObj);
			var i:Number = new Number(attrObj.attrType)-1;
			attrObj.Value = event.target.selectedItem;
			
			for(var j:int=0; j<elementColl[i].AC[0].DATA.length;j++)
			{
				if (elementColl[i].AC[0].DATA[j].ROUTE_NAME == AttrObj(FlexGlobals.topLevelApplication.currAttrObj).Route_Name && 
					elementColl[i].AC[0].DATA[j].REFPT <= AttrObj(FlexGlobals.topLevelApplication.currAttrObj).Clicked_Milepoint&& 
					elementColl[i].AC[0].DATA[j].ENDREFPT >= AttrObj(FlexGlobals.topLevelApplication.currAttrObj).Clicked_Milepoint)
				{
					//attrObj.Value = elementColl[event.target.id].elementObj.attrTextBox.text;
					attrObj.Begin_Mile = new Number(elementColl[i].AC[0].DATA[j].REFPT);
					attrObj.End_Mile = new Number(elementColl[i].AC[0].DATA[j].ENDREFPT);
				}
			}
			
			//attrObj.saveAttr(attrEvent.data.getItemAt(0).ID,attrEvent.data.getItemAt(0).DATA[0],event.target.selectedItem);
			attrObj.saveAttr(attrObj);
			
		}
		
		private function attrTextChange(event:Event):void{
			//save to database and also to temp variables to redraw
			
			pop.removeAllElements();
			pop.close(true,null);
			var attrObj:AttrObj = AttrObj(FlexGlobals.topLevelApplication.currAttrObj);
			//		attrObj.saveAttr(attrEvent.data.getItemAt(0).ID,attrEvent.data.getItemAt(0).DATA[0],elementColl[event.target.id].elementObj.attrTextBox.text);
			attrObj.Value = elementColl[event.target.id].elementObj.attrTextBox.text;
			attrObj.saveAttr(attrObj);
		}
		
		// If splitting a bar element, call the split method with the appropriate data
		private function attrMPChange(event:Event):void{
			//save to local db
			pop.removeAllElements();
			pop.close(true,null);
			AttrObj(FlexGlobals.topLevelApplication.currAttrObj).Value = elementColl[event.target.id].elementObj.attrTextBox.text;
			var splitMP:Number =  elementColl[event.target.id].elementObj.attrTextBox.text;
			var splitX:Number = Converter.scaleMileToPixel(splitMP - diagramRoute.beginMi, diagramScale);
			FlexGlobals.topLevelApplication.splitElement(this.elementToEdit, splitMP, splitX);
		}
				
		
		private function removeChildRelatedToSingleElem():void{
			var elemChildArray:Array = new Array("Element"+AttrObj(FlexGlobals.topLevelApplication.currAttrObj).attrType, "ElemDropDown", "ElemTextBox", "ElemTextBoxBtn");
			
			for(var i:Number=0; i< elemChildArray.length ; i++)
			{
				var DO:DisplayObject = this.getChildByName(elemChildArray[i]);
				if (DO != null)
				{
					this.removeChild(DO);
				}
			}
			
		}
		
		public function hideAttrDrpDwnOrTxt():void
		{
			for(var i:int=0; i<elementColl.length;i++)
			{
				pop.close(true,null);
				elementColl[i].elementObj.attrDropDown.visible = false;
				elementColl[i].elementObj.attrTextBox.visible= false;
				elementColl[i].elementObj.attrTextBoxBtn.visible = false;
			}
		}
		
		
		public function clearContainer():void
		{
			
			// clear all children of container
			while (this.numChildren > 0)
			{
				this.removeChildAt(0);
			}
		}
		
		public function get labels():Array
		{
			return labelArray;
		}
		
		public function removeGuideBar():void
		{
			this.getChildByName("GUIDE_BAR_SPRITE").visible = false;
		}
		
		
		public function invElementsToJSON():String
		{
			var elemCnt:int = elementColl.length;
			var inventoryItems:Array = [];
			
			for(var i:int=0; i<elemCnt;i++)
			{
				var rowObj:Object = new Object();
				var rowArr:Array = [];
				
				var itemCnt:int = elementColl[i].AC.length;
				for(var j:int=0; j < itemCnt;j++)
				{
					var obj:Object = new Object();
					obj = elementColl[i].AC.source[j];
					// Data Array Collection must be converted to an array of objects in order for JSON.stringify to work.
					var dataArr:Array = new Array();
					if(obj.DATA.length > 0)
					{
						for(var k:int=0; k<obj.DATA.length; k++)
						{
							var dataObj:Object = new Object();
							dataObj = obj.DATA[k] as Object;
							dataArr.push(dataObj);
						}
					}
					obj.DATA = dataArr;
					rowArr.push(obj);
				}
				rowObj.AC = rowArr;
				rowObj.elementObj = null;
				inventoryItems[i] = rowObj;
			}
			return JSON.stringify(inventoryItems);
		}
		
		
		public function JSONtoInvElements(jsonText:String, begMile:Number, endMile:Number):void
		{
			// decodes JSON and rehydrates array collections
			var newElemColl:ArrayCollection = new ArrayCollection();
			var eStore:Array = JSON.parse(jsonText) as Array;
			
			for(var i:int=0; i<eStore.length;i++)
			{
				var rowObj:Object = new Object();
				var ac:ArrayCollection = new ArrayCollection();
				var tmpObj:Object = eStore[i].AC;
				
				for(var j:int=0; j<tmpObj.length;j++)
				{
					var sObj:Object = tmpObj[j];
					//filter data which is outside the current range milepoint
					var dataArr:Array = sObj.DATA as Array;
					var newData:Array = new Array();
					for(var k:int=0; k<dataArr.length;k++)
					{
						var bgP:Number = new  Number(dataArr[k].FROMMEASURE);
						var endP:Number = new Number(dataArr[k].TOMEASURE);
						if((bgP>=begMile && bgP<= endMile) || (endP >= begMile && endP <=endMile))
							newData.push(dataArr[k]);
						
					}
					sObj.DATA = newData;
					ac.addItem(sObj);
				}
				
				
				rowObj.AC = ac;
				rowObj.elementObj = null;
				newElemColl.addItem(rowObj);
			}
			// replace existing element Collection
			elementColl = newElemColl;			
		}	
		
		public function getNumElemsByDesc(desc:String):int
		{
			var numElems:int=0;
			var name:String;
			for(var i:int=0; i<this.elementColl.length; i++)
			{
				name = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getTypeFromAttName(elementColl[i].AC[0].ATT_NAME);
				if(name == desc)
				{
					numElems = elementColl[i].AC[0].DATA.length;
					break;
				}
			}
			return numElems;
		}
	}
}