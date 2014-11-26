package com.transcendss.transcore.events
{
	import flash.events.Event;
	
	public class ConfigManagerEvent extends Event
	{
		public static const GUIDEBAR_CHANGED:String = "configManagerGuideBarChanged";
		public static const INV_PANEL_VIEW_CHANGED:String = "configManagerInvFormViewChanged";
		public static const MEASUREBAR_SWITCH_CHANGED:String = "configManagerFeetMarkerSwitchChanged";
		public static const LINEAREDITING_SWITCH_CHANGED:String = "configManagerLinearEditingSwitchChanged";
		public static const MEASUREBAR_UNIT_CHANGED:String = "configManagerMeasureBarUnitChanged";
		public static const ASSET_SWITCH_CHANGED:String = "configManagerassetSwitchChanged";
		public static const SYNC_TYPE_CHANGED:String = "configManagerSyncTypeChanged";
		public static const ROADWAYLANES_SWITCH_CHANGED:String = "configManagerRoadwayLanesSwitchChanged";

		private var guideBarNewVal:Boolean;
		private var _panelContent:String;
		private var _newUnit:Number;
		
		private var _assetSwitchObj:Object = new Object();
		
		public function ConfigManagerEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
		}
		
		public function get NewValue():Boolean
		{
			return guideBarNewVal;
		}
		
		public function set NewValue(val:Boolean):void
		{
			guideBarNewVal=val;
		}
		
		public function get assetSwitchObj():Object
		{
			return _assetSwitchObj;
		}
		
		public function set assetSwitchObj(val:Object):void
		{
			_assetSwitchObj=val;
		}
		
		public function get NewUnit():Number
		{
			return _newUnit;
		}
		
		public function set NewUnit(val:Number):void
		{
			_newUnit=val;
		}
		
		public function get PanelContent():String
		{
			return _panelContent;
		}
		
		public function set PanelContent(val:String):void
		{
			_panelContent=val;
		}
		
		
	}
}