package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import starling.core.Starling;
	
	import mode.MainStage;
	
	public class Q5 extends Sprite
	{		
		public function Q5()
		{
			super();
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var starling:Starling;
			starling = new Starling(MainStage, stage);
			starling.showStats = true;
			starling.start();
		}
	}
}