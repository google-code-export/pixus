// pixusShell class
// Version 0.9.0 2008-07-09
// (cc)2007-2008 codeplay
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
	import codeplay.event.customEvent;

	public class pixusShell extends MovieClip {
		public static  const APP_NAME:String='Pixus';
		public static  const APP_PATH:String='/';
		public static  const UI_TWEENING_TIME:Number=.3;
		public static  const ROW_WIDTH:int=260;
		public static  const PRESET_ROW_HEIGHT:int=25;
		public static  const SKIN_ROW_HEIGHT:int=50;

		// Custom Events
		public static  const EVENT_SYNC_WINDOW_SIZE:String='PixusEventSyncWindowSize';
		public static  const EVENT_SYNC_MENU:String='PixusEventSyncMenu';// Sync System Tray / Dock Icon Menu To The Presets
		public static  const EVENT_SYNC_PRESETS:String='PixusEventSyncPresets';// Sync Preferences / Presets
		public static  const EVENT_APPLY_SKIN:String='PixusEventApplySkin';// Apply Skin

		// Defult Presets
		public static  const PRESETS:Array=[
		{width:320,height:240,comments:'CGA'},
		{width:640,height:480,comments:'VGA'},
		{width:1024,height:768,comments:'XGA'}
		];

		var windowPixus:NativeWindow;
		var windowPreferences:NativeWindow;
		public static var skinpresets:XML;
		var loader:URLLoader=new URLLoader();
		static var so:SharedObject=SharedObject.getLocal(APP_NAME,APP_PATH);
		// Must initialize SharedObject first for Max OS X compatibility. Never use SharedObject.getLocal(APP_NAME,APP_PATH).data directly.
		public static  var options:Object=so.data;

		function pixusShell():void {
			// Default settings
			if (options.presets==undefined) {
				options.presets=PRESETS;
			}

			loader.addEventListener(Event.COMPLETE,init);
			loader.load(new URLRequest('skin.xml'));
		}

		function init(event:Event):void {
			skinpresets=new XML(event.target.data);
			if (options.skin==undefined) {
				options.skin=0;
			}

			// Create Pixus Window
			var option:NativeWindowInitOptions;

			option=new NativeWindowInitOptions();
			option.type=NativeWindowType.LIGHTWEIGHT ;
			option.systemChrome=NativeWindowSystemChrome.NONE;
			option.transparent=true;
			windowPixus=new NativeWindow(option);
			windowPixus.visible=false;
			windowPixus.title = 'Pixus';
			windowPixus.width = 600;
			windowPixus.height = 400;
			windowPixus.alwaysInFront=true;
			windowPixus.stage.addChild(new pixus(this));

			//Create Preferences Window
			option=new NativeWindowInitOptions();
			option.type=NativeWindowType.LIGHTWEIGHT;
			option.systemChrome=NativeWindowSystemChrome.NONE;
			option.transparent=true;
			windowPreferences=new NativeWindow(option);
			if (options.preferencesWindowPosition==undefined) {
				options.preferencesWindowPosition={x:300,y:200,height:600};
			}
			if (options.preferencesWindowPosition!=undefined) {
				windowPreferences.x=options.preferencesWindowPosition.x;
				windowPreferences.y=options.preferencesWindowPosition.y;
			}
			windowPreferences.visible=false;
			windowPreferences.title = 'Pixus Preferences';
			windowPreferences.width = 400;
			windowPreferences.height = 600;
			windowPreferences.stage.scaleMode=StageScaleMode.NO_SCALE;
			windowPreferences.stage.align=StageAlign.TOP_LEFT;
			windowPreferences.alwaysInFront=true;
			var p:preferences=new preferences(this);
			p.x=10;
			p.y=10;
			windowPreferences.stage.addChild(p);

			// Dock and SystemTray Icon
			syncMenu();
			NativeApplication.nativeApplication.icon.addEventListener(MouseEvent.CLICK,handleIcon);// For Windows Tray Icon
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE,handleIcon);// For Mac OS Dock Icon Click or Reinvoke in Windows
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
			NativeApplication.nativeApplication.addEventListener(customEvent.OPEN_PREFERENCES, handlePreferences);
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

			item=new NativeMenuItem('Preferences');
			item.addEventListener(Event.SELECT,handlePreferences);
			item.mnemonicIndex=0;
			item.keyEquivalent='k';
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

		function handleIcon(event:Event):void {
			windowPixus.visible=!windowPixus.visible;// Hide / Show NativeWindow
		}

		function handleExit(event:Event):void {
			NativeApplication.nativeApplication.exit();
		}

		function handlePreferences(event:Event):void {
			windowPreferences.visible=true;
			windowPreferences.orderToFront();
		}

		public function get currentSkin():XML {
			return options.skin==0?null:skinpresets.skin[options.skin-1];
		}
	}
}