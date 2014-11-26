package com.transcendss.transcore.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class MenuBarEvent extends Event
	{
		public static const ROUTE_SAVED:String = "menuBarEvent_routeSaved";
		public static const ROUTE_LOADED:String = "menuBarEvent_routeLoaded";
		public static const CREATE_MENU:String = "menuBarEvent_menuCreate";
		public static const MENU_READY:String ="menuBarEvent_menuReady";
		public static const MENU_CLICKED:String ="menuBarEvent_menuClicked";
		public static const SETTINGS_ENABLED:String = "menuBarEvent_settingsEnabled";
		public static const ROUTE_SELECTOR_ENABLED:String = "menuBarEvent_rteSelectorEnabled";
		public static const CONTROLBAR_ENABLED:String = "menuBarEvent_controlbarEnabled";
		public static const DRIVEMAP_ENABLED:String = "menuBarEvent_drivemapEnabled";
		public static const OVERVIEW_ENABLED:String = "menuBarEvent_overviewEnabled";
		public static const FULL_SCREEN_ENABLED:String = "menuBarEvent_fullScreenEnabled";
		public static const QUERY_SELECTOR_ENABLED:String = "menuBarEvent_querySelectorEnabled";
		public static const DISTRICT_CHANGED:String = "menuBarEvent_districtChanged";
		public static const INSP1_CHANGED:String = "menuBarEvent_insp1Changed";
		public static const INSP2_CHANGED:String = "menuBarEvent_insp2Changed";
		private var itemAC:ArrayCollection;
		private var itemName:String;
		private var toggled:Boolean;
		private var _insp1:String;
		private var _insp2:String;
		private var _dist:String;
		
		
		public function MenuBarEvent(type:String, items:ArrayCollection = null, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
			itemAC = items;
		}
		
		public function get dist():String
		{
			return _dist;
		}

		public function set dist(value:String):void
		{
			_dist = value;
		}

		public function get insp2():String
		{
			return _insp2;
		}

		public function set insp2(value:String):void
		{
			_insp2 = value;
		}

		public function get insp1():String
		{
			return _insp1;
		}

		public function set insp1(value:String):void
		{
			_insp1 = value;
		}

		public function get menuItems():ArrayCollection
		{
			return itemAC;
		}
		public function set clickedItem(item:String):void
		{
			itemName = item;
		}
		
		public function set itemToggled(toggle:Boolean):void
		{
			toggled = toggle;
		}
		
		public function get clickedItem():String
		{
			return itemName;
		}
		
		public function get itemToggled():Boolean
		{
			return toggled;
		}
		
		public var scale:Number ;
	}
}