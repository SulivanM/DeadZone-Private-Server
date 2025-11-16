package thelaststand.app.game.logic
{
   import com.exileetiquette.math.MathUtils;
   import com.exileetiquette.sound.SoundData;
   import flash.utils.getTimer;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.Zombie;
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.game.data.arena.ArenaStageData;
   import thelaststand.app.game.entities.buildings.StadiumButtonEntity;
   import thelaststand.app.game.logic.ai.AIActorAgent;
   import thelaststand.app.network.Network;
   import thelaststand.common.resources.ResourceManager;
   import thelaststand.engine.objects.GameEntity;
   
   public class ArenaMissionController
   {
      
      private var _disposed:Boolean;
      
      private var _director:MissionDirector;
      
      private var _session:ArenaSession;
      
      private var _stage:ArenaStageData;
      
      private var _currentAnnouncerSound:SoundData;
      
      private var _currentAnnouncerSoundPriority:int = -2147483648;
      
      private var _allDead:Boolean;
      
      private var _timerWarningPlaying:Boolean;
      
      private var _ambientSound:SoundData;
      
      private var _nextDeathTime:Number;
      
      public function ArenaMissionController(param1:MissionDirector)
      {
         super();
         this._director = param1;
         this._session = ArenaSession(Network.getInstance().playerData.assignments.getById(this._director.missionData.assignmentId));
         this._stage = this._session.getArenaStage(this._session.currentStageIndex);
         this._director.playerSurvivorDied.add(this.onPlayerSurvivorDied);
         this._director.allPlayerSurvivorsDied.addOnce(this.onAllPlayerSurvivorsDied);
         this._director.enemyDied.add(this.onEnemyDied);
         this._director.enemySpawned.add(this.onEnemySpawn);
         this._director.timerExhausted.addOnce(this.onTimerExhausted);
         this._director.scavengedCompleted.add(this.onScavengeCompleted);
      }
      
      public function start() : void
      {
         this._director.guiLayer.ui_timer.warningSoundEnabled = false;
         this._ambientSound = this.playRandomSound(this.getArenaAudioList("ambient"),{"loops":-1});
         this._nextDeathTime = getTimer() + MathUtils.randomBetween(5,20) * 1000;
         this.playAnnouncerArenaSound("start");
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         if(!this._timerWarningPlaying)
         {
            if(param2 - this._director.startTime >= (this._director.missionData.missionTime - 30) * 1000)
            {
               this._timerWarningPlaying = true;
               this.playRandomSound(this.getArenaAudioList("timer_warning"));
            }
         }
      }
      
      public function end() : void
      {
         if(this._ambientSound != null)
         {
            this._ambientSound.stop();
            this._ambientSound = null;
         }
      }
      
      public function dispose() : void
      {
         if(this._disposed)
         {
            return;
         }
         this._disposed = true;
      }
      
      private function playAnnouncerArenaSound(param1:String, param2:int = 0) : void
      {
         if(this._currentAnnouncerSound != null && param2 <= this._currentAnnouncerSoundPriority)
         {
            return;
         }
         this.playRandomAnnouncerSound(this.getArenaAudioList(param1),param2);
      }
      
      private function playAnnouncerEliteSpawnSound(param1:String) : void
      {
         var zombieNode:XML = null;
         var eliteId:String = param1;
         zombieNode = ResourceManager.getInstance().get("xml/zombie.xml").zombies.zombie.(@id == eliteId)[0];
         if(zombieNode == null)
         {
            return;
         }
         this.playRandomAnnouncerSound(zombieNode.audio.child("spawn"),int.MAX_VALUE - 1);
      }
      
      private function playRandomAnnouncerSound(param1:XMLList, param2:int = 0) : void
      {
         if(param1 == null || param1.length() == 0)
         {
            return;
         }
         var _loc3_:int = Math.random() * param1.length();
         var _loc4_:String = param1[_loc3_].@uri;
         if(!_loc4_)
         {
            return;
         }
         this.stopAnnouncerSound();
         this._currentAnnouncerSoundPriority = param2;
         this._currentAnnouncerSound = Audio.sound.play(_loc4_,{"onComplete":this.onAnnouncerSoundComplete});
      }
      
      private function playRandomSound(param1:XMLList, param2:Object = null) : SoundData
      {
         if(param1 == null || param1.length() == 0)
         {
            return null;
         }
         var _loc3_:int = Math.random() * param1.length();
         var _loc4_:String = param1[_loc3_].@uri;
         return Audio.sound.play(_loc4_,param2);
      }
      
      private function stopAnnouncerSound() : void
      {
         if(this._currentAnnouncerSound != null)
         {
            this._currentAnnouncerSound.stop();
            this._currentAnnouncerSound = null;
         }
      }
      
      private function getArenaAudioList(param1:String) : XMLList
      {
         var _loc2_:XMLList = this._stage.stageXml.audio.child(param1);
         if(_loc2_.length() > 0)
         {
            return _loc2_;
         }
         var _loc3_:XMLList = this._session.xml.audio.child(param1);
         if(_loc3_.length() > 0)
         {
            return _loc3_;
         }
         return null;
      }
      
      private function onAnnouncerSoundComplete() : void
      {
         if(this._disposed)
         {
            return;
         }
         this._currentAnnouncerSound = null;
         this._currentAnnouncerSoundPriority = int.MIN_VALUE;
      }
      
      private function onPlayerSurvivorDied(param1:Survivor, param2:Object) : void
      {
         this.playAnnouncerArenaSound("survivor_death");
      }
      
      private function onEnemySpawn(param1:AIActorAgent) : void
      {
         var _loc2_:Zombie = null;
         if(param1.isElite)
         {
            _loc2_ = param1 as Zombie;
            if(_loc2_ != null)
            {
               this.playAnnouncerEliteSpawnSound(_loc2_.type);
            }
         }
      }
      
      private function onEnemyDied(param1:AIActorAgent, param2:Object) : void
      {
         var _loc3_:Zombie = param1 as Zombie;
         if(_loc3_ != null)
         {
            if(_loc3_.explodedOnDeath)
            {
               this.playAnnouncerArenaSound("zombie_explode");
            }
            else if(getTimer() > this._nextDeathTime)
            {
               this.playAnnouncerArenaSound("zombie_death",-100);
               this._nextDeathTime = getTimer() + MathUtils.randomBetween(15,30) * 1000;
            }
         }
      }
      
      private function onTimerExhausted() : void
      {
         if(!this._allDead)
         {
            this.playAnnouncerArenaSound("win",int.MAX_VALUE);
         }
      }
      
      private function onScavengeCompleted(param1:Survivor, param2:GameEntity) : void
      {
         if(param2 is StadiumButtonEntity)
         {
            this.playAnnouncerArenaSound("score");
         }
      }
      
      private function onAllPlayerSurvivorsDied() : void
      {
         this._allDead = true;
         this.playAnnouncerArenaSound("lose",int.MAX_VALUE);
      }
   }
}

