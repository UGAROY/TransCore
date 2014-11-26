package com.transcendss.transcore.sld.models.managers
{
	public class BaseResourceManager
	{
		public function BaseResourceManager()
		{
			
		}
		public static function getServiceSource():String
		{
			return	BaseConfigUtility.get("serviceDataSource");
		}
		
		public static function getBaseLayerURL():String
		{
			return	BaseConfigUtility.get("basemapLayer");
		}
		
	}
}