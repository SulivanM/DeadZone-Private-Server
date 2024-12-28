package playerio.generated
{
   import flash.events.EventDispatcher;
   import playerio.Client;
   import playerio.generated.messages.OneScoreAddArgs;
   import playerio.generated.messages.OneScoreAddError;
   import playerio.generated.messages.OneScoreAddOutput;
   import playerio.generated.messages.OneScoreLoadArgs;
   import playerio.generated.messages.OneScoreLoadError;
   import playerio.generated.messages.OneScoreLoadOutput;
   import playerio.generated.messages.OneScoreRefreshArgs;
   import playerio.generated.messages.OneScoreRefreshError;
   import playerio.generated.messages.OneScoreRefreshOutput;
   import playerio.generated.messages.OneScoreSetArgs;
   import playerio.generated.messages.OneScoreSetError;
   import playerio.generated.messages.OneScoreSetOutput;
   import playerio.utils.HTTPChannel;
   
   public class OneScore extends EventDispatcher
   {
      protected var channel:HTTPChannel;
      
      protected var client:Client;
      
      public function OneScore(param1:HTTPChannel, param2:Client)
      {
         super();
         this.channel = param1;
         this.client = param2;
      }
      
      protected function _oneScoreRefresh(param1:Function = null, param2:Function = null) : void
      {
         var callback:Function = param1;
         var errorHandler:Function = param2;
         var input:OneScoreRefreshArgs = new OneScoreRefreshArgs();
         var output:OneScoreRefreshOutput = new OneScoreRefreshOutput();
         channel.Request(360,input,output,new OneScoreRefreshError(),function(param1:OneScoreRefreshOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.oneScore);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("OneScore.oneScoreRefresh",e);
                  throw e;
               }
            }
         },function(param1:OneScoreRefreshError):void
         {
            var _loc2_:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
            if(errorHandler != null)
            {
               errorHandler(_loc2_);
               return;
            }
            throw _loc2_;
         });
      }
      
      protected function _oneScoreSet(param1:int, param2:Function = null, param3:Function = null) : void
      {
         var score:int = param1;
         var callback:Function = param2;
         var errorHandler:Function = param3;
         var input:OneScoreSetArgs = new OneScoreSetArgs(score);
         var output:OneScoreSetOutput = new OneScoreSetOutput();
         channel.Request(354,input,output,new OneScoreSetError(),function(param1:OneScoreSetOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.oneScore);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("OneScore.oneScoreSet",e);
                  throw e;
               }
            }
         },function(param1:OneScoreSetError):void
         {
            var _loc2_:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
            if(errorHandler != null)
            {
               errorHandler(_loc2_);
               return;
            }
            throw _loc2_;
         });
      }
      
      protected function _oneScoreAdd(param1:int, param2:Function = null, param3:Function = null) : void
      {
         var score:int = param1;
         var callback:Function = param2;
         var errorHandler:Function = param3;
         var input:OneScoreAddArgs = new OneScoreAddArgs(score);
         var output:OneScoreAddOutput = new OneScoreAddOutput();
         channel.Request(357,input,output,new OneScoreAddError(),function(param1:OneScoreAddOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.oneScore);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("OneScore.oneScoreAdd",e);
                  throw e;
               }
            }
         },function(param1:OneScoreAddError):void
         {
            var _loc2_:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
            if(errorHandler != null)
            {
               errorHandler(_loc2_);
               return;
            }
            throw _loc2_;
         });
      }
      
      protected function _oneScoreLoad(param1:Array, param2:Function = null, param3:Function = null) : void
      {
         var userIds:Array = param1;
         var callback:Function = param2;
         var errorHandler:Function = param3;
         var input:OneScoreLoadArgs = new OneScoreLoadArgs(userIds);
         var output:OneScoreLoadOutput = new OneScoreLoadOutput();
         channel.Request(351,input,output,new OneScoreLoadError(),function(param1:OneScoreLoadOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.oneScores);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("OneScore.oneScoreLoad",e);
                  throw e;
               }
            }
         },function(param1:OneScoreLoadError):void
         {
            var _loc2_:PlayerIOError = new PlayerIOError(param1.message,param1.errorCode);
            if(errorHandler != null)
            {
               errorHandler(_loc2_);
               return;
            }
            throw _loc2_;
         });
      }
   }
}

