package playerio
{
   import playerio.generated.GameRequests;
   import playerio.generated.PlayerIOError;
   import playerio.generated.messages.WaitingGameRequest;
   import playerio.utils.HTTPChannel;
   import playerio.utils.Utilities;
   
   public class GameRequests extends playerio.generated.GameRequests
   {
      private var _waitingRequests:Array;
      
      public function GameRequests(param1:HTTPChannel, param2:Client)
      {
         super(param1,param2);
      }
      
      public function get waitingRequests() : Array
      {
         if(_waitingRequests == null)
         {
            throw new playerio.generated.PlayerIOError("Cannot access requests before refresh() has been called.",playerio.PlayerIOError.GameRequestsNotLoaded.errorID);
         }
         return _waitingRequests;
      }
      
      public function send(param1:String, param2:Object, param3:Array, param4:Function, param5:Function) : void
      {
         _gameRequestsSend(param1,param2,param3,param4,param5);
      }
      
      public function refresh(param1:Function, param2:Function) : void
      {
         var callback:Function = param1;
         var errorCallback:Function = param2;
         _gameRequestsRefresh(null,function(param1:Array, param2:Boolean, param3:Array):void
         {
            read(param1,param2);
            if(callback != null)
            {
               callback();
            }
         },errorCallback);
      }
      
      public function remove(param1:Array, param2:Function, param3:Function) : void
      {
         var requests:Array = param1;
         var callback:Function = param2;
         var errorCallback:Function = param3;
         _gameRequestsDelete(requestArrayToRequestIdArray(requests),function(param1:Array, param2:Boolean):void
         {
            read(param1,param2);
            if(callback != null)
            {
               callback();
            }
         },errorCallback);
      }
      
      public function showSendDialog(param1:String, param2:Object, param3:Function) : void
      {
         var requestType:String = param1;
         var requestData:Object = param2;
         var callback:Function = param3;
         var args:Object = {};
         args["requestType"] = requestType;
         args["requestData"] = StringForm.encodeStringDictionary(requestData);
         PublishingNetwork._internal_showDialog("sendgamerequest",args,channel,function(param1:Object):void
         {
            var _loc2_:GameRequestSendDialogResult = null;
            if(callback != null)
            {
               _loc2_ = new GameRequestSendDialogResult();
               _loc2_._internal_initialize(param1["recipients"] != undefined ? StringForm.decodeStringArray(param1["recipients"]) : [],param1["recipientCountExternal"] != undefined ? int(param1["recipientCountExternal"]) : 0);
               callback(_loc2_);
            }
         });
      }
      
      private function requestArrayToRequestIdArray(param1:Array) : Array
      {
         var _loc3_:int = 0;
         var _loc2_:Array = [];
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_.push((param1[_loc3_] as GameRequest)._internal_id);
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function read(param1:Array, param2:Boolean) : Boolean
      {
         var i:int;
         var item:WaitingGameRequest;
         var gr:GameRequest;
         var requests:Array = param1;
         var moreRequestsWaiting:Boolean = param2;
         var anyNew:Boolean = false;
         var array:Array = [];
         if(requests != null)
         {
            i = 0;
            while(i < requests.length)
            {
               item = requests[i];
               gr = new GameRequest();
               gr._internal_initialize(item);
               array.push(gr);
               if(_waitingRequests != null)
               {
                  anyNew = anyNew || Utilities.find(_waitingRequests,function(param1:GameRequest):Boolean
                  {
                     return param1._internal_id == item.id;
                  }) == null;
               }
               i++;
            }
         }
         this._waitingRequests = array;
         return anyNew;
      }
   }
}

