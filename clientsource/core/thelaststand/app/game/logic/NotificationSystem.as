package thelaststand.app.game.logic
{
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.notification.INotification;
   
   public class NotificationSystem
   {
      
      private static var _instance:NotificationSystem;
      
      private var _notifications:Vector.<INotification>;
      
      public var notificationAdded:Signal;
      
      public var notificationRemoved:Signal;
      
      public function NotificationSystem(param1:NotificationSystemSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("NotificationSystem is a Singleton and cannot be directly instantiated. Use NotificationSystem.getInstance().");
         }
         this._notifications = new Vector.<INotification>();
         this.notificationAdded = new Signal(INotification);
         this.notificationRemoved = new Signal(INotification);
      }
      
      public static function getInstance() : NotificationSystem
      {
         return _instance || (_instance = new NotificationSystem(new NotificationSystemSingletonEnforcer()));
      }
      
      public function addNotification(param1:INotification) : INotification
      {
         if(this._notifications.indexOf(param1) > -1)
         {
            return param1;
         }
         this._notifications.unshift(param1);
         this.notificationAdded.dispatch(param1);
         return param1;
      }
      
      public function getNotification(param1:int) : INotification
      {
         if(param1 < 0 || param1 >= this._notifications.length)
         {
            return null;
         }
         return this._notifications[param1];
      }
      
      public function getActiveNotifications() : Vector.<INotification>
      {
         var _loc3_:INotification = null;
         var _loc1_:Vector.<INotification> = new Vector.<INotification>();
         var _loc2_:int = 0;
         while(_loc2_ < this._notifications.length)
         {
            _loc3_ = this._notifications[_loc2_];
            if(_loc3_ != null && _loc3_.active)
            {
               _loc1_.push(_loc3_);
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function getPassiveNotifications() : Vector.<INotification>
      {
         var _loc3_:INotification = null;
         var _loc1_:Vector.<INotification> = new Vector.<INotification>();
         var _loc2_:int = 0;
         while(_loc2_ < this._notifications.length)
         {
            _loc3_ = this._notifications[_loc2_];
            if(!_loc3_.active)
            {
               _loc1_.push(_loc3_);
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function openActiveNotifications() : void
      {
         this.openQueue(this.getActiveNotifications());
      }
      
      public function openPassiveNotifications() : void
      {
         this.openQueue(this.getPassiveNotifications());
      }
      
      public function removeNotification(param1:INotification) : void
      {
         var _loc2_:int = int(this._notifications.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         this._notifications.splice(_loc2_,1);
         this.notificationRemoved.dispatch(param1);
      }
      
      private function openQueue(param1:Vector.<INotification>) : void
      {
         var currentIndex:int = 0;
         var openNextNotification:Function = null;
         var notes:Vector.<INotification> = param1;
         if(notes.length == 0)
         {
            return;
         }
         currentIndex = 0;
         openNextNotification = function(param1:INotification = null):void
         {
            param1 = notes[currentIndex];
            param1.open();
            removeNotification(param1);
            if(currentIndex < notes.length - 1)
            {
               param1.closed.addOnce(openNextNotification);
               ++currentIndex;
            }
         };
         openNextNotification(null);
      }
      
      public function get numNotifications() : int
      {
         return this._notifications.length;
      }
      
      public function get numActiveNotifications() : int
      {
         var _loc2_:INotification = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._notifications)
         {
            if(_loc2_.active)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      public function get numPassiveNotifications() : int
      {
         var _loc2_:INotification = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._notifications)
         {
            if(_loc2_ != null && !_loc2_.active)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
   }
}

class NotificationSystemSingletonEnforcer
{
   
   public function NotificationSystemSingletonEnforcer()
   {
      super();
   }
}
