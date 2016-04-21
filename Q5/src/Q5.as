package
{
	//import com.lpesign.ToastExtension;
	
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	
	import starling.core.Starling;
	import mode.MainStage;
	
	//[SWF(width="1280", height="800")]
	public class Q5 extends Sprite
	{
		
		public function Q5()
		{
			super();
			
			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			//stage.displayState = StageDisplayState.FULL_SCREEN;
			//stage.stageWidth = Screen.mainScreen.bounds.width;
			//stage.stageHeight = Screen.mainScreen.bounds.height;
			
			trace(Screen.mainScreen.bounds);
			//trace(stage.fullScreenWidth + " " + stage.fullScreenHeight);
			
			var starling:Starling;
			starling = new Starling(MainStage, stage);
			starling.showStats = true;
			starling.start();
			
			//var actualScreen:Screen = getCurrentScreen();
			//trace ("actualScreen = " + actualScreen.bounds.width +' '+actualScreen.bounds.height);
		
		}
		
//		private function getCurrentScreen():Screen
//		{
//			var current:Screen;
//			var screenArray:Array = Screen.screens;
//			var screens:Array = Screen.getScreensForRectangle(stage.nativeWindow.bounds);
//			(screens.length > 0) ? current = screens[0] : current = Screen.mainScreen;
//			return current;
//		}
	}
}