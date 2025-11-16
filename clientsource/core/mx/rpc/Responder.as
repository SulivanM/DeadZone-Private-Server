package mx.rpc
{
   public class Responder implements IResponder
   {
      
      private var _resultHandler:Function;
      
      private var _faultHandler:Function;
      
      public function Responder(param1:Function, param2:Function)
      {
         super();
         this._resultHandler = param1;
         this._faultHandler = param2;
      }
      
      public function result(param1:Object) : void
      {
         this._resultHandler(param1);
      }
      
      public function fault(param1:Object) : void
      {
         this._faultHandler(param1);
      }
   }
}

