package resourceLoader
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
		private var _loadSpriteSheetsButton:Sprite = new Sprite();							//애니메이션모드, 이미지모드에서 공유됨. 스프라이트시트를 로드하는 버튼
		private var _selectSpriteSheetButton:Sprite = new Sprite();							//셀렉트버튼
		
		private var _xmlDic:Dictionary = new Dictionary();
		private var _spriteSheetDic:Dictionary = new Dictionary();							//사용자가 Load SpriteSheets 버튼을 통해 스프라이트시트를 로드하면 이 딕셔너리에 추가됨
		
		private var _pieceImageVectorAMode:Vector.<Image>;									//조각난 이미지들을 담는 배열		- 애니메이션모드용
		private var _sheetImageDicAMode:Dictionary = new Dictionary();
		
		private var _pieceImageDicIMode:Dictionary;								 			//조각난 이미지들을 담는 딕셔너리	- 이미지모드용
		private var _sheetImageDicIMode:Dictionary = new Dictionary();
		
		private var _numberOfPNG:int;
		private var _numberOfXML:int;
		
		private var _stageWidth:int;
		private var _stageHeight:int;
	
		private var _currentTextField:TextField;											//현재 선택된 스프라이트 시트를 나타내기 위한 텍스트필드
		private var _currentSheetImage:Image = new Image(null);
		
		public function SpriteSheet(stageWidth:int, stageHeight:int)
		{		
			_stageWidth = stageWidth;
			_stageHeight = stageHeight;
			addEventListener(TouchEvent.TOUCH, onAddedEvents);	
		}

		public function get currentSheetImage():Image
		{
			return _currentSheetImage;
		}

		public function set currentSheetImage(value:Image):void
		{
			_currentSheetImage = value;
		}

		public function get spriteSheetDic():Dictionary
		{
			return _spriteSheetDic;
		}

		public function set spriteSheetDic(value:Dictionary):void
		{
			_spriteSheetDic = value;
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
			var image:Image;
			for(var i:int = 0; i<guiArray.length; ++i)
			{
				switch(guiArray[i].name)
				{
					case "loadButton":
						image = new Image(guiArray[i].texture);
						image.width = _stageWidth / 10 * 3;
						image.height = image.width / 4;
						_loadSpriteSheetsButton.addChild(image);
						
						_loadSpriteSheetsButton.x = _stageWidth / 10 * 2;
						_loadSpriteSheetsButton.y = _stageHeight / 10 * 6.5;
						_loadSpriteSheetsButton.alignPivot("center", "center");
						addChild(_loadSpriteSheetsButton);
						break;
					
					case "selectButton":
						image = new Image(guiArray[i].texture);
						image.width = _stageWidth / 10 / 3;
						image.height = image.width;
						_selectSpriteSheetButton.addChild(image);
						
						_selectSpriteSheetButton.x = _stageWidth / 10 * 3.5;
						_selectSpriteSheetButton.y = _stageHeight / 10 * 7.5;
						_selectSpriteSheetButton.alignPivot("center", "center");
						_selectSpriteSheetButton.visible = false;
						addChild(_selectSpriteSheetButton);						
						break;
				}
			}
			
			_currentTextField = new TextField(_stageWidth / 10 * 2.5, _stageHeight / 10 / 2, "");
			_currentTextField.format.size = 50;
			_currentTextField.format.bold = true;
			_currentTextField.x = _stageWidth / 10 * 2;
			_currentTextField.y = _stageHeight / 10 * 7.5;
			_currentTextField.alignPivot("center", "center");
			_currentTextField.border = true;
			addChild(_currentTextField);
			
			_currentSheetImage.texture = null;
			_currentSheetImage.width = 0;
			_currentSheetImage.height = 0;
			_currentSheetImage.alignPivot("center", "center");
			_currentSheetImage.x = _stageWidth / 10 * 2.5;
			_currentSheetImage.y = _stageHeight / 10 * 3;	
			
			addChild(_currentSheetImage);
		
		}
		
		private function onAddedEvents(event:starling.events.Event):void
		{		
			_loadSpriteSheetsButton.addEventListener(TouchEvent.TOUCH, onLoadSpriteSheetsButton);	
			_selectSpriteSheetButton.addEventListener(TouchEvent.TOUCH, onClickSheetSelectButton);
			
		}
		
		
		/**
		 * 
		 * @param event 클릭
		 * 화살표 버튼을 클릭하면 드롭다운을 보여주는 이벤트리스너
		 */
		private function onClickSheetSelectButton(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_selectSpriteSheetButton, TouchPhase.ENDED);
			if(touch)
			{
				dispatchEvent(new Event("selectSheet"));
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
			
			touch = event.getTouch(_loadSpriteSheetsButton, TouchPhase.ENDED);
			if(touch)
			{
				_loadSpriteSheetsButton.scale = 1;
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
			if(_numberOfPNG == FunctionMgr.getDictionaryLength(_spriteSheetDic) && _numberOfXML == FunctionMgr.getDictionaryLength(_xmlDic))
			{
				_currentSheetImage.texture = _spriteSheetDic[_currentTextField.text].image.texture;
				_currentSheetImage.width = _spriteSheetDic[_currentTextField.text].rect.width * _stageWidth / 2500;
				_currentSheetImage.height = _spriteSheetDic[_currentTextField.text].rect.height * _stageHeight / 2500;
				
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
		}
		
		
		/**
		 * 
		 * @param event 완료
		 * 해당 파일의 로딩이 완료되면, imageData 형태로 저장하는  이벤트 리스너
		 */
		private function onLoaderComplete(event:flash.events.Event):void
		{
			
			_selectSpriteSheetButton.visible = true;
			
			var loaderInfo:LoaderInfo = LoaderInfo(event.target);
			
			var bitmap:Bitmap;
			bitmap = loaderInfo.content as Bitmap;
			var texture:Texture = Texture.fromBitmap(bitmap);			
			var image:Image = new Image(texture);
			
			//이름 따오기
			var name:String = loaderInfo.url;
			name = FunctionMgr.getRealName(name);	
			
			var imageData:ImageData = new ImageData();
			imageData.image = image;
			imageData.bitmapData = bitmap.bitmapData;
			imageData.rect = bitmap.bitmapData.rect;
			imageData.name = name;
			//원본 스프라이트시트 딕셔너리에 추가
			_currentTextField.text = name;
			_currentTextField.name = name;
			_spriteSheetDic[name] = imageData;
			
			loaderInfo.removeEventListener(flash.events.Event.COMPLETE, onLoaderComplete);
			completeAll();
		}
		
		private function onLoaderFailed(event:flash.events.Event):void
		{
			trace("로드 실패 " + event);			
		}
	}
}