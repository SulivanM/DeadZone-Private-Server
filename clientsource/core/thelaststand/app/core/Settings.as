package thelaststand.app.core
{
   import com.exileetiquette.net.PersistentData;
   import flash.display.StageQuality;
   import org.osflash.signals.Signal;
   import thelaststand.common.lang.Language;
   
   public class Settings extends PersistentData
   {
      
      private static var _instance:Settings;
      
      private static const SHARED_OBJECT_NAME:String = "thelaststand-settings";
      
      public static const ANTIALIAS_OFF:int = 0;
      
      public static const ANTIALIAS_X2:int = 1;
      
      public static const ANTIALIAS_X4:int = 2;
      
      public static const ANTIALIAS_X8:int = 3;
      
      public static const SHADOWS_OFF:int = 0;
      
      public static const SHADOWS_LOW:int = 1;
      
      public static const SHADOWS_HIGH:int = 2;
      
      public static const FLASH_QUALITY_LOW:int = 0;
      
      public static const FLASH_QUALITY_MED:int = 1;
      
      public static const FLASH_QUALITY_HIGH:int = 2;
      
      public static const FLASH_QUALITY_BEST:int = 3;
      
      private var _alliancesEnabled:Boolean = true;
      
      public var session_dontAskInventoryNearCapacity:Boolean;
      
      public var session_dontAskInventoryFull:Boolean;
      
      public var session_dontAskDefenceEquipped:Boolean;
      
      public var effectTimersEnabled:Boolean = true;
      
      public var earnFuelEnabled:Boolean = true;
      
      public var storeEnabled:Boolean = true;
      
      public var zombieAttacks:Boolean = true;
      
      public var chatEnabled:Boolean = true;
      
      public var payvaultURL:String = "this should be set";
      
      public var tradeEnabled:Boolean = true;
      
      public var broadcastEnabled:Boolean = true;
      
      public var globalQuestsEnabled:Boolean = true;
      
      public var offersEnabled:Boolean = true;
      
      public var bountyEnabled:Boolean = true;
      
      public var craftingEnabled:Boolean = true;
      
      public var itemUpgradingEnabled:Boolean = true;
      
      public var settingChanged:Signal;
      
      public function Settings(param1:SettingsSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("Settings is a Singleton and cannot be directly instantiated. Use Settings.getInstance().");
         }
         sharedObjectName = SHARED_OBJECT_NAME;
         this.settingChanged = new Signal(String,Object);
         var _loc2_:Object = getData("antiAlias",ANTIALIAS_OFF);
         if(_loc2_ is String)
         {
            switch(_loc2_)
            {
               case "off":
                  setData("antiAlias",ANTIALIAS_OFF);
                  break;
               case "low":
                  setData("antiAlias",ANTIALIAS_X2);
                  break;
               case "high":
                  setData("antiAlias",ANTIALIAS_X4);
            }
         }
         var _loc3_:Object = getData("shadows",ANTIALIAS_OFF);
         if(_loc3_ is String)
         {
            switch(_loc3_)
            {
               case "off":
                  setData("shadows",SHADOWS_OFF);
                  break;
               case "low":
                  setData("shadows",SHADOWS_LOW);
                  break;
               case "high":
                  setData("shadows",SHADOWS_HIGH);
            }
         }
         if(!isSet("flash"))
         {
            setData("flash",FLASH_QUALITY_HIGH);
         }
         this.updateStageQuality();
      }
      
      public static function getInstance() : Settings
      {
         if(!_instance)
         {
            _instance = new Settings(new SettingsSingletonEnforcer());
         }
         return _instance;
      }
      
      public function resetWarnings() : void
      {
         this.session_dontAskInventoryNearCapacity = false;
         this.session_dontAskInventoryFull = false;
         this.session_dontAskDefenceEquipped = false;
      }
      
      private function updateStageQuality() : void
      {
         switch(getData("flash",FLASH_QUALITY_HIGH))
         {
            case FLASH_QUALITY_LOW:
               Global.stage.quality = StageQuality.LOW;
               break;
            case FLASH_QUALITY_MED:
               Global.stage.quality = StageQuality.MEDIUM;
               break;
            case FLASH_QUALITY_HIGH:
               Global.stage.quality = StageQuality.HIGH;
               break;
            case FLASH_QUALITY_BEST:
               Global.stage.quality = StageQuality.BEST;
         }
      }
      
      public function get antiAlias() : int
      {
         return getData("antiAlias",ANTIALIAS_OFF);
      }
      
      public function set antiAlias(param1:int) : void
      {
         setData("antiAlias",param1);
         this.settingChanged.dispatch("antiAlias",param1);
      }
      
      public function get shadows() : int
      {
         return getData("shadows",SHADOWS_OFF);
      }
      
      public function set shadows(param1:int) : void
      {
         setData("shadows",param1);
         this.settingChanged.dispatch("shadows",param1);
      }
      
      public function get flashQuality() : int
      {
         return getData("flash",FLASH_QUALITY_HIGH);
      }
      
      public function set flashQuality(param1:int) : void
      {
         setData("flash",param1);
         this.updateStageQuality();
         this.settingChanged.dispatch("flash",param1);
      }
      
      public function get dynamicLights() : Boolean
      {
         return getData("dynamicLights",false);
      }
      
      public function set dynamicLights(param1:Boolean) : void
      {
         setData("dynamicLights",param1);
         this.settingChanged.dispatch("dynamicLights",param1);
      }
      
      public function get staticLights() : Boolean
      {
         return getData("staticLights",true);
      }
      
      public function set staticLights(param1:Boolean) : void
      {
         setData("staticLights",param1);
         this.settingChanged.dispatch("staticLights",param1);
      }
      
      public function get sound3D() : Boolean
      {
         return getData("sound3D",true);
      }
      
      public function set sound3D(param1:Boolean) : void
      {
         setData("sound3D",param1);
         this.settingChanged.dispatch("sound3D",param1);
      }
      
      public function get cacheEnabled() : Boolean
      {
         return getData("cacheEnabled",true);
      }
      
      public function set cacheEnabled(param1:Boolean) : void
      {
         setData("cacheEnabled",param1);
         this.settingChanged.dispatch("cacheEnabled",param1);
      }
      
      public function get gore() : Boolean
      {
         return getData("gore",true);
      }
      
      public function set gore(param1:Boolean) : void
      {
         setData("gore",param1);
         this.settingChanged.dispatch("gore",param1);
      }
      
      public function get bulletTracers() : Boolean
      {
         return getData("tracers",true);
      }
      
      public function set bulletTracers(param1:Boolean) : void
      {
         setData("tracers",param1);
         this.settingChanged.dispatch("tracers",param1);
      }
      
      public function get clothingPreview() : Boolean
      {
         return getData("clothingPreview",true);
      }
      
      public function set clothingPreview(param1:Boolean) : void
      {
         setData("clothingPreview",param1);
         this.settingChanged.dispatch("clothingPreview",param1);
      }
      
      public function get language() : String
      {
         return getData("lang",Language.getInstance().defaultLanguage);
      }
      
      public function set language(param1:String) : void
      {
         setData("lang",param1);
         this.settingChanged.dispatch("lang",param1);
      }
      
      public function get autoShowNews() : Boolean
      {
         return getData("autoNews",true);
      }
      
      public function set autoShowNews(param1:Boolean) : void
      {
         setData("autoNews",param1);
         this.settingChanged.dispatch("autoNews",param1);
      }
      
      public function get voices() : Boolean
      {
         return getData("voices",true);
      }
      
      public function set voices(param1:Boolean) : void
      {
         setData("voices",param1);
         this.settingChanged.dispatch("voices",param1);
      }
      
      public function get alliancesEnabled() : Boolean
      {
         return this._alliancesEnabled;
      }
      
      public function set alliancesEnabled(param1:Boolean) : void
      {
         var _loc2_:Boolean = this._alliancesEnabled;
         this._alliancesEnabled = param1;
         if(this._alliancesEnabled != _loc2_)
         {
            this.settingChanged.dispatch("alliancesEnabled",param1);
         }
      }
   }
}

class SettingsSingletonEnforcer
{
   
   public function SettingsSingletonEnforcer()
   {
      super();
   }
}
