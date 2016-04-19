package
{
	import flash.utils.Dictionary;
	import starling.display.Sprite;
	
	public class FunctionMgr
	{
		
		public static function replaceExtensionPngToXml(text:String):String
		{
			var result:String = text;
			var dot:int = result.lastIndexOf(".");
			result = result.substring(0, dot);		
			result += ".xml";
			
			return result;
		}
		
		public static function removeExtension(text:String):String
		{
			var result:String = text;
			var dot:int = result.lastIndexOf(".");
			result = result.substring(0, dot);			
			
			return result;
		}
		
		
		
		public static function getDictionaryLength(dic:Dictionary):int
		{
			var length:int;
			
			for(var key:Object in dic)
			{
				length++;				
			}
			
			return length;
		}
		
		public static function makeVisibleFalse(vector:Vector.<Sprite>):void
		{
			for(var i:int = 0; i<vector.length; ++i)
			{
				vector[i].visible = false;
			}
		}
		
//		public static function compareName(a, b):int
//		{
//			
//			if (b.name > a.name) 
//			{ 
//				return -1; 
//			} 
//			else if (b.name < a.name) 
//			{ 
//				return 1; 
//			} 
//			else 
//			{ 
//				return 0; 
//			} 
//		}
	}
}