package playerio
{
   import playerio.helpers.FieldToBeRemoved;
   import playerio.utils.Converter;
   
   public dynamic class DatabaseObject
   {
      
      private var _table:String = "";
      
      private var _version:String = "";
      
      private var _creator:uint = 0;
      
      private var _key:String = "";
      
      private var _saveHandler:Function;
      
      private var _cache:DatabaseObject;
      
      private var _createIfMissing:Boolean = false;
      
      private var saveQueue:Array = [];
      
      private var inSave:Boolean = false;
      
      private var prefix:String = "    ";
      
      public function DatabaseObject(param1:String, param2:String, param3:String, param4:uint, param5:Boolean, param6:Function)
      {
         super();
         this._table = param1;
         this._version = param3;
         this._creator = param4;
         this._key = param2;
         this._saveHandler = param6;
         this._createIfMissing = param5;
      }
      
      public function save(param1:Boolean = false, param2:Boolean = false, param3:Function = null, param4:Function = null) : void
      {
         var _loc7_:SaveQueueItem = null;
         var _loc6_:SaveQueueItem = null;
         if(param2)
         {
            throw new Error("FullOverwrite is not yet supported by BigDB - Stay tuned at www.player.io for updates!",0);
         }
         var _loc5_:DatabaseObject = Converter.toDatabaseObject(table,Converter.toSparseBigDBObject(key,_version,_creator,this),_createIfMissing,null);
         if(inSave)
         {
            _loc7_ = saveQueue.length > 0 ? saveQueue[saveQueue.length - 1] : null;
            if(_loc7_ != null && _loc7_.useOptimisticLock == param1 && _loc7_.fullOverwrite == param2)
            {
               _loc7_.data = _loc5_;
               _loc7_.callbacks.push(param3);
               _loc7_.errorHandlers.push(param4);
            }
            else
            {
               _loc6_ = new SaveQueueItem();
               _loc6_.data = _loc5_;
               _loc6_.callbacks.push(param3);
               _loc6_.errorHandlers.push(param4);
               _loc6_.fullOverwrite = param2;
               _loc6_.useOptimisticLock = param1;
               saveQueue.push(_loc6_);
            }
            return;
         }
         doSave(_loc5_,param1,param2,param3,param4);
      }
      
      public function commit() : void
      {
         _cache = Converter.toDatabaseObject(table,Converter.toSparseBigDBObject(key,_version,_creator,this),_createIfMissing,null);
      }
      
      private function doSave(param1:DatabaseObject, param2:Boolean = false, param3:Boolean = false, param4:Function = null, param5:Function = null) : void
      {
         var changed:Boolean;
         var x:String;
         var cached:DatabaseObject = param1;
         var useOptimisticLock:Boolean = param2;
         var fullOverwrite:Boolean = param3;
         var callback:Function = param4;
         var errorHandler:Function = param5;
         inSave = true;
         var ret:Object = {};
         compareObject(_cache,cached,ret);
         changed = false;
         var _loc8_:int = 0;
         var _loc7_:Object = ret;
         for(x in _loc7_)
         {
            changed = true;
         }
         if(!changed)
         {
            if(callback != null)
            {
               callback();
            }
            emptyQueue();
            return;
         }
         this._saveHandler(_table,_key,_version,ret,useOptimisticLock,_createIfMissing,function(param1:String):void
         {
            if(param1 == null)
            {
               if(errorHandler == null)
               {
                  throw PlayerIOError.StaleVersion;
               }
               errorHandler(PlayerIOError.StaleVersion);
            }
            else
            {
               _version = param1;
               _cache = cached;
               if(callback != null)
               {
                  callback();
               }
            }
            emptyQueue();
         },function(param1:PlayerIOError):void
         {
            emptyQueue();
            if(errorHandler == null)
            {
               throw param1;
            }
            errorHandler(param1);
         });
      }
      
      private function emptyQueue() : void
      {
         var qi:SaveQueueItem;
         inSave = false;
         if(saveQueue.length != 0)
         {
            qi = saveQueue.shift();
            doSave(qi.data,qi.useOptimisticLock,qi.fullOverwrite,function():void
            {
               var _loc1_:int = 0;
               _loc1_ = 0;
               while(_loc1_ < qi.callbacks.length)
               {
                  if(qi.callbacks[_loc1_] != null)
                  {
                     qi.callbacks[_loc1_]();
                  }
                  _loc1_++;
               }
            },function(param1:PlayerIOError):void
            {
               var _loc2_:int = 0;
               _loc2_ = 0;
               while(_loc2_ < qi.errorHandlers.length)
               {
                  if(qi.errorHandlers[_loc2_] == null)
                  {
                     throw param1;
                  }
                  qi.errorHandlers[_loc2_](param1);
                  _loc2_++;
               }
            });
         }
      }
      
      public function get table() : String
      {
         return _table;
      }
      
      public function get key() : String
      {
         return _key;
      }
      
      private function compareObject(param1:Object, param2:Object, param3:Object = null) : Object
      {
         var x:String;
         var na:Array;
         var no:Object;
         var changed:Boolean;
         var nx:String;
         var before:Object = param1;
         var after:Object = param2;
         var target:Object = param3;
         var setProp:* = function(param1:String, param2:*):void
         {
            ret[param1] = param2;
         };
         var ret:Object = target || {};
         var prop:Object = mergePropertyList(before,after);
         for(x in prop)
         {
            if(before[x] !== after[x])
            {
               if(after[x] === undefined)
               {
                  setProp(x,new FieldToBeRemoved());
               }
               else if(before[x] is Array && after[x] is Array)
               {
                  na = objectToArray(compareObject(before[x],after[x]));
                  if(na.length > 0)
                  {
                     setProp(x,na);
                  }
               }
               else if(before[x] is Object && before[x].constructor == Object && after[x] is Object && after[x].constructor == Object)
               {
                  no = compareObject(before[x],after[x]);
                  changed = false;
                  var _loc6_:int = 0;
                  var _loc5_:Object = no;
                  for(nx in _loc5_)
                  {
                     changed = true;
                  }
                  if(changed)
                  {
                     setProp(x,no);
                  }
               }
               else
               {
                  setProp(x,after[x]);
               }
            }
         }
         return ret;
      }
      
      private function mergePropertyList(param1:Object, param2:Object) : Object
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:Object = {};
         if(param1 is Array)
         {
            _loc4_ = 0;
            while(_loc4_ < param1.length)
            {
               _loc3_[_loc4_] = true;
               _loc4_++;
            }
         }
         else
         {
            for(var _loc7_ in param1)
            {
               _loc3_[_loc7_] = true;
            }
         }
         if(param2 is Array)
         {
            _loc5_ = 0;
            while(_loc5_ < param2.length)
            {
               _loc3_[_loc5_] = true;
               _loc5_++;
            }
         }
         else
         {
            for(var _loc6_ in param2)
            {
               _loc3_[_loc6_] = true;
            }
         }
         return _loc3_;
      }
      
      private function objectToArray(param1:Object) : Array
      {
         var _loc2_:Array = [];
         for(var _loc3_ in param1)
         {
            _loc2_[parseInt(_loc3_)] = param1[_loc3_];
         }
         return _loc2_;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "[playerio.DatabaseObject]\n";
         return _loc1_ + (_table + "[\"" + key + "\"] = " + serialize(prefix,this) + " (Version:" + _version + ")");
      }
      
      private function serialize(param1:String, param2:*) : String
      {
         var _loc4_:int = 0;
         var _loc3_:String = "";
         var _loc6_:String = "";
         var _loc5_:Array = [];
         if(param2 is String)
         {
            return "\"" + param2 + "\"";
         }
         if(param2 is Array)
         {
            _loc3_ = "[\n";
            _loc4_ = 0;
            while(_loc4_ < param2.length)
            {
               if(param2[_loc4_] !== undefined)
               {
                  _loc5_.push({
                     "id":_loc4_,
                     "value":serialize(param1 + prefix,param2[_loc4_])
                  });
               }
               _loc4_++;
            }
            _loc5_.sortOn("id",16);
            _loc4_ = 0;
            while(_loc4_ < _loc5_.length)
            {
               _loc3_ += param1 + _loc5_[_loc4_].id + ":" + _loc5_[_loc4_].value + "\n";
               _loc4_++;
            }
            return _loc3_ + (param1.substring(4) + "]");
         }
         if(param2 is Object)
         {
            if(param2.constructor == Object || param2.constructor == DatabaseObject)
            {
               _loc3_ = "{\n";
               for(_loc6_ in param2)
               {
                  _loc5_.push({
                     "id":_loc6_,
                     "value":serialize(param1 + prefix,param2[_loc6_])
                  });
               }
               _loc5_.sortOn("id");
               _loc4_ = 0;
               while(_loc4_ < _loc5_.length)
               {
                  _loc3_ += param1 + _loc5_[_loc4_].id + ":" + _loc5_[_loc4_].value + "\n";
                  _loc4_++;
               }
               return _loc3_ + (param1.substring(4) + "}");
            }
         }
         switch(param2)
         {
            case null:
               return "null";
            case undefined:
               return "undefined";
            default:
               return param2.toString();
         }
      }
   }
}

class SaveQueueItem
{
   
   public var data:DatabaseObject;
   
   public var callbacks:Array = [];
   
   public var errorHandlers:Array = [];
   
   public var useOptimisticLock:Boolean;
   
   public var fullOverwrite:Boolean;
   
   public function SaveQueueItem()
   {
      super();
   }
}
