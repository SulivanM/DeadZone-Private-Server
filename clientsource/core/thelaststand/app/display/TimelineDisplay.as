package thelaststand.app.display
{
   import com.greensock.TweenMax;
   import com.greensock.easing.Cubic;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.TimerEvent;
   import flash.geom.Matrix;
   import flash.utils.Timer;
   import thelaststand.common.lang.Language;
   
   public class TimelineDisplay extends Sprite
   {
      
      private static var _items:Vector.<TimelineItem>;
      
      private var _index:int = 0;
      
      private var _spacing:int = 20;
      
      private var _slideTime:Number = 2;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _timer:Timer;
      
      private var _visited:Array;
      
      private var mc_mask:Shape;
      
      private var mc_items:Sprite;
      
      private var mc_highlight:Shape;
      
      public function TimelineDisplay()
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:TimelineItem = null;
         var _loc5_:int = 0;
         var _loc6_:XML = null;
         super();
         this.mc_items = new Sprite();
         addChild(this.mc_items);
         this.mc_mask = new Shape();
         addChild(this.mc_mask);
         this.mc_items.mask = this.mc_mask;
         this.mc_items.cacheAsBitmap = this.mc_mask.cacheAsBitmap = true;
         var _loc1_:Matrix = new Matrix();
         _loc1_.createGradientBox(560,60);
         this.mc_highlight = new Shape();
         this.mc_highlight.graphics.beginGradientFill("linear",[16777215,16777215,16777215,16777215],[0,0.08,0.08,0],[0,50,205,255],_loc1_);
         this.mc_highlight.graphics.drawRect(0,0,560,80);
         this.mc_highlight.graphics.endFill();
         this.mc_highlight.cacheAsBitmap = true;
         addChild(this.mc_highlight);
         if(_items == null)
         {
            _items = new Vector.<TimelineItem>();
            for each(_loc6_ in Language.getInstance().xml.data.timeline.item)
            {
               _loc4_ = new TimelineItem();
               _loc4_.dayNum = int(_loc6_.@day.toString());
               _loc4_.textBody = _loc6_.toString();
               _items.push(_loc4_);
            }
         }
         _loc5_ = 0;
         _loc2_ = 0;
         _loc3_ = int(_items.length);
         while(_loc2_ < _loc3_)
         {
            _loc4_ = _items[_loc2_];
            TweenMax.killTweensOf(_loc4_);
            _loc4_.y = _loc5_;
            _loc4_.scaleX = _loc4_.scaleY = 0.5;
            _loc4_.txt_body.visible = false;
            _loc4_.txt_body.alpha = 0;
            _loc5_ += int(_loc4_.height + this._spacing);
            this.mc_items.addChild(_loc4_);
            _loc2_++;
         }
         this._timer = new Timer(10000);
         this._timer.addEventListener(TimerEvent.TIMER,this.onTimerTick,false,0,true);
      }
      
      public function dispose() : void
      {
         var _loc3_:TimelineItem = null;
         if(parent)
         {
            parent.removeChild(this);
         }
         var _loc1_:int = 0;
         var _loc2_:int = int(_items.length);
         while(_loc1_ < _loc2_)
         {
            _loc3_ = _items[_loc1_];
            if(_loc3_.parent != null)
            {
               _loc3_.parent.removeChild(_loc3_);
            }
            TweenMax.killTweensOf(_loc3_);
            TweenMax.killDelayedCallsTo(_loc3_.type);
            _loc1_++;
         }
         this._timer.removeEventListener(TimerEvent.TIMER,this.onTimerTick);
         this._timer.stop();
         this._timer = null;
      }
      
      public function start() : void
      {
         this._timer.start();
         this._visited = [];
         this.gotoRandomItem();
      }
      
      public function stop() : void
      {
         this._timer.stop();
      }
      
      public function gotoRandomItem() : void
      {
         if(this._visited.length == _items.length)
         {
            this._visited = [];
         }
         var _loc1_:int = int(Math.random() * _items.length);
         while(this._visited.indexOf(_loc1_) > -1)
         {
            _loc1_ = int(Math.random() * _items.length);
         }
         this._visited.push(_loc1_);
         this.gotoItem(_loc1_);
      }
      
      public function gotoItem(param1:int) : void
      {
         var _loc6_:TimelineItem = null;
         var _loc7_:int = 0;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 >= _items.length)
         {
            param1 = int(_items.length - 1);
         }
         var _loc2_:TimelineItem = _items[param1];
         var _loc3_:TimelineItem = _items[this._index];
         if(_loc2_ == _loc3_)
         {
            return;
         }
         _loc3_.stop();
         TweenMax.killDelayedCallsTo(_loc3_.type);
         TweenMax.to(_loc3_.txt_body,0.15,{
            "autoAlpha":0,
            "overwrite":true
         });
         this._index = param1;
         var _loc4_:int = int(this.mc_highlight.y + this.mc_highlight.height * 0.5);
         var _loc5_:int = 0;
         while(_loc5_ < _items.length)
         {
            _loc6_ = _items[_loc5_];
            _loc7_ = this._index - _loc5_;
            _loc8_ = _loc5_ == this._index ? 1 : 0.5;
            _loc9_ = _loc6_.height * (1 / _loc6_.scaleX);
            _loc10_ = int(_loc4_ - _loc7_ * (_loc9_ + this._spacing));
            TweenMax.killTweensOf(_loc6_);
            TweenMax.to(_loc6_,this._slideTime,{
               "y":_loc10_,
               "overwrite":true,
               "ease":Cubic.easeInOut
            });
            if(_loc5_ == this._index)
            {
               _loc6_.txt_body.visible = true;
               TweenMax.to(_loc6_,this._slideTime * 0.5,{
                  "delay":this._slideTime * 0.6,
                  "scaleX":_loc8_,
                  "scaleY":_loc8_,
                  "ease":Cubic.easeInOut
               });
               _loc6_.txt_body.text = "";
               _loc6_.txt_body.alpha = 1;
               _loc6_.txt_body.visible = true;
               TweenMax.delayedCall(this._slideTime * 1.1,_loc6_.type);
            }
            else
            {
               TweenMax.to(_loc6_,this._slideTime * 0.5,{
                  "scaleX":_loc8_,
                  "scaleY":_loc8_,
                  "ease":Cubic.easeInOut
               });
            }
            _loc5_++;
         }
      }
      
      public function setSize(param1:int, param2:int) : void
      {
         this._width = param1;
         this._height = param2;
         scaleX = scaleY = 1;
         var _loc3_:Matrix = new Matrix();
         _loc3_.createGradientBox(this._width,this._height,Math.PI * 0.5);
         this.mc_mask.graphics.clear();
         this.mc_mask.graphics.beginGradientFill("linear",[0,0,0,0],[0,1,1,0],[0,100,155,255],_loc3_);
         this.mc_mask.graphics.drawRect(0,0,this._width,this._height);
         this.mc_mask.graphics.endFill();
         this.mc_highlight.x = int((this._width - this.mc_highlight.width) * 0.5);
         this.mc_highlight.y = int((this._height - this.mc_highlight.height) * 0.5);
         this.mc_items.x = int(this.mc_highlight.x + 20);
         this.mc_items.y = 0;
         this.mc_items.cacheAsBitmap = this.mc_mask.cacheAsBitmap = true;
      }
      
      private function onTimerTick(param1:TimerEvent) : void
      {
         this.gotoRandomItem();
      }
   }
}

