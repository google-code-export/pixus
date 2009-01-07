// preferences class
// Version 0.8.0 2008-07-09
// (cc)2007-2008 codeplay
// By Jam Zhang
// jam@01media.cn

package {
	import flash.display.NativeWindow;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import codeplay.ui.aqua.scrollPanel;
	import codeplay.event.customEvent;
	import caurina.transitions.Tweener;

	public class preferences extends Sprite {

		const MARGIN_TOP:int=80;
		const MARGIN_BOTTOM:int=40;
		const MIN_HEIGHT:int=240;//320;
		const MAX_HEIGHT:int=600;

		public var shell:pixusShell;
		var presets:scrollPanel;
		var skins:scrollPanel;
		var currentPanel:int=0;
		//var panelArray:Array=new Array();
		var panelsX0:int;

		function preferences(pshell:pixusShell):void {
			shell=pshell;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		public function init(event:Event):void {
			var l,n:int;

			maskPanel.width=resizer.x=bg.width=pixusShell.PREFERENCES_PANEL_WIDTH+1;
			if(pixusShell.options.preferencesWindowPosition.height!=undefined)
				resizer.y=bg.height=pixusShell.options.preferencesWindowPosition.height;
			stage.addEventListener(pixusShell.EVENT_SYNC_WINDOW_SIZE,handleSyncWindowSize);
			bClose.addEventListener(MouseEvent.CLICK, handleClose);
			bg.addEventListener(MouseEvent.MOUSE_DOWN,handleMove);
			bTabPresets.addEventListener(MouseEvent.CLICK, handleTab);
			bTabSkins.addEventListener(MouseEvent.CLICK, handleTab);
			bTabHelp.addEventListener(MouseEvent.CLICK, handleTab);
			bTabAbout.addEventListener(MouseEvent.CLICK, handleTab);
			resizer.addEventListener(MouseEvent.MOUSE_DOWN, handleResize);
			NativeApplication.nativeApplication.addEventListener(pixusShell.EVENT_RESET_PRESETS,doResetPresets);
			iconPresets.activate();

			//panelArray=[panels.panelPresets,panels.panelSkins];
			panelsX0=panels.x;

			// Presets Panel
			panels.panelPresets.bottomControl.bAdd.addEventListener(MouseEvent.CLICK, handleAdd);
			rebuildPresets();

			// Skins Panel
			skins=new scrollPanel({width:pixusShell.PREFERENCES_PANEL_WIDTH,viewHeight:pixusShell.options.preferencesWindowPosition.height,delta:pixusShell.SKIN_ROW_HEIGHT,snapping:true});
			panels.panelSkins.addChild(skins);
			l=pixusShell.skinpresets.skin.length()+1;
			for (n=0; n<l; n++) {
				skins.addChild(new skinRow());
			}

			// Help Panel
			panels.panelHelp.inner.bFindBack.addEventListener(MouseEvent.CLICK, handleFindBack);
			panels.panelHelp.inner.bResetPresets.addEventListener(MouseEvent.CLICK, handleResetPresets);

			syncWindowSize();
		}

		function handleFindBack(event:MouseEvent):void {
			NativeApplication.nativeApplication.dispatchEvent(new Event(pixusShell.EVENT_FIND_BACK));
		}

		function handleResetPresets(event:MouseEvent):void {
			NativeApplication.nativeApplication.dispatchEvent(new Event(pixusShell.EVENT_RESET_PRESETS));
		}

		function doResetPresets(event:Event):void {
			pixusShell.options.presets=pixusShell.PRESETS;
			rebuildPresets();
			syncWindowSize();
		}

		function rebuildPresets():void {
			var l,n:int;
			if(presets!=null){
				panels.panelPresets.removeChild(presets);
				menuRow.clearRows();
			}
			presets=new scrollPanel({width:pixusShell.PREFERENCES_PANEL_WIDTH,viewHeight:pixusShell.options.preferencesWindowPosition.height,delta:pixusShell.PRESET_ROW_HEIGHT,snapping:true});
			panels.panelPresets.addChild(presets);
			l=pixusShell.options.presets.length;
			for (n=0; n<l; n++) {
				presets.addChild(new presetRow());
			}
		}

		public function handleResize(event:MouseEvent):void {
			switch (event.type) {
				case MouseEvent.MOUSE_DOWN :
					resizer.startDrag(false,new Rectangle(resizer.x,MIN_HEIGHT,0,MAX_HEIGHT));
					stage.addEventListener(MouseEvent.MOUSE_MOVE, handleResize);
					stage.addEventListener(MouseEvent.MOUSE_UP, handleResize);
					break;
				case MouseEvent.MOUSE_UP :
					resizer.stopDrag();
					syncWindowSize();
					pixusShell.options.preferencesWindowPosition.height=bg.height=resizer.y;
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleResize);
					stage.removeEventListener(MouseEvent.MOUSE_UP, handleResize);
					break;
				case MouseEvent.MOUSE_MOVE :
					bg.height=resizer.y;
					syncWindowSize();
					break;
			}
		}

		public function handleMove(event:MouseEvent):void {
			switch (event.type) {
				case MouseEvent.MOUSE_DOWN :
					stage.nativeWindow.startMove();
					stage.addEventListener(MouseEvent.MOUSE_UP,handleMove);
					break;
				case MouseEvent.MOUSE_UP :
					stage.removeEventListener(MouseEvent.MOUSE_UP,handleMove);
					pixusShell.options.preferencesWindowPosition=new Object();
					pixusShell.options.preferencesWindowPosition={x:stage.nativeWindow.x,y:stage.nativeWindow.y};
					break;
			}
		}

		public function handleTab(event:MouseEvent):void {
			switch (event.target) {
				case bTabPresets :
					iconPresets.activate();
					panelSlide(0);
					break;
				case bTabSkins :
					iconSkins.activate();
					panelSlide(1);
					break;
				case bTabHelp :
					iconHelp.activate();
					panelSlide(2);
					break;
				case bTabAbout :
					iconAbout.activate();
					panelSlide(3);
					break;
			}
		}

		function syncMenu():void {
			NativeApplication.nativeApplication.dispatchEvent(new Event(pixusShell.EVENT_SYNC_MENU));
		}

		public function handleClose(event:MouseEvent):void {
			stage.nativeWindow.visible=false;
		}

		public function handleAdd(event:MouseEvent):void {
			presets.addChild(new presetRow());
			panels.panelPresets.dispatchEvent(new customEvent(customEvent.RESIZE));
			syncMenu();
		}

		public function handleSyncWindowSize(event:Event):void {
			//syncWindowSize();
		}

		function panelSlide(id:int) {
			if (currentPanel!=id) {
				currentPanel=id;
				Tweener.addTween(panels,{x:panelsX0-id*pixusShell.PREFERENCES_PANEL_WIDTH,time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
			}
		}

		function get presetListHeight():int{
			return bg.height-MARGIN_TOP-MARGIN_BOTTOM;
		}

		function syncWindowSize():void {
			resizer.y=bg.height;
			maskPanel.height=bg.height-MARGIN_TOP;
			panels.panelPresets.bottomControl.y=presetListHeight;
			panels.panelPresets.dispatchEvent(new customEvent(customEvent.RESIZE,{viewWidth:pixusShell.PREFERENCES_PANEL_WIDTH, viewHeight:presetListHeight}));
			panels.panelSkins.dispatchEvent(new customEvent(customEvent.RESIZE,{viewWidth:pixusShell.PREFERENCES_PANEL_WIDTH, viewHeight:presetListHeight}));
			panels.panelHelp.dispatchEvent(new customEvent(customEvent.RESIZE,{viewWidth:pixusShell.PREFERENCES_PANEL_WIDTH, viewHeight:resizer.y-MARGIN_TOP-MARGIN_BOTTOM}));
			panels.panelAbout.dispatchEvent(new customEvent(customEvent.RESIZE,{viewWidth:pixusShell.PREFERENCES_PANEL_WIDTH, viewHeight:resizer.y-MARGIN_TOP-MARGIN_BOTTOM}));
			stage.nativeWindow.height=bg.height+20;
		}

	}
}