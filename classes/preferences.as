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
		const MARGIN_BOTTOM:int=50;
		public static const MIN_HEIGHT:int=360;
		public static const MAX_HEIGHT:int=600;

		public var shell:pixusShell;
		var presets:scrollPanel;
		var skins:scrollPanel;
		var currentPanel:int=0;
		var panelsX0:int;

		function preferences(pshell:pixusShell):void {
			shell=pshell;
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		public function init(event:Event):void {
			var l,n:int;

			maskPanel.width=bg.width=pixusShell.PREFERENCES_PANEL_WIDTH+1;
			resizer.x=int(bg.width*.5);

			// Default settings
			if (pixusShell.options.preferencesWindow==undefined) {
				pixusShell.options.preferencesWindow={x:pixusShell.PREFERENCES_PANEL_X,y:pixusShell.PREFERENCES_PANEL_Y,height:600,visible:false};
			}
//			trace('preferences x='+pixusShell.options.preferencesWindow.x+' y='+pixusShell.options.preferencesWindow.y+' height='+pixusShell.options.preferencesWindow.height+' visible='+pixusShell.options.preferencesWindow.visible);
			if(pixusShell.options.preferencesWindow.height!=undefined)
				setHeight(pixusShell.options.preferencesWindow.height);
			if (pixusShell.options.preferencesWindow!=undefined) {
				stage.nativeWindow.x=pixusShell.options.preferencesWindow.x;
				stage.nativeWindow.y=pixusShell.options.preferencesWindow.y;
			}
			stage.nativeWindow.visible=pixusShell.options.preferencesWindow.visible;
			bClose.addEventListener(MouseEvent.CLICK, handleClose);
			bg.addEventListener(MouseEvent.MOUSE_DOWN,handleMove);
			bTabPresets.addEventListener(MouseEvent.CLICK, handleTab);
			bTabSkins.addEventListener(MouseEvent.CLICK, handleTab);
			bTabOptions.addEventListener(MouseEvent.CLICK, handleTab);
			bTabHelp.addEventListener(MouseEvent.CLICK, handleTab);
			bTabAbout.addEventListener(MouseEvent.CLICK, handleTab);
			resizer.addEventListener(MouseEvent.MOUSE_DOWN, handleResize);
			iconPresets.activate();

			//panelArray=[panels.panelPresets,panels.panelSkins];
			panelsX0=panels.x;

			// Presets Panel
			panels.panelPresets.bottomControl.bAdd.addEventListener(MouseEvent.CLICK, handleAdd);
			panels.panelPresets.bottomControl.bReset.addEventListener(MouseEvent.CLICK, handleResetPresets);
			rebuildPresets();

			// Skins Panel
			panels.panelSkins.bottomControl.bFind.addEventListener(MouseEvent.CLICK, handleFindBackButton);
			skins=new scrollPanel({width:pixusShell.PREFERENCES_PANEL_WIDTH});//,viewHeight:pixusShell.options.preferencesWindow.height,delta:pixusShell.SKIN_ROW_HEIGHT,snapping:true});
			panels.panelSkins.addChild(skins);
			l=pixusShell.skinpresets.skin.length();
			for (n=0; n<l; n++) {
				skins.addChild(new skinRow());
			}

			// Help Panel

			// About Panel
			panels.panelAbout.bottomControl.bUpdate.addEventListener(MouseEvent.CLICK, handleUpdate);
			panels.panelAbout.inner.tfInfo.text=pixusShell.options.version.version+'\n'+pixusShell.options.version.release+'\n'+pixusShell.options.version.date;

			NativeApplication.nativeApplication.addEventListener(pixusShell.EVENT_PRESETS_CHANGE, handlePresetsChange);
			NativeApplication.nativeApplication.addEventListener(pixusShell.EVENT_FIND_BACK,handleFindBackEvent);
			addEventListener(Event.ENTER_FRAME,init2);
		}

		// Things must be done 1-frame after init()
		function init2(event:Event):void {
			removeEventListener(Event.ENTER_FRAME,init2);
			syncWindowSize();
		}

		function handleFindBackEvent(event:customEvent):void {
			setHeight(MIN_HEIGHT);
			syncWindowSize();
		}

		function handleFindBackButton(event:MouseEvent):void {
			// Strange! The handler accepts an Event parameter but I have to trigger a customEvent or I will get a runtime error.
			NativeApplication.nativeApplication.dispatchEvent(new customEvent(pixusShell.EVENT_FIND_BACK));
		}

		function handleResetPresets(event:Event):void {
			NativeApplication.nativeApplication.dispatchEvent(new Event(pixusShell.EVENT_RESET_PRESETS));
		}

		function handleUpdate(event:Event):void {
			shell.toggleUpdateWindow(true);
		}

		function handlePresetsChange(event:Event):void {
			rebuildPresets();
			syncWindowSize();
		}

		function rebuildPresets():void {
			var l,n:int;
			if(presets!=null){
				panels.panelPresets.removeChild(presets);
				menuRow.clearRows();
			}
			presets=new scrollPanel({width:pixusShell.PREFERENCES_PANEL_WIDTH,viewHeight:pixusShell.options.preferencesWindow.height,delta:pixusShell.PRESET_ROW_HEIGHT,snapping:true});
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
					pixusShell.options.preferencesWindow.height=bg.height=resizer.y;
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleResize);
					stage.removeEventListener(MouseEvent.MOUSE_UP, handleResize);
					break;
				case MouseEvent.MOUSE_MOVE :
					bg.height=resizer.y;
					syncWindowSize();
					break;
			}
		}

		public function setHeight(h:int){
			resizer.y=bg.height=pixusShell.options.preferencesWindow.height=h;
			stage.nativeWindow.height = h+100;
		}

		public function handleMove(event:MouseEvent):void {
			switch (event.type) {
				case MouseEvent.MOUSE_DOWN :
					stage.nativeWindow.startMove();
					stage.addEventListener(MouseEvent.MOUSE_UP,handleMove);
					break;
				case MouseEvent.MOUSE_UP :
					stage.removeEventListener(MouseEvent.MOUSE_UP,handleMove);
					pixusShell.options.preferencesWindow.x=stage.nativeWindow.x;
					pixusShell.options.preferencesWindow.y=stage.nativeWindow.y;
					break;
			}
		}

		public function handleTab(event:MouseEvent):void {
			switch (event.target) {
				case bTabPresets :
					iconPresets.activate();
					panels.slideToPanel(0);
					break;
				case bTabSkins :
					iconSkins.activate();
					panels.slideToPanel(1);
					break;
				case bTabOptions :
					iconOptions.activate();
					panels.slideToPanel(2);
					break;
				case bTabHelp :
					iconHelp.activate();
					panels.slideToPanel(3);
					break;
				case bTabAbout :
					iconAbout.activate();
					panels.slideToPanel(4);
					break;
			}
		}

		function syncMenu():void {
			NativeApplication.nativeApplication.dispatchEvent(new Event(pixusShell.EVENT_SYNC_MENU));
		}

		public function handleClose(event:MouseEvent):void {
			NativeApplication.nativeApplication.dispatchEvent(new customEvent(pixusShell.HIDE_PREFERENCES));
		}

		public function handleAdd(event:MouseEvent):void {
			presets.addChild(new presetRow());
			panels.panelPresets.dispatchEvent(new customEvent(customEvent.RESIZE));
			syncMenu();
		}

		function get presetListHeight():int{
			return bg.height-MARGIN_TOP-MARGIN_BOTTOM;
		}

		function syncWindowSize():void {
			resizer.y=bg.height;
			maskPanel.height=bg.height-MARGIN_TOP;
			panels.panelPresets.bottomControl.y=panels.panelSkins.bottomControl.y=panels.panelAbout.bottomControl.y=presetListHeight;
			panels.panelPresets.dispatchEvent(new customEvent(customEvent.RESIZE,{viewWidth:pixusShell.PREFERENCES_PANEL_WIDTH, viewHeight:presetListHeight}));
			panels.panelSkins.dispatchEvent(new customEvent(customEvent.RESIZE,{viewWidth:pixusShell.PREFERENCES_PANEL_WIDTH, viewHeight:presetListHeight}));
			panels.panelHelp.dispatchEvent(new customEvent(customEvent.RESIZE,{viewWidth:pixusShell.PREFERENCES_PANEL_WIDTH, viewHeight:resizer.y-MARGIN_TOP-MARGIN_BOTTOM}));
			panels.panelAbout.dispatchEvent(new customEvent(customEvent.RESIZE,{viewWidth:pixusShell.PREFERENCES_PANEL_WIDTH, viewHeight:resizer.y-MARGIN_TOP-MARGIN_BOTTOM}));
			stage.nativeWindow.height=bg.height+100;
		}

	}
}