// rulerButtons class
// 2009-03-18
// (cc)2007-2009 codeplay
// By Jam Zhang
// jammind@gmail.com

package {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.display.NativeWindow;
	import flash.events.MouseEvent;
	import flash.desktop.NativeApplication;
	import codeplay.event.customEvent;

	public class rulerButtons extends Sprite {
		public function rulerButtons():void {
			buttonMove.addEventListener(MouseEvent.MOUSE_DOWN, handleButtons);
			buttonOverlay.addEventListener(MouseEvent.CLICK, handleButtons);
//			buttonPreferences.addEventListener(MouseEvent.CLICK, handleButtons);
			buttonClose.addEventListener(MouseEvent.CLICK, handleButtons);
		}

		public function handleButtons(event:MouseEvent):void {
			switch(event.target){
				case buttonMove:
					NativeApplication.nativeApplication.dispatchEvent(new customEvent(pixusShell.EVENT_START_FREE_DRAG));
					break;
				case buttonOverlay:
					(parent.parent.parent as pixus).toggleOverlay();
					break;
//				case buttonPreferences:
//					NativeApplication.nativeApplication.dispatchEvent(new customEvent(pixusShell.SHOW_PREFERENCES));
//					break;
				case buttonClose:
					NativeApplication.nativeApplication.dispatchEvent(new customEvent(pixusShell.HIDE_PIXUS));
					break;
			}
		}

	}
}
