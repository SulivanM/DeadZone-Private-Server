package playerio
{
   import playerio.generated.messages.OneScoreValue;
   
   public class OneScoreValue
   {
      private var _score:int;
      
      private var _percentile:Number;
      
      private var _topRank:int;
      
      public function OneScoreValue()
      {
         super();
      }
      
      public function get score() : int
      {
         return _score;
      }
      
      public function get percentile() : Number
      {
         return _percentile;
      }
      
      public function get topRank() : int
      {
         return _topRank;
      }
      
      internal function _internal_initialize(param1:playerio.generated.messages.OneScoreValue) : void
      {
         this._score = param1.score;
         this._percentile = param1.percentile;
         this._topRank = param1.topRank;
      }
   }
}

