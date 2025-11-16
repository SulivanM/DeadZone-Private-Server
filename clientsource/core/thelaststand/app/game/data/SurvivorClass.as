package thelaststand.app.game.data
{
   import flash.display.BitmapData;
   import flash.utils.getDefinitionByName;
   import thelaststand.common.io.ISerializable;
   
   public class SurvivorClass implements ISerializable
   {
      
      public static const FIGHTER:String = "fighter";
      
      public static const MEDIC:String = "medic";
      
      public static const SCAVENGER:String = "scavenger";
      
      public static const ENGINEER:String = "engineer";
      
      public static const RECON:String = "recon";
      
      public static const PLAYER:String = "player";
      
      public static const UNASSIGNED:String = "unassigned";
      
      private var _id:String = "";
      
      private var _weaponClasses:Vector.<String>;
      
      private var _weaponTypes:uint = 0;
      
      public var baseAttributes:Attributes;
      
      public var levelAttributes:Attributes;
      
      public var maleModelUpper:String;
      
      public var maleModelLower:String;
      
      public var femaleModelUpper:String;
      
      public var femaleModelLower:String;
      
      public var maleSkinOverlay:String;
      
      public var femaleSkinOverlay:String;
      
      public var hideHair:Boolean;
      
      public function SurvivorClass()
      {
         super();
         this._weaponClasses = new Vector.<String>();
         this._weaponTypes = new Vector.<String>();
         this.baseAttributes = new Attributes();
         this.levelAttributes = new Attributes();
      }
      
      public static function getClasses() : Array
      {
         return [FIGHTER,RECON,ENGINEER,SCAVENGER,MEDIC];
      }
      
      public static function getClassIcon(param1:String) : BitmapData
      {
         var _loc2_:Class = getDefinitionByName("BmpIconClass_" + param1) as Class;
         if(_loc2_ != null)
         {
            return new _loc2_();
         }
         return null;
      }
      
      public static function getClassColor(param1:String) : uint
      {
         switch(param1)
         {
            case FIGHTER:
               return 3881777;
            case RECON:
               return 5254699;
            case ENGINEER:
               return 5063990;
            case SCAVENGER:
               return 3618369;
            case MEDIC:
               return 5330777;
            default:
               return 0;
         }
      }
      
      public static function getClassSkills(param1:String) : Array
      {
         switch(param1)
         {
            case FIGHTER:
               return [Attributes.COMBAT_PROJECTILE,Attributes.COMBAT_MELEE,Attributes.COMBAT_IMPROVISED];
            case RECON:
               return [Attributes.TRAP_SPOTTING,Attributes.COMBAT_PROJECTILE];
            case ENGINEER:
               return [Attributes.TRAP_DISARMING,Attributes.COMBAT_IMPROVISED,Attributes.COMBAT_MELEE];
            case SCAVENGER:
               return [Attributes.SCAVENGE_SPEED];
            case MEDIC:
               return [Attributes.HEALING];
            default:
               return [];
         }
      }
      
      public function isSpecialisedWithWeapon(param1:Weapon) : Boolean
      {
         if(this._weaponClasses.indexOf(param1.weaponClass) > -1)
         {
            return true;
         }
         return Boolean(param1.weaponType & this._weaponTypes);
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         return param1;
      }
      
      public function readObject(param1:Object) : void
      {
         var _loc2_:String = null;
         this._id = param1.id;
         this.maleModelUpper = param1.maleUpper;
         this.maleModelLower = param1.maleLower;
         this.maleSkinOverlay = param1.maleSkinOverlay != null ? param1.maleSkinOverlay : null;
         this.femaleModelUpper = param1.femaleUpper;
         this.femaleModelLower = param1.femaleLower;
         this.femaleSkinOverlay = param1.femaleSkinOverlay != null ? param1.femaleSkinOverlay : null;
         this.baseAttributes.readObject(param1.baseAttributes);
         this.levelAttributes.readObject(param1.levelAttributes);
         this.hideHair = param1.hasOwnProperty("hideHair") ? Boolean(param1.hideHair) : false;
         this._weaponClasses.length = 0;
         this._weaponTypes = WeaponType.NONE;
         if(param1.weapons != null)
         {
            for each(_loc2_ in param1.weapons.classes)
            {
               this._weaponClasses.push(WeaponClass[_loc2_.toUpperCase()]);
            }
            for each(_loc2_ in param1.weapons.types)
            {
               this._weaponTypes |= WeaponType[_loc2_.toUpperCase()];
            }
         }
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get weaponClasses() : Vector.<String>
      {
         return this._weaponClasses;
      }
      
      public function get weaponTypes() : uint
      {
         return this._weaponTypes;
      }
   }
}

