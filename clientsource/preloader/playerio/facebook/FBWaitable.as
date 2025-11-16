package playerio.facebook
{
   import flash.events.*;
   import flash.external.*;
   import flash.system.*;
   import flash.utils.*;
   
   public class FBWaitable
   {
      
      private var subscribers:Object = {};
      
      private var _value:Object = null;
      
      public function FBWaitable()
      {
         super();
      }
      
      public function set value(param1:Object) : void
      {
         if(JSON2.serialize(param1) != JSON2.serialize(this._value))
         {
            this._value = param1;
            this.fire("value",param1);
         }
      }
      
      public function get value() : Object
      {
         return this._value;
      }
      
      public function error(param1:Error) : void
      {
         this.fire("error",param1);
      }
      
      public function wait(param1:Function, ... rest) : void
      {
         var t:* = undefined;
         var callback:Function = param1;
         var args:Array = rest;
         var errorHandler:Function = args.length == 1 && args[0] is Function ? args[0] : null;
         if(errorHandler != null)
         {
            this.subscribe("error",errorHandler);
         }
         t = this;
         this.monitor("value",function():Boolean
         {
            if(t.value != null)
            {
               callback(t.value);
               return true;
            }
            return false;
         });
      }
      
      public function subscribe(param1:String, param2:Function) : void
      {
         if(!this.subscribers[param1])
         {
            this.subscribers[param1] = [param2];
         }
         else
         {
            this.subscribers[param1].push(param2);
         }
      }
      
      public function unsubscribe(param1:String, param2:Function) : void
      {
         var _loc4_:int = 0;
         var _loc3_:Array = this.subscribers[param1];
         if(_loc3_)
         {
            _loc4_ = 0;
            while(_loc4_ != _loc3_.length)
            {
               if(_loc3_[_loc4_] == param2)
               {
                  _loc3_[_loc4_] = null;
               }
               _loc4_++;
            }
         }
      }
      
      public function monitor(param1:String, param2:Function) : void
      {
         var ctx:FBWaitable = null;
         var fn:Function = null;
         var name:String = param1;
         var callback:Function = param2;
         if(!callback())
         {
            ctx = this;
            fn = function(... rest):void
            {
               if(callback.apply(callback,rest))
               {
                  ctx.unsubscribe(name,fn);
               }
            };
            this.subscribe(name,fn);
         }
      }
      
      public function clear(param1:String) : void
      {
         delete this.subscribers[param1];
      }
      
      public function fire(param1:String, ... rest) : void
      {
         var _loc4_:int = 0;
         var _loc3_:Array = this.subscribers[param1];
         if(_loc3_)
         {
            _loc4_ = 0;
            while(_loc4_ != _loc3_.length)
            {
               if(_loc3_[_loc4_] != null)
               {
                  _loc3_[_loc4_].apply(this,rest);
               }
               _loc4_++;
            }
         }
      }
   }
}

