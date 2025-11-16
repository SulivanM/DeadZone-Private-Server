package thelaststand.app.game.logic.ai
{
   import flash.utils.Dictionary;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.scenes.BaseScene;
   import thelaststand.app.utils.DictionaryUtils;
   
   public class Blackboard
   {
      
      public var allAgents:Vector.<AIAgent>;
      
      public var enemies:Vector.<AIActorAgent>;
      
      public var friends:Vector.<AIActorAgent>;
      
      public var buildings:Vector.<Building>;
      
      public var traps:Vector.<Building>;
      
      public var scene:BaseScene;
      
      public var lastKnownAgentPos:Dictionary;
      
      public var visibleAgents:Dictionary;
      
      public var visibleAgentTimes:Dictionary;
      
      public var buildingThreatLevels:Dictionary;
      
      public var teamTargets:Dictionary;
      
      public function Blackboard()
      {
         super();
         this.visibleAgents = new Dictionary(true);
         this.visibleAgentTimes = new Dictionary(true);
         this.lastKnownAgentPos = new Dictionary(true);
         this.teamTargets = new Dictionary(true);
      }
      
      public function erase() : void
      {
         this.buildingThreatLevels = null;
         this.allAgents = null;
         this.enemies = null;
         this.friends = null;
         this.buildings = null;
         this.traps = null;
         this.scene = null;
         DictionaryUtils.clear(this.visibleAgents);
         DictionaryUtils.clear(this.visibleAgentTimes);
         DictionaryUtils.clear(this.lastKnownAgentPos);
         DictionaryUtils.clear(this.teamTargets);
      }
   }
}

