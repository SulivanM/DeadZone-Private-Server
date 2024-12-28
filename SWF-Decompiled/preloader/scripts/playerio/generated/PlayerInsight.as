package playerio.generated
{
   import flash.events.EventDispatcher;
   import playerio.Client;
   import playerio.generated.messages.PlayerInsightRefreshArgs;
   import playerio.generated.messages.PlayerInsightRefreshError;
   import playerio.generated.messages.PlayerInsightRefreshOutput;
   import playerio.generated.messages.PlayerInsightSessionKeepAliveArgs;
   import playerio.generated.messages.PlayerInsightSessionKeepAliveError;
   import playerio.generated.messages.PlayerInsightSessionKeepAliveOutput;
   import playerio.generated.messages.PlayerInsightSessionStopArgs;
   import playerio.generated.messages.PlayerInsightSessionStopError;
   import playerio.generated.messages.PlayerInsightSessionStopOutput;
   import playerio.generated.messages.PlayerInsightSetSegmentsArgs;
   import playerio.generated.messages.PlayerInsightSetSegmentsError;
   import playerio.generated.messages.PlayerInsightSetSegmentsOutput;
   import playerio.generated.messages.PlayerInsightTrackEventsArgs;
   import playerio.generated.messages.PlayerInsightTrackEventsError;
   import playerio.generated.messages.PlayerInsightTrackEventsOutput;
   import playerio.generated.messages.PlayerInsightTrackExternalPaymentArgs;
   import playerio.generated.messages.PlayerInsightTrackExternalPaymentError;
   import playerio.generated.messages.PlayerInsightTrackExternalPaymentOutput;
   import playerio.generated.messages.PlayerInsightTrackInvitedByArgs;
   import playerio.generated.messages.PlayerInsightTrackInvitedByError;
   import playerio.generated.messages.PlayerInsightTrackInvitedByOutput;
   import playerio.utils.HTTPChannel;
   
   public class PlayerInsight extends EventDispatcher
   {
      protected var channel:HTTPChannel;
      
      protected var client:Client;
      
      public function PlayerInsight(param1:HTTPChannel, param2:Client)
      {
         super();
         this.channel = param1;
         this.client = param2;
      }
      
      protected function _playerInsightRefresh(param1:Function = null, param2:Function = null) : void
      {
         var callback:Function = param1;
         var errorHandler:Function = param2;
         var input:PlayerInsightRefreshArgs = new PlayerInsightRefreshArgs();
         var output:PlayerInsightRefreshOutput = new PlayerInsightRefreshOutput();
         channel.Request(301,input,output,new PlayerInsightRefreshError(),function(param1:PlayerInsightRefreshOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.state);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("PlayerInsight.playerInsightRefresh",e);
                  throw e;
               }
            }
         },function(param1:PlayerInsightRefreshError):void
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
      
      protected function _playerInsightSetSegments(param1:Array, param2:Function = null, param3:Function = null) : void
      {
         var segments:Array = param1;
         var callback:Function = param2;
         var errorHandler:Function = param3;
         var input:PlayerInsightSetSegmentsArgs = new PlayerInsightSetSegmentsArgs(segments);
         var output:PlayerInsightSetSegmentsOutput = new PlayerInsightSetSegmentsOutput();
         channel.Request(304,input,output,new PlayerInsightSetSegmentsError(),function(param1:PlayerInsightSetSegmentsOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.state);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("PlayerInsight.playerInsightSetSegments",e);
                  throw e;
               }
            }
         },function(param1:PlayerInsightSetSegmentsError):void
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
      
      protected function _playerInsightTrackInvitedBy(param1:String, param2:String, param3:Function = null, param4:Function = null) : void
      {
         var invitingUserId:String = param1;
         var invitationChannel:String = param2;
         var callback:Function = param3;
         var errorHandler:Function = param4;
         var input:PlayerInsightTrackInvitedByArgs = new PlayerInsightTrackInvitedByArgs(invitingUserId,invitationChannel);
         var output:PlayerInsightTrackInvitedByOutput = new PlayerInsightTrackInvitedByOutput();
         channel.Request(307,input,output,new PlayerInsightTrackInvitedByError(),function(param1:PlayerInsightTrackInvitedByOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback();
               }
               catch(e:Error)
               {
                  client.handleCallbackError("PlayerInsight.playerInsightTrackInvitedBy",e);
                  throw e;
               }
            }
         },function(param1:PlayerInsightTrackInvitedByError):void
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
      
      protected function _playerInsightTrackEvents(param1:Array, param2:Function = null, param3:Function = null) : void
      {
         var events:Array = param1;
         var callback:Function = param2;
         var errorHandler:Function = param3;
         var input:PlayerInsightTrackEventsArgs = new PlayerInsightTrackEventsArgs(events);
         var output:PlayerInsightTrackEventsOutput = new PlayerInsightTrackEventsOutput();
         channel.Request(311,input,output,new PlayerInsightTrackEventsError(),function(param1:PlayerInsightTrackEventsOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback();
               }
               catch(e:Error)
               {
                  client.handleCallbackError("PlayerInsight.playerInsightTrackEvents",e);
                  throw e;
               }
            }
         },function(param1:PlayerInsightTrackEventsError):void
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
      
      protected function _playerInsightTrackExternalPayment(param1:String, param2:int, param3:Function = null, param4:Function = null) : void
      {
         var currency:String = param1;
         var amount:int = param2;
         var callback:Function = param3;
         var errorHandler:Function = param4;
         var input:PlayerInsightTrackExternalPaymentArgs = new PlayerInsightTrackExternalPaymentArgs(currency,amount);
         var output:PlayerInsightTrackExternalPaymentOutput = new PlayerInsightTrackExternalPaymentOutput();
         channel.Request(314,input,output,new PlayerInsightTrackExternalPaymentError(),function(param1:PlayerInsightTrackExternalPaymentOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback();
               }
               catch(e:Error)
               {
                  client.handleCallbackError("PlayerInsight.playerInsightTrackExternalPayment",e);
                  throw e;
               }
            }
         },function(param1:PlayerInsightTrackExternalPaymentError):void
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
      
      public function playerInsightSessionKeepAlive(param1:Function = null, param2:Function = null) : void
      {
         var callback:Function = param1;
         var errorHandler:Function = param2;
         var input:PlayerInsightSessionKeepAliveArgs = new PlayerInsightSessionKeepAliveArgs();
         var output:PlayerInsightSessionKeepAliveOutput = new PlayerInsightSessionKeepAliveOutput();
         channel.Request(317,input,output,new PlayerInsightSessionKeepAliveError(),function(param1:PlayerInsightSessionKeepAliveOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback();
               }
               catch(e:Error)
               {
                  client.handleCallbackError("PlayerInsight.playerInsightSessionKeepAlive",e);
                  throw e;
               }
            }
         },function(param1:PlayerInsightSessionKeepAliveError):void
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
      
      public function playerInsightSessionStop(param1:Function = null, param2:Function = null) : void
      {
         var callback:Function = param1;
         var errorHandler:Function = param2;
         var input:PlayerInsightSessionStopArgs = new PlayerInsightSessionStopArgs();
         var output:PlayerInsightSessionStopOutput = new PlayerInsightSessionStopOutput();
         channel.Request(320,input,output,new PlayerInsightSessionStopError(),function(param1:PlayerInsightSessionStopOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback();
               }
               catch(e:Error)
               {
                  client.handleCallbackError("PlayerInsight.playerInsightSessionStop",e);
                  throw e;
               }
            }
         },function(param1:PlayerInsightSessionStopError):void
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

