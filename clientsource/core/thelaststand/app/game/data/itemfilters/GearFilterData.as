package thelaststand.app.game.data.itemfilters
{
   public class GearFilterData implements IFilterData
   {
      
      public var levelMin:int;
      
      public var levelMax:int;
      
      public var quality:String;
      
      public var sortField:String;
      
      public function GearFilterData()
      {
         super();
         this.reset();
      }
      
      public function reset() : void
      {
         this.levelMin = 0;
         this.levelMax = int.MAX_VALUE;
         this.quality = "all";
         this.sortField = "level";
      }
   }
}

