package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;

	public class SpriteSheet extends Sprite
	{
		private var _loadSpriteSheetsButton:Image;											//애니메이션모드, 이미지모드에서 공유됨. 스프라이트시트를 로드하는 버튼
		private var _selectSpriteSheetButton:Image;											//화살표버튼
		
		private var _spriteSheetList:Sprite = new Sprite();									//스프라이트시트 텍스트필드 를 담는 Sprite		
		private var _spriteSheetVector:Vector.<TextField> = new Vector.<TextField>;			//스프라이트시트 텍스트필드를 담는 배열
		
		private var _xmlDic:Dictionary = new Dictionary();
		
		private var _spriteSheetDic:Dictionary = new Dictionary();							//사용자가 Load SpriteSheets 버튼을 통해 스프라이트시트를 로드하면 이 딕셔너리에 추가됨
		private var _scaledSpriteSheetDic:Dictionary = new Dictionary();					//위와 같지만 이미지 크기를 1/4로 줄인 이미지가 담긴 딕셔너리
				
		private var _pieceImageVectorAMode:Vector.<Image>;									//조각난 이미지들을 담는 배열		- 애니메이션모드용
		private var _sheetImageDicAMode:Dictionary = new Dictionary();
		
		private var _pieceImageDicIMode:Dictionary;								 			//조각난 이미지들을 담는 딕셔너리	- 이미지모드용
		private var _sheetImageDicIMode:Dictionary = new Dictionary();
		
		private var _numberOfPNG:int;
		private var _numberOfXML:int;
	
		private var _currentTextField:TextField = new TextField(240, 24, "");				//현재 선택된 스프라이트 시트를 나타내기 위한 텍스트필드
		
		public function SpriteSheet()
		{		
			addEventListener(TouchEvent.TOUCH, onAddedEvents);	
		}

		public function get pieceImageVectorAMode():Vector.<Image>
		{
			return _pieceImageVectorAMode;
		}

		public function set pieceImageVectorAMode(value:Vector.<Image>):void
		{
			_pieceImageVectorAMode = value;
		}

		public function get sheetImageDicAMode():Dictionary
		{
			return _sheetImageDicAMode;
		}

		public function set sheetImageDicAMode(value:Dictionary):void
		{
			_sheetImageDicAMode = value;
		}

		public function get currentTextField():TextField
		{
			return _currentTextField;
		}

		public function set currentTextField(value:TextField):void
		{
			_currentTextField = value;
		}

		public function get pieceImageDicIMode():Dictionary
		{
			return _pieceImageDicIMode;
		}

		public function set pieceImageDicIMode(value:Dictionary):void
		{
			_pieceImageDicIMode = value;
		}

		public function get sheetImageDicIMode():Dictionary
		{
			return _sheetImageDicIMode;
		}

		public function set sheetImageDicIMode(value:Dictionary):void
		{
			_sheetImageDicIMode = value;
		}

		/**
		 * 
		 * @param guiArray 로드된 이미지들
		 * 초기화 메소드
		 */
		public function init(guiArray:Vector.<Image>):void
		{
			//trace("init");
			for(var i:int = 0; i<guiArray.length; ++i)
			{
				switch(guiArray[i].name)
				{
					case "loadButton":
						_loadSpriteSheetsButton = new Image(guiArray[i].texture);
						_loadSpriteSheetsButton.pivotX = _loadSpriteSheetsButton.width / 2;
						_loadSpriteSheetsButton.pivotY = _loadSpriteSheetsButton.height / 2;
						_loadSpriteSheetsButton.x = 178;
						_loadSpriteSheetsButton.y = 532;
						addChild(_loadSpriteSheetsButton);
						break;
					
					case "selectButton":
						_selectSpriteSheetButton = new Image(guiArray[i].texture);
						_selectSpriteSheetButton.pivotX = _selectSpriteSheetButton.width / 2;
						_selectSpriteSheetButton.pivotY = _selectSpriteSheetButton.height / 2;
						_selectSpriteSheetButton.x = 300;
						_selectSpriteSheetButton.y = 612;
						_selectSpriteSheetButton.visible = false;
						addChild(_selectSpriteSheetButton);						
						break;
				}
			}
			_currentTextField.x = 50;
			_currentTextField.y = 600;
			_currentTextField.border = true;
			
			addChild(_currentTextField);
		
		}
		
		private function onAddedEvents(event:starling.events.Event):void
		{		
			_loadSpriteSheetsButton.addEventListener(TouchEvent.TOUCH, onLoadSpriteSheetsButton);	
			_selectSpriteSheetButton.addEventListener(TouchEvent.TOUCH, onSelectSpriteSheetButton);
		}
		
		
		/**
		 * 
		 * @param event 클릭
		 * 화살표 버튼을 클릭하면 드롭다운을 보여주는 이벤트리스너
		 */
		private function onSelectSpriteSheetButton(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_selectSpriteSheetButton, TouchPhase.ENDED);
			if(touch)
			{
				_spriteSheetList.visible = true;
			}
		}
		
		/**
		 * 
		 * @param event 마우스 클릭
		 * 클릭이 발생했을 때 버튼 이미지의 크기를 신축하고, 스프라이트 시트를 가져오는 메소드
		 */
		private function onLoadSpriteSheetsButton(event:TouchEvent):void
		{
			//trace("로드스프라이트시트");
			var touch:Touch = event.getTouch(_loadSpriteSheetsButton, TouchPhase.BEGAN);
			if(touch)
			{
				
				_loadSpriteSheetsButton.scale = 0.8;
			}			
			else
			{
				_loadSpriteSheetsButton.scale = 1;
			}
			
			touch = event.getTouch(_loadSpriteSheetsButton, TouchPhase.ENDED);
			if(touch)
			{
				//trace("로드스프라이트시트버튼");
				//이미지 파일만 여는 예외처리 필요
				var file:File = File.applicationDirectory;
				file.browseForOpenMultiple("Select SpriteSheet PNG Files");
				file.addEventListener(FileListEvent.SELECT_MULTIPLE, onFilesSelected);
			}
		}
		
		/**
		 * 
		 * @param event 선택된 파일(들) 
		 * 선택된 파일들을 로드하는 이벤트리스너
		 */
		private function onFilesSelected(event:FileListEvent):void
		{
			_numberOfXML += event.files.length;
			_numberOfPNG += event.files.length;
			
			for (var i:int = 0; i < event.files.length; ++i) 
			{
				//trace(event.files[i].nativePath);
				//PNG 로드
				var loader:Loader = new Loader();				
				loader.load(new URLRequest(event.files[i].url));				
				loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, onLoaderComplete);				
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderFailed);
				
				
				//XML 로드
				var xmlURL:String = FunctionMgr.replaceExtensionPngToXml(event.files[i].url);
				var urlRequest:URLRequest = new URLRequest(xmlURL);
				var urlLoader:URLLoader = new URLLoader();				
				urlLoader.addEventListener(flash.events.Event.COMPLETE, onXMLLoaderComplete);
				urlLoader.load(urlRequest);
			}
		}
		
		
		/**
		 * 선택한 png와 그 이름과 동일한 xml이 모두 로드됬는지 검사하는 메소드 
		 * 모두 로드됬다면 xml을 읽어서 딕셔너리에 저장함
		 */
		private function completeAll():void
		{
			if(_numberOfPNG == _spriteSheetVector.length && _numberOfXML == FunctionMgr.getDictionaryLength(_xmlDic))
			{
				readXML();
			}
		}

		/**
		 * 
		 * @param event xml 로딩이 끝나는 이벤트
		 * xml파일의 로드가 완료되면 xml을 읽어서 데이터를 저장하는 이벤트리스너
		 */
		private function onXMLLoaderComplete(event:flash.events.Event):void
		{
			
			var xml:XML = new XML(event.currentTarget.data);
			
			var name:String = FunctionMgr.removeExtension(xml.attribute("ImagePath"));
			
			_xmlDic[name] = xml;
			
			completeAll();
		}
		
		/**
		 * xml 파일을 읽어서 ImageMode와 AnimationMode에서 쓸 공간에 구조화하여 저장하는 메소드 
		 * 
		 */
		private function readXML():void
		{
			for(var key:String in _xmlDic)
			{
				_pieceImageDicIMode = new Dictionary();
				_pieceImageVectorAMode = new Vector.<Image>;
				for(var i:int = 0; i < _xmlDic[key].child("SubTexture").length(); ++i)
				{
					var imageData:ImageData = new ImageData();
					imageData.name = _xmlDic[key].child("SubTexture")[i].attribute("name");
					imageData.rect.x = _xmlDic[key].child("SubTexture")[i].attribute("x");
					imageData.rect.y = _xmlDic[key].child("SubTexture")[i].attribute("y");
					imageData.rect.width = _xmlDic[key].child("SubTexture")[i].attribute("width");
					imageData.rect.height = _xmlDic[key].child("SubTexture")[i].attribute("height");
					
					var pieceTexture:Texture = Texture.fromTexture(_spriteSheetDic[key].image.texture, imageData.rect);
					var pieceImage:Image = new Image(pieceTexture);
					
					var pt:Point = new Point(0,0);
					var pieceBitmapData:BitmapData = new BitmapData(imageData.rect.width, imageData.rect.height);
					pieceBitmapData.copyPixels(_spriteSheetDic[key].bitmapData, imageData.rect, pt);
					
					
					pieceImage.name = imageData.name;
					imageData.image = pieceImage;
					imageData.bitmapData = pieceBitmapData;
					
					_pieceImageVectorAMode.push(pieceImage);					
					_pieceImageDicIMode[imageData.name] = imageData; 
				}
				
				_sheetImageDicIMode[key] = _pieceImageDicIMode;
				_sheetImageDicAMode[key] = _pieceImageVectorAMode;
		
			}
			
			dispatchEvent(new Event("loaded"));
			
			
		}
		
		
		/**
		 * 
		 * @param event 완료
		 * 해당 파일의 로딩이 완료되면, image 로 형변환하여 배열에 저장하고, 보여주기용 배열에 스케일링하여 저장하는 이벤트 리스너
		 */
		private function onLoaderComplete(event:flash.events.Event):void
		{
			
			_selectSpriteSheetButton.visible = true;
			
			var loaderInfo:LoaderInfo = LoaderInfo(event.target);
			
			var bitmap:Bitmap;
			bitmap = loaderInfo.content as Bitmap;
			var texture:Texture = Texture.fromBitmap(bitmap);			
			var image:Image = new Image(texture);
			
			var imageData:ImageData = new ImageData();
			imageData.image = image;
			imageData.bitmapData = bitmap.bitmapData;
			//이름 따오기
			var name:String = loaderInfo.url;
			var slash:int = name.lastIndexOf("/");
			var dot:int = name.lastIndexOf(".");
			name = name.substring(slash + 1, dot);		
			
			//원본 스프라이트시트 딕셔너리에 추가
			_spriteSheetDic[name] = imageData;
			
			//보여주기용 스프라이트시트 세팅
			image.scale = 0.25;
			var scaledSpriteSheet:Image = image;
			
			scaledSpriteSheet.pivotX = scaledSpriteSheet.width / 2;
			scaledSpriteSheet.pivotY = scaledSpriteSheet.height / 2;
			
			scaledSpriteSheet.x = 150;
			scaledSpriteSheet.y = 150;
			scaledSpriteSheet.visible = false;
			
			//딕셔너리에 추가
			_scaledSpriteSheetDic[name] = scaledSpriteSheet;
			
			
			addChild(scaledSpriteSheet);			
			
			
			setSpriteSheetTextField(name);
			
			loaderInfo.removeEventListener(flash.events.Event.COMPLETE, onLoaderComplete);
			completeAll();
		}
		
		private function onLoaderFailed(event:flash.events.Event):void
		{
			trace("로드 실패 " + event);			
		}
		
	
		/**
		 * 
		 * @param name 이미지 파일(스프라이트시트.png)의 이름
		 * 텍스트 필드를 세팅하는 메소드
		 */
		private function setSpriteSheetTextField(name:String):void
		{
			var _spriteSheetTextField:TextField;
			_spriteSheetTextField = new TextField(240,24, "");
			
			_spriteSheetTextField.text = name;
			_spriteSheetTextField.name = name;
			_spriteSheetTextField.border = true;
			
			_spriteSheetVector.push(_spriteSheetTextField);
			
			if(_numberOfPNG == _spriteSheetVector.length)
			{
				for(var i:int = 0; i < _spriteSheetVector.length; ++i)
				{					
					_spriteSheetVector[i].x = 50;
					_spriteSheetVector[i].y = 624 + (i * 24);
					_spriteSheetList.visible = false;
					_spriteSheetList.addChild(_spriteSheetVector[i]);
					if(i == _spriteSheetVector.length - 1)
					{
						_currentTextField.text = _spriteSheetVector[i].name;
						_currentTextField.name = _spriteSheetVector[i].name;
					
						_scaledSpriteSheetDic[_currentTextField.text].visible = true;
					}
				}
				
				_spriteSheetList.addEventListener(TouchEvent.TOUCH, onSelectSpriteSheetList);
				addChild(_spriteSheetList);
				
				
			}
		}
		

		
		/**
		 * 
		 * @param event 클릭
		 * 스프라이트시트 리스트 중 하나를 클릭했을때 발생하는 이벤트 리스너
		 */
		private function onSelectSpriteSheetList(event:TouchEvent):void
		{
			for(var i:int = 0; i<_spriteSheetVector.length; ++i)
			{
				var touch:Touch = event.getTouch(_spriteSheetVector[i], TouchPhase.ENDED);
				if(touch)
				{
					trace(touch.target.name);
					_currentTextField.text = touch.target.name;
					_spriteSheetList.visible = false;
					
					//딕셔너리를 순회하여 모든 작은이미지들의 visible을 끄고, 선택된 이미지의 visible만 true로 함
					for(var key:String in _scaledSpriteSheetDic)
					{
						_scaledSpriteSheetDic[key].visible = false;
					}
					_scaledSpriteSheetDic[_currentTextField.text].visible = true;	
					
					dispatchEvent(new Event("selected"));
					
				}
			}			
			
		}
		
		
	}
}