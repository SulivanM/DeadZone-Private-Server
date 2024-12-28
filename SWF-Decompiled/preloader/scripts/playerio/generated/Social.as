package playerio.generated
{
   import flash.events.EventDispatcher;
   import playerio.Client;
   import playerio.generated.messages.SocialLoadProfilesArgs;
   import playerio.generated.messages.SocialLoadProfilesError;
   import playerio.generated.messages.SocialLoadProfilesOutput;
   import playerio.generated.messages.SocialRefreshArgs;
   import playerio.generated.messages.SocialRefreshError;
   import playerio.generated.messages.SocialRefreshOutput;
   import playerio.utils.HTTPChannel;
   
   public class Social extends EventDispatcher
   {
      protected var channel:HTTPChannel;
      
      protected var client:Client;
      
      public function Social(param1:HTTPChannel, param2:Client)
      {
         super();
         this.channel = param1;
         this.client = param2;
      }
      
      protected function _socialRefresh(param1:Function = null, param2:Function = null) : void
      {
         var callback:Function = param1;
         var errorHandler:Function = param2;
         var input:SocialRefreshArgs = new SocialRefreshArgs();
         var output:SocialRefreshOutput = new SocialRefreshOutput();
         channel.Request(601,input,output,new SocialRefreshError(),function(param1:SocialRefreshOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.myProfile,param1.friends,param1.blocked);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("Social.socialRefresh",e);
                  throw e;
               }
            }
         },function(param1:SocialRefreshError):void
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
      
      protected function _socialLoadProfiles(param1:Array, param2:Function = null, param3:Function = null) : void
      {
         var userIds:Array = param1;
         var callback:Function = param2;
         var errorHandler:Function = param3;
         var input:SocialLoadProfilesArgs = new SocialLoadProfilesArgs(userIds);
         var output:SocialLoadProfilesOutput = new SocialLoadProfilesOutput();
         channel.Request(604,input,output,new SocialLoadProfilesError(),function(param1:SocialLoadProfilesOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.profiles);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("Social.socialLoadProfiles",e);
                  throw e;
               }
            }
         },function(param1:SocialLoadProfilesError):void
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

