package com.VideoPlayer.toky.video {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class TokyVideoPlayer extends Sprite
	{
		protected var playpause:PlayPause;
		protected var scrubber:Scrubber;
		protected var volume:Volume;
		protected var caption:Caption;
		protected var posterimg:PosterImg;
		protected var path:String;
		protected var timecounter:TimeCounter;
		protected var vidstream:VidStream; 
		protected var autoplay:Boolean;
		protected var ui:Sprite;
		protected var hw:Point;
		private var isplaying:Boolean;
		private var isdragging:Boolean;
		
		public function TokyVideoPlayer(vidpath:String, w:int, h:int, posterpath:String = "", hasvol:Boolean = false, hastimecount:Boolean = false, captionpath:String = null)
		{
			autoplay = true;
			
			hw = new Point(w, h);
			
			path = vidpath;
			
			ui = new Sprite();
			
			//first load poster if there is one
			if (posterpath!="") {
				autoplay  = false;
				posterimg = new PosterImg(posterpath, w, h);
				posterimg.addEventListener("POSTER_LOADED", setupvidstream);
				posterimg.addEventListener("CLICK_POSTER", clickposter);
				ui.addChild(posterimg);
			} else {
				setupvidstream();
			}
			
			/* UNDER DEVELOPMENT
			if (hasvol) {
			volume = new Volume();
			//addEventListener("VOLUME_CHANGE", volumeEvent);
			//ui.addChild(volume);
			}
			*/
			
			if (hastimecount) {
				timecounter = makeCounter();
				ui.addChild(timecounter);
			}
			
			/* UNDER DEVELOPMENT
			if (caption) {
			caption = new Caption();
			ui.addChild(caption);
			}
			*/
			
			playpause = makePlayPause();
			this.addEventListener("CLICK_PLAYPAUSE", clickplaypause);//listens for bubble
			ui.addChild(playpause);	
			
			scrubber = makeScrubber();
			ui.addChild(scrubber);
			
			isplaying = autoplay;
		}
		
		//then setup the video stream
		private function setupvidstream(e:Event = null):void {
			vidstream = new VidStream(path, hw.x, hw.y, autoplay);
			vidstream.addEventListener("VIDEO_READY", videoready);
			vidstream.addEventListener("VIDEO_COMPLETE", videoEnd);
			addChild(vidstream);
		}
		
		//once it's ready, show stuff		
		private function videoready(e:Event):void {
			positionUI();
			addChild(ui);
			show();
			//if 
			
			scrubber.addEventListener("DRAG_ON", setdrag);
			scrubber.addEventListener("DRAG_OFF", setdragoff);
			this.addEventListener(Event.ENTER_FRAME, renderscrubber);
		}
		
		private function clickposter(e:Event):void {
			//if scrubber has been added activate
			clickplaypause(null);
			scrubber.activate();
			vidstream.show();
		}
		
		private function clickplaypause(e:Event):void {
			//handle poster check
			if (posterimg) {posterimg.hide();}
			
			scrubber.activate();
			
			//play pause
			if (!isplaying) {
				isplaying = true;
				vidstream.streamresume();
				playpause.showpause();
				vidstream.show();
			} else {
				isplaying = false;
				vidstream.streampause();
				playpause.showplay();
			}
		}
		
		/*
		private function volumeEvent(e:Event):void {
		//trace("evt dispatched");
		//vidstream.
		vidstream.setVolume(volume.getVolumePct());
		}
		*/
		
		private function setdrag(e:Event):void {
			isdragging = true;
		}
		private function setdragoff(e:Event):void {
			isdragging = false;
		}
		
		private function videoEnd(e:Event):void {
			reset();
			trace("RESET");
		}
		
		private function renderscrubber(e:Event):void {
			if (isdragging) {
				if (posterimg) {posterimg.hide();}
				//push from scubber > NS
				vidstream.seekTo(scrubber.getdraggedpct());
				//trace("seek to " + scrubber.getdraggedpct());
			} 
			//data goes round trip; from scrubber > NS > scrubber; OR just NS > scrubbers
			scrubber.setbuffered(vidstream.getPercentLoaded());
			scrubber.setprogress(vidstream.getPlayhead());
			
			if (timecounter) {
				//populate time counter
				timecounter.setTimeCounter(vidstream.getCurrentTime());
			}
		}
		
		/**
		 ** PUBLIC FUNCTIONS
		 **
		 **/
		
		public function reset():void {
			trace("RESET");
			
			// DECIDE WHETHER OR NOT TO MAKE CUSTOM
			if (!autoplay) {
				//bring back poster, set play pause to play, pause stream go to zero
				isplaying = false;
				vidstream.streampause();
				vidstream.hide();
				posterimg.reset();
				playpause.showplay();
				vidstream.seekTo(0);
				scrubber.reset();
			} else {
				//just pause at end
				isplaying = true;
				playpause.showpause();
			}
			
			//check and reset vol, fullscreen, etc.
		}
		
		public function makePlayPause():PlayPause {
			var pp:PlayPause = new PlayPause();
			return pp;
		}
		
		public function makeScrubber():Scrubber {
			var sc:Scrubber = new Scrubber();
			return sc;
		}
		
		public function makeCounter():TimeCounter {
			var tc:TimeCounter = new TimeCounter();
			return tc;
		}
		
		public function positionUI():void {
			//overwrite
		}
		
		public function show():void {
			this.alpha = 1;
			this.visible = true;	
		}
		
		public function hide():void {
			this.alpha = 0;
			this.visible = false;
		}
		
		public function destroy():void{
			//kill netstream and all listeners
			vidstream.destroy();
		}
	}
}
