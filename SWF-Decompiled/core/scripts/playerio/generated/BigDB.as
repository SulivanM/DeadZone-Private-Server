package playerio.generated
{
   import flash.events.EventDispatcher;
   import playerio.Client;
   import playerio.generated.messages.CreateObjectsArgs;
   import playerio.generated.messages.CreateObjectsError;
   import playerio.generated.messages.CreateObjectsOutput;
   import playerio.generated.messages.DeleteIndexRangeArgs;
   import playerio.generated.messages.DeleteIndexRangeError;
   import playerio.generated.messages.DeleteIndexRangeOutput;
   import playerio.generated.messages.DeleteObjectsArgs;
   import playerio.generated.messages.DeleteObjectsError;
   import playerio.generated.messages.DeleteObjectsOutput;
   import playerio.generated.messages.LoadIndexRangeArgs;
   import playerio.generated.messages.LoadIndexRangeError;
   import playerio.generated.messages.LoadIndexRangeOutput;
   import playerio.generated.messages.LoadMatchingObjectsArgs;
   import playerio.generated.messages.LoadMatchingObjectsError;
   import playerio.generated.messages.LoadMatchingObjectsOutput;
   import playerio.generated.messages.LoadMyPlayerObjectArgs;
   import playerio.generated.messages.LoadMyPlayerObjectError;
   import playerio.generated.messages.LoadMyPlayerObjectOutput;
   import playerio.generated.messages.LoadObjectsArgs;
   import playerio.generated.messages.LoadObjectsError;
   import playerio.generated.messages.LoadObjectsOutput;
   import playerio.generated.messages.SaveObjectChangesArgs;
   import playerio.generated.messages.SaveObjectChangesError;
   import playerio.generated.messages.SaveObjectChangesOutput;
   import playerio.utils.HTTPChannel;
   
   public class BigDB extends EventDispatcher
   {
      protected var channel:HTTPChannel;
      
      protected var client:Client;
      
      public function BigDB(param1:HTTPChannel, param2:Client)
      {
         super();
         this.channel = param1;
         this.client = param2;
      }
      
      protected function _createObjects(param1:Array, param2:Boolean, param3:Function = null, param4:Function = null) : void
      {
         var objects:Array = param1;
         var loadExisting:Boolean = param2;
         var callback:Function = param3;
         var errorHandler:Function = param4;
         var input:CreateObjectsArgs = new CreateObjectsArgs(objects,loadExisting);
         var output:CreateObjectsOutput = new CreateObjectsOutput();
         channel.Request(82,input,output,new CreateObjectsError(),function(param1:CreateObjectsOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.objects);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("BigDB.createObjects",e);
                  throw e;
               }
            }
         },function(param1:CreateObjectsError):void
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
      
      protected function _loadObjects(param1:Array, param2:Function = null, param3:Function = null) : void
      {
         var objectIds:Array = param1;
         var callback:Function = param2;
         var errorHandler:Function = param3;
         var input:LoadObjectsArgs = new LoadObjectsArgs(objectIds);
         var output:LoadObjectsOutput = new LoadObjectsOutput();
         channel.Request(85,input,output,new LoadObjectsError(),function(param1:LoadObjectsOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.objects);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("BigDB.loadObjects",e);
                  throw e;
               }
            }
         },function(param1:LoadObjectsError):void
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
      
      protected function _saveObjectChanges(param1:int, param2:Array, param3:Boolean, param4:Function = null, param5:Function = null) : void
      {
         var lockType:int = param1;
         var changesets:Array = param2;
         var createIfMissing:Boolean = param3;
         var callback:Function = param4;
         var errorHandler:Function = param5;
         var input:SaveObjectChangesArgs = new SaveObjectChangesArgs(lockType,changesets,createIfMissing);
         var output:SaveObjectChangesOutput = new SaveObjectChangesOutput();
         channel.Request(88,input,output,new SaveObjectChangesError(),function(param1:SaveObjectChangesOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.versions);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("BigDB.saveObjectChanges",e);
                  throw e;
               }
            }
         },function(param1:SaveObjectChangesError):void
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
      
      protected function _deleteObjects(param1:Array, param2:Function = null, param3:Function = null) : void
      {
         var objectIds:Array = param1;
         var callback:Function = param2;
         var errorHandler:Function = param3;
         var input:DeleteObjectsArgs = new DeleteObjectsArgs(objectIds);
         var output:DeleteObjectsOutput = new DeleteObjectsOutput();
         channel.Request(91,input,output,new DeleteObjectsError(),function(param1:DeleteObjectsOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback();
               }
               catch(e:Error)
               {
                  client.handleCallbackError("BigDB.deleteObjects",e);
                  throw e;
               }
            }
         },function(param1:DeleteObjectsError):void
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
      
      protected function _loadMyPlayerObject(param1:Function = null, param2:Function = null) : void
      {
         var callback:Function = param1;
         var errorHandler:Function = param2;
         var input:LoadMyPlayerObjectArgs = new LoadMyPlayerObjectArgs();
         var output:LoadMyPlayerObjectOutput = new LoadMyPlayerObjectOutput();
         channel.Request(103,input,output,new LoadMyPlayerObjectError(),function(param1:LoadMyPlayerObjectOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.playerObject);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("BigDB.loadMyPlayerObject",e);
                  throw e;
               }
            }
         },function(param1:LoadMyPlayerObjectError):void
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
      
      protected function _loadMatchingObjects(param1:String, param2:String, param3:Array, param4:int, param5:Function = null, param6:Function = null) : void
      {
         var table:String = param1;
         var index:String = param2;
         var indexValue:Array = param3;
         var limit:int = param4;
         var callback:Function = param5;
         var errorHandler:Function = param6;
         var input:LoadMatchingObjectsArgs = new LoadMatchingObjectsArgs(table,index,indexValue,limit);
         var output:LoadMatchingObjectsOutput = new LoadMatchingObjectsOutput();
         channel.Request(94,input,output,new LoadMatchingObjectsError(),function(param1:LoadMatchingObjectsOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.objects);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("BigDB.loadMatchingObjects",e);
                  throw e;
               }
            }
         },function(param1:LoadMatchingObjectsError):void
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
      
      protected function _loadIndexRange(param1:String, param2:String, param3:Array, param4:Array, param5:int, param6:Function = null, param7:Function = null) : void
      {
         var table:String = param1;
         var index:String = param2;
         var startIndexValue:Array = param3;
         var stopIndexValue:Array = param4;
         var limit:int = param5;
         var callback:Function = param6;
         var errorHandler:Function = param7;
         var input:LoadIndexRangeArgs = new LoadIndexRangeArgs(table,index,startIndexValue,stopIndexValue,limit);
         var output:LoadIndexRangeOutput = new LoadIndexRangeOutput();
         channel.Request(97,input,output,new LoadIndexRangeError(),function(param1:LoadIndexRangeOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback(param1.objects);
               }
               catch(e:Error)
               {
                  client.handleCallbackError("BigDB.loadIndexRange",e);
                  throw e;
               }
            }
         },function(param1:LoadIndexRangeError):void
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
      
      protected function _deleteIndexRange(param1:String, param2:String, param3:Array, param4:Array, param5:Function = null, param6:Function = null) : void
      {
         var table:String = param1;
         var index:String = param2;
         var startIndexValue:Array = param3;
         var stopIndexValue:Array = param4;
         var callback:Function = param5;
         var errorHandler:Function = param6;
         var input:DeleteIndexRangeArgs = new DeleteIndexRangeArgs(table,index,startIndexValue,stopIndexValue);
         var output:DeleteIndexRangeOutput = new DeleteIndexRangeOutput();
         channel.Request(100,input,output,new DeleteIndexRangeError(),function(param1:DeleteIndexRangeOutput):void
         {
            if(callback != null)
            {
               try
               {
                  callback();
               }
               catch(e:Error)
               {
                  client.handleCallbackError("BigDB.deleteIndexRange",e);
                  throw e;
               }
            }
         },function(param1:DeleteIndexRangeError):void
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

