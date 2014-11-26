package com.transcendss.transcore.sld.models.components
{
	public class GeoTag
	{
		private var _id:Number;
		private var _cached_route_id:String;
		private var _is_insp:Number=0;
		private var _begin_mile_point:Number;
		private var _end_mile_point:Number;
		private var _image_file_name:String="";
		private var _video_file_name:String="";
		private var _voice_file_name:String="";
		private var _text_memo:String;
		private var _asset_base_id:String;
		private var _local_asset_id:String;
		private var _asset_ty_id:String;
		private var _inspection_base_id:Number;
		private var _url:String;
		public function GeoTag(id:Number =0,asset_ty_id:String ="", cached_route_id:String = "", 
							asset_base_id:String="", local_asset_id:String ="",is_insp:Number=0,
							begin_mile_point:Number=0,end_mile_point:Number=0,
							image_file_name:String="",video_file_name:String="",voice_file_name:String="",
							text_memo:String ="", inspection_base_id:Number=0, url:String = "")
		{
			_id = id;
			_cached_route_id=cached_route_id;
			_is_insp= is_insp;
			_begin_mile_point=begin_mile_point;
			_end_mile_point=end_mile_point;
			_image_file_name=image_file_name;
			_video_file_name=video_file_name;
			_voice_file_name=voice_file_name;
			_text_memo=text_memo;
			_asset_base_id=asset_base_id;
			_local_asset_id=local_asset_id;
			_asset_ty_id = asset_ty_id;
			_inspection_base_id = inspection_base_id;
			_url = url;
		}
		

		public function get url():String
		{
			return _url;
		}

		public function set url(value:String):void
		{
			_url = value;
		}

		public function get inspection_base_id():Number
		{
			return _inspection_base_id;
		}

		public function set inspection_base_id(value:Number):void
		{
			_inspection_base_id = value;
		}

		public function get is_insp():Number
		{
			return _is_insp;
		}

		public function set is_insp(value:Number):void
		{
			_is_insp = value;
		}
		public function get asset_ty_id():String
		{
			return _asset_ty_id;
		}
		
		public function set asset_ty_id(value:String):void
		{
			_asset_ty_id = value;
		}
		public function get text_memo():String
		{
			return _text_memo;
		}

		public function set text_memo(value:String):void
		{
			_text_memo = value;
		}

		public function get voice_file_name():String
		{
			return _voice_file_name;
		}

		public function set voice_file_name(value:String):void
		{
			_voice_file_name = value;
		}

		public function get video_file_name():String
		{
			return _video_file_name;
		}

		public function set video_file_name(value:String):void
		{
			_video_file_name = value;
		}

		public function get image_file_name():String
		{
			return _image_file_name;
		}

		public function set image_file_name(value:String):void
		{
			_image_file_name = value;
		}

		public function get end_mile_point():Number
		{
			return _end_mile_point;
		}

		public function set end_mile_point(value:Number):void
		{
			_end_mile_point = value;
		}

		public function get begin_mile_point():Number
		{
			return _begin_mile_point;
		}

		public function set begin_mile_point(value:Number):void
		{
			_begin_mile_point = value;
		}

		public function get cached_route_id():String
		{
			return _cached_route_id;
		}

		public function set cached_route_id(value:String):void
		{
			_cached_route_id = value;
		}

		public function get asset_base_id():String
		{
			return _asset_base_id;
		}
		
		public function set asset_base_id(value:String):void
		{
			_asset_base_id = value;
		}
		
		public function get local_asset_id():String
		{
			return _local_asset_id;
		}
		
		public function set local_asset_id(value:String):void
		{
			_local_asset_id = value;
		}
		
		public function get id():Number
		{
			return _id;
		}

		public function set id(value:Number):void
		{
			_id = value;
		}

	}
}