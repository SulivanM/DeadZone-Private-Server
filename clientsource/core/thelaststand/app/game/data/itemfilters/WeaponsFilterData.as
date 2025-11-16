package thelaststand.app.game.data.itemfilters
{
   import thelaststand.app.game.data.SurvivorLoadout;
   
   public class WeaponsFilterData implements IFilterData
   {
      
      public var levelMin:int;
      
      public var levelMax:int;
      
      public var quality:String;
      
      public var melee:Boolean;
      
      public var firearms:Boolean;
      
      public var sortField:String;
      
      public var loadout:SurvivorLoadout;
      
      public function WeaponsFilterData()
      {
         super();
         this.reset();
      }
      
      public function reset() : void
      {
         this.levelMin = 0;
         this.levelMax = int.MAX_VALUE;
         this.quality = "all";
         this.melee = true;
         this.firearms = true;
         this.sortField = "level";
      }
   }
}

