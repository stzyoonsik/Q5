package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import starling.core.Starling;
	
	[SWF(width="1980", height="1024")]
	public class Q5 extends Sprite
	{
		public function Q5()
		{
			super();
			
			// support autoOrients
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			//stage.
			
			var starling:Starling;
			starling = new Starling(MainStage, stage);	
			starling.showStats = true;
			starling.start();
		}
	}
}