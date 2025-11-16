package thelaststand.app.game.gui
{
   import com.deadreckoned.threshold.display.Color;
   import com.exileetiquette.math.MathUtils;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.game.gui.alliance.UIAllianceIndividualRewardTierMarker;
   import thelaststand.app.game.gui.tooltip.UIRewardTierTooltip;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIComponent;
   
   public class UIRewardsProgressBar extends UIComponent
   {
      
      private var _width:Number = 450;
      
      private var _fadedValue:Number = 0;
      
      private var _solidValue:Number = 0;
      
      private var _borderColor:uint = 3221815;
      
      private var _barColor:uint = 10585016;
      
      private var _tiersXML:XMLList;
      
      private var _tierIndex:int = -1;
      
      private var _barBG:Shape;
      
      private var _fadedFill:Shape;
      
      private var _solidFill:Shape;
      
      private var _markerBG:Shape;
      
      private var _highestScore:int = 0;
      
      private var _markers:Vector.<UIAllianceIndividualRewardTierMarker>;
      
      private var _tooltip:UIRewardTierTooltip;
      
      public function UIRewardsProgressBar()
      {
         super();
         this._barBG = new Shape();
         addChild(this._barBG);
         this._markerBG = new Shape();
         addChild(this._markerBG);
         this._fadedFill = new Shape();
         addChild(this._fadedFill);
         this._solidFill = new Shape();
         addChild(this._solidFill);
         this._markers = new Vector.<UIAllianceIndividualRewardTierMarker>();
      }
      
      public function setData(param1:XMLList) : void
      {
         var i:int;
         var currentMarker:UIAllianceIndividualRewardTierMarker = null;
         var node:XML = null;
         var marker:UIAllianceIndividualRewardTierMarker = null;
         var tiers:XMLList = param1;
         this._tiersXML = tiers;
         i = 0;
         while(i < this._markers.length)
         {
            this._markers[i].dispose();
            i++;
         }
         this._markers.length = 0;
         this._highestScore = int.MIN_VALUE;
         for each(node in this._tiersXML)
         {
            marker = new UIAllianceIndividualRewardTierMarker(node);
            marker.y = -4;
            if(marker.value > this._highestScore)
            {
               this._highestScore = marker.value;
               currentMarker = marker;
            }
            marker.addEventListener(MouseEvent.ROLL_OVER,this.onMarkerOver,false,100,true);
            TooltipManager.getInstance().add(marker,this._tooltip,new Point(0,-2),TooltipDirection.DIRECTION_DOWN);
            this._markers.push(marker);
            addChild(marker);
         }
         this._markers.sort(function(param1:UIAllianceIndividualRewardTierMarker, param2:UIAllianceIndividualRewardTierMarker):Number
         {
            return param1.value - param2.value;
         });
         this._tierIndex = currentMarker != null ? int(this._markers.indexOf(currentMarker)) : -1;
         invalidate();
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIAllianceIndividualRewardTierMarker = null;
         for each(_loc1_ in this._markers)
         {
            TooltipManager.getInstance().remove(_loc1_);
            _loc1_.removeEventListener(MouseEvent.ROLL_OVER,this.onMarkerOver);
            _loc1_.dispose();
         }
      }
      
      override protected function draw() : void
      {
         var _loc1_:Graphics = null;
         var _loc3_:UIAllianceIndividualRewardTierMarker = null;
         _loc1_ = this._barBG.graphics;
         _loc1_.clear();
         _loc1_.beginFill(this._borderColor,1);
         _loc1_.drawRect(-1,-1,this._width + 2,22);
         _loc1_.endFill();
         _loc1_.beginFill(0,1);
         _loc1_.drawRect(0,0,this._width,20);
         _loc1_.endFill();
         this._fadedFill.scaleX = this._fadedFill.scaleY = 1;
         this._fadedFill.x = this._fadedFill.y = 2;
         _loc1_ = this._fadedFill.graphics;
         _loc1_.beginFill(new Color(this._barColor).adjustBrightness(0.5).RGB,1);
         _loc1_.drawRect(0,0,16,16);
         this._solidFill.scaleX = this._solidFill.scaleY = 1;
         this._solidFill.x = this._solidFill.y = 2;
         _loc1_ = this._solidFill.graphics;
         _loc1_.beginFill(this._barColor,1);
         _loc1_.drawRect(0,0,16,16);
         this._markerBG.y = 23;
         _loc1_ = this._markerBG.graphics;
         _loc1_.clear();
         _loc1_.beginFill(0,0.5);
         _loc1_.drawRect(0,0,this._width,17);
         _loc1_.endFill();
         var _loc2_:Number = 0;
         for each(_loc3_ in this._markers)
         {
            _loc3_.x = int(this._width * (_loc3_.value / this._highestScore));
            _loc2_ = _loc3_.x;
         }
         this.fadedValue = this._fadedValue;
         this.solidValue = this._solidValue;
      }
      
      private function onMarkerOver(param1:MouseEvent) : void
      {
         var _loc4_:uint = 0;
         var _loc2_:UIAllianceIndividualRewardTierMarker = UIAllianceIndividualRewardTierMarker(param1.target);
         var _loc3_:int = int(this._markers.indexOf(_loc2_));
         if(_loc3_ < this._tierIndex)
         {
            _loc4_ = UIRewardTierTooltip.STATE_PAST;
         }
         else if(_loc3_ == this._tierIndex)
         {
            _loc4_ = UIRewardTierTooltip.STATE_ACTIVE;
         }
         else
         {
            _loc4_ = UIRewardTierTooltip.STATE_FUTURE;
         }
         this._tooltip.populate(_loc2_.data,_loc4_);
      }
      
      public function get fadedValue() : Number
      {
         return this._fadedValue;
      }
      
      public function set fadedValue(param1:Number) : void
      {
         this._fadedValue = param1;
         this._fadedFill.width = (this._width - 4) * MathUtils.clamp(this._fadedValue / this._highestScore,0,1);
      }
      
      public function get solidValue() : Number
      {
         return this._solidValue;
      }
      
      public function set solidValue(param1:Number) : void
      {
         var _loc4_:UIAllianceIndividualRewardTierMarker = null;
         this._solidValue = param1;
         this._solidFill.width = (this._width - 4) * MathUtils.clamp(this._solidValue / this._highestScore,0,1);
         this._tierIndex = -1;
         var _loc2_:UIAllianceIndividualRewardTierMarker = null;
         var _loc3_:int = 0;
         while(_loc3_ < this._markers.length)
         {
            _loc4_ = this._markers[_loc3_];
            if(_loc4_.value <= this._solidValue)
            {
               _loc4_.state = UIAllianceIndividualRewardTierMarker.STATE_ACTIVE_PASSED;
               if(_loc2_ == null || _loc4_.value > _loc2_.value)
               {
                  _loc2_ = _loc4_;
                  this._tierIndex = _loc3_;
               }
            }
            else
            {
               _loc4_.state = UIAllianceIndividualRewardTierMarker.STATE_INACTIVE;
            }
            _loc3_++;
         }
         if(_loc2_ != null)
         {
            _loc2_.state = UIAllianceIndividualRewardTierMarker.STATE_ACTIVE_CURRENT;
         }
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         invalidate();
      }
      
      override public function get height() : Number
      {
         return super.height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      public function get tooltip() : UIRewardTierTooltip
      {
         return this._tooltip;
      }
      
      public function set tooltip(param1:UIRewardTierTooltip) : void
      {
         this._tooltip = param1;
      }
      
      public function get borderColor() : uint
      {
         return this._borderColor;
      }
      
      public function set borderColor(param1:uint) : void
      {
         this._borderColor = param1;
         invalidate();
      }
      
      public function get barColor() : uint
      {
         return this._barColor;
      }
      
      public function set barColor(param1:uint) : void
      {
         this._barColor = param1;
         invalidate();
      }
   }
}

