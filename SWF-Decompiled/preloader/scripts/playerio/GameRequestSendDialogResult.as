package playerio
{
   public class GameRequestSendDialogResult
   {
      private var _recipientCountExternal:int;
      
      private var _recipients:Array;
      
      public function GameRequestSendDialogResult()
      {
         super();
      }
      
      internal function _internal_initialize(param1:Array, param2:int) : void
      {
         this._recipientCountExternal = param2;
         this._recipients = param1;
      }
      
      public function get recipients() : Array
      {
         return _recipients;
      }
   }
}

