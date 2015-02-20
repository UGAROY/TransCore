package com.transcendss.transcore.sld.models.managers
{
	import com.transcendss.transcore.sld.models.components.GeoTag;
	import com.transcendss.transcore.util.TSSAudio;
	import com.transcendss.transcore.util.TSSLoader;
	import com.transcendss.transcore.util.TSSMemo;
	import com.transcendss.transcore.util.TSSPicture;
	import com.transcendss.transcore.util.TSSVideo;
	import com.transcendss.transcore.util.TSSWAVReader;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import mx.core.FlexGlobals;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.VGroup;
	
	public class GeotagsManager
	{
		[Embed(source="../../../../../../images/gray_icons/icon_Mav_Camera_40x40.png")] protected var _camera:Class
		[Embed(source="../../../../../../images/gray_icons/icon_Mav_Video_40x40.png")] protected var _video:Class
		[Embed(source="../../../../../../images/gray_icons/icon_Mav_Microphone_40x40.png")] protected var _voice:Class
		[Embed(source="../../../../../../images/gray_icons/icon_Mav_Note_40x40.png")] protected var _memo:Class
		public var currentAudioStream:URLStream = null;
		public var currentAudio:TSSAudio= null;
		
		public function GeotagsManager()
		{
			
			
		}
		
		//		[Bindable]
		public function get camera():Class
		{
			return _camera;
		}
		//		[Bindable]
		public function get video():Class
		{
			return _video;
		}
		//		[Bindable]
		public function get voice():Class
		{
			return _voice;
		}
		public function get memo():Class
		{
			return _memo;
		}
		
		public function ConvertGeotags(tmpGT:GeoTag, loaderPath:String ="", source:String="server", doLoad:Boolean = true):*
		{
			var sourceURL:String =""
			var gtURL:String ="";
			
			if (tmpGT.image_file_name != null && tmpGT.image_file_name != "")
			{
				var tmpImage:TSSPicture = new TSSPicture();
				tmpImage.geoTag = tmpGT;
				tmpImage.label = tmpGT.image_file_name;
				
				
				if(loaderPath == null || loaderPath == "")
				{
					//					if (BaseConfigUtility.get("geotags_folder").substr(0,1) == "/")
					gtURL= FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.geotagUrl;
					if (gtURL.substr(0,1) == "/")
					{
						loaderPath = "file:///mnt" + gtURL+ tmpGT.image_file_name;
					} else
					{
						if(FlexGlobals.topLevelApplication.platform == "IOS") {
							loaderPath = "app-storage:/" + gtURL+ tmpGT.image_file_name;
						} else {
							loaderPath = gtURL+ tmpGT.image_file_name;
						}
					}
				} else if (source == "local")
				{
					loaderPath = "file://" + loaderPath + tmpGT.image_file_name;
				}
				sourceURL =  loaderPath;
				
				tmpImage.sourceURL = sourceURL;
				//tmpImage.source = camera;
				tmpImage.source = sourceURL;
				
				tmpImage.geoLocalId =String(tmpGT.id);
				tmpImage.width = 40;
				tmpImage.height = 40;
				
				if(doLoad)
				{
					var load:TSSLoader = new TSSLoader();
					load.picture = tmpImage;
					var request:URLRequest = new URLRequest(loaderPath);
					
					load.contentLoaderInfo.addEventListener(Event.COMPLETE, function image_load_complete(event:Event):void
					{
						var ldr:TSSLoader = event.target.loader as TSSLoader;
						var img:Bitmap = event.target.content as Bitmap;
						var tmpPic:TSSPicture = ldr.picture;
						tmpPic.bitmap = img;
						load = null;
					});
					load.load(request);
					
				}
				return tmpImage;
			} else if (tmpGT.video_file_name != null && tmpGT.video_file_name != "")
			{
				var vid:TSSVideo=new TSSVideo();
				vid.source=video;
				vid.geoTag = tmpGT;
				//vid.video=event.video;
				vid.geoLocalId = String(tmpGT.id);
				vid.width=40;
				vid.height=40;
				vid.label = tmpGT.video_file_name;
				/*if(source =="server")
				sourceURL = loaderPath;
				else
				sourceURL = tmpGT.video_file_name;*/
				
				if(loaderPath == null || loaderPath == "")
				{
					gtURL = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.geotagUrl;
					if (BaseConfigUtility.get("geotags_folder").substr(0,1) == "/")
					{
						loaderPath = "file:///mnt" + gtURL + tmpGT.video_file_name;
					} else
					{
						if(FlexGlobals.topLevelApplication.platform == "IOS") {
							loaderPath = "app-storage:/" + gtURL + tmpGT.video_file_name;
						} else {
							loaderPath = gtURL + tmpGT.video_file_name;
						}
						
					}
				} else if (source == "local")
				{
					loaderPath = "file://" + loaderPath + tmpGT.video_file_name;
				}
				sourceURL = loaderPath;
				
				
				vid.filePath=sourceURL;
				return vid;
				
				//load = new TSSLoader();
				//load.video = vid;
				//request = new URLRequest(String(obj.URL));
				//load.load(request);
				//load.contentLoaderInfo.addEventListener(Event.COMPLETE, video_load_complete);	
			} else if (tmpGT.text_memo != null && tmpGT.text_memo != "")
			{
				var tmpMemo:TSSMemo = new TSSMemo();			
				tmpMemo.source = memo;
				tmpMemo.geoTag = tmpGT;
				tmpMemo.geoLocalId = String(tmpGT.id);
				tmpMemo.memo=tmpGT.text_memo;
				tmpMemo.label = tmpGT.text_memo;
				
				tmpMemo.width = 40;
				tmpMemo.height = 40;
				return tmpMemo;
				
				
			} else if (tmpGT.voice_file_name != null && tmpGT.voice_file_name != "")
			{
				var tmpAudio:TSSAudio = new TSSAudio();
				tmpAudio.label = tmpGT.voice_file_name;
				tmpAudio.source = voice;
				//tmpAudio.soundBytes = event.byteArray;
				tmpAudio.geoTag = tmpGT;
				tmpAudio.geoLocalId = String(tmpGT.id);
				tmpAudio.width = 40;
				tmpAudio.height = 40;
				
				//				if(source =="server")
				//					sourceURL = loaderPath;
				if(loaderPath == null || loaderPath == "")
				{
					/*if (BaseConfigUtility.get("geotags_folder").substr(0,1) == "/")
					{
					loaderPath = "file:///mnt" + BaseConfigUtility.get("geotags_folder");
					} else
					{
					loaderPath = BaseConfigUtility.get("geotags_folder");
					}*/
					var gtURL2:String = FlexGlobals.topLevelApplication.GlobalComponents.ConfigManager.geotagUrl;
					if (gtURL2.substr(0,1) == "/")
					{
						loaderPath = "file:///mnt" + gtURL2+ tmpGT.voice_file_name;
					} else
					{
						if(FlexGlobals.topLevelApplication.platform == "IOS") {
							// Temporary code for demo. TODO:
							loaderPath = gtURL2+ tmpGT.voice_file_name;
							//loaderPath = "app-storage:/" + gtURL2+ tmpGT.voice_file_name;
						} else {
							loaderPath = gtURL2+ tmpGT.voice_file_name;
						}
					}
				} else if (source == "local")
				{
					loaderPath = "file://" + loaderPath + tmpGT.voice_file_name;					
				} 
				sourceURL = loaderPath;
				//				
				//				var load2:TSSLoader = new TSSLoader();
				//				load2.audio = tmpAudio;
				//				var request2:URLRequest = new URLRequest(sourceURL);
				//				load2.load(request2);
				//				load2.contentLoaderInfo.addEventListener(Event.COMPLETE, func);	
				
				tmpAudio.sourceURL = sourceURL;
				//local audio load code
				
				
				//currentAudio = tmpAudio;
				if(doLoad)
				{
					currentAudioStream = new URLStream();
					currentAudioStream.addEventListener(Event.COMPLETE, function audio_load_complete(event:Event):void
					{
						
						currentAudioStream = event.target as URLStream;
						var soundBytes:ByteArray = new ByteArray();
						currentAudioStream.readBytes(soundBytes);
						var read:TSSWAVReader = new TSSWAVReader();
						read.loadAudio(soundBytes);
						tmpAudio.soundBytes = read.audioBytes;
						currentAudioStream = null;
					});
					//tmpFile = new File("/sdcard/geotags/" + tmpGT.voice_file_name);
					currentAudioStream.load(new URLRequest(sourceURL));
				}
				return tmpAudio;
			}
		}
		
		
		public function setGeotags(attachmentGroup:Group, gtArray:Array, assetType:String, assetID:String, routeName:String, begMile:Number,assetLocalID:String="", endMile:Number=0, layerID:String=null, inspGroup:Group=null):void
		{
			FlexGlobals.topLevelApplication.setBusyStatus(false);
			if(!gtArray)
				return;
			for (var gti:int=0;gti<gtArray.length;gti++)
			{
				var insp:Number = (String(gtArray[gti].IS_INSP)=="1")?1:0;
				
				var image_fileName:String = "";
				var video_fileName:String = "";
				var voice_fileName:String = "";
				var text_memo:String ="";
				var id:String ="";
				
				if(gtArray[gti].TEXT_MEMO)
					text_memo = String(gtArray[gti].TEXT_MEMO)
				
				if(gtArray[gti].ID)
					id = String(gtArray[gti].ID);
				if(gtArray[gti].id)
					id = String(gtArray[gti].id);
				else
					id = String(gtArray[gti].ATTACH_ID);
				
				
				
				if(gtArray[gti].contentType)
				{
					image_fileName = String(gtArray[gti].contentType).toLowerCase().indexOf("image")!=-1 ? String(gtArray[gti].name):"";
					video_fileName =  String(gtArray[gti].contentType).toLowerCase().indexOf("video")!=-1 ? String(gtArray[gti].name):"";
					voice_fileName = String(gtArray[gti].contentType).toLowerCase().indexOf("audio")!=-1 ? String(gtArray[gti].name):"";
					
				}
				else
				{
					image_fileName = String(gtArray[gti].IMAGE_FILENAME);
					video_fileName =String(gtArray[gti].VIDEO_FILENAME);
					voice_fileName =String(gtArray[gti].VOICE_FILENAME);
				}
				
				var tmpGT:GeoTag = new GeoTag(Number(id),assetType, routeName ,assetID,assetLocalID
					,insp,begMile,endMile,image_fileName,video_fileName,voice_fileName,text_memo);
				
				var url:String ="";
				
				if(FlexGlobals.topLevelApplication.useAgsService)
					url = FlexGlobals.topLevelApplication.GlobalComponents.agsManager.getAttachmentByIDUrl(layerID, assetID, gtArray[gti].id);	
				else
					url = String(gtArray[gti].URL);
				
				var viE:*= ConvertGeotags(tmpGT,url );
				if(viE)
				{
//					if(insp==0 && attachmentGroup) 
//						attachmentGroup.addElement(viE);
//					else if(insp==1 && inspGroup)
//						inspGroup.addElement(viE);
					
					var vContainer:VGroup = new VGroup();
					vContainer.horizontalAlign = "center";
					var assetLabel:Label = new Label();
					assetLabel.text = (assetType =="SIGN")?"Sign -- "+assetID:FlexGlobals.topLevelApplication.GlobalComponents.assetManager.getAssetUINameByType(assetType) + "--" + assetID;
					vContainer.addElement(viE);
					vContainer.addElement(assetLabel);
					
					if(inspGroup)
						inspGroup.addElement(vContainer);
					else if(insp==0 && attachmentGroup) 
						attachmentGroup.addElement(vContainer);
				}
				
			}
			
		}
		
		
		
		
	}
}