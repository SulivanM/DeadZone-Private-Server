package thelaststand.app.core
{
   import com.junkbyte.console.Cc;
   import com.junkbyte.console.addons.autoFocus.CommandLineAutoFocusAddon;
   import flash.display.Stage;
   import flash.display3D.Context3D;
   import flash.system.Capabilities;
   import thelaststand.app.game.Game;
   import thelaststand.app.game.data.assignment.AssignmentData;
   import thelaststand.app.network.PlayerIOConnector;
   
   public class Global
   {
      
      public static var parameters:Object;
      
      public static var stage:Stage;
      
      public static var document:Main;
      
      public static var mouseInApp:Boolean;
      
      public static var active:Boolean;
      
      public static var throttled:Boolean;
      
      public static var softwareRendering:Boolean;
      
      public static var context:Context3D;
      
      public static var completedAssignment:AssignmentData;
      
      public static const DOCUMENT_WIDTH:uint = 960;
      
      public static const DOCUMENT_HEIGHT:uint = 580;
      
      public static const DOCUMENT_CENTRE_X:uint = DOCUMENT_WIDTH * 0.5;
      
      public static const DOCUMENT_CENTRE_Y:uint = DOCUMENT_HEIGHT * 0.5;
      
      public static var lowFPS:Boolean = false;
      
      public static var showInjuryTutorial:Boolean = false;
      
      public static var showSchematicTutorial:Boolean = false;
      
      public static var showEffectTutorial:Boolean = false;
      
      public static var activeMuzzleFlashCount:int = 0;
      
      public static var useSSL:Boolean = false;
      
      public static var game:Game = null;
      
      public function Global()
      {
         super();
         throw new Error("Global cannot be directly instantiated.");
      }
      
      public static function initConsole() : void
      {
         Cc.config.commandLineAllowed = true;
         Cc.startOnStage(stage,"=");
         Cc.fpsMonitor = true;
         Cc.memoryMonitor = true;
         Cc.commandLine = true;
         Cc.width = stage.stageWidth;
         Cc.height = int(stage.stageHeight * 0.33);
         CommandLineAutoFocusAddon.registerToConsole();
      }
      
      public static function getCapabilityData(param1:Object = null) : Object
      {
         var _loc3_:String = null;
         var _loc2_:Object = {
            "version":Capabilities.version,
            "os":Capabilities.os,
            "isDebugger":Capabilities.isDebugger,
            "playerType":Capabilities.playerType,
            "cpuArchitecture":Capabilities.cpuArchitecture,
            "screenResolution":Capabilities.screenResolutionX + "x" + Capabilities.screenResolutionY
         };
         if(param1 != null)
         {
            for(_loc3_ in param1)
            {
               _loc2_[_loc3_] = param1[_loc3_];
            }
         }
         return _loc2_;
      }
      
      public static function processResourceURI(param1:String) : String
      {
         if(param1.substr(0,1) != "/")
         {
            param1 = "/" + param1;
         }
         return PlayerIOConnector.getInstance().client.gameFS.getUrl(param1,useSSL);
      }
   }
}

