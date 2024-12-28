package playerio.generated
{
   import flash.events.EventDispatcher;
   import playerio.Client;
   import playerio.generated.messages.AchievementsLoadArgs;
   import playerio.generated.messages.AchievementsLoadError;
   import playerio.generated.messages.AchievementsLoadOutput;
   import playerio.generated.messages.AchievementsProgressAddArgs;
   import playerio.generated.messages.AchievementsProgressAddError;
   import playerio.generated.messages.AchievementsProgressAddOutput;
   import playerio.generated.messages.AchievementsProgressCompleteArgs;
   import playerio.generated.messages.AchievementsProgressCompleteError;
   import playerio.generated.messages.AchievementsProgressCompleteOutput;
   import playerio.generated.messages.AchievementsProgressMaxArgs;
   import playerio.generated.messages.AchievementsProgressMaxError;
   import playerio.generated.messages.AchievementsProgressMaxOutput;
   import playerio.generated.messages.AchievementsProgressSetArgs;
   import playerio.generated.messages.AchievementsProgressSetError;
   import playerio.generated.messages.AchievementsProgressSetOutput;
   import playerio.generated.messages.AchievementsRefreshArgs;
   import playerio.generated.messages.AchievementsRefreshError;
   import playerio.generated.messages.AchievementsRefreshOutput;
   import playerio.utils.HTTPChannel;
   
   public class Achievements extends EventDispatcher
   {
      protected var channel:HTTPChannel;
      
      protected var client:Client;
      
      public function Achievements(param1:HTTPChannel, param2:Client)
      {
         super();
         this.channel = param1;
         this.client = param2;
      }
      
      protected function _achievementsRefresh(param1:String, param2:Function = null, param3:Function = null) : void
      {
         var lastVersion:String = param1;
         var callback:Function = param2;
         var errorHandler:Function = param3;
         var input:AchievementsRefreshArgs = new AchievementsRefreshArgs(lastVersion);
         var output:AchievementsRefreshOutput = new AchievementsRefreshOutput();
         channel.Request(271,input,output,new AchievementsRefreshError(),function(param1:AchievementsRefreshOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.version,param1.achievements);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("Achievements.achievementsRefresh",e);
                  throw e;
               }
            }
         },function(param1:AchievementsRefreshError):void
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
      
      protected function _achievementsLoad(param1:Array, param2:Function = null, param3:Function = null) : void
      {
         var userIds:Array = param1;
         var callback:Function = param2;
         var errorHandler:Function = param3;
         var input:AchievementsLoadArgs = new AchievementsLoadArgs(userIds);
         var output:AchievementsLoadOutput = new AchievementsLoadOutput();
         channel.Request(274,input,output,new AchievementsLoadError(),function(param1:AchievementsLoadOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.userAchievements);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("Achievements.achievementsLoad",e);
                  throw e;
               }
            }
         },function(param1:AchievementsLoadError):void
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
      
      protected function _achievementsProgressSet(param1:String, param2:int, param3:Function = null, param4:Function = null) : void
      {
         var achievementId:String = param1;
         var progress:int = param2;
         var callback:Function = param3;
         var errorHandler:Function = param4;
         var input:AchievementsProgressSetArgs = new AchievementsProgressSetArgs(achievementId,progress);
         var output:AchievementsProgressSetOutput = new AchievementsProgressSetOutput();
         channel.Request(277,input,output,new AchievementsProgressSetError(),function(param1:AchievementsProgressSetOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.achievement,param1.completedNow);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("Achievements.achievementsProgressSet",e);
                  throw e;
               }
            }
         },function(param1:AchievementsProgressSetError):void
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
      
      protected function _achievementsProgressAdd(param1:String, param2:int, param3:Function = null, param4:Function = null) : void
      {
         var achievementId:String = param1;
         var progressDelta:int = param2;
         var callback:Function = param3;
         var errorHandler:Function = param4;
         var input:AchievementsProgressAddArgs = new AchievementsProgressAddArgs(achievementId,progressDelta);
         var output:AchievementsProgressAddOutput = new AchievementsProgressAddOutput();
         channel.Request(280,input,output,new AchievementsProgressAddError(),function(param1:AchievementsProgressAddOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.achievement,param1.completedNow);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("Achievements.achievementsProgressAdd",e);
                  throw e;
               }
            }
         },function(param1:AchievementsProgressAddError):void
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
      
      protected function _achievementsProgressMax(param1:String, param2:int, param3:Function = null, param4:Function = null) : void
      {
         var achievementId:String = param1;
         var progress:int = param2;
         var callback:Function = param3;
         var errorHandler:Function = param4;
         var input:AchievementsProgressMaxArgs = new AchievementsProgressMaxArgs(achievementId,progress);
         var output:AchievementsProgressMaxOutput = new AchievementsProgressMaxOutput();
         channel.Request(283,input,output,new AchievementsProgressMaxError(),function(param1:AchievementsProgressMaxOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.achievement,param1.completedNow);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("Achievements.achievementsProgressMax",e);
                  throw e;
               }
            }
         },function(param1:AchievementsProgressMaxError):void
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
      
      protected function _achievementsProgressComplete(param1:String, param2:Function = null, param3:Function = null) : void
      {
         var achievementId:String = param1;
         var callback:Function = param2;
         var errorHandler:Function = param3;
         var input:AchievementsProgressCompleteArgs = new AchievementsProgressCompleteArgs(achievementId);
         var output:AchievementsProgressCompleteOutput = new AchievementsProgressCompleteOutput();
         channel.Request(286,input,output,new AchievementsProgressCompleteError(),function(param1:AchievementsProgressCompleteOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.achievement,param1.completedNow);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("Achievements.achievementsProgressComplete",e);
                  throw e;
               }
            }
         },function(param1:AchievementsProgressCompleteError):void
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