import com.exileetiquette.utils.NumberFormatter;
import flash.display.Sprite;
import flash.text.AntiAliasType;
import thelaststand.common.lang.Language;

class TimelineItem extends Sprite
{
   
   private var _dayNum:int;
   
   private var _textBody:String;
   
   private var _typer:TextFieldTyper;
   
   public var txt_day:TitleTextField;
   
   public var txt_body:BodyTextField;
   
   public function TimelineItem()
   {
      super();
      this.txt_day = new TitleTextField({
         "color":10497808,
         "size":50,
         "filters":[Effects.ICON_SHADOW]
      });
      addChild(this.txt_day);
      this.txt_body = new BodyTextField({
         "color":10855845,
         "size":17,
         "leading":-2,
         "multiline":true,
         "width":400,
         "antiAliasType":AntiAliasType.ADVANCED,
         "filters":[Effects.ICON_SHADOW]
      });
      addChild(this.txt_body);
      this._typer = new TextFieldTyper(this.txt_body);
   }
   
   public function type() : void
   {
      this._typer.type(this._textBody,80);
   }
   
   public function stop() : void
   {
      this._typer.pause();
   }
   
   public function get dayNum() : int
   {
      return this._dayNum;
   }
   
   public function set dayNum(param1:int) : void
   {
      this._dayNum = param1;
      this.txt_day.text = Language.getInstance().getString("timeline_day",NumberFormatter.addLeadingZero(this._dayNum));
      this.txt_day.y = -int(this.txt_day.height * 0.5);
   }
   
   public function get textBody() : String
   {
      return this._textBody;
   }
   
   public function set textBody(param1:String) : void
   {
      this._textBody = param1;
      this.txt_body.text = this._textBody;
      this.txt_body.x = int(this.txt_day.x + this.txt_day.width + 10);
      this.txt_body.y = int(this.txt_day.y + (this.txt_day.height - this.txt_body.height) * 0.5) - 1;
   }
}
