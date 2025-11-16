package thelaststand.app.game.data.arena
{
   import com.dynamicflash.util.Base64;
   import com.exileetiquette.math.MathUtils;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Global;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.data.NavigationLocation;
   import thelaststand.app.data.PlayerData;
   import thelaststand.app.events.NavigationEvent;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.ZombieOpponentData;
   import thelaststand.app.game.data.assignment.AssignmentStageData;
   import thelaststand.app.game.data.assignment.AssignmentStageState;
   import thelaststand.app.game.data.assignment.AssignmentType;
   import thelaststand.app.game.logic.DialogueController;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.lang.Language;
   
   public class ArenaSystem
   {
      
      public static var sessionStarted:Signal = new Signal(ArenaSession);
      
      public static var sessionEnded:Signal = new Signal(ArenaSession);
      
      public function ArenaSystem()
      {
         super();
      }
      
      public static function updateState(param1:ArenaSession) : void
      {
         var _loc4_:String = null;
         var _loc5_:Survivor = null;
         var _loc2_:Object = {"hp":{}};
         var _loc3_:PlayerData = Network.getInstance().playerData;
         for each(_loc4_ in param1.survivorIds)
         {
            _loc5_ = _loc3_.compound.survivors.getSurvivorById(_loc4_);
            if(_loc5_ != null)
            {
               _loc2_.hp[_loc4_] = MathUtils.clamp01(_loc5_.health / _loc5_.maxHealth);
            }
         }
         Network.getInstance().save(_loc2_,SaveDataMethod.ARENA_UPDATE);
      }
      
      public static function handleMissionResult(param1:Object, param2:MissionData) : void
      {
         var _loc3_:int = 0;
         var _loc9_:AssignmentStageData = null;
         var _loc10_:String = null;
         var _loc11_:Survivor = null;
         var _loc12_:Array = null;
         var _loc13_:Item = null;
         var _loc4_:ArenaSession = Network.getInstance().playerData.assignments.getById(param1.id) as ArenaSession;
         if(_loc4_ == null)
         {
            return;
         }
         var _loc5_:Network = Network.getInstance();
         var _loc6_:ArenaStageData = _loc4_.getArenaStage(_loc4_.currentStageIndex);
         _loc6_.survivorCount = int(param1.srvcount);
         _loc6_.survivorPoints = int(param1.srvpoints);
         _loc6_.objectivePoints = int(param1.objpoints);
         _loc4_.completedStageIndex = _loc6_.index;
         var _loc7_:Boolean = Boolean(param1.completed);
         _loc4_.isCompleted = _loc7_;
         _loc4_.points = int(param1.points);
         _loc4_.currentStageIndex = int(param1.stage);
         _loc3_ = 0;
         while(_loc3_ < _loc4_.stageCount)
         {
            _loc9_ = _loc4_.getArenaStage(_loc3_);
            if(_loc3_ < _loc4_.currentStageIndex)
            {
               _loc9_.state = AssignmentStageState.COMPLETE;
            }
            else if(_loc3_ == _loc4_.currentStageIndex)
            {
               _loc9_.state = AssignmentStageState.ACTIVE;
            }
            else
            {
               _loc9_.state = AssignmentStageState.LOCKED;
            }
            _loc3_++;
         }
         var _loc8_:Array = param1.returnsurvivors as Array;
         _loc3_ = 0;
         while(_loc3_ < _loc8_.length)
         {
            _loc10_ = _loc8_[_loc3_];
            _loc11_ = _loc5_.playerData.compound.survivors.getSurvivorById(_loc10_);
            _loc11_.assignmentId = null;
            _loc11_.missionId = null;
            _loc4_.removeSurvivor(_loc11_);
            _loc3_++;
         }
         if(param1.cooldown != null)
         {
            _loc5_.playerData.cooldowns.parse(Base64.decodeToByteArray(param1.cooldown));
         }
         if(_loc7_)
         {
            _loc4_.successful = Boolean(param1.assignsuccess);
            _loc4_.rewardItems = new Vector.<Item>();
            if(param1.items is Array)
            {
               _loc12_ = param1.items;
               _loc3_ = 0;
               while(_loc3_ < _loc12_.length)
               {
                  _loc13_ = ItemFactory.createItemFromObject(_loc12_[_loc3_]);
                  if(_loc13_ != null)
                  {
                     _loc4_.rewardItems.push(_loc13_);
                     _loc5_.playerData.giveItem(_loc13_,true);
                     if(param2 != null)
                     {
                        param2.addLootItem(_loc13_);
                     }
                  }
                  _loc3_++;
               }
            }
            Global.completedAssignment = _loc4_;
            _loc5_.playerData.assignments.remove(_loc4_);
            _loc5_.playerData.checkAndUpdateLoadouts();
            ArenaSystem.sessionEnded.dispatch(_loc4_);
            try
            {
               if(_loc4_.successful)
               {
                  Tracking.trackEvent("Arena","Completed",_loc4_.name);
               }
               else
               {
                  Tracking.trackEvent("Arena","Failed",_loc4_.name,_loc6_.index);
               }
            }
            catch(error:Error)
            {
            }
         }
      }
      
      public static function finishSession(param1:ArenaSession, param2:MissionData, param3:Function = null) : void
      {
         var data:Object;
         var busy:BusyDialogue = null;
         var network:Network = null;
         var session:ArenaSession = param1;
         var missionData:MissionData = param2;
         var onComplete:Function = param3;
         if(!session.hasStarted)
         {
            if(onComplete != null)
            {
               onComplete(false);
            }
            return;
         }
         busy = new BusyDialogue(Language.getInstance().getString("arena.abandoning"));
         busy.open();
         data = {"id":session.id};
         network = Network.getInstance();
         network.save(data,SaveDataMethod.ARENA_FINISH,function(param1:Object):void
         {
            var _loc3_:String = null;
            var _loc4_:Survivor = null;
            var _loc5_:Array = null;
            var _loc6_:Item = null;
            busy.close();
            if(param1 == null || param1.success === false)
            {
               DialogueController.getInstance().showGenericRequestError();
               if(onComplete != null)
               {
                  onComplete(false);
               }
               return;
            }
            session.bailOut = true;
            session.isCompleted = true;
            session.successful = false;
            session.points = int(param1.points);
            session.rewardItems = new Vector.<Item>();
            var _loc2_:int = 0;
            while(_loc2_ < session.survivorIds.length)
            {
               _loc3_ = session.survivorIds[_loc2_];
               _loc4_ = network.playerData.compound.survivors.getSurvivorById(_loc3_);
               if(_loc4_ != null)
               {
                  _loc4_.assignmentId = null;
                  _loc4_.missionId = null;
               }
               _loc2_++;
            }
            if(param1.items is Array)
            {
               _loc5_ = param1.items;
               _loc2_ = 0;
               while(_loc2_ < _loc5_.length)
               {
                  _loc6_ = ItemFactory.createItemFromObject(_loc5_[_loc2_]);
                  if(_loc6_ != null)
                  {
                     session.rewardItems.push(_loc6_);
                     network.playerData.giveItem(_loc6_,true);
                     if(missionData != null)
                     {
                        missionData.addLootItem(_loc6_);
                     }
                  }
                  _loc2_++;
               }
            }
            if(param1.cooldown != null)
            {
               network.playerData.cooldowns.parse(Base64.decodeToByteArray(param1.cooldown));
            }
            Global.completedAssignment = session;
            network.playerData.assignments.remove(session);
            network.playerData.checkAndUpdateLoadouts();
            if(onComplete != null)
            {
               onComplete(true);
            }
            ArenaSystem.sessionEnded.dispatch(session);
            try
            {
               Tracking.trackEvent("Arena","Ended",session.name,session.currentStageIndex);
            }
            catch(error:Error)
            {
            }
         });
      }
      
      public static function launchSession(param1:ArenaSession, param2:Function = null) : void
      {
         var data:Object;
         var missionData:MissionData = null;
         var busy:BusyDialogue = null;
         var onMissionStarted:Function = null;
         var i:int = 0;
         var srv:Survivor = null;
         var session:ArenaSession = param1;
         var onComplete:Function = param2;
         busy = new BusyDialogue(Language.getInstance().getString("arena.launching"));
         busy.open();
         onMissionStarted = function():void
         {
            if(onComplete != null)
            {
               onComplete(true);
            }
            Network.getInstance().playerData.missionList.addMission(missionData);
            Global.stage.dispatchEvent(new NavigationEvent(NavigationEvent.REQUEST,NavigationLocation.MISSION,missionData));
         };
         data = {};
         if(session.hasStarted)
         {
            data.id = session.id;
            Network.getInstance().save(data,SaveDataMethod.ARENA_CONTINUE,function(param1:Object):void
            {
               busy.close();
               if(param1 == null || param1.success !== true)
               {
                  DialogueController.getInstance().showGenericRequestError();
                  if(onComplete != null)
                  {
                     onComplete(false);
                  }
                  return;
               }
               missionData = createMissionData(session,param1.mission);
               missionData.startMission(onMissionStarted);
            });
         }
         else
         {
            data.name = session.name;
            data.survivors = [];
            data.loadout = [];
            i = 0;
            while(i < session.survivorIds.length)
            {
               srv = Network.getInstance().playerData.compound.survivors.getSurvivorById(session.survivorIds[i]);
               data.survivors.push(srv.id);
               data.loadout.push(srv.loadoutOffence.toHashtable());
               i++;
            }
            Network.getInstance().save(data,SaveDataMethod.ARENA_START,function(param1:Object):void
            {
               var _loc2_:int = 0;
               var _loc4_:String = null;
               var _loc5_:Survivor = null;
               busy.close();
               if(param1 == null || param1.success !== true)
               {
                  DialogueController.getInstance().showGenericRequestError();
                  if(onComplete != null)
                  {
                     onComplete(false);
                  }
                  return;
               }
               session.id = String(param1.id);
               session.hasStarted = true;
               session.survivorIds.length = 0;
               var _loc3_:Array = param1.survivors as Array;
               _loc2_ = 0;
               while(_loc2_ < _loc3_.length)
               {
                  session.survivorIds.push(String(_loc3_[_loc2_]));
                  _loc2_++;
               }
               _loc2_ = 0;
               while(_loc2_ < session.survivorIds.length)
               {
                  _loc4_ = session.survivorIds[_loc2_];
                  if(_loc4_ != null)
                  {
                     _loc5_ = Network.getInstance().playerData.compound.survivors.getSurvivorById(_loc4_);
                     _loc5_.assignmentId = session.id;
                  }
                  _loc2_++;
               }
               Network.getInstance().playerData.assignments.add(session);
               missionData = createMissionData(session,param1.mission);
               missionData.startMission(onMissionStarted);
               ArenaSystem.sessionStarted.dispatch(session);
               try
               {
                  Tracking.trackEvent("Arena","Started",session.name);
               }
               catch(error:Error)
               {
               }
            });
         }
      }
      
      public static function abortSession(param1:ArenaSession, param2:Function = null) : void
      {
         var data:Object;
         var busy:BusyDialogue = null;
         var network:Network = null;
         var session:ArenaSession = param1;
         var onComplete:Function = param2;
         busy = new BusyDialogue(Language.getInstance().getString("arena.abandoning"));
         busy.open();
         data = {"id":session.id};
         network = Network.getInstance();
         network.save(data,SaveDataMethod.ARENA_ABORT,function(param1:Object):void
         {
            var _loc3_:String = null;
            var _loc4_:Survivor = null;
            busy.close();
            if(param1 == null || param1.success === false)
            {
               DialogueController.getInstance().showGenericRequestError();
               if(onComplete != null)
               {
                  onComplete(false);
               }
               return;
            }
            var _loc2_:int = 0;
            while(_loc2_ < session.survivorIds.length)
            {
               _loc3_ = session.survivorIds[_loc2_];
               _loc4_ = network.playerData.compound.survivors.getSurvivorById(_loc3_);
               if(_loc4_ != null)
               {
                  _loc4_.assignmentId = null;
                  _loc4_.missionId = null;
               }
               _loc2_++;
            }
            if(param1.cooldown != null)
            {
               network.playerData.cooldowns.parse(Base64.decodeToByteArray(param1.cooldown));
            }
            network.playerData.assignments.remove(session);
            network.playerData.checkAndUpdateLoadouts();
            if(onComplete != null)
            {
               onComplete(true);
            }
            ArenaSystem.sessionEnded.dispatch(session);
            try
            {
               Tracking.trackEvent("Arena","Aborted",session.name + "_" + session.currentStageIndex,session.currentStageIndex);
            }
            catch(error:Error)
            {
            }
         });
      }
      
      private static function createMissionData(param1:ArenaSession, param2:Object) : MissionData
      {
         var _loc5_:String = null;
         var _loc6_:Survivor = null;
         var _loc3_:MissionData = new MissionData();
         _loc3_.assignmentId = param1.id;
         _loc3_.assignmentType = AssignmentType.Arena;
         _loc3_.opponent = new ZombieOpponentData(int(param2.level));
         var _loc4_:int = 0;
         while(_loc4_ < param1.survivorIds.length)
         {
            _loc5_ = param1.survivorIds[_loc4_];
            _loc6_ = Network.getInstance().playerData.compound.survivors.getSurvivorById(_loc5_);
            _loc3_.survivors.push(_loc6_);
            _loc4_++;
         }
         return _loc3_;
      }
   }
}

