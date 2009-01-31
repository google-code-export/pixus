// update class
// update NativeWindow
// Version 0.1.0 2009-1-30
// (cc)2007-2008 codeplay
// By Jam Zhang
// jam@01media.cn

package {
	import flash.display.MovieClip;
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


	public class update extends MovieClip {

		const PANEL_WIDTH:int=260;
		const STATE_CHECKING:int=0;
		const STATE_CONNECTION_FAILED:int=1;
		const STATE_LATEST:int=2;
		const STATE_OUTOFDATE:int=3;
		const STATE_DOWNLOADING:int=4;
		const STATE_DOWNLOADED:int=5;
		const STATE_DOWNLOAD_FAILED:int=6;

		var urlLoader:URLLoader=new URLLoader();
		var updateInfo:XML;
		var urlStream:URLStream = new URLStream(); 
		var fileData:ByteArray = new ByteArray(); 
		var file:File;

		function update():void {
			stop();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		public function init(event:Event):void {
			stage.scaleMode=StageScaleMode.NO_SCALE;
			stage.align=StageAlign.TOP_LEFT;
			bg.addEventListener(MouseEvent.MOUSE_DOWN,handleMove);
			control.bDownload01.addEventListener(MouseEvent.CLICK,handleButtons);
			control.bDownload02.addEventListener(MouseEvent.CLICK,handleButtons);
			control.bInstall.addEventListener(MouseEvent.CLICK,handleButtons);
			urlStream.addEventListener(ProgressEvent.PROGRESS,updateProgress); 
			urlStream.addEventListener(Event.COMPLETE,updateLoaded); 
			urlLoader.addEventListener(Event.COMPLETE,handleLoader);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,handleLoader);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,handleLoader);
			urlLoader.load(new URLRequest(pixusShell.UPDATE_FEED));
		}

		function handleButtons(event:MouseEvent):void {
			switch (event.target) {
				case control.bDownload01 :
				case control.bDownload02 :
					trace(updateInfo.source[0]);
					downloadUpdate(updateInfo.source[0]);
					setState(STATE_DOWNLOADING);
					break;
				case control.bInstall :
					var updater:Updater=new Updater();
					updater.update(file,updateInfo.latest.version.toString());
					break;
			}
		}

		function handleLoader(event:Event):void {
			switch(event.type){
				case Event.COMPLETE:
					updateInfo=new XML(event.target.data);
					control.tfInfo01.text=control.tfInfo02.text=pixusShell.CURRENT_VERSION+'\n'+updateInfo.latest.version+'\n'+updateInfo.latest.date+'\n'+updateInfo.latest.size;
					setState(pixusShell.CURRENT_VERSION<updateInfo.latest.version?STATE_OUTOFDATE:STATE_LATEST);
					break;
				default:
					setState(STATE_CONNECTION_FAILED);
					break;
			}
		}

		function downloadUpdate(url:XML){
			urlStream.load(new URLRequest(url.toString())); 
		}

		function updateProgress(event:ProgressEvent):void {
			control.tfProgress.text=int(event.bytesLoaded*0.001)+'/'+int(event.bytesTotal*0.001)+'KB';
			control.progress01.setProgress(event.bytesLoaded/event.bytesTotal);
		} 
 
		function updateLoaded(event:Event):void { 
			control.progress01.setProgress(1);
		    urlStream.readBytes(fileData, 0, urlStream.bytesAvailable); 
		    writeAirFile(); 
			setState(STATE_DOWNLOADED);
		} 
 
		function writeAirFile():void { 
		    file = File.applicationStorageDirectory.resolvePath("pixus_update.air"); 
		    var fileStream:FileStream = new FileStream(); 
		    fileStream.open(file, FileMode.WRITE); 
		    fileStream.writeBytes(fileData, 0, fileData.length); 
		    fileStream.close(); 
		    trace("The AIR file is written."); 
		}

		function setState(s:int){
			control.x=-PANEL_WIDTH*s;
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