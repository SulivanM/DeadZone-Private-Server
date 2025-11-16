package thelaststand.app.game.data
{
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.effects.Effect;
   import thelaststand.app.game.data.effects.EffectSaveFlags;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.common.io.ISerializable;
   
   public class EffectCollection implements ISerializable
   {
      
      private var _compound:CompoundData;
      
      private var _effects:Vector.<Effect>;
      
      private var _effectsById:Dictionary;
      
      private var _groupCounts:Dictionary;
      
      private var _attributes:ItemAttributes = new ItemAttributes();
      
      public var effectChanged:Signal;
      
      public var effectExpired:Signal;
      
      public function EffectCollection(param1:CompoundData, param2:int = 0)
      {
         super();
         this._compound = param1;
         if(param2 > 0)
         {
            this._effects = new Vector.<Effect>(param2,true);
         }
         else
         {
            this._effects = new Vector.<Effect>();
         }
         this._effectsById = new Dictionary(true);
         this._groupCounts = new Dictionary(true);
         this.effectChanged = new Signal(Effect,int);
         this.effectExpired = new Signal(Effect);
      }
      
      public function addEffect(param1:Effect) : void
      {
         if(this._effects.fixed)
         {
            throw new Error("Cannot call addEffect on fixed length collection.");
         }
         var _loc2_:Effect = this.getEffectById(param1.id);
         if(_loc2_ != null)
         {
            this.setEffect(param1,this._effects.indexOf(_loc2_));
         }
         else
         {
            this.setEffect(param1,this._effects.length);
         }
      }
      
      public function getAttribute(param1:String, param2:String) : Number
      {
         return 1;
      }
      
      private function updateAttributes() : void
      {
         var _loc2_:Effect = null;
         this._attributes.clear();
         var _loc1_:int = 0;
         while(_loc1_ < this._effects.length)
         {
            _loc2_ = this._effects[_loc1_];
            if(!(_loc2_ == null || _loc2_.attributes == null))
            {
               this._attributes.merge(_loc2_.attributes);
            }
            _loc1_++;
         }
      }
      
      public function setEffect(param1:Effect, param2:int) : void
      {
         if(param2 < 0 || this._effects.fixed && param2 >= this._effects.length)
         {
            return;
         }
         var _loc3_:Effect = param2 <= this._effects.length - 1 ? this._effects[param2] : null;
         if(_loc3_ != param1 && _loc3_ != null)
         {
            delete this._effectsById[_loc3_.id];
            _loc3_.expired.remove(this.onEffectExpired);
         }
         if(param1 != null)
         {
            param1.expired.addOnce(this.onEffectExpired);
            this._effectsById[param1.id] = param1;
         }
         this._effects[param2] = param1;
         this.effectChanged.dispatch(param1,param2);
         this.updateGroupCounts();
         this.updateAttributes();
      }
      
      public function getNumEffectsOfGroup(param1:String) : int
      {
         return int(this._groupCounts[param1]);
      }
      
      public function getMaxEffectsOfGroup(param1:String) : int
      {
         var _loc4_:Effect = null;
         var _loc2_:Number = 1;
         var _loc3_:int = EffectType.getTypeValue("EffectGroupLimit");
         for each(_loc4_ in this._effects)
         {
            if(!(_loc4_ == null || _loc4_.group != param1))
            {
               _loc2_ += _loc4_.getValue(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function getValue(param1:uint) : Number
      {
         var _loc3_:Effect = null;
         var _loc2_:Number = 0;
         for each(_loc3_ in this._effects)
         {
            if(_loc3_ != null)
            {
               _loc2_ += _loc3_.getValue(param1);
            }
         }
         return _loc2_;
      }
      
      public function hasEffectType(param1:uint) : Boolean
      {
         var _loc2_:Effect = null;
         for each(_loc2_ in this._effects)
         {
            if(_loc2_ != null)
            {
               if(_loc2_.hasEffectType(param1))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function containsEffect(param1:Effect) : Boolean
      {
         return this._effects.indexOf(param1) > -1;
      }
      
      public function containsEffectOfType(param1:String) : Boolean
      {
         var _loc2_:Effect = null;
         for each(_loc2_ in this._effects)
         {
            if(_loc2_ != null && _loc2_.type == param1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function dispose() : void
      {
         var _loc1_:Effect = null;
         for each(_loc1_ in this._effects)
         {
            if(_loc1_ != null)
            {
               _loc1_.dispose();
            }
         }
         this.effectChanged.removeAll();
         this.effectExpired.removeAll();
         this._effects = null;
         this._effectsById = null;
         this._compound = null;
         this._attributes = null;
      }
      
      public function getEffect(param1:uint) : Effect
      {
         if(param1 < 0 || param1 >= this._effects.length)
         {
            return null;
         }
         return this._effects[param1];
      }
      
      public function getEffectById(param1:String) : Effect
      {
         var _loc2_:Effect = null;
         param1 = param1.toUpperCase();
         for each(_loc2_ in this._effects)
         {
            if(_loc2_ != null && _loc2_.id.toUpperCase() == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getEffectByType(param1:String) : Effect
      {
         var _loc2_:Effect = null;
         for each(_loc2_ in this._effects)
         {
            if(_loc2_ != null && _loc2_.type == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getEffectsOfType(param1:String) : Vector.<Effect>
      {
         var _loc3_:Effect = null;
         var _loc2_:Vector.<Effect> = new Vector.<Effect>();
         for each(_loc3_ in this._effects)
         {
            if(_loc3_ != null && _loc3_.type == param1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function hasPermanentEffect(param1:uint) : Boolean
      {
         var _loc2_:Effect = null;
         for each(_loc2_ in this._effects)
         {
            if(_loc2_ != null && _loc2_.timer == null && _loc2_.hasEffectType(param1))
            {
               return true;
            }
         }
         return false;
      }
      
      public function removeEffect(param1:Effect) : void
      {
         var _loc2_:int = int(this._effects.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         this._effects.splice(_loc2_,1);
         this.updateAttributes();
         this.effectChanged.dispatch(param1,_loc2_);
      }
      
      public function removeEffectsWithType(param1:uint) : void
      {
         var _loc3_:Effect = null;
         var _loc2_:int = int(this._effects.length - 1);
         while(_loc2_ >= 0)
         {
            _loc3_ = this._effects[_loc2_];
            if(_loc3_ != null)
            {
               if(_loc3_.getValue(param1) > 0)
               {
                  if(this._effects.fixed)
                  {
                     this._effects[_loc2_] = null;
                  }
                  else
                  {
                     this._effects.splice(_loc2_,1);
                  }
                  this.updateAttributes();
                  this.effectChanged.dispatch(_loc3_,_loc2_);
               }
            }
            _loc2_--;
         }
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         return param1;
      }
      
      public function readObject(param1:Object) : void
      {
         var data:Object = null;
         var effect:Effect = null;
         var j:int = 0;
         var len:int = 0;
         var i:String = null;
         var index:int = 0;
         var itemId:String = null;
         var effectItem:EffectItem = null;
         var input:Object = param1;
         if(input is Array)
         {
            j = 0;
            len = int(input.length);
            for(; j < len; j++)
            {
               data = input[j];
               if(data != null)
               {
                  try
                  {
                     effect = new Effect();
                     effect.readObject(data);
                  }
                  catch(e:Error)
                  {
                     continue;
                  }
                  effect.expired.addOnce(this.onEffectExpired);
                  this._effects.push(effect);
               }
            }
         }
         else
         {
            for(i in input)
            {
               index = int(i);
               data = input[i];
               if(data == null || index < 0)
               {
                  this._effects[index] = null;
                  return;
               }
               if(data.flags & EffectSaveFlags.CONSUMABLE)
               {
                  effect = new Effect();
                  effect.readObject(data.effect);
                  effect.expired.addOnce(this.onEffectExpired);
                  this._effects[index] = effect;
               }
               else if(data.flags & EffectSaveFlags.LINKED_ITEM)
               {
                  itemId = String(data.itemId);
                  effectItem = this._compound.player.inventory.getItemById(itemId) as EffectItem;
                  if(effectItem != null)
                  {
                     this._effects[index] = effectItem.effect;
                     effectItem.effect.expired.addOnce(this.onEffectExpired);
                  }
               }
            }
         }
         this.updateAttributes();
         this.updateGroupCounts();
      }
      
      private function updateGroupCounts() : void
      {
         var _loc1_:String = null;
         var _loc2_:Effect = null;
         var _loc3_:int = 0;
         for(_loc1_ in this._groupCounts)
         {
            this._groupCounts[_loc1_] = 0;
         }
         for each(_loc2_ in this._effects)
         {
            if(_loc2_ != null)
            {
               _loc3_ = int(this._groupCounts[_loc2_.group]);
               this._groupCounts[_loc2_.group] = _loc3_ + 1;
            }
         }
      }
      
      private function onEffectExpired(param1:Effect) : void
      {
         var _loc2_:int = int(this._effects.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         this.setEffect(null,_loc2_);
         this.effectExpired.dispatch(param1);
      }
      
      public function get compound() : CompoundData
      {
         return this._compound;
      }
      
      public function get length() : int
      {
         return this._effects.length;
      }
      
      public function get attributes() : ItemAttributes
      {
         return this._attributes;
      }
   }
}

