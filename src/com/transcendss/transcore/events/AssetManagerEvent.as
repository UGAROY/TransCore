package com.transcendss.transcore.events
{
	import com.transcendss.transcore.sld.models.components.BaseAsset;
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class AssetManagerEvent extends Event
	{
		public static const CULVERT_MATERIAL_REQUEST:String = "AssetManagerEvent_materialRequest";
		public static const CULVERT_MATERIAL_READY:String = "AssetManagerEvent_materialReady";
		public static const CULVERT_SHAPE_REQUEST:String = "AssetManagerEvent_shapeRequest";
		public static const CULVERT_SHAPE_READY:String = "AssetManagerEvent_shapeReady";
		public static const CULVERT_PLACEMENT_REQUEST:String = "AssetManagerEvent_placementRequest";
		public static const CULVERT_PLACEMENT_READY:String = "AssetManagerEvent_placementReady";
		public static const CULVERT_JOINTLOC_REQUEST:String = "AssetManagerEvent_jointlocRequest";
		public static const CULVERT_JOINTLOC_READY:String = "AssetManagerEvent_jointlocReady";
		public static const CULVERT_ABUTMENT_REQUEST:String = "AssetManagerEvent_abutmentRequest";
		public static const CULVERT_ABUTMENT_READY:String = "AssetManagerEvent_abutmentReady";
		public static const CULVERT_BEAM_REQUEST:String = "AssetManagerEvent_beamRequest";
		public static const CULVERT_BEAM_READY:String = "AssetManagerEvent_beamReady";
		public static const CULVERT_GENERAL_REQUEST:String = "AssetManagerEvent_generalRequest";
		public static const CULVERT_GENERAL_READY:String = "AssetManagerEvent_generalReady";
		public static const CULVERT_FLOW_REQUEST:String = "AssetManagerEvent_flowRequest";
		public static const CULVERT_FLOW_READY:String = "AssetManagerEvent_flowReady";
		public static const CULVERT_JOINT_REQUEST:String = "AssetManagerEvent_jointRequest";
		public static const CULVERT_JOINT_READY:String = "AssetManagerEvent_jointReady";
		public static const CULVERT_BARREL_REQUEST:String = "AssetManagerEvent_barrelRequest";
		public static const CULVERT_BARREL_READY:String = "AssetManagerEvent_barrelReady";
		public static const CULVERT_CHANNEL_REQUEST:String = "AssetManagerEvent_channelRequest";
		public static const CULVERT_CHANNEL_READY:String = "AssetManagerEvent_channelReady";
		public static const CULVERT_CULVERTENDS_REQUEST:String = "AssetManagerEvent_culvertendsRequest";
		public static const CULVERT_CULVERTENDS_READY:String = "AssetManagerEvent_culvertendsReady";
		public static const CULVERT_MAINT_REQUEST:String = "AssetManagerEvent_maintRequest";
		public static const CULVERT_MAINT_READY:String = "AssetManagerEvent_maintReady";
		public static const MULTIPLE_DOMAINS_REQUEST:String = "AssetManagerEvent_multipleDomainsRequest";
		public static const MULTIPLE_DOMAINS_READY:String = "AssetManagerEvent_multipleDomainsReady";
		public static const ASSET_SELECTED_EVENT:String = "AssetManagerEvent_assetSelectedEvent";
		
		public var serviceURL:String;
		private var _dataProviderAC:ArrayCollection = new ArrayCollection();
		private var _asset:BaseAsset;
		private var _x:Number;
		private var _y:Number;
		
		public function AssetManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, ac:ArrayCollection = null, asset:BaseAsset=null)
		{
			super(type, bubbles, cancelable);
			_dataProviderAC = ac;
			_asset = asset;
		}
		
		public function get x():Number
		{
			return _x;
		}
		
		public function set x(value:Number):void
		{
			_x= value;
		}
		
		public function get y():Number
		{
			return _y;
		}
		
		public function set y(value:Number):void
		{
			_y = value;
		}
		
		
		
		public function get dataProviderAC():ArrayCollection
		{
			return _dataProviderAC;
		}
		
		public function set dataProviderAC(value:ArrayCollection):void
		{
			_dataProviderAC = value;
		}
		
		public function get asset():BaseAsset
		{
			return _asset;
		}
		
		public function set asset(value:BaseAsset):void
		{
			_asset = value;
		}
		
	}
}