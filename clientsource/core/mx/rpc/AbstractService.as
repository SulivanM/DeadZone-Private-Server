package mx.rpc
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.Proxy;
   import flash.utils.flash_proxy;
   import mx.core.mx_internal;
   import mx.messaging.ChannelSet;
   import mx.resources.IResourceManager;
   import mx.resources.ResourceManager;
   import mx.rpc.events.AbstractEvent;
   
   use namespace mx_internal;
   use namespace flash_proxy;
   
   [Bindable(event="operationsChange")]
   public dynamic class AbstractService extends Proxy implements IEventDispatcher
   {
      
      private var resourceManager:IResourceManager = ResourceManager.getInstance();
      
      private var _managers:Array;
      
      mx_internal var _operations:Object;
      
      private var nextNameArray:Array;
      
      mx_internal var _availableChannelIds:Array;
      
      mx_internal var asyncRequest:AsyncRequest;
      
      private var eventDispatcher:EventDispatcher;
      
      private var _initialized:Boolean = false;
      
      public function AbstractService(param1:String = null)
      {
         super();
         this.eventDispatcher = new EventDispatcher(this);
         this.mx_internal::asyncRequest = new AsyncRequest();
         if(param1)
         {
            this.destination = param1;
            this.mx_internal::asyncRequest.destination = param1;
         }
         this.mx_internal::_operations = {};
      }
      
      public function get channelSet() : ChannelSet
      {
         return this.mx_internal::asyncRequest.channelSet;
      }
      
      public function set channelSet(param1:ChannelSet) : void
      {
         if(this.channelSet != param1)
         {
            this.mx_internal::asyncRequest.channelSet = param1;
         }
      }
      
      public function get destination() : String
      {
         return this.mx_internal::asyncRequest.destination;
      }
      
      public function set destination(param1:String) : void
      {
         this.mx_internal::asyncRequest.destination = param1;
      }
      
      public function get managers() : Array
      {
         return this._managers;
      }
      
      public function set managers(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(this._managers != null)
         {
            _loc2_ = 0;
            while(_loc2_ < this._managers.length)
            {
               _loc3_ = this._managers[_loc2_];
               if(_loc3_.hasOwnProperty("service"))
               {
                  _loc3_.service = null;
               }
               _loc2_++;
            }
         }
         this._managers = param1;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = this._managers[_loc2_];
            if(_loc3_.hasOwnProperty("service"))
            {
               _loc3_.service = this;
            }
            if(this._initialized && Boolean(_loc3_.hasOwnProperty("initialize")))
            {
               _loc3_.initialize();
            }
            _loc2_++;
         }
      }
      
      public function get operations() : Object
      {
         return this.mx_internal::_operations;
      }
      
      public function set operations(param1:Object) : void
      {
         var _loc2_:AbstractOperation = null;
         var _loc3_:String = null;
         for(_loc3_ in param1)
         {
            _loc2_ = AbstractOperation(param1[_loc3_]);
            _loc2_.mx_internal::setService(this);
            if(!_loc2_.name)
            {
               _loc2_.name = _loc3_;
            }
            _loc2_.mx_internal::asyncRequest = this.mx_internal::asyncRequest;
         }
         this.mx_internal::_operations = param1;
         this.dispatchEvent(new Event("operationsChange"));
      }
      
      public function get requestTimeout() : int
      {
         return this.mx_internal::asyncRequest.requestTimeout;
      }
      
      public function set requestTimeout(param1:int) : void
      {
         if(this.requestTimeout != param1)
         {
            this.mx_internal::asyncRequest.requestTimeout = param1;
         }
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this.eventDispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this.eventDispatcher.dispatchEvent(param1);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this.eventDispatcher.removeEventListener(param1,param2,param3);
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this.eventDispatcher.hasEventListener(param1);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this.eventDispatcher.willTrigger(param1);
      }
      
      public function initialize() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         if(!this._initialized && this._managers != null)
         {
            _loc1_ = 0;
            while(_loc1_ < this._managers.length)
            {
               _loc2_ = this._managers[_loc1_];
               if(_loc2_.hasOwnProperty("initialize"))
               {
                  _loc2_.initialize();
               }
               _loc1_++;
            }
            this._initialized = true;
         }
      }
      
      override flash_proxy function getProperty(param1:*) : *
      {
         return this.getOperation(this.mx_internal::getLocalName(param1));
      }
      
      override flash_proxy function setProperty(param1:*, param2:*) : void
      {
         var _loc3_:String = this.resourceManager.getString("rpc","operationsNotAllowedInService",[this.mx_internal::getLocalName(param1)]);
         throw new Error(_loc3_);
      }
      
      override flash_proxy function callProperty(param1:*, ... rest) : *
      {
         return this.getOperation(this.mx_internal::getLocalName(param1)).send.apply(null,rest);
      }
      
      override flash_proxy function nextNameIndex(param1:int) : int
      {
         var _loc2_:String = null;
         if(param1 == 0)
         {
            this.nextNameArray = [];
            for(_loc2_ in this.mx_internal::_operations)
            {
               this.nextNameArray.push(_loc2_);
            }
         }
         return param1 < this.nextNameArray.length ? param1 + 1 : 0;
      }
      
      override flash_proxy function nextName(param1:int) : String
      {
         return this.nextNameArray[param1 - 1];
      }
      
      override flash_proxy function nextValue(param1:int) : *
      {
         return this.mx_internal::_operations[this.nextNameArray[param1 - 1]];
      }
      
      mx_internal function getLocalName(param1:Object) : String
      {
         if(param1 is QName)
         {
            return QName(param1).localName;
         }
         return String(param1);
      }
      
      public function getOperation(param1:String) : AbstractOperation
      {
         var _loc2_:Object = this.mx_internal::_operations[param1];
         return _loc2_ is AbstractOperation ? AbstractOperation(_loc2_) : null;
      }
      
      public function disconnect() : void
      {
         this.mx_internal::asyncRequest.disconnect();
      }
      
      public function setCredentials(param1:String, param2:String, param3:String = null) : void
      {
         this.mx_internal::asyncRequest.setCredentials(param1,param2,param3);
      }
      
      public function logout() : void
      {
         this.mx_internal::asyncRequest.logout();
      }
      
      public function setRemoteCredentials(param1:String, param2:String, param3:String = null) : void
      {
         this.mx_internal::asyncRequest.setRemoteCredentials(param1,param2,param3);
      }
      
      public function valueOf() : Object
      {
         return this;
      }
      
      mx_internal function hasTokenResponders(param1:Event) : Boolean
      {
         var _loc2_:AbstractEvent = null;
         if(param1 is AbstractEvent)
         {
            _loc2_ = param1 as AbstractEvent;
            if(_loc2_.token != null && _loc2_.token.hasResponder())
            {
               return true;
            }
         }
         return false;
      }
   }
}

