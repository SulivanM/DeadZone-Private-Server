package thelaststand.app.game.logic.ai
{
   import thelaststand.app.game.logic.ai.effects.IAIEffect;
   
   public class AIEffectEngine
   {
      
      private var _effects:Vector.<IAIEffect>;
      
      private var _timeElapsed:Number;
      
      public function AIEffectEngine()
      {
         super();
         this._effects = new Vector.<IAIEffect>();
      }
      
      public function addEffect(param1:IAIEffect) : void
      {
         if(this._effects.indexOf(param1) > -1)
         {
            return;
         }
         this._effects.push(param1);
         param1.start(this._timeElapsed);
      }
      
      public function clear() : void
      {
         var _loc1_:IAIEffect = null;
         for each(_loc1_ in this._effects)
         {
            _loc1_.dispose();
         }
         this._effects.length = 0;
      }
      
      public function getMultiplierForAttribute(param1:String) : Number
      {
         var _loc3_:IAIEffect = null;
         var _loc2_:Number = 0;
         for each(_loc3_ in this._effects)
         {
            _loc2_ += _loc3_.getMultiplierForAttribute(param1);
         }
         return _loc2_;
      }
      
      public function hasEffect(param1:Class) : Boolean
      {
         var _loc2_:IAIEffect = null;
         for each(_loc2_ in this._effects)
         {
            if(Object(_loc2_).prototype.constructor == param1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function removeEffect(param1:IAIEffect) : void
      {
         var _loc2_:int = int(this._effects.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         this._effects.splice(_loc2_,1);
         param1.end(this._timeElapsed);
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         var _loc4_:IAIEffect = null;
         this._timeElapsed = param2;
         var _loc3_:int = int(this._effects.length - 1);
         while(_loc3_ >= 0)
         {
            _loc4_ = this._effects[_loc3_];
            _loc4_.update(param1,param2);
            if(_loc4_.length > 0 && _loc4_.timeStart - param2 > _loc4_.length)
            {
               this.removeEffect(_loc4_);
            }
            _loc3_--;
         }
      }
   }
}

