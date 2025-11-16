package mx.rpc
{
   import mx.core.mx_internal;
   
   use namespace mx_internal;
   
   public class ActiveCalls
   {
      
      private var calls:Object;
      
      private var callOrder:Array;
      
      public function ActiveCalls()
      {
         super();
         this.calls = {};
         this.callOrder = [];
      }
      
      public function addCall(param1:String, param2:AsyncToken) : void
      {
         this.calls[param1] = param2;
         this.callOrder.push(param1);
      }
      
      public function getAllMessages() : Array
      {
         var _loc2_:String = null;
         var _loc1_:Array = [];
         for(_loc2_ in this.calls)
         {
            _loc1_.push(this.calls[_loc2_]);
         }
         return _loc1_;
      }
      
      public function cancelLast() : AsyncToken
      {
         if(this.callOrder.length > 0)
         {
            return this.removeCall(this.callOrder[this.callOrder.length - 1] as String);
         }
         return null;
      }
      
      public function hasActiveCalls() : Boolean
      {
         return this.callOrder.length > 0;
      }
      
      public function removeCall(param1:String) : AsyncToken
      {
         var _loc2_:AsyncToken = this.calls[param1];
         if(_loc2_ != null)
         {
            delete this.calls[param1];
            this.callOrder.splice(this.callOrder.lastIndexOf(param1),1);
         }
         return _loc2_;
      }
      
      public function wasLastCall(param1:String) : Boolean
      {
         if(this.callOrder.length > 0)
         {
            return this.callOrder[this.callOrder.length - 1] == param1;
         }
         return false;
      }
   }
}

