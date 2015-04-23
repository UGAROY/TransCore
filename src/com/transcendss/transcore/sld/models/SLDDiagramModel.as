package com.transcendss.transcore.sld.models
{
	import com.transcendss.transcore.events.*;
	import com.transcendss.transcore.sld.models.components.*;
	import com.transcendss.transcore.util.Converter;
	import com.transcendss.transcore.util.Tippable;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.utils.*;
	
	import mx.binding.utils.*;
	import mx.collections.ArrayCollection;
	import mx.core.*;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.components.Group;
	import spark.components.HSlider;
	import spark.components.RichEditableText;
	import spark.components.Scroller;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.primitives.Graphic;
	
	[Exclude(name="layout", kind="property")]
	
	public class SLDDiagramModel extends Group
	{
		private var sldBorder:BorderContainer;
		private var deBorder:BorderContainer;
		private var sldScroller:Scroller;
		private var sldHSlider:HSlider;
		private var deScroller:Scroller;
		private var sldGroup:Group;
		private var deGroup:Group;
		private var stickDiagram:StickDiagram;
		private var invDiagram:InventoryDiagram;
		private var deGraphic:Graphic;
		private var dragTarget:GuideBar;
		private var diagramScale:Number;
		private var diagramViewMile:Number;
		
		private var scrollActionOn:Boolean = false;
		private var GuideDragOn:Boolean = false;
		
		private var timer:Timer = new Timer(250);
		private var runInterval:int = 1;
		private var scrollForward:Boolean = true;
		public var running:Boolean = false;
		private var guideBarSwitch:Boolean = true;
		private var screenWidthforViewM:Number;
		
		public function SLDDiagramModel(route:Route=null,scale:Number=50000){
			super();
			super.layout = new VerticalLayout();
			
			this.percentHeight = 100;
			this.percentWidth = 100;
			this.gap = 10;
			
			initStick(route);
			initInventory();
			
			stickDiagram.height = sldBorder.height;
			diagramScale = scale;
			addEventListener(MouseEvent.CLICK, attrFocusOut);
			
		}
		
		//when dragging one update x of another and turn on the GuideDragOn to watch the mouse move/ move down outside the Guidebar/diagram 
		//and add event listner to keep tracking x and move the other guidebar at the same time
		private function dragStarter(event:MouseEvent):void {
			if (event.target is Sprite) {
				dragTarget = event.target.parent as GuideBar;
				dragTarget.startDrag(false, new Rectangle(0,dragTarget.y,stickDiagram.width,dragTarget.y));
				GuideDragOn = true;
				dragTarget.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
		}
		
		//stop drag and switch off the GuideDragOn and remove the mouse move event listner to stop tracking x
		private function dragStopper(event:MouseEvent):void {
			dragTarget.stopDrag();
			GuideDragOn = false;
			dragTarget.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		//For the continous movement of second guidebar along with the drag of the first
		private function onMouseMove(event:MouseEvent):void{
			if(dragTarget.parentN == "INV")
			{
				stickDiagram.guideBar.x= dragTarget.x ;
				stickDiagram.routeHUD.updateGuideMile( Converter.scalePixelToMile(dragTarget.x, this.scale) + this.stickDiagram.route.beginMi);
			}
			else
			{
				invDiagram.guideBar.x= dragTarget.x;
				stickDiagram.routeHUD.updateGuideMile( Converter.scalePixelToMile(dragTarget.x, this.scale)+ this.stickDiagram.route.beginMi);
			}
		}
		
		//if mouse clicks anywhere other than the element drop down/ text box or button hide all element DrpDwns/TBs/Btns
		private function attrFocusOut(event:Event):void{
			var target:Object  = event.target;
			if (!(target is Tippable || target is Button || target is RichEditableText))
			{
				invDiagram.hideAttrDrpDwnOrTxt();
			}
		}
		
		public function updateRoute(newRoute:Route,newScale:Number,viewMile:Number=0):void{
			
			// redraws stick diagram 
			var curRoute:Route = stickDiagram.route;
			var scrollPos:Number;
			screenWidthforViewM = sldScroller.viewport.width;
			screenWidthforViewM = sldBorder.width;
			if(curRoute.routeName != newRoute.routeName || 
				curRoute.beginMi != newRoute.beginMi || 
				curRoute.endMi != newRoute.endMi)
			{
				sldScroller.viewport.horizontalScrollPosition = 0;
				//trace("view mi = " + viewMile);
				this.viewMile = viewMile;
				this.scale = newScale;
				invDiagram.draw(newScale,newRoute);
				stickDiagram.draw(newScale,newRoute,false,screenWidthforViewM);
			}
			else if (this.scale != newScale){ 
				// route same - redraw from storage at new scale
				
				scrollPos = sldScroller.viewport.horizontalScrollPosition;
				viewMile = Converter.scalePixelToMile(scrollPos,this.scale); //current view mile
				//trace("view mi = " + viewMile);
				
				//				newScrollPos = Converter.scaleMileToPixel(viewMile,newScale); // vm scaled to new scale
				//				var newViewMile:Number = Converter.scalePixelToMile(newScrollPos,newScale); //current view mile
				//				trace("new view mi = " + newViewMile);
				
				this.viewMile = viewMile;
				this.scale = newScale;
				
				//sldScroller.viewport.horizontalScrollPosition = 0;
				
				invDiagram.draw(newScale,stickDiagram.route,true);
				stickDiagram.draw(newScale,stickDiagram.route,true,screenWidthforViewM);
				
				
			}
			// position HUD Text after stick draw
			stickDiagram.moveHUD(sldScroller.viewport.horizontalScrollPosition+(sldScroller.viewport.width/2));
			guideBarSwitch = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.guideBarSwitch;
			//link guidebars
			if (guideBarSwitch)
			{
				invDiagram.guideBar.addEventListener(MouseEvent.MOUSE_DOWN, dragStarter, false);
				stickDiagram.guideBar.addEventListener(MouseEvent.MOUSE_DOWN, dragStarter, false);
				stickDiagram.guideBar.addEventListener(MouseEvent.MOUSE_UP, dragStopper);
				invDiagram.guideBar.addEventListener(MouseEvent.MOUSE_UP, dragStopper);
			}
			
			//sldScroller.viewport.horizontalScrollPosition = Converter.scaleMileToPixel(this.viewMile,this.scale);
		}
		
		
		public function setViewMile(mile:Number):void{
			sldScroller.viewport.horizontalScrollPosition = Converter.scaleMileToPixel(mile,this.scale);
		}
		
		public function addattDropDown(event:AttributeEvent):void{
			invDiagram.displayElementDrop(event,this.scale)
		}
		
		private function initStick(route:Route=null):void{
			initSLDContainer();
			initSLDScroller();
			initSLDGroup();
			
			// init and add stick to group
			stickDiagram = new StickDiagram(route);
			sldGroup.addElement(stickDiagram);
			
			// add group to border
			sldBorder.addElement(sldGroup);
			
			// set group to scroller's viewport
			sldScroller.viewport = sldGroup;
			sldScroller.viewport.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, linkScrollers);
			
			// add scroller to container
			sldBorder.addElement(sldScroller);	
			
			// add border container to Diagram object (vgroup)
			this.addElement(sldBorder);
		}
		
		private function initInventory(route:Route=null, scale:Number = 50000):void{
			initDEContainer();
			initDEScroller();
			initDEGroup();
			//			addDEGraphic();
			
			invDiagram= new InventoryDiagram(route, scale);
			deGroup.addElement(invDiagram);
			
			deBorder.addElement(deGroup);
			deScroller.viewport = deGroup;
			deBorder.addElement(deScroller);
			
			this.addElement(deBorder);
			
			
		}
		
		private function initSLDContainer():void{
			sldBorder = new BorderContainer();	
			sldBorder.id = "sldBorder";
			sldBorder.height = 240;
			sldBorder.setStyle("cornerRadius", 3);
			sldBorder.setStyle("borderWeight", 1);
			sldBorder.setStyle("borderColor", 0x444444);
			sldBorder.setStyle("dropShadowVisible", true);
			sldBorder.setStyle("backgroundColor", 0xffffff);	
			
		}
		
		private function initSLDScroller():void{		
			sldScroller = new Scroller();
			sldScroller.id = "sldScroller";
			sldScroller.percentWidth = 100;
			sldScroller.percentHeight = 100;
			sldScroller.setStyle("verticalScrollPolicy", "off");
			
			// add event listeners
			sldScroller.addEventListener(MouseEvent.MOUSE_DOWN,setScrollDown);
			//			sldScroller.addEventListener(MouseEvent.MOUSE_UP,getScrollUpdates);
			
		}	
		
		private function initSLDGroup():void{
			sldGroup = new Group();
			sldGroup.id = "sldGroup";
			sldGroup.clipAndEnableScrolling = true;
			sldGroup.horizontalScrollPosition = 0;
			sldGroup.percentWidth = 100;
			sldGroup.percentHeight = 100;
			
			var sldHL:HorizontalLayout = new HorizontalLayout();
			sldHL.paddingLeft = 20;
			sldHL.paddingRight = 20;
			// add horizontal layout
			sldGroup.layout = sldHL;
		}
		
		//		private function addSLDHSlider():void{
		//			sldHSlider = new HSlider();
		//			sldHSlider.id = "sldScroller"
		//			sldHSlider.percentWidth = 100;
		//			sldHSlider.height = 15;
		//			sldHSlider.snapInterval = 1;
		//			sldBorder.addElement(sldHSlider);
		//		}		
		
		
		private function initDEContainer():void{
			deBorder = new BorderContainer();	
			deBorder.id = "deBorder";
			deBorder.percentHeight = 100;
			deBorder.setStyle("cornerRadius", 3);
			deBorder.setStyle("borderWeight", 1);
			deBorder.setStyle("borderColor", 0x444444);
			deBorder.setStyle("dropShadowVisible", true);
			deBorder.setStyle("backgroundColor", 0xffffff);	
			
		}
		
		private function initDEScroller():void{
			deScroller = new Scroller();
			deScroller.id = "deScroller";
			deScroller.percentWidth = 100;
			deScroller.percentHeight = 100;
			deScroller.setStyle("verticalScrollPolicy", "auto");
			deScroller.setStyle("horizontalScrollPolicy", "off");
			
		}
		
		private function initDEGroup():void{
			deGroup = new Group();
			deGroup.clipAndEnableScrolling = true;
			deGroup.horizontalScrollPosition = 0;
			deGroup.percentWidth = 100;
			deGroup.percentHeight = 100;
			
			var deHL:HorizontalLayout = new HorizontalLayout();
			deHL.paddingLeft = 20;
			deHL.paddingRight = 20;
			deGroup.layout = deHL;
		}
		
		private function setScrollDown(dir:Boolean):void{
			scrollActionOn = true;
		}
		
		public function updateScrollerOrGuide(event:MouseEvent):void{
			// this function triangulates to ensure the mouse up command fires to refresh 
			// if the user has activate the scrollbar but has moved of the scrollbar element
			//or if the user has activated the guidebar drag but moved of the guidebar before mouse up 
			if (scrollActionOn == true){
				getScrollUpdates(event);
			}
			if (GuideDragOn == true && guideBarSwitch ==true)
			{
				onMouseMove(event);
				dragStopper(event);
			}
		}	
		
		public function updateGuideX(event:MouseEvent):void{
			// this function triangulates to ensure the mouse move command fires to refresh 
			// if the user has activate the guidebar but has moved of the guidebar element
			//to keep moving the other guidebar
			if (GuideDragOn == true && guideBarSwitch ==true){
				onMouseMove(event);
			}
		}	
		
		private function getScrollUpdates(event:MouseEvent):void{
			scrollActionOn = false; // reset bool
			//			calcCurrentViewMile();
			//			getLatLongforView.url=ConfigManager.serviceURL+ "LatLong/"+sldRoute.name+"/"+sldDiagram.viewMiLeft+"/"+ sldDiagram.viewMiRight;
			//			getLatLongforView.send();
		}
		
		private function linkScrollers(e:PropertyChangeEvent):void{
			if (e.source == e.target && e.property == "horizontalScrollPosition") {
				deScroller.viewport.horizontalScrollPosition = new Number(e.newValue);
				invDiagram.labels.forEach(moveLabels);
				stickDiagram.moveHUD(sldScroller.viewport.horizontalScrollPosition+(sldScroller.viewport.width/2));
				var maxRightX:Number =  new Number(e.newValue) +  sldScroller.viewport.width-40;
				stickDiagram.updateCallOutXs(new Number(e.newValue));
				if (guideBarSwitch)
				{
					if (stickDiagram.guideBar.x < new Number(e.newValue))
					{
						stickDiagram.guideBar.x = new Number(e.newValue);
						invDiagram.guideBar.x = new Number(e.newValue);
						stickDiagram.routeHUD.updateGuideMile(Converter.scalePixelToMile(new Number(e.newValue), this.scale)+ this.stickDiagram.route.beginMi);
						
					}
					else if (stickDiagram.guideBar.x >  maxRightX)
					{
						stickDiagram.guideBar.x = maxRightX;
						invDiagram.guideBar.x = maxRightX;
						stickDiagram.routeHUD.updateGuideMile(Converter.scalePixelToMile(maxRightX, this.scale)+ this.stickDiagram.route.beginMi);
					}
					
					
				}
			}
			
		}
		
		private function moveLabels(element:DisplayObject, index:int, arr:Array):void{
			element.x = sldScroller.viewport.horizontalScrollPosition;
		}
		
		public function addToolTip(tooltip:Sprite,dType:int):void{
			switch (dType)
			{
				case 1 :
					stickDiagram.addChild(tooltip);
					break;
				case 2 :
					invDiagram.addChild(tooltip);
					break;
			}			
		}
		public function removeToolTip(tooltip:Sprite,dType:int):void{
			//var tipDO:DisplayObject = stickDiagram.getChildByName(tooltip.name);
			try
			{
				switch (dType)
				{
					case 1 :
						stickDiagram.removeChild(tooltip);
						break;
					case 2 :
						invDiagram.removeChild(tooltip);
						break;
				}
			}
			catch(excep:Error)
			{
				var ex:int = excep.errorID;
			}
			
		}
		
		public function set sldBorderWidth(val:Number):void{
			sldBorder.width = val*99/100;
		}
		
		public function set deBorderWidth(val:Number):void{
			deBorder.width = val*99/100;
		}	
		
		public function set scale(scale:Number):void{
			diagramScale = scale;
			// dispatch scale change event
			//			var scaleEvent:MapOperationEvent = new MapOperationEvent(MapOperationEvent.MAP_SCALE_CHANGED);
			//			dispatchEvent(scaleEvent);
		}
		public function get scale():Number{
			return diagramScale;
		}
		
		public function set viewMile(vMile:Number):void{
			diagramViewMile = vMile;
		}
		public function get viewMile():Number{
			return diagramViewMile;
		}		
		
		public function set setRoute(rte:Route):void{
			stickDiagram.route = rte; //sets stick route
		}		
		public function get getRoute():Route{
			return stickDiagram.route; //sets stick route
		}
		
		
		private function get verticalLayout():VerticalLayout
		{
			return VerticalLayout(layout);
		}	
		
		[Inspectable(category="General")]
		public function get gap():int
		{
			return verticalLayout.gap;
		}
		
		/**
		 *  @private
		 */
		public function set gap(value:int):void
		{
			verticalLayout.gap = value;
		}
		
		[Inspectable(category="General", enumeration="left,right,center,justify,contentJustify", defaultValue="left")]
		public function get horizontalAlign():String
		{
			return verticalLayout.horizontalAlign;
		}
		
		public function set horizontalAlign(value:String):void
		{
			verticalLayout.horizontalAlign = value;
		}
		
		[Inspectable(category="General", enumeration="top,bottom,middle", defaultValue="top")]
		public function get verticalAlign():String
		{
			return verticalLayout.verticalAlign;
		}
		
		public function set verticalAlign(value:String):void
		{
			verticalLayout.verticalAlign = value;
		}
		
		[Inspectable(category="General")]
		public function get paddingLeft():Number
		{
			return verticalLayout.paddingLeft;
		}
		
		public function set paddingLeft(value:Number):void
		{
			verticalLayout.paddingLeft = value;
		}    
		
		[Inspectable(category="General")]
		public function get paddingRight():Number
		{
			return verticalLayout.paddingRight;
		}
		
		public function set paddingRight(value:Number):void
		{
			verticalLayout.paddingRight = value;
		}    
		
		[Inspectable(category="General")]
		public function get paddingTop():Number
		{
			return verticalLayout.paddingTop;
		}
		
		public function set paddingTop(value:Number):void
		{
			verticalLayout.paddingTop = value;
		}    
		
		[Inspectable(category="General")]
		public function get paddingBottom():Number
		{
			return verticalLayout.paddingBottom;
		}
		
		public function set paddingBottom(value:Number):void
		{
			verticalLayout.paddingBottom = value;
		}    
		
		[Bindable("propertyChange")]
		[Inspectable(category="General")]
		
		/**
		 *  @copy spark.layouts.VerticalLayout#rowCount
		 * 
		 *  @default -1
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get rowCount():int
		{
			return verticalLayout.rowCount;
		}
		
		[Inspectable(category="General")]
		public function get requestedRowCount():int
		{
			return verticalLayout.requestedRowCount;
		}
		
		public function set requestedRowCount(value:int):void
		{
			verticalLayout.requestedRowCount = value;
		}    
		
		[Inspectable(category="General")]
		public function get rowHeight():Number
		{
			return verticalLayout.rowHeight;
		}
		
		public function set rowHeight(value:Number):void
		{
			verticalLayout.rowHeight = value;
		}
		
		[Inspectable(category="General")]
		public function get variableRowHeight():Boolean
		{
			return verticalLayout.variableRowHeight;
		}
		
		public function set variableRowHeight(value:Boolean):void
		{
			verticalLayout.variableRowHeight = value;
		}
		
		[Bindable("indexInViewChanged")]    
		[Inspectable(category="General")]
		
		public function get firstIndexInView():int
		{
			return verticalLayout.firstIndexInView;
		}
		
		[Bindable("indexInViewChanged")]    
		[Inspectable(category="General")]
		
		public function get lastIndexInView():int
		{
			return verticalLayout.lastIndexInView;
		}
		
		override public function set layout(value:LayoutBase):void
		{
			throw(new Error(resourceManager.getString("components", "layoutReadOnly")));
		}
		
//		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
//		{
//			switch(type)
//			{
//				case "indexInViewChanged":
//				case "propertyChange":
//					if (!hasEventListener(type))
//						verticalLayout.addEventListener(type, redispatchHandler);
//					break;
//			}
//			super.addEventListener(type, listener, useCapture, priority, useWeakReference)
//		}    
		
//		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
//		{
//			super.removeEventListener(type, listener, useCapture);
//			switch(type)
//			{
//				case "indexInViewChanged":
//				case "propertyChange":
//					if (!hasEventListener(type))
//						verticalLayout.removeEventListener(type, redispatchHandler);
//					break;
//			}
//		}
		
		private function redispatchHandler(event:Event):void
		{
			dispatchEvent(event);
		}
		
		// functions for autorun
		public function startRun():void
		{
			running = true;
			timer.addEventListener(TimerEvent.TIMER, run);
			timer.start();
		}
		
		private function run(obj:Object):void
		{
			
			if (scrollForward)
			{
				advanceScroller(null);
			}else
			{
				retreatScroller(null);
			}
		}
		public function stopRun():void
		{
			running = false;
			timer.stop();
		}
		
		public function advanceScroller(obj:Object):void
		{
			sldGroup.horizontalScrollPosition = sldGroup.horizontalScrollPosition + runInterval;
			fireXYChange();
		}
		
		public function retreatScroller(obj:Object):void
		{
			sldGroup.horizontalScrollPosition = sldGroup.horizontalScrollPosition - runInterval;
			fireXYChange();
		}
		
		public function scrollToBeginning(obj:Object):void
		{
			sldGroup.horizontalScrollPosition = 0;
			fireXYChange();
		}
		
		public function scrollToEnd(obj:Object):void
		{
			sldGroup.horizontalScrollPosition = stickDiagram.width-1;
			fireXYChange();
		}
		
		public function uturn(obj:Object):void
		{
			if (scrollForward)
			{
				scrollForward = false;		
			} else
			{
				scrollForward = true;
			}
		}
		
		public function changeSpeed(event:NavControlEvent):void
		{
			var speed:Number = event.sliderValue;
			if (running)
			{
				stopRun();
				timer = new Timer(speed);
				startRun();
			} else
			{
				timer = new Timer(speed);
			}
		}
		
		public function changeStep(event:NavControlEvent):void
		{
			runInterval = event.sliderValue;
		}
		
		protected function fireXYChange():void
		{
			try 
			{		
				var runEvent:NavControlEvent = new NavControlEvent(NavControlEvent.XY_CHANGE, true, true);
				runEvent.mp = getCurrentMP();
				dispatchEvent(runEvent);
			}
			catch(error:TypeError){
				//catch the occassional type error obtained when clicked on the menu container outside the item
			}
		}
		
		protected function getCurrentMP():Number{
			var percent:Number = sldGroup.horizontalScrollPosition / stickDiagram.width;
			var miDist:Number = stickDiagram.route.endMi - stickDiagram.route.beginMi;
			var currMP:Number = stickDiagram.route.beginMi + (miDist * percent);
			return currMP;
			
		}
		
		public function turnGuideBaroff():void{
			invDiagram.guideBar.removeEventListener(MouseEvent.MOUSE_DOWN, dragStarter, false);
			stickDiagram.guideBar.removeEventListener(MouseEvent.MOUSE_DOWN, dragStarter, false);
			stickDiagram.guideBar.removeEventListener(MouseEvent.MOUSE_UP, dragStopper);
			invDiagram.guideBar.removeEventListener(MouseEvent.MOUSE_UP, dragStopper);
			stickDiagram.removeGuideBar();
			invDiagram.removeGuideBar();
		}
		
		public function turnGuideBaron():void{
			stickDiagram.drawGuideBar();
			invDiagram.drawGuideBar();
			invDiagram.guideBar.addEventListener(MouseEvent.MOUSE_DOWN, dragStarter, false);
			stickDiagram.guideBar.addEventListener(MouseEvent.MOUSE_DOWN, dragStarter, false);
			stickDiagram.guideBar.addEventListener(MouseEvent.MOUSE_UP, dragStopper);
			invDiagram.guideBar.addEventListener(MouseEvent.MOUSE_UP, dragStopper);
		}
	}
}