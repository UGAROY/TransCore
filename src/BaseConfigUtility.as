package
{
	import mx.resources.ResourceManager;

	
	[ResourceBundle("basesettings")]
	
	public class BaseConfigUtility
	{
		public static function get(param:String):String
		{
			var str:String = ResourceManager.getInstance().getString("basesettings", param);
			return str ? str : "";
		}
		
		public static function getInt(param:String):int
		{
			var val:int = parseInt(ResourceManager.getInstance().getString("basesettings", param));
			return val;
		}
		
		public static function getNumber(param:String):Number
		{
			var val:Number = parseFloat(ResourceManager.getInstance().getString("basesettings", param));
			return val;
		}
		
		public static function getBool(param:String):Boolean
		{
			var val:Boolean = ResourceManager.getInstance().getString("basesettings", param) == "true" ? true : false;
			return val;
		}
		
	}
}