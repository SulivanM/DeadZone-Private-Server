package thelaststand.app.data
{
   public class RequirementTypes
   {
      
      public static const None:uint = 0;
      
      public static const PlayerLevel:uint = 1 << 1;
      
      public static const Buildings:uint = 1 << 2;
      
      public static const Survivors:uint = 1 << 3;
      
      public static const Items:uint = 1 << 4;
      
      public static const Resources:uint = 1 << 5;
      
      public static const Skills:uint = 1 << 6;
      
      public static const All:uint = 16777215;
      
      public static const NotItemsResources:uint = 0xFFFFFF ^ (Items | Resources);
      
      public static const ItemsResources:uint = Items | Resources;
      
      public function RequirementTypes()
      {
         super();
         throw new Error("RequirementTypes cannot be directly instantiated.");
      }
   }
}

