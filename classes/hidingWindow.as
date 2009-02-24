// hidingWindow class
// An NativeWindow that hide itself instead of closing the window
// Version 0.1.0 2009-2-24
// (cc)2009 codeplay
// By Jam Zhang
// jam@01media.cn

package {
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.events.Event;

	public class hidingWindow extends NativeWindow {

		function hidingWindow(initOptions:NativeWindowInitOptions):void {
			super(initOptions);
			addEventListener(Event.CLOSING, handleWindowClose);
		}

		function handleWindowClose(event:Event):void {
			event.preventDefault();
			visible=false;
		}

	}
}