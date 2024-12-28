package thelaststand.app.game.scenes
{
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Settings;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorCollection;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.data.assignment.AssignmentData;
   import thelaststand.app.game.data.assignment.AssignmentType;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.logic.ZombieDirector;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.common.resources.AssetLoader;
   import thelaststand.common.resources.ResourceManager;
   
   public class MissionLoader
   {
      private var _missionData:MissionData;
      
      private var _resources:ResourceManager;
      
      private var _assetLoader:AssetLoader;
      
      private var _sceneLoader:SceneLoader;
      
      private var _sceneXML:XML;
      
      public var loadCompleted:Signal;
      
      public function MissionLoader()
      {
         super();
         this._resources = ResourceManager.getInstance();
         this._sceneLoader = new SceneLoader();
         this._assetLoader = new AssetLoader();
         this.loadCompleted = new Signal(MissionLoader);
      }
      
      public function close(param1:Boolean = false) : void
      {
         this._assetLoader.loadingCompleted.remove(this.onAssetsCompleted);
         if(param1)
         {
            this._assetLoader.purgeLoadedAssets();
         }
         this._assetLoader.clear(param1);
         this._sceneLoader.loadCompleted.remove(this.onSceneComplated);
         this._sceneLoader.close(param1);
         this._missionData = null;
         this._sceneXML = null;
      }
      
      public function dispose() : void
      {
         this.loadCompleted.removeAll();
         this._resources = null;
         this._missionData = null;
         this._assetLoader.dispose(true);
         this._assetLoader = null;
         this._sceneLoader.dispose();
         this._sceneLoader = null;
      }
      
      public function load(param1:MissionData) : void
      {
         this._missionData = param1;
         this._assetLoader.clear(true);
         this._assetLoader.loadingCompleted.remove(this.onAssetsCompleted);
         this._sceneLoader.loadCompleted.remove(this.onSceneComplated);
         if(!(this._missionData.opponent.isPlayer || this._missionData.type == "compound"))
         {
            this._sceneXML = param1.sceneXML;
         }
         this.loadMissionResources();
      }
      
      private function loadMissionResources() : void
      {
         var node:XML = null;
         var voicePackURI:String = null;
         var srv:Survivor = null;
         var hEnemy:Survivor = null;
         var loadout:SurvivorLoadout = null;
         var enemySurvivors:SurvivorCollection = null;
         var i:int = 0;
         var zombieXML:XML = null;
         var zombieList:XMLList = null;
         var usedWeapons:XMLList = null;
         var soundList:XMLList = null;
         var zombieAssets:XMLList = null;
         var zombieSoundList:XMLList = null;
         var weaponNode:XML = null;
         var uriList:XMLList = null;
         var uriNode:XML = null;
         var itemXML:XML = null;
         var itmURINode:XML = null;
         var uri:String = null;
         var itemsXML:XML = null;
         var pumpkinHatXML:XML = null;
         var assignment:AssignmentData = null;
         var fileNode:XML = null;
         var fileUri:String = null;
         var zId:String = null;
         var zXml:XML = null;
         var zSpawnNode:XML = null;
         var assetList:Array = [];
         var compoundAttack:Boolean = this._missionData.isCompoundAttack();
         var xmlURI:String = "resources_mission.xml";
         var missionResources:XML = ResourceManager.getInstance().getResource(xmlURI).content;
         for each(node in missionResources.res)
         {
            assetList.push(node.toString());
         }
         for each(srv in this._missionData.survivors)
         {
            if(srv != null)
            {
               if(Settings.getInstance().voices)
               {
                  voicePackURI = "sound/voices/" + srv.voicePack + ".zip";
                  if(assetList.indexOf(voicePackURI) == -1)
                  {
                     assetList.push(voicePackURI);
                  }
               }
               loadout = compoundAttack ? srv.loadoutDefence : srv.loadoutOffence;
               loadout.getAssets(assetList);
            }
         }
         if(this._missionData.opponent.isPlayer)
         {
            enemySurvivors = RemotePlayerData(this._missionData.opponent).compound.survivors;
            assetList = assetList.concat(enemySurvivors.getResourceURIs());
            i = 0;
            while(i < enemySurvivors.length)
            {
               srv = enemySurvivors.getSurvivor(i);
               if(srv != null)
               {
                  srv.loadoutDefence.getAssets(assetList,false);
               }
               i++;
            }
         }
         else
         {
            zombieXML = ResourceManager.getInstance().getResource("xml/zombie.xml").content;
            zombieList = ZombieDirector.getZombieDefinitionsForLevel(this._missionData.opponent.level);
            usedWeapons = zombieList.weapon.@id;
            for each(node in usedWeapons)
            {
               weaponNode = zombieXML.weapons.item.(@id == node.toString())[0];
               if(weaponNode != null)
               {
                  uriList = weaponNode.descendants().(hasOwnProperty("@uri")) + weaponNode.weap.snd.children();
                  for each(uriNode in uriList)
                  {
                     if("@uri" in uriNode)
                     {
                        assetList.push(uriNode.@uri.toXMLString());
                     }
                     else
                     {
                        assetList.push(uriNode.toString());
                     }
                  }
               }
            }
            soundList = zombieList.explosive.sound;
            if(soundList != null && soundList.length() > 0)
            {
               for each(node in soundList)
               {
                  assetList.push(node.toString());
               }
            }
            assetList.push("models/anim/zombie.anim","models/anim/zombie.daeanim","models/anim/animal-dog.anim","models/anim/animal-dog.daeanim","models/characters/zombies/blood-overlay-lower.png","models/characters/zombies/blood-overlay-upper.png");
            zombieAssets = zombieList.descendants().(hasOwnProperty("@uri")) + zombieList.descendants().item;
            for each(node in zombieAssets)
            {
               if(node.localName() == "item")
               {
                  itemXML = ItemFactory.getItemDefinition(node.@id.toString());
                  if(itemXML != null)
                  {
                     for each(itmURINode in itemXML.descendants().(hasOwnProperty("@uri")))
                     {
                        if(itmURINode.localName() != "img")
                        {
                           assetList.push(itmURINode.@uri.toString());
                        }
                     }
                  }
               }
               else
               {
                  uri = node.@uri.toString();
                  assetList.push(uri);
               }
            }
            zombieSoundList = zombieXML.sounds.zombieHuman.male.children() + zombieXML.sounds.zombieHuman.female.children() + zombieXML.sounds.zombieDog.children();
            for each(node in zombieSoundList)
            {
               assetList.push(node.toString());
            }
            if(Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("HalloweenTrickPumpkinZombie")) > 0)
            {
               itemsXML = ResourceManager.getInstance().getResource("xml/items.xml").content;
               pumpkinHatXML = itemsXML.item.(@id == "hat-pumpkin").attire.(@id == "hat-pumpkin")[0];
               for each(node in pumpkinHatXML.descendants().(hasOwnProperty("@uri")))
               {
                  assetList.push(node.@uri.toString());
               }
            }
         }
         for each(hEnemy in this._missionData.humanEnemies)
         {
            if(hEnemy != null)
            {
               assetList = assetList.concat(hEnemy.getResourceURIs());
               hEnemy.loadoutDefence.getAssets(assetList);
            }
         }
         if(Boolean(this._missionData.assignmentType) && this._missionData.assignmentType != AssignmentType.None)
         {
            assignment = Network.getInstance().playerData.assignments.getById(this._missionData.assignmentId);
            if(assignment.xml != null)
            {
               for each(fileNode in assignment.xml.resources.child("file"))
               {
                  fileUri = fileNode.@uri.toString();
                  if(Boolean(fileUri) && assetList.indexOf(fileUri) == -1)
                  {
                     assetList.push(fileUri);
                  }
               }
            }
            if(assignment.name == "stadium")
            {
               if(this._missionData.initZombieData != null && this._missionData.initZombieData.length > 3)
               {
                  zId = this._missionData.initZombieData[1];
                  zXml = ResourceManager.getInstance().get("xml/zombie.xml").zombies.zombie.(@id == zId)[0];
                  if(zXml != null && Boolean(zXml.hasOwnProperty("@elite")))
                  {
                     for each(zSpawnNode in zXml.audio.child("spawn"))
                     {
                        assetList.push(zSpawnNode.@uri.toString());
                     }
                  }
               }
            }
         }
         if(Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("HalloweenTrickPewPew")) > 0)
         {
            assetList.push("sound/weapons/pew-1.mp3","sound/weapons/pew-2.mp3","sound/weapons/pew-3.mp3","sound/weapons/pew-4.mp3","sound/weapons/pew-5.mp3");
         }
         this._assetLoader.loadingCompleted.addOnce(this.onAssetsCompleted);
         this._assetLoader.loadAssets(assetList);
      }
      
      private function onAssetsCompleted() : void
      {
         if(this._missionData.opponent.isPlayer || this._missionData.type == "compound")
         {
            this.loadCompleted.dispatch(this);
         }
         else
         {
            this._sceneLoader.loadCompleted.addOnce(this.onSceneComplated);
            this._sceneLoader.load(this.sceneXML);
         }
      }
      
      private function onSceneComplated(param1:SceneLoader) : void
      {
         this.loadCompleted.dispatch(this);
      }
      
      public function get missionData() : MissionData
      {
         return this._missionData;
      }
      
      public function get sceneXML() : XML
      {
         return this._sceneXML;
      }
   }
}

