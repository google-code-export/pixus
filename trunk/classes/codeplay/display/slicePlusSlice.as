// slicePlusSlice class
// A Enhancement to 9-Slice
// Controlling single slice of a slicePlus instance
// 2008-06-22
// (cc)2008 codeplay
// By Jam Zhang
// jam@01media.cn

package codeplay.display{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import codeplay.display.slicePlus;

	public class slicePlusSlice extends Sprite {

		const NULL_EVENT:Event=new Event('');

		var bdOriginal:BitmapData;
		var bmp:Bitmap;
		var xml:XML;
		var p:slicePlus;
		var m:Sprite=new Sprite();
		var minw:int=0;
		var minh:int=0;
		var currentw:int=0;
		var currenth:int=0;
		var offsetx:int=0;
		var offsety:int=0;

		public function slicePlusSlice(bd:BitmapData, data:XML, sp:slicePlus):void {
			bdOriginal=bd;
			p=sp;
			xml=data;
			offsetx=int(xml.@offsetx);
			offsety=int(xml.@offsety);
			minw=int(xml.@minw);
			minh=int(xml.@minh);
			var newBitmapData:BitmapData=new BitmapData(xml.@w,xml.@h);
			newBitmapData.copyPixels(bd,new Rectangle(xml.@x,xml.@y,xml.@w,xml.@h),new Point(0,0));
			bmp=new Bitmap(newBitmapData);
			addChild(bmp);
			addEventListener(Event.ADDED_TO_STAGE,init);
		}

		function init(event:Event) {
			x=xml.@x;
			y=xml.@y;
			var s:String=String(xml.@position).toLowerCase();
			switch (s) {
				case 'tl' :// Top Left
				case 'lt' :
					p.TL=this;
					addMask();
					x=offsetx;
					y=offsety;
					parent.addEventListener(Event.RESIZE,syncTopLeft);
					if (minw==0) {
						minw=int(xml.@w)+offsetx;
					}
					if (minh==0) {
						minh=int(xml.@h)+offsety;
					}
					p.minWidthTop+=minw;
					p.minHeightLeft+=minh;
					break;
				case 'tc' :// Top Center
				case 'ct' :
					p.TC=this;
					minw=0;
					if (minh==0) {
						minh=int(xml.@h)+offsety;
					}
					x=p.sliceWidth+offsetx;
					y=offsety;
					parent.addEventListener(Event.RESIZE,syncTopCenter,false,-10);
					break;
				case 'tr' :// Top Right
				case 'rt' :
					p.TR=this;
					addMask();
					if (minw==0) {
						minw=Math.max(0,-offsetx);
					}
					if (minh==-0) {
						minh=int(xml.@h)+offsety;
					}
					x=p.sliceWidth+offsetx;
					y=offsety;
					parent.addEventListener(Event.RESIZE,syncTopRight);
					currentw=-offsetx;
					p.minWidthTop+=minw;
					p.minHeightRight+=minh;
					break;
				case 'bl' :// Bottom Left
				case 'lb' :
					p.BL=this;
					addMask();
					x=offsetx;
					y=p.sliceHeight+offsety;
					parent.addEventListener(Event.RESIZE,syncBottomLeft);
					if (minw==0) {
						minw=xml.@w+offsetx;
					}
					if (minh==0) {
						minh=Math.max(0,-offsety);
					}
					p.minWidthBottom+=minw;
					p.minHeightLeft+=minh;
					break;
				case 'bc' :// Bottom Center
				case 'cb' :
					p.BC=this;
					minw=0;
					y=p.sliceHeight+offsety;
					parent.addEventListener(Event.RESIZE,syncBottomCenter,false,-10);
					break;
				case 'br' :// Bottom Right
				case 'rb' :
					p.BR=this;
					addMask();
					if (minw==0) {
						minw=Math.max(0,-offsetx);
					}
					if (minh==0) {
						minh=Math.max(0,-offsety);
					}
					x=p.sliceWidth+offsetx;
					y=p.sliceHeight+offsety;
					parent.addEventListener(Event.RESIZE,syncBottomRight);
					currentw=-offsetx;
					break;
					p.minWidthBottom+=minw;
					p.minHeightRight+=minh;
				case 'l' :// Middle Left
				case 'ml' :
					p.L=this;
					minh=0;
					x=offsetx;
//					syncMiddleLeft();
					parent.addEventListener(Event.RESIZE,syncMiddleLeft,false,-10);
					break;
				case 'r' :// Middle Right
				case 'mr' :
					p.R=this;
					minh=0;
					x=p.sliceWidth+offsetx;
//					syncMiddleRight();
					parent.addEventListener(Event.RESIZE,syncMiddleRight,false,-10);
					break;
			}
		}

		function addMask():void {
			m.graphics.beginFill(0xFFFFFF);
			m.graphics.drawRect(0,0,xml.@w,xml.@h);
			m.graphics.endFill();
			addChild(m);
			bmp.mask=m;
		}

		function syncTopLeft(event:Event=null) {
			m.width=Math.min(Math.max(minw,p.sliceWidth-p.TR.currentw)-offsetx,int(xml.@w));
			m.height=Math.min(Math.max(minh,p.sliceHeight-p.TR.currenth)-offsety,int(xml.@h));
			currentw=m.width+offsetx;
			currenth=m.height+offsety;
		}

		function syncTopCenter(event:Event=null) {
			if (p.TR.x-p.TL.currentw>0) {
				x=p.TL.currentw;
				width=p.TR.x-p.TL.currentw;
				visible=true;
			} else {
				visible=false;
			}
		}

		function syncTopRight(event:Event=null) {
			x=p.sliceWidth+offsetx;
			if (p.sliceWidth+offsetx<p.TL.currentw) {// Horizontally Cropped
				m.x=p.TL.currentw-(p.sliceWidth+offsetx);
				currentw=-offsetx-m.x;
			} else { // Full Width
				m.x=0;
				currentw=offsetx;
			}
			m.height=Math.min(Math.max(minh,p.sliceHeight-p.TR.currenth)-offsety,int(xml.@h));
			currenth=m.height+offsety;
		}

		function syncMiddleLeft(event:Event=null) {
			if (p.BL.y-p.TL.currenth>0) {
				y=p.TL.currenth;
				height=p.BL.y-p.TL.currenth;
				visible=true;
			} else {
				visible=false;
			}
		}

		function syncMiddleRight(event:Event=null) {
			x=p.sliceWidth+offsetx;
			if (p.BR.y-p.TR.currenth>0) {
				y=p.TR.currenth;
				height=p.BR.y-p.TR.currenth;
				visible=true;
			} else {
				visible=false;
			}
		}

		function syncBottomLeft(event:Event=null) {
			m.width=Math.min(Math.max(minw,p.sliceWidth-p.BR.currentw)-offsetx,int(xml.@w));
			y=p.sliceHeight+offsety;
			currentw=m.width+offsetx;
		}

		function syncBottomCenter(event:Event=null) {
			if (p.BR.x-p.BL.currentw>0) {
				x=p.BL.currentw;
				y=p.sliceHeight+offsety;
				width=p.BR.x-p.BL.currentw;
				visible=true;
			} else {
				visible=false;
			}
		}

		function syncBottomRight(event:Event=null) {
			x=p.sliceWidth+offsetx;
			if (p.sliceWidth+offsetx<p.BL.currentw) {// Horizontally Cropped
				m.x=p.BL.currentw-(p.sliceWidth+offsetx);
				currentw=-offsetx-m.x;
			} else { // Full Width
				m.x=0;
				currentw=offsetx;
			}
			y=p.sliceHeight+offsety;
			currenth=m.height+offsety;
		}

	}
}