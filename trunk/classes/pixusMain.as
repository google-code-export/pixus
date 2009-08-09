// pixusMain class
// The ruler Sprite inside the pixus NativeWindow
// 2009-08-9
// (cc)2007-2009 codeplay
// By Jam Zhang
// jammind@gmail.com

package {
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.events.Event;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.desktop.NativeApplication;
	import codeplay.event.customEvent;
	import caurina.transitions.Tweener;
	import codeplay.display.slicePlus;

	public class pixusMain extends Sprite {
		
		public static const RESIZE:String='pixusMainEventResize';
		public static const RESIZE_WIDTH:String='pixusMainEventResizeWidth';
		public static const RESIZE_HEIGHT:String='pixusMainEventResizeHeight';
		
		const MIN_WIDTH:uint=20;
		const MIN_HEIGHT:uint=20;
		const RULER_WIDTH:uint=20;
		const RULER_HEIGHT:uint=20;
		const FREE_DRAG_WIDTH:uint=310;
		const FREE_DRAG_HEIGHT:uint=140;
		const FREE_DRAG_OFFSET_X:int=30;
		const FREE_DRAG_OFFSET_Y:int=50;

		var shell:pixusShell;
		private var _rulerWidth:uint;
		private var _rulerHeight:uint;
		private var _pixus:pixus=parent as pixus;
		private var currentSkin:slicePlus=null;
		private var guideDaggers:Array=[];
		private var guidesContainerInner:Sprite=new colorSwitchableSprite([0x00FF00,0x00FFFF]);
		private var guides:Array=[];
		private var w:NativeWindow;
		private var tempPos:Object;
		public var freeDragging:Boolean=false;

		public function pixusMain() {
			// Creating Guide guideDaggers
			guideContainer.addChild(guideDaggers['VL']=new pixusGuideDragger(this,'VL'));
			guideContainer.addChild(guideDaggers['VR']=new pixusGuideDragger(this,'VR'));
			guideContainer.addChild(guideDaggers['HT']=new pixusGuideDragger(this,'HT'));
			guideContainer.addChild(guideDaggers['HB']=new pixusGuideDragger(this,'HB'));
			
			// Creating Guides
			guidesContainerInner.addChild(guides['VL']=new pixusGuide(this,'V'));
			guidesContainerInner.addChild(guides['VR']=new pixusGuide(this,'V'));
			guidesContainerInner.addChild(guides['HT']=new pixusGuide(this,'H'));
			guidesContainerInner.addChild(guides['HB']=new pixusGuide(this,'H'));
			guidesContainerInner.alpha=.75;
			guideContainer.addChild(guidesContainerInner);

			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		public function init(event:Event):void {
			w=stage.nativeWindow;
			panelFreeDrag.visible=false;
			shell=(parent as pixus).shell;
			
			rulers.addEventListener(MouseEvent.MOUSE_DOWN, handleDrag);
			NativeApplication.nativeApplication.addEventListener(pixusShell.EVENT_APPLY_SKIN, handleSkin);
			NativeApplication.nativeApplication.addEventListener(pixusShell.EVENT_START_FREE_DRAG, handleFreeDrag);
			handleSkin();
		}


		// Multi-screen Drag Logic
		// Tested in Windows
		// Large displacement in Mac OS X

		function traceFreeDrag(){
			trace('mouseDown');
			trace('- Window '+w.x+','+w.y);
			trace('- Pixus '+_pixus.x+','+_pixus.y);
			trace('- Pixus Main '+x+','+y);
			trace('- Options '+pixusShell.options.pixusWindow.x+','+pixusShell.options.pixusWindow.y);
		}

		// Mouse-down on Dragger Button
		public function handleFreeDrag(event:Event=null):void {
//			traceFreeDrag();
			// Disable interactions that conflict with normal window mode
			freeDragging=true;
			tempPos={
				x:x+getDraggerX()-FREE_DRAG_OFFSET_X+w.x,
				y:y+getDraggerY()-getDraggerY(0)-FREE_DRAG_OFFSET_Y+w.y
			};
			// Hide standard UI and show panel
			skin.visible=rulers.visible=frame.visible=r.visible=b.visible=br.visible=false;
			panelFreeDrag.visible=true;
			// Add event listeners
			w.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,handleRestored);
			w.restore();
		}

		function handleRestored(e:NativeWindowDisplayStateEvent) {
			trace('handleRestored');
			w.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,handleRestored);
			dragger.x=getDraggerX(0);
			dragger.y=getDraggerY(0);
			_pixus.x=FREE_DRAG_OFFSET_X;
			_pixus.y=FREE_DRAG_OFFSET_Y;
			_pixus.moveTo(0,0);
			w.x=tempPos.x;
			w.y=tempPos.y;
			stage.stageWidth=FREE_DRAG_WIDTH;
			stage.stageHeight=FREE_DRAG_HEIGHT;
			if(pixusShell.isMacOS){
				// 2 steps under Mac OS X to avoid startDrag() malfunctioning
				panelFreeDrag.addEventListener(MouseEvent.MOUSE_DOWN,handleFreeDragMouse);
				dragger.hotspot.addEventListener(MouseEvent.MOUSE_DOWN,handleFreeDragMouse);
			} else
				// Direct drag'n'drop under Windows
				beginFreeDrag();
		}

		// Free Drag Panel Mouse Handler
		function handleFreeDragMouse(e:MouseEvent) {
			switch(e.type){
				case MouseEvent.MOUSE_DOWN:
					beginFreeDrag();
					break;
				case MouseEvent.MOUSE_UP:
					stage.removeEventListener(MouseEvent.MOUSE_UP,handleFreeDragMouse);
					stopFreeDrag();
					break;
			}
		}

		public function beginFreeDrag(){
			panelFreeDrag.removeEventListener(MouseEvent.MOUSE_DOWN,handleFreeDragMouse);
			dragger.hotspot.removeEventListener(MouseEvent.MOUSE_DOWN,handleFreeDragMouse);
			stage.addEventListener(MouseEvent.MOUSE_UP,handleFreeDragMouse);
			w.startMove();
		}

		public function stopFreeDrag(){
			if(!freeDragging)
				return;
			freeDragging=false;
			panelFreeDrag.visible=false;
			dragger.x=getDraggerX();
			dragger.y=getDraggerY();
			_pixus.x=_pixus.y=0;
			tempPos={x:w.x+FREE_DRAG_OFFSET_X-getDraggerX(), y:w.y+FREE_DRAG_OFFSET_Y-getDraggerY()+getDraggerY(0)};
			w.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,handleMaximized);
			w.maximize();
		}

		function handleMaximized(e:NativeWindowDisplayStateEvent) {
			trace('handleMaximized');
			w.removeEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,handleMaximized);
