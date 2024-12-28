package playerio
{
   import playerio.generated.Notifications;
   import playerio.generated.PlayerIOError;
   import playerio.generated.messages.Notification;
   import playerio.generated.messages.NotificationsEndpoint;
   import playerio.generated.messages.NotificationsEndpointId;
   import playerio.utils.Converter;
   import playerio.utils.HTTPChannel;
   import playerio.utils.Utilities;
   
   public class Notifications extends playerio.generated.Notifications
   {
      private var _version:String;
      
      private var _myNotifications:Array;
      
      public function Notifications(param1:HTTPChannel, param2:Client)
      {
         super(param1,param2);
      }
      
      public function get myNotifications() : Array
      {
         if(_myNotifications == null)
         {
            throw new playerio.generated.PlayerIOError("Cannot access \'myNotifications\' before refresh() is called.",playerio.PlayerIOError.NotificationsNotLoaded.errorID);
         }
         return _myNotifications;
      }
      
      public function refresh(param1:Function, param2:Function) : void
      {
         var callback:Function = param1;
         var errorCallback:Function = param2;
         _notificationsRefresh(_version,function(param1:String, param2:Array):void
         {
            refreshed(param1,param2);
            if(callback != null)
            {
               callback();
            }
         },errorCallback);
      }
      
      private function refreshed(param1:String, param2:Array) : void
      {
         var _loc5_:int = 0;
         var _loc3_:NotificationEndpoint = null;
         var _loc4_:Array = [];
         if(this._version != param1)
         {
            this._version = param1;
            if(param2 != null)
            {
               _loc5_ = 0;
               while(_loc5_ < param2.length)
               {
                  _loc3_ = new NotificationEndpoint();
                  _loc3_._internal_initialize(param2[_loc5_]);
                  _loc4_.push(_loc3_);
                  _loc5_++;
               }
            }
            this._myNotifications = _loc4_;
         }
      }
      
      public function registerEndpoints(param1:String, param2:String, param3:Object, param4:Boolean, param5:Function, param6:Function) : void
      {
         var newEndpoint:NotificationsEndpoint;
         var endpointType:String = param1;
         var identifier:String = param2;
         var configuration:Object = param3;
         var enabled:Boolean = param4;
         var callback:Function = param5;
         var errorCallback:Function = param6;
         var current:NotificationEndpoint = get(endpointType,identifier);
         if(current == null || current.endabled != enabled || !areEqual(current.configuration,configuration))
         {
            newEndpoint = createChannelNotificationEndpoint(endpointType,identifier,configuration,enabled);
            _notificationsRegisterEndpoints(_version,[newEndpoint],function(param1:String, param2:Array):void
            {
               refreshed(param1,param2);
               if(callback != null)
               {
                  callback();
               }
            },errorCallback);
         }
         else if(callback != null)
         {
            callback();
         }
      }
      
      public function send(param1:Array, param2:Function, param3:Function) : void
      {
         if(param1.length > 0)
         {
            _notificationsSend(convertNotification(param1),param2,param3);
         }
         else if(param2 != null)
         {
            param2();
         }
      }
      
      public function toggleEndpoints(param1:Array, param2:Boolean, param3:Function, param4:Function) : void
      {
         var endpoints:Array = param1;
         var enable:Boolean = param2;
         var callback:Function = param3;
         var errorCallback:Function = param4;
         var ids:Array = convertNotificationEndpoint(endpoints);
         if(ids.length > 0)
         {
            _notificationsToggleEndpoints(this._version,ids,enable,function(param1:String, param2:Array):void
            {
               refreshed(param1,param2);
               if(callback != null)
               {
                  callback();
               }
            },errorCallback);
         }
         else if(callback != null)
         {
            callback();
         }
      }
      
      public function deleteEndpoints(param1:Array, param2:Function, param3:Function) : void
      {
         var endpoints:Array = param1;
         var callback:Function = param2;
         var errorCallback:Function = param3;
         var ids:Array = convertNotificationEndpoint(endpoints);
         if(ids.length > 0)
         {
            _notificationsDeleteEndpoints(this._version,ids,function(param1:String, param2:Array):void
            {
               refreshed(param1,param2);
               if(callback != null)
               {
                  callback();
               }
            },errorCallback);
         }
         else if(callback != null)
         {
            callback();
         }
      }
      
      private function createChannelNotificationEndpoint(param1:String, param2:String, param3:Object, param4:Boolean) : NotificationsEndpoint
      {
         var _loc5_:NotificationsEndpoint = new NotificationsEndpoint();
         _loc5_.configuration = Converter.toKeyValueArray(param3);
         _loc5_.type = param1;
         _loc5_.identifier = param2;
         _loc5_.enabled = param4;
         return _loc5_;
      }
      
      private function get(param1:String, param2:String) : NotificationEndpoint
      {
         var endpointType:String = param1;
         var identifier:String = param2;
         return _myNotifications == null ? null : Utilities.find(_myNotifications,function(param1:NotificationEndpoint):Boolean
         {
            if(param1.identifier == identifier && param1.type == endpointType)
            {
               return true;
            }
            return false;
         }) as NotificationEndpoint;
      }
      
      private function areEqual(param1:Object, param2:Object) : Boolean
      {
         if(Utilities.countKeys(param1) == Utilities.countKeys(param2))
         {
            for(var _loc3_ in param1)
            {
               if(param1[_loc3_] != param2[_loc3_])
               {
                  return false;
               }
            }
            return true;
         }
         return false;
      }
      
      private function convertNotification(param1:Array) : Array
      {
         var _loc5_:int = 0;
         var _loc2_:playerio.generated.messages.Notification = null;
         var _loc3_:playerio.Notification = null;
         var _loc4_:Array = [];
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc2_ = new playerio.generated.messages.Notification();
            _loc3_ = param1[_loc5_] as playerio.Notification;
            _loc2_.data = Converter.getObjectProperties(_loc3_.data);
            _loc2_.recipient = _loc3_.recipientUserId;
            _loc2_.endpointType = _loc3_.endpointType;
            _loc4_.push(_loc2_);
            _loc5_++;
         }
         return _loc4_;
      }
      
      private function convertNotificationEndpoint(param1:Array) : Array
      {
         var _loc4_:int = 0;
         var _loc3_:NotificationsEndpointId = null;
         var _loc2_:Array = [];
         if(param1 == null)
         {
            return _loc2_;
         }
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc3_ = new NotificationsEndpointId();
            _loc3_.identifier = (param1[_loc4_] as NotificationEndpoint).identifier;
            _loc3_.type = (param1[_loc4_] as NotificationEndpoint).type;
            _loc2_.push(_loc3_);
            _loc4_++;
         }
         return _loc2_;
      }
   }
}

