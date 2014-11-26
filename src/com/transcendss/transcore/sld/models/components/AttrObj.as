package com.transcendss.transcore.sld.models.components
{
	
	import com.asfusion.mate.events.Dispatcher;
	
	import mx.core.*;
	
	[Bindable]
	public class AttrObj
	{
		public var attrType:String;
		public var ID:Number;
		public var Clicked_Milepoint:Number;
		public var Route_Name:String;
		public var RouteFullName:String;
		public var Begin_Mile:Number;
		public var End_Mile:Number;
		public var route_Begin_Mile:Number;
		public var route_End_Mile:Number;
		public var Value:Number;
		public var Description:String;
		public var elemName:String;
		public var status:String;
		
		private var dispatcher:Dispatcher = new Dispatcher();
		
		// Save the bar element attribute changes to the local database for later syncing to the main db
		public function saveAttr(obj:AttrObj):void{
			var tmpElem:Object = new Object();
			tmpElem["ID"] = obj.ID;
			tmpElem["ROUTE"] = obj.Route_Name;
			tmpElem["ROUTE_NAME"] = obj.RouteFullName;
			tmpElem["REFPT"] = obj.Begin_Mile;
			tmpElem["ENDREFPT"] = obj.End_Mile;
			tmpElem["ELEM_VALUE"] = obj.Value;
			tmpElem["ELEM_DESC"] = obj.Description;
			tmpElem["STATUS"] = obj.status;
			if(obj.status != "NEW")
				tmpElem["STATUS"] = "EDITED";
			
			AttrObj(FlexGlobals.topLevelApplication.currAttrObj).Value = obj.Value;
			AttrObj(FlexGlobals.topLevelApplication.currAttrObj).Begin_Mile = obj.Begin_Mile;
			AttrObj(FlexGlobals.topLevelApplication.currAttrObj).End_Mile = obj.End_Mile;

			var elem:BaseAsset = FlexGlobals.topLevelApplication.GlobalComponents.assetManager.mapDataToBaseAsset(tmpElem, tmpElem.ELEM_DESC, false);
			FlexGlobals.topLevelApplication.GlobalComponents.assetManager.saveBarElement(elem);
			FlexGlobals.topLevelApplication.redrawRoute();
		}
	}
}