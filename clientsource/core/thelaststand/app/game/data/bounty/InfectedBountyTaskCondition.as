package thelaststand.app.game.data.bounty
{
   import org.osflash.signals.Signal;
   
   public class InfectedBountyTaskCondition
   {
      
      private var _index:int;
      
      private var _kills:int;
      
      private var _killsRequired:int;
      
      private var _zombieType:String;
      
      private var _suburb:String;
      
      public var completed:Signal = new Signal(InfectedBountyTaskCondition);
      
      public var killsChanged:Signal = new Signal(InfectedBountyTaskCondition);
      
      public function InfectedBountyTaskCondition(param1:int, param2:String, param3:Object)
      {
         super();
         this._index = param1;
         this._suburb = param2;
         this.deserialize(param3);
      }
      
      public function get index() : int
      {
         return this._index;
      }
      
      public function get kills() : int
      {
         return this._kills;
      }
      
      public function set kills(param1:int) : void
      {
         this.setKills(param1);
      }
      
      public function get killsRequired() : int
      {
         return this._killsRequired;
      }
      
      public function get zombieType() : String
      {
         return this._zombieType;
      }
      
      public function get suburb() : String
      {
         return this._suburb;
      }
      
      public function get isComplete() : Boolean
      {
         return this._kills >= this._killsRequired;
      }
      
      public function complete() : void
      {
         this.setKills(this._killsRequired);
      }
      
      private function setKills(param1:int) : void
      {
         if(param1 <= 0)
         {
            param1 = 0;
         }
         if(param1 == this.kills)
         {
            return;
         }
         this._kills = param1;
         if(this._kills >= this.killsRequired)
         {
            this._kills = this._killsRequired;
            this.killsChanged.dispatch(this);
            this.completed.dispatch(this);
         }
         else
         {
            this.killsChanged.dispatch(this);
         }
      }
      
      private function deserialize(param1:Object) : void
      {
         this._zombieType = String(param1["zombieType"]);
         this._killsRequired = int(param1["killsRequired"]);
         this._kills = int(param1["kills"]);
      }
   }
}

