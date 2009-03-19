// pixus class
// The First Child MovieClip of pixus NativeWindow
// 2009-3-3
// (cc)2007-2009 codeplay
// By Jam Zhang
// jam@01media.cn
//
// General Interface
// Methods below have the complete logic are recommend to invoke for general purposes
//   moveTo() - Absolute Move
//   moveRel() - Relative Movement
//   resizeTo() - Absolute Resizing
//   resizeRel() - Relative Resizing

package {
	import flash.display.NativeWindow;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.NativeWindowDisplayState;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.MovieClip;
	import flash.display.Sprite;
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
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.geom.Point;
	import flash.net.SharedObject;
	import caurina.transitions.Tweener;
	import codeplay.event.customEvent;

	public class pixus extends Sprite {
		const MARGIN_LEFT:uint=25;
		const MARGIN_TOP:uint=150;
		const MARGIN_RIGHT:uint=60;
		const MARGIN_BOTTOM:uint=200;

		public var shell:pixusShell;
		private var w:NativeWindow;

		function pixus(pshell:pixusShell):void {
			shell=pshell;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		public function init(event:Event):void {

			w=stage.nativeWindow;
			stage.scaleMode=StageScaleMode.NO_SCALE;
			stage.align=StageAlign.TOP_LEFT;
			stage.nativeWindow.minSize=new Point(210,50);

			// Default settings
			if (pixusShell.options.pixusWindow==undefined) {
				pixusShell.options.pixusWindow={x:500,y:100,width:640,height:480,visible:true};
			}
			if (pixusShell.options.pixusWindow.width==undefined) {
				pixusShell.options.pixusWindow.width=480;
			}
			if (pixusShell.options.pixusWindow.height==undefined) {
				pixusShell.options.pixusWindow.height=360;
			}

			if (pixusShell.options.pixusWindow.x==undefined) {
				pixusShell.options.pixusWindow.x=120;
			}
			if (pixusShell.options.pixusWindow.y==undefined) {
				pixusShell.options.pixusWindow.y=80;
			}

			if (pixusShell.options.pixusWindow.visible==undefined) {
				pixusShell.options.pixusWindow.visible=true;
			}

			stage.nativeWindow.visible=pixusShell.options.pixusWindow.visible;
			resizeTo(pixusShell.options.pixusWindow.width,pixusShell.options.pixusWindow.height);
			moveTo(pixusShell.options.pixusWindow.x,pixusShell.options.pixusWindow.y);

			if (pixusShell.options.pixusWindow.overlayMode==undefined) {
				pixusShell.options.pixusWindow.overlayMode=false;
			}
			if (pixusShell.options.pixusWindow.overlayMode) {
				pixusShell.options.pixusWindow.overlayMode=false;
				toggleOverlay();
			}

			// Handles Menu And Closes The Primary Window
			NativeApplication.nativeApplication.addEventListener(customEvent.SET_WINDOW_SIZE,handleWindowSize);
			NativeApplication.nativeApplication.addEventListener(pixusShell.EVENT_FIND_BACK,handleFindBack);
			shell.stage.nativeWindow.close();
			stage.nativeWindow.maximize();
			stage.addEventListener(KeyboardEvent.KEY_DOWN,handleKeys);

		}

		function get rulerWidth():int{
			return pixusShell.options.pixusWindow.width;
		}

		function get rulerHeight():int{
			return pixusShell.options.pixusWindow.height;
		}

		function set rulerWidth(w:int){
			main.rulerWidth=pixusShell.options.pixusWindow.width=w;
		}

		function set rulerHeight(h:int){
			main.rulerHeight=pixusShell.options.pixusWindow.height=h;
		}

		function startMove():void {
//			if(!shell.freeDragging){
				stage.addEventListener(MouseEvent.MOUSE_MOVE,handleMouse);
				stage.addEventListener(MouseEvent.MOUSE_UP,handleMouse);
				main.startDrag();
//			}
		}

		//
		function handleKeys(event:KeyboardEvent) {
			var inc:int=event.shiftKey?10:1; // Shift = Speed Up
			if(shell.freeDragging){
				switch(event.keyCode){
					case Keyboard.LEFT:
						w.x-=inc;
						break;
					case Keyboard.RIGHT:
						w.x+=inc;
						break;
					case Keyboard.UP:
						w.y-=inc;
						break;
					case Keyboard.DOWN:
						w.y+=inc;
						break;
				}
			} else {
			if(event.controlKey || event.commandKey){ // Control / Command + Directions = Resize
				switch(event.keyCode){
					case Keyboard.LEFT:
						resizeRel(-inc,0);
						break;
					case Keyboard.RIGHT:
						resizeRel(inc,0);
						break;
					case Keyboard.UP:
						resizeRel(0,-inc);
						break;
					case Keyboard.DOWN:
						resizeRel(0,inc);
						break;
				}
			}else{ // Directions = Move
				switch(event.keyCode){
					case Keyboard.LEFT:
						moveRel(-inc,0);
						break;
					case Keyboard.RIGHT:
						moveRel(inc,0);
						break;
					case Keyboard.UP:
						moveRel(0,-inc);
						break;
					case Keyboard.DOWN:
						moveRel(0,inc);
						break;
				}
			}
			}
		}

		function moveRel(dx:int,dy:int,save:Boolean=true){
			main.x+=dx;
			main.y+=dy;
			overlay.themask.inner.x+=dx;
			overlay.themask.inner.y+=dy;
			if(save){
				pixusShell.options.pixusWindow.x=main.x;
				pixusShell.options.pixusWindow.y=main.y;
			}
		}

		function moveTo(x:int,y:int,save:Boolean=true){
			main.x=overlay.themask.inner.x=x;
			main.y=overlay.themask.inner.y=y;
			if(save){
				pixusShell.options.pixusWindow.x=x;
				pixusShell.options.pixusWindow.y=y;
			}
		}

		function resizeRel(dw:int,dh:int){
			overlay.overlayWidth=rulerWidth=rulerWidth+dw;
			overlay.overlayHeight=rulerHeight=rulerHeight+dh;
		}

		// resize will ignore the negative parameters incase you want to resize a specific dimension
		function resizeTo(w:int,h:int){
			if(w>0){
				overlay.overlayWidth=rulerWidth=w;
			}
			if(h>0){
				overlay.overlayHeight=rulerHeight=h;
			}
		}

		function handleWindowSize(event:customEvent) {
			shell.stopFreeDrag();
			resizeTo(event.data.width,event.data.height);
		}

		// pixus handle finding back of the pixus window
		function handleFindBack(event:customEvent) {
			shell.stopFreeDrag();
			var w1:int=main.rulerWidth;
			var h1:int=main.rulerHeight;
			if(main.rulerWidth>stage.nativeWindow.width*.8)
				w1=stage.nativeWindow.width*.5;
			if(main.rulerHeight>stage.nativeWindow.height*.8)
				h1=stage.nativeWindow.height*.5;
			if(w1!=main.rulerWidth||h1!=main.rulerHeight)
				resizeTo(w1,h1);

			pixusShell.options.pixusWindow.x=pixusShell.PIXUS_PANEL_X;
			pixusShell.options.pixusWindow.y=pixusShell.PIXUS_PANEL_Y;
			Tweener.addTween(main,{x:pixusShell.PIXUS_PANEL_X,time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
			Tweener.addTween(main,{y:pixusShell.PIXUS_PANEL_Y,time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
			Tweener.addTween(overlay.themask.inner,{x:pixusShell.PIXUS_PANEL_X,time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
			Tweener.addTween(overlay.themask.inner,{y:pixusShell.PIXUS_PANEL_Y,time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
		}

		function handleMouse(event:MouseEvent) {
			switch (event.type) {
				case MouseEvent.MOUSE_MOVE :
					overlay.move(main.x,main.y);
					break;
				case MouseEvent.MOUSE_UP :
					stage.removeEventListener(MouseEvent.MOUSE_MOVE,handleMouse);
					stage.removeEventListener(MouseEvent.MOUSE_UP,handleMouse);
					main.stopDrag();
					if (stage==null) {
						break;
					}
					pixusShell.options.pixusWindow.x=main.x+stage.nativeWindow.x;// Because nativeWindow.x==-2 when maximized
					pixusShell.options.pixusWindow.y=main.y+stage.nativeWindow.y;// Because nativeWindow.y==-4 when maximized
					break;
			}
		}

		function toggleOverlay():void {
			shell.stopFreeDrag();
			if (pixusShell.options.pixusWindow.overlayMode) {
				pixusShell.options.pixusWindow.overlayMode=overlay.visible=false;
			} else {
				pixusShell.options.pixusWindow.overlayMode=overlay.visible=true;
			}
		}

	}
}