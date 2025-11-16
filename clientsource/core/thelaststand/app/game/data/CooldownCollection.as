package thelaststand.app.game.data
{
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.effects.Cooldown;
   import thelaststand.common.io.ISerializable;
   
   public class CooldownCollection implements ISerializable
   {
      
      private var _cooldowns:Vector.<Cooldown>;
      
      private var _cooldownsById:Dictionary;
      
      public var cooldownAdded:Signal;
      
      public var cooldownRemoved:Signal;
      
      public var cooldownCompleted:Signal;
      
      public function CooldownCollection()
      {
         super();
         this._cooldowns = new Vector.<Cooldown>();
         this._cooldownsById = new Dictionary(true);
         this.cooldownAdded = new Signal(Cooldown);
         this.cooldownRemoved = new Signal(Cooldown);
         this.cooldownCompleted = new Signal(Cooldown);
      }
      
      public function dispose() : void
      {
         var _loc1_:Cooldown = null;
         for each(_loc1_ in this._cooldowns)
         {
            _loc1_.completed.remove(this.onCooldownCompleted);
         }
         this.cooldownAdded.removeAll();
         this.cooldownRemoved.removeAll();
         this.cooldownCompleted.removeAll();
         this._cooldowns = null;
         this._cooldownsById = null;
      }
      
      public function add(param1:Cooldown) : void
      {
         param1.completed.addOnce(this.onCooldownCompleted);
         this._cooldowns.push(param1);
         this._cooldownsById[param1.id] = param1;
         this.cooldownAdded.dispatch(param1);
      }
      
      public function getByType(param1:uint, param2:String = null) : Cooldown
      {
         var _loc3_:Cooldown = null;
         for each(_loc3_ in this._cooldowns)
         {
            if(_loc3_ != null)
            {
               if(_loc3_.type == param1 && _loc3_.subType == param2)
               {
                  return _loc3_;
               }
            }
         }
         return null;
      }
      
      public function getById(param1:String) : Cooldown
      {
         return this._cooldownsById[param1];
      }
      
      public function hasActive(param1:uint, param2:String = null) : Boolean
      {
         var _loc3_:Cooldown = null;
         for each(_loc3_ in this._cooldowns)
         {
            if(_loc3_ != null)
            {
               if(_loc3_.type == param1 && _loc3_.subType == param2 && !_loc3_.timer.hasEnded())
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function remove(param1:Cooldown) : void
      {
         var _loc2_:int = int(this._cooldowns.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         param1.completed.remove(this.onCooldownCompleted);
         this._cooldowns.splice(_loc2_,1);
         delete this._cooldownsById[param1.id];
         this.cooldownRemoved.dispatch(param1);
      }
      
      public function parse(param1:ByteArray) : void
      {
         var _loc2_:Cooldown = new Cooldown();
         _loc2_.readObject(param1);
         var _loc3_:Cooldown = this._cooldownsById[_loc2_.id];
         if(_loc3_ != null)
         {
            _loc3_.readObject(param1);
         }
         else
         {
            this.add(_loc2_);
         }
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         return param1;
      }
      
      public function readObject(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:ByteArray = null;
         this._cooldowns.length = 0;
         for(_loc2_ in param1)
         {
            _loc3_ = param1[_loc2_] as ByteArray;
            if(_loc3_ != null)
            {
               this.parse(_loc3_);
            }
         }
      }
      
      private function onCooldownCompleted(param1:Cooldown) : void
      {
         this.remove(param1);
         this.cooldownCompleted.dispatch(param1);
      }
   }
}

