package mode
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
	
	import exporter.Exporter;
	
	import packer.MaxRectPacker;
	
	import resourceLoader.GUILoader;
	import resourceLoader.SpriteSheet;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.text.TextField;
	import starling.textures.Texture;
	
	public class MainStage extends Sprite
	{
		private var _YSExt:YoonsikExtension;
		private var _vibeExt:Vibration = new Vibration(); 
		private var _stageWidth:int;
		private var _stageHeight:int;
		
		private var _exporter:Exporter;
		private var _modeChooser:ModeChooser;
		private var _animationMode:AnimationMode;
		private var _imageMode:ImageMode; 
		private var _spriteSheet:SpriteSheet;
		private var _loadResource:GUILoader;
		
		private var _guiArray:Vector.<Image> = new Vector.<Image>;									//gui 리소스가 담긴 배열
	
		private var _spriteVector:Vector.<TextField> = new Vector.<TextField>;
		
		private var _addedSpriteSheetVector:Vector.<Image>;
		private var _addedSpriteSheetDic:Dictionary = new Dictionary();
		
		public function MainStage()
		{
			_YSExt = new YoonsikExtension();
			_stageWidth = Screen.mainScreen.bounds.width;
			_stageHeight = Screen.mainScreen.bounds.height;
			_loadResource = new GUILoader(onLoadingComplete);
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onBack);
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
					event.preventDefault();
					_YSExt.alert("exit");					
					break;
			}
		}
		
		/**
		 * 모든 리소스의 로딩이 끝났는지를 검사하는 메소드
		 * 다 끝났다면 새 배열로 복사함
		 * 
		 */
		private function onLoadingComplete():void
		{	
			//모두 로딩이 됬다면
			if(_loadResource.imageDataArray.length == _loadResource.fileCount)
			{	
				moveToImage(_loadResource.imageDataArray);
				
				_exporter = new Exporter();
				
				_modeChooser = new ModeChooser(_stageWidth, _stageHeight);
				_modeChooser.init(_guiArray); 
				_modeChooser.addEventListener("animationModeOn", onClickAnimationModeOn)
				_modeChooser.addEventListener("imageModeOn", onClickImageModeOn)
				addChild(_modeChooser);
				
				_spriteSheet = new SpriteSheet(_stageWidth, _stageHeight);
				_spriteSheet.init(_guiArray);
				_spriteSheet.addEventListener("selectSheet", onClickSheetSelectButton);
				_spriteSheet.addEventListener("loadSheet", onLoadSheet);
				addChild(_spriteSheet);
				
				_animationMode = new AnimationMode(_stageWidth, _stageHeight);
				_animationMode.init(_guiArray);	
				_animationMode.addEventListener("Play", onClickPlayButton);
				_animationMode.addEventListener("Pause", onClickPauseButton);
				_animationMode.addEventListener("Delete", onClickDeleteButton);				
				addChild(_animationMode);
				
				_imageMode = new ImageMode(_stageWidth, _stageHeight);
				_imageMode.init(_guiArray);
				_imageMode.addEventListener("saveImage", onClickImageSaveButton);
				_imageMode.addEventListener("saveSheet", onClickSheetSaveButton);
				_imageMode.addEventListener("add", onAddImage);
				_imageMode.addEventListener("selectImage", onClickImageSelectButton);
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
				
				var image:Image = new Image(texture);				
				image.name = loadedImageArray[i].name;
				
				_guiArray.push(image);
				image.dispose();
				image = null;
			}			
		}
		
		private function onClickAnimationModeOn():void
		{
			_animationMode.visible = true;
			_imageMode.visible = false;
			
			if(_animationMode.timer != null && _animationMode.timer.running)
				onClickPauseButton();
		}
		
		private function onClickImageModeOn():void
		{
			_animationMode.visible = false;
			_imageMode.visible = true;
		}
		
		//스프라이트시트 선택 버튼 클릭
		private function onClickSheetSelectButton():void
		{			
			var array:Array = new Array();
			var tempDic:Dictionary = _spriteSheet.spriteSheetDic;
			for(var key:String in tempDic)
			{
				array.push(tempDic[key].name);
			}
			array.sort(FunctionMgr.compareAscending);
			_YSExt.selectImage(array, onSheetSelected);
			array = null;
		}
		
		//이미지가 선택되었다면 작동하는 콜백 메소드
		private function onSheetSelected(name:String):void
		{	
			_animationMode.currentIndex = 0;
			_animationMode.timer = new Timer(_animationMode.delay, _spriteSheet.sheetImageDicAMode[_spriteSheet.currentTextField.text].length - _animationMode.currentIndex);
			
			_spriteSheet.currentSheetImage.texture = _spriteSheet.spriteSheetDic[name].image.texture;
			_spriteSheet.currentSheetImage.width = _spriteSheet.spriteSheetDic[name].rect.width * _stageWidth / 2500;
			_spriteSheet.currentSheetImage.height = _spriteSheet.spriteSheetDic[name].rect.height * _stageHeight / 2500;
			_spriteSheet.currentTextField.text =  _spriteSheet.spriteSheetDic[name].name;
		}
		
		//로드스프라이트시트 버튼을 누르면 애니메이션 모드의 현재 인덱스와 타이머를 재할당함
		private function onLoadSheet():void
		{
			_animationMode.currentIndex = 0;
			_animationMode.timer = null;
			_animationMode.timer = new Timer(_animationMode.delay, _spriteSheet.sheetImageDicAMode[_spriteSheet.currentTextField.text].length - _animationMode.currentIndex);
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
			_animationMode.timer = null;
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
				_animationMode.currentIndex = 0;
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
			fileStream = null;
			
			_YSExt.toast(_imageMode.currentImageTextField.text + ".png 저장 완료");
		}
		
		/**
		 * 현재 시트를 png와 xml로 저장하는 메소드 
		 * 
		 */
		private function onClickSheetSaveButton():void
		{
			_exporter.exportToPNG(new Bitmap(_spriteSheet.spriteSheetDic[_spriteSheet.currentTextField.text].bitmapData));
			_YSExt.toast("new_sprite_sheet"+_exporter.count+".png 저장");
			
			_exporter.exportToXML(_spriteSheet.sheetImageDicIMode[_spriteSheet.currentTextField.text]);
			_YSExt.toast("new_sprite_sheet"+_exporter.count+".xml 저장");
			_exporter.count++;
		}
		
		/**
		 * 현재 보여지는 시트에 현재 이미지를 추가하여 maxrect packing하는 메소드 
		 * 
		 */
		private function onAddImage():void
		{
			_addedSpriteSheetVector = new Vector.<Image>;
			var currentSheetName:String = _spriteSheet.currentTextField.text;
			
			var maxRect:MaxRectPacker = new MaxRectPacker(1024, 1024);
			var tempDic:Dictionary = _spriteSheet.sheetImageDicIMode[_spriteSheet.currentTextField.text];
			
			var tempVec:Vector.<ImageData> = _imageMode.addedImageVector;
			
			var imageData:ImageData, i:int, key:String, rect:Rectangle;
			trace("---------tempVec---------");
			for(i = 0; i < tempVec.length; ++i)
			{
				_YSExt.toast(tempVec[i].name + " 추가");
				trace(tempVec[i].name);	
			}
			
			for(key in tempDic)
			{
				imageData = new ImageData();
				imageData.image = tempDic[key].image;
				imageData.bitmapData = tempDic[key].bitmapData;
				imageData.name = tempDic[key].name;
				imageData.rect.x = tempDic[key].rect.x;
				imageData.rect.y = tempDic[key].rect.y;
				imageData.rect.width = tempDic[key].bitmapData.width;
				imageData.rect.height = tempDic[key].bitmapData.height;
				tempVec.push(imageData);
				
				imageData = null;
			}
			
			//패킹 시작
			tempVec.sort(FunctionMgr.compareAreaDescending);
			for(i = 0; i < tempVec.length; ++i)
			{
				rect = maxRect.quickInsert(tempVec[i].bitmapData.width, tempVec[i].bitmapData.height); 
				if(rect == null)
				{
					_YSExt.toast(tempVec[i].name + " 공간 부족");
					continue;
				}
				
				imageData = new ImageData();
				imageData.image = tempVec[i].image;
				imageData.bitmapData = tempVec[i].bitmapData;
				imageData.name = tempVec[i].name;
				imageData.rect.x = rect.x;
				imageData.rect.y = rect.y;
				imageData.rect.width = tempVec[i].bitmapData.width;
				imageData.rect.height = tempVec[i].bitmapData.height;
				_addedSpriteSheetDic[imageData.name] = imageData;
				_addedSpriteSheetVector.push(imageData.image);
				
				imageData = null;				
			}
			
			var tempSpr:flash.display.Sprite = new flash.display.Sprite();
			
			var bmd:BitmapData = new BitmapData(1024, 1024);
			
			for(key in _addedSpriteSheetDic)
			{
				var bitmap:Bitmap = new Bitmap(_addedSpriteSheetDic[key].bitmapData);
				bitmap.x = _addedSpriteSheetDic[key].rect.x;
				bitmap.y = _addedSpriteSheetDic[key].rect.y;
				tempSpr.addChild(bitmap);
				rect = new Rectangle(0, 0, bitmap.bitmapData.width, bitmap.bitmapData.height);
				//bmd.merge(bitmap.bitmapData, rect, new Point(bitmap.x, bitmap.y), 0xFF, 0xFF, 0xFF, 0xFF);
				bmd.copyPixels(bitmap.bitmapData, rect, new Point(bitmap.x, bitmap.y));
				rect = null;
			}
			
			var rt:Rectangle = new Rectangle(0, 0, FunctionMgr.getCorrectLength(tempSpr.width), FunctionMgr.getCorrectLength(tempSpr.height));
			var newBmd:BitmapData = new BitmapData(rt.width, rt.height);
			var pt:Point = new Point(0,0);
			newBmd.copyPixels(bmd, rt, pt);
			var texture:Texture = Texture.fromBitmapData(newBmd);			
			var image:Image = new Image(texture);
			
			imageData = new ImageData();
			imageData.image = image;
			imageData.bitmapData = newBmd;
			imageData.rect = newBmd.rect;
			imageData.name = currentSheetName;
			
			_spriteSheet.spriteSheetDic[currentSheetName] = imageData;
			_spriteSheet.sheetImageDicIMode[currentSheetName] = _addedSpriteSheetDic;			
			_spriteSheet.sheetImageDicAMode[currentSheetName] = _addedSpriteSheetVector;
			_spriteSheet.currentSheetImage.texture = imageData.image.texture;	
			
			_addedSpriteSheetVector = null;
			maxRect = null; 
			tempSpr = null;
			bmd.dispose(); bmd = null;
			rt = null;
			//newBmd.dispose(); newBmd = null;
			image.dispose(); image = null;			
		}
		
		// (이미지모드)이미지 선택 버튼 클릭
		private function onClickImageSelectButton():void
		{
			var array:Array = new Array();
			var tempDic:Dictionary = _spriteSheet.sheetImageDicIMode[_spriteSheet.currentTextField.text];
			for(var key:String in tempDic)
			{
				array.push(tempDic[key].name);
			}
			array.sort(FunctionMgr.compareAscending);
			_YSExt.selectImage(array, onImageSelected);
			array = null;
		}
		
		//이미지가 선택되었다면 작동하는 콜백 메소드
		private function onImageSelected(name:String):void
		{
			_imageMode.pieceImage.texture = _spriteSheet.sheetImageDicIMode[_spriteSheet.currentTextField.text][name].image.texture;
			_imageMode.pieceImage.width = _spriteSheet.sheetImageDicIMode[_spriteSheet.currentTextField.text][name].rect.width * _stageWidth / 1000;
			_imageMode.pieceImage.height = _spriteSheet.sheetImageDicIMode[_spriteSheet.currentTextField.text][name].rect.height * _stageHeight / 1000;
			_imageMode.currentImageTextField.text =  _spriteSheet.sheetImageDicIMode[_spriteSheet.currentTextField.text][name].name;
		}
	}
}