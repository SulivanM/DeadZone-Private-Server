package thelaststand.common.resources
{
   import flash.utils.Dictionary;
   import org.as3commons.zip.Zip;
   import org.as3commons.zip.ZipFile;
   import org.osflash.signals.Signal;
   import thelaststand.common.resources.formats.IFormatHandler;
   
   public class ResourceUnpacker
   {
      
      private var _currentPack:Zip;
      
      private var _currentPackSize:int;
      
      private var _currentFileIndex:int;
      
      private var _filesTotal:uint;
      
      private var _filesUnpacked:uint;
      
      private var _sizeTotal:uint;
      
      private var _sizeUnpacked:uint;
      
      private var _manager:ResourceManager;
      
      private var _purgeWhenDone:Boolean;
      
      private var _queue:Vector.<Resource>;
      
      public var unpackCompleted:Signal;
      
      public var unpackProgress:Signal;
      
      public function ResourceUnpacker()
      {
         super();
         this._queue = new Vector.<Resource>();
         this.unpackCompleted = new Signal();
         this.unpackProgress = new Signal(Resource,uint,uint);
      }
      
      public function addPackage(param1:Resource) : void
      {
         var _loc2_:Resource = null;
         var _loc3_:Zip = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:ZipFile = null;
         if(this._queue.indexOf(param1) > -1)
         {
            return;
         }
         if(param1.type != "zip")
         {
            throw new Error("Resource is not a valid zip package");
         }
         this._queue.push(param1);
         this._filesTotal = this._sizeTotal = 0;
         for each(_loc2_ in this._queue)
         {
            _loc3_ = Zip(_loc2_.content);
            _loc4_ = 0;
            _loc5_ = int(_loc3_.getFileCount());
            while(_loc4_ < _loc5_)
            {
               _loc6_ = _loc3_.getFileAt(_loc4_);
               if(!this.isDirectory(_loc6_.filename))
               {
                  ++this._filesTotal;
                  this._sizeTotal += _loc6_.sizeUncompressed;
               }
               _loc4_++;
            }
         }
      }
      
      public function dispose() : void
      {
         this.unpackCompleted.removeAll();
         this.unpackProgress.removeAll();
         this._currentPack = null;
         this._manager = null;
         this._queue = null;
      }
      
      public function removePackage(param1:Resource) : void
      {
         var _loc2_:int = int(this._queue.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         this._queue.splice(_loc2_,1);
      }
      
      public function unpack(param1:ResourceManager, param2:Boolean = false) : Dictionary
      {
         var _loc6_:Vector.<String> = null;
         var _loc7_:Zip = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         this._filesUnpacked = 0;
         this._manager = param1;
         this._purgeWhenDone = param2;
         if(this._queue.length == 0)
         {
            this.unpackCompleted.dispatch();
            return null;
         }
         var _loc3_:Dictionary = new Dictionary();
         var _loc4_:int = 0;
         var _loc5_:int = int(this._queue.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = new Vector.<String>();
            _loc3_[this._queue[0].uri.toLowerCase()] = _loc6_;
            _loc7_ = this._queue[0].content;
            _loc8_ = int(_loc7_.getFileCount());
            _loc9_ = 0;
            while(_loc9_ < _loc8_)
            {
               _loc6_.push(_loc7_.getFileAt(0).filename);
               _loc9_++;
            }
            _loc4_++;
         }
         this.doUnpack();
         return _loc3_;
      }
      
      private function doUnpack() : void
      {
         this._currentPack = this._queue[0].content;
         this._currentFileIndex = 0;
         this._currentPackSize = this._currentPack.getFileCount();
         if(this._currentPackSize == 0)
         {
            if(this._purgeWhenDone)
            {
               this._manager.purge(this._queue[0].uri);
            }
            this._queue.shift();
            if(this._queue.length == 0)
            {
               this.unpackCompleted.dispatch();
            }
            else
            {
               this.doUnpack();
            }
            return;
         }
         this.processFile(0);
      }
      
      private function isDirectory(param1:String) : Boolean
      {
         return param1.substr(param1.length - 1) == "/";
      }
      
      private function processFile(param1:int) : void
      {
         if(param1 < 0 || param1 >= this._currentPackSize)
         {
            return;
         }
         this._currentFileIndex = param1;
         var _loc2_:ZipFile = this._currentPack.getFileAt(this._currentFileIndex);
         if(this.isDirectory(_loc2_.filename))
         {
            this.processNext();
            return;
         }
         var _loc3_:IFormatHandler = ResourceManager.getResourceHandlerFromURI(_loc2_.filename);
         _loc3_.loadCompleted.addOnce(this.onFileComplete);
         _loc3_.loadFromByteArray(_loc2_.content);
      }
      
      private function processNext() : void
      {
         if(this._currentFileIndex < this._currentPackSize - 1)
         {
            this.processFile(this._currentFileIndex + 1);
         }
         else
         {
            if(this._purgeWhenDone)
            {
               this._manager.purge(this._queue[0].uri);
            }
            this._queue.shift();
            if(this._queue.length == 0)
            {
               this.unpackCompleted.dispatch();
               return;
            }
            this.doUnpack();
         }
      }
      
      private function onFileComplete(param1:IFormatHandler) : void
      {
         var _loc2_:ZipFile = this._currentPack.getFileAt(this._currentFileIndex);
         var _loc3_:Resource = new Resource(_loc2_.filename,param1.id,param1);
         _loc3_.content = param1.getContent();
         this._manager.addResource(_loc3_,_loc2_.filename,param1.id);
         ++this._filesUnpacked;
         this._sizeUnpacked += _loc2_.sizeUncompressed;
         this.unpackProgress.dispatch(_loc3_,this._sizeUnpacked,this._sizeTotal);
         this.processNext();
      }
   }
}