//			_pixus.moveTo(tempPos.x,tempPos.y);
			_pixus.moveTo(tempPos.x-w.x,tempPos.y-w.y);
			if(pixusShell.options.skin==0)
				rulers.visible=true;
			skin.visible=frame.visible=r.visible=b.visible=br.visible=true;
		}

		function getDraggerX(id:int=-1):int{
			return int(shell.getSkin(id).dragger.@x);
		}

		function getDraggerY(id:int=-1):int{
			return int(shell.getSkin(id).dragger.@y);
		}

		public function syncDragger():void {
			Tweener.addTween(dragger,{x:getDraggerX(),y:getDraggerY(),time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
		}

		public function handleSkin(event:Event=null):void {
			stopFreeDrag();
			// Dispose of current skinPlus instance
			if(currentSkin!=null){
				skin.removeEventListener(MouseEvent.MOUSE_DOWN, handleDrag);
				skin.removeChild(currentSkin);
				currentSkin=null;
			}

			// Synchronizing positions
			var pR:XMLList=(shell.getSkin().resizer.(@position=="r"));
			r.offsetx=int(pR.@offsetx);
			r.offsety=int(pR.@offsety);
			var pBR:XMLList=(shell.getSkin().resizer.(@position=="br"));
			br.offsetx=int(pBR.@offsetx);
			br.offsety=int(pBR.@offsety);
			var pB:XMLList=(shell.getSkin().resizer.(@position=="b"));
			b.offsetx=int(pB.@offsetx);
			b.offsety=int(pB.@offsety);

			// Show and hide
			if(pixusShell.options.skin==0){ // Native Ruler
				guideContainer.visible=rulers.visible=true;
				br.hotspot.alpha=1;
				syncDragger();
			} else { // Custom Skin
				br.hotspot.alpha=0;
				guideContainer.visible=rulers.visible=false;
				syncDragger();
				skin.addChild(currentSkin=new slicePlus(shell.getSkin(),pixusShell.options.width,pixusShell.options.height));
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

		// Ruler Size
		
		public function get rulerWidth():int {
			return pixusShell.options.width;
		}

		public function get rulerHeight():int {
			return pixusShell.options.height;
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
			//guides.draggerVT.x=guides.draggerVB.x=
			frame.width=_rulerWidth=r.x=br.x=w;
			setVerticalGuides(); // Sync with the new width by default
			b.x=int(w*0.5);
			rulers.rulerHorizontal.setLength(w);
			showSize(_rulerWidth,_rulerHeight);
			if (currentSkin==null) {
				dispatchEvent(new Event(RESIZE_WIDTH));
			} else {
				currentSkin.setWidth(w);
			}
		}

		public function set rulerHeight(h:int):void {
			h=Math.max(h,minHeight);
			pixusShell.options.height=h;
			rulers.bg.height=h+RULER_HEIGHT*2;
			guideDaggers['VL'].y=guideDaggers['VR'].y=frame.height=_rulerHeight=b.y=br.y=h;
			setHorizontalGuides(); // Sync with the new height by default
			r.y=int(h*0.5);
			rulers.rulerVertical.setLength(h);
			showSize(_rulerWidth,_rulerHeight);
			if (currentSkin==null) {
				dispatchEvent(new Event(RESIZE_HEIGHT));
			} else {
				currentSkin.setHeight(h);
			}
		}

		public function setVerticalGuides(x:int=-1){
			// Sync with the new width by default
			if(x==-1){
				x=guideDaggers['VL'].x;
			}
			x=Math.max(0,Math.min(_pixus.rulerWidth*.5,x));
			guides['VL'].x=guideDaggers['VL'].x=x;
			guides['VR'].x=guideDaggers['VR'].x=_pixus.rulerWidth-x;
		}
		
		public function setHorizontalGuides(y:int=-1){
			// Sync with the new height by default
			if(y==-1){
				y=guideDaggers['HT'].y;
			}
			y=Math.max(0,Math.min(_pixus.rulerHeight*.5,y));
			guides['HT'].y=guideDaggers['HT'].y=y;
			guides['HB'].y=guideDaggers['HB'].y=_pixus.rulerHeight-y;
		}
		
		public function showSize(w:uint,h:uint):void {
			var t=w+'x'+h;
			dragger.tfSize.text=t;
			if (stage!=null) {
				stage.nativeWindow.title = "Pixus "+t;
			}
		}
	}
}