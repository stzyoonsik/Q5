package com.yoonsik
{
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	
	public class YoonsikExtension
	{
		private var _context:ExtensionContext;
		private var _imageSelected:Function;
		
		public function YoonsikExtension()
		{
			try
			{
				if(!_context)
					_context = ExtensionContext.createExtensionContext("com.yoonsik.YoonsikExtension",null);
				if(_context)
					_context.addEventListener(StatusEvent.STATUS, onStatusHandle);
				
			} 
			catch(e:Error) 
			{
				trace(e.message);
			}
		}
		
		public function onStatusHandle(event:StatusEvent):void
		{
			trace(event);
			// process event data
			trace(event.code);
			trace(event.level);
			_imageSelected(event.level as String);
		}
		
		public function toast(message:String):void
		{
			_context.call("toast",message);
		}
		public function alert(message:String):void
		{
			_context.call("alert", message);
		}
		public function selectImage(imageArray:Array, resultFunc:Function):void
		{
			_imageSelected = resultFunc;
			_context.call("selectImage", imageArray);
		}
		
		
	}
}