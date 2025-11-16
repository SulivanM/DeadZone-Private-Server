package thelaststand.app.game.logic.ai
{
   import com.deadreckoned.threshold.data.ObjectPool;
   import de.polygonal.ds.Prioritizable;
   import thelaststand.app.game.data.Building;
   
   public class ThreatData extends Prioritizable
   {
      
      public static var pool:ObjectPool = new ObjectPool(ThreatData,1000,1,true);
      
      public var agent:AIAgent;
      
      public var agentThreatValue:Number = -1;
      
      public var helpingFriend:Boolean = false;
      
      public var buildings:Vector.<Building> = new Vector.<Building>();
      
      public var noise:NoiseSource;
      
      public function ThreatData()
      {
         super();
      }
      
      public function reset() : ThreatData
      {
         this.agent = null;
         this.noise = null;
         this.buildings.length = 0;
         this.agentThreatValue = -1;
         this.helpingFriend = false;
         return this;
      }
      
      public function returnToPool() : void
      {
         this.reset();
         pool.put(this);
      }
   }
}

