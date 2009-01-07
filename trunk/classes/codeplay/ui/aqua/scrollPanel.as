// scrollPanel class
// Version 0.9.0 2008-07-09
// (cc)2007-2008 codeplay
// By Jam Zhang
// jam@01media.cn

package codeplay.ui.aqua{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import codeplay.ui.aqua.scrollBar;
	import codeplay.event.customEvent;
	import caurina.transitions.Tweener;

	public class scrollPanel extends Sprite {

		var viewWidth:int=200;
		var viewHeight:int=200;
		var vScrollBar:scrollBar=null;
		var panelMask:Sprite=new Sprite();
		public var scrollDelta:int=10;
		public var snapping:Boolean=false;

		public function scrollPanel(data:Object=null):void {
			if (data!=null) {
				if (data.width!=undefined) {
					viewWidth=data.width;
				}
				if (data.viewHeight!=undefined) {
					viewHeight=data.viewHeight;
				}
				if (data.delta!=undefined) {
					scrollDelta=data.delta;
				}
				if (data.snapping!=undefined) {
					snapping=data.snapping;
				}
			}
			addEventListener(Event.ADDED_TO_STAGE,init);
			addEventListener(Event.REMOVED_FROM_STAGE,dispose);
		}

		function init(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE,init);
			addEventListener(MouseEvent.MOUSE_WHEEL,handleWheel);

			// Adding mask
			panelMask.graphics.beginFill(0x000000);
			panelMask.graphics.drawRect(0,0,viewWidth,viewHeight);
			panelMask.graphics.endFill();
			parent.addChild(panelMask);
			mask=panelMask;

			// Adding scrollbar
			parent.addEventListener(customEvent.RESIZE,handleResize);
			parent.addEventListener(customEvent.CONTENT_RESIZED,handleResize);
			parent.addEventListener(customEvent.SCROLLING,handleScroll);
			parent.addEventListener(customEvent.SCROLLED,handleScroll);
			vScrollBar=new scrollBar({x:pixusShell.ROW_WIDTH-scrollBar.MINIMAL_WIDTH});
			parent.addChild(vScrollBar);
		}

		function dispose(event:Event):void {
			parent.removeChild(panelMask);
			parent.removeChild(vScrollBar);
		}

		function handleScroll(event:customEvent):void {
			switch (event.type) {
				case customEvent.SCROLLING :
					y=Math.round((viewHeight-height)*event.data.percentage);
					break;
				case customEvent.SCROLLED :
					y=Math.round((viewHeight-height)*event.data.percentage);
					if (snapping) {
						var y1:int=Math.round(y/scrollDelta)*scrollDelta;
						Tweener.addTween(this,{y:y1,time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
						syncBarPercentage(y1);
					}
					break;
			}
		}

		function handleWheel(event:MouseEvent):void {
			var y1:int=Math.min(0,Math.max(viewHeight-height,y+scrollDelta*event.delta));
			Tweener.addTween(this,{y:y1,time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic'});
			syncBarPercentage(y1);
		}

		function handleResize(event:customEvent):void {
			var contentHeight:int=height;
			if (event.data!=null) {
				if (event.data.viewWidth!=null)
					viewWidth=event.data.viewWidth;
				if (event.data.viewHeight!=null)
					viewHeight=event.data.viewHeight;
				if (event.data.contentHeight!=null)
					contentHeight=event.data.contentHeight;
			}
			y=Math.min(Math.max(viewHeight-contentHeight,y),0);
			panelMask.width=viewWidth;
			panelMask.height=viewHeight;
			vScrollBar.visible=(viewHeight<contentHeight);
			if (vScrollBar.visible) {
				vScrollBar.barLength=Math.round(viewHeight*viewHeight/contentHeight);
				syncBarPercentage();
			}
		}

		function syncBarPercentage(y1:int=1):void {
			if (y1>0) {
				y1=y;
			}
			vScrollBar.percentage=-y1/(height-viewHeight);
		}

	}
}