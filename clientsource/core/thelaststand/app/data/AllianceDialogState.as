package thelaststand.app.data
{
   public class AllianceDialogState
   {
      
      private static var _instance:AllianceDialogState;
      
      public static const SHOW_NONE:int = 0;
      
      public static const SHOW_ALLIANCE_DIALOG:int = 1;
      
      public static const SHOW_INDIVIDUALS:int = 2;
      
      public static const SHOW_TOP_100:int = 3;
      
      public var viewingFromWars:Boolean = false;
      
      public var allianceDialogReturnType:int = 0;
      
      public var allianceId:String = "";
      
      public var allianceName:String = "";
      
      public var allianceTag:String = "";
      
      public var alliancePage:int = 0;
      
      public var playerPage:int = 0;
      
      public var sortProperty:String = "";
      
      public var sortDirection:int = -1;
      
      public function AllianceDialogState(param1:AllianceDialogStateEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("AllianceDialogState is a Singleton and cannot be directly instantiated. Use AllianceDialogState.getInstance().");
         }
      }
      
      public static function getInstance() : AllianceDialogState
      {
         if(!_instance)
         {
            _instance = new AllianceDialogState(new AllianceDialogStateEnforcer());
         }
         return _instance;
      }
   }
}

class AllianceDialogStateEnforcer
{
   
   public function AllianceDialogStateEnforcer()
   {
      super();
   }
}
