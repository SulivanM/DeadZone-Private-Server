package thelaststand.app.game.gui.tooltip
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Morale;
   import thelaststand.app.game.gui.compound.UIMoraleDisplay;
   import thelaststand.common.lang.Language;
   
   public class UIMoraleTooltip extends Sprite
   {
      
      private var _morale:Morale;
      
      private var _labels:Vector.<BodyTextField>;
      
      private var _values:Vector.<BodyTextField>;
      
      private var _showTotal:Boolean = true;
      
      public function UIMoraleTooltip()
      {
         super();
         this._labels = new Vector.<BodyTextField>();
         this._values = new Vector.<BodyTextField>();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      public function dispose() : void
      {
         var _loc1_:BodyTextField = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this._morale = null;
         for each(_loc1_ in this._labels)
         {
            _loc1_.dispose();
         }
         this._labels = null;
         for each(_loc1_ in this._values)
         {
            _loc1_.dispose();
         }
         this._values = null;
      }
      
      private function update() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:BodyTextField = null;
         var _loc7_:int = 0;
         var _loc8_:uint = 0;
         var _loc9_:BodyTextField = null;
         var _loc10_:String = null;
         var _loc11_:Number = NaN;
         var _loc12_:BodyTextField = null;
         var _loc13_:BodyTextField = null;
         _loc5_ = numChildren - 1;
         while(_loc5_ >= 0)
         {
            removeChild(getChildAt(_loc5_));
            _loc5_--;
         }
         this._labels.length = 0;
         this._values.length = 0;
         if(this._morale == null || stage == null)
         {
            return;
         }
         var _loc3_:Language = Language.getInstance();
         if(this._showTotal)
         {
            _loc7_ = this._morale.getRoundedTotal();
            _loc8_ = uint(UIMoraleDisplay.COLORS[UIMoraleDisplay.getMoraleDisplayIndex(_loc7_)]);
            _loc9_ = new BodyTextField({
               "bold":true,
               "color":_loc8_,
               "size":13,
               "antiAliasType":AntiAliasType.ADVANCED
            });
            _loc9_.text = _loc3_.getString("tooltip.morale_srv",(_loc7_ > 0 ? "+" : "") + _loc7_.toString());
            addChild(_loc9_);
            _loc1_ += int(_loc9_.height) + 10;
         }
         var _loc4_:Vector.<String> = this._morale.effects;
         _loc4_.sort(this.effectSort);
         _loc5_ = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc10_ = _loc4_[_loc5_];
            _loc11_ = Math.round(this._morale.getEffect(_loc10_));
            if(_loc11_ != 0)
            {
               _loc8_ = _loc11_ < 0 ? Effects.COLOR_WARNING : Effects.COLOR_GOOD;
               _loc12_ = new BodyTextField({
                  "color":_loc8_,
                  "bold":true,
                  "size":13,
                  "antiAliasType":AntiAliasType.ADVANCED
               });
               _loc12_.text = String((_loc11_ > 0 ? "+" : "") + _loc11_);
               _loc12_.y = _loc1_;
               addChild(_loc12_);
               _loc13_ = new BodyTextField({
                  "color":_loc8_,
                  "size":13
               });
               _loc13_.text = _loc3_.getString("morale_effects." + _loc10_);
               _loc13_.y = _loc1_;
               addChild(_loc13_);
               if(_loc12_.width > _loc2_)
               {
                  _loc2_ = _loc12_.width;
               }
               this._values.push(_loc12_);
               this._labels.push(_loc13_);
               _loc1_ += int(_loc13_.height);
            }
            _loc5_++;
         }
         for each(_loc6_ in this._labels)
         {
            _loc6_.x = _loc2_ + 2;
         }
         for each(_loc6_ in this._values)
         {
            _loc6_.x = _loc2_ - _loc6_.width;
         }
      }
      
      private function effectSort(param1:String, param2:String) : int
      {
         return param1.toLowerCase().localeCompare(param2.toLowerCase());
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.update();
      }
      
      public function get morale() : Morale
      {
         return this._morale;
      }
      
      public function set morale(param1:Morale) : void
      {
         this._morale = param1;
         this.update();
      }
      
      public function get showTotal() : Boolean
      {
         return this._showTotal;
      }
      
      public function set showTotal(param1:Boolean) : void
      {
         this._showTotal = param1;
         this.update();
      }
   }
}

