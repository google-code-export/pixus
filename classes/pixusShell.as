// pixusShell class
// The Application Root Class
// 2009-3-3
// (cc)2007-2009 codeplay
// By Jam Zhang
// jam@01media.cn

package {
	import flash.display.NativeWindow;
	import flash.display.NativeWindowType;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.desktop.DockIcon;
	import flash.desktop.SystemTrayIcon;
	import flash.desktop.NativeApplication;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.SharedObject;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.events.MouseEvent;
	import flash.events.ScreenMouseEvent;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.system.Capabilities;
	import caurina.transitions.Tweener;
	import codeplay.event.customEvent;
	import codeplay.utils.copyObjectDeep;

	public class pixusShell extends MovieClip {
		public static  const APP_NAME:String='Pixus';
		public static  const APP_PATH:String='/';
		public static  const UI_TWEENING_TIME:Number=.3;
		public static  const ROW_WIDTH:int=300;
		public static  const PRESET_ROW_HEIGHT:int=25;
		public static  const SKIN_ROW_HEIGHT:int=50;
		public static  const PIXUS_PANEL_X:int=450;
		public static  const PIXUS_PANEL_Y:int=100;
		public static  const UPDATE_PANEL_X:int=100;
		public static  const UPDATE_PANEL_Y:int=100;
		public static  const PREFERENCES_PANEL_WIDTH:int=300;
		public static  const PREFERENCES_PANEL_X:int=100;
		public static  const PREFERENCES_PANEL_Y:int=400;

		// Custom Events
		public static  const EVENT_SYNC_WINDOW_SIZE:String='PixusEventSyncWindowSize';
		public static  const EVENT_SYNC_MENU:String='PixusEventSyncMenu';// Sync System Tray / Dock Icon Menu To The Presets
		public static  const EVENT_SYNC_PRESETS:String='PixusEventSyncPresets';// Sync Preferences / Presets
		public static  const EVENT_APPLY_SKIN:String='PixusEventApplySkin';// Apply Skin
		public static  const EVENT_FIND_BACK:String='PixusEventFindPixusBack';// Apply Skin
		public static  const EVENT_RESET_PRESETS:String='PixusEventResetPresets';// Reset Preferences / Presets
		public static  const EVENT_PRESETS_CHANGE:String='PixusEventPresetsChange';// Presets Data Changed
		public static  const EVENT_CHECK_UPDATE:String='PixusEventCheckUpdate';// Check For Update
		public static  const SHOW_PREFERENCES:String='PixusEventShowPreferences';// Show Preferences Window
		public static  const HIDE_PREFERENCES:String='PixusEventHidePreferences';// Hide Preferences Window
		public static  const SHOW_PIXUS:String='PixusEventShowPixus';// Show Pixus Window
		public static  const HIDE_PIXUS:String='PixusEventHidePixus';// Hide Pixus Window
		public static  const TOGGLE_PIXUS:String='PixusEventTogglePixus';// Toggle Pixus Window

		// Defult Presets
		public static  const PRESETS:Array=[
		{width:480,height:272,comments:'PSP'},
		{width:480,height:320,comments:'iPhone Landscape'},
		{width:320,height:480,comments:'iPhone Portrait'},
		{width:640,height:480,comments:'VGA'},
		{width:760,height:420,comments:'SVGA Windowed'},
		{width:800,height:600,comments:'SVGA'},
		{width:955,height:600,comments:'XGA Windowed'},
		{width:1024,height:768,comments:'XGA'}
		];

		var windowPixus:hidingWindow;
		var windowPreferences:hidingWindow;
		var windowUpdate:hidingWindow;
		static var firstTimeInvoke:Boolean=true;
		static var so:SharedObject=SharedObject.getLocal(APP_NAME,APP_PATH);
		public static var skinpresets, settings:XML;
		public static var options:Object=so.data;
		var loader:URLLoader=new URLLoader();
		// Must initialize SharedObject first for Max OS X compatibility. Never use SharedObject.getLocal(APP_NAME,APP_PATH).data directly.

		function pixusShell():void {
			// Default settings
			if (options.presets==undefined) {
				options.presets=PRESETS;
			}

			loader.addEventListener(Event.COMPLETE,init);
			loader.load(new URLRequest('pixus-settings.xml'));
		}

		function init(event:Event):void {
			settings=new XML(event.target.data);
			skinpresets=settings.skinpresets;
			if (options.skin==undefined) {
				options.skin=0;
			}
			options.updateFeedURL=settings.updatefeedurl;
			options.version=settings.version;

			// Create Pixus Window
			var option:NativeWindowInitOptions;

			option=new NativeWindowInitOptions();
			option.type=NativeWindowType.LIGHTWEIGHT ;
			option.systemChrome=NativeWindowSystemChrome.NONE;
			option.transparent=true;
			windowPixus=new hidingWindow(option);
			windowPixus.title = 'Pixus';
			windowPixus.alwaysInFront=true;
			windowPixus.stage.addChild(new pixus(this));

			//Create Preferences Window
			option=new NativeWindowInitOptions();
			option.type=NativeWindowType.LIGHTWEIGHT;
			option.systemChrome=NativeWindowSystemChrome.NONE;
			option.transparent=true;
			windowPreferences=new hidingWindow(option);
			if (options.preferencesWindowPosition==undefined) {
				options.preferencesWindowPosition={x:100,y:300,height:600};
			}
			if (options.preferencesWindowPosition!=undefined) {
				windowPreferences.x=options.preferencesWindowPosition.x;
				windowPreferences.y=options.preferencesWindowPosition.y;
			}
//			windowPreferences.visible=false;
			windowPreferences.title = 'Pixus Preferences';
			windowPreferences.width = PREFERENCES_PANEL_WIDTH+100;
			windowPreferences.stage.scaleMode=StageScaleMode.NO_SCALE;
			windowPreferences.stage.align=StageAlign.TOP_LEFT;
			windowPreferences.alwaysInFront=true;
			var p:preferences=new preferences(this);
			p.x=10;
			p.y=10;
			windowPreferences.stage.addChild(p);

			//Create Update Window
			option=new NativeWindowInitOptions();
			option.type=NativeWindowType.LIGHTWEIGHT ;
			option.systemChrome=NativeWindowSystemChrome.NONE;
			option.transparent=true;
			windowUpdate=new hidingWindow(option);
			windowUpdate.width=350;
			windowUpdate.height=300;
			if (options.updateWindowPosition==undefined) {
				options.updateWindowPosition={x:100,y:100};
			}
			windowUpdate.visible=false;
			windowUpdate.alwaysInFront=true;
			var u:update=new update();
			u.x=10;
			u.y=10;
			u.scaleX=u.scaleY=1;
			windowUpdate.stage.addChild(u);

			// Dock and SystemTray Icon
			syncMenu();
			NativeApplication.nativeApplication.icon.addEventListener(MouseEvent.CLICK,handleIcon);// For Windows Tray Icon
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE,handleInvoke);// For Mac OS Dock Icon Click or Reinvoke in Windows
			NativeApplication.nativeApplication.icon.bitmaps  = [
			new BitmapIconPixus512(512,512),
			new BitmapIconPixus128(128,128),
			new BitmapIconPixus48(48,48),
			new BitmapIconPixus32(32,32),
			new BitmapIconPixus16(16,16)
			];

			// Windows System Tray
			if (NativeApplication.supportsSystemTrayIcon) {
				var sysTrayIcon:SystemTrayIcon=NativeApplication.nativeApplication.icon as SystemTrayIcon;
				sysTrayIcon.tooltip = APP_NAME;
			}

			// Max OSX Dock Bar
			//if (NativeApplication.supportsDockIcon) {
			//var dockIcon:DockIcon=NativeApplication.nativeApplication.icon as DockIcon;
			//}

			NativeApplication.nativeApplication.addEventListener(EVENT_SYNC_MENU, handleSyncMenu);
			NativeApplication.nativeApplication.addEventListener(SHOW_PREFERENCES, handleWindows);
			NativeApplication.nativeApplication.addEventListener(HIDE_PREFERENCES, handleWindows);
			NativeApplication.nativeApplication.addEventListener(SHOW_PIXUS, handleWindows);
			NativeApplication.nativeApplication.addEventListener(HIDE_PIXUS, handleWindows);
			NativeApplication.nativeApplication.addEventListener(TOGGLE_PIXUS, handleWindows);
			NativeApplication.nativeApplication.addEventListener(EVENT_FIND_BACK,handleFindBackEvent);
			NativeApplication.nativeApplication.addEventListener(EVENT_RESET_PRESETS,doResetPresets);
		}

		function handleWindows(event:Event):void {
			switch(event.type){
				case SHOW_PREFERENCES:
					togglePreferencesWindow(true);
					break;
				case HIDE_PREFERENCES:
					togglePreferencesWindow(false);
					break;
				case SHOW_PREFERENCES:
					togglePreferencesWindow(true);
					break;
				case SHOW_PIXUS:
					togglePixusWindow(true);
					break;
				case HIDE_PIXUS:
					togglePixusWindow(false);
					break;
				case TOGGLE_PIXUS:
					togglePixusWindow();
					break;
			}
		}

		function syncMenu():void {
			var iconMenu:NativeMenu = new NativeMenu();
			var item:NativeMenuItem;
			for (var n=0; n<options.presets.length; n++) {
				var preset=options.presets[n];
				item=new NativeMenuItem(preset.width+' x '+preset.height+' '+preset.comments);
				item.data=preset;
				item.addEventListener(Event.SELECT,handlePresets);
				iconMenu.addItem(item);
			}
			iconMenu.addItem(new NativeMenuItem('',true));

			item=new NativeMenuItem('Find Pixus');
			item.addEventListener(Event.SELECT,handleFindBack);
			item.mnemonicIndex=0;
			item.keyEquivalent='f';
			iconMenu.addItem(item);

			item=new NativeMenuItem('Preferences');
			item.addEventListener(Event.SELECT,handlePreferences);
			item.mnemonicIndex=0;
			item.keyEquivalent='k';
			iconMenu.addItem(item);

			item=new NativeMenuItem('Update');
			item.addEventListener(Event.SELECT,handleUpdate);
			item.mnemonicIndex=0;
			item.keyEquivalent='u';
			iconMenu.addItem(item);

			item=new NativeMenuItem('Exit');
			item.keyEquivalent='q';
			item.addEventListener(Event.SELECT,handleExit);
			iconMenu.addItem(item);
			var sysTrayIcon=NativeApplication.nativeApplication.icon;
			sysTrayIcon.menu = iconMenu;
		}

		function handleSyncMenu(event:Event):void {
			syncMenu();
		}

		function handlePresets(event:Event):void {
			NativeApplication.nativeApplication.dispatchEvent(new customEvent(customEvent.SET_WINDOW_SIZE,(event.target as NativeMenuItem).data));
		}

		// Toggle Pixus
		function handleIcon(event:Event):void {
			togglePixusWindow();
		}

		// Show Pixus when invoking
		// Strange in Windows, even running for the 1st time will dispatch INVOKE
		// Stop from always showing Pixus when launching
		function handleInvoke(event:Event):void {
			if(firstTimeInvoke)
				firstTimeInvoke=false;
			else
				if(Capabilities.os.indexOf('mac')==-1) // Always show it when launching again under Windows
					togglePixusWindow(true);
				else // Toggle visibility when clicking the dock icon under Mac OS X
					togglePixusWindow();
		}

		function handleFindBack(event:Event):void { // Invoked from sys tray / dock menu
			// Strange! handleFindBackEvent accepts an Event parameter but I have to trigger a customEvent or I will get a runtime error.
			NativeApplication.nativeApplication.dispatchEvent(new customEvent(EVENT_FIND_BACK));
		}

		// pixusShell handle finding back of the preferences window
		function handleFindBackEvent(event:Event):void { // Real find back codes
			togglePixusWindow(true);
			togglePreferencesWindow(true);
			toggleUpdateWindow(true);
			// Find Preferences window
			options.preferencesWindowPosition.x=PREFERENCES_PANEL_X;
			options.preferencesWindowPosition.y=PREFERENCES_PANEL_Y;
			Tweener.addTween(windowPreferences,{x:options.preferencesWindowPosition.x,time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
			Tweener.addTween(windowPreferences,{y:options.preferencesWindowPosition.y,time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
			// Find Update window
			options.updateWindowPosition.x=UPDATE_PANEL_X;
			options.updateWindowPosition.y=UPDATE_PANEL_Y;
			Tweener.addTween(windowUpdate,{x:options.updateWindowPosition.x,time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
			Tweener.addTween(windowUpdate,{y:options.updateWindowPosition.y,time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
		}

		function doResetPresets(event:Event):void {
			pixusShell.options.presets=copyObjectDeep(pixusShell.PRESETS);
			NativeApplication.nativeApplication.dispatchEvent(new Event(EVENT_PRESETS_CHANGE));
		}

		function handleExit(event:Event):void {
			NativeApplication.nativeApplication.exit();
		}

		function handlePreferences(event:Event):void {
			togglePreferencesWindow(true);
		}

		function handleUpdate(event:Event):void {
			toggleUpdateWindow(true);
		}

		public function togglePixusWindow(v:Object=null):void{
			if(v==null)
				v=!pixusShell.options.pixusWindow.visible;
			windowPixus.visible=pixusShell.options.pixusWindow.visible=v;
			trace('togglePixusWindow '+pixusShell.options.pixusWindow.visible);
			if(v)
				windowPixus.orderToFront();
		}

		public function togglePreferencesWindow(v:Object=null):void{
			if(v==null)
				v=!pixusShell.options.preferencesWindow.visible;
			windowPreferences.visible=pixusShell.options.preferencesWindow.visible=v;
			if(v)
				windowPreferences.orderToFront();
		}

		public function toggleUpdateWindow(v:Object=null):void{
			if(v==null)
				v=!pixusShell.options.updateWindow.visible;
			windowUpdate.visible=pixusShell.options.updateWindow.visible=v;
			if(v)
				windowUpdate.orderToFront();
		}

		public function get currentSkin():XML {
			return options.skin==0?null:skinpresets.skin[options.skin];
		}
	}
}