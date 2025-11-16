package starling.animation
{
   import starling.events.Event;
   import starling.events.EventDispatcher;
   
   public class Tween extends EventDispatcher implements IAnimatable
   {
      
      private var mTarget:Object;
      
      private var mTransition:String;
      
      private var mProperties:Vector.<String>;
      
      private var mStartValues:Vector.<Number>;
      
      private var mEndValues:Vector.<Number>;
      
      private var mOnStart:Function;
      
      private var mOnUpdate:Function;
      
      private var mOnComplete:Function;
      
      private var mOnStartArgs:Array;
      
      private var mOnUpdateArgs:Array;
      
      private var mOnCompleteArgs:Array;
      
      private var mTotalTime:Number;
      
      private var mCurrentTime:Number;
      
      private var mDelay:Number;
      
      private var mRoundToInt:Boolean;
      
      public function Tween(param1:Object, param2:Number, param3:String = "linear")
      {
         super();
         this.reset(param1,param2,param3);
      }
      
      public function reset(param1:Object, param2:Number, param3:String = "linear") : Tween
      {
         this.mTarget = param1;
         this.mCurrentTime = 0;
         this.mTotalTime = Math.max(0.0001,param2);
         this.mDelay = 0;
         this.mTransition = param3;
         this.mRoundToInt = false;
         this.mOnStart = this.mOnUpdate = this.mOnComplete = null;
         this.mOnStartArgs = this.mOnUpdateArgs = this.mOnCompleteArgs = null;
         if(this.mProperties)
         {
            this.mProperties.length = 0;
         }
         else
         {
            this.mProperties = new Vector.<String>(0);
         }
         if(this.mStartValues)
         {
            this.mStartValues.length = 0;
         }
         else
         {
            this.mStartValues = new Vector.<Number>(0);
         }
         if(this.mEndValues)
         {
            this.mEndValues.length = 0;
         }
         else
         {
            this.mEndValues = new Vector.<Number>(0);
         }
         return this;
      }
      
      public function animate(param1:String, param2:Number) : void
      {
         if(this.mTarget == null)
         {
            return;
         }
         this.mProperties.push(param1);
         this.mStartValues.push(Number.NaN);
         this.mEndValues.push(param2);
      }
      
      public function scaleTo(param1:Number) : void
      {
         this.animate("scaleX",param1);
         this.animate("scaleY",param1);
      }
      
      public function moveTo(param1:Number, param2:Number) : void
      {
         this.animate("x",param1);
         this.animate("y",param2);
      }
      
      public function fadeTo(param1:Number) : void
      {
         this.animate("alpha",param1);
      }
      
      public function advanceTime(param1:Number) : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Function = null;
         var _loc10_:Number = NaN;
         if(param1 == 0)
         {
            return;
         }
         var _loc2_:Number = this.mCurrentTime;
         this.mCurrentTime += param1;
         if(this.mCurrentTime < 0 || _loc2_ >= this.mTotalTime)
         {
            return;
         }
         if(this.mOnStart != null && _loc2_ <= 0 && this.mCurrentTime >= 0)
         {
            this.mOnStart.apply(null,this.mOnStartArgs);
         }
         var _loc3_:Number = Math.min(this.mTotalTime,this.mCurrentTime) / this.mTotalTime;
         var _loc4_:int = int(this.mStartValues.length);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            if(isNaN(this.mStartValues[_loc5_]))
            {
               this.mStartValues[_loc5_] = this.mTarget[this.mProperties[_loc5_]] as Number;
            }
            _loc6_ = this.mStartValues[_loc5_];
            _loc7_ = this.mEndValues[_loc5_];
            _loc8_ = _loc7_ - _loc6_;
            _loc9_ = Transitions.getTransition(this.mTransition);
            _loc10_ = _loc6_ + _loc9_(_loc3_) * _loc8_;
            if(this.mRoundToInt)
            {
               _loc10_ = Math.round(_loc10_);
            }
            this.mTarget[this.mProperties[_loc5_]] = _loc10_;
            _loc5_++;
         }
         if(this.mOnUpdate != null)
         {
            this.mOnUpdate.apply(null,this.mOnUpdateArgs);
         }
         if(_loc2_ < this.mTotalTime && this.mCurrentTime >= this.mTotalTime)
         {
            dispatchEventWith(Event.REMOVE_FROM_JUGGLER);
            if(this.mOnComplete != null)
            {
               this.mOnComplete.apply(null,this.mOnCompleteArgs);
            }
         }
      }
      
      public function get isComplete() : Boolean
      {
         return this.mCurrentTime >= this.mTotalTime;
      }
      
      public function get target() : Object
      {
         return this.mTarget;
      }
      
      public function get transition() : String
      {
         return this.mTransition;
      }
      
      public function get totalTime() : Number
      {
         return this.mTotalTime;
      }
      
      public function get currentTime() : Number
      {
         return this.mCurrentTime;
      }
      
      public function get delay() : Number
      {
         return this.mDelay;
      }
      
      public function set delay(param1:Number) : void
      {
         this.mCurrentTime = this.mCurrentTime + this.mDelay - param1;
         this.mDelay = param1;
      }
      
      public function get roundToInt() : Boolean
      {
         return this.mRoundToInt;
      }
      
      public function set roundToInt(param1:Boolean) : void
      {
         this.mRoundToInt = param1;
      }
      
      public function get onStart() : Function
      {
         return this.mOnStart;
      }
      
      public function set onStart(param1:Function) : void
      {
         this.mOnStart = param1;
      }
      
      public function get onUpdate() : Function
      {
         return this.mOnUpdate;
      }
      
      public function set onUpdate(param1:Function) : void
      {
         this.mOnUpdate = param1;
      }
      
      public function get onComplete() : Function
      {
         return this.mOnComplete;
      }
      
      public function set onComplete(param1:Function) : void
      {
         this.mOnComplete = param1;
      }
      
      public function get onStartArgs() : Array
      {
         return this.mOnStartArgs;
      }
      
      public function set onStartArgs(param1:Array) : void
      {
         this.mOnStartArgs = param1;
      }
      
      public function get onUpdateArgs() : Array
      {
         return this.mOnUpdateArgs;
      }
      
      public function set onUpdateArgs(param1:Array) : void
      {
         this.mOnUpdateArgs = param1;
      }
      
      public function get onCompleteArgs() : Array
      {
         return this.mOnCompleteArgs;
      }
      
      public function set onCompleteArgs(param1:Array) : void
      {
         this.mOnCompleteArgs = param1;
      }
   }
}

