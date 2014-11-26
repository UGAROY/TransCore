package com.VideoPlayer.toky.video
{
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.geom.Point;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class VidStream extends Video
	{
		private var _autoplay:Boolean;
		private var _ns:NetStream;
		private var _flvpath:String;
		private var _cliplength:Number;
		private var _hw:Point;
		
		public function VidStream(path:String, w:int, h:int, autoplay:Boolean)
		{
			super();
			_hw = new Point(w, h);
			_autoplay = autoplay;
			_flvpath = path;
			
			this.smoothing = true;
			init();
		}
		
		private function init():void {
			this.hide();
			
			var nc:NetConnection = new NetConnection();
			nc.connect(null);
			
			_ns = new NetStream(nc);
			_ns.bufferTime = 3;
			_ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			
			var meta:Object = new Object();
			meta.onMetaData = function(meta:Object):void
			{
				resizevideo();
				_cliplength = meta.duration;
				var evt:Event = new Event("VIDEO_READY");
				
				dispatchEvent(evt);
			}
			
			_ns.client = meta;
			this.attachNetStream(_ns);	
			
			//connect media, go to first frame
			
			_ns.play(_flvpath);
			_ns.seek(0);
			
			if (!_autoplay) {
				_ns.pause();	
			}
		}
		
		private function netStatusHandler(e:NetStatusEvent):void{
			
			switch(e.info.code){
				case "NetConnection.Connect.Success":
					break;
				case "NetStream.Play.StreamNotFound":
					break;
		        case "NetStream.Play.Stop":
		        	//trace(e.info.code);
		        	if (_cliplength && (_ns.time/_cliplength == 1)) {
		        		dispatchEvent(new Event("VIDEO_COMPLETE"));	
		        	} else {
		        		//false stop
		        		//trace("bad stop");
		        	}
		        	break;
			}
		}
		
		private function resizevideo():void {
			
			//size for width
			this.height = _hw.y;
			this.scaleX = this.scaleY;
			
			//check for width hangover
			if (this.width > _hw.x) {
				this.width = _hw.x;
				this.scaleY = this.scaleX;
			}

			//center
			this.y = _hw.y/2 - this.height/2;
			this.x = _hw.x/2 - this.width/2;
		}
		
		/**
		 * INTERNAL FUNCTIONS
		 **/
		
		internal function streampause():void {
			_ns.pause();
		}
		
		internal function streamresume():void {
			_ns.resume();
		}
		
		internal function getPercentLoaded():Number {
			var _pctloaded:Number = _ns.bytesLoaded / _ns.bytesTotal;
			return _pctloaded;
		}
		
		internal function getPlayhead():Number {
			var pctplayed:Number = _ns.time / _cliplength;
			return pctplayed;
		}
		
		internal function seekTo(pct:Number):void {
			var newPctPlayed:Number = pct * _cliplength;
			_ns.seek(newPctPlayed);
		}
		
		internal function getCurrentTime():Point {
			var time_point:Point = new Point();
			time_point.x = _ns.time;
			time_point.y = _cliplength;
			return time_point;
		}
		
		internal function setVolume(pct:Number):void {
			var st:SoundTransform = new SoundTransform(pct,0);
			_ns.soundTransform = st;
		}
		
		internal function destroy():void {
			_ns.close();
		}
		
		/**
		 * PUBLIC FUNCTIONS
		 **/
		 
		 public function show():void {
		 	this.alpha = 1;
		 	this.visible = true;
		 }
		 
		 public function hide():void {
		 	this.alpha = 0;
		 	this.visible = false;
		 }

	}
}