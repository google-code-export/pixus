// scrollPanel class
// 2009-03-04
// (cc)2007-2009 codeplay
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

		public static const HEAT_SINK_HEIGHT:int=20;

		var viewWidth:int=200;
		var viewHeight:int=200;
		var vScrollBar:scrollBar=null;

		var panelBgContainer:Sprite=new Sprite();
		var panelMask:Sprite=new Sprite();
		var panelBg:Sprite=new Sprite();
		var heatSink:scrollPanelHeatSink=new scrollPanelHeatSink();
		var edge:scrollPanelEdgeLight=new scrollPanelEdgeLight();

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

			// Adding panel bg
			panelBg.graphics.beginFill(0x222222);
			panelBg.graphics.drawRect(0,0,viewWidth,viewHeight);
			panelBg.graphics.endFill();
			panelBg.alpha=.5;
			panelBgContainer.addChild(panelBg);

			// Adding heat sink
			panelBgContainer.addChild(heatSink);
			syncHeatSink();

			// Adding scroll panel bg shade
			panelBgContainer.addChild(new scrollPanelBgShade());

			// Adding bottom bar top edge
			edge.y=viewHeight;
			panelBgContainer.addChild(edge);

			// Adding containers
			parent.addChild(panelBgContainer);
			parent.swapChildren(this,panelBgContainer);

			// Adding scrollbar
			parent.addEventListener(customEvent.RESIZE,handleResize);
			parent.addEventListener(customEvent.CONTENT_RESIZED,handleResize);
			parent.addEventListener(customEvent.SCROLLING,handleScroll);
			parent.addEventListener(customEvent.SCROLLED,handleScroll);
			vScrollBar=new scrollBar({x:viewWidth-scrollBar.MINIMAL_WIDTH});
			parent.addChild(vScrollBar);
		}

		function dispose(event:Event):void {
			parent.removeChild(panelMask);
			parent.removeChild(vScrollBar);
			parent.removeChild(panelBgContainer);
		}

		function handleScroll(event:customEvent):void {
			switch (event.type) {
				case customEvent.SCROLLING :
					y=Math.round((viewHeight-contentHeight)*event.data.percentage);
					syncHeatSink();
					break;
				case customEvent.SCROLLED :
					y=Math.round((viewHeight-contentHeight)*event.data.percentage);
					if (snapping) {
						var y1:int=Math.round(y/scrollDelta)*scrollDelta;
						Tweener.addTween(this,{y:y1,time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic',onUpdate:syncHeatSink});
						syncBarPercentage(y1);
					} else
						syncHeatSink();
					break;
			}
		}

		function handleWheel(event:MouseEvent):void {
			var y1:int=Math.min(0,Math.max(viewHeight-contentHeight,y+scrollDelta*event.delta));
			Tweener.addTween(this,{y:y1,time:pixusShell.UI_TWEENING_TIME,transition:'easeOutCubic',onUpdate:syncHeatSink});
			syncBarPercentage(y1);
		}

		function get contentHeight():int{
			return height+HEAT_SINK_HEIGHT;
		}

		function handleResize(event:customEvent):void {
			if (event.data!=null) {
				if (event.data.viewWidth!=null)
					viewWidth=event.data.viewWidth;
				if (event.data.viewHeight!=null)
					viewHeight=event.data.viewHeight;
			}
			y=Math.min(Math.max(viewHeight-contentHeight,y),0);
			panelMask.width=panelBg.width=viewWidth;
			panelBg.height=panelMask.height=edge.y=viewHeight;
			vScrollBar.visible=(viewHeight<contentHeight);
			if (vScrollBar.visible) {
				vScrollBar.x=viewWidth-scrollBar.MINIMAL_WIDTH;
				vScrollBar.barLength=Math.round(viewHeight*viewHeight/contentHeight);
				syncBarPercentage();
			}
			syncHeatSink();
		}

		function syncHeatSink(){
			heatSink.themask.width=viewWidth;
			heatSink.y=contentHeight+y-HEAT_SINK_HEIGHT;
			if(viewHeight>heatSink.y){
				heatSink.visible=true;
				heatSink.themask.height=viewHeight-heatSink.y;
			} else
				heatSink.visible=false;
		}

		function syncBarPercentage(y1:int=1):void {
			if (y1>0) {
				y1=y;
			}
			vScrollBar.percentage=-y1/(contentHeight-viewHeight);
		}

	}
}