package thelaststand.app.game.data
{
   import thelaststand.common.io.ISerializable;
   
   public class Attributes implements ISerializable
   {
      
      public static const COMBAT_IMPROVISED:String = "combatImprovised";
      
      public static const COMBAT_PROJECTILE:String = "combatProjectile";
      
      public static const COMBAT_MELEE:String = "combatMelee";
      
      public static const MOVEMENT_SPEED:String = "movement";
      
      public static const SCAVENGE_SPEED:String = "scavenge";
      
      public static const HEALING:String = "healing";
      
      public static const TRAP_SPOTTING:String = "trapSpotting";
      
      public static const TRAP_DISARMING:String = "trapDisarming";
      
      public static const HEALTH:String = "health";
      
      public static const INJURY_CHANCE:String = "injuryChance";
      
      public var health:Number = 1;
      
      public var combatProjectile:Number = 1;
      
      public var combatMelee:Number = 1;
      
      public var combatImprovised:Number = 1;
      
      public var movement:Number = 1;
      
      public var scavenge:Number = 1;
      
      public var healing:Number = 0;
      
      public var trapSpotting:Number = 0;
      
      public var trapDisarming:Number = 0;
      
      public var injuryChance:Number = 0;
      
      public function Attributes()
      {
         super();
      }
      
      public static function getAttributes() : Array
      {
         return ["health","combatProjectile","combatMelee","combatImprovised","movement","scavenge","healing","trapSpotting","trapDisarming"];
      }
      
      public function clone() : Attributes
      {
         var _loc1_:Attributes = new Attributes();
         _loc1_.readObject(this);
         return _loc1_;
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         if(!param1)
         {
            param1 = {};
         }
         param1.health = this.health;
         param1.combatProjectile = this.combatProjectile;
         param1.combatMelee = this.combatMelee;
         param1.combatImprovised = this.combatImprovised;
         param1.movement = this.movement;
         param1.scavenge = this.scavenge;
         param1.healing = this.healing;
         param1.trapSpotting = this.trapSpotting;
         param1.trapDisarming = this.trapDisarming;
         return param1;
      }
      
      public function readObject(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this.health = isNaN(param1.health) ? 0 : Number(param1.health);
         this.combatProjectile = isNaN(param1.combatProjectile) ? 0 : Number(param1.combatProjectile);
         this.combatMelee = isNaN(param1.combatMelee) ? 0 : Number(param1.combatMelee);
         this.combatImprovised = isNaN(param1.combatImprovised) ? 0 : Number(param1.combatImprovised);
         this.movement = isNaN(param1.movement) ? 0 : Number(param1.movement);
         this.scavenge = isNaN(param1.scavenge) ? 0 : Number(param1.scavenge);
         this.healing = isNaN(param1.healing) ? 0 : Number(param1.healing);
         this.trapSpotting = isNaN(param1.trapSpotting) ? 0 : Number(param1.trapSpotting);
         this.trapDisarming = isNaN(param1.trapDisarming) ? 0 : Number(param1.trapDisarming);
      }
   }
}

