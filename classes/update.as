// update class
// update NativeWindow
// Version 0.1.0 2009-1-30
// (cc)2007-2008 codeplay
// By Jam Zhang
// jam@01media.cn

package {
	import flash.display.NativeWindow;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.net.SharedObject;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.desktop.Updater;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import com.google.analytics.GATracker;

	public class update extends Sprite {

		const PANEL_WIDTH:int=300;
		const STATE_CHECKING:int=0;
		const STATE_CONNECTION_FAILED:int=1;
		const STATE_LATEST:int=2;
		const STATE_OUTOFDATE:int=3;
		const STATE_DOWNLOADING:int=4;
		const STATE_DOWNLOADED:int=5;
		const STATE_DOWNLOAD_FAILED:int=6;

		private var urlLoader:URLLoader=new URLLoader();
		private var updateInfo:XML;
		private var urlStream:URLStream = new URLStream(); 
		private var fileData:ByteArray = new ByteArray(); 
		private var file:File;
		private var downloadSince:int; // Time value for estimating time remaining
		private var intervalId:int;
		private var tracker:GATracker=pixusShell.tracker;

		function update():void {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		function init(event:Event):void {
			stage.scaleMode=StageScaleMode.NO_SCALE;
			stage.align=StageAlign.TOP_LEFT;

			// Default settings
			if (pixusShell.options.updateWindow==undefined) {
				pixusShell.options.updateWindow={x:pixusShell.UPDATE_PANEL_X,y:pixusShell.UPDATE_PANEL_Y,visible:false};
			}
//			trace('update x='+pixusShell.options.updateWindow.x+' y='+pixusShell.options.updateWindow.y+' visible='+pixusShell.options.updateWindow.visible);
			if (pixusShell.options.preferencesWindow!=undefined) {
				stage.nativeWindow.x=pixusShell.options.updateWindow.x;
				stage.nativeWindow.y=pixusShell.options.updateWindow.y;
				stage.nativeWindow.visible=false; // Always hide Update by default.
			}

			bClose.addEventListener(MouseEvent.CLICK, handleCloseButton);
			bg.addEventListener(MouseEvent.MOUSE_DOWN,handleMove);
			panels.bCheck01.addEventListener(MouseEvent.CLICK,handleButtons);
			panels.bCheck02.addEventListener(MouseEvent.CLICK,handleButtons);
			panels.bDownload01.addEventListener(MouseEvent.CLICK,handleButtons);
			panels.bDownload02.addEventListener(MouseEvent.CLICK,handleButtons);
			panels.bDownload03.addEventListener(MouseEvent.CLICK,handleButtons);
			panels.bInstall.addEventListener(MouseEvent.CLICK,handleButtons);
			panels.bCancel.addEventListener(MouseEvent.CLICK,handleButtons);
			urlLoader.addEventListener(Event.COMPLETE,handleLoader);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,handleLoader);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,handleLoader);
			urlStream.addEventListener(IOErrorEvent.IO_ERROR,handleDownloadUpdateError);
			urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR,handleDownloadUpdateError);
			urlStream.addEventListener(ProgressEvent.PROGRESS,updateProgress); 
			checkUpdate();
		}

		public function handleCloseButton(event:MouseEvent):void {
			tracker.trackPageview( 'Update/Hide');
			stage.nativeWindow.visible=false;
		}

		function handleButtons(event:MouseEvent):void {
			switch (event.target) {
				case panels.bCheck01 :
				case panels.bCheck02 :
					tracker.trackPageview( 'Update/Check');
					checkUpdate();
					break;
				case panels.bDownload01 :
				case panels.bDownload02 :
				case panels.bDownload03 :
//					trace(updateInfo.source[0]);
					tracker.trackPageview( 'Update/Download');
					downloadUpdate(updateInfo.source[0]);
					break;
				case panels.bInstall :
					tracker.trackPageview( 'Update/Install');
					var updater:Updater=new Updater();
					updater.update(file,updateInfo.latest.version.toString());
					break;
				case panels.bCancel :
					tracker.trackPageview( 'Update/Cancel');
					cancelUpdate();
					break;
			}
		}

		function handleLoader(event:Event):void {
			switch(event.type){
				case Event.COMPLETE: // Update feed XML successfully loaded
					tracker.trackPageview( 'Update/Check/Succeeded');
					updateInfo=new XML(event.target.data);
					panels.tfInfo01.text=panels.tfInfo02.text=updateInfo.latest.version+'\n'+updateInfo.latest.release+'\n'+updateInfo.latest.date+'\n'+updateInfo.latest.size;
					compareVersions();
					break;
				default:
					tracker.trackPageview( 'Update/Check/Failed');
					panels.slideToPanel(STATE_CONNECTION_FAILED);
					break;
			}
		}

		function compareVersions(){
			if(pixusShell.options.version.release<updateInfo.latest.release){
				tracker.trackPageview( 'Update/Check/UpdateAvailable');
				panels.slideToPanel(STATE_OUTOFDATE);
				stage.nativeWindow.visible=true;
			} else
				tracker.trackPageview( 'Update/Check/UpToDate');
				panels.slideToPanel(STATE_LATEST);
		}

		function checkUpdate():void {
			panels.slideToPanel(STATE_CHECKING);
			intervalId=setInterval(doCheckUpdate,2000);
		}

		function doCheckUpdate():void {
			urlLoader.load(new URLRequest(pixusShell.options.updateFeedURL));
			clearInterval(intervalId);
		}

		function cancelUpdate():void {
			urlStream.removeEventListener(Event.COMPLETE,updateLoaded); 
			compareVersions();
			try{
				urlStream.close();
			} catch(Error) {
			}
		}

		function downloadUpdate(url:XML){
			tracker.trackPageview( 'Update/Download/Began');
			panels.slideToPanel(STATE_DOWNLOADING);
			downloadSince=getTimer();
			urlStream.addEventListener(Event.COMPLETE,updateLoaded); 
			urlStream.load(new URLRequest(url.toString())); 
		}

		function handleDownloadUpdateError():void {
			tracker.trackPageview( 'Update/Download/Failed');
			panels.slideToPanel(STATE_DOWNLOAD_FAILED);
			urlStream.removeEventListener(Event.COMPLETE,updateLoaded); 
		}

		function downloadingSpeed(bl:int):int{
			return Math.round(bl/(getTimer()-downloadSince)*1000); // Bytes per Second
		}

		function updateProgress(event:ProgressEvent):void {
			var bytesRemaining:int=event.bytesTotal-event.bytesLoaded;
			panels.tfProgress01.text=Math.ceil(bytesRemaining*0.001)+' KB\n'+Math.round(bytesRemaining/downloadingSpeed(event.bytesLoaded))+' Seconds';
			panels.progress01.setProgress(event.bytesLoaded/event.bytesTotal);
			panels.progress02.setProgress(event.bytesLoaded/event.bytesTotal);
		} 
 
		function updateLoaded(event:Event):void { 
			tracker.trackPageview( 'Update/Download/Downloaded');
			panels.progress01.setProgress(1);
			panels.progress02.setProgress(1);
			urlStream.removeEventListener(Event.COMPLETE,updateLoaded); 
		    urlStream.readBytes(fileData, 0, urlStream.bytesAvailable); 
		    writeAirFile(); 
			panels.slideToPanel(STATE_DOWNLOADED);
		} 
 
		function writeAirFile():void { 
		    file = File.applicationStorageDirectory.resolvePath("pixus_update.air"); 
		    var fileStream:FileStream = new FileStream(); 
		    fileStream.open(file, FileMode.WRITE); 
		    fileStream.writeBytes(fileData, 0, fileData.length); 
		    fileStream.close(); 
		    trace("The AIR file is written."); 
		}

		function handleMove(event:MouseEvent):void {
			switch (event.type) {
				case MouseEvent.MOUSE_DOWN :
					stage.nativeWindow.startMove();
					stage.addEventListener(MouseEvent.MOUSE_UP,handleMove);
					break;
				case MouseEvent.MOUSE_UP :
					stage.removeEventListener(MouseEvent.MOUSE_UP,handleMove);
					pixusShell.options.updateWindowPosition=new Object();
					pixusShell.options.updateWindowPosition={x:stage.nativeWindow.x,y:stage.nativeWindow.y};
					break;
			}
		}

	}
}