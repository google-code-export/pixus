// slicePlus class
// A Enhancement to 9-Slice
// 2008-06-17
// (cc)2008 codeplay
// By Jam Zhang
// jam@01media.cn

package codeplay.display{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import codeplay.display.slicePlusSlice;

	public class slicePlus extends Sprite {

		const DEFAULT_WIDTH:int=540;
		const DEFAULT_HEIGHT:int=280;

		var loader:Loader=new Loader();
		var bd:BitmapData;
		var sliceWidth,sliceHeight:int;
		var minWidthTop:int=0;
		var minWidthBottom:int=0;
		var minHeightLeft:int=0;
		var minHeightRight:int=0;
		var TL,TC,TR,L,R,BL,BC,BR:slicePlusSlice;
		var skin:XML;

		public function slicePlus(skinxml:XML, w:int=DEFAULT_WIDTH, h:int=DEFAULT_HEIGHT):void {
			skin=skinxml;
			sliceWidth=w;
			sliceHeight=h;
			addEventListener(Event.ADDED_TO_STAGE,init);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,handleComplete);
			loader.load(new URLRequest(skin.file.@filename));
		}

		function init(event:Event) {
		}

		function handleComplete(event:Event) {
			bd=new BitmapData(loader.width,loader.height,true,0x000000);
			bd.draw(loader);
			for each (var s:XML in skin..slice) {
				addChild(new slicePlusSlice(bd,s,this));
			}
			dispatchEvent(new Event(Event.RESIZE));
			trace('minWidthTop='+minWidthTop+' minWidthBottom='+minWidthBottom+' minHeightLeft='+minHeightLeft+' minHeightRight='+minHeightRight);
		}

		public function get minWidth():int{
			return Math.max(minWidthTop,minWidthBottom);
		}

		public function get minHeight():int{
			return Math.max(minHeightLeft,minHeightRight);
		}

		public function setWidth(w:int):void{
			sliceWidth=Math.max(w,Math.max(TL.minw+TR.minw,BL.minw+BR.minw));
			dispatchEvent(new Event(Event.RESIZE));
		}

		public function setHeight(h:int):void{
			sliceHeight=Math.max(h,Math.max(TL.minh+BL.minh,TR.minh+BR.minh));
			dispatchEvent(new Event(Event.RESIZE));
		}

		public function resize(w:int,h:int):void{
			sliceWidth=Math.max(w,Math.max(TL.minw+TR.minw,BL.minw+BR.minw));
			sliceHeight=Math.max(h,Math.max(TL.minh+BL.minh,TR.minh+BR.minh));
			dispatchEvent(new Event(Event.RESIZE));
		}
	}
}