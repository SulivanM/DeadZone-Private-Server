package mx.messaging
{
   import flash.events.EventDispatcher;
   import mx.core.mx_internal;
   import mx.events.PropertyChangeEvent;
   
   use namespace mx_internal;
   
   public class FlexClient extends EventDispatcher
   {
      
      private static var _instance:FlexClient;
      
      mx_internal static const NULL_FLEXCLIENT_ID:String = "nil";
      
      private var _id:String;
      
      private var _waitForFlexClientId:Boolean = false;
      
      public function FlexClient()
      {
         super();
      }
      
      public static function getInstance() : FlexClient
      {
         if(_instance == null)
         {
            _instance = new FlexClient();
         }
         return _instance;
      }
      
      [Bindable(event="propertyChange")]
      public function get id() : String
      {
         return this._id;
      }
      
      public function set id(param1:String) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(this._id != param1)
         {
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"id",this._id,param1);
            this._id = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      [Bindable(event="propertyChange")]
      mx_internal function get waitForFlexClientId() : Boolean
      {
         return this._waitForFlexClientId;
      }
      
      mx_internal function set waitForFlexClientId(param1:Boolean) : void
      {
         var _loc2_:PropertyChangeEvent = null;
         if(this._waitForFlexClientId != param1)
         {
            _loc2_ = PropertyChangeEvent.createUpdateEvent(this,"waitForFlexClientId",this._waitForFlexClientId,param1);
            this._waitForFlexClientId = param1;
            dispatchEvent(_loc2_);
         }
      }
   }
}

