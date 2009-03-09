// skinRow class
// (cc)2008 01media farm
// By Jam Zhang
// jam@01media.cn

package {
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.desktop.NativeApplication;
	import flash.net.SharedObject;
	import flash.net.URLRequest;

	import caurina.transitions.Tweener;

	public class skinRow extends menuRow {

		var loader:Loader=new Loader();

		public function skinRow() {
			super(pixusShell.ROW_WIDTH,pixusShell.SKIN_ROW_HEIGHT,'skinRow');
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		public function init(event:Event):void {
			// HandlesTextFields
			tfTitle.text=pixusShell.skinpresets.skin[id].@title;
			tfSubtitle.text=pixusShell.skinpresets.skin[id].@subtitle;
			loader.load(new URLRequest(pixusShell.skinpresets.skin[id].file.@thumbnail));
			tn.addChild(loader);
			hidden.bApply.addEventListener(MouseEvent.CLICK, handleApply);
			tn.addEventListener(MouseEvent.CLICK, handleApply);
			tn.buttonMode=true;
		}

		function handleApply(event:MouseEvent):void {
			pixusShell.options.skin=id;
			NativeApplication.nativeApplication.dispatchEvent(new Event(pixusShell.EVENT_APPLY_SKIN));
		}

	}
}
