package thelaststand.app.game.data
{
   import com.exileetiquette.math.MathUtils;
   import flash.utils.Dictionary;
   import thelaststand.app.core.Config;
   import thelaststand.common.io.ISerializable;
   
   public class Morale implements ISerializable
   {
      
      public static const EFFECT_INJURY:String = "injury";
      
      public static const EFFECT_MISSION_COMPLETE:String = "missionComplete";
      
      public static const EFFECT_FOOD:String = "food";
      
      public static const EFFECT_WATER:String = "water";
      
      public static const EFFECT_SECURITY:String = "security";
      
      public static const EFFECT_COMFORT:String = "comfort";
      
      public static const EFFECT_AVERAGE_SURVIVOR:String = "avgSurvivor";
      
      public static const EFFECT_DAILY_QUEST_COMPLETED:String = "dailyQuestCompleted";
      
      public static const EFFECT_DAILY_QUEST_FAILED:String = "dailyQuestFailed";
      
      private var _effects:Dictionary;
      
      private var _multiplier:Number = 0;
      
      public function Morale()
      {
         super();
         this._effects = new Dictionary(true);
      }
      
      public function clear() : void
      {
         var _loc1_:String = null;
         for(_loc1_ in this._effects)
         {
            this._effects[_loc1_] = 0;
            delete this._effects[_loc1_];
         }
      }
      
      public function getEffect(param1:String) : Number
      {
         var _loc2_:Number = this._effects[param1] == null ? 0 : Number(this._effects[param1]);
         return _loc2_ + _loc2_ * this._multiplier;
      }
      
      public function getTotal(param1:Vector.<String> = null) : Number
      {
         var _loc3_:String = null;
         var _loc2_:Number = 0;
         for(_loc3_ in this._effects)
         {
            if(!(param1 != null && param1.indexOf(_loc3_) > -1))
            {
               if(!isNaN(this._effects[_loc3_]))
               {
                  _loc2_ += Number(this._effects[_loc3_]);
               }
            }
         }
         return _loc2_ + _loc2_ * this._multiplier;
      }
      
      public function getRoundedTotal() : int
      {
         var _loc2_:String = null;
         var _loc1_:Number = 0;
         for(_loc2_ in this._effects)
         {
            if(!isNaN(this._effects[_loc2_]))
            {
               _loc1_ += Math.round(Number(this._effects[_loc2_]));
            }
         }
         return Math.round(_loc1_ + _loc1_ * this._multiplier);
      }
      
      public function getClampedTotal() : Number
      {
         return MathUtils.clamp(this.getTotal(),Config.constant.MORALE_MIN,Config.constant.MORALE_MAX);
      }
      
      public function setEffect(param1:String, param2:Number) : void
      {
         this._effects[param1] = param2;
         if(this._effects[param1] == 0)
         {
            this._effects[param1] = null;
            delete this._effects[param1];
         }
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         return param1 || {};
      }
      
      public function readObject(param1:Object) : void
      {
         var _loc2_:String = null;
         this._effects = new Dictionary(true);
         for(_loc2_ in param1)
         {
            this._effects[_loc2_] = Number(param1[_loc2_]);
         }
      }
      
      public function get effects() : Vector.<String>
      {
         var _loc2_:String = null;
         var _loc1_:Vector.<String> = new Vector.<String>();
         for(_loc2_ in this._effects)
         {
            _loc1_.push(_loc2_);
         }
         return _loc1_;
      }
      
      public function get multiplier() : Number
      {
         return this._multiplier;
      }
      
      public function set multiplier(param1:Number) : void
      {
         this._multiplier = param1;
      }
   }
}

