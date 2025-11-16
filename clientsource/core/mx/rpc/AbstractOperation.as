package mx.rpc
{
   import mx.core.mx_internal;
   import mx.resources.IResourceManager;
   import mx.resources.ResourceManager;
   import mx.rpc.events.AbstractEvent;
   
   use namespace mx_internal;
   
   public class AbstractOperation extends AbstractInvoker
   {
      
      public var arguments:Object;
      
      public var properties:Object;
      
      private var resourceManager:IResourceManager = ResourceManager.getInstance();
      
      mx_internal var _service:AbstractService;
      
      private var _name:String;
      
      public function AbstractOperation(param1:AbstractService = null, param2:String = null)
      {
         super();
         this.mx_internal::_service = param1;
         this._name = param2;
         this.arguments = {};
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function set name(param1:String) : void
      {
         var _loc2_:String = null;
         if(!this._name)
         {
            this._name = param1;
            return;
         }
         _loc2_ = this.resourceManager.getString("rpc","cannotResetOperationName");
         throw new Error(_loc2_);
      }
      
      public function get service() : AbstractService
      {
         return this.mx_internal::_service;
      }
      
      mx_internal function setService(param1:AbstractService) : void
      {
         var _loc2_:String = null;
         if(!this.mx_internal::_service)
         {
            this.mx_internal::_service = param1;
            return;
         }
         _loc2_ = this.resourceManager.getString("rpc","cannotResetService");
         throw new Error(_loc2_);
      }
      
      public function send(... rest) : AsyncToken
      {
         return null;
      }
      
      override mx_internal function dispatchRpcEvent(param1:AbstractEvent) : void
      {
         param1.mx_internal::callTokenResponders();
         if(!param1.isDefaultPrevented())
         {
            if(hasEventListener(param1.type))
            {
               dispatchEvent(param1);
            }
            else if(this.mx_internal::_service != null)
            {
               this.mx_internal::_service.dispatchEvent(param1);
            }
         }
      }
   }
}

