// scrollPanel class
// 2009-03-04
// (cc)2007-2009 codeplay
// By Jam Zhang
// jam@01media.cn

// Construction
//

package codeplay.ui.minimal{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import codeplay.ui.aqua.scrollBar;
	import codeplay.event.customEvent;
	import codeplay.utils.sharedVariables;
	import caurina.transitions.Tweener;

	public class scrollPanel extends Sprite {

		var viewWidth:int=300;
		var viewHeight:int=300;
		var vScrollBar:scrollBar=null;
		var hScrollBar:scrollBar=null;

		var panelMask:Sprite=new Sprite();

		public var scrollDelta:int=10;
		public var snapping:Boolean=false;
		public var stageWheelResponding:Boolean=false;

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
				if (data.stageWheelResponding!=undefined) {
					stageWheelResponding=data.stageWheelResponding;
				}
			}
			addEventListener(Event.ADDED_TO_STAGE,init);
			addEventListener(Event.REMOVED_FROM_STAGE,dispose);
		}

		function init(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE,init);
			addEventListener(MouseEvent.MOUSE_WHEEL,handleWheel);
			if(stageWheelResponding)
				stage.addEventListener(MouseEvent.MOUSE_WHEEL,handleWheel);

			// Adding mask
			panelMask.graphics.beginFill(0x000000);
			panelMask.graphics.drawRect(0,0,viewWidth-2,viewHeight);
			panelMask.graphics.endFill();
			panelMask.x=1;
			parent.addChild(panelMask);
			mask=panelMask;

			// Adding scrollbars
			parent.addEventListener(customEvent.RESIZE,handleResize);
			parent.addEventListener(customEvent.CONTENT_RESIZED,handleResize);
			parent.addEventListener(customEvent.SCROLLING,handleScroll);
			parent.addEventListener(customEvent.SCROLLED,handleScroll);
			vScrollBar=new scrollBar({x:viewWidth-scrollBar.MINIMAL_WIDTH});
			hScrollBar=new scrollBar({y:viewHeight-scrollBar.MINIMAL_HEIGHT,vertical:false});
			parent.addChild(vScrollBar);
			parent.addChild(hScrollBar);
		}

		function dispose(event:Event):void {
			parent.removeChild(panelMask);
			parent.removeChild(vScrollBar);
			if(stageWheelResponding)
				stage.removeEventListener(MouseEvent.MOUSE_WHEEL,handleWheel);
		}

		function get contentWidth():int{
			return width;
		}

		function get contentHeight():int{
			return height;
		}

		function handleScroll(event:customEvent):void {
			switch (event.type) {
				case customEvent.SCROLLING :
					// Dispatched by scrollBar
					if(event.data.vertical)
						y=Math.round((viewHeight-contentHeight)*event.data.percentage);
					else
						x=Math.round((viewWidth-contentWidth)*event.data.percentage);
					break;
				case customEvent.SCROLLED :
					// Dispatched by scrollBar
					if(event.data.vertical){
						y=Math.round((viewHeight-contentHeight)*event.data.percentage);
						if (snapping) {
							var y1:int=Math.round(y/scrollDelta)*scrollDelta;
							Tweener.addTween(this,{y:y1,time:sharedVariables.UI_TWEENING_TIME,transition:'easeOutCubic'});
							vScrollBar.percentage=-y1/(contentHeight-viewHeight);
						}
					} else {
						x=Math.round((viewWidth-contentWidth)*event.data.percentage);
						if (snapping) {
							var x1:int=Math.round(x/scrollDelta)*scrollDelta;
							Tweener.addTween(this,{x:x1,time:sharedVariables.UI_TWEENING_TIME,transition:'easeOutCubic'});
							hScrollBar.percentage=-x1/(contentWidth-viewWidth);
						}
					}
					break;
			}
		}

		function handleWheel(event:MouseEvent):void {
			var y1:int=Math.min(0,Math.max(viewHeight-contentHeight,y+scrollDelta*event.delta));
			Tweener.addTween(this,{y:y1,time:sharedVariables.UI_TWEENING_TIME,transition:'easeOutCubic'});
			vScrollBar.percentage=-y1/(contentHeight-viewHeight);
		}

		function handleResize(event:customEvent):void {
			if (event.data!=null) {
				resizeView(event.data.viewWidth,event.data.viewHeight);
			}
		}

		public function resizeView(w:Object=null, h:Object=null){
			if (w!=null)
				viewWidth=int(w);
			if (h!=null)
				viewHeight=int(h);
			y=Math.min(Math.max(viewHeight-contentHeight,y),0);
			panelMask.width=viewWidth;
			panelMask.height=viewHeight;
			vScrollBar.visible=(viewHeight<contentHeight);
			if (vScrollBar.visible) {
				vScrollBar.x=viewWidth-scrollBar.MINIMAL_WIDTH;
				vScrollBar.barLength=Math.round(viewHeight*viewHeight/contentHeight);
				vScrollBar.railLength=viewHeight;
				vScrollBar.percentage=-y/(contentHeight-viewHeight);
			}
			hScrollBar.visible=(viewWidth<contentWidth);
			if (hScrollBar.visible) {
				hScrollBar.y=viewHeight-scrollBar.MINIMAL_HEIGHT;
				hScrollBar.barLength=Math.round(viewWidth*viewWidth/contentWidth);
				hScrollBar.railLength=viewWidth;
				hScrollBar.percentage=-x/(contentWidth-viewWidth);
			}
		}

	}
}