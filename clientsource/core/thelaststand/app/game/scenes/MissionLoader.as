package thelaststand.app.game.scenes
{
   import flash.external.ExternalInterface;
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
      
      public function log(msg:String) : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.call("console.log",msg);
         }
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
         var assetList:Array;
         var xmlURI:String;
         var missionResources:XML;
         var node:XML;
         var srv:Survivor;
         var voicePackURI:String;
         var loadout:SurvivorLoadout;
         var enemySurvivors:SurvivorCollection;
         var i:int;
         var es:Survivor;
         var zombieXML:XML;
         var zombieList:XMLList;
         var usedWeapons:XMLList;
         var wNode:XML;
         var weaponNode:XML;
         var uriList:XMLList;
         var uriNode:XML;
         var uri:String;
         var soundList:XMLList;
         var zombieAssets:XMLList;
         var itemXML:XML;
         var itmURINode:XML;
         var zombieSoundList:XMLList;
         var pumpkinEffectVal:Number;
         var itemsXML:XML;
         var pumpkinHatXML:XML;
         var hEnemy:Survivor;
         var assignment:AssignmentData;
         var fileNode:XML;
         var fileUri:String;
         var zId:String;
         var zXml:XML;
         var zSpawnNode:XML;
         var pewVal:Number = 0;
         log("[loadMissionResources] Entering...");
         assetList = [];
         xmlURI = "resources_mission.xml";
         missionResources = ResourceManager.getInstance().getResource(xmlURI).content;
         log("[loadMissionResources] missionResources loaded.");
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
                     log("Added voice pack: " + voicePackURI);
                  }
               }
               loadout = this._missionData.isCompoundAttack() ? srv.loadoutDefence : srv.loadoutOffence;
               loadout.getAssets(assetList);
            }
         }
         if(this._missionData.opponent.isPlayer)
         {
            log("Opponent is player.");
            enemySurvivors = RemotePlayerData(this._missionData.opponent).compound.survivors;
            assetList = assetList.concat(enemySurvivors.getResourceURIs());
            i = 0;
            while(i < enemySurvivors.length)
            {
               es = enemySurvivors.getSurvivor(i);
               if(es != null)
               {
                  es.loadoutDefence.getAssets(assetList,false);
               }
               i++;
            }
         }
         else
         {
            log("Opponent is zombie.");
            zombieXML = ResourceManager.getInstance().getResource("xml/zombie.xml").content;
            if(!zombieXML)
            {
               log("[ERROR] zombie.xml is null!");
               return;
            }
            zombieList = ZombieDirector.getZombieDefinitionsForLevel(this._missionData.opponent.level);
            if(!zombieList || zombieList.length() == 0)
            {
               log("[ERROR] zombieList is empty or null!");
               return;
            }
            log("zombieList count: " + zombieList.length());
            usedWeapons = zombieList.weapon.@id;
            for each(wNode in usedWeapons)
            {
               weaponNode = zombieXML.weapons.item.(@id == wNode.toString())[0];
               if(weaponNode != null)
               {
                  uriList = weaponNode.descendants().(hasOwnProperty("@uri")) + weaponNode.weap.snd.children();
                  for each(uriNode in uriList)
                  {
                     uri = "@uri" in uriNode ? uriNode.@uri.toXMLString() : uriNode.toString();
                     assetList.push(uri);
                  }
               }
               else
               {
                  log("[WARN] Missing weaponNode for id: " + wNode);
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
            log("Adding default zombie anim assets.");
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
                  else
                  {
                     log("[WARN] Item not found: " + node.@id);
                  }
               }
               else
               {
                  uri = node.@uri.toString();
                  assetList.push(uri);
               }
            }
            log("Adding zombie sound variants...");
            zombieSoundList = zombieXML.sounds.zombieHuman.male.children() + zombieXML.sounds.zombieHuman.female.children() + zombieXML.sounds.zombieDog.children();
            for each(node in zombieSoundList)
            {
               assetList.push(node.toString());
               log("  Adding zombie sound: " + node.toString());
            }
            pumpkinEffectVal = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("HalloweenTrickPumpkinZombie"));
            log("PumpkinZombieEffect value = " + pumpkinEffectVal);
            if(pumpkinEffectVal > 0)
            {
               log("PumpkinZombieEffect is active, loading pumpkin hat assets...");
               itemsXML = ResourceManager.getInstance().getResource("xml/items.xml").content;
               pumpkinHatXML = itemsXML.item.(@id == "hat-pumpkin").attire.(@id == "hat-pumpkin")[0];
               if(!pumpkinHatXML)
               {
                  log("[ERROR] pumpkinHatXML is null!");
               }
               else
               {
                  for each(node in pumpkinHatXML.descendants().(hasOwnProperty("@uri")))
                  {
                     assetList.push(node.@uri.toString());
                     log("  Pumpkin hat asset: " + node.@uri.toString());
                  }
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
            log("AssignmentType active: " + this._missionData.assignmentType);
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
         pewVal = Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("HalloweenTrickPewPew"));
         log("PewPewEffect value = " + pewVal);
         if(pewVal > 0)
         {
            log("PewPewEffect is active, loading pew sounds.");
            assetList.push("sound/weapons/pew-1.mp3","sound/weapons/pew-2.mp3","sound/weapons/pew-3.mp3","sound/weapons/pew-4.mp3","sound/weapons/pew-5.mp3");
         }
         log("[loadMissionResources] Asset list complete, loading " + assetList.length + " assets.");
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

