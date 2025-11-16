package thelaststand.app.game.data.quests
{
   import org.osflash.signals.Signal;
   
   public class MiniTask
   {
      
      private var _id:String;
      
      private var _minValue:Number = 0;
      
      private var _value:Number = 0;
      
      private var _xpPerc:Number = 0;
      
      private var _xpValue:int;
      
      private var _lastChange:uint;
      
      private var _lastTime:uint;
      
      private var _minIncrementTime:uint;
      
      private var _missionOnly:Boolean;
      
      private var _isPercentage:Boolean;
      
      private var _limitPerMission:int = -1;
      
      private var _thisMissionCount:int = 0;
      
      public var completed:Signal = new Signal(MiniTask);
      
      public function MiniTask(param1:String = null)
      {
         super();
         if(param1 != null)
         {
            this._id = param1;
         }
         this.reset();
      }
      
      public function get minValue() : Number
      {
         return this._minValue;
      }
      
      public function set minValue(param1:Number) : void
      {
         if(param1 < 0 || isNaN(this._minValue))
         {
            param1 = 0;
         }
         this._minValue = param1;
      }
      
      public function get missionOnly() : Boolean
      {
         return this._missionOnly;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get value() : Number
      {
         return this._value;
      }
      
      public function get xp() : int
      {
         return this._xpValue;
      }
      
      public function get isPercentage() : Boolean
      {
         return this._isPercentage;
      }
      
      public function reset() : void
      {
         this._value = 0;
         this._xpValue = 0;
         this._lastChange = 0;
      }
      
      public function resetMissionCounts() : void
      {
         this.reset();
         this._thisMissionCount = 0;
      }
      
      public function updateTimer(param1:Number) : void
      {
         if(this._minIncrementTime > 0)
         {
            if(param1 - this._lastChange > this._minIncrementTime)
            {
               if(this._value >= this._minValue)
               {
                  if(this._limitPerMission <= 0 || this._limitPerMission > 0 && this._thisMissionCount < this._limitPerMission)
                  {
                     this.completed.dispatch(this);
                     ++this._thisMissionCount;
                  }
               }
               this.reset();
            }
         }
         else if(this._value >= this._minValue)
         {
            if(this._limitPerMission <= 0 || this._limitPerMission > 0 && this._thisMissionCount < this._limitPerMission)
            {
               this.completed.dispatch(this);
               ++this._thisMissionCount;
            }
            this.reset();
         }
         this._lastTime = param1;
      }
      
      public function decrement(param1:Number) : void
      {
         if(isNaN(param1))
         {
            return;
         }
         this._value -= param1;
         if(this._value < 0)
         {
            this._value = 0;
         }
      }
      
      public function increment(param1:Number, param2:int = 0) : void
      {
         if(isNaN(param1))
         {
            return;
         }
         this._lastChange = this._lastTime;
         this._value += param1;
         this._xpValue += param2;
      }
      
      public function parseXML(param1:XML) : void
      {
         this._id = param1.@id.toString();
         this._minValue = Number(param1.min.toString());
         this._minIncrementTime = int(Number(param1.time.toString()) * 1000);
         this._missionOnly = param1.@mission == "1";
         this._isPercentage = param1.@perc == "1";
         this._limitPerMission = param1.limitPerMission.length() == 0 ? -1 : int(param1.limitPerMission[0]);
      }
   }
}

