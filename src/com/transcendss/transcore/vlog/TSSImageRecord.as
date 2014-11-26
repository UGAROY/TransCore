package com.transcendss.transcore.vlog
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.*;
	
	import mx.controls.Alert;

	public class TSSImageRecord
	{
		public var id:String;
		public var urls:Array = new Array();
		public var loaders:Array = new Array();
		
		public var x:Number = 0.0;
		public var y:Number = 0.0;
		public var mp:Number = 0.0;
		public var angle:Number = 0.0;
		
		public var routeID:String;
		public var direction:String;
		
		public function TSSImageRecord(iid:String, ix:Number, iy:Number, imp:Number, ang:Number, rtid:String, dir:String)
		{
			id = iid;
			x = ix;
			y = iy;
			mp = imp;
			angle=ang;
			routeID = rtid;
			direction = dir;
		}
		
		public function addImage(position:int, url:String):void
		{
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.checkPolicyFile = true;
			var myLoader:TSSImageLoader = new TSSImageLoader();
			myLoader.position = position;
			myLoader.url = url;
			myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderReady);
			myLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			myLoader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			var fileRequest:URLRequest = new URLRequest(url);
			myLoader.load(fileRequest, loaderContext);
		}
		
		public function getURL(index:Number):String
		{
			return urls[index];
		}
		
		public function getLoader(index:Number):TSSImageLoader
		{
			return loaders[index] as TSSImageLoader;	
		}
		
		public function onLoaderReady(e:Event):void { 
			var doneloaderinfo:LoaderInfo = e.target as LoaderInfo;
			var doneloader:TSSImageLoader = doneloaderinfo.loader as TSSImageLoader;
			this.loaders[doneloader.position] = doneloader;
			this.urls[doneloader.position] = doneloader.url;
		}
		
		public function onSecurityError(e:SecurityErrorEvent):void { 
			Alert.show(e.toString());
		}
		
		public function onIOError(e:IOErrorEvent):void { 
			//Alert.show(e.toString());
		}
		
	}
}