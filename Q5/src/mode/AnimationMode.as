package mode
{
	import flash.utils.Timer;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;

	public class AnimationMode extends Sprite
	{
		private var _playButton:Sprite = new Sprite();
		private var _pauseButton:Sprite = new Sprite();
		private var _deleteButton:Sprite = new Sprite();	
		
		private var _fasterButton:Sprite = new Sprite();
		private var _slowerButton:Sprite = new Sprite();
		
		private var _pieceImage:Image = new Image(null);									//화면에 보여주기 용 스프라이트
		
		private var _currentIndex:int;														//현재 보여줄 이미지의 인덱스
		
		private var _delay:uint = 100;
		private var _timer:Timer = new Timer(0, 0);
		
		private var _nameTextField:TextField;												//현재 재생중인 애니메이션의 이미지의 이름을 알려주는 텍스트필드
		private var _indexTextField:TextField;
		
		private var _stageWidth:int;														//실제 디바이스의 사이즈보다 10배 작게 세팅 (무분별한 나눗셈 작업 최소화)
		private var _stageHeight:int;
		
		public function AnimationMode(stageWidth:int, stageHeight:int)
		{
			_stageWidth = stageWidth / 10;
			_stageHeight = stageHeight / 10;
			addEventListener(TouchEvent.TOUCH, onAddedEvents);	
		}
		
		public function get indexTextField():TextField{	return _indexTextField;	}
		public function set indexTextField(value:TextField):void{ _indexTextField = value; }

		public function get timer():Timer{ return _timer; }
		public function set timer(value:Timer):void{ _timer = value; }

		public function get delay():uint{ return _delay; }
		public function set delay(value:uint):void{ _delay = value; }

		public function get nameTextField():TextField{ return _nameTextField; }
		public function set nameTextField(value:TextField):void{ _nameTextField = value; }

		public function get currentIndex():int{ return _currentIndex; }
		public function set currentIndex(value:int):void{ _currentIndex = value; }

		public function get pieceImage():Image{ return _pieceImage; }
		public function set pieceImage(value:Image):void{ _pieceImage = value; }
		
		

		public function init(guiArray:Vector.<Image>):void
		{
			var image:Image;
			trace("init");
			for(var i:int = 0; i<guiArray.length; ++i)
			{
				switch(guiArray[i].name)
				{
					case "playButton":						
						image = new Image(guiArray[i].texture);
						image.width = _stageWidth;
						image.height = image.width;
						_playButton.addChild(image);
						
						_playButton.x = _stageWidth * 6;
						_playButton.y = _stageHeight * 7; 		
						_playButton.alignPivot("center", "center");
						addChild(_playButton);	
						break;
					case "pauseButton":
						image = new Image(guiArray[i].texture);
						image.width = _stageWidth;
						image.height = image.width;
						_pauseButton.addChild(image);
						
						_pauseButton.x = _stageWidth * 7.25;
						_pauseButton.y = _stageHeight * 7;
						_pauseButton.alignPivot("center", "center");
						addChild(_pauseButton);
						break;
					case "deleteButton":
						image = new Image(guiArray[i].texture);
						image.width = _stageWidth;
						image.height = image.width;
						_deleteButton.addChild(image);
						
						_deleteButton.x = _stageWidth * 8.5;
						_deleteButton.y = _stageHeight * 7;
						_deleteButton.alignPivot("center", "center");						
						addChild(_deleteButton);
						break;
					case "fasterButton":						
						image = new Image(guiArray[i].texture);
						image.width = _stageWidth / 2;
						image.height = image.width;
						_fasterButton.addChild(image);
						
						_fasterButton.x = _stageWidth * 9;
						_fasterButton.y = _stageHeight * 3; 		
						_fasterButton.alignPivot("center", "center");
						addChild(_fasterButton);	
						break;
					case "slowerButton":						
						image = new Image(guiArray[i].texture);
						image.width = _stageWidth / 2;
						image.height = image.width;
						_slowerButton.addChild(image);
						
						_slowerButton.x = _stageWidth * 6;
						_slowerButton.y = _stageHeight * 3; 		
						_slowerButton.alignPivot("center", "center");
						addChild(_slowerButton);	
						break;
				}
			}
			
			_pieceImage.texture = null;
			_pieceImage.width = 0;
			_pieceImage.height = 0;			
			_pieceImage.x = _stageWidth * 7.5;
			_pieceImage.y = _stageHeight * 3;	
			_pieceImage.alignPivot("center", "center");
			addChild(_pieceImage);
			
			_nameTextField = new TextField(_stageWidth, _stageHeight, "");
			_nameTextField.format.size = 40;
			_nameTextField.x = _stageWidth * 7.5;
			_nameTextField.y = _stageHeight * 5;
			_nameTextField.alignPivot("center", "center");
			addChild(_nameTextField);
			
			_indexTextField = new TextField(_stageWidth, _stageHeight, "");
			_indexTextField.format.size = 40;
			_indexTextField.x = _stageWidth * 7.5;
			_indexTextField.y = _stageHeight;
			_indexTextField.alignPivot("center", "center");
			addChild(_indexTextField);
		}
		
		private function onAddedEvents(event:starling.events.Event):void
		{
			_playButton.addEventListener(TouchEvent.TOUCH, onClickPlayButton);
			_pauseButton.addEventListener(TouchEvent.TOUCH, onClickPauseButton);
			_deleteButton.addEventListener(TouchEvent.TOUCH, onClickDeleteButton);
			_fasterButton.addEventListener(TouchEvent.TOUCH, onClickFasterButton);
			_slowerButton.addEventListener(TouchEvent.TOUCH, onClickSlowerButton);
		}
		
		/**
		 * 
		 * @param event 마우스 클릭 
		 * 클릭이 발생했을 때 버튼 이미지의 크기를 신축하고, 이미지를 재생하는 메소드
		 */
		private function onClickPlayButton(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_playButton, TouchPhase.BEGAN);
			if(touch)
			{
				_playButton.scale = 0.8;
			}
			
			touch = event.getTouch(_playButton, TouchPhase.ENDED);
			if(touch)
			{
				trace("플레이버튼");
				_playButton.scale = 1;
				dispatchEvent(new Event("Play"));
			}
		}
		
		/**
		 * 
		 * @param event 마우스 클릭
		 * 클릭이 발생했을 때 버튼 이미지의 크기를 신축하고, 이미지의 재생을 멈추는 메소드
		 */
		private function onClickPauseButton(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_pauseButton, TouchPhase.BEGAN);
			if(touch)
			{
				_pauseButton.scale = 0.8;
			}
			
			touch = event.getTouch(_pauseButton, TouchPhase.ENDED);
			if(touch)
			{
				trace("퍼즈버튼");
				_pauseButton.scale = 1;
				dispatchEvent(new Event("Pause"));
			}
		}
		
		/**
		 * 
		 * @param event 마우스 클릭
		 * 클릭이 발생했을 때 버튼 이미지의 크기를 신축하고, 현재 이미지를 배열에서 제거하는 메소드
		 */
		private function onClickDeleteButton(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_deleteButton, TouchPhase.BEGAN);
			if(touch)
			{
				_deleteButton.scale = 0.8;
			}
			
			touch = event.getTouch(_deleteButton, TouchPhase.ENDED);
			if(touch)
			{
				trace("삭제버튼");
				_deleteButton.scale = 1;
				dispatchEvent(new Event("Delete"));
			}
		}
		
		/**
		 * 
		 * @param event 마우스 클릭
		 * 클릭이 발생했을때 애니메이션 재생 속도를 2배 빠르게 해주는 콜백메소드
		 */
		private function onClickFasterButton(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_fasterButton, TouchPhase.BEGAN);
			if(touch)
			{
				_fasterButton.scale = 0.8;
			}
			
			touch = event.getTouch(_fasterButton, TouchPhase.ENDED);
			if(touch)
			{
				_fasterButton.scale = 1;
				
				if(_timer.running)
				{
					_timer.delay /= 2; 
				}				
				_delay /= 2;
			}
		}
		
		/**
		 * 
		 * @param event 마우스 클릭
		 * 클릭이 발생했을때 애니메이션 재생 속도를 2배 느리게 해주는 콜백메소드
		 */
		private function onClickSlowerButton(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(_slowerButton, TouchPhase.BEGAN);
			if(touch)
			{
				_slowerButton.scale = 0.8;
			}
			
			touch = event.getTouch(_slowerButton, TouchPhase.ENDED);
			if(touch)
			{
				_slowerButton.scale = 1;
				if(_timer.running)
				{
					_timer.delay *= 2; 
				}				
				_delay *= 2;
			}
		}
		
	}
}