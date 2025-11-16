package thelaststand.app.game.logic
{
   import thelaststand.app.game.data.AttireData;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.HumanAppearance;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorAppearance;
   import thelaststand.app.game.data.SurvivorClass;
   import thelaststand.app.game.data.Weapon;
   import thelaststand.common.resources.ResourceManager;
   
   public class HumanEnemyFactory
   {
      
      public function HumanEnemyFactory()
      {
         super();
         throw new Error("HumanEnemyFactory cannot be directly instantiated.");
      }
      
      public static function create(param1:XML) : Survivor
      {
         var xmlEnemies:XML = null;
         var enemyNode:XML = null;
         var enemy:Survivor = null;
         var mdlNode:XML = null;
         var appearance:HumanAppearance = null;
         var data:Object = null;
         var weaponId:String = null;
         var gearId:String = null;
         var xmlWeapon:XML = null;
         var newWeapon:Weapon = null;
         var xmlGear:XML = null;
         var newGear:Gear = null;
         var node:XML = param1;
         var typeId:String = node.type;
         if(typeId == null || typeId.toString() == null)
         {
            return null;
         }
         xmlEnemies = ResourceManager.getInstance().getResource("xml/humanenemies.xml").content;
         enemyNode = xmlEnemies.enemies.human.(@id == typeId)[0];
         if(enemyNode == null)
         {
            return null;
         }
         enemy = new Survivor();
         mdlNode = enemyNode.mdl[0];
         appearance = createAppearance(enemy,mdlNode);
         data = {
            "id":GUID.create(),
            "classId":SurvivorClass.PLAYER,
            "level":1,
            "scale":(enemyNode.hasOwnProperty("scale") ? Number(enemyNode.scale) : 1),
            "appearance":appearance
         };
         enemy.readObject(data);
         enemy.enemyHumanId = enemyNode.@id.toString();
         enemy.statId = enemyNode.@type.toString();
         enemy.attributes.health = Number(enemyNode.hp);
         weaponId = enemyNode.loadout.weapon.@id;
         if(weaponId != null)
         {
            xmlWeapon = xmlEnemies.items.item.(@id == weaponId)[0];
            if(xmlWeapon != null)
            {
               newWeapon = new Weapon();
               newWeapon.xml = xmlWeapon;
               newWeapon.baseLevel = data.level;
               enemy.loadoutDefence.weapon.item = newWeapon;
            }
         }
         gearId = enemyNode.loadout.gear.@id;
         if(gearId != null)
         {
            xmlGear = xmlEnemies.items.item.(@id == gearId)[0];
            if(xmlGear != null)
            {
               newGear = new Gear();
               newGear.xml = xmlGear;
               newGear.baseLevel = data.level;
               enemy.loadoutDefence.gearPassive.item = newGear;
            }
         }
         return enemy;
      }
      
      private static function createAppearance(param1:Survivor, param2:XML) : SurvivorAppearance
      {
         var _loc9_:AttireData = null;
         var _loc10_:AttireData = null;
         var _loc3_:SurvivorAppearance = new SurvivorAppearance(param1);
         var _loc4_:String = param1.gender;
         var _loc5_:AttireData = new AttireData();
         _loc5_.parseXML(param2.upper[0],_loc4_);
         _loc5_.type = "upper";
         _loc3_.upperBody = _loc5_;
         var _loc6_:AttireData = new AttireData();
         _loc6_.parseXML(param2.lower[0],_loc4_);
         _loc6_.type = "lower";
         _loc3_.lowerBody = _loc6_;
         var _loc7_:XML = param2.hair[0];
         if(_loc7_ != null)
         {
            _loc9_ = new AttireData();
            _loc9_.parseXML(_loc7_,_loc4_);
            _loc9_.type = "hair";
            _loc3_.hair = _loc9_;
         }
         var _loc8_:XML = param2.skin[0];
         if(_loc8_ != null)
         {
            _loc10_ = new AttireData();
            _loc10_.parseXML(_loc8_,_loc4_);
            _loc10_.type = "skin";
            _loc3_.skin = _loc10_;
         }
         return _loc3_;
      }
   }
}

