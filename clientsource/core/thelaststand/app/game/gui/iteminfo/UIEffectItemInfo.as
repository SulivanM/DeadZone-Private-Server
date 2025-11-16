package thelaststand.app.game.gui.iteminfo
{
   import com.deadreckoned.threshold.display.Color;
   import com.exileetiquette.utils.NumberFormatter;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.EffectItem;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemAttributes;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.game.data.effects.Cooldown;
   import thelaststand.app.game.data.effects.CooldownType;
   import thelaststand.app.game.data.effects.Effect;
   import thelaststand.app.game.data.effects.EffectData;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.StringUtils;
   import thelaststand.common.lang.Language;
   
   public class UIEffectItemInfo extends UIGenericItemInfo
   {
      
      private var _effectItem:EffectItem;
      
      private var _effect:Effect;
      
      private var _timer:Timer;
      
      private var txt_effects:BodyTextField;
      
      private var txt_time:BodyTextField;
      
      public function UIEffectItemInfo()
      {
         super();
         this.txt_effects = new BodyTextField({
            "color":16777215,
            "multiline":true,
            "size":14
         });
         this.txt_effects.width = _width;
         addChild(this.txt_effects);
         this.txt_time = new BodyTextField({
            "color":16777215,
            "multiline":true,
            "size":14
         });
         this.txt_time.width = _width;
         this._timer = new Timer(500);
         this._timer.addEventListener(TimerEvent.TIMER,this.onTimerTick,false,0,true);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.txt_effects.dispose();
         this.txt_time.dispose();
         this._effectItem = null;
         this._effect = null;
      }
      
      override public function setItem(param1:Item, param2:SurvivorLoadout = null, param3:Object = null) : void
      {
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:EffectData = null;
         var _loc11_:String = null;
         var _loc12_:XML = null;
         var _loc13_:String = null;
         var _loc14_:Boolean = false;
         var _loc15_:String = null;
         var _loc16_:uint = 0;
         if(!(param1 is EffectItem))
         {
            throw new Error("Item is not EffectItem");
         }
         this._effectItem = EffectItem(param1);
         this._effect = this._effectItem.effect;
         super.setItem(param1,param2);
         txt_desc.htmlText = _lang.getString("effect_desc." + this._effect.type);
         _height = Math.max(_height,int(txt_desc.y + txt_desc.height)) + 10;
         var _loc4_:Array = [];
         if(this._effect.attributes != null)
         {
            _loc7_ = this.getAttributeDescriptions(ItemAttributes.GROUP_SURVIVOR);
            if(_loc7_)
            {
               _loc4_.push(_loc7_);
            }
            _loc8_ = this.getAttributeDescriptions(ItemAttributes.GROUP_WEAPON);
            if(_loc8_)
            {
               _loc4_.push(_loc8_);
            }
            _loc9_ = this.getAttributeDescriptions(ItemAttributes.GROUP_GEAR);
            if(_loc9_)
            {
               _loc4_.push(_loc9_);
            }
         }
         var _loc5_:int = 0;
         var _loc6_:int = this._effect.numEffects;
         while(_loc5_ < _loc6_)
         {
            _loc10_ = this._effect.getEffect(_loc5_);
            if(_loc10_ != null)
            {
               _loc11_ = EffectType.getTypeName(_loc10_.type);
               _loc12_ = _lang.xml.data.effect_type_desc[_loc11_][0];
               if(_loc12_ != null)
               {
                  if(_loc11_ == "EffectGroupLimit")
                  {
                     _loc13_ = _loc12_.pos.toString().replace("%s",_loc10_.value + " x " + _lang.getString("effect_group." + this._effect.group));
                     _loc4_.push("<font color=\'" + Color.colorToHex(Effects.COLOR_GOOD) + "\'>" + _loc13_ + "</font>");
                  }
                  else
                  {
                     _loc14_ = Boolean(_loc12_.@low == "1");
                     _loc15_ = NumberFormatter.format(Math.abs(Number(_loc10_.value.toFixed(2))),0);
                     _loc13_ = _loc12_[_loc10_.value < 0 ? "neg" : "pos"].toString().replace("%s",_loc15_);
                     _loc16_ = _loc10_.value < 0 ? (_loc14_ ? Effects.COLOR_GOOD : Effects.COLOR_WARNING) : (_loc14_ ? Effects.COLOR_WARNING : Effects.COLOR_GOOD);
                     _loc4_.push("<font color=\'" + Color.colorToHex(_loc16_) + "\'>" + _loc13_ + "</font>");
                  }
               }
            }
            _loc5_++;
         }
         if(_loc4_.length > 0)
         {
            this.txt_effects.visible = true;
            this.txt_effects.htmlText = StringUtils.htmlSetDoubleBreakLeading(_loc4_.join("<br/><br/>"),-10);
            this.txt_effects.y = _height;
            _height += int(this.txt_effects.height + 10);
         }
         else
         {
            this.txt_effects.visible = false;
         }
         this.updateTimeDisplay();
         this._timer.start();
         if(this.txt_time.parent != null)
         {
            this.txt_time.y = int(_height + 10);
            _height = int(this.txt_time.y + this.txt_time.height);
         }
      }
      
      private function updateTimeDisplay() : void
      {
         var _loc4_:int = 0;
         var _loc5_:* = null;
         var _loc6_:String = null;
         var _loc7_:Cooldown = null;
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         if(this._effect == null)
         {
            return;
         }
         var _loc1_:Array = [];
         var _loc2_:TimerData = this._effect.timer;
         if(_loc2_ != null && _loc2_.hasStarted())
         {
            _loc4_ = _loc2_.getSecondsRemaining();
            _loc5_ = _lang.getString("effect_desc.time_active",DateTimeUtils.secondsToString(_loc4_,true,true));
            if(_loc4_ <= _loc2_.length * 0.1)
            {
               _loc5_ = "<font color=\'" + Color.colorToHex(Effects.COLOR_WARNING) + "\'>" + _loc5_ + "</font>";
            }
            _loc1_.push(_loc5_);
         }
         else if(this._effect.time > 0)
         {
            _loc6_ = DateTimeUtils.secondsToString(this._effect.time);
            _loc1_.push(_lang.getString("effect_desc.time",_loc6_));
         }
         if(this._effect.hasEffectType(EffectType.getTypeValue("DisablePvP")))
         {
            _loc7_ = Network.getInstance().playerData.cooldowns.getByType(CooldownType.DisablePvP);
            if(_loc7_ != null)
            {
               _loc8_ = DateTimeUtils.secondsToString(_loc7_.timer.getSecondsRemaining(),true,true);
               _loc1_.push("<font color=\'" + Color.colorToHex(Effects.COLOR_WARNING) + "\'>" + _lang.getString("effect_desc.cooldown_active",_loc8_) + "</font>");
            }
            else if(this._effect.cooldownTime > 0)
            {
               _loc9_ = DateTimeUtils.secondsToString(this._effect.cooldownTime);
               _loc1_.push("<font color=\'#8DCBDA\'>" + _lang.getString("effect_desc.cooldown",_loc9_) + "</font>");
            }
         }
         var _loc3_:TimerData = this._effect.lockoutTimer;
         if(_loc3_ != null && _loc3_.hasStarted())
         {
            _loc10_ = DateTimeUtils.secondsToString(_loc3_.getSecondsRemaining(),true,true);
            _loc1_.push("<font color=\'" + Color.colorToHex(Effects.COLOR_WARNING) + "\'>" + _lang.getString("effect_desc.lockout_active",_loc10_) + "</font>");
         }
         else if(this._effect.lockoutTime > 0)
         {
            _loc11_ = DateTimeUtils.secondsToString(this._effect.lockoutTime);
            _loc1_.push("<font color=\'#8DCBDA\'>" + _lang.getString("effect_desc.lockout",_loc11_) + "</font>");
         }
         if(_loc1_.length > 0)
         {
            this.txt_time.htmlText = _loc1_.join("<br/>");
            addChild(this.txt_time);
         }
         else if(this.txt_time.parent != null)
         {
            this.txt_time.parent.removeChild(this.txt_time);
         }
      }
      
      public function getAttributeDescriptions(param1:String) : String
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc8_:Number = NaN;
         var _loc9_:Boolean = false;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc13_:* = null;
         var _loc14_:uint = 0;
         var _loc2_:Array = [];
         var _loc3_:Language = Language.getInstance();
         var _loc4_:Dictionary = this._effect.attributes.getModValues(param1);
         for(_loc5_ in _loc4_)
         {
            _loc7_ = _loc3_.getString("itm_details." + _loc5_);
            _loc8_ = Number(_loc4_[_loc5_]);
            _loc9_ = ItemAttributes.isLowerBetter(_loc5_) ? _loc8_ < 0 : _loc8_ > 0;
            _loc10_ = ItemAttributes.reverseSign(_loc5_) ? (_loc8_ < 0 ? "+" : "-") : (_loc8_ < 0 ? "-" : "+");
            _loc11_ = Math.abs(Number((_loc8_ * 100).toFixed(2))) + "%";
            _loc11_ = int(Math.abs(_loc8_)).toString();
            _loc11_ = ItemAttributes.isAdditive(_loc5_) ? (_loc11_) : (_loc11_);
            _loc12_ = _loc7_.indexOf("%s") > -1 ? Language.getInstance().replaceVars(_loc7_,_loc10_ + _loc11_) : _loc7_ + " " + (_loc10_ + _loc11_);
            _loc13_ = "<b>" + _loc12_ + "</b>";
            _loc14_ = _loc9_ ? Effects.COLOR_GOOD : Effects.COLOR_WARNING;
            _loc2_.push("<font color=\'" + Color.colorToHex(_loc14_) + "\'>" + _loc13_ + "</font>");
         }
         _loc6_ = _loc2_.join("<br/>");
         _loc6_ = StringUtils.htmlRemoveTrailingBreaks(_loc6_);
         return StringUtils.htmlSetDoubleBreakLeading(_loc6_);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         this._timer.stop();
      }
      
      private function onTimerTick(param1:TimerEvent) : void
      {
         this.updateTimeDisplay();
      }
   }
}

