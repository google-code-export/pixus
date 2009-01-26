// pixusRulerResizer class
// (cc)2007 01media reactor
// By Jam Zhang
// jam@01media.cn

package {
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowResize;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Point;

	public class pixusRulerResizer extends MovieClip {
		private var _pixus:pixus=parent.parent as pixus; // _pixus will handle resizing and moving
		private var dx, dy:int;

		public function pixusRulerResizer():void {
			hotspot.addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
		}

		private function handleMouse(event:MouseEvent):void {
			switch(event.type){
				case MouseEvent.MOUSE_DOWN:
					var p:Point=localToGlobal(new Point(0,0));
					dx=p.x-event.stageX;
					dy=p.y-event.stageY;
					stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouse);
					stage.addEventListener(MouseEvent.MOUSE_UP, handleMouse);
					break;
				case MouseEvent.MOUSE_UP:
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouse);
					stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouse);
					break;
				case MouseEvent.MOUSE_MOVE:
					syncSize(new Point(event.stageX+dx,event.stageY+dy));
					break;
			}
		}

		public function set offsetx(x0:int){
			hotspot.x=x0;
		}

		public function set offsety(y0:int){
			hotspot.y=y0;
		}

		public function syncSize(point:Point):void{
			point=parent.globalToLocal(point);
			for (var n=0;n<name.length;n++){
				switch(name.charAt(n).toUpperCase()){
					case 'R':
						_pixus.resizeTo(point.x,-1);
						break;
					case 'B':
						_pixus.resizeTo(-1,point.y);
						break;
				}
			}
		}
	}
}