// pixus class
// Version 0.9.0 2008-07-14
// (cc)2007-2008 codeplay
// By Jam Zhang
// jam@01media.cn

package {
	import flash.display.NativeWindow;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindowDisplayState;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import flash.desktop.DockIcon;
	import flash.desktop.SystemTrayIcon;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.events.ScreenMouseEvent;
	import flash.geom.Point;
	import flash.net.SharedObject;
	import codeplay.event.customEvent;

	public class pixus extends MovieClip {
		const MARGIN_LEFT:uint=25;
		const MARGIN_TOP:uint=150;
		const MARGIN_RIGHT:uint=60;
		const MARGIN_BOTTOM:uint=200;

		public var shell:pixusShell;
//		var options:Object=SharedObject.getLocal('preferences',pixusShell.APP_PATH).data;

		function pixus(pshell:pixusShell):void {
			shell=pshell;
			addEventListener(Event.ADDED_TO_STAGE, handleInit);
		}

		public function handleInit(event:Event):void {

			stage.scaleMode=StageScaleMode.NO_SCALE;
			stage.align=StageAlign.TOP_LEFT;
			stage.nativeWindow.minSize=new Point(210,50);

			// Default settings
			if (pixusShell.options.width==undefined) {
				pixusShell.options.width=480;
			}
			main.rulerWidth=pixusShell.options.width;
			if (pixusShell.options.height==undefined) {
				pixusShell.options.height=360;
			}
			main.rulerHeight=pixusShell.options.height;
			if (pixusShell.options.x==undefined) {
				pixusShell.options.x=120;
			}
			stage.nativeWindow.x=pixusShell.options.x;
			if (pixusShell.options.y==undefined) {
				pixusShell.options.y=80;
			}
			stage.nativeWindow.y=pixusShell.options.y;
			if (pixusShell.options.overlayMode==undefined) {
				pixusShell.options.overlayMode=false;
			}
			if (pixusShell.options.overlayMode) {
				pixusShell.options.overlayMode=false;
				toggleOverlay();
			} else {
				initNormalWindow();
			}

			// Handles Menu And Closes The Primary Window
			NativeApplication.nativeApplication.addEventListener(customEvent.SET_WINDOW_SIZE,handleWindowSize);
			shell.stage.nativeWindow.close();

		}

		function set rulerWidth(w:int){
			main.rulerWidth=pixusShell.options.width=w;
		}

		function set rulerHeight(h:int){
			main.rulerHeight=pixusShell.options.height=h;
		}

		function startMove():void {
			if (pixusShell.options.overlayMode) {
				stage.addEventListener(MouseEvent.MOUSE_MOVE,handleMouse);
				stage.addEventListener(MouseEvent.MOUSE_UP,handleMouse);
				main.startDrag();
			} else {
				stage.addEventListener(MouseEvent.MOUSE_UP,handleMouse);
				stage.nativeWindow.startMove();
			}
		}

		function handleWindowSize(event:customEvent) {
			rulerWidth=event.data.width;
			rulerHeight=event.data.height;
		}

		function handleMouse(event:MouseEvent) {
			switch (event.type) {
				case MouseEvent.MOUSE_MOVE :
					if (pixusShell.options.overlayMode) {
						overlay.move(main.x,main.y);
					}
					break;
				case MouseEvent.MOUSE_UP :
					if (pixusShell.options.overlayMode) {
						stage.removeEventListener(MouseEvent.MOUSE_MOVE,handleMouse);
						stage.removeEventListener(MouseEvent.MOUSE_UP,handleMouse);
						main.stopDrag();
						if (stage==null) {
							break;
						}
						pixusShell.options.x=main.x+stage.nativeWindow.x;// Because nativeWindow.x==-2 when maximized
						pixusShell.options.y=main.y+stage.nativeWindow.y;// Because nativeWindow.x==-4 when maximized
					} else {
						stage.removeEventListener(MouseEvent.MOUSE_UP,handleMouse);
						pixusShell.options.x=stage.nativeWindow.x+MARGIN_LEFT;
						pixusShell.options.y=stage.nativeWindow.y+MARGIN_TOP;
					}
					break;
			}
		}

		function toggleOverlay():void {
			if (pixusShell.options.overlayMode) {
				// restore() executes asynchronously.
				// To detect the completion of the state change, listen for the "displayStateChange" event.
				pixusShell.options.overlayMode=false;
				stage.displayState = StageDisplayState.NORMAL;
						initNormalWindow();
						overlay.visible=false;
//				stage.nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,handleWindowStateChange);
//				stage.nativeWindow.restore();
			} else {
				// maximize() executes asynchronously.
				// To detect the completion of the state change, listen for the "displayStateChange" event.
				pixusShell.options.overlayMode=true;
				stage.displayState = StageDisplayState.FULL_SCREEN;
						main.x=pixusShell.options.x-stage.nativeWindow.x;// Strangely x==-2 when maximized instead of 0
						main.y=pixusShell.options.y-stage.nativeWindow.y;// Strangely x==-4 when maximized instead of 0
						overlay.move(main.x,main.y);
						overlay.visible=true;
//				stage.nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,handleWindowStateChange);
//				stage.nativeWindow.maximize();
			}
		}

		function syncWindowWidth(w:int):void {
			overlay.overlayWidth=w;
			if (!pixusShell.options.overlayMode) {
				stage.nativeWindow.width=w+MARGIN_RIGHT;
			}
		}

		function syncWindowHeight(h:int):void {
			overlay.overlayHeight=h;
			if (!pixusShell.options.overlayMode) {
				stage.nativeWindow.height=h+MARGIN_BOTTOM;
			}
		}

		function handleWindowStateChange(event:NativeWindowDisplayStateEvent):void {
			if (event.type==NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE) {
				switch (event.afterDisplayState) {
					case NativeWindowDisplayState.MAXIMIZED :
						main.x=pixusShell.options.x-stage.nativeWindow.x;// Strangely x==-2 when maximized instead of 0
						main.y=pixusShell.options.y-stage.nativeWindow.y;// Strangely x==-4 when maximized instead of 0
						overlay.move(main.x,main.y);
						overlay.visible=true;
						break;
					case NativeWindowDisplayState.NORMAL :
						stage.nativeWindow.removeEventListener(NativeWindowDisplayState.NORMAL,handleWindowStateChange);
						initNormalWindow();
						overlay.visible=false;
						break;
				}
			}
		}

		function initNormalWindow():void {
			main.x=MARGIN_LEFT;
			main.y=MARGIN_TOP;
			stage.nativeWindow.x=pixusShell.options.x-MARGIN_LEFT;
			stage.nativeWindow.y=pixusShell.options.y-MARGIN_TOP;
			syncWindowWidth(overlay.themask.inner.width);
			syncWindowHeight(overlay.themask.inner.height);
		}

	}
}