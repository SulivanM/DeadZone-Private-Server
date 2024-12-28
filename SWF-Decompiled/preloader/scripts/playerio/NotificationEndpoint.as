package playerio
{
   import playerio.generated.messages.NotificationsEndpoint;
   import playerio.utils.Converter;
   
   public class NotificationEndpoint
   {
      private var _type:String;
      
      private var _identifier:String;
      
      private var _data:Object;
      
      private var _enabled:Boolean;
      
      public function NotificationEndpoint()
      {
         super();
      }
      
      internal function _internal_initialize(param1:NotificationsEndpoint) : void
      {
         this._type = param1.type;
         this._identifier = param1.identifier;
         this._enabled = param1.enabled;
         this._data = Converter.toKeyValueObject(param1.configuration);
      }
      
      public function get type() : String
      {
         return _type;
      }
      
      public function get identifier() : String
      {
         return _identifier;
      }
      
      public function get configuration() : Object
      {
         return _data;
      }
      
      public function get endabled() : Boolean
      {
         return _enabled;
      }
   }
}

