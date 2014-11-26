package com.transcendss.transcore.events
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	public class UserDataEvent extends Event
	{
		
		public static const FETCH_USER_DOMAIN:String = "fetch_user_domain";
		public static const USER_DOMAIN_READY:String = "user_domain_ready";
		private var _url:String;
		private var _userlist:ArrayCollection;
		
		public function UserDataEvent(type:String, users:ArrayCollection=null, bubbles:Boolean=true, cancelable:Boolean=true)
		{
			super(type, bubbles, cancelable);
			_url = url;
			_userlist =  users;
		}
		
		public function get url():String
		{
			return _url;
		}
		
		public function set url(value:String):void
		{
			_url = value;
		}
		public function get users():ArrayCollection
		{
			return _userlist;
		}
		
		public function set users(value:ArrayCollection):void
		{
			_userlist = value;
		}
		
	}
}