package thelaststand.app.game.data.enemies
{
   import thelaststand.app.audio.Audio;
   import thelaststand.app.game.data.AttireData;
   import thelaststand.app.game.data.AttireOverlay;
   import thelaststand.app.game.data.Gender;
   import thelaststand.app.game.data.HumanAppearance;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.Zombie;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.entities.actors.ZombieHumanActor;
   import thelaststand.app.game.logic.ai.states.ActorDeathState;
   import thelaststand.app.network.Network;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.audio.SoundOutput;
   import thelaststand.engine.objects.GameEntity;
   
   public class ZombieHuman extends Zombie
   {
      
      private static var _sounds_male:XML;
      
      private static var _sounds_female:XML;
      
      private static var _staticDeathAnims:Array = ["death","death-back","death-forward"];
      
      private static var _movingDeathAnims:Array = ["death-clothesline","death-faceslide"];
      
      private var _actor:ZombieHumanActor;
      
      private var _gender:String = "male";
      
      private var _idleSound:SoundOutput;
      
      private var _idleSoundTime:Number = 0;
      
      public function ZombieHuman()
      {
         super();
         _enemyClass = "zombieHuman";
         this._actor = new ZombieHumanActor();
         this._actor.setHitAreaSize(60,150);
         this._actor.addedToScene.add(this.onActorAddedToScene);
         entity = this._actor;
         addActorListeners();
         agentData.visionRangeMin = 1500;
         agentData.visionRange = agentData.pursuitRange = agentData.visionRangeMin;
         agentData.visionFOVMin = Math.PI * 0.8;
         agentData.visionFOVMax = Math.PI;
         agentData.radius = 100;
         agentData.canBeKnockedBack = true;
         movementStarted.add(this.onMovementStarted);
         movementStopped.add(this.onMovementStopped);
      }
      
      override public function dispose() : void
      {
         if(this._idleSound != null)
         {
            soundSource.stop(this._idleSound);
            this._idleSound = null;
         }
         movementStarted.remove(this.onMovementStarted);
         movementStopped.remove(this.onMovementStopped);
         super.dispose();
         if(this._actor != null)
         {
            this._actor.addedToScene.remove(this.onActorAddedToScene);
            this._actor = null;
         }
      }
      
      override public function reset() : void
      {
         super.reset();
         if(this._actor != null)
         {
            if(this._actor.scene != null)
            {
               this._actor.scene.removeEntity(this._actor);
            }
            this._actor.clear();
         }
         if(this._idleSound != null)
         {
            soundSource.stop(this._idleSound);
            this._idleSound = null;
         }
      }
      
      override public function getSound(param1:String) : String
      {
         var _loc4_:XML = null;
         var _loc2_:XML = ZombieHuman["_sounds_" + this._gender];
         if(_loc2_ == null)
         {
            _loc4_ = ResourceManager.getInstance().getResource("xml/zombie.xml").content;
            _loc2_ = ZombieHuman["_sounds_" + this._gender] = _loc4_.sounds.zombieHuman[this._gender][0];
            if(_sounds_male == null)
            {
               return null;
            }
         }
         var _loc3_:XMLList = _loc2_[param1];
         if(_loc3_.length() == 0)
         {
            return null;
         }
         return _loc3_[int(Math.random() * _loc3_.length())].toString();
      }
      
      override protected function onDie(param1:Object) : void
      {
         super.onDie(param1);
         stateMachine.setState(new ActorDeathState(this,_staticDeathAnims,_movingDeathAnims));
      }
      
      override public function update(param1:Number, param2:Number) : void
      {
         var _loc3_:String = null;
         super.update(param1,param2);
         if(_health > 0 && this._idleSound == null && !agentData.attacking)
         {
            if(this._idleSoundTime <= 0 && Math.random() < 0.005)
            {
               _loc3_ = this.getSound("idle");
               if(Audio.sound.getNumPlaying(_loc3_) == 0)
               {
                  this._idleSound = soundSource.play(_loc3_,{"onComplete":this.onIdleSoundComplete});
               }
               this._idleSoundTime = 3 + Math.random() * 5;
            }
            else
            {
               this._idleSoundTime -= param1;
            }
         }
      }
      
      override protected function addAnimations() : void
      {
         actor.addAnimation("models/anim/zombie.anim");
         actor.addAnimation("models/anim/death.anim");
      }
      
      override protected function setupModel() : void
      {
         var modelData:XML;
         var appearance:HumanAppearance;
         var upperNode:XML;
         var upperMdlNode:XML;
         var upperTexNode:XML;
         var lowerNode:XML;
         var lowerMdlNode:XML;
         var lowerTexNode:XML;
         var hairList:XMLList;
         var accList:XMLList;
         var acc:AttireData = null;
         var hairNode:XML = null;
         var hairMdlNode:XML = null;
         var hairTexNode:XML = null;
         var accNode:XML = null;
         var itemNode:XML = null;
         var itemXML:XML = null;
         var attireNode:XML = null;
         var accMdlNode:XML = null;
         var accTexNode:XML = null;
         var pumpkinHatXML:XML = null;
         var pumpkinHat:AttireData = null;
         var modelNode:XML = _xml.mdl[0];
         if(!modelNode.hasOwnProperty(Gender.MALE) == -1)
         {
            this._gender = Gender.FEMALE;
         }
         else
         {
            this._gender = Gender.MALE;
            if(Boolean(modelNode.hasOwnProperty(Gender.FEMALE)) && Math.random() <= 0.25)
            {
               this._gender = Gender.FEMALE;
            }
         }
         modelData = modelNode[this._gender][0];
         appearance = new HumanAppearance();
         appearance.skin.uniqueTexture = true;
         appearance.skin.texture = modelData.skin.tex[int(Math.random() * modelData.skin.tex.length())].@uri.toString().toLowerCase();
         upperNode = modelData.upper[int(Math.random() * modelData.upper.length())];
         upperMdlNode = upperNode.mdl[int(Math.random() * upperNode.mdl.length())];
         upperTexNode = upperNode.tex[int(Math.random() * upperNode.tex.length())];
         appearance.upperBody.model = upperMdlNode.@uri.toString().toLowerCase();
         appearance.upperBody.texture = upperTexNode.@uri.toString().toLowerCase();
         appearance.upperBody.uniqueTexture = true;
         if(upperTexNode.@overlays != "0")
         {
            appearance.upperBody.overlays.push(new AttireOverlay("upper","models/characters/zombies/blood-overlay-upper.png"));
         }
         if(!upperTexNode.hasOwnProperty("@allowBrightness") || upperTexNode.@allowBrightness == "1")
         {
            appearance.upperBody.brightness = (Math.random() * 2 - 1) * 0.75;
         }
         if(!upperTexNode.hasOwnProperty("@allowHue") || upperTexNode.@allowHue == "1")
         {
            appearance.upperBody.hue = Math.random() * 360;
         }
         lowerNode = modelData.lower[int(Math.random() * modelData.lower.length())];
         lowerMdlNode = lowerNode.mdl[int(Math.random() * lowerNode.mdl.length())];
         lowerTexNode = lowerNode.tex[int(Math.random() * lowerNode.tex.length())];
         appearance.lowerBody.model = lowerMdlNode.@uri.toString().toLowerCase();
         appearance.lowerBody.texture = lowerTexNode.@uri.toString().toLowerCase();
         appearance.lowerBody.uniqueTexture = true;
         if(lowerTexNode.@overlays != "0")
         {
            appearance.lowerBody.overlays.push(new AttireOverlay("lower","models/characters/zombies/blood-overlay-lower.png"));
         }
         if(!lowerTexNode.hasOwnProperty("@allowBrightness") || lowerTexNode.@allowBrightness == "1")
         {
            appearance.lowerBody.brightness = (Math.random() * 2 - 1) * 0.75;
         }
         if(!lowerTexNode.hasOwnProperty("@allowHue") || lowerTexNode.@allowHue == "1")
         {
            appearance.lowerBody.hue = Math.random() * 360;
         }
         hairList = modelData.hair;
         if(hairList.length() > 0)
         {
            hairNode = hairList[int(Math.random() * hairList.length())];
            if(hairNode != null)
            {
               hairMdlNode = hairNode.mdl[int(Math.random() * hairNode.mdl.length())];
               if(hairMdlNode != null && Boolean(hairMdlNode.hasOwnProperty("@uri")))
               {
                  hairTexNode = hairNode.tex[int(Math.random() * hairNode.tex.length())];
                  appearance.hair.model = hairMdlNode.@uri.toString();
                  appearance.hair.texture = hairTexNode.@uri.toString().toLowerCase();
                  appearance.hair.uniqueTexture = true;
               }
            }
         }
         accList = modelData.acc;
         if(accList.length() > 0)
         {
            for each(accNode in accList)
            {
               itemNode = accNode.item[0];
               if(itemNode != null)
               {
                  itemXML = ItemFactory.getItemDefinition(itemNode.@id.toString());
                  if(itemXML != null)
                  {
                     for each(attireNode in itemXML.attire)
                     {
                        acc = new AttireData();
                        acc.parseXML(attireNode,this._gender);
                        appearance.addAccessory(acc);
                     }
                  }
               }
               else
               {
                  accMdlNode = accNode.mdl[int(Math.random() * accNode.mdl.length())];
                  if(accMdlNode != null && Boolean(accMdlNode.hasOwnProperty("@uri")))
                  {
                     accTexNode = accNode.tex[int(Math.random() * accMdlNode.tex.length())];
                     acc = new AttireData();
                     acc.model = accMdlNode.@uri.toString();
                     acc.texture = accTexNode.@uri.toString();
                     appearance.addAccessory(acc);
                  }
               }
            }
         }
         if(Network.getInstance().playerData.compound.getEffectValue(EffectType.getTypeValue("HalloweenTrickPumpkinZombie")) > 0)
         {
            pumpkinHatXML = ItemFactory.getItemDefinition("hat-pumpkin").attire.(@id == "hat-pumpkin")[0];
            pumpkinHat = new AttireData();
            pumpkinHat.parseXML(pumpkinHatXML,this._gender);
            appearance.addAccessory(pumpkinHat);
         }
         this._actor.setAppearance(appearance);
      }
      
      private function setupAccessories() : void
      {
         if(_weapon != null && _weapon.xml.mdl != null)
         {
            this._actor.setRightHandItem(_weapon.xml.mdl.@uri.toString(),_weapon.attachments);
            this._actor.addAnimation("models/anim/human-weapons-" + _weapon.animType + ".anim");
         }
         this._actor.refreshAnimations();
      }
      
      private function onActorAddedToScene(param1:GameEntity) : void
      {
         this._actor.applyAppearance();
         this.setupAccessories();
         this._actor.animatedAsset.gotoAndPlay(getAnimation("idle"),0,true,1,0);
         this._idleSoundTime = 0.5 + Math.random() * 5;
      }
      
      private function onMovementStarted(param1:ZombieHuman) : void
      {
         this._actor.animatedAsset.play(_moveAnim,true);
      }
      
      private function onMovementStopped(param1:ZombieHuman) : void
      {
         this._actor.animatedAsset.play(getAnimation("idle"),true,1,1.25);
      }
      
      private function onIdleSoundComplete() : void
      {
         this._idleSound = null;
      }
   }
}

