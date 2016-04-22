package mode
{
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	public class ImageMode extends Sprite
	{
		private var _addButton:Sprite = new Sprite();
		private var _imageSaveButton:Sprite = new Sprite();
		private var _sheetSaveButton:Sprite = new Sprite();
		private var _currentPage:int;
		private var _pieceImage:Image = new Image(null);									//화면에 보여주기 용 스프라이트			
		private var _selectButton:Image;											//상하화살표버튼
		private var _currentImageTextField:TextField;										//현재 선택된 이미지의 이름을 나타내기 위한 텍스트필드
		
		private var _stageWidth:int;
		private var _stageHeight:int;
		
		private var _numberOfAddedPNG:int;
		private var _addedImageVector:Vector.<ImageData>;
		
		public function ImageMode(stageWidth:int, stageHeight:int)
		{
			_stageWidth = stageWidth;
			_stageHeight = stageHeight;
			addEventListener(TouchEvent.TOUCH, onAddedEvents);	
			
		}
		

		public function get addedImageVector():Vector.<ImageData>
		{
			return _addedImageVector;
		}

		public function set addedImageVector(value:Vector.<ImageData>):void
		{
			_addedImageVector = value;
		}

		public function get selectSpriteSheetButton():Image
		{
			return _selectButton;
		}

		public function set selectSpriteSheetButton(value:Image):void
		{
			_selectButton = value;
		}

		public function get currentImageTextField():TextField
		{
			return _currentImageTextField;
		}
		
		public function set currentImageTextField(value:TextField):void
		{
			_currentImageTextField = value;
		}
		
		public function get currentPage():int
		{
			return _currentPage;
		}
		
		public function set currentPage(value:int):void
		{
			_currentPage = value;
		}
		
		public function get pieceImage():Image
		{
			return _pieceImage;
		}
		
		public function set pieceImage(value:Image):void
		{
			_pieceImage = value;
		}

		
		public function init(guiArray:Vector.<Image>):void
		{
			var image:Image;
			for(var i:int = 0; i<guiArray.length; ++i)
			{
				switch(guiArray[i].name)
				{
					
					case "selectButton":
						_selectButton = new Image(guiArray[i].texture);
						_selectButton.x = _stageWidth / 10 * 6.5;
						_selectButton.y = _stageHeight / 10 * 7;
						_selectButton.width = _stageWidth / 10 ;
						_selectButton.height = _selectButton.width;
						_selectButton.alignPivot("center", "center");
						
						addChild(_selectButton);						
						break;
					
					case "sheetSaveButton":
						image = new Image(guiArray[i].texture);
						image.width = _stageWidth / 10;
						image.height = image.width;
						_sheetSaveButton.addChild(image);
						
						_sheetSaveButton.x = _stageWidth / 10 * 8.5;
						_sheetSaveButton.y = _stageHeight / 10 * 8.25;						
						_sheetSaveButton.alignPivot("center", "center");
						addChild(_sheetSaveButton);
						break;
					
					case "imageSaveButton":
						image = new Image(guiArray[i].texture);
						image.width = _stageWidth / 10;
						image.height = image.width;
						_imageSaveButton.addChild(image);
						
						_imageSaveButton.x = _stageWidth / 10 * 9.5;
						_imageSaveButton.y = _stageHeight / 10 * 8.25;						
						_imageSaveButton.alignPivot("center", "center");
						addChild(_imageSaveButton);
						break;
					
					case "addButton":
						image = new Image(guiArray[i].texture);
						image.width = _stageWidth / 10;
						image.height = image.width;
						_addButton.addChild(image);
						
						_addButton.x = _stageWidth / 10 * 9;
						_addButton.y = _stageHeight / 10 * 6.25;						
						_addButton.alignPivot("center", "center");
						addChild(_addButton);					
						break;
				}
			}
			_currentImageTextField = new TextField(_stageWidth / 10, _stageHeight / 10, "");
			_currentImageTextField.format.bold = true;
			_currentImageTextField.format.size = 50;
			_currentImageTextField.x = _stageWidth / 10 * 7.5;
			_currentImageTextField.y = _stageHeight / 10 * 5;
			_currentImageTextField.alignPivot("center", "center");
			addChild(_currentImageTextField);
			
			_pieceImage.texture = null;
			_pieceImage.width = 0;
			_pieceImage.height = 0;
			_pieceImage.alignPivot("center", "center");
			_pieceImage.x = _stageWidth / 10 * 7.5;
			_pieceImage.y = _stageHeight / 10 * 3;	
			
			addChild(_pieceImage);
		}
		
		/**
		 * 
		 * @param event 터치 이벤트
		 * 이벤트 리스너 등록
		 */
		private function onAddedEvents(event:starling.events.Event):void
		{				
			_selectButton.addEventListener(TouchEvent.TOUCH, onClickSpriteListButton);
			_imageSaveButton.addEventListener(TouchEvent.TOUCH, onClickImageSaveButton);
			_sheetSaveButton.addEventListener(TouchEvent.TOUCH, onClickSheetSaveButton);
			_addButton.addEventListener(TouchEvent.TOUCH, onClickAddButton);
		}
		

		
		/**
		 * 
		 * @param event 화면 우측 하단 스프라이트리스트버튼 클릭
		 * 5개 단위의 스프라이트 리스트를 띄워줌
		 */
		private function onClickSpriteListButton(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_selectButton, TouchPhase.ENDED);
			if(touch)
			{
				dispatchEvent(new Event("selectImage"));
			}
		}
		

		
		/**
		 * 
		 * @param event 클릭
		 * 현재 보여지는 이미지를 저장하는 콜백 메소드
		 */
		private function onClickImageSaveButton(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_imageSaveButton, TouchPhase.BEGAN);
			if(touch)
			{
				
				_imageSaveButton.scale = 0.8;
			}
			
			touch = event.getTouch(_imageSaveButton, TouchPhase.ENDED);
			if(touch)
			{
				_imageSaveButton.scale = 1;				
				dispatchEvent(new Event("saveImage"));
			}
		}
		
		/**
		 * 
		 * @param event 클릭
		 * 현재 보여지는 시트를 저장하는 콜백 메소드
		 */
		private function onClickSheetSaveButton(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_sheetSaveButton, TouchPhase.BEGAN);
			if(touch)
			{
				
				_sheetSaveButton.scale = 0.8;
			}
			
			touch = event.getTouch(_sheetSaveButton, TouchPhase.ENDED);
			if(touch)
			{
				_sheetSaveButton.scale = 1;				
				dispatchEvent(new Event("saveSheet"));
			}
		}
		
		/**
		 * 
		 * @param event 클릭
		 * 현재 스프라이트시트에 현재 이미지를 추가하는 콜백메소드
		 */
		private function onClickAddButton(event:TouchEvent):void
		{
			
			var touch:Touch = event.getTouch(_addButton, TouchPhase.BEGAN);
			if(touch)
			{
				_addButton.scale = 0.8;
			}
			
			touch = event.getTouch(_addButton, TouchPhase.ENDED);
			if(touch)
			{
				_addButton.scale = 1;	
				
				var file:File = File.applicationDirectory;
				file.browseForOpenMultiple("Select SpriteSheet PNG Files");
				file.addEventListener(FileListEvent.SELECT_MULTIPLE, onFilesSelected);
			}
		}
		
		private function onFilesSelected(event:FileListEvent):void
		{
			_numberOfAddedPNG = 0;
			_numberOfAddedPNG += event.files.length;
			
			for (var i:int = 0; i < event.files.length; ++i) 
			{
				//trace(event.files[i].nativePath);
				//PNG 로드
				var loader:Loader = new Loader();				
				loader.load(new URLRequest(event.files[i].url));				
				loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, onLoaderComplete);				
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderFailed);
				
			}
			_addedImageVector = new Vector.<ImageData>;
		}
		
		private function onLoaderComplete(event:flash.events.Event):void
		{
			var loaderInfo:LoaderInfo = LoaderInfo(event.target);
			
			var bitmap:Bitmap = loaderInfo.content as Bitmap;
			var texture:Texture = Texture.fromBitmap(bitmap);			
			var image:Image = new Image(texture);
			var imageData:ImageData = new ImageData();
			
			
			var name:String = loaderInfo.url;
//			var slash:int = name.lastIndexOf("/");
//			var dot:int = name.lastIndexOf(".");
//			name = name.substring(slash + 1, dot);
			name = FunctionMgr.getRealName(name);
			
			imageData.name = name;
			imageData.image = image;
			imageData.bitmapData = bitmap.bitmapData;
			imageData.rect = bitmap.bitmapData.rect;
			_addedImageVector.push(imageData);
			
			//선택된 추가 이미지들이 다 로드 되면
			if(_numberOfAddedPNG == _addedImageVector.length)
			{
				dispatchEvent(new Event("add"));
			}
		
		}
		
		private function onLoaderFailed(event:flash.events.Event):void
		{
			trace("로드 실패 " + event);			
		}
	}
}