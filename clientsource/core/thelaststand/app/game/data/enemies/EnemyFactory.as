package thelaststand.app.game.data.enemies
{
   import thelaststand.app.game.data.Zombie;
   
   public class EnemyFactory
   {
      
      public function EnemyFactory()
      {
         super();
         throw new Error("EnemyFactory cannot be directly instantiated.");
      }
      
      public static function createEnemy(param1:String) : Zombie
      {
         switch(param1)
         {
            case "zombieHuman":
               return new ZombieHuman();
            case "zombieDog":
               return new ZombieDog();
            default:
               return null;
         }
      }
   }
}

