package thelaststand.app.game.data
{
   public class ItemBindState
   {
      
      public static const NotBindable:uint = 0;
      
      public static const OnEquip:uint = 1;
      
      public static const Bound:uint = 2;
      
      public function ItemBindState()
      {
         super();
         throw new Error("ItemBindState cannot be directly instantiated.");
      }
   }
}

