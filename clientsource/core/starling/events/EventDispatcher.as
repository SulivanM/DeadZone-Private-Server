package starling.events
{
   import flash.utils.Dictionary;
   import starling.core.starling_internal;
   import starling.display.DisplayObject;
   
   use namespace starling_internal;
   
   public class EventDispatcher
   {
      
      private static var sBubbleChains:Array = [];
      
      private var mEventListeners:Dictionary;
      
      public function EventDispatcher()
      {
         super();
      }
      
      public function addEventListener(param1:String, param2:Function) : void
      {
         if(this.mEventListeners == null)
         {
            this.mEventListeners = new Dictionary();
         }
         var _loc3_:Vector.<Function> = this.mEventListeners[param1];
         if(_loc3_ == null)
         {
            this.mEventListeners[param1] = new <Function>[param2];
         }
         else if(_loc3_.indexOf(param2) == -1)
         {
            _loc3_.push(param2);
         }
      }
      
      public function removeEventListener(param1:String, param2:Function) : void
      {
         var _loc3_:Vector.<Function> = null;
         var _loc4_:int = 0;
         var _loc5_:Vector.<Function> = null;
         var _loc6_:int = 0;
         if(this.mEventListeners)
         {
            _loc3_ = this.mEventListeners[param1];
            if(_loc3_)
            {
               _loc4_ = int(_loc3_.length);
               _loc5_ = new Vector.<Function>(0);
               _loc6_ = 0;
               while(_loc6_ < _loc4_)
               {
                  if(_loc3_[_loc6_] != param2)
                  {
                     _loc5_.push(_loc3_[_loc6_]);
                  }
                  _loc6_++;
               }
               this.mEventListeners[param1] = _loc5_;
            }
         }
      }
      
      public function removeEventListeners(param1:String = null) : void
      {
         if(Boolean(param1) && Boolean(this.mEventListeners))
         {
            delete this.mEventListeners[param1];
         }
         else
         {
            this.mEventListeners = null;
         }
      }
      
      public function dispatchEvent(param1:Event) : void
      {
         var _loc2_:Boolean = param1.bubbles;
         if(!_loc2_ && (this.mEventListeners == null || !(param1.type in this.mEventListeners)))
         {
            return;
         }
         var _loc3_:EventDispatcher = param1.target;
         param1.setTarget(this);
         if(_loc2_ && this is DisplayObject)
         {
            this.bubble(param1);
         }
         else
         {
            this.invoke(param1);
         }
         if(_loc3_)
         {
            param1.setTarget(_loc3_);
         }
      }
      
      private function invoke(param1:Event) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:Function = null;
         var _loc6_:int = 0;
         var _loc2_:Vector.<Function> = this.mEventListeners ? this.mEventListeners[param1.type] : null;
         var _loc3_:int = _loc2_ == null ? 0 : int(_loc2_.length);
         if(_loc3_)
         {
            param1.setCurrentTarget(this);
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _loc5_ = _loc2_[_loc4_] as Function;
               _loc6_ = _loc5_.length;
               if(_loc6_ == 0)
               {
                  _loc5_();
               }
               else if(_loc6_ == 1)
               {
                  _loc5_(param1);
               }
               else
               {
                  _loc5_(param1,param1.data);
               }
               if(param1.stopsImmediatePropagation)
               {
                  return true;
               }
               _loc4_++;
            }
            return param1.stopsPropagation;
         }
         return false;
      }
      
      private function bubble(param1:Event) : void
      {
         var _loc2_:Vector.<EventDispatcher> = null;
         var _loc6_:Boolean = false;
         var _loc3_:DisplayObject = this as DisplayObject;
         var _loc4_:int = 1;
         if(sBubbleChains.length > 0)
         {
            _loc2_ = sBubbleChains.pop();
            _loc2_[0] = _loc3_;
         }
         else
         {
            _loc2_ = new <EventDispatcher>[_loc3_];
         }
         while(true)
         {
            _loc3_ = _loc3_.parent;
            if(_loc3_ == null)
            {
               break;
            }
            var _loc7_:*;
            _loc2_[_loc7_ = _loc4_++] = _loc3_;
         }
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc6_ = _loc2_[_loc5_].invoke(param1);
            if(_loc6_)
            {
               break;
            }
            _loc5_++;
         }
         _loc2_.length = 0;
         sBubbleChains.push(_loc2_);
      }
      
      public function dispatchEventWith(param1:String, param2:Boolean = false, param3:Object = null) : void
      {
         var _loc4_:Event = null;
         if(param2 || this.hasEventListener(param1))
         {
            _loc4_ = Event.starling_internal::fromPool(param1,param2,param3);
            this.dispatchEvent(_loc4_);
            Event.starling_internal::toPool(_loc4_);
         }
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         var _loc2_:Vector.<Function> = this.mEventListeners ? this.mEventListeners[param1] : null;
         return _loc2_ ? _loc2_.length != 0 : false;
      }
   }
}

