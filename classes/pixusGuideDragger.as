// pixusGuideDragger class
// (cc)2009 JPEG Interactive
// By Jam Zhang
// jammind@gmail.com

package {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowResize;
	import flash.events.NativeWindowBoundsEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import com.google.analytics.GATracker;

	public class pixusGuideDragger extends Sprite {
		
		//private static var draggers:Array=[];
		//private static var guides:Array=[];
		//private var guide:Sprite;
		
		private var type:String; //=name.substr(name.length-2).toUpperCase();
		private var _host:pixusMain; //=parent.parent.parent as pixus; // _host will handle resizing and moving
		private var dx, dy:int;
		private var tracker:GATracker=pixusShell.tracker;

		public function pixusGuideDragger(pm:pixusMain, t:String, pos:int=0):void {
			_host=pm;
			type=t;
//			draggers[type]=this;
			if(type.charAt(0)=='H'){
				hotspot.rotation=-90;
				hotspot.x=-20;
			}
//			guide=new pixusGuide(type,);
			hotspot.addEventListener(MouseEvent.MOUSE_DOWN, handleMouse);
		}

		function handleMouse(event:MouseEvent):void {
			switch(event.type){
				case MouseEvent.MOUSE_DOWN:
//					tracker.trackPageview( 'Pixus/Guide');
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
					syncGuides(new Point(event.stageX+dx,event.stageY+dy));
					break;
			}
		}

		public function set offsetx(x0:int){
			hotspot.x=x0;
		}

		public function set offsety(y0:int){
			hotspot.y=y0;
		}

		public function syncGuides(point:Point):void{
			point=parent.globalToLocal(point);
			switch (type){
				case 'VL':
					_host.setHorizontalGuides(point.x);
					break;
				case 'VR':
					_host.setHorizontalGuides(_host.rulerWidth-point.x);
					break;
				case 'HT':
					_host.setVerticalGuides(point.y);
					break;
				case 'HB':
					_host.setVerticalGuides(_host.rulerHeight-point.y);
					break;
			}
		}
		/*
		public function setHorizontalGuides(x:int=-1){
			// Sync with the new width by default
			if(x==-1){
				x=draggers['VL'].x;
			}
			x=Math.max(0,Math.min(_host.rulerWidth*.5,x));
			draggers['VL'].x=x;
			draggers['VR'].x=_host.rulerWidth-x;
		}
		
		public function setVerticalGuides(y:int=-1){
			// Sync with the new height by default
			if(y==-1){
				y=draggers['HT'].y;
			}
			y=Math.max(0,Math.min(_host.rulerHeight*.5,y));
			draggers['HT'].y=y;
			draggers['HB'].y=_host.rulerHeight-y;
		}
		*/
	}
}