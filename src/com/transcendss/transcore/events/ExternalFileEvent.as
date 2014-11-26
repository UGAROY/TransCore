package com.transcendss.transcore.events
{
	import com.transcendss.transcore.sld.models.components.BaseAsset;
	
	import flash.events.Event;
	
	import mx.rpc.IResponder;

	public class ExternalFileEvent extends Event
	{
		
		public static const FILE_REQUESTED:String = "ExternalFileEvent_filerequested";
		public static const LOCAL_FILE_REQUESTED:String = "ExternalFileEvent_localfilerequested";
		public static const FILE_READY:String = "ExternalFileEvent_fileReady";
		public static const CONFIG_FILE_LOADED:String = "ExternalFileEvent_configfileloaded";
		public static const ASSET_DEF_FILE_REQUESTED:String = "ExternalFileEvent_assetdefFileRequested";
		public static const ASSET_TEMPL_FILE_REQUESTED:String = "ExternalFileEvent_assettemplFileRequested";
		public static const ASSET_SYMBL_REQUESTED:String = "ExternalFileEvent_assetSymblRequested";
		public static const ALT_SUBTYPE_DRAWSTRING_REQUESTED:String = "ExternalFileEvent_altSubtypeDrawstringRequested";
		public static const QUERY_DEF_FILE_REQUESTED:String = "ExternalFileEvent_querydefFileRequested";
		public static const DATAENTRY_TEMPL_FILE_REQUESTED:String = "ExternalFileEvent_dataEntrytemplFileRequested";

		private var fileURL:String;
		private var fName:String;
		private var _responder:IResponder;
		private var _featureType:String;
		private var _bAsset:BaseAsset;
		private var _subTypeObj:Object;
		private var _subTypeCount:Number;
		private var _altType:Number;
		
		public function ExternalFileEvent(type:String, filePath:String=null, fileName:String=null, bubbles:Boolean = true, cancellable:Boolean = true)
		{
			fileURL = filePath;
			fName = fileName;
			super(type, bubbles,cancellable);
			
		}
		
		public function get subTypeObj():Object{
			return _subTypeObj;
		}
		public function set subTypeObj(b:Object):void{
			_subTypeObj=b;
		}
		public function get subTypeCount():Number{
			return _subTypeCount;
		}
		public function set subTypeCount(b:Number):void{
			_subTypeCount=b;
		}
		
		public function get altType():Number{
			return _altType;
		}
		public function set altType(b:Number):void{
			_altType=b;
		}
		
		public function get bAsset():BaseAsset{
			return _bAsset;
		}
		public function set bAsset(b:BaseAsset):void{
			_bAsset=b;
		}
		public function get featureName():String{
			return _featureType;
		}
		public function set featureName(typ:String):void{
			_featureType=typ;
		}
		public function get responder():IResponder
		{
			return _responder;
		}
		
		public function set responder(value:IResponder):void
		{
			_responder = value;
		}
		
		public function get filePath():String
		{
			return fileURL;
		}
		public function set filePath(filePath:String):void
		{
			fileURL = filePath;
		}
		
		public function get fileName():String
		{
			return fName;
		}
		public function set fileName(name:String):void
		{
			fName = name;
		}
	}
}