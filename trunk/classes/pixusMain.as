// pixusMain class
// Version 0.9.0 2008-07-04
// (cc)2007-2008 codeplay
// By Jam Zhang
// jam@01media.cn

package {
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.desktop.NativeApplication;
	import caurina.transitions.Tweener;
	import codeplay.display.slicePlus;

	public class pixusMain extends MovieClip {
		const MIN_WIDTH:uint=20;
		const MIN_HEIGHT:uint=20;
		const RULER_WIDTH:uint=20;
		const RULER_HEIGHT:uint=20;

		var shell:pixusShell;
		private var _rulerWidth:uint;
		private var _rulerHeight:uint;
		private var overlay:NativeWindow=null;
		private var _root:pixus=parent as pixus;
		private var currentSkin:slicePlus=null;

		public function pixusMain() {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		public function init(event:Event):void {
			shell=(parent as pixus).shell;
			NativeApplication.nativeApplication.addEventListener(pixusShell.EVENT_APPLY_SKIN, handleSkin);
			handleSkin();
		}

		public function handleSkin(event:Event=null):void {
			if(currentSkin!=null){
				skin.removeEventListener(MouseEvent.MOUSE_DOWN, handleDrag);
				skin.removeChild(currentSkin);
				currentSkin=null;
			}
			if(shell.currentSkin==null){
				rulers.visible=true;
				r.offsetx=r.offsety=br.offsetx=br.offsety=b.offsetx=b.offsety=0;

				Tweener.addTween(dragger,{x:0,y:-5,time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
			} else {
				var pTR:XMLList=(shell.currentSkin.resizer.(@position=="tr"));
				r.offsetx=int(pTR.@offsetx);
				r.offsety=int(pTR.@offsety);
				var pBR:XMLList=(shell.currentSkin.resizer.(@position=="br"));
				br.offsetx=int(pBR.@offsetx);
				br.offsety=int(pBR.@offsety);
				var pBL:XMLList=(shell.currentSkin.resizer.(@position=="bl"));
				b.offsetx=int(pBL.@offsetx);
				b.offsety=int(pBL.@offsety);

				rulers.visible=false;
				Tweener.addTween(dragger,{x:int(shell.currentSkin.dragger.@x),y:int(shell.currentSkin.dragger.@y),time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
				skin.addChild(currentSkin=new slicePlus(shell.currentSkin,pixusShell.options.width,pixusShell.options.height));
				skin.addEventListener(MouseEvent.MOUSE_DOWN, handleDrag);
			}
		}

		public function handleDrag(event:MouseEvent):void {
			switch (event.type) {
				case MouseEvent.MOUSE_DOWN :
					(parent as pixus).startMove();
					break;
			}
		}

		public function get rulerWidth():int {
			return pixusShell.options.width;
		}

		public function get minWidth():int{
			if(currentSkin==null)
				return MIN_WIDTH;
			else
				return Math.max(MIN_WIDTH,currentSkin.minWidth);
		}

		public function get minHeight():int{
			if(currentSkin==null)
				return MIN_HEIGHT;
			else
				return Math.max(MIN_HEIGHT,currentSkin.minHeight);
		}

		public function set rulerWidth(w:int):void {
			w=Math.max(w,minWidth);
			pixusShell.options.width=w;
			rulers.bg.width=w+RULER_WIDTH*2;
			frame.width=_rulerWidth=r.x=br.x=w;
			rulers.rulerHorizontal.setLength(w);
			showSize(_rulerWidth,_rulerHeight);
			if (currentSkin!=null) {
				currentSkin.setWidth(w);
			}
		}

		public function get rulerHeight():int {
			return pixusShell.options.height;
		}

		public function set rulerHeight(h:int):void {
			h=Math.max(h,minHeight);
			pixusShell.options.height=h;
			rulers.bg.height=h+RULER_HEIGHT*2;
			frame.height=
			_rulerHeight=b.y=br.y=h;
			rulers.rulerVertical.setLength(h);
			showSize(_rulerWidth,_rulerHeight);
			if (currentSkin!=null) {
				currentSkin.setHeight(h);
			}
		}

		public function showSize(w:uint,h:uint):void {
			var t=w+'x'+h;
			dragger.text.tfSize.text=t;
			if (stage!=null) {
				stage.nativeWindow.title = "Pixus "+t;
			}
		}
	}
}