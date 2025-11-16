package thelaststand.app.game.data.alliance
{
   import org.osflash.signals.Signal;
   
   public class AllianceMessageList
   {
      
      private var _messages:Vector.<AllianceMessage>;
      
      private var _numMessages:int;
      
      private var _lastViewedDate:Date;
      
      private var _unreadMessageCount:uint = 0;
      
      public var messageAdded:Signal = new Signal(AllianceMessage);
      
      public var messageRemoved:Signal = new Signal(AllianceMessage);
      
      public var unreadMessageCountChange:Signal = new Signal(uint);
      
      public function AllianceMessageList()
      {
         super();
         this._messages = new Vector.<AllianceMessage>();
         this._lastViewedDate = new Date();
         this._lastViewedDate.minutes += this._lastViewedDate.timezoneOffset;
      }
      
      public function get numMessages() : int
      {
         return this._numMessages;
      }
      
      public function get unreadMessageCount() : uint
      {
         return this._unreadMessageCount;
      }
      
      public function get lastViewedDate() : Date
      {
         return this._lastViewedDate;
      }
      
      public function set lastViewedDate(param1:Date) : void
      {
         var _loc3_:AllianceMessage = null;
         this._lastViewedDate = param1;
         var _loc2_:uint = this._unreadMessageCount;
         this._unreadMessageCount = 0;
         for each(_loc3_ in this._messages)
         {
            if(_loc3_.date.time > this._lastViewedDate.time)
            {
               ++this._unreadMessageCount;
            }
         }
         if(this._unreadMessageCount != _loc2_)
         {
            this.unreadMessageCountChange.dispatch(this._unreadMessageCount);
         }
      }
      
      public function clear() : void
      {
         this._messages.length = 0;
         this._numMessages = 0;
         if(this._unreadMessageCount > 0)
         {
            this._unreadMessageCount = 0;
            this.unreadMessageCountChange.dispatch(0);
         }
      }
      
      public function addMessage(param1:AllianceMessage) : void
      {
         var _loc2_:int = int(this._messages.indexOf(param1));
         if(_loc2_ > -1)
         {
            return;
         }
         this._messages.push(param1);
         ++this._numMessages;
         this.messageAdded.dispatch(param1);
         if(param1.date.time > this._lastViewedDate.time)
         {
            ++this._unreadMessageCount;
            this.unreadMessageCountChange.dispatch(this._unreadMessageCount);
         }
      }
      
      public function removeMessage(param1:AllianceMessage) : void
      {
         var _loc2_:int = int(this._messages.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         this._messages.splice(_loc2_,1);
         --this._numMessages;
         this.messageRemoved.dispatch(param1);
         if(param1.date.time > this.lastViewedDate.time)
         {
            --this._unreadMessageCount;
            this.unreadMessageCountChange.dispatch(this._unreadMessageCount);
         }
      }
      
      public function removeMessageById(param1:String) : void
      {
         this.removeMessage(this.getMessageById(param1));
      }
      
      public function getMessage(param1:int) : AllianceMessage
      {
         if(param1 < 0 || param1 >= this._messages.length)
         {
            return null;
         }
         return this._messages[param1];
      }
      
      public function getMessageById(param1:String) : AllianceMessage
      {
         var _loc3_:AllianceMessage = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._numMessages)
         {
            _loc3_ = this._messages[_loc2_];
            if(_loc3_ != null && _loc3_.id == param1)
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      public function deserialize(param1:Object) : void
      {
         var _loc4_:Object = null;
         var _loc5_:AllianceMessage = null;
         this.clear();
         var _loc2_:Array = param1 as Array;
         if(_loc2_ == null)
         {
            return;
         }
         this._unreadMessageCount = 0;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc3_];
            if(_loc4_ == null)
            {
               return;
            }
            _loc5_ = new AllianceMessage(_loc4_);
            this._messages.push(_loc5_);
            ++this._numMessages;
            if(_loc5_.date.time > this.lastViewedDate.time)
            {
               ++this._unreadMessageCount;
            }
            _loc3_++;
         }
         if(this._unreadMessageCount > 0)
         {
            this.unreadMessageCountChange.dispatch(this._unreadMessageCount);
         }
      }
   }
}

