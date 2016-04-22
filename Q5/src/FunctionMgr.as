package
{
	import flash.utils.Dictionary;
	
	import starling.display.Sprite;
	
	public class FunctionMgr
	{
		
		/**
		 * 
		 * @param text String
		 * @return String
		 * String을 맨 뒤에서부터 검사하여 처음 .이 나오면 . 이후의 부분을 .xml로 교체하는 메소드 
		 */
		public static function replaceExtensionPngToXml(text:String):String
		{
			var result:String = text;
			var dot:int = result.lastIndexOf(".");
			result = result.substring(0, dot);		
			result += ".xml";
			
			return result;
		}
		
		/**
		 * 
		 * @param text String
		 * @return String
		 * 마지막 "." 의 뒷부분을 제거해주는 메소드
		 */
		public static function removeExtension(text:String):String
		{
			var result:String = text;
			var dot:int = result.lastIndexOf(".");
			result = result.substring(0, dot);			
			
			return result;
		}		
		
		
		/**
		 * 
		 * @param dic Dictionary
		 * @return int 
		 * 해당 Dictionary 안에 몇개의 키값이 들어있는지 검사하여 리턴하는 메소드
		 */
		public static function getDictionaryLength(dic:Dictionary):int
		{
			var length:int;
			
			for(var key:Object in dic)
			{
				length++;				
			}
			
			return length;
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
		 * @param a any type
		 * @param b any type
		 * @return 
		 * 오름차순 정렬 메소드
		 */
		public static function compareAscending(a, b):int
		{
			if (b > a) 
			{ 
				return -1; 
			} 
			else if (b < a) 
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
		
		
		/**
		 * 
		 * @param sourceName String
		 * @return String
		 * 파일명에서 쓸데없는 부분을 모두 제거하는 메소드
		 */
		public static function getRealName(sourceName:String):String
		{
			var name:String = sourceName;
			
			var slash:int = name.lastIndexOf("/");
			var dot:int = name.lastIndexOf(".");
			name = name.substring(slash + 1, dot);
			
			return name;
		}
	}
}