package thelaststand.app.game.data.research
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.junkbyte.console.Cc;
   import thelaststand.app.game.gui.research.ResearchDialogue;
   import thelaststand.app.game.logic.DialogueController;
   import thelaststand.app.gui.dialogues.BusyDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class ResearchSystem
   {
      
      private static var _instance:ResearchSystem;
      
      private var _initialized:Boolean;
      
      public function ResearchSystem(param1:ResearchSystemSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("ResearchSystem is a Singleton and cannot be directly instantiated. Use ResearchSystem.getInstance().");
         }
      }
      
      public static function getInstance() : ResearchSystem
      {
         if(!_instance)
         {
            _instance = new ResearchSystem(new ResearchSystemSingletonEnforcer());
         }
         return _instance;
      }
      
      public static function getCategoryXML(param1:String) : XML
      {
         var xml:XML = null;
         var nodes:XMLList = null;
         var category:String = param1;
         xml = XML(ResourceManager.getInstance().get("xml/research.xml"));
         nodes = xml.research.(@id == category);
         return nodes.length() > 0 ? nodes[0] : null;
      }
      
      public static function getCategoryGroupXML(param1:String, param2:String) : XML
      {
         var nodes:XMLList;
         var xmlCategory:XML = null;
         var category:String = param1;
         var group:String = param2;
         xmlCategory = getCategoryXML(category);
         if(xmlCategory == null)
         {
            return null;
         }
         nodes = xmlCategory.group.(@id == group);
         return nodes.length() > 0 ? nodes[0] : null;
      }
      
      public static function getCategoryGroupLevelXML(param1:String, param2:String, param3:int) : XML
      {
         var nodes:XMLList;
         var xmlGroup:XML = null;
         var category:String = param1;
         var group:String = param2;
         var level:int = param3;
         xmlGroup = getCategoryGroupXML(category,group);
         if(xmlGroup == null)
         {
            return null;
         }
         nodes = xmlGroup.level.(@n == level.toString());
         return nodes.length() > 0 ? nodes[0] : null;
      }
      
      public static function getCategoryName(param1:String) : String
      {
         return Language.getInstance().getString("research_categories." + param1 + ".name");
      }
      
      public static function getCategoryGroupName(param1:String, param2:String, param3:int = -1) : String
      {
         var _loc4_:String = Language.getInstance().getString("research_categories." + param1 + ".groups." + param2 + "_name");
         if(param3 > -1)
         {
            _loc4_ += " - " + Language.getInstance().getString("lvl",param3 + 1);
         }
         return _loc4_;
      }
      
      public static function getCategoryGroupDescription(param1:String, param2:String) : String
      {
         return Language.getInstance().getString("research_categories." + param1 + ".groups." + param2 + "_desc");
      }
      
      public static function getCategoryGroupEffectDescription(param1:String, param2:String, param3:int) : String
      {
         var _loc4_:XML = getCategoryGroupLevelXML(param1,param2,param3);
         var _loc5_:Number = Number(_loc4_.value.toString()) * 100;
         var _loc6_:String = (_loc5_ < 0 ? "-" : "+") + NumberFormatter.format(Math.abs(_loc5_),2);
         return Language.getInstance().getString("research_categories." + param1 + ".groups." + param2 + "_effect",_loc6_);
      }
      
      public static function getMaxLevel(param1:String, param2:String) : int
      {
         var _loc5_:XML = null;
         var _loc6_:int = 0;
         var _loc3_:XML = getCategoryGroupXML(param1,param2);
         if(_loc3_ == null)
         {
            return -1;
         }
         var _loc4_:int = -1;
         for each(_loc5_ in _loc3_.level)
         {
            _loc6_ = int(_loc5_.@n);
            if(_loc6_ > _loc4_)
            {
               _loc4_ = _loc6_;
            }
         }
         return _loc4_;
      }
      
      public static function calculateFuelCost(param1:String, param2:String, param3:int) : int
      {
         var _loc4_:Object = Network.getInstance().data.costTable.getItemByKey("ResearchTask");
         return Math.max((param3 + 1) * int(_loc4_.costPerLevel),1);
      }
      
      public function init() : void
      {
         if(this._initialized)
         {
            return;
         }
         this._initialized = true;
         this.setupConsoleCommands();
      }
      
      public function startResearch(param1:String, param2:String, param3:Function = null) : void
      {
         var msgBusy:BusyDialogue = null;
         var category:String = param1;
         var group:String = param2;
         var onComplete:Function = param3;
         msgBusy = new BusyDialogue(Language.getInstance().getString("research_starting"));
         msgBusy.open();
         Network.getInstance().save({
            "category":category,
            "group":group
         },SaveDataMethod.RESEARCH_START,function(param1:Object):void
         {
            msgBusy.close();
            if(param1 == null || param1.success !== true)
            {
               if(param1.error == "notenoughfuel")
               {
                  PaymentSystem.getInstance().openBuyCoinsScreen(true);
               }
               else
               {
                  DialogueController.getInstance().showGenericRequestError();
               }
               if(onComplete != null)
               {
                  onComplete(false,null);
               }
               return;
            }
            var _loc2_:ResearchTask = onResearchStarted(param1);
            if(onComplete != null)
            {
               onComplete(param1.success,_loc2_);
            }
         });
      }
      
      public function completeResearchTasks(param1:Object) : void
      {
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:ResearchTask = null;
         if(param1 == null)
         {
            return;
         }
         var _loc2_:ResearchState = Network.getInstance().playerData.researchState;
         var _loc3_:Array = param1.ids as Array;
         if(_loc3_ != null)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               _loc5_ = _loc3_[_loc4_];
               _loc6_ = Network.getInstance().playerData.researchState.getTaskById(_loc5_);
               if(_loc6_ != null)
               {
                  this.onResearchCompleted({
                     "success":true,
                     "id":_loc6_.id,
                     "category":_loc6_.category,
                     "group":_loc6_.group,
                     "level":_loc6_.level
                  });
               }
               _loc4_++;
            }
         }
         if(param1.effects != null)
         {
            _loc2_.parseEffects(param1.effects);
         }
      }
      
      private function setupConsoleCommands() : void
      {
         var args:Array = null;
         Cc.addSlashCommand("research",function():void
         {
            var _loc1_:ResearchDialogue = new ResearchDialogue();
            _loc1_.open();
         },"Open the research window");
         Cc.addSlashCommand("researchstart",function(param1:String = ""):void
         {
            args = param1.split(/\s+/);
            if(args.length < 2)
            {
               return;
            }
            var _loc2_:String = String(args[0]);
            var _loc3_:String = String(args[1]);
            var _loc4_:Boolean = args.length > 2 ? Boolean(int(args[2])) : false;
            Network.getInstance().save({
               "category":_loc2_,
               "group":_loc3_,
               "ignorereqs":_loc4_
            },"researchstart",onResearchStarted);
         },"category group [ignorereqs(0|1)]");
         Cc.addSlashCommand("researchcomp",function(param1:String = ""):void
         {
            args = param1.split(/\s+/);
            var _loc2_:Object = {};
            if(args.length == 1)
            {
               _loc2_.id = String(args[0]);
            }
            else if(args.length > 1)
            {
               _loc2_.category = String(args[0]);
               _loc2_.group = String(args[1]);
            }
            Network.getInstance().save(_loc2_,"researchcomp",onResearchCompleted);
         },"[id|(category group)]");
         Cc.addSlashCommand("researchtime",function(param1:String = ""):void
         {
            var params:String = param1;
            args = params.split(/\s+/);
            var data:Object = {};
            if(args.length == 1)
            {
               data.id = String(args[0]);
            }
            else if(args.length > 1)
            {
               data.category = String(args[0]);
               data.group = String(args[1]);
            }
            Network.getInstance().save(data,"researchtime",function(param1:Object):void
            {
               if(param1 == null)
               {
                  return;
               }
            });
         },"[id|(category group)]");
         Cc.addSlashCommand("researchlevel",function(param1:String = ""):void
         {
            args = param1.split(/\s+/);
            if(args.length < 3)
            {
               return;
            }
            var _loc2_:String = String(args[0]);
            var _loc3_:String = String(args[1]);
            var _loc4_:int = int(args[2]);
            Network.getInstance().save({
               "category":_loc2_,
               "group":_loc3_,
               "level":_loc4_
            },"researchlevel",onResearchLevelSet);
         },"category group level");
      }
      
      private function onResearchStarted(param1:Object) : ResearchTask
      {
         if(param1 == null || param1.success !== true)
         {
            return null;
         }
         if(param1.change != null)
         {
            Network.getInstance().playerData.inventory.updateQuantities(param1.change);
         }
         var _loc2_:ResearchTask = new ResearchTask();
         _loc2_.parse(param1.task);
         var _loc3_:ResearchState = Network.getInstance().playerData.researchState;
         _loc3_.addTask(_loc2_);
         _loc3_.researchStarted.dispatch(_loc2_);
         return _loc2_;
      }
      
      private function onResearchCompleted(param1:Object) : ResearchTask
      {
         if(param1 == null || param1.success !== true)
         {
            return null;
         }
         var _loc2_:String = String(param1["id"]);
         var _loc3_:String = String(param1["category"]);
         var _loc4_:String = String(param1["group"]);
         var _loc5_:int = int(param1["level"]);
         var _loc6_:Object = param1["effects"];
         var _loc7_:ResearchState = Network.getInstance().playerData.researchState;
         _loc7_.setLevel(_loc3_,_loc4_,_loc5_);
         var _loc8_:ResearchTask = _loc7_.removeTaskById(_loc2_);
         if(_loc6_ != null)
         {
            _loc7_.parseEffects(_loc6_);
         }
         if(_loc8_ != null)
         {
            _loc7_.researchCompleted.dispatch(_loc8_);
         }
         return _loc8_;
      }
      
      private function onResearchLevelSet(param1:Object) : void
      {
         if(param1 == null || param1.success !== true)
         {
            return;
         }
         var _loc2_:String = String(param1["category"]);
         var _loc3_:String = String(param1["group"]);
         var _loc4_:int = int(param1["level"]);
         var _loc5_:Object = param1["effects"];
         var _loc6_:ResearchState = Network.getInstance().playerData.researchState;
         _loc6_.setLevel(_loc2_,_loc3_,_loc4_);
         _loc6_.removeTaskByType(_loc2_,_loc3_,_loc4_);
         _loc6_.parseEffects(_loc5_);
      }
   }
}

class ResearchSystemSingletonEnforcer
{
   
   public function ResearchSystemSingletonEnforcer()
   {
      super();
   }
}
