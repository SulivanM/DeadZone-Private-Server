package thelaststand.app.data
{
   public class PlayerUpgrades
   {
      
      public static const DeathMobileUpgrade:int = 0;
      
      public static const TradeSlotUpgrade:int = 1;
      
      public static const InventoryUpgrade1_UNUSED:int = 2;
      
      public function PlayerUpgrades()
      {
         super();
         throw new Error("PlayerUpgrades cannot be directly instantiated.");
      }
      
      public static function getName(param1:uint) : String
      {
         switch(param1)
         {
            case DeathMobileUpgrade:
               return "DeathMobileUpgrade";
            case TradeSlotUpgrade:
               return "TradeSlotUpgrade";
            case InventoryUpgrade1_UNUSED:
               return "InventoryUpgrade1_UNUSED";
            default:
               return null;
         }
      }
   }
}

