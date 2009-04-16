// scrollBar class
// Version 0.9.0 2008-07-09
// (cc)2007-2008 codeplay
// By Jam Zhang
// jam@01media.cn

package codeplay.ui.minimal{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import codeplay.ui.aqua.scrollPanel;
	import codeplay.event.customEvent;

	public class scrollBar extends Sprite{

		public static const MINIMAL_HEIGHT:int=15;
		public static const MINIMAL_WIDTH:int=15;
		const DEFAULT_ALPHA:Number=.5;
		const ROLLOVER_ALPHA:Number=.75;

		var vertical:Boolean=true;
		var _railLength:int=300;
		var _barLength:int=50;
		var x0:int=x;
		var y0:int=y;

		public function scrollBar(data:Object=null):void{
			if(data!=null){
				if(data.x!=undefined)
					x=x0=data.x;
				if(data.y!=undefined)
					y=y0=data.y;
				if(data.x0!=undefined)
					x=x0=data.x0;
				if(data.y0!=undefined)
					y=y0=data.y0;
				if(data._railLength!=undefined)
					_railLength=data._railLength;
				if(data._barLength!=undefined)
					_barLength=data.barLength;
				if(data.vertical!=undefined)
					vertical=data.vertical;
			}
			addEventListener(Event.ADDED_TO_STAGE,init);
		}

		function init(event:Event):void{
			if(vertical){
				width=MINIMAL_WIDTH;
				height=_barLength;
			} else {
				height=MINIMAL_HEIGHT;
				width=_barLength;
			}
			alpha=DEFAULT_ALPHA;
			buttonMode=true;
			addEventListener(MouseEvent.MOUSE_DOWN,handleMouse);
			addEventListener(MouseEvent.MOUSE_OVER,handleMouse);
			addEventListener(MouseEvent.MOUSE_OUT,handleMouse);
			parent.addEventListener(customEvent.RESIZE,handleResize);
		}

		function handleResize(event:customEvent):void{
			switch(event.type){
				case customEvent.SCROLLBAR_RESIZED:
					railLength=event.data.railLength;
					break;
				case customEvent.RESIZE:
					if(event.data!=null){
						railLength=vertical?event.data.viewHeight:event.data.viewWidth;
					}
					break;
			}
		}

		function set railLength(l:int):void{
			var p:Number=percentage;
			_railLength=l;
			percentage=p;
		}

		function handleMouse(event:MouseEvent):void{
			switch(event.type){
				case MouseEvent.MOUSE_OVER:
					alpha=ROLLOVER_ALPHA;
					break;
				case MouseEvent.MOUSE_OUT:
					alpha=DEFAULT_ALPHA;
					break;
				case MouseEvent.MOUSE_DOWN:
					stage.addEventListener(MouseEvent.MOUSE_UP,handleMouse);
					stage.addEventListener(MouseEvent.MOUSE_MOVE,handleMouse);
					removeEventListener(MouseEvent.MOUSE_OUT,handleMouse);
					if(vertical)
						startDrag(false,new Rectangle(x,y0,0,_railLength-_barLength));
					else
						startDrag(false,new Rectangle(x0,y,_railLength-_barLength,0));
					break;
				case MouseEvent.MOUSE_UP:
					parent.dispatchEvent(new customEvent(customEvent.SCROLLED,{percentage:percentage,vertical:vertical}));
					stage.removeEventListener(MouseEvent.MOUSE_UP,handleMouse);
					stage.removeEventListener(MouseEvent.MOUSE_MOVE,handleMouse);
					addEventListener(MouseEvent.MOUSE_OUT,handleMouse);
					alpha=DEFAULT_ALPHA;
					stopDrag();
					break;
				case MouseEvent.MOUSE_MOVE:
//					parent.dispatchEvent(new customEvent(customEvent.SCROLL,{percentage:percentage}));
					parent.dispatchEvent(new customEvent(customEvent.SCROLLING,{percentage:percentage,vertical:vertical}));
					break;
			}
		}

		function get percentage():Number{
			return (vertical?(y-y0):(x-x0))/(_railLength-_barLength);
		}

		function set percentage(p:Number):void{
			if(vertical)
				y=y0+Math.round((_railLength-_barLength)*p);
			else
				x=x0+Math.round((_railLength-_barLength)*p);
		}

		function set barLength(l:int):void{
			if(vertical)
				height=_barLength=l;
			else
				width=_barLength=l;
		}

	}
}
