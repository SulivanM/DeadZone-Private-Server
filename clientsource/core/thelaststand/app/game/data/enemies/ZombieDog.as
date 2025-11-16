package thelaststand.app.game.data.enemies
{
   import thelaststand.app.audio.Audio;
   import thelaststand.app.game.data.AnimalAppearance;
   import thelaststand.app.game.data.Zombie;
   import thelaststand.app.game.entities.actors.AnimalActor;
   import thelaststand.app.game.logic.ai.states.ActorDeathState;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.audio.SoundOutput;
   import thelaststand.engine.objects.GameEntity;
   
   public class ZombieDog extends Zombie
   {
      
      private static var _sounds:XMLList;
      
      private static var _staticDeathAnims:Array = ["death-static"];
      
      private static var _movingDeathAnims:Array = ["death-motion"];
      
      private var _actor:AnimalActor;
      
      private var _barkSound:SoundOutput;
      
      private var _idleSound:SoundOutput;
      
      private var _idleSoundTime:Number = 0;
      
      public function ZombieDog()
      {
         super();
         _enemyClass = "zombieDog";
         this._actor = new AnimalActor();
         this._actor.setHitAreaSize(80,60);
         this._actor.addedToScene.add(this.onActorAddedToScene);
         entity = this._actor;
         addActorListeners();
         agentData.visionRangeMin = 1500;
         agentData.visionRange = agentData.pursuitRange = agentData.visionRangeMin;
         agentData.visionFOVMin = Math.PI * 0.5;
         agentData.visionFOVMax = Math.PI;
         agentData.radius = 150;
         agentData.canBeKnockedBack = false;
         movementStarted.add(this.onMovementStarted);
         movementStopped.add(this.onMovementStopped);
      }
      
      override public function dispose() : void
      {
         movementStarted.remove(this.onMovementStarted);
         movementStopped.remove(this.onMovementStopped);
         if(this._actor != null)
         {
            this._actor.addedToScene.remove(this.onActorAddedToScene);
            this._actor = null;
         }
         if(this._idleSound != null)
         {
            soundSource.stop(this._idleSound);
            this._idleSound = null;
         }
         if(this._barkSound != null)
         {
            soundSource.stop(this._barkSound);
            this._barkSound = null;
         }
         super.dispose();
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
         if(this._barkSound != null)
         {
            soundSource.stop(this._barkSound);
            this._barkSound = null;
         }
      }
      
      override protected function onDie(param1:Object) : void
      {
         super.onDie(param1);
         stateMachine.setState(new ActorDeathState(this,_staticDeathAnims,_movingDeathAnims));
      }
      
      override public function update(param1:Number, param2:Number) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         super.update(param1,param2);
         if(_health > 0 && !agentData.attacking)
         {
            if(agentData.target != null && this._barkSound == null)
            {
               if(Math.random() < 0.02)
               {
                  _loc3_ = this.getSound("alert");
                  if(Audio.sound.getNumPlaying(_loc3_) == 0)
                  {
                     this._barkSound = soundSource.play(_loc3_,{"onComplete":this.onBarkSoundComplete});
                  }
               }
            }
            else if(this._idleSound == null)
            {
               if(this._idleSoundTime <= 0 && Math.random() < 0.5)
               {
                  _loc4_ = this.getSound("idle");
                  if(Audio.sound.getNumPlaying(_loc4_) == 0)
                  {
                     this._idleSound = soundSource.play(_loc4_,{"onComplete":this.onIdleSoundComplete});
                  }
                  this._idleSoundTime = 3 + Math.random() * 5;
               }
               else
               {
                  this._idleSoundTime -= param1;
               }
            }
         }
      }
      
      override public function getSound(param1:String) : String
      {
         var _loc2_:XML = null;
         if(_sounds == null)
         {
            _loc2_ = ResourceManager.getInstance().getResource("xml/zombie.xml").content;
            _sounds = _loc2_.sounds.zombieDog[param1];
         }
         if(_sounds.length() == 0)
         {
            return null;
         }
         return _sounds[int(Math.random() * _sounds.length())].toString();
      }
      
      override protected function addAnimations() : void
      {
         this._actor.addAnimation("models/anim/animal-dog.anim");
      }
      
      override protected function setupModel() : void
      {
         var _loc1_:XML = _xml.mdl[0];
         var _loc2_:XMLList = _loc1_.type;
         var _loc3_:XML = _loc2_[int(Math.random() * _loc2_.length())];
         var _loc4_:XML = _loc3_.mdl[int(Math.random() * _loc3_.mdl.length())];
         var _loc5_:XML = _loc3_.tex[int(Math.random() * _loc3_.tex.length())];
         var _loc6_:AnimalAppearance = new AnimalAppearance();
         _loc6_.body.id = "zombieDogBody";
         _loc6_.body.model = _loc4_.@uri.toString().toLowerCase();
         _loc6_.body.texture = _loc5_.@uri.toString().toLowerCase();
         _loc6_.body.uniqueTexture = true;
         this._actor.setAppearance(_loc6_);
      }
      
      private function onIdleSoundComplete() : void
      {
         this._idleSound = null;
      }
      
      private function onBarkSoundComplete() : void
      {
         this._barkSound = null;
      }
      
      private function onActorAddedToScene(param1:GameEntity) : void
      {
         this._actor.applyAppearance();
         this._actor.animatedAsset.gotoAndPlay(getAnimation("idle"),0,true,1,0);
         this._idleSoundTime = 0.5 + Math.random() * 5;
      }
      
      private function onMovementStarted(param1:ZombieDog) : void
      {
         this._actor.animatedAsset.play(_moveAnim,true);
      }
      
      private function onMovementStopped(param1:ZombieDog) : void
      {
         this._actor.animatedAsset.play(getAnimation("idle"),true);
      }
   }
}

