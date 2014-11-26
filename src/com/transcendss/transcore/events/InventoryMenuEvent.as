package com.transcendss.transcore.events
{
	import com.transcendss.transcore.sld.models.components.Materials;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class InventoryMenuEvent extends Event
	{
		public static const CULVERT_MATERIAL_REQUEST:String = "InventoryMenuEvent_materialRequest";
		public static const CULVERT_MATERIAL_READY:String = "InventoryMenuEvent_materialReady";
		public static const CULVERT_SHAPE_REQUEST:String = "InventoryMenuEvent_shapeRequest";
		public static const CULVERT_SHAPE_READY:String = "InventoryMenuEvent_shapeReady";
		public static const CULVERT_PLACEMENT_REQUEST:String = "InventoryMenuEvent_placementRequest";
		public static const CULVERT_PLACEMENT_READY:String = "InventoryMenuEvent_placementReady";
		public static const CULVERT_JOINTLOC_REQUEST:String = "InventoryMenuEvent_jointlocRequest";
		public static const CULVERT_JOINTLOC_READY:String = "InventoryMenuEvent_jointlocReady";
		public static const CULVERT_ABUTMENT_REQUEST:String = "InventoryMenuEvent_abutmentRequest";
		public static const CULVERT_ABUTMENT_READY:String = "InventoryMenuEvent_abutmentReady";
		public static const CULVERT_BEAM_REQUEST:String = "InventoryMenuEvent_beamRequest";
		public static const CULVERT_BEAM_READY:String = "InventoryMenuEvent_beamReady";
		public static const CULVERT_GENERAL_REQUEST:String = "InventoryMenuEvent_generalRequest";
		public static const CULVERT_GENERAL_READY:String = "InventoryMenuEvent_generalReady";
		public static const CULVERT_FLOW_REQUEST:String = "InventoryMenuEvent_flowRequest";
		public static const CULVERT_FLOW_READY:String = "InventoryMenuEvent_flowReady";
		public static const CULVERT_JOINT_REQUEST:String = "InventoryMenuEvent_jointRequest";
		public static const CULVERT_JOINT_READY:String = "InventoryMenuEvent_jointReady";
		public static const CULVERT_BARREL_REQUEST:String = "InventoryMenuEvent_barrelRequest";
		public static const CULVERT_BARREL_READY:String = "InventoryMenuEvent_barrelReady";
		public static const CULVERT_CHANNEL_REQUEST:String = "InventoryMenuEvent_channelRequest";
		public static const CULVERT_CHANNEL_READY:String = "InventoryMenuEvent_channelReady";
		public static const CULVERT_CULVERTENDS_REQUEST:String = "InventoryMenuEvent_culvertendsRequest";
		public static const CULVERT_CULVERTENDS_READY:String = "InventoryMenuEvent_culvertendsReady";
		public static const CULVERT_MAINT_REQUEST:String = "InventoryMenuEvent_maintRequest";
		public static const CULVERT_MAINT_READY:String = "InventoryMenuEvent_maintReady";
		public static const CULVERT_MAINT_EQUIP_REQUEST:String = "InventoryMenuEvent_maintEquipRequest";
		public static const CULVERT_MAINT_EQUIP_READY:String = "InventoryMenuEvent_maintEquipReady";
		public static const CULVERT_GEOTAG_REQUEST:String = "InventoryMenuEvent_geotagRequest";
		public static const CULVERT_GEOTAG_READY:String = "InventoryMenuEvent_geotagReady";
		public static const CULVERT_INSP_HISTORY_REQUEST:String = "InventoryMenuEvent_inspHistoryRequest";
		public static const CULVERT_INSP_HISTORY_READY:String = "InventoryMenuEvent_inspHistoryReady";
		public static const CULVERT_INSP_DATE_POPULATE:String = "InventoryMenuEvent_inspDatePopulate";
		
		public var serviceURL:String;
		private var _description:Materials;
		private var _dataProviderAC:ArrayCollection = new ArrayCollection();
		private var _inspHistoryJson:String;
		
		public function InventoryMenuEvent(type:String, description:Materials = null, bubbles:Boolean = true, cancellable:Boolean = true)
		{
			_description = description;
			super(type, bubbles, cancellable);
		}
		
		public function get inspHistoryJson():String
		{
			return _inspHistoryJson;
		}

		public function set inspHistoryJson(value:String):void
		{
			_inspHistoryJson = value;
		}

		public function get description():Materials
		{
			return _description;
		}
		
		public function get dataProviderAC():ArrayCollection
		{
			return _dataProviderAC;
		}
		
		public function set dataProviderAC(value:ArrayCollection):void
		{
			_dataProviderAC = value;
		}
		
		
		
	}
}