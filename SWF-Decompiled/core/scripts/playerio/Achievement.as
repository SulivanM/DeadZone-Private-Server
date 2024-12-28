package playerio
{
   import playerio.generated.messages.Achievement;
   
   public class Achievement
   {
      private var _id:String;
      
      private var _title:String;
      
      private var _description:String;
      
      private var _imageUrl:String;
      
      private var _progress:int;
      
      private var _progressGoal:int;
      
      private var _lastUpdated:Date;
      
      public function Achievement()
      {
         super();
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get title() : String
      {
         return _title;
      }
      
      public function get description() : String
      {
         return _description;
      }
      
      public function get imageUrl() : String
      {
         return _imageUrl;
      }
      
      public function get progress() : int
      {
         return _progress;
      }
      
      public function get progressGoal() : int
      {
         return _progressGoal;
      }
      
      public function get lastUpdated() : Date
      {
         return _lastUpdated;
      }
      
      public function get progressRatio() : Number
      {
         return _progress / _progressGoal;
      }
      
      public function get completed() : Boolean
      {
         return _progress == _progressGoal;
      }
      
      internal function _internal_initialize(param1:playerio.generated.messages.Achievement) : void
      {
         this._id = param1.identifier;
         this._title = param1.title;
         this._description = param1.description;
         this._imageUrl = param1.imageUrl;
         this._progress = param1.progress;
         this._progressGoal = param1.progressGoal;
         this._lastUpdated = new Date(param1.lastUpdated * 1000);
      }
   }
}

