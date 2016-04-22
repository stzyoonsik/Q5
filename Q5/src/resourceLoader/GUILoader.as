package resourceLoader
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;

	public class GUILoader
	{
		private var _completeFunc:Function;	
		private var _urlArray:Vector.<String> = new Vector.<String>;						//파일명이 담긴 배열
		private var _imageDataArray:Vector.<ImageData> = new Vector.<ImageData>;			//ImageData가 담긴 배열 
		private var _fileCount:int;
		
		public function get imageDataArray():Vector.<ImageData>{ return _imageDataArray; }		
		public function set imageDataArray(value:Vector.<ImageData>):void{ _imageDataArray = value;	}
				
		public function get fileCount():int{ return _fileCount;	}		
		public function set fileCount(value:int):void{ _fileCount = value; }
		
		
		public function GUILoader(cFunc:Function)
		{
			_completeFunc = cFunc;
			
			var array:Array = new Array();
			array = getResource();
			countImageFile(array);
			buildLoader();
		}		
		
		/**
		 * 
		 * @param event 로딩이 끝나면 이벤트를 받아옴
		 * BitmapData에 로딩된 타겟을 그리고 배열에 푸쉬하는 리스너함수
		 */
		public function onLoaderComplete(event:flash.events.Event):void
		{
			trace("loadeD");
			var loaderInfo:LoaderInfo = LoaderInfo(event.target);
			
			var name:String = loaderInfo.url;
			name = FunctionMgr.getRealName(name);
			
			var imageData:ImageData = new ImageData();
			imageData.name = name;
			
			var _bitmapData:BitmapData = new BitmapData(loaderInfo.width, loaderInfo.height);			
			_bitmapData.draw(loaderInfo.loader);
			imageData.bitmapData = _bitmapData;
			
			_imageDataArray.push(imageData);
			
			loaderInfo.removeEventListener(flash.events.Event.COMPLETE, onLoaderComplete);
			
			_completeFunc();
		}
		
		public function onLoaderFailed(event:flash.events.Event):void
		{
			trace("로드 실패 " + event);
			_fileCount--;
		}
		
		
		/**
		 * 각각의 리소스를 로드하고 이벤트를 붙여주는 메소드 
		 * 
		 */
		public function buildLoader():void
		{
			for(var i:int = 0; i<_urlArray.length; ++i)
			{
				var loader:Loader = new Loader();				
				loader.load(new URLRequest(_urlArray[i]));
				loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, onLoaderComplete);				
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderFailed);				
			}			
		}		
		
		/**
		 * application 디렉토리에 있는 모든 파일을 가져와서 각각을 Array에 저장하고 리턴하는 메소드 
		 * @return 폴더 안의 각각의 파일들
		 * 
		 */
		public function getResource():Array
		{
			//내부 저장소\data\data\resources
			var directory:File = File.applicationDirectory.resolvePath("resources");
			var array:Array = directory.getDirectoryListing();

			return array;
		}
		
		/**
		 * 
		 * @param resourceArray 폴더 안에 들어있던 모든 파일들
		 * 파일 이름을 push하는 메소드
		 */
		public function countImageFile(resourceArray:Array):void
		{			
			for(var i:int = 0; i<resourceArray.length; ++i)
			{				
				var url:String = resourceArray[i].url; 		
				url = url.substring(5, url.length);	
				
				_urlArray.push(url);					
				_fileCount++;
			}
		}
	}
}