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
		
		/**
		 * 
		 * @param a 이미지의 데이터
		 * @param b 이미지의 데이터
		 * @return  a가 면적이 더 크다면 -1, b가 크다면 1, 같으면 0
		 * 내림차순
		 */
		public static function compareAreaDescending(a, b):int
		{
			//var aArea:int = a.imageData.height * a.imageData.width;
			//var bArea:int = b.imageData.height * b.imageData.width;
			var aArea:int = a.rect.height * a.rect.width;
			var bArea:int = b.rect.height * b.rect.width;
			
			if (bArea < aArea) 
			{ 
				return -1; 
			} 
			else if (bArea > aArea) 
			{ 
				return 1; 
			} 
			else 
			{ 
				return 0; 
			} 
		}
		
		/**
		 * 
		 * @param size 받아오는 사이즈
		 * @return size보다 큰 최소의 2의n승 
		 * 
		 */
		public static function getCorrectLength(size:int):int
		{
			var newSize:int = 1;
			
			while(newSize < size)
			{
				newSize *= 2;
			}
			
			return newSize;
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