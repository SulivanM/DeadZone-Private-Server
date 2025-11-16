package thelaststand.app.game.gui.alliance
{
   import com.exileetiquette.math.MathUtils;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.common.resources.ResourceManager;
   
   public class UIAllianceIndividualRewardsProgressBar extends Sprite
   {
      
      private var _width:Number = 450;
      
      private var _fadedValue:Number = 0;
      
      private var _solidValue:Number = 0;
      
      private var _barBG:Shape;
      
      private var _fadedFill:Shape;
      
      private var _solidFill:Shape;
      
      private var _markerBG:Shape;
      
      private var allianceXML:XML;
      
      private var highestScore:int = 0;
      
      private var markers:Vector.<UIAllianceIndividualRewardTierMarker>;
      
      private var tooltip:UIAllianceIndividualRewardTooltip;
      
      public function UIAllianceIndividualRewardsProgressBar()
      {
         var list:XMLList;
         var g:Graphics = null;
         var node:XML = null;
         var m:UIAllianceIndividualRewardTierMarker = null;
         super();
         this.allianceXML = ResourceManager.getInstance().get("xml/alliances.xml");
         this._barBG = new Shape();
         addChild(this._barBG);
         this._fadedFill = new Shape();
         this._fadedFill.x = this._fadedFill.y = 2;
         g = this._fadedFill.graphics;
         g.beginFill(7693960,1);
         g.drawRect(0,0,16,16);
         addChild(this._fadedFill);
         this._solidFill = new Shape();
         this._solidFill.x = this._solidFill.y = 2;
         g = this._solidFill.graphics;
         g.beginFill(10585016,1);
         g.drawRect(0,0,16,16);
         addChild(this._solidFill);
         this._markerBG = new Shape();
         this._markerBG.y = 23;
         addChild(this._markerBG);
         this.tooltip = new UIAllianceIndividualRewardTooltip();
         this.markers = new Vector.<UIAllianceIndividualRewardTierMarker>();
         list = this.allianceXML.individualTiers.tier;
         for each(node in list)
         {
            m = new UIAllianceIndividualRewardTierMarker(node);
            m.y = -4;
            this.markers.push(m);
            addChild(m);
            if(m.value > this.highestScore)
            {
               this.highestScore = m.value;
            }
            m.addEventListener(MouseEvent.ROLL_OVER,this.onMarkerOver,false,100,true);
            TooltipManager.getInstance().add(m,this.tooltip,new Point(0,-2),TooltipDirection.DIRECTION_DOWN);
         }
         this.markers.sort(function(param1:UIAllianceIndividualRewardTierMarker, param2:UIAllianceIndividualRewardTierMarker):Number
         {
            return param1.value - param2.value;
         });
         this.rebuild();
      }
      
      public function dispose() : void
      {
         var _loc1_:UIAllianceIndividualRewardTierMarker = null;
         for each(_loc1_ in this.markers)
         {
            TooltipManager.getInstance().remove(_loc1_);
            _loc1_.removeEventListener(MouseEvent.ROLL_OVER,this.onMarkerOver);
            _loc1_.dispose();
         }
         this.tooltip.dispose();
      }
      
      private function rebuild() : void
      {
         var _loc3_:UIAllianceIndividualRewardTierMarker = null;
         var _loc1_:Graphics = this._barBG.graphics;
         _loc1_.clear();
         _loc1_.beginFill(3221815,1);
         _loc1_.drawRect(-1,-1,this._width + 2,22);
         _loc1_.endFill();
         _loc1_.beginFill(0,1);
         _loc1_.drawRect(0,0,this._width,20);
         _loc1_.endFill();
         _loc1_ = this._markerBG.graphics;
         _loc1_.clear();
         _loc1_.beginFill(0,0.5);
         _loc1_.drawRect(0,0,this._width,17);
         _loc1_.endFill();
         var _loc2_:Number = 0;
         for each(_loc3_ in this.markers)
         {
            _loc3_.x = this._width * (_loc3_.value / this.highestScore);
            _loc2_ = _loc3_.x;
         }
         this.FadedValue = this._fadedValue;
         this.SolidValue = this._solidValue;
      }
      
      public function get FadedValue() : Number
      {
         return this._fadedValue;
      }
      
      public function set FadedValue(param1:Number) : void
      {
         this._fadedValue = param1;
         this._fadedFill.width = (this._width - 4) * MathUtils.clamp(this._fadedValue / this.highestScore,0,1);
      }
      
      public function get SolidValue() : Number
      {
         return this._solidValue;
      }
      
      public function set SolidValue(param1:Number) : void
      {
         var _loc3_:UIAllianceIndividualRewardTierMarker = null;
         this._solidValue = param1;
         this._solidFill.width = (this._width - 4) * MathUtils.clamp(this._solidValue / this.highestScore,0,1);
         var _loc2_:UIAllianceIndividualRewardTierMarker = null;
         for each(_loc3_ in this.markers)
         {
            if(_loc3_.value <= this._solidValue)
            {
               _loc3_.state = UIAllianceIndividualRewardTierMarker.STATE_ACTIVE_PASSED;
               if(_loc2_ == null || _loc3_.value > _loc2_.value)
               {
                  _loc2_ = _loc3_;
               }
            }
            else
            {
               _loc3_.state = UIAllianceIndividualRewardTierMarker.STATE_INACTIVE;
            }
         }
         if(_loc2_ != null)
         {
            _loc2_.state = UIAllianceIndividualRewardTierMarker.STATE_ACTIVE_CURRENT;
         }
      }
      
      private function onMarkerOver(param1:MouseEvent) : void
      {
         var _loc2_:UIAllianceIndividualRewardTierMarker = UIAllianceIndividualRewardTierMarker(param1.target);
         this.tooltip.populate(_loc2_);
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         this.rebuild();
      }
      
      override public function get height() : Number
      {
         return super.height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

