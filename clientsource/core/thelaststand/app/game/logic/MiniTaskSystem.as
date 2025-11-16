package thelaststand.app.game.logic
{
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.quests.MiniTask;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.resources.ResourceManager;
   
   public class MiniTaskSystem
   {
      
      private static var _instance:MiniTaskSystem;
      
      private var _initialized:Boolean = false;
      
      private var _achievements:Vector.<MiniTask> = new Vector.<MiniTask>();
      
      private var _achievementsById:Dictionary = new Dictionary(true);
      
      public var achievementCompleted:Signal = new Signal(MiniTask,Number,int);
      
      public function MiniTaskSystem(param1:MiniTaskSystemSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("MiniTaskSystem is a Singleton and cannot be directly instantiated. Use MiniTaskSystem.getInstance().");
         }
      }
      
      public static function getInstance() : MiniTaskSystem
      {
         if(!_instance)
         {
            _instance = new MiniTaskSystem(new MiniTaskSystemSingletonEnforcer());
         }
         return _instance;
      }
      
      public function init() : void
      {
         var xml:XML;
         var node:XML = null;
         var ach:MiniTask = null;
         if(this._initialized)
         {
            return;
         }
         this._initialized = true;
         xml = ResourceManager.getInstance().getResource("xml/quests.xml").content;
         for each(node in xml.repeat.ach)
         {
            try
            {
               ach = new MiniTask();
               ach.parseXML(node);
               this.addAchievement(ach);
            }
            catch(error:Error)
            {
            }
         }
      }
      
      public function addAchievement(param1:MiniTask) : void
      {
         if(this._achievements.indexOf(param1) > -1)
         {
            return;
         }
         if(param1.id in this._achievementsById)
         {
            throw new Error("MiniTask with id \'" + param1.id + "\' already in system. Ids must be unique.");
         }
         this._achievements.push(param1);
         this._achievementsById[param1.id] = param1;
         param1.completed.add(this.onAchievementCompleted);
      }
      
      public function getAchievement(param1:String) : MiniTask
      {
         return this._achievementsById[param1];
      }
      
      public function resetMissionAchievements() : void
      {
         var _loc1_:MiniTask = null;
         for each(_loc1_ in this._achievements)
         {
            if(_loc1_.missionOnly)
            {
               _loc1_.resetMissionCounts();
            }
         }
      }
      
      public function updateTimers(param1:Number) : void
      {
         var _loc2_:MiniTask = null;
         for each(_loc2_ in this._achievements)
         {
            _loc2_.updateTimer(param1);
         }
      }
      
      public function dispatchTaskComplete(param1:MiniTask, param2:Number = 0, param3:int = 0) : void
      {
         this.achievementCompleted.dispatch(param1,param2,param3);
      }
      
      private function onAchievementCompleted(param1:MiniTask) : void
      {
         var ach:MiniTask = param1;
         var val:Number = ach.value;
         var xp:int = ach.xp;
         Network.getInstance().save({
            "id":ach.id,
            "val":val,
            "xp":xp
         },SaveDataMethod.REPEAT_ACHIEVEMENT,function(param1:Object):void
         {
            if(param1 == null || param1.success === false)
            {
               return;
            }
            dispatchTaskComplete(ach,Number(param1.val),int(param1.xp));
         });
      }
   }
}

class MiniTaskSystemSingletonEnforcer
{
   
   public function MiniTaskSystemSingletonEnforcer()
   {
      super();
   }
}
