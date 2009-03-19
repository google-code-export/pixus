// pixusRulerDragger class
// (cc)2007 01media reactor
// By Jam Zhang
// jam@01media.cn

package {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class pixusRulerDragger extends Sprite {
		var shell:pixusShell;

		public function pixusRulerDragger():void {
			tfSize.autoSize=TextFieldAutoSize.LEFT;
			hotspot.useHandCursor=false;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		function init(e:Event){
			shell=(parent as pixusMain).shell;
			hotspot.addEventListener(MouseEvent.MOUSE_DOWN, handleDrag);
		}

		public function handleDrag(event:MouseEvent):void {
			if(shell.freeDragging)
				return;
			switch(event.type){
				case MouseEvent.MOUSE_DOWN:
					(parent.parent as pixus).startMove();
					break;
			}
		}
	}
}
