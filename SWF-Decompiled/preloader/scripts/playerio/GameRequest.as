package playerio
{
   import playerio.generated.messages.WaitingGameRequest;
   import playerio.utils.Converter;
   
   public class GameRequest
   {
      private var _id:String;
      
      private var _type:String;
      
      private var _sendUserId:String;
      
      private var _created:Date;
      
      private var _data:Object;
      
      public function GameRequest()
      {
         super();
      }
      
      internal function _internal_initialize(param1:WaitingGameRequest) : void
      {
         this._id = param1.id;
         this._type = param1.type;
         this._sendUserId = param1.senderUserId;
         this._created = new Date(param1.created);
         this._data = Converter.toKeyValueObject(param1.data);
      }
      
      internal function get _internal_id() : String
      {
         return _id;
      }
      
      public function get type() : String
      {
         return _type;
      }
      
      public function get senderUserId() : String
      {
         return _sendUserId;
      }
      
      public function get created() : Date
      {
         return _created;
      }
      
      public function get data() : Object
      {
         return _data;
      }
   }
}

