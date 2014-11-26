package com.transcendss.transcore.vlog
{
	
	import com.transcendss.transcore.events.TSSMapEvent;
	import com.transcendss.transcore.util.*;
	
	import flash.display.*;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.*;
	
	import flashx.textLayout.formats.Float;
	
	import mx.containers.Canvas;
	import mx.controls.CheckBox;
	import mx.controls.HSlider;
	import mx.controls.Text;
	import mx.core.FlexGlobals;
	import mx.core.LayoutContainer;
	import mx.events.SliderEvent;
	import mx.managers.PopUpManager;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.Image;
	
	
	
	
	public class TSSVideoLogger extends Canvas
	{
		private var numimages:int = 2;
		//private var config_url:String = "https://s3.amazonaws.com/videolog/cdot_config.json";
		private var config_url:String = "http://ec2-23-20-37-199.compute-1.amazonaws.com/VLogWcfService/VLogService.svc/ConfigList";
		private var small_image_base:String = "https://s3.amazonaws.com/videolog/";
		private var large_image_base:String = "https://s3.amazonaws.com/videolog/";
		private var image_width:int;
		private var image_height:int;
		private var image_service:String;
		private var configID:String = "3";
		private var routeID:String = "I-44";
		private var routeDir:String = "5";
		private var minMP:String = "1";
		private var maxMP:String = "3";
		private var resetImages:Boolean = true;
		
		private var captionArray:Array = new Array();
		
		private var irArray:Array = new Array();
		private var speedArray:Array = new Array();
		
		private var imgcounter:Number = 0;
		public var running:Boolean = false;
		private var timer:Timer = new Timer(50);
		private var imgArray:Array = new Array();
		private var imgCaptions:Array = new Array();
		
		private var imgRun:Image = new Image();
		private var imgNext:Image = new Image();
		private var imgPrevious:Image = new Image();
		private var imgStop:Image = new Image();
		private var imgUturn:Image = new Image();
		
		private var speedSlider:HSlider = new HSlider();
		private var bannerImage:Image = new Image();
		private var bannerLayout:LayoutContainer;
		private var btnLayout:LayoutContainer;
		private var imgLayout:LayoutContainer;
		private var sliderLayout:LayoutContainer;
		private var attrLayout:LayoutContainer;
		//private var vMap:TSSMap;
		private var mapx:Number = -84.489; 
		private var mapy:Number = 42.678;
		private var tpAngle:Number = 0;
		
		private var attrTitle:Text = new Text();
		private var attrRouteID:Text = new Text();
		private var attrDirection:Text = new Text();
		private var attrHeading:Text = new Text();
		private var attrX:Text = new Text();
		private var attrY:Text = new Text();
		
		private var urlReq:URLRequest;
		private var urlLdr:URLLoader;
		
		private var layoutStyle:CSSStyleDeclaration;
		
		private var controlsChkBx:CheckBox = new CheckBox();

		
		private var i:int;

		public function TSSVideoLogger()
		{
			setupStyles();
		}
		
		private function setupStyles():void
		{	
			var txtTitleStyle:CSSStyleDeclaration = new CSSStyleDeclaration();
			txtTitleStyle.setStyle('fontStyle', 'bold');
			styleManager.setStyleDeclaration("mx.controls.Text", txtTitleStyle, true);
			this.configID = FlexGlobals.topLevelApplication.configID;
			this.routeID = FlexGlobals.topLevelApplication.routeID;
			this.routeDir = FlexGlobals.topLevelApplication.routeDir;
			this.minMP = FlexGlobals.topLevelApplication.minMP;
			this.maxMP = FlexGlobals.topLevelApplication.maxMP;
			openConfiguration();
		}
		
		private function setupLayout():void
		{		
			imgLayout = new LayoutContainer();
			imgLayout.layout = "horizontal";
			imgLayout.styleName = "ImgLayout";
			imgLayout.horizontalCenter = 0;
			imgLayout.verticalCenter = 0;
			imgLayout.width = (image_width * numimages) + (30 * (numimages -1) + 2);
			imgLayout.height = image_height + 2;
			
			var imgcnter:int = 0;
			for (imgcnter = 0;imgcnter<numimages;imgcnter++)
			{
				var tmpImg:TSSImage = new TSSImage();
				tmpImg.styleName = "VideoImage";
				tmpImg.position = imgcnter;
				tmpImg.height = image_height;
				tmpImg.width = image_width;
				tmpImg.toolTip = imgCaptions[imgcnter];
				tmpImg.doubleClickEnabled = true;
				tmpImg.addEventListener(MouseEvent.DOUBLE_CLICK, img_openFullSize);
				tmpImg.filters = [new DropShadowFilter()];
				imgLayout.addChild(tmpImg);
			}
			
			addChild(imgLayout);
			
			attrLayout = new LayoutContainer();
			attrLayout.layout = "vertical";
			attrLayout.styleName = "AttrLayout";
			attrLayout.y = 15;
			attrLayout.x = 5;
			
			attrTitle.text = "";
			attrTitle.styleName = "AttrTitle";
			
			
			attrLayout.addChild(attrTitle);
			attrLayout.addChild(attrRouteID);
			attrLayout.addChild(attrDirection);
			attrLayout.addChild(attrHeading);
			attrLayout.addChild(attrX);
			attrLayout.addChild(attrY);
			
			addChild(attrLayout);
			
			showLoadingImage();
			}
					
		protected function controlChanged(e:Event):void
		{
			var tmpchkb:CheckBox = e.target as CheckBox;
			this.setControlVisible(tmpchkb.selected);
		}
		
		protected function nextImage(e:TimerEvent):void
		{
			nextImageManual();
		}
		
		public function nextImageManual():void
		{	
	
			if (imgcounter == irArray.length)
			{
				imgcounter = 0;	
			}
			var tmpIR:TSSImageRecord = irArray[imgcounter];
			var tmpMapEvent:TSSMapEvent = new TSSMapEvent(TSSMapEvent.TRACKING_POINT, true, true);
			tmpMapEvent.x = tmpIR.x;
			tmpMapEvent.y = tmpIR.y;
			tmpMapEvent.tpangle = tmpIR.angle;
			tmpMapEvent.tpname = "current";
			dispatchEvent(tmpMapEvent);
			//vMap.positionTrackingPoint(tmpIR.x, tmpIR.y, tmpIR.angle, "current");
			var ircnt:Number;
			
			var x:Number = Converter.roundDec(tmpIR.x,4);
			var y:Number = Converter.roundDec(tmpIR.y,4);			
			
			attrTitle.text = "Current Image";
			attrRouteID.htmlText = "<b>Route ID:</b> " + tmpIR.routeID;
			attrDirection.htmlText = "<b>Direction:</b> " + tmpIR.direction;
			attrHeading.htmlText = "<b>Heading:</b> " + tmpIR.angle.toString() + String.fromCharCode(176);
			attrX.htmlText = "<b>X Coordinate:</b> " + x.toString();
			attrY.htmlText = "<b>Y Coordinate:</b> " + y.toString();
			
			for (ircnt=0;ircnt < numimages; ircnt++)
			{
				var tmploader:Loader = tmpIR.getLoader(ircnt);
				var tmpbm:Bitmap = tmploader.content as Bitmap;
				var tmpbmdata:BitmapData = tmpbm.bitmapData.clone();
				var tmpimg:TSSImage = imgLayout.getChildAt(ircnt) as TSSImage;
				tmpimg.source = new Bitmap(tmpbmdata);
				tmpimg.fullURL = tmpIR.getURL(ircnt);
				tmpimg.styleName = "VideoImage";
				tmpimg.filters = [new DropShadowFilter()];
			}

			imgcounter++;
		}
	
		
		public function startRun():void
		{
			timer.addEventListener(TimerEvent.TIMER,nextImage);
			timer.start();
		}
			
		
		public function stopRun():void
		{
			timer.stop();
		}
		
		
		public function previousImageManual():void
		{	
			if (imgcounter < 0)
			{
				imgcounter = irArray.length -1;	
				
			}	
			var tmpIR:TSSImageRecord = irArray[imgcounter];
			//vMap.positionTrackingPoint(tmpIR.x, tmpIR.y, tmpIR.angle, "current");
			var tmpMapEvent:TSSMapEvent = new TSSMapEvent(TSSMapEvent.TRACKING_POINT, true, true);
			tmpMapEvent.x = tmpIR.x;
			tmpMapEvent.y = tmpIR.y;
			tmpMapEvent.tpangle = tmpIR.angle;
			tmpMapEvent.tpname = "current";
			dispatchEvent(tmpMapEvent);
			var ircnt:Number;
			
			var x:Number = Converter.roundDec(tmpIR.x,4);
			var y:Number = Converter.roundDec(tmpIR.y,4);
			attrTitle.text = "Current Image";
			attrRouteID.htmlText = "<b>Route ID:</b> " + tmpIR.routeID;
			attrDirection.htmlText = "<b>Direction:</b> " + tmpIR.direction;
			attrHeading.htmlText = "<b>Heading:</b> " + tmpIR.angle.toString() + String.fromCharCode(176);
			attrX.htmlText = "<b>X Coordinate:</b> " + x.toString();
			attrY.htmlText = "<b>Y Coordinae:</b> " + y.toString();
			
			for (ircnt=0;ircnt < numimages; ircnt++)
			{
				var tmploader:Loader = tmpIR.getLoader(ircnt);
				var tmpbm:Bitmap = tmploader.content as Bitmap;
				var tmpbmdata:BitmapData = tmpbm.bitmapData.clone();
				var tmpimg:TSSImage = imgLayout.getChildAt(ircnt) as TSSImage;
				tmpimg.source = new Bitmap(tmpbmdata);
				tmpimg.fullURL = tmpIR.getURL(ircnt);
				tmpimg.styleName = "VideoImage";
				tmpimg.filters = [new DropShadowFilter()];
			}
			imgcounter--;
		}
		
		public function gotoImage(imgcounter:int):void
		{	
			var tmpIR:TSSImageRecord = irArray[imgcounter];
			//vMap.positionTrackingPoint(tmpIR.x, tmpIR.y, tmpIR.angle, "current");
			var tmpMapEvent:TSSMapEvent = new TSSMapEvent(TSSMapEvent.TRACKING_POINT, true, true);
			tmpMapEvent.x = tmpIR.x;
			tmpMapEvent.y = tmpIR.y;
			tmpMapEvent.tpangle = tmpIR.angle;
			tmpMapEvent.tpname = "current";
			dispatchEvent(tmpMapEvent);
			var ircnt:Number;
			
			var x:Number = Converter.roundDec(tmpIR.x,4);
			var y:Number = Converter.roundDec(tmpIR.y,4);
			attrTitle.text = "Current Image";
			attrRouteID.htmlText = "<b>Route ID:</b> " + tmpIR.routeID;
			attrDirection.htmlText = "<b>Direction:</b> " + tmpIR.direction;
			attrHeading.htmlText = "<b>Heading:</b> " + tmpIR.angle.toString() + String.fromCharCode(176);
			attrX.htmlText = "<b>X Coordinate:</b> " + x.toString();
			attrY.htmlText = "<b>Y Coordinate:</b> " + y.toString();
			
			for (ircnt=0;ircnt < numimages; ircnt++)
			{
				var tmploader:Loader = tmpIR.getLoader(ircnt);
				if (tmploader != null && tmploader.content != null)
				{
					var tmpbm:Bitmap = tmploader.content as Bitmap;
					var tmpbmdata:BitmapData = tmpbm.bitmapData.clone();
					var tmpimg:TSSImage = imgLayout.getChildAt(ircnt) as TSSImage;
					tmpimg.source = new Bitmap(tmpbmdata);
					tmpimg.fullURL = tmpIR.getURL(ircnt);
					tmpimg.styleName = "VideoImage";
					tmpimg.filters = [new DropShadowFilter()];
				} else
				{
					this.showNoImage();
				}
			}
		}
		
		public function fireXYChange(x:Number, y:Number, mp:Number):void
		{
			var tmpCnt:int = 0;
			/*var tmpIR1:TSSImageRecord = irArray[0];
			var tmpIR2:TSSImageRecord = irArray[1];
			
			var tmpPt1:Point = new Point();
			var tmpPt2:Point = new Point();
			var currPt:Point = new Point();
			currPt.x = x;
			currPt.y = y;
			tmpPt1.x = tmpIR1.x;
			tmpPt1.y = tmpIR1.y;
			tmpPt2.x = tmpIR2.x;
			tmpPt2.y = tmpIR2.y;
			trace(currPt.x +  "," + currPt.y);
			trace(tmpPt1.x + "," + tmpPt1.y);
			trace(tmpPt2.x + "," + tmpPt2.y);
			var typicalDist:Number = distance(tmpPt1, tmpPt2);
			trace("typdist: " + typicalDist);*/
			var smallestDist:Number = .1;
			var gotoIR:Number = -1;
			for (tmpCnt=0;tmpCnt < irArray.length;tmpCnt++)
			{
				
				
				var tmpIR:TSSImageRecord = irArray[tmpCnt];
				//trace(Math.abs(mp - tmpIR.mp));
				//trace(mp);
				//trace(tmpIR.mp);
				if (Math.abs(mp - tmpIR.mp) < smallestDist)
				{
					smallestDist = mp - tmpIR.mp;
					gotoIR = tmpCnt;
				}
				/*tmpPt1.x = tmpIR.x;
				tmpPt1.y = tmpIR.y;
				trace(distance(currPt, tmpPt1));
				trace(tmpPt1.x + "," + tmpPt1.y);
				if (distance(currPt, tmpPt1) < 0.00025)
				{
					gotoImage(tmpCnt);
					break;
				}
				showNoImage();*/
			}
			if (gotoIR > -1)
			{
				gotoImage(gotoIR);
			} else
			{
				showNoImage();
			}
			//vMap.positionTrackingPoint(x, y, 0, "current");
			var tmpMapEvent:TSSMapEvent = new TSSMapEvent(TSSMapEvent.TRACKING_POINT, true, true);
			tmpMapEvent.x = x;
			tmpMapEvent.y = y;
			tmpMapEvent.tpangle = 0;
			tmpMapEvent.tpname = "current";
			//dispatchEvent(tmpMapEvent);
			if ((parseFloat(this.maxMP) - mp) < 1)
			{
				getMoreImages();	
			}
		}
		
		private function getMoreImages():void
		{
			var currentLast:Number = parseFloat(this.maxMP);
			this.minMP = this.maxMP;
			this.maxMP = (currentLast + 5).toString();
			resetImages = false;
			addImageRecords();
		}
		
		private function distance(p1:Point,p2:Point):Number
		{
			var dist:Number,dx:Number,dy:Number;
			dx = p2.x-p1.x;
			dy = p2.y-p1.y;
			dist = Math.sqrt(dx*dx + dy*dy);
			return dist;
		}
		
		private function showNoImage():void{
			attrTitle.text = "";
			attrRouteID.text = "";
			attrDirection.text = "";
			attrHeading.text = "";
			attrX.text = "";
			attrY.text = "";
			var ircnt:int;
			
			for (ircnt=0;ircnt < numimages; ircnt++)
			{

				var tmpimg:TSSImage = imgLayout.getChildAt(ircnt) as TSSImage;
				tmpimg.source = "images/vlog/noimage.jpg";
				tmpimg.styleName = "VideoImage";
				tmpimg.filters = [new DropShadowFilter()];
				
			}
		}
		
		private function showLoadingImage():void{
			attrTitle.text = "";
			attrRouteID.text = "";
			attrDirection.text = "";
			attrHeading.text = "";
			attrX.text = "";
			attrY.text = "";
			var ircnt:int;
			
			for (ircnt=0;ircnt < numimages; ircnt++)
			{
				var tmpimg:TSSImage = imgLayout.getChildAt(ircnt) as TSSImage;
				tmpimg.source = "images/vlog/loadingimage.jpg";
				tmpimg.styleName = "VideoImage";
				tmpimg.filters = [new DropShadowFilter()];	
			}
		}
		
		
		protected function btnNext_clickHandler(event:MouseEvent):void
		{
			nextImageManual();
		}
		
		protected function btnRun_clickHandler(event:MouseEvent):void
		{
			running = true;
			startRun();
		}
		
		protected function btnStop_clickHandler(event:MouseEvent):void
		{
			running = false;
			stopRun();
		}
		
		protected function btnPrevious_clickHandler(event:MouseEvent):void
		{
			previousImageManual();
		}
		
		protected function resetImageManual():void
		{	
			
			var tmpIR:TSSImageRecord = irArray[imgcounter];
			var ircnt:Number;
			
			for (ircnt=0;ircnt < numimages; ircnt++)
			{
				var tmploader:Loader = tmpIR.getLoader(ircnt);
				var tmpbm:Bitmap = tmploader.content as Bitmap;
				var tmpbmdata:BitmapData = tmpbm.bitmapData.clone();
				var tmpimg:TSSImage = imgLayout.getChildAt(ircnt) as TSSImage;
				tmpimg.source = new Bitmap(tmpbmdata);
				tmpimg.fullURL = tmpIR.getURL(ircnt);
				tmpimg.filters = [new DropShadowFilter()];
			}
		}
		
		
		protected function img_openFullSize(event:MouseEvent):void
		{
			if (running)
			{
				stopRun();
			}
			var clkimage:TSSImage = event.target as TSSImage;
			var pimage:Image = new Image();
			var tmpsrc:String = clkimage.fullURL;
			tmpsrc = tmpsrc.replace(small_image_base, large_image_base);
			pimage.source = tmpsrc;
			pimage.doubleClickEnabled = true;
			pimage.addEventListener(MouseEvent.DOUBLE_CLICK, closeImagePopup);
			PopUpManager.addPopUp(pimage, this, true);
		}
		protected function closeImagePopup(event:MouseEvent):void
		{
			var img:Image = event.currentTarget as Image;
			PopUpManager.removePopUp(img);
			resetImageManual();
		}
		public function changeSpeed(e:Event):void
		{
			if (running)
			{
				stopRun();
			}
			var speed:Number = speedSlider.value;
			timer = new Timer(speed);
			if (running)
			{
				startRun();
			}
		}
		
		private function openConfiguration():void
		{
			
			urlReq = new URLRequest(config_url);
			
			urlLdr = new URLLoader();
			urlLdr.addEventListener(Event.COMPLETE, handleCFGEvent);
			urlLdr.addEventListener(Event.OPEN, handleCFGEvent);
			urlLdr.addEventListener(HTTPStatusEvent.HTTP_STATUS, handleCFGEvent);
			urlLdr.addEventListener(IOErrorEvent.IO_ERROR, handleCFGEvent);
			urlLdr.addEventListener(ProgressEvent.PROGRESS, handleCFGEvent);
			urlLdr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleCFGEvent);
			urlLdr.load(urlReq);
		}
		
		//Change the route
		public function addNewRouteImages(rtid:String, rtdir:String, minmp:String, maxmp:String):void
		{
			this.routeID = rtid;
			this.routeDir = rtdir;
			if ((parseFloat(maxmp) - parseFloat(minmp)) > 10)
			{
				this.minMP = minmp;
				this.maxMP = (parseFloat(minmp) + 10).toString();
			} else
			{
				this.minMP = minmp;
				this.maxMP = maxmp;
			}
			addImageRecords();
		}
		
		private function addImageRecords():void
		{
			showLoadingImage();
			urlReq = new URLRequest(image_service + this.configID + "/" + this.routeID + "/" + this.routeDir + "/" + this.minMP + "/" + this.maxMP);
			
			urlLdr = new URLLoader();
			urlLdr.addEventListener(Event.COMPLETE, handleIREvent);
			urlLdr.addEventListener(Event.OPEN, handleIREvent);
			urlLdr.addEventListener(HTTPStatusEvent.HTTP_STATUS, handleIREvent);
			urlLdr.addEventListener(IOErrorEvent.IO_ERROR, handleIREvent);
			urlLdr.addEventListener(ProgressEvent.PROGRESS, handleIREvent);
			urlLdr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleIREvent);
			urlLdr.load(urlReq);
		}
		
		
		private function parseImageRecords(records:String):void
		{
			while (records.indexOf("}{") > -1)
			{
				records = records.replace("}{", "},{");
			}
			//decode the data to ActionScript using the JSON API
			//in this case, the JSON data is a serialize Array of Objects.
			//var irs:Object = (JSON.decode(records));
			var irsArray:Array = (Array)(JSON.parse(records));
			//var irsArray:Array = irs.ImageRecords as Array;
			if (resetImages)
			{
				irArray = new Array();
			}
			resetImages = true;
			var irscnt:int = 0;
			for (irscnt=0;irscnt<irsArray[0].length;irscnt++)
			{
				var irsobj:Object = irsArray[0][irscnt];
				if (irsobj != null && irsobj.hasOwnProperty("images"))
				{
					var tmpid:String = irsobj.images[0].VLOG_IMAGES_ID;
					var tmprouteid:String = irsobj.ROUTE_ID;
					var tmpdirection:String = irsobj.ROUTE_DIR;
					var tmpx:String = irsobj.X_COORD as String;
					var tmpy:String = irsobj.Y_COORD as String;
					var tmpang:String = irsobj.HEADING as String;
					var tmpmp:String = irsobj.MILEPOINT as String;
					
					var tmpIR:TSSImageRecord = 
						new TSSImageRecord(tmpid, new Number(tmpx), new Number(tmpy), new Number(tmpmp), new Number(tmpang), tmprouteid, tmpdirection);
		
					var irsimgcnt:int = 0;
					for (irsimgcnt= 0;irsimgcnt<numimages;irsimgcnt++)
					{
						var tmpimgid:Number = irsobj.images[irsimgcnt].VLOG_IMAGES_ID as Number;
						var tmpimgname:String = irsobj.images[irsimgcnt].IMG_FILENAME;
						tmpIR.addImage(irsimgcnt, small_image_base + tmpimgname);
					}
					irArray[irscnt] = tmpIR;
				}
			}
			showNoImage();

		}
		
		private function parseConfiguration(config:String):void
		{
			while (config.indexOf("}{") > -1)
			{
				config = config.replace("}{", "},{");
			}
			var cfg:Object = (JSON.parse(config));
			var cfgObj:Object = cfg[2] as Object;	
			numimages = cfgObj.IMAGE_COUNT;
			image_width = cfgObj.IMAGE_WIDTH;
			image_height = cfgObj.IMAGE_HEIGHT;
			image_service = cfgObj.IMAGE_SERVICE;
			image_service = image_service.replace("ec2-75-101-204-181", "ec2-23-20-37-199");
			small_image_base = cfgObj.SMALL_BASE_URL;
			large_image_base = cfgObj.LARGE_BASE_URL;
			var tmpcnt:int;
			for (tmpcnt=0;tmpcnt<numimages;tmpcnt++)
			{
				//imgCaptions[cfg.Configuration.image_info[tmpcnt].position] = cfg.Configuration.image_info[tmpcnt].caption;
				imgCaptions[tmpcnt] = "Center View";
			}
			setupLayout();
			addImageRecords();
		}
		
		/*public function setMap(map:TSSMap):void
		{
			vMap = map;
		}*/
		
		private function handleIREvent(evt:Event):void {
			
			switch (evt.type) {
				case Event.COMPLETE:
					var ldr:URLLoader = evt.currentTarget as URLLoader;
					parseImageRecords(ldr.data);
					break;
			}
		}
		
		private function handleCFGEvent(evt:Event):void {
			
			switch (evt.type) {
				case Event.COMPLETE:
					var ldr:URLLoader = evt.currentTarget as URLLoader;
					parseConfiguration(ldr.data);
					break;
			}
		}
		
		/*
		Function to show or hide the vlog controls
		*/
		public function setControlVisible(value:Boolean):void
		{
			btnLayout.visible = value;		
			sliderLayout.visible = value;
			if (value)
			{
				btnLayout.height = 40;
				sliderLayout.height = 50;
			}else	
			{
				btnLayout.height = 0;
				sliderLayout.height = 0;
			}
		}
	
	}
}