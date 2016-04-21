package
{	
	import com.adobe.nativeExtensions.Vibration;
	import com.yoonsik.YoonsikExtension;
	
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Screen;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import mode.AnimationMode;
	import mode.ImageMode;
	
	import packer.MaxRectPacker;
	
	import resourceLoader.GUILoader;
	import resourceLoader.SpriteSheet;
	
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	public class MainStage extends Sprite
	{
		private var _YSExt:YoonsikExtension = new YoonsikExtension();
		private var _vibeExt:Vibration = new Vibration(); 
		private var _stageWidth:int;
		private var _stageHeight:int;
		private var _animationMode:AnimationMode;
		private var _imageMode:ImageMode; 
		private var _spriteSheet:SpriteSheet;
		private var _loadResource:GUILoader;
		
		private var _guiArray:Vector.<Image> = new Vector.<Image>;									//gui 리소스가 담긴 배열
		
		private var _animationModeOnButton:Image;
		private var _animationModeOffButton:Image;
		private var _imageModeOnButton:Image;
		private var _imageModeOffButton:Image;
		
		private var _animationModeText:TextField;
		private var _imageModeText:TextField;
		
		private var _spriteVector:Vector.<TextField> = new Vector.<TextField>;
		
		private var _addedSpriteSheetVector:Vector.<Image>;
		private var _addedSpriteSheetDic:Dictionary = new Dictionary();
		
		public function MainStage()
		{
			
			_stageWidth = Screen.mainScreen.bounds.width;
			_stageHeight = Screen.mainScreen.bounds.height;
			_loadResource = new GUILoader(onLoadingComplete);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onBack);
			addEventListener(TouchEvent.TOUCH, onAddedEvents);	
		}
	
		/**
		 * 
		 * @param event 디바이스의 뒤로가기 버튼
		 * 뒤로가기를 누르면 종료 alert를 띄우고, 예를 누르면 종료, 아니오를 누르면 취소
		 */
		private function onBack(event:KeyboardEvent):void
		{
			switch(event.keyCode)
			{
				case Keyboard.BACK:
					trace("back");
					event.preventDefault();
					_YSExt.alert("a");
					
					break;
			}
		}

		/**
		 * 모든 터치 이벤트를 관장하는 이벤트 리스너 
		 * @param event
		 * 
		 */
		private function onAddedEvents(event:starling.events.Event):void
		{
			//trace(event.target);
			_animationModeOnButton.addEventListener(TouchEvent.TOUCH, onTouchRadioAnimationModeOn);
			_animationModeOffButton.addEventListener(TouchEvent.TOUCH, onTouchRadioAnimationModeOff);
			
			_imageModeOnButton.addEventListener(TouchEvent.TOUCH, onTouchRadioImageModeOn);
			_imageModeOffButton.addEventListener(TouchEvent.TOUCH, onTouchRadioImageModeOff);
		}
		
		/**
		 * 모든 리소스의 로딩이 끝났는지를 검사하는 메소드
		 * 다 끝났다면 새 배열로 복사함
		 * 
		 */
		private function onLoadingComplete():void
		{	
			
			//얼마나 로딩됬는지를 나타냄
//			if(_loadResource.imageDataArray.length / _loadResource.fileCount != 1)
//				trace((_loadResource.imageDataArray.length / _loadResource.fileCount * 100).toFixed(1));
//			else if(_loadResource.imageDataArray.length / _loadResource.fileCount == 1)
//				trace("이미지 로딩 완료");
//			else
//				trace("이미지 로딩 실패");
			
			trace("배열길이 = " + _loadResource.imageDataArray.length);
			trace("카운트 = " + _loadResource.fileCount);
			//모두 로딩이 됬다면
			if(_loadResource.imageDataArray.length == _loadResource.fileCount)
			{	
				moveToImage(_loadResource.imageDataArray);
				init();
				
				trace(this.width + " " + this.height);
				_spriteSheet = new SpriteSheet(_stageWidth, _stageHeight);
				_spriteSheet.init(_guiArray);
				_spriteSheet.addEventListener("selected", onSelectSpriteSheet);
				_spriteSheet.addEventListener("loaded", onSelectSpriteSheet);
				addChild(_spriteSheet);
				
				_animationMode = new AnimationMode(_stageWidth, _stageHeight);
				_animationMode.init(_guiArray);	
				_animationMode.addEventListener("Play", onClickPlayButton);
				_animationMode.addEventListener("Pause", onClickPauseButton);
				_animationMode.addEventListener("Delete", onClickDeleteButton);				
				addChild(_animationMode);
				
				_imageMode = new ImageMode(_stageWidth, _stageHeight);
				_imageMode.init(_guiArray);
				_imageMode.addEventListener("save", onClickImageSaveButton);
				_imageMode.addEventListener("add", onAddImage);
				_imageMode.visible = false;
				addChild(_imageMode);
				
			}
		}
		
		/**
		 * 
		 * @param loadedImageArray ImageData 타입의 어레이
		 * @return Image 타입의 어레이
		 * ImageData의 비트맵데이터와 이름을 Image에 옮기는 메소드
		 */
		private function moveToImage(loadedImageArray:Vector.<ImageData>):void
		{
			for(var i:int = 0; i<loadedImageArray.length; ++i)
			{				
				var texture:Texture = Texture.fromBitmapData(loadedImageArray[i].bitmapData);
				//_textureArray.push(texture);
				
				var image:Image = new Image(texture);				
				image.name = loadedImageArray[i].name;
				
				_guiArray.push(image);
				
			}			
			
		}
		
		/**
		 * 로드된 UI 객체들을 초기화 하는 메소드 
		 * 
		 */
		private function init():void
		{
			//trace("init");
			for(var i:int = 0; i<_guiArray.length; ++i)
			{
				switch(_guiArray[i].name)
				{
					case "radioButtonOff":
						_animationModeOffButton = new Image(_guiArray[i].texture);
						_animationModeOffButton.x = _stageWidth / 10 * 4.5;
						_animationModeOffButton.y = _stageHeight / 10 * 6;						
						_animationModeOffButton.width = _stageWidth / 10 / 2;
						_animationModeOffButton.height = _animationModeOffButton.width;
						_animationModeOffButton.alignPivot("center", "center");
						_animationModeOffButton.visible = false;
						addChild(_animationModeOffButton);
						
						_imageModeOffButton = new Image(_guiArray[i].texture);
						_imageModeOffButton.x = _stageWidth / 10 * 4.5;
						_imageModeOffButton.y = _stageHeight / 10 * 8;
						_imageModeOffButton.width = _stageWidth / 10 / 2;
						_imageModeOffButton.height = _imageModeOffButton.width;
						_imageModeOffButton.alignPivot("center", "center");
						_imageModeOffButton.visible = true;
						addChild(_imageModeOffButton);						
						break;
					case "radioButtonOn":
						_animationModeOnButton = new Image(_guiArray[i].texture);
						_animationModeOnButton.x = _stageWidth / 10 * 4.5;
						_animationModeOnButton.y = _stageHeight / 10 * 6;
						_animationModeOnButton.width = _stageWidth / 10 / 2;
						_animationModeOnButton.height = _animationModeOnButton.width;
						_animationModeOnButton.alignPivot("center", "center");
						_animationModeOnButton.visible = true;
						addChild(_animationModeOnButton);
						
						_imageModeOnButton = new Image(_guiArray[i].texture);
						_imageModeOnButton.x = _stageWidth / 10 * 4.5;
						_imageModeOnButton.y = _stageHeight / 10 * 8;
						_imageModeOnButton.width = _stageWidth / 10 / 2;
						_imageModeOnButton.height = _imageModeOnButton.width;
						_imageModeOnButton.alignPivot("center", "center");
						_imageModeOnButton.visible = false;
						addChild(_imageModeOnButton);
						break;
//					case "content":
//						_content = new Image(_guiArray[i].texture);								
//						_content.x = _stageWidth / 10 / 2;
//						_content.y = _stageHeight / 10 / 2;
//						_content.width = _stageWidth / 10 * 9;
//						_content.height = _stageHeight / 10 * 5;
//						addChild(_content);
//						
//						break;
					
				}
			}
			
			_animationModeText = new TextField(_stageWidth / 10, _stageHeight / 10, "Animation Mode");
			_animationModeText.format.size = 40;			
			_animationModeText.x = _stageWidth / 10 * 4.5;
			_animationModeText.y = _stageHeight / 10 * 6.75;			
			_animationModeText.alignPivot("center", "center");
			//_animationModeText.border = true;
			addChild(_animationModeText);
			
			_imageModeText = new TextField(_stageWidth / 10, _stageHeight / 10, "Image Mode");
			_imageModeText.format.size = 40;
			_imageModeText.x = _stageWidth / 10 * 4.5;
			_imageModeText.y = _stageHeight / 10 * 8.75;
			_imageModeText.alignPivot("center", "center");
			//_imageModeText.border = true;
			addChild(_imageModeText);
			
		}
		
		/**
		 * 
		 * @param event 마우스가 버튼위에 올라오는 이벤트
		 * 터치 (클릭)이 발생하면, 라디오 버튼의 이미지를 바꿔주는 콜백 메소드 (아래 4개 동일)
		 */		
		private function onTouchRadioAnimationModeOn(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_animationModeOnButton, TouchPhase.ENDED);
			if(touch)
			{
				//trace("라디오 터치");
				_animationModeOnButton.visible = true;
				_animationModeOffButton.visible = false;
				
				_imageModeOnButton.visible = false;
				_imageModeOffButton.visible = true;
				
				_animationMode.visible = true;
				_imageMode.visible = false;
			}
		}
		
		private function onTouchRadioAnimationModeOff(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_animationModeOffButton, TouchPhase.ENDED);
			if(touch)
			{
				_animationModeOnButton.visible = true;
				_animationModeOffButton.visible = false;
				
				_imageModeOnButton.visible = false;
				_imageModeOffButton.visible = true;
				
				_animationMode.visible = true;
				_imageMode.visible = false;
			}
		}
		
		
		private function onTouchRadioImageModeOn(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_imageModeOnButton, TouchPhase.ENDED);
			if(touch)
			{
				_animationModeOnButton.visible = false;
				_animationModeOffButton.visible = true;
				
				_imageModeOnButton.visible = true;
				_imageModeOffButton.visible = false;
				
				_animationMode.visible = false;
				_imageMode.visible = true;
			}
		}
		
		
		private function onTouchRadioImageModeOff(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_imageModeOffButton, TouchPhase.ENDED);
			if(touch)
			{
				_animationModeOnButton.visible = false;
				_animationModeOffButton.visible = true;
				
				_imageModeOnButton.visible = true;
				_imageModeOffButton.visible = false;
				
				_animationMode.visible = false;
				_imageMode.visible = true;
				
				if(_animationMode.timer != null && _animationMode.timer.running)
					onClickPauseButton();
			}
		}
		
		
		/**
		 * 이미지모드 - 왼쪽에서 스프라이트시트를 선택하면 오른쪽에 안에 들어있는 이미지들을 순차적으로 담는 메소드 
		 * 
		 */		
		private function onSelectSpriteSheet():void
		{
			trace("스프라이트 시트 선택함");
			_imageMode.currentPage = 0;
			_animationMode.currentIndex = 0;
			
			_imageMode.selectSpriteSheetButton.visible = true;
			var dic:Dictionary = _spriteSheet.sheetImageDicIMode;
			var pieceDic:Dictionary = dic[_spriteSheet.currentTextField.text];
			
			
			//trace(pieceDic);
			var setY:int;
			var count:int;
			var length:int = FunctionMgr.getDictionaryLength(pieceDic);
			
			_imageMode.spriteListVector = new Vector.<Sprite>;
			_imageMode.listSpr = new Sprite();
			_imageMode.listSpr.x = _stageWidth / 10 * 6.5;
			_imageMode.listSpr.y = _stageHeight / 10 * 6.5;
			_imageMode.listSpr.visible = false;
			
			for(var key:String in pieceDic)
			{
				count++;
				
				var textField:TextField = new TextField(_stageWidth / 10 * 1.5, _stageHeight / 10 / 2, pieceDic[key].name);
				textField.format.size = 30;
				textField.alignPivot("center", "center");
				textField.y = setY;
				
				textField.border = true;
				textField.name = pieceDic[key].name;
				_spriteVector.push(textField);
				
				_imageMode.listSpr.addChild(textField);
				
				
				if(count % 5 != 0)
				{
					setY += _stageHeight / 10 / 2;
				}
				else
				{
					_imageMode.listSpr.addEventListener(TouchEvent.TOUCH, onSelectSpriteList);
					
					_imageMode.spriteListVector.push(_imageMode.listSpr);
					_imageMode.listSpr.visible = false;
					_imageMode.addChild(_imageMode.listSpr);
					_imageMode.listSpr = new Sprite();
					_imageMode.listSpr.x = _stageWidth / 10 * 6.5;
					_imageMode.listSpr.y = _stageHeight / 10 * 6.5;
					
					setY = 0;					
				}
				
				if(count == length)
				{
					_imageMode.listSpr.addEventListener(TouchEvent.TOUCH, onSelectSpriteList);					
					_imageMode.spriteListVector.push(_imageMode.listSpr);
					_imageMode.listSpr.visible = false;
					_imageMode.addChild(_imageMode.listSpr);
				}
			}
			
			
			//_imageMode.spriteListVector.sort(FunctionMgr.compareName);
			_animationMode.timer = new Timer(_animationMode.delay, _spriteSheet.sheetImageDicAMode[_spriteSheet.currentTextField.text].length - _animationMode.currentIndex);
		}
		
	
		
		/**
		 * 
		 * @param event 텍스트 필드 클릭
		 * 이미지모드 - 텍스트 필드를 클릭하면 해당 이름의 이미지를 화면에 띄워주는 메소드 
		 */
		private function onSelectSpriteList(event:TouchEvent):void
		{
			//trace("리스트 클릭");
			for(var i:int = 0; i<_spriteVector.length; ++i)
			{
				var touch:Touch = event.getTouch(_spriteVector[i], TouchPhase.ENDED);
				if(touch)
				{
					
					//trace(touch.target.name);
					_imageMode.pieceImage.texture = _spriteSheet.sheetImageDicIMode[_spriteSheet.currentTextField.text][touch.target.name].image.texture;
					_imageMode.pieceImage.width = _spriteSheet.sheetImageDicIMode[_spriteSheet.currentTextField.text][touch.target.name].rect.width * _stageWidth / 1000;
					_imageMode.pieceImage.height = _spriteSheet.sheetImageDicIMode[_spriteSheet.currentTextField.text][touch.target.name].rect.height * _stageHeight / 1000;
					_imageMode.currentImageTextField.text =  _spriteSheet.sheetImageDicIMode[_spriteSheet.currentTextField.text][touch.target.name].name;
					
//					if(_imageMode.pieceImage.width > 400 || _imageMode.pieceImage.height > 400)
//					{
//						_imageMode.pieceImage.width /= 2;
//						_imageMode.pieceImage.height /= 2;
//						_imageMode.currentImageTextField.text += " (2배 축소)";
//						trace("축소");
//					}
					
					_YSExt.toast(_imageMode.currentImageTextField.text);
					_vibeExt.vibrate(250);
					
					FunctionMgr.makeVisibleFalse(_imageMode.spriteListVector);
					
					_imageMode.makeArrowVisibleFalse();
				}
			}
		}
		
		//플레이버튼 클릭 (dispatch된 콜백메소드)
		private function onClickPlayButton():void
		{
			trace("재생");
			
			_vibeExt.vibrate(250);
			if(_spriteSheet.currentTextField.text == "")
			{
				trace("스프라이트시트를 먼저 추가해야합니다.");
				_YSExt.toast("스프라이트시트를 먼저 추가해야합니다.");
				return;	
			}
			if(_animationMode.timer.running)
			{
				_YSExt.toast("이미 재생중입니다.");
				return;
			}
			_animationMode.timer = new Timer(_animationMode.delay, _spriteSheet.sheetImageDicAMode[_spriteSheet.currentTextField.text].length - _animationMode.currentIndex);
						
			_animationMode.timer.addEventListener(TimerEvent.TIMER, onTimerStart);
			_animationMode.timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerStop)
				
			_animationMode.timer.start();		
		}
		
		//일시정지버튼 클릭 (dispatch된 콜백메소드)
		private function onClickPauseButton():void
		{
			if(_spriteSheet.currentTextField.text == "")
			{
				trace("스프라이트시트를 먼저 추가해야합니다.");
				_YSExt.toast("스프라이트시트를 먼저 추가해야합니다.");
				return;	
			}
			_vibeExt.vibrate(250);
			_animationMode.timer.stop();
			_animationMode.timer.removeEventListener(TimerEvent.TIMER, onTimerStart);
			_animationMode.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerStop);
		}
		
		//삭제버튼 클릭 (dispatch된 콜백메소드) - 타이머가 일시정지(정지)된 상태에서만 삭제 가능
		private function onClickDeleteButton():void
		{
			_vibeExt.vibrate(250);
			
			if(_spriteSheet.currentTextField.text == "")
			{
				trace("스프라이트시트를 먼저 추가해야합니다.");
				_YSExt.toast("스프라이트시트를 먼저 추가해야합니다.");
				return;	
			}
			//일시정지중이면
			if(!_animationMode.timer.running)
			{
				_spriteSheet.sheetImageDicAMode[_spriteSheet.currentTextField.text].splice(_animationMode.currentIndex - 1, 1);
				_animationMode.nameTextField.text = "삭제됨";
				_animationMode.currentIndex--;
			}
		}
		
		
		/**
		 * 
		 * @param event timer가 시작됨
		 * 정해진 시간마다 1번씩 들어오는 콜백메소드. 애니메이션을 띄워준다
		 */
		private function onTimerStart(event:TimerEvent):void
		{
			
			trace("타이머 시작");
			
			_animationMode.pieceImage.texture = _spriteSheet.sheetImageDicAMode[_spriteSheet.currentTextField.text][_animationMode.currentIndex].texture;
			_animationMode.pieceImage.width = _spriteSheet.sheetImageDicAMode[_spriteSheet.currentTextField.text][_animationMode.currentIndex].width * _stageWidth / 1000;
			_animationMode.pieceImage.height = _spriteSheet.sheetImageDicAMode[_spriteSheet.currentTextField.text][_animationMode.currentIndex].height * _stageHeight / 1000;
			_animationMode.nameTextField.text = _spriteSheet.sheetImageDicAMode[_spriteSheet.currentTextField.text][_animationMode.currentIndex].name; 
			
//			if(_animationMode.pieceImage.width > _screenWidth / 10 * 2.5 || _animationMode.pieceImage.height > _screenHeight / 10 * 2.5)
//			{
//				_animationMode.pieceImage.width /= 2;
//				_animationMode.pieceImage.height /= 2;
//				_animationMode.nameTextField.text += " (2배 축소)";
//				trace("축소");
//			}
			
			
			_animationMode.indexTextField.text = (_animationMode.currentIndex + 1).toString() + " / " + (_spriteSheet.sheetImageDicAMode[_spriteSheet.currentTextField.text].length ); 
			_animationMode.currentIndex++;
		}
		
		/**
		 * 
		 * @param event 타이머 종료
		 * 
		 */
		private function onTimerStop(event:TimerEvent):void
		{
			trace("타이머 종료");
			_animationMode.currentIndex = 0;
			
			_animationMode.timer.removeEventListener(TimerEvent.TIMER, onTimerStart);
			_animationMode.timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerStop);
			
		}
		
		/**
		 * 
		 * 디스패치된 저장 버튼 클릭 메소드 
		 */
		private function onClickImageSaveButton():void
		{
			if(_imageMode.currentImageTextField.text == "")
			{
				trace("저장할 이미지를 선택하세요");
				_YSExt.toast("저장할 이미지를 선택하세요.");
				return;
			}
			var pngFile:File = File.documentsDirectory.resolvePath("images/" + _imageMode.currentImageTextField.text + ".png");
		
			var byteArray:ByteArray = PNGEncoder.encode(_spriteSheet.sheetImageDicIMode[_spriteSheet.currentTextField.text][_imageMode.currentImageTextField.text].bitmapData);
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(pngFile, FileMode.WRITE);
			fileStream.writeBytes(byteArray);
			fileStream.close();
			
			_YSExt.toast(_imageMode.currentImageTextField.text + ".png 저장 완료");
		}
		
		private function onAddImage():void
		{
			_addedSpriteSheetVector = new Vector.<Image>;
			
			var maxRect:MaxRectPacker = new MaxRectPacker(1024, 1024);
			var tempDic:Dictionary = _spriteSheet.sheetImageDicIMode[_spriteSheet.currentTextField.text];
			
			var tempVec:Vector.<ImageData> = _imageMode.addedImageVector;
			//_addedSpriteSheetVector = _imageMode.addedImageVector;
			
			trace("---------tempVec---------");
			for(var i:int = 0; i < tempVec.length; ++i)
			{
				_YSExt.toast(tempVec[i].name + " 추가");
				trace(tempVec[i].name);	
			}
			
			for(var key:String in tempDic)
			{
				//trace(tempDic[key].name);
				var imageData:ImageData = new ImageData();
				imageData.image = tempDic[key].image;
				imageData.bitmapData = tempDic[key].bitmapData;
				imageData.name = tempDic[key].name;
				imageData.rect.x = tempDic[key].rect.x;
				imageData.rect.y = tempDic[key].rect.y;
				imageData.rect.width = tempDic[key].bitmapData.width;
				imageData.rect.height = tempDic[key].bitmapData.height;
				tempVec.push(imageData);
			}
			
			
			
			
			
			tempVec.sort(FunctionMgr.compareAreaDescending);
			for(var i:int = 0; i < tempVec.length; ++i)
			{
				var rect:Rectangle = maxRect.quickInsert(tempVec[i].bitmapData.width, tempVec[i].bitmapData.height); 
				//trace("삽입 위치 = " + rect);
				if(rect == null)
				{
					_YSExt.toast(tempVec[i].name + " 공간 부족");
					continue;
				}
				
				var imageData:ImageData = new ImageData();
				imageData.image = tempVec[i].image;
				imageData.bitmapData = tempVec[i].bitmapData;
				imageData.name = tempVec[i].name;
				imageData.rect.x = rect.x;
				imageData.rect.y = rect.y;
				imageData.rect.width = tempVec[i].bitmapData.width;
				imageData.rect.height = tempVec[i].bitmapData.height;
				_addedSpriteSheetDic[imageData.name] = imageData;
				_addedSpriteSheetVector.push(imageData.image);
			}
			
			var tempSpr:flash.display.Sprite = new flash.display.Sprite();
			
			var bmd:BitmapData = new BitmapData(1024, 1024);
			
			for(var key:String in _addedSpriteSheetDic)
			{
				var bitmap:Bitmap = new Bitmap(_addedSpriteSheetDic[key].bitmapData);
				bitmap.x = _addedSpriteSheetDic[key].rect.x;
				bitmap.y = _addedSpriteSheetDic[key].rect.y;
				tempSpr.addChild(bitmap);
				var rect:Rectangle = new Rectangle(0, 0, bitmap.bitmapData.width, bitmap.bitmapData.height);
				bmd.merge(bitmap.bitmapData, rect, new Point(bitmap.x, bitmap.y), 0xFF, 0xFF, 0xFF, 0xFF);
			}
			
			var rt:Rectangle = new Rectangle(0, 0, FunctionMgr.getCorrectLength(tempSpr.width), FunctionMgr.getCorrectLength(tempSpr.height));
			var newBmd:BitmapData = new BitmapData(rt.width, rt.height);
			var pt:Point = new Point(0,0);
			newBmd.copyPixels(bmd, rt, pt);
			var texture:Texture = Texture.fromBitmapData(newBmd);			
			var image:Image = new Image(texture);
			
			//_spriteSheet.sheetImageDicIMode[_spriteSheet.currentTextField.text];
			
			//_spriteSheet.sheetImageDicIMode[_spriteSheet.currentTextField.text] ************ dispose 해야함
			
			var currentSpriteName:String = _spriteSheet.currentTextField.text;
			
			
			_spriteSheet.sheetImageDicIMode[currentSpriteName] = _addedSpriteSheetDic;
			
//			for(var key:String in _spriteSheet.sheetImageDicAMode[currentSpriteName])
//			{
//				_spriteSheet.sheetImageDicAMode[currentSpriteName][key].dispose();
//				_spriteSheet.sheetImageDicAMode[currentSpriteName][key] = null;
//			}
			//_spriteSheet.sheetImageDicAMode[currentSpriteName] = null;
			
			_spriteSheet.sheetImageDicAMode[currentSpriteName] = _addedSpriteSheetVector;
			
			//_spriteSheet.scaledSpriteSheetDic[_spriteSheet.currentTextField.text].visible = false;
			var scaledSpriteSheet:Sprite = new Sprite();
			image.width *= _stageWidth / 2500;
			image.height *= _stageHeight / 2500;
			scaledSpriteSheet.addChild(image);
			
			scaledSpriteSheet.x = _stageWidth / 10 * 2.5;
			scaledSpriteSheet.y = _stageHeight / 10 * 3;
			scaledSpriteSheet.alignPivot("center", "center");
			
			_spriteSheet.addChild(scaledSpriteSheet);
			
			_spriteSheet.scaledSpriteSheetDic[currentSpriteName].visible = false;
			_spriteSheet.scaledSpriteSheetDic[currentSpriteName].dispose();
			_spriteSheet.scaledSpriteSheetDic[currentSpriteName] = scaledSpriteSheet;
		}
		
	
	}
}