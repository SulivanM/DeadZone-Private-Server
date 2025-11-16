package thelaststand.app.gui
{
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.AntiAliasType;
   import flash.text.TextLineMetrics;
   import thelaststand.app.display.BodyTextField;
   
   public class Tooltip extends Sprite
   {
      
      private const MIN_TEXT_WIDTH:int = 100;
      
      private const MAX_TEXT_WIDTH:int = 240;
      
      private const PADDING:int = 6;
      
      private const ARROW_SIZE:int = 8;
      
      private var _arrowDir:int;
      
      private var _content:*;
      
      private var _point:Point;
      
      private var _displayAreaExtents:Rectangle;
      
      private var mc_background:Shape;
      
      private var txt_message:BodyTextField;
      
      public function Tooltip()
      {
         super();
         mouseEnabled = mouseChildren = false;
         this.mc_background = new Shape();
         this.mc_background.filters = [new DropShadowFilter(0,0,0,1,5,5,0.3,1,true),new GlowFilter(6905685,1,1.75,1.75,10,1),new DropShadowFilter(1,45,0,1,8,8,0.6,2)];
         addChild(this.mc_background);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
      }
      
      public function setTooltip(param1:*, param2:int, param3:Point, param4:Rectangle = null, param5:int = 0) : void
      {
         var _loc6_:String = null;
         var _loc7_:Boolean = false;
         var _loc8_:String = null;
         if(this._content != null && this._content is DisplayObject && DisplayObject(this._content).parent != null)
         {
            DisplayObject(this._content).parent.removeChild(DisplayObject(this._content));
         }
         this._content = param1 is Function ? param1() : param1;
         if(!(this._content is String) && !(this._content is DisplayObject))
         {
            throw new Error("Tooltip content must be of type String or DisplayObject.");
         }
         this._arrowDir = param2;
         this._point = param3;
         this._displayAreaExtents = param4 || new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
         param5 = param5 <= 0 ? this.MAX_TEXT_WIDTH : param5;
         if(this._content is String)
         {
            _loc6_ = String(this._content);
            if(this.txt_message == null)
            {
               this.txt_message = new BodyTextField({
                  "color":16777215,
                  "size":13,
                  "leading":1,
                  "antiAliasType":AntiAliasType.ADVANCED
               });
            }
            _loc7_ = _loc6_.indexOf("<br/>") > -1 || _loc6_.indexOf("<br>") > -1;
            this.txt_message.multiline = this.txt_message.wordWrap = _loc7_;
            if(_loc7_)
            {
               this.txt_message.width = param5;
            }
            _loc8_ = "<textformat leading=\'-8\'><br/><br/></textformat>";
            _loc6_ = _loc6_.replace(/\<br\/?\>\<br\/?\>/ig,_loc8_);
            this.txt_message.htmlText = _loc6_;
            if(_loc7_)
            {
               this.txt_message.width = this.getLongestLineWidth() + 10;
               if(this.txt_message.width < this.MIN_TEXT_WIDTH)
               {
                  this.txt_message.width = this.MIN_TEXT_WIDTH;
               }
            }
            else if(this.txt_message.width > param5)
            {
               this.txt_message.multiline = this.txt_message.wordWrap = true;
               this.txt_message.width = param5;
            }
            if(!contains(this.txt_message))
            {
               addChild(this.txt_message);
            }
         }
         else
         {
            if(this.txt_message != null && contains(this.txt_message))
            {
               removeChild(this.txt_message);
            }
            addChild(DisplayObject(this._content));
         }
         this.draw(this._point);
      }
      
      private function getLongestLineWidth() : int
      {
         var _loc3_:TextLineMetrics = null;
         var _loc4_:Number = NaN;
         var _loc1_:Number = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.txt_message.numLines)
         {
            _loc3_ = this.txt_message.getLineMetrics(_loc2_);
            _loc4_ = _loc3_.x + _loc3_.width;
            if(_loc4_ > _loc1_)
            {
               _loc1_ = _loc4_;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      private function draw(param1:Point) : void
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:DisplayObject = null;
         var _loc2_:int = this._content is String ? int(this.txt_message.width) : int(DisplayObject(this._content).width);
         var _loc3_:int = this._content is String ? int(this.txt_message.height) : int(DisplayObject(this._content).height);
         var _loc4_:int = 3;
         var _loc5_:int = _loc2_ + this.PADDING * 2;
         var _loc6_:int = _loc3_ + this.PADDING * 2;
         var _loc9_:int = _loc5_ * 0.5;
         var _loc10_:int = _loc6_ * 0.5;
         if(this._arrowDir == TooltipDirection.DIRECTION_UP || this._arrowDir == TooltipDirection.DIRECTION_DOWN)
         {
            _loc11_ = this._displayAreaExtents.left + (10 + _loc2_ * 0.5);
            _loc12_ = this._displayAreaExtents.right - (10 + _loc2_ * 0.5);
            if(param1.x < _loc11_)
            {
               _loc17_ = param1.x - _loc11_;
               param1.x = _loc11_;
               _loc9_ += _loc17_;
            }
            else if(param1.x > _loc12_)
            {
               _loc17_ = param1.x - _loc12_;
               param1.x = _loc12_;
               _loc9_ += _loc17_;
            }
            _loc15_ = this.ARROW_SIZE + 4;
            if(_loc9_ < _loc15_)
            {
               _loc9_ = _loc15_;
            }
            else if(_loc9_ > _loc5_ - _loc15_)
            {
               _loc9_ = _loc5_ - _loc15_;
            }
         }
         else if(this._arrowDir == TooltipDirection.DIRECTION_LEFT || this._arrowDir == TooltipDirection.DIRECTION_RIGHT)
         {
            _loc13_ = this._displayAreaExtents.top + (10 + _loc3_ * 0.5);
            _loc14_ = this._displayAreaExtents.bottom - (10 + _loc3_ * 0.5);
            if(param1.y < _loc13_)
            {
               _loc18_ = param1.y - _loc13_;
               param1.y = _loc13_;
               _loc10_ += _loc18_;
            }
            else if(param1.y > _loc14_)
            {
               _loc18_ = param1.y - _loc14_;
               param1.y = _loc14_;
               _loc10_ += _loc18_;
            }
            _loc15_ = this.ARROW_SIZE + 4;
            if(_loc10_ < _loc15_)
            {
               _loc10_ = _loc15_;
            }
            else if(_loc10_ > _loc6_ - _loc15_)
            {
               _loc10_ = _loc6_ - _loc15_;
            }
         }
         var _loc16_:Graphics = this.mc_background.graphics;
         _loc16_.clear();
         _loc16_.beginFill(1776411);
         switch(this._arrowDir)
         {
            case TooltipDirection.DIRECTION_UP:
               _loc16_.drawRoundRect(0,this.ARROW_SIZE,_loc5_,_loc6_,_loc4_,_loc4_);
               _loc16_.moveTo(_loc9_,0);
               _loc16_.lineTo(_loc9_ - this.ARROW_SIZE,this.ARROW_SIZE);
               _loc16_.lineTo(_loc9_ + this.ARROW_SIZE,this.ARROW_SIZE);
               _loc16_.lineTo(_loc9_,0);
               _loc16_.endFill();
               this.mc_background.x = -int(this.mc_background.width * 0.5);
               this.mc_background.y = 0;
               _loc7_ = this.mc_background.x + this.PADDING;
               _loc8_ = this.mc_background.y + this.ARROW_SIZE + this.PADDING;
               break;
            case TooltipDirection.DIRECTION_DOWN:
               _loc16_.drawRoundRect(0,0,_loc5_,_loc6_,_loc4_,_loc4_);
               _loc16_.moveTo(_loc9_,_loc6_ + this.ARROW_SIZE);
               _loc16_.lineTo(_loc9_ - this.ARROW_SIZE,_loc6_);
               _loc16_.lineTo(_loc9_ + this.ARROW_SIZE,_loc6_);
               _loc16_.lineTo(_loc9_,_loc6_ + this.ARROW_SIZE);
               _loc16_.endFill();
               this.mc_background.x = -int(this.mc_background.width * 0.5);
               this.mc_background.y = -int(this.mc_background.height);
               _loc7_ = this.mc_background.x + this.PADDING;
               _loc8_ = this.mc_background.y + this.PADDING;
               break;
            case TooltipDirection.DIRECTION_LEFT:
               _loc16_.drawRoundRect(this.ARROW_SIZE,0,_loc5_,_loc6_,_loc4_,_loc4_);
               _loc16_.moveTo(0,_loc10_);
               _loc16_.lineTo(this.ARROW_SIZE,_loc10_ - this.ARROW_SIZE);
               _loc16_.lineTo(this.ARROW_SIZE,_loc10_ + this.ARROW_SIZE);
               _loc16_.lineTo(0,_loc10_);
               _loc16_.endFill();
               this.mc_background.x = 0;
               this.mc_background.y = -int(this.mc_background.height * 0.5);
               _loc7_ = this.mc_background.x + this.ARROW_SIZE + this.PADDING;
               _loc8_ = this.mc_background.y + this.PADDING;
               break;
            case TooltipDirection.DIRECTION_RIGHT:
               _loc16_.drawRoundRect(0,0,_loc5_,_loc6_,_loc4_,_loc4_);
               _loc16_.moveTo(_loc5_ + this.ARROW_SIZE,_loc10_);
               _loc16_.lineTo(_loc5_,_loc10_ - this.ARROW_SIZE);
               _loc16_.lineTo(_loc5_,_loc10_ + this.ARROW_SIZE);
               _loc16_.lineTo(_loc5_ + this.ARROW_SIZE,_loc10_);
               _loc16_.endFill();
               this.mc_background.x = -int(this.mc_background.width);
               this.mc_background.y = -int(this.mc_background.height * 0.5);
               _loc7_ = this.mc_background.x + this.PADDING;
               _loc8_ = this.mc_background.y + this.PADDING;
         }
         if(this._content is String)
         {
            this.txt_message.x = _loc7_;
            this.txt_message.y = _loc8_;
         }
         else
         {
            _loc19_ = DisplayObject(this._content);
            _loc19_.x = _loc7_;
            _loc19_.y = _loc8_;
         }
         x = int(param1.x);
         y = int(param1.y);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         if(this._content is DisplayObject && this._point != null)
         {
            this.draw(this._point);
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
   }
}

