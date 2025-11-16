package thelaststand.app.game.data.alliance
{
   public class AllianceMessage
   {
      
      private var _id:String;
      
      private var _date:Date;
      
      private var _playerId:String;
      
      private var _playerName:String;
      
      private var _subject:String;
      
      private var _body:String;
      
      public function AllianceMessage(param1:Object)
      {
         super();
         this.deserialize(param1);
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get date() : Date
      {
         return this._date;
      }
      
      public function get playerId() : String
      {
         return this._playerId;
      }
      
      public function get playerName() : String
      {
         return this._playerName;
      }
      
      public function get subject() : String
      {
         return this._subject;
      }
      
      public function get body() : String
      {
         return this._body;
      }
      
      private function deserialize(param1:Object) : void
      {
         this._id = String(param1.id);
         this._date = new Date(param1.date);
         this._playerId = String(param1.playerId);
         this._playerName = String(param1.author);
         this._subject = String(param1.title);
         this._body = String(param1.message);
      }
   }
}

