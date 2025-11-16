package starling.events
{
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   
   public class TouchEvent extends Event
   {
      
      public static const TOUCH:String = "touch";
      
      private var mTouches:Vector.<Touch>;
      
      private var mShiftKey:Boolean;
      
      private var mCtrlKey:Boolean;
      
      private var mTimestamp:Number;
      
      public function TouchEvent(param1:String, param2:Vector.<Touch>, param3:Boolean = false, param4:Boolean = false, param5:Boolean = true)
      {
         super(param1,param5,param2);
         this.mTouches = param2;
         this.mShiftKey = param3;
         this.mCtrlKey = param4;
         this.mTimestamp = -1;
         var _loc6_:int = int(param2.length);
         var _loc7_:int = 0;
         while(_loc7_ < _loc6_)
         {
            if(param2[_loc7_].timestamp > this.mTimestamp)
            {
               this.mTimestamp = param2[_loc7_].timestamp;
            }
            _loc7_++;
         }
      }
      
      public function getTouches(param1:DisplayObject, param2:String = null) : Vector.<Touch>
      {
         var _loc6_:Touch = null;
         var _loc7_:Boolean = false;
         var _loc8_:Boolean = false;
         var _loc3_:Vector.<Touch> = new Vector.<Touch>(0);
         var _loc4_:int = int(this.mTouches.length);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc6_ = this.mTouches[_loc5_];
            _loc7_ = _loc6_.target == param1 || param1 is DisplayObjectContainer && (param1 as DisplayObjectContainer).contains(_loc6_.target);
            _loc8_ = param2 == null || param2 == _loc6_.phase;
            if(_loc7_ && _loc8_)
            {
               _loc3_.push(_loc6_);
            }
            _loc5_++;
         }
         return _loc3_;
      }
      
      public function getTouch(param1:DisplayObject, param2:String = null) : Touch
      {
         var _loc3_:Vector.<Touch> = this.getTouches(param1,param2);
         if(_loc3_.length > 0)
         {
            return _loc3_[0];
         }
         return null;
      }
      
      public function interactsWith(param1:DisplayObject) : Boolean
      {
         var _loc2_:Vector.<Touch> = null;
         var _loc3_:int = 0;
         if(this.getTouch(param1) == null)
         {
            return false;
         }
         _loc2_ = this.getTouches(param1);
         _loc3_ = int(_loc2_.length - 1);
         while(_loc3_ >= 0)
         {
            if(_loc2_[_loc3_].phase != TouchPhase.ENDED)
            {
               return true;
            }
            _loc3_--;
         }
         return false;
      }
      
      public function get timestamp() : Number
      {
         return this.mTimestamp;
      }
      
      public function get touches() : Vector.<Touch>
      {
         return this.mTouches.concat();
      }
      
      public function get shiftKey() : Boolean
      {
         return this.mShiftKey;
      }
      
      public function get ctrlKey() : Boolean
      {
         return this.mCtrlKey;
      }
   }
}

