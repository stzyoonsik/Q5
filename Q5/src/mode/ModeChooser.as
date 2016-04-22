package mode
{
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;

	public class ModeChooser extends Sprite
	{
		private var _animationModeOnButton:Image;
		private var _animationModeOffButton:Image;
		private var _imageModeOnButton:Image;
		private var _imageModeOffButton:Image;
		
		private var _animationModeText:TextField;
		private var _imageModeText:TextField;
		
		private var _stageWidth:int;
		private var _stageHeight:int;
		
		public function ModeChooser(stageWidth:int, stageHeight:int)
		{
			_stageWidth = stageWidth / 10;
			_stageHeight = stageHeight / 10;
			addEventListener(TouchEvent.TOUCH, onAddedEvents);	
		}
		
		/**
		 * 모든 터치 이벤트를 관장하는 이벤트 리스너 
		 * @param event
		 * 
		 */
		private function onAddedEvents(event:starling.events.Event):void
		{
			_animationModeOnButton.addEventListener(TouchEvent.TOUCH, onTouchRadioAnimationModeOn);
			_animationModeOffButton.addEventListener(TouchEvent.TOUCH, onTouchRadioAnimationModeOff);
			
			_imageModeOnButton.addEventListener(TouchEvent.TOUCH, onTouchRadioImageModeOn);
			_imageModeOffButton.addEventListener(TouchEvent.TOUCH, onTouchRadioImageModeOff);
		}
		
		public function init(guiArray:Vector.<Image>):void
		{
			for(var i:int = 0; i<guiArray.length; ++i)
			{
				switch(guiArray[i].name)
				{
					case "radioButtonOff":
						_animationModeOffButton = new Image(guiArray[i].texture);
						_animationModeOffButton.x = _stageWidth * 4.5;
						_animationModeOffButton.y = _stageHeight * 6;						
						_animationModeOffButton.width = _stageWidth / 2;
						_animationModeOffButton.height = _animationModeOffButton.width;
						_animationModeOffButton.alignPivot("center", "center");
						_animationModeOffButton.visible = false;
						addChild(_animationModeOffButton);
						
						_imageModeOffButton = new Image(guiArray[i].texture);
						_imageModeOffButton.x = _stageWidth * 4.5;
						_imageModeOffButton.y = _stageHeight * 8;
						_imageModeOffButton.width = _stageWidth / 2;
						_imageModeOffButton.height = _imageModeOffButton.width;
						_imageModeOffButton.alignPivot("center", "center");
						_imageModeOffButton.visible = true;
						addChild(_imageModeOffButton);						
						break;
					case "radioButtonOn":
						_animationModeOnButton = new Image(guiArray[i].texture);
						_animationModeOnButton.x = _stageWidth * 4.5;
						_animationModeOnButton.y = _stageHeight * 6;
						_animationModeOnButton.width = _stageWidth / 2;
						_animationModeOnButton.height = _animationModeOnButton.width;
						_animationModeOnButton.alignPivot("center", "center");
						_animationModeOnButton.visible = true;
						addChild(_animationModeOnButton);
						
						_imageModeOnButton = new Image(guiArray[i].texture);
						_imageModeOnButton.x = _stageWidth * 4.5;
						_imageModeOnButton.y = _stageHeight * 8;
						_imageModeOnButton.width = _stageWidth / 2;
						_imageModeOnButton.height = _imageModeOnButton.width;
						_imageModeOnButton.alignPivot("center", "center");
						_imageModeOnButton.visible = false;
						addChild(_imageModeOnButton);
						break;
					
				}
			}
			
			_animationModeText = new TextField(_stageWidth, _stageHeight, "Animation Mode");
			_animationModeText.format.size = 40;			
			_animationModeText.x = _stageWidth * 4.5;
			_animationModeText.y = _stageHeight * 6.75;			
			_animationModeText.alignPivot("center", "center");
			addChild(_animationModeText);
			
			_imageModeText = new TextField(_stageWidth, _stageHeight, "Image Mode");
			_imageModeText.format.size = 40;
			_imageModeText.x = _stageWidth * 4.5;
			_imageModeText.y = _stageHeight * 8.75;
			_imageModeText.alignPivot("center", "center");
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
				_animationModeOnButton.visible = true;
				_animationModeOffButton.visible = false;
				
				_imageModeOnButton.visible = false;
				_imageModeOffButton.visible = true;
				
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
				
				dispatchEvent(new Event("animationModeOn"));
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
				
				dispatchEvent(new Event("imageModeOn"));
			}
		}
	}
}