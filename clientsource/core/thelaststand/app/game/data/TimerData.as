package thelaststand.app.game.data
{
   import org.osflash.signals.Signal;
   import thelaststand.aftermath;
   import thelaststand.app.game.logic.TimerManager;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.io.ISerializable;
   
   use namespace aftermath;
   
   public class TimerData implements ISerializable
   {
      
      private var _target:*;
      
      private var _timeEnd:Date;
      
      private var _timeStart:Date;
      
      private var _timeLength:Number;
      
      private var _timeRemaining:Number = 0;
      
      private var _running:Boolean;
      
      private var _progress:Number = 0;
      
      public var data:Object = {};
      
      public var completed:Signal;
      
      public var started:Signal;
      
      public var cancelled:Signal;
      
      public function TimerData(param1:Date, param2:int, param3:*)
      {
         super();
         this._target = param3;
         this._timeStart = param1;
         this._timeLength = param2;
         this.calculateEndTime();
         this.started = new Signal(TimerData);
         this.completed = new Signal(TimerData);
         this.cancelled = new Signal(TimerData);
      }
      
      public function cancel() : void
      {
         this._timeStart = null;
         this._timeEnd = null;
         this._timeLength = 0;
         this.cancelled.dispatch(this);
      }
      
      public function dispose() : void
      {
         this._timeStart = null;
         this._timeEnd = null;
         this._timeLength = 0;
         this._running = false;
         this._target = null;
         this.started.removeAll();
         this.completed.removeAll();
         this.cancelled.removeAll();
         TimerManager.getInstance().removeTimer(this);
      }
      
      public function merge(param1:TimerData) : void
      {
         var _loc2_:String = null;
         this._timeStart.time = Math.min(this._timeStart.time,param1.timeStart.time);
         this._timeLength += param1.length;
         this.calculateEndTime();
         for(_loc2_ in param1.data)
         {
            this.data[_loc2_] = param1.data[_loc2_];
         }
      }
      
      public function getProgress() : Number
      {
         return this._progress;
      }
      
      public function hasEnded() : Boolean
      {
         if(this._timeEnd == null)
         {
            return true;
         }
         return Network.getInstance().serverTime >= this._timeEnd.time;
      }
      
      public function hasStarted() : Boolean
      {
         if(this._timeStart == null)
         {
            return false;
         }
         return Network.getInstance().serverTime >= this._timeStart.time;
      }
      
      public function getTimeRemaining() : Object
      {
         return DateTimeUtils.secondsToTime(this.getSecondsRemaining());
      }
      
      public function getSecondsRemaining() : int
      {
         return Math.max(0,int(this._timeRemaining));
      }
      
      public function getTotalTime() : Object
      {
         return DateTimeUtils.secondsToTime(this._timeLength);
      }
      
      public function speedUp(param1:Number) : Boolean
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         if(this._timeStart == null)
         {
            return false;
         }
         this._timeStart.seconds -= param1;
         this.calculateEndTime();
         return !this.hasEnded();
      }
      
      public function speedUpByPurchaseOption(param1:Object) : int
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         if(param1.hasOwnProperty("percent"))
         {
            _loc3_ = Number(param1.percent);
            if(_loc3_ < 0)
            {
               _loc3_ = 0;
            }
            else if(_loc3_ > 1)
            {
               _loc3_ = 1;
            }
            if(_loc3_ == 1)
            {
               _loc2_ = this.length;
            }
            else
            {
               _loc2_ = int(this.getSecondsRemaining() * _loc3_);
            }
         }
         else if(param1.hasOwnProperty("time"))
         {
            _loc2_ = int(param1.time);
         }
         this.speedUp(_loc2_);
         return _loc2_;
      }
      
      public function setTimer(param1:Date, param2:int) : void
      {
         if(param2 < 0)
         {
            param2 = 0;
         }
         this._timeStart = param1;
         this._timeLength = param2;
         this.calculateEndTime();
      }
      
      public function toString() : String
      {
         var _loc1_:* = "";
         _loc1_ += "----TIMER----\r";
         _loc1_ += "Start " + this._timeStart + "\r";
         _loc1_ += "Length " + this._timeLength + "\r";
         _loc1_ += "End " + this._timeEnd + "\r";
         _loc1_ += "Now " + new Date(Network.getInstance().serverTime) + "\r";
         return _loc1_ + "-------------";
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         if(!param1)
         {
            param1 = {};
         }
         param1.start = DateTimeUtils.dateToString(this._timeStart);
         param1.length = this._timeLength;
         param1.data = this.data;
         return param1;
      }
      
      public function readObject(param1:Object) : void
      {
         var _loc2_:String = null;
         this._timeStart = new Date(param1.start);
         this._timeLength = param1.length;
         this.data = param1.data || {};
         for(_loc2_ in this.data)
         {
            if(this.data[_loc2_] is Number && isNaN(this.data[_loc2_]))
            {
               this.data[_loc2_] = 0;
            }
         }
         this.calculateEndTime();
      }
      
      private function calculateEndTime() : void
      {
         if(!this._timeStart)
         {
            return;
         }
         this._timeEnd = new Date(this._timeStart.time + this._timeLength * 1000);
      }
      
      aftermath function setProgress(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > 1)
         {
            param1 = 1;
         }
         this._progress = param1;
      }
      
      aftermath function setTimeRemaining(param1:Number) : void
      {
         var _loc2_:Number = param1 / 1000;
         if(_loc2_ >= this._timeLength)
         {
            _loc2_ = this._timeLength;
         }
         this._timeRemaining = _loc2_;
      }
      
      aftermath function setRunning(param1:Boolean) : void
      {
         this._running = param1;
      }
      
      public function get timeStart() : Date
      {
         return this._timeStart;
      }
      
      public function set timeStart(param1:Date) : void
      {
         this._timeStart = param1;
         this.calculateEndTime();
      }
      
      public function get timeEnd() : Date
      {
         return this._timeEnd;
      }
      
      public function get length() : int
      {
         return this._timeLength;
      }
      
      public function set length(param1:int) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._timeLength = param1;
         this.calculateEndTime();
      }
      
      public function get target() : *
      {
         return this._target;
      }
      
      public function get running() : Boolean
      {
         return this._running;
      }
   }
}

