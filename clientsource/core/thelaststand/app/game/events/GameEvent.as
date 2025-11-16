package thelaststand.app.game.events
{
   import flash.events.Event;
   
   public class GameEvent extends Event
   {
      
      public static const APP_INACTIVE:String = "appInactive";
      
      public static const CONSTRUCTION_START:String = "gameConstructionStart";
      
      public static const ZOMBIE_ATTACK_PREPARATION:String = "gameZombieAttackPrep";
      
      public static const ZOMBIE_ATTACK_ENGAGE:String = "gameZombieAttackEngage";
      
      public static const GOTO_LOADING_SCREEN:String = "gameLoadingScreen";
      
      public static const CENTER_ON_ENTITY:String = "centerOnEntity";
      
      private var _data:*;
      
      public function GameEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:* = null)
      {
         super(param1,param2,param3);
         this._data = param4;
      }
      
      public function get data() : *
      {
         return this._data;
      }
   }
}

