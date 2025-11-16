package thelaststand.app.game.data
{
   import com.dynamicflash.util.Base64;
   import flash.utils.ByteArray;
   import thelaststand.app.game.data.effects.Effect;
   import thelaststand.common.lang.Language;
   
   public class EffectItem extends Item
   {
      
      private var _effect:Effect;
      
      public function EffectItem()
      {
         super();
         _isUpgradable = false;
      }
      
      public function get effect() : Effect
      {
         return this._effect;
      }
      
      public function set effect(param1:Effect) : void
      {
         this._effect = param1;
         this._effect.item = this;
      }
      
      override public function clone() : Item
      {
         var _loc1_:EffectItem = new EffectItem();
         cloneBaseProperties(_loc1_);
         _loc1_._effect = this._effect;
         return _loc1_;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this._effect != null)
         {
            if(this._effect.item == this)
            {
               this._effect.item = null;
            }
            this._effect = null;
         }
      }
      
      override public function getBaseName() : String
      {
         if(_nameBase == null)
         {
            _nameBase = Language.getInstance().getString("effect_names." + this._effect.type);
         }
         return _nameBase;
      }
      
      override public function getName() : String
      {
         var _loc1_:String = null;
         if(_name == null)
         {
            _loc1_ = Language.getInstance().getString("effect_names." + this._effect.type);
            if(this._effect.isChallenge)
            {
               _name = Language.getInstance().getString("items." + _type + "-challenge",_loc1_);
            }
            else
            {
               _name = Language.getInstance().getString("items." + _type + "-" + this._effect.group,_loc1_);
               if(!_name || _name == "?")
               {
                  _name = Language.getInstance().getString("items." + _type,_loc1_);
               }
            }
         }
         return _name;
      }
      
      override public function getImageURI() : String
      {
         return this._effect.imageURI;
      }
      
      override public function toChatObject() : Object
      {
         var _loc1_:Object = super.toChatObject();
         _loc1_.data.effect = Base64.encodeByteArray(this._effect.rawData);
         _loc1_.linkClass = "effect_" + this._effect.group;
         return _loc1_;
      }
      
      override public function writeObject(param1:Object = null) : Object
      {
         param1 = super.writeObject(param1);
         param1.effect = this.effect.rawData;
         return param1;
      }
      
      override public function readObject(param1:Object) : void
      {
         super.readObject(param1);
         this._effect = new Effect();
         this._effect.item = this;
         this.parseInputData(param1);
         if(this._effect.quality != ItemQualityType.NONE)
         {
            _qualityType = this._effect.quality;
         }
      }
      
      private function parseInputData(param1:Object) : void
      {
         var _loc2_:ByteArray = null;
         if(param1 is XML)
         {
            _loc2_ = Base64.decodeToByteArray(param1.e.toString());
            if(_loc2_ == null || _loc2_.length == 0)
            {
               _loc2_ = null;
               this._effect.readLootXML(XML(param1));
               return;
            }
         }
         else if(param1.effect is ByteArray)
         {
            _loc2_ = ByteArray(param1.effect);
         }
         else
         {
            _loc2_ = Base64.decodeToByteArray(param1.effect);
         }
         if(_loc2_ != null)
         {
            this._effect.readObject(_loc2_);
            return;
         }
      }
   }
}

