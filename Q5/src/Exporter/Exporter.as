package exporter
{
	import flash.display.Bitmap;
	import flash.display.PNGEncoderOptions;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class Exporter
	{
		private var _count:int;		
		
		public function get count():int
		{
			return _count;
		}

		public function set count(value:int):void
		{
			_count = value;
		}

		/**
		 * 
		 * @param bitmap Bitmap을 입력받음
		 * png파일로 출력하는 메소드
		 */
		public function exportToPNG(bitmap:Bitmap):void
		{
			//내문서에 저장됨
			var _pngFile:File = File.documentsDirectory.resolvePath("sprite_sheet/new_sprite_sheet" + _count + ".png");
			var byteArray:ByteArray = new ByteArray();
			bitmap.bitmapData.encode(new Rectangle(0, 0, bitmap.width, bitmap.height), new PNGEncoderOptions(), byteArray);
			var fileStream:FileStream = new FileStream();
			fileStream.open(_pngFile, FileMode.WRITE);
			fileStream.writeBytes(byteArray);
			fileStream.close();
		}		
	
		/**
		 * 
		 * @param dic Dictionary
		 * Dictionary를 순회하며 xml을 출력하는 메소드
		 */
		public function exportToXML(dic:Dictionary):void
		{
			var _xmlFile:File = File.documentsDirectory.resolvePath("sprite_sheet/new_sprite_sheet" + _count + ".xml");
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(_xmlFile, FileMode.WRITE);
			fileStream.writeUTFBytes("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
			fileStream.writeUTFBytes("<TextureAtlas ImagePath=\"" + "new_sprite_sheet" + _count + ".png" + "\">\n");
			
			for(var key:String in dic)
			{
				fileStream.writeUTFBytes("<SubTexture name=\"" + dic[key].name + "\" x=\"" + dic[key].rect.x 
					+ "\" y=\"" + dic[key].rect.y + "\" width=\"" + dic[key].rect.width + "\" height=\"" + dic[key].rect.height + "\"/>\n");				
			}
			fileStream.writeUTFBytes("</TextureAtlas>");
			fileStream.close();
			
		}
	}
}