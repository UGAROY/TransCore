package com.transcendss.transcore.sld.models
{
	import com.google.maps.overlays.GroundOverlay;
	import com.transcendss.transcore.events.MapOperationEvent;
	import com.transcendss.transcore.sld.models.components.Culvert;
	import com.transcendss.transcore.sld.models.components.Route;
	import com.transcendss.transcore.sld.models.interfaces.IAssetDiagram;
	import com.transcendss.transcore.util.Converter;
	import com.transcendss.transcore.util.Tippable;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.controls.Spacer;
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	import mx.effects.easing.Back;
	import mx.events.EffectEvent;
	import mx.events.PropertyChangeEvent;
	import mx.graphics.SolidColor;
	
	import spark.components.BorderContainer;
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.RadioButton;
	import spark.components.RadioButtonGroup;
	import spark.components.RichEditableText;
	import spark.components.Scroller;
	import spark.components.VGroup;
	import spark.core.SpriteVisualElement;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	import spark.primitives.Rect;
	
	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------
	
	public class AssetDiagram extends Group implements IAssetDiagram
	{
		//  Panel Properties
		protected var leftPanelGroup:Group;
		protected var rightPanelGroup:Group;
		
		// Stick properties
		protected var stickDiagram:StickDiagram;
		protected var _stickScroller:Scroller;
		protected var sldGroup:Group;
		protected var sldBorder:BorderContainer;
		
		// Inventory properties
		protected var invDiagram:InventoryDiagram;
		protected var invGroup:Group;
		protected var invBorder:BorderContainer;
		protected var _invScroller:Scroller;
		
		// Sign Inventory properties
		protected var inventoryForm:InventoryForm;
		//private var ifGroup:Group;
		//private var ifBorder:BorderContainer;
		
		protected var scrollActionOn:Boolean = false;
		protected var guideBarSwitch:Boolean = true;
		protected var diagramScale:Number;
		protected var diagramViewMile:Number;
		protected var screenWidthforViewM:Number;
		protected var runningScrlr:Boolean = false;
		protected var invPanelContent:String;
		protected var deBrdrWidth:Number;
		protected var ifBrdrWidth:Number;
		protected var _route:Route;
		protected var _labelLayer:Group;
		
		protected var offsetValue:Number;
		
		/**
		 * Asset Diagram Constructor
		 * Initializes stick and inventory diagrams and sets diagram dimensions and scale
		 * @param route
		 * @param scale
		 * 
		 */
		public function AssetDiagram(route:Route=null,scale:Number=.5)
		{
			//this.isInvForm = FlexGlobals.topLevelApplication.isInvForm;
			this.layout = new HorizontalLayout;
			_route =route; 
			this.percentHeight = 100;
			this.percentWidth = 100;
			this.gap = 10;
			

			
			initLeftPanel();
			initRightPanel();
			initStick(route);
			initInvSection();
			
			stickDiagram.height = sldBorder.height;
			diagramScale = scale;
			addEventListener(MouseEvent.CLICK, attrFocusOut);
			
		}
		
		/**
		 * Updates existing diagrams with new route information.  Causes data query and diagram redraw
		 * @param route
		 * @param scale
		 * @param view
		 * 
		 */
		public function updateRoute(nRoute:Route, nScale:Number, fromStorage:Boolean=false, view:Number=0):void
		{
			
			_route = nRoute;
			updateRouteBase(nRoute,nScale,fromStorage,view);
		}
		
		public function initInvPanelContent(content:IVisualElement=null):void
		{
			invPanelContent = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.invPanelContent;
			if (invPanelContent != "bars")
				initInventory(content);
			
		}
		
		public function toggleInvPanelContent(content:IVisualElement=null, guideBarPos:String = "middle", buttonMd:Boolean=false, useHandCrsr:Boolean = false):void
		{
			var scrollPos:Number= _stickScroller.viewport.horizontalScrollPosition;
			var guidebarX:Number= Converter.scalePixelToMile(scrollPos,this.scale);
			screenWidthforViewM = _stickScroller.viewport.width;
			
			this.offsetValue = (screenWidthforViewM-50)/2;
			invPanelContent = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.invPanelContent;
			guideBarSwitch = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.guideBarSwitch;
			
			if(guideBarPos == "middle")
			{
				guidebarX = screenWidthforViewM/2;
			}
			else
			{
				guidebarX = 0;
			}
			
			if (invPanelContent != "bars")
				initInventory(content);
			else
			{
				if (invDiagram != null)
				{
					initInventory(invDiagram);
					
				}
			}
			
			//deScroller.viewport.verticalScrollPosition = 500;
		}
		
		/**
		 * @private 
		 * @param nRoute
		 * @param nScale
		 * @param view
		 * @param guideBarPos
		 * @param buttonMd
		 * @param useHandCrsr
		 * 
		 */
		protected function updateRouteBase(nRoute:Route, nScale:Number, fromStorage:Boolean=false, view:Number=0, guideBarPos:String = "middle", buttonMd:Boolean=false, useHandCrsr:Boolean = false):void
		{
			// redraws stick diagram 
			var curRoute:Route = stickDiagram.route;
			var scrollPos:Number;
			var guidebarX:Number;
			_route = nRoute;	
			
			screenWidthforViewM = (_stickScroller.viewport as UIComponent).width;
			
			this.offsetValue = (screenWidthforViewM-50)/2;
			if(guideBarPos =="middle")
			{
				guidebarX = (screenWidthforViewM - 50) / 2;
			}
			else
			{
				guidebarX = 0;
			}
			
			
			
			if (!fromStorage || invDiagram == null)
			{
				//sldScroller.viewport.horizontalScrollPosition = 0;
				
				//trace("view mi = " + viewMile);
				//this.viewMile = nRoute.beginMi;
				//changed from viewmile 
				this.scale = nScale;
				_labelLayer = new Group();
				
				//stick diagram needs to be drawn first
				stickDiagram.draw(nScale,nRoute,fromStorage,screenWidthforViewM,guidebarX, buttonMd,useHandCrsr);
				
				//create invDiagram  even if map is defualt. This will allow to switch from map to bars later
				invDiagram = new InventoryDiagram(nRoute, scale, _labelLayer,offsetValue);
				invDiagram.draw(nScale,nRoute,false,guidebarX);
				//don't add yet to the view. until the bars view is selected
				if (invPanelContent=="bars")
					initInventory(invDiagram);
				
				
				
			}
			else 
			{ 
				this.scale = nScale;
				// route same - redraw from storage at new scale
				//				scrollPos = sldScroller.viewport.horizontalScrollPosition;
				//				viewMile = Converter.scalePixelToMile(scrollPos,this.scale); //current view mile
				
				//stick diagram needs to be drawn first
				stickDiagram.draw(nScale,nRoute,true,screenWidthforViewM,guidebarX, buttonMd,useHandCrsr, true);
				
				invDiagram.draw(nScale,nRoute,true,guidebarX);
				if (invPanelContent == "bars")
					initInventory(invDiagram);
				
				
				
			}	
			
			//this._invScroller.viewport.horizontalScrollPosition = this._stickScroller.viewport.horizontalScrollPosition;
			this.viewMile = view;
			//allow offset to scroll to beg and end of route.
			if(sldGroup.getChildByName("SPACEHOLDER")==null)
			{
				var spaceHolder:Label = new Label();
				spaceHolder.name = "SPACEHOLDER";
				spaceHolder.width = offsetValue * 2;
				sldGroup.addElement(spaceHolder);
			}
			if(invGroup.getChildByName("SPACEHOLDER")==null)
			{
				var spaceHolder2:Label = new Label();
				spaceHolder2.name = "SPACEHOLDER";
				spaceHolder2.width = offsetValue * 2;
				invGroup.addElement(spaceHolder2);
			}
			// position HUD Text after stick draw
			stickDiagram.moveHUD(_stickScroller.viewport.horizontalScrollPosition+(_stickScroller.viewport.width/2));
			guideBarSwitch = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.guideBarSwitch;
			
			
		}
		
		
		/**
		 * Hides all element drop downs/ text boxes and buttons if the user mouse clicks anywhere other than the element drop down 
		 * @param event
		 * 
		 */
		protected function attrFocusOut(event:Event):void{
			var target:Object  = event.target;
			if (!(target is Tippable || target is Button || target is RichEditableText))
			{
				if(invDiagram !=null)
					invDiagram.hideAttrDrpDwnOrTxt();
			}
		}		
		
		/**
		 * Initializes the Left Panel Group object (empty/zero width)
		 * 
		 */
		private function initLeftPanel():void
		{
			leftPanelGroup = new Group();
			var lPanelLayout:VerticalLayout = new VerticalLayout();
			lPanelLayout.gap = 20;
			leftPanelGroup.layout = lPanelLayout;
			leftPanelGroup.percentHeight = 100;
			this.addElement(leftPanelGroup);
		}
		
		private function initRightPanel():void
		{
			rightPanelGroup = new Group();
			var rPanelLayout:VerticalLayout = new VerticalLayout();
			rPanelLayout.gap = 10;
			rightPanelGroup.layout = rPanelLayout;
			rightPanelGroup.percentHeight = 100;
			this.addElement(rightPanelGroup);
		}
		
		/**
		 * Initializes the route (stick) diagram object and UI support containers
		 * @param route
		 * 
		 */		
		public function initStick(route:Route=null):void
		{
			initSLDContainer();
			initSLDScroller();
			initSLDGroup();
			
			// init and add stick to group
			stickDiagram = new StickDiagram(route);
			sldGroup.addElement(stickDiagram);
			//sldGroup.width +=offsetValue*2;
			//offset
			
			
			// add group to border
			sldBorder.addElement(sldGroup);
			
			// set group to scroller's viewport
			_stickScroller.viewport = sldGroup;
			//if (invPanelContent=="bars")
			//sldScroller.viewport.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, linkScrollers);
			
			// add scroller to container
			sldBorder.addElement(_stickScroller);	
			
			// add border container
			rightPanelGroup.addElement(sldBorder);
		}
		
		public function clearRoute():void
		{
			//sldGroup.removeAllElements();
			this._route = null;
			//this.stickDiagram = null;
			if (FlexGlobals.topLevelApplication.GlobalComponents)
				FlexGlobals.topLevelApplication.GlobalComponents.stkDiagram = null;
			stickDiagram.removeChildren();
			stickDiagram.route = new Route("no_rte", 0, 0);
			//stickDiagram = new StickDiagram();
			
			invGroup.removeAllElements();
			this.invDiagram = null;
			if (FlexGlobals.topLevelApplication.GlobalComponents)
				FlexGlobals.topLevelApplication.GlobalComponents.invDiagram = null;
			
			invBorder.removeAllElements();
			
			stickScroller.viewport.removeEventListener(PropertyChangeEvent.PROPERTY_CHANGE, linkScrollers);
		}
		
		
		protected var tButton:Button;
		/**
		 * Initializes the inventory (data element) diagram object and UI support containers
		 * @param route
		 * @param scale
		 * 
		 */
		public function initInventory(content:IVisualElement):void
		{
			invGroup.removeAllElements();
			if (_invScroller != null)
				invBorder.removeElement(_invScroller);
			initDEScroller();
			if (invPanelContent != null && invPanelContent != "map" && invPanelContent != "settings")
				_invScroller.setStyle("verticalScrollPolicy", "on");
			invGroup.addElement(content); 
			//offset
			
			_invScroller.viewport = invGroup;
			if (this.InvPanelContent != "bars") 
			{
				content.percentHeight = 100;
				// For map, set the horizontalScrollPosition to 0
				// Actually we can remove the scroller for map.
				// TODO: revisit this
				invGroup.horizontalScrollPosition = 0;
			}
			
			var bc:BorderContainer = btmPanelContentSelect();
			if (bc)
			{
				invBorder.addElement(bc);
				_invScroller.top = 60;
			}
			
			invBorder.addElement(_invScroller);
			if (bc)
				rightPanelGroup.addElement(invBorder);
		}
		
		public function reseatInventory():void
		{
			
		}
		
		protected function btmPanelContentSelect():BorderContainer
		{
			var hg:HGroup = new HGroup();
			var label:Label = new Label();
			label.text = "Panel Content: ";
			
			var rg:RadioButtonGroup = new RadioButtonGroup();
			rg.selectedValue=FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.invPanelContent;
			rg.addEventListener(Event.CHANGE, function f(e:Event):void{FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.invPanelContent=rg.selectedValue;});
			
			var rd1:RadioButton = new RadioButton();
			rd1.value= "form";
			rd1.label = "Form";
			rd1.group = rg;
			rd1.visible = false;
			rd1.includeInLayout = false;
			
			var rd2:RadioButton = new RadioButton();
			rd2.value= "settings";
			rd2.label = "Settings";
			rd2.group = rg;
			
			var rd3:RadioButton = new RadioButton();
			rd3.value= "bars";
			rd3.label = "Attribute Bars";
			rd3.id = "barRadio"
			rd3.group = rg;
			
			var rd4:RadioButton = new RadioButton();
			rd4.value= "map";
			rd4.label = "Overview Map";
			rd4.group = rg;
			
			var bc:BorderContainer = new BorderContainer();
			bc.setStyle("backgroundColor", 0xc0c0c0);
			
			
			hg.gap=10;
			hg.verticalAlign = "middle";
			var tmpSp:Spacer = new Spacer();
			tmpSp.width = 20;
			hg.addElement(tmpSp);
			hg.addElement(label);
			hg.addElement(rd1);
			//hg.addElement(rd2);
			hg.addElement(rd3);
			hg.addElement(rd4);
			bc.addElement(hg);
			bc.percentWidth = 100;
			return bc;
		}
		
		public function initInvSection():void
		{
			initInvContainer();
			initInvGroup();
			invBorder.addElement(invGroup);
			rightPanelGroup.addElement(invBorder);
		}
		
		/**
		 * Initializes the sign inventory object and UI support containers
		 * @param route
		 * @param scale
		 * 
		 */
		//		public function initInventoryForm(content:DisplayObject):void
		//		{
		//			invGroup.removeAllElements();
		//			initDEScroller();
		//			inventoryForm = new InventoryForm(content);
		//			inventoryForm.height = content.height;
		//			inventoryForm.width = content.width;
		//			
		//			
		//			invGroup.addElement(inventoryForm);
		//			
		//			deScroller.viewport = invGroup;
		//			deScroller.top = 50;
		//			invBorder.addElement(btmPanelContentSelect());
		//			invBorder.addElement(deScroller);
		//			rightPanelGroup.addElement(invBorder);
		//		}
		
		/**
		 * Initializes the SLD UI border container
		 * 
		 */
		public function initSLDContainer():void
		{
			sldBorder = new BorderContainer();	
			sldBorder.id = "sldBorder";
			sldBorder.height = 280;
			sldBorder.setStyle("cornerRadius", 3);
			sldBorder.setStyle("borderWeight", 1);
			sldBorder.setStyle("borderColor", 0x444444);
			sldBorder.setStyle("dropShadowVisible", true);
			sldBorder.setStyle("backgroundColor", 0xffffcc);
		}
		
		/**
		 *  Initializes the SLD Scroller object
		 * 
		 */
		public function initSLDScroller():void
		{
			_stickScroller = new Scroller();
			_stickScroller.id = "sldScroller";
			_stickScroller.percentWidth = 100;
			_stickScroller.percentHeight = 100;
			_stickScroller.setStyle("verticalScrollPolicy", "off");
			// add event listeners
			_stickScroller.addEventListener(MouseEvent.MOUSE_DOWN,setScrollDown);
			//sldScroller.viewport.addEventListener(EffectEvent.EFFECT_END, scrollFinished);
		}
		
		
		/**
		 * Initializes the SLD UI Group container
		 * 
		 */
		public function initSLDGroup():void
		{
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
		
		/**
		 * Initializes the inventory (data element) UI border container
		 * 
		 */	
		public function initInvContainer():void
		{
			invBorder = new BorderContainer();	
			invBorder.id = "deBorder";
			invBorder.percentHeight = 100;
			invBorder.width = deBrdrWidth;
			invBorder.setStyle("cornerRadius", 3);
			invBorder.setStyle("borderWeight", 1);
			invBorder.setStyle("borderColor", 0x444444);
			invBorder.setStyle("dropShadowVisible", true);
			invBorder.setStyle("backgroundColor", 0xffffcc);	
		}
		
		/**
		 *  Initializes the inventory (data element) Scroller object
		 * 
		 */		
		public function initDEScroller():void
		{
			_invScroller = new Scroller();
			_invScroller.id = "deScroller";
			_invScroller.percentWidth = 100;
			_invScroller.percentHeight = 100;
			_invScroller.setStyle("verticalScrollPolicy", "auto");
			_invScroller.setStyle("horizontalScrollPolicy", "off");
		}
		
		/**
		 * Initializes the inventory (data element) UI Group container
		 * 
		 */
		public function initInvGroup():void
		{
			invGroup = new Group();
			invGroup.clipAndEnableScrolling = true;
			invGroup.horizontalScrollPosition = 0;
			invGroup.percentWidth = 100;
			invGroup.percentHeight = 100;
			
			var deHL:HorizontalLayout = new HorizontalLayout();
			deHL.paddingLeft = 20;
			deHL.paddingRight = 20;
			invGroup.layout = deHL;
		}
		
		//		/**
		//		 * Initializes the sign inventory UI border container
		//		 * 
		//		 */	
		//		public function initIFContainer():void
		//		{
		//			ifBorder = new BorderContainer();	
		//			ifBorder.id = "siBorder";
		//			ifBorder.percentHeight = 100;
		//			ifBorder.width = ifBrdrWidth;
		//			ifBorder.setStyle("cornerRadius", 3);
		//			ifBorder.setStyle("borderWeight", 1);
		//			ifBorder.setStyle("borderColor", 0x444444);
		//			ifBorder.setStyle("dropShadowVisible", true);
		//			ifBorder.setStyle("backgroundColor", 0xffffff);	
		//		}
		
		//		/**
		//		 * Initializes the sign inventory UI Group container
		//		 * 
		//		 */
		//		public function initIFGroup():void
		//		{
		//			ifGroup = new Group();
		//			ifGroup.clipAndEnableScrolling = true;
		//			ifGroup.horizontalScrollPosition = 0;
		//			ifGroup.percentWidth = 100;
		//			ifGroup.percentHeight = 100;
		//			
		//			var siHL:HorizontalLayout = new HorizontalLayout();
		//			siHL.paddingLeft = 20;
		//			siHL.paddingRight = 20;
		//			ifGroup.layout = siHL;
		//		}
		
		protected function preserveSync(e:MouseEvent):void
		{
			if (InvPanelContent=="bars")
			{
				if (true)
				{
					_invScroller.viewport.removeEventListener(MouseEvent.MOUSE_MOVE, preserveSync);
					_invScroller.viewport.horizontalScrollPosition = stickScroller.viewport.horizontalScrollPosition;
					_invScroller.viewport.addEventListener(MouseEvent.MOUSE_MOVE, preserveSync);	
				}
			}
			else
			{
				_invScroller.viewport.horizontalScrollPosition = 0;
			}
			
		}
		
		/**
		 * Links the movement of the SLD scrollbar to the hidden Inventory diagram scrollbar
		 * Also assists in moving/updating other drawn objects
		 * @param e
		 * @private
		 */
		protected function linkScrollers(e:PropertyChangeEvent):void
		{
			if (e.source == e.target && e.property == "verticalScrollPosition") 
			{
				if (InvPanelContent=="bars")
				{
					//invScroller.viewport.horizontalScrollPosition = sldScroller.viewport.horizontalScrollPosition;
					//inventoryDrawing.labels.forEach(moveLabels);
				}
				/*				stickDiagram.moveHUD(sldScroller.viewport.horizontalScrollPosition+(sldScroller.viewport.width/2));
				var maxRightX:Number =  sldScroller.viewport.horizontalScrollPosition +  sldScroller.viewport.width-40;
				stickDiagram.updateCallOutXs(sldScroller.viewport.horizontalScrollPosition,maxRightX);
				//				stickDiagram.viewMileLabelMarkers.x = new Number(sldScroller.viewport.horizontalScrollPosition);
				//				stickDiagram.viewMileValueMarkers.x =  new Number(sldScroller.viewport.horizontalScrollPosition);
				if (guideBarSwitch)
				{
				var xForGuideB:Number =  sldScroller.viewport.horizontalScrollPosition+(sldScroller.viewport.width/2) ;
				stickDiagram.guideBar.x =xForGuideB;
				if (InvPanelContent=="bars")
				{
				invDiagram.guideBar.x =xForGuideB;
				}
				stickDrawing.routeHUD.updateGuideMile(Converter.scalePixelToMile(xForGuideB, this.scale));
				//					if (scrollerRunning)
				//					{
				//									
				//						stickDrawing.routeHUD.updateGuideMile(Converter.scalePixelToMile(xForGuideB, this.scale));
				//					}
				//					else if (stickDiagram.guideBar.x < sldScroller.viewport.horizontalScrollPosition)
				//					{
				////						stickDiagram.guideBar.x = sldScroller.viewport.horizontalScrollPosition;
				////						if (InvPanelContent=="bars")
				////						{
				////							invDiagram.guideBar.x =sldScroller.viewport.horizontalScrollPosition;
				////						}
				//						stickDiagram.routeHUD.updateGuideMile(Converter.scalePixelToMile(sldScroller.viewport.horizontalScrollPosition, this.scale));
				//						
				//					}
				//					else if (stickDiagram.guideBar.x >  maxRightX)
				//					{
				////						stickDiagram.guideBar.x =maxRightX;
				////						if (InvPanelContent=="bars")
				////						{
				////							invDiagram.guideBar.x =maxRightX;
				////						}
				//						stickDiagram.routeHUD.updateGuideMile(Converter.scalePixelToMile(maxRightX, this.scale));
				//					}
				}*/
			}
		}
		
		/**
		 * Moves drawn objects to the SLD diagram's current scroll position
		 * @param element
		 * @param index
		 * @param arr
		 * @priva
		 * 
		 */
		protected function moveLabels(element:DisplayObject, index:int, arr:Array):void
		{
			if (element!=null)
				element.x = _stickScroller.viewport.horizontalScrollPosition;
		}
		
		/**
		 * Sets bool that determines if the mouse was clicked down on the scrollbar 
		 * @param dir
		 * @private
		 * 
		 */
		protected function setScrollDown(dir:Boolean):void
		{
			scrollActionOn = true;
		}
		
		/**
		 * Sets bool that turns off the scroll action 
		 * @param event
		 * 
		 */
		protected function getScrollUpdates(event:MouseEvent):void{
			scrollActionOn = false; 
		}
		
		/**
		 * adds tooltip object to designated diagram
		 * @param tooltip
		 * @param dType
		 * 
		 */
		public function addToolTip(tooltip:Sprite, dType:int):void
		{
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
		
		/**
		 * removes tooltip object from the designated diagram
		 * @param tooltip
		 * @param dType
		 * 
		 */
		public function removeToolTip(tooltip:Sprite, dType:int):void
		{
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
		
		/**
		 *  draws guide bar on stick and inventory diagrams
		 * 
		 */
		public function turnGuideBarOn():void
		{
			if(!invDiagram)
				return;
			stickDiagram.drawGuideBar();
			invDiagram.drawGuideBar();
			guideBarSwitch = true;
		}
		
		/**
		 * removes guide bar from stick and inventory diagrams
		 * 
		 */
		public function turnGuideBarOff():void
		{
			stickDiagram.removeGuideBar();
			invDiagram.removeGuideBar();
			guideBarSwitch = false;
		}
		
		
		
		
		
		
		/**
		 *  this function triangulates to ensure the mouse up command fires to refresh 
		 if the user has activate the scrollbar but has moved of the scrollbar element
		 or if the user has activated the guidebar drag but moved of the guidebar before mouse up
		 * @param event
		 * 
		 */
		public function triangulateMouseUp(event:MouseEvent):void{
			if (scrollActionOn == true){
				getScrollUpdates(event);
			}
		}
		
		
		/**
		 * Returns whther the sroller running is on or off 
		 * @return 
		 * 
		 */
		protected function get scrollerRunning():Boolean
		{
			return runningScrlr;
		}
		protected function set scrollerRunning(running:Boolean):void
		{
			runningScrlr = running;
		}
		
		
		/**
		 * 
		 * @return 
		 * 
		 */
		protected function get leftPanel():Group
		{
			return leftPanelGroup;
		}
		
		protected function get guideBarStatus():Boolean
		{
			return guideBarSwitch;
		}
		
		/**
		 * Returns stickDiagram object 
		 * @return 
		 * 
		 */
		protected function get stickDrawing():StickDiagram
		{
			return stickDiagram;
		}
		
		/**
		 * Returns stick UI Border Container 
		 * @return 
		 * 
		 */
		protected function get stickBorder():BorderContainer
		{
			return sldBorder;
		}
		
		/**
		 * Returns stick group
		 * @return 
		 * 
		 */
		protected function get stickGroup():Group
		{
			return sldGroup;
		}
		
		/**
		 * Returns Invetory diagram
		 * @return 
		 * 
		 */
		protected function get inventoryDrawing():InventoryDiagram
		{
			return invDiagram;
		}
		
		
		/**
		 * Returns Invetory diagram
		 * @return 
		 * 
		 */
		protected function set inventoryDrawing(diag:InventoryDiagram):void
		{
			invDiagram = diag;
		}
		
		/**
		 * Returns inv UI Border Container 
		 * @return 
		 * 
		 */
		protected function get inventoryBorder():BorderContainer
		{
			return invBorder;
		}
		
		/**
		 * Returns inv group
		 * @return 
		 * 
		 */
		protected function get inventoryGroup():Group
		{
			return invGroup;
		}
		
		
		/**
		 * Returns the stick scroller
		 * @return 
		 * 
		 */
		protected function get stickScroller():Scroller
		{
			return _stickScroller;
		}
		
		/**
		 * Returns the stick scroller
		 * @return 
		 * 
		 */
		protected function get invScroller():Scroller
		{
			return _invScroller;
		}
		
		/**
		 * Sets SLD border container width 
		 * @param val
		 * 
		 */
		public function set sldBorderWidth(val:Number):void
		{
			sldBorder.width = val;
		}
		
		/**
		 * Sets Inventory border container width 
		 * @param val
		 * 
		 */
		public function set invBorderWidth(val:Number):void
		{
			invBorder.width = val;
		}
		
		
		
		/**
		 * sets/returns the current diagram scale
		 * @return Number
		 * 
		 */
		public function get scale():Number
		{
			return diagramScale;
		}
		
		public function set scale(scale:Number):void
		{
			diagramScale = scale;
			// dispatch scale change event
			//			var scaleEvent:MapOperationEvent = new MapOperationEvent(MapOperationEvent.MAP_SCALE_CHANGED);
			//			dispatchEvent(scaleEvent);
		}
		
		/**
		 * sets/returns the current diagram view mile
		 * @return Number
		 * 
		 */
		public function get viewMile():Number
		{
			return Converter.scalePixelToMile(stickScroller.viewport.horizontalScrollPosition,this.scale);
		}
		public function set viewMile(vMile:Number):void
		{
			diagramViewMile = vMile;
			stickScroller.viewport.horizontalScrollPosition = Converter.scaleMileToPixel(vMile,this.scale);
		}
		
		/**
		 * returns current diagram route 
		 * @return 
		 * 
		 */
		public function get getRoute():Route
		{
			if (!stickDiagram)
				return null;
			
			return stickDiagram.route; //gets route
		}
		
		/**
		 *  returns diagrams layout type
		 * @return VerticalLayout
		 * 
		 */
		private function get horizontalLayout():HorizontalLayout
		{
			return HorizontalLayout(layout);
		}
		
		[Inspectable(category="General")]
		/**
		 * sets/returns diagrams gap 
		 * @return int
		 * 
		 */
		public function get gap():int
		{
			return horizontalLayout.gap;
		}
		
		public function set gap(value:int):void
		{
			horizontalLayout.gap = value;
		}
		
		[Inspectable(category="General", enumeration="left,right,center,justify,contentJustify", defaultValue="left")]
		/**
		 * sets/returns diagram horizontal alignment 
		 * @return 
		 * 
		 */
		public function get horizontalAlign():String
		{
			return horizontalLayout.horizontalAlign;
		}
		
		public function set horizontalAlign(value:String):void
		{
			horizontalLayout.horizontalAlign = value;
		}		
		
		
		[Inspectable(category="General", enumeration="top,bottom,middle", defaultValue="top")]
		/**
		 * sets/returns diagram vertical alignment 
		 * @return 
		 * 
		 */
		public function get verticalAlign():String
		{
			return horizontalLayout.verticalAlign;
		}
		
		public function set verticalAlign(value:String):void
		{
			horizontalLayout.verticalAlign = value;
		}
		
		[Inspectable(category="General")]
		/**
		 *  sets/returns the minimum number of pixels between the diagram's left edge and
		 *  the left edge of the [internal] layout element.
		 * 
		 *  @default 0
		 *  
		 */
		public function get paddingLeft():Number
		{
			return horizontalLayout.paddingLeft;
		}
		
		public function set paddingLeft(value:Number):void
		{
			horizontalLayout.paddingLeft = value;
		}
		
		[Inspectable(category="General")]
		/**
		 *  sets/returns the minimum number of pixels between the diagram's right edge and
		 *  the right edge of the [internal] layout element.
		 * 
		 *  @default 0
		 *  
		 */		
		public function get paddingRight():Number
		{
			return horizontalLayout.paddingRight;
		}
		
		public function set paddingRight(value:Number):void
		{
			horizontalLayout.paddingRight = value;
		}
		
		[Inspectable(category="General")]
		/**
		 *  sets/returns the minimum number of pixels between the diagram's top edge and
		 *  the top edge of the [internal] layout element.
		 * 
		 *  @default 0
		 *  
		 */
		public function get paddingTop():Number
		{
			return horizontalLayout.paddingTop;
		}
		
		public function set paddingTop(value:Number):void
		{
			horizontalLayout.paddingTop = value;
		}
		
		[Inspectable(category="General")]
		/**
		 *  sets/returns the minimum number of pixels between the diagram's bottom edge and
		 *  the bottom edge of the [internal] layout element.
		 * 
		 *  @default 0
		 *  
		 */
		public function get paddingBottom():Number
		{
			return horizontalLayout.paddingBottom;
		}
		
		public function set paddingBottom(value:Number):void
		{
			horizontalLayout.paddingBottom = value;
		}
		
		/**
		 *Returns whether the scroll action is on 
		 * @return 
		 * 
		 */
		protected function get scrollOn():Boolean
		{
			return scrollActionOn;
		}
		
		/**
		 *Returns whether the guide bar is on 
		 * @return 
		 * 
		 */
		protected function get guideBarOn():Boolean
		{
			return guideBarSwitch;
		}
		protected function get InvPanelContent():String
		{
			return invPanelContent;
		}
		
		
		protected function get screenWidth():Number
		{
			return screenWidthforViewM;
		}
		
		protected function set screenWidth(width:Number):void
		{
			screenWidthforViewM= width;
		}
		/**
		 * adds event listener to diagram 
		 * @param type
		 * @param listener
		 * @param useCapture
		 * @param priority
		 * @param useWeakReference
		 * 
		 */
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			switch(type)
			{
				case "indexInViewChanged":
				case "propertyChange":
					if (!hasEventListener(type))
						horizontalLayout.addEventListener(type, redispatchHandler);
					break;
			}
			super.addEventListener(type, listener, useCapture, priority, useWeakReference)
		}    
		
		/**
		 * removes event listener from diagram 
		 * @param type
		 * @param listener
		 * @param useCapture
		 * 
		 */
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			super.removeEventListener(type, listener, useCapture);
			switch(type)
			{
				case "indexInViewChanged":
				case "propertyChange":
					if (!hasEventListener(type))
						horizontalLayout.removeEventListener(type, redispatchHandler);
					break;
			}
		}
		
		/**
		 * Dispatches Events 
		 * @param event
		 * 
		 */
		private function redispatchHandler(event:Event):void
		{
			dispatchEvent(event);
		}
		
	}
}