package com.transcendss.transcore.util
{

	
	import com.asfusion.mate.events.Dispatcher;
	import com.transcendss.transcore.events.ConfigManagerEvent;
	import com.transcendss.transcore.events.ExternalFileEvent;
	
	import mx.collections.ArrayCollection;
	import mx.core.*;
	import mx.core.ByteArrayAsset;
	import mx.events.PropertyChangeEvent;
	
	[Bindable]
	public class ConfigurationManager
	{ 
		private var configArray:ArrayCollection = null;
		private var settingsAC:ArrayCollection= null;
		private var rWidth:Number;
		private var rColor:uint;
		private var sColor:uint;
		private var scale:Number;
		private var scaleValArr:Array;
		private var dataElemArr:Array;
		private var dataElemDtlsArr:Array;
		private var sURL:String;
		private var mateDispatcher:Dispatcher = new Dispatcher();
		private var attrView:Boolean;
		private var vlImageSize:String;
		private var gdeBarSwitch:Boolean;
		private var invFrmSwitch:Boolean;
		private var btmPanelContent:String = ""; 
		
		public function ConfigurationManager()
		{
//			var event:ExternalFileEvent = new ExternalFileEvent(ExternalFileEvent.FILE_REQUESTED,"../Files/settings.txt", "settings");
			var event:ExternalFileEvent = new ExternalFileEvent(ExternalFileEvent.FILE_REQUESTED,"https://s3.amazonaws.com/roadanalyzer/settings.txt", "settings");
			mateDispatcher.dispatchEvent(event);
//			event = new ExternalFileEvent(ExternalFileEvent.FILE_REQUESTED,"../Files/config.txt", "config");
			event = new ExternalFileEvent(ExternalFileEvent.FILE_REQUESTED,"https://s3.amazonaws.com/roadanalyzer/config.txt", "config");
			mateDispatcher.dispatchEvent(event);
		}
		
		public function set settingsArrayColl(stngsAC:ArrayCollection):void
		{
			settingsAC = stngsAC;
			rWidth = new Number(String(settingsAC.getItemAt(0).RoadWidth));
			rColor = new uint(String(settingsAC.getItemAt(0).RoadColor));
			sColor = new uint(String(settingsAC.getItemAt(0).StripeColor));
			scale = new int(String(settingsAC.getItemAt(0).DefaultScale));
			gdeBarSwitch =String(settingsAC.getItemAt(0).GuideBarView)=="on"?true:false ;
			scaleValArr = String(settingsAC.getItemAt(0).ScaleValues).split(",");
			dataElemArr = String(settingsAC.getItemAt(0).DataElements).split(",");
			dataElemDtlsArr = settingsAC.getItemAt(0).DataElementSettings;
			//attrView = String(settingsAC.getItemAt(0).AttributeTableView)=="on"?true:false ;
			vlImageSize = String(settingsAC.getItemAt(0).VLCntrlButtonSize);
			gdeBarSwitch =String(settingsAC.getItemAt(0).GuideBarView)=="on"?true:false ;
			var con:String = String(settingsAC.getItemAt(0).BottomPanelContent);
			btmPanelContent = con=="form"?"form":con=="bars"?"bars":"settings";
			var event:ExternalFileEvent = new ExternalFileEvent(ExternalFileEvent.CONFIG_FILE_LOADED);
			mateDispatcher.dispatchEvent(event);
		}
		
		public function set guideBarSwitch(swtch:Boolean):void{
			gdeBarSwitch = swtch;
			var eventObj:ConfigManagerEvent = new ConfigManagerEvent(ConfigManagerEvent.GUIDEBAR_CHANGED);
			eventObj.NewValue = swtch;
			mateDispatcher.dispatchEvent(eventObj);
		}
		
		[Bindable(event="configManagerGuideBarChanged")]
		public function get guideBarSwitch():Boolean{
			return gdeBarSwitch;
		}
		
		public function set configArrayColl(configAC:ArrayCollection):void
		{
			configArray = configAC;
			sURL = String(configAC.getItemAt(0).ServiceURL);
		}
		
		public function get settingsArrayColl():ArrayCollection
		{
			return settingsAC;
		}
		
		public function get configArrayColl():ArrayCollection
		{
			return configArray;
		}
		
		public function get roadWidth():Number
		{
			return rWidth;
		}
		
		public function set roadWidth(rw:Number):void
		{
			var old:Number = rWidth;
			rWidth =rw;
		}
		
		public function get roadColor():uint
		{
			return rColor;
		}
		
		public function set roadColor(rc:uint):void
		{
			var old:uint = rColor;
			rColor =rc;
		}
		public function get stripeColor():uint
		{
			return sColor;
		}
		
		public function set stripeColor(sc:uint):void
		{
			var old:uint = sColor;
			sColor =sc;
		}
		public function get defaultScale():Number
		{
			return scale;
		}
		
		public function set defaultScale(s:Number):void
		{
			scale =s;
		}
		public function get scaleValues():Array
		{
			return scaleValArr;
		}
		
		public function set scaleValues(sv:Array):void
		{
			scaleValArr =sv;
		}
		public function get dataElementValues():Array
		{
			return dataElemArr;
		}
		
		public function set dataElementValues(sv:Array):void
		{
			dataElemArr =sv;
		}	
		
		public function get dataElementDetails():Array
		{
			return dataElemDtlsArr;
		}
		
		public function set dataElementDetails(sv:Array):void
		{
			dataElemDtlsArr =sv;
		}
		
		public function get serviceURL():String
		{
			return sURL;
		}
		public function set serviceURL(url:String):void
		{
			sURL = url;
		}
		
//		public function get AttributeTableView():Boolean
//		{
//			return attrView;
//		}
//		public function set AttributeTableView(viewType:Boolean):void
//		{
//			attrView = viewType;
//		}
		
		public function get VLImageSize():String
		{
			return vlImageSize;
		}
		public function set VLImageSize(size:String):void
		{
			vlImageSize = size;
		}
		public function set invPanelContent(swtch:String):void{
			if (swtch != btmPanelContent)
			{
				btmPanelContent = swtch;
				var eventObj:ConfigManagerEvent = new ConfigManagerEvent(ConfigManagerEvent.INV_PANEL_VIEW_CHANGED);
				eventObj.PanelContent = swtch;
				mateDispatcher.dispatchEvent(eventObj);
			}
		}
		
		[Bindable(event="configManagerInvPanelViewChanged")]
		public function get invPanelContent():String{
			return btmPanelContent;
		}
	}
}