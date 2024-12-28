package playerio
{
   import playerio.generated.BigDB;
   import playerio.generated.messages.BigDBChangeset;
   import playerio.generated.messages.BigDBObject;
   import playerio.generated.messages.BigDBObjectId;
   import playerio.generated.messages.NewBigDBObject;
   import playerio.utils.Converter;
   import playerio.utils.HTTPChannel;
   
   public class BigDB extends playerio.generated.BigDB
   {
      public function BigDB(param1:HTTPChannel, param2:Client)
      {
         super(param1,param2);
      }
      
      public function load(param1:String, param2:String, param3:Function = null, param4:Function = null) : void
      {
         var table:String = param1;
         var key:String = param2;
         var callback:Function = param3;
         var errorHandler:Function = param4;
         var db:BigDBObjectId = new BigDBObjectId();
         db.table = table;
         db.keys = [key];
         _loadObjects([db],function(param1:Array):void
         {
            if(callback != null)
            {
               callback(Converter.toDatabaseObject(table,param1[0],false,save));
            }
         },errorHandler);
      }
      
      public function loadOrCreate(param1:String, param2:String, param3:Function = null, param4:Function = null) : void
      {
         var table:String = param1;
         var key:String = param2;
         var callback:Function = param3;
         var errorHandler:Function = param4;
         var obj:NewBigDBObject = Converter.toNewBigDBObject(table,key,{});
         _createObjects([obj],true,function(param1:Array):void
         {
            if(callback != null)
            {
               callback(Converter.toDatabaseObject(table,param1[0],false,save));
            }
         },errorHandler);
      }
      
      public function loadKeys(param1:String, param2:Array, param3:Function = null, param4:Function = null) : void
      {
         var table:String = param1;
         var keys:Array = param2;
         var callback:Function = param3;
         var errorHandler:Function = param4;
         var db:BigDBObjectId = new BigDBObjectId();
         db.table = table;
         db.keys = keys;
         _loadObjects([db],function(param1:Array):void
         {
            if(callback != null)
            {
               callback(toDatabaseObjectArray(table,param1));
            }
         },errorHandler);
      }
      
      public function loadKeysOrCreate(param1:String, param2:Array, param3:Function = null, param4:Function = null) : void
      {
         var table:String = param1;
         var keys:Array = param2;
         var callback:Function = param3;
         var errorHandler:Function = param4;
         var objs:Array = [];
         var a:int = 0;
         while(a < keys.length)
         {
            objs.push(Converter.toNewBigDBObject(table,keys[a],{}));
            a++;
         }
         _createObjects(objs,true,function(param1:Array):void
         {
            if(callback != null)
            {
               callback(toDatabaseObjectArray(table,param1));
            }
         },errorHandler);
      }
      
      public function createObject(param1:String, param2:String, param3:Object, param4:Function = null, param5:Function = null) : void
      {
         var table:String = param1;
         var key:String = param2;
         var data:Object = param3;
         var callback:Function = param4;
         var errorHandler:Function = param5;
         var obj:NewBigDBObject = Converter.toNewBigDBObject(table,key,data);
         _createObjects([obj],false,function(param1:Array):void
         {
            param1[0].properties = obj.properties;
            if(callback != null)
            {
               callback(Converter.toDatabaseObject(table,param1[0],false,save));
            }
         },errorHandler);
      }
      
      public function loadMyPlayerObject(param1:Function = null, param2:Function = null) : void
      {
         var callback:Function = param1;
         var errorHandler:Function = param2;
         _loadMyPlayerObject(function(param1:BigDBObject):void
         {
            if(callback != null)
            {
               callback(Converter.toDatabaseObject("PlayerObjects",param1,true,save));
            }
         },errorHandler);
      }
      
      public function loadSingle(param1:String, param2:String, param3:Array, param4:Function = null, param5:Function = null) : void
      {
         var table:String = param1;
         var index:String = param2;
         var indexValue:Array = param3;
         var callback:Function = param4;
         var errorHandler:Function = param5;
         _loadMatchingObjects(table,index,Converter.toValueObjectArray(indexValue),1,function(param1:Array):void
         {
            if(callback != null)
            {
               callback(Converter.toDatabaseObject(table,param1[0],false,save));
            }
         },errorHandler);
      }
      
      public function loadRange(param1:String, param2:String, param3:Array, param4:Object, param5:Object, param6:int, param7:Function = null, param8:Function = null) : void
      {
         var table:String = param1;
         var index:String = param2;
         var path:Array = param3;
         var start:Object = param4;
         var stop:Object = param5;
         var limit:int = param6;
         var callback:Function = param7;
         var errorHandler:Function = param8;
         var startIndexValue:Array = start != null ? [start] : [];
         var stopIndexValue:Array = stop != null ? [stop] : [];
         if(path != null)
         {
            startIndexValue = path.concat(startIndexValue);
            stopIndexValue = path.concat(stopIndexValue);
         }
         _loadIndexRange(table,index,Converter.toValueObjectArray(startIndexValue),Converter.toValueObjectArray(stopIndexValue),limit,function(param1:Array):void
         {
            if(callback != null)
            {
               callback(toDatabaseObjectArray(table,param1));
            }
         },errorHandler);
      }
      
      public function deleteRange(param1:String, param2:String, param3:Array, param4:Object, param5:Object, param6:Function = null, param7:Function = null) : void
      {
         var _loc9_:Array = param4 != null ? [param4] : [];
         var _loc8_:Array = param5 != null ? [param5] : [];
         if(param3 != null)
         {
            _loc9_ = param3.concat(_loc9_);
            _loc8_ = param3.concat(_loc8_);
         }
         _deleteIndexRange(param1,param2,Converter.toValueObjectArray(_loc9_),Converter.toValueObjectArray(_loc8_),param6,param7);
      }
      
      public function deleteKeys(param1:String, param2:Array, param3:Function = null, param4:Function = null) : void
      {
         var _loc5_:BigDBObjectId = new BigDBObjectId();
         _loc5_.table = param1;
         _loc5_.keys = param2;
         _deleteObjects([_loc5_],param3,param4);
      }
      
      private function save(param1:String, param2:String, param3:String, param4:Object, param5:Boolean, param6:Boolean = false, param7:Function = null, param8:Function = null) : void
      {
         var obj:NewBigDBObject;
         var table:String = param1;
         var key:String = param2;
         var version:String = param3;
         var changeset:Object = param4;
         var useOptimisticLocks:Boolean = param5;
         var createIfMissing:Boolean = param6;
         var callback:Function = param7;
         var errorHandler:Function = param8;
         var cs:BigDBChangeset = new BigDBChangeset();
         cs.table = table;
         cs.key = key;
         if(useOptimisticLocks)
         {
            cs.onlyIfVersion = version;
         }
         obj = Converter.toNewBigDBObject(table,key,changeset);
         cs.changes = obj.properties;
         _saveObjectChanges(2,[cs],createIfMissing,function(param1:Array):void
         {
            callback(param1[0]);
         },errorHandler);
      }
      
      private function toDatabaseObjectArray(param1:String, param2:Array) : Array
      {
         var _loc4_:int = 0;
         var _loc3_:Array = [];
         _loc4_ = 0;
         while(_loc4_ < param2.length)
         {
            _loc3_.push(Converter.toDatabaseObject(param1,param2[_loc4_],false,save));
            _loc4_++;
         }
         return _loc3_;
      }
   }
}

