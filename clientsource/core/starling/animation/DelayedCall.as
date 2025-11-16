package starling.animation
{
   import starling.events.Event;
   import starling.events.EventDispatcher;
   
   public class DelayedCall extends EventDispatcher implements IAnimatable
   {
      
      private var mCurrentTime:Number = 0;
      
      private var mTotalTime:Number;
      
      private var mCall:Function;
      
      private var mArgs:Array;
      
      private var mRepeatCount:int = 1;
      
      public function DelayedCall(param1:Function, param2:Number, param3:Array = null)
      {
         super();
         this.mCall = param1;
         this.mTotalTime = Math.max(param2,0.0001);
         this.mArgs = param3;
      }
      
      public function advanceTime(param1:Number) : void
      {
         var _loc2_:Number = this.mCurrentTime;
         this.mCurrentTime = Math.min(this.mTotalTime,this.mCurrentTime + param1);
         if(_loc2_ < this.mTotalTime && this.mCurrentTime >= this.mTotalTime)
         {
            this.mCall.apply(null,this.mArgs);
            if(this.mRepeatCount > 1)
            {
               --this.mRepeatCount;
               this.mCurrentTime = 0;
               this.advanceTime(_loc2_ + param1 - this.mTotalTime);
            }
            else
            {
               dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
            }
         }
      }
      
      public function get isComplete() : Boolean
      {
         return this.mRepeatCount == 1 && this.mCurrentTime >= this.mTotalTime;
      }
      
      public function get totalTime() : Number
      {
         return this.mTotalTime;
      }
      
      public function get currentTime() : Number
      {
         return this.mCurrentTime;
      }
      
      public function get repeatCount() : int
      {
         return this.mRepeatCount;
      }
      
      public function set repeatCount(param1:int) : void
      {
         this.mRepeatCount = param1;
      }
   }
}

