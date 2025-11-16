package mx.messaging.messages
{
   public class MessagePerformanceInfo
   {
      
      public var messageSize:int;
      
      public var sendTime:Number = 0;
      
      private var _receiveTime:Number;
      
      public var overheadTime:Number;
      
      private var _infoType:String;
      
      public var pushedFlag:Boolean;
      
      public var serverPrePushTime:Number;
      
      public var serverPreAdapterTime:Number;
      
      public var serverPostAdapterTime:Number;
      
      public var serverPreAdapterExternalTime:Number;
      
      public var serverPostAdapterExternalTime:Number;
      
      public var recordMessageTimes:Boolean;
      
      public var recordMessageSizes:Boolean;
      
      public function MessagePerformanceInfo()
      {
         super();
      }
      
      public function set infoType(param1:String) : void
      {
         var _loc2_:Date = null;
         this._infoType = param1;
         if(this._infoType == "OUT")
         {
            _loc2_ = new Date();
            this._receiveTime = _loc2_.getTime();
         }
      }
      
      public function get infoType() : String
      {
         return this._infoType;
      }
      
      public function set receiveTime(param1:Number) : void
      {
         if(this._infoType == null || this._infoType != "OUT")
         {
            this._receiveTime = param1;
         }
      }
      
      public function get receiveTime() : Number
      {
         return this._receiveTime;
      }
   }
}

