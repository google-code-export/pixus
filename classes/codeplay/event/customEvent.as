// customEvent class
// (cc)2008 codeplay
// By Jam Zhang
// jam@01media.cn

package codeplay.event{
	import flash.events.Event;

	public class customEvent extends Event {
		public static const OPEN_PREFERENCES:String='PixusOpenPreferences';
		public static const SET_WINDOW_SIZE:String='PixusSetWindowSize';
		public static const TAB_ACTIVATED:String='PixusTabIconActivated';
		public static const RESIZE:String='PixusResize';
		public static const SCROLLBAR_RESIZED:String='PixusScrollBarResized';
		public static const VIEWPORT_RESIZED:String='PixusViewportResized';
		public static const CONTENT_RESIZED:String='PixusContentResized';
		public static const SCROLL:String='PixusScroll';
		public static const SCROLLING:String='PixusScrolling';
		public static const SCROLLED:String='PixusScrolled';

		public var data:Object;

		public function customEvent(t:String, d:Object=null) {
			super(t);
			data=d;
		}
	}
}