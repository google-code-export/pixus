// rulerButtons class
// (cc)2007 01media reactor
// By Jam Zhang
// jam@01media.cn

package {
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.NativeWindow;
	import flash.events.MouseEvent;
	import flash.desktop.NativeApplication;
	import codeplay.event.customEvent;

	public class rulerButtons extends MovieClip {
		public function rulerButtons():void {
			buttonOverlay.addEventListener(MouseEvent.CLICK, handleButtons);
			buttonPreferences.addEventListener(MouseEvent.CLICK, handleButtons);
			buttonClose.addEventListener(MouseEvent.CLICK, handleButtons);
		}

		public function handleButtons(event:MouseEvent):void {
			switch(event.target){
				case buttonOverlay:
					(parent.parent.parent as pixus).toggleOverlay();
					break;
				case buttonPreferences:
					NativeApplication.nativeApplication.dispatchEvent(new customEvent(customEvent.OPEN_PREFERENCES));
					break;
				case buttonClose:
					stage.nativeWindow.visible=!stage.nativeWindow.visible;
					break;
			}
		}

	}
}
