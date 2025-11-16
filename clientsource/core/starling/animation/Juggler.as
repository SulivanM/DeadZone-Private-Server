package starling.animation
{
   import starling.events.Event;
   import starling.events.EventDispatcher;
   
   public class Juggler implements IAnimatable
   {
      
      private var mObjects:Vector.<IAnimatable>;
      
      private var mElapsedTime:Number;
      
      public function Juggler()
      {
         super();
         this.mElapsedTime = 0;
         this.mObjects = new Vector.<IAnimatable>(0);
      }
      
      public function add(param1:IAnimatable) : void
      {
         var _loc2_:EventDispatcher = null;
         if(Boolean(param1) && this.mObjects.indexOf(param1) == -1)
         {
            this.mObjects.push(param1);
            _loc2_ = param1 as EventDispatcher;
            if(_loc2_)
            {
               _loc2_.addEventListener(Event.REMOVE_FROM_JUGGLER,this.onRemove);
            }
         }
      }
      
      public function remove(param1:IAnimatable) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:EventDispatcher = param1 as EventDispatcher;
         if(_loc2_)
         {
            _loc2_.removeEventListener(Event.REMOVE_FROM_JUGGLER,this.onRemove);
         }
         var _loc3_:int = int(this.mObjects.indexOf(param1));
         if(_loc3_ != -1)
         {
            this.mObjects[_loc3_] = null;
         }
      }
      
      public function removeTweens(param1:Object) : void
      {
         var _loc4_:Tween = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:int = int(this.mObjects.length);
         var _loc3_:int = _loc2_ - 1;
         while(_loc3_ >= 0)
         {
            _loc4_ = this.mObjects[_loc3_] as Tween;
            if((Boolean(_loc4_)) && _loc4_.target == param1)
            {
               this.mObjects[_loc3_] = null;
            }
            _loc3_--;
         }
      }
      
      public function purge() : void
      {
         var _loc2_:EventDispatcher = null;
         var _loc1_:int = int(this.mObjects.length - 1);
         while(_loc1_ >= 0)
         {
            _loc2_ = this.mObjects.pop() as EventDispatcher;
            if(_loc2_)
            {
               _loc2_.removeEventListener(Event.REMOVE_FROM_JUGGLER,this.onRemove);
            }
            _loc1_--;
         }
      }
      
      public function delayCall(param1:Function, param2:Number, ... rest) : DelayedCall
      {
         if(param1 == null)
         {
            return null;
         }
         var _loc4_:DelayedCall = new DelayedCall(param1,param2,rest);
         this.add(_loc4_);
         return _loc4_;
      }
      
      public function advanceTime(param1:Number) : void
      {
         var _loc4_:int = 0;
         var _loc5_:IAnimatable = null;
         var _loc2_:int = int(this.mObjects.length);
         var _loc3_:int = 0;
         this.mElapsedTime += param1;
         if(_loc2_ == 0)
         {
            return;
         }
         _loc4_ = 0;
         while(_loc4_ < _loc2_)
         {
            _loc5_ = this.mObjects[_loc4_];
            if(_loc5_)
            {
               if(_loc3_ != _loc4_)
               {
                  this.mObjects[_loc3_] = _loc5_;
                  this.mObjects[_loc4_] = null;
               }
               _loc5_.advanceTime(param1);
               _loc3_++;
            }
            _loc4_++;
         }
         if(_loc3_ != _loc4_)
         {
            _loc2_ = int(this.mObjects.length);
            while(_loc4_ < _loc2_)
            {
               var _loc6_:*;
               this.mObjects[_loc6_ = _loc3_++] = this.mObjects[_loc4_++];
            }
            this.mObjects.length = _loc3_;
         }
      }
      
      private function onRemove(param1:Event) : void
      {
         this.remove(param1.target as IAnimatable);
      }
      
      public function get elapsedTime() : Number
      {
         return this.mElapsedTime;
      }
   }
}

