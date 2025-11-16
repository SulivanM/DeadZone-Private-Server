package thelaststand.app.game.gui
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import com.greensock.easing.Back;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.core.Config;
   import thelaststand.app.core.Settings;
   import thelaststand.app.core.Tracking;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.effects.EffectType;
   import thelaststand.app.game.gui.compound.UIEarnFuelDisplay;
   import thelaststand.app.game.gui.compound.UIResourceDisplay;
   import thelaststand.app.game.gui.dialogues.StoreDialogue;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.network.*;
   import thelaststand.common.lang.Language;
   
   public class UIResourceListPanel extends Sprite
   {
      
      private var _lang:Language;
      
      private var _network:Network;
      
      private var res_wood:UIResourceDisplay;
      
      private var res_metal:UIResourceDisplay;
      
      private var res_cloth:UIResourceDisplay;
      
      private var res_food:UIResourceDisplay;
      
      private var res_water:UIResourceDisplay;
      
      private var res_ammunition:UIResourceDisplay;
      
      private var ui_earnFuel:UIEarnFuelDisplay;
      
      private var _gui:GameGUI;
      
      private var _transitionedIn:Boolean = false;
      
      public function UIResourceListPanel()
      {
         var allowedEarnFuel:Boolean;
         var earnFuelNode:XML;
         var earnFuelServices:String;
         var tooltip:TooltipManager;
         super();
         this._lang = Language.getInstance();
         this._network = Network.getInstance();
         this.res_wood = new UIResourceDisplay(new BmpIconWood(),GameResources.RESOURCE_COLORS[GameResources.WOOD]);
         this.res_wood.clicked.add(this.onClickAddResource);
         addChild(this.res_wood);
         this.res_metal = new UIResourceDisplay(new BmpIconMetal(),GameResources.RESOURCE_COLORS[GameResources.METAL]);
         this.res_metal.clicked.add(this.onClickAddResource);
         this.res_metal.y = int(this.res_wood.y + this.res_wood.height + 5);
         addChild(this.res_metal);
         this.res_cloth = new UIResourceDisplay(new BmpIconCloth(),GameResources.RESOURCE_COLORS[GameResources.CLOTH]);
         this.res_cloth.clicked.add(this.onClickAddResource);
         this.res_cloth.y = int(this.res_metal.y + this.res_metal.height + 5);
         addChild(this.res_cloth);
         this.res_food = new UIResourceDisplay(new BmpIconFood(),GameResources.RESOURCE_COLORS[GameResources.FOOD],true,new Point(0,-3));
         this.res_food.clicked.add(this.onClickAddResource);
         this.res_food.y = int(this.res_cloth.y + this.res_cloth.height + 18);
         this.res_food.warningLevel = -1;
         addChild(this.res_food);
         this.res_water = new UIResourceDisplay(new BmpIconWater(),GameResources.RESOURCE_COLORS[GameResources.WATER],true,new Point(0,-3));
         this.res_water.clicked.add(this.onClickAddResource);
         this.res_water.y = int(this.res_food.y + this.res_food.height + 5);
         this.res_water.warningLevel = -1;
         addChild(this.res_water);
         this.res_ammunition = new UIResourceDisplay(new BmpIconAmmunition(),GameResources.RESOURCE_COLORS[GameResources.AMMUNITION]);
         this.res_ammunition.clicked.add(this.onClickAddResource);
         this.res_ammunition.y = int(this.res_water.y + this.res_water.height + 18);
         addChild(this.res_ammunition);
         this.ui_earnFuel = new UIEarnFuelDisplay();
         this.ui_earnFuel.clicked.add(this.onClickEarnFuel);
         this.ui_earnFuel.y = int(this.res_ammunition.y + this.res_ammunition.height + 26);
         allowedEarnFuel = false;
         earnFuelNode = Config.xml.earn_fuel[0];
         earnFuelServices = earnFuelNode.@services.toString().split(",");
         if(earnFuelServices.indexOf(Network.getInstance().service) > -1 && (earnFuelNode.hasOwnProperty("@all") && earnFuelNode.@all.toString() == "1" || earnFuelNode.locale.(toString() == Network.getInstance().playerData.user.locale).length() > 0))
         {
            allowedEarnFuel = true;
         }
         if(Settings.getInstance().earnFuelEnabled && allowedEarnFuel)
         {
            addChild(this.ui_earnFuel);
         }
         this.updateAllResources();
         tooltip = TooltipManager.getInstance();
         tooltip.add(this.res_wood,this.getWoodTooltip,new Point(this.res_wood.width + 4,this.res_wood.height * 0.5),TooltipDirection.DIRECTION_LEFT,0.1);
         tooltip.add(this.res_metal,this.getMetalTooltip,new Point(this.res_metal.width + 4,this.res_metal.height * 0.5),TooltipDirection.DIRECTION_LEFT,0.1);
         tooltip.add(this.res_cloth,this.getClothTooltip,new Point(this.res_cloth.width + 4,this.res_cloth.height * 0.5),TooltipDirection.DIRECTION_LEFT,0.1);
         tooltip.add(this.res_ammunition,this.getAmmoTooltip,new Point(this.res_ammunition.width + 4,this.res_ammunition.height * 0.5),TooltipDirection.DIRECTION_LEFT,0.1);
         tooltip.add(this.res_food,this.getFoodTooltip,new Point(this.res_food.width + 4,this.res_food.height * 0.5),TooltipDirection.DIRECTION_LEFT,0.1);
         tooltip.add(this.res_water,this.getWaterTooltip,new Point(this.res_water.width + 4,this.res_water.height * 0.5),TooltipDirection.DIRECTION_LEFT,0.1);
         tooltip.add(this.ui_earnFuel,this._lang.getString("tooltip.earn_fuel"),new Point(this.ui_earnFuel.width + 4,this.ui_earnFuel.height * 0.5),TooltipDirection.DIRECTION_LEFT,0.1);
         this._network.playerData.compound.resources.resourceChanged.add(this.onResourceChanged);
         this._network.playerData.compound.resources.storageCapacityChanged.add(this.onResourceCapacityChanged);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.ui_earnFuel.dispose();
         this.ui_earnFuel = null;
         this._network.playerData.compound.resources.resourceChanged.remove(this.onResourceChanged);
         this._network.playerData.compound.resources.storageCapacityChanged.remove(this.onResourceCapacityChanged);
         this._lang = null;
         this._network = null;
      }
      
      public function transitionIn(param1:Number = 0) : void
      {
         var easeFunction:Function;
         var easeParams:Array;
         var d:Number;
         var tx:int;
         var delay:Number = param1;
         if(this._transitionedIn)
         {
            return;
         }
         this._transitionedIn = true;
         easeFunction = Back.easeOut;
         easeParams = [0.75];
         this.res_wood.x = this.res_metal.x = this.res_cloth.x = this.res_food.x = this.res_water.x = this.res_ammunition.x = this.ui_earnFuel.x = 0;
         d = delay;
         tx = -(this.res_water.width + 60);
         TweenMax.from(this.res_wood,0.25,{
            "delay":delay = delay + d,
            "x":tx,
            "ease":easeFunction,
            "easeParams":easeParams,
            "onStart":function():void
            {
               visible = true;
            }
         });
         TweenMax.from(this.res_metal,0.25,{
            "delay":delay = delay + d,
            "x":tx,
            "ease":easeFunction,
            "easeParams":easeParams
         });
         TweenMax.from(this.res_cloth,0.25,{
            "delay":delay = delay + d,
            "x":tx,
            "ease":easeFunction,
            "easeParams":easeParams
         });
         TweenMax.from(this.res_food,0.25,{
            "delay":delay = delay + d,
            "x":tx,
            "ease":easeFunction,
            "easeParams":easeParams
         });
         TweenMax.from(this.res_water,0.25,{
            "delay":delay = delay + d,
            "x":tx,
            "ease":easeFunction,
            "easeParams":easeParams
         });
         TweenMax.from(this.res_ammunition,0.25,{
            "delay":delay = delay + d,
            "x":tx,
            "ease":easeFunction,
            "easeParams":easeParams
         });
         if(this.ui_earnFuel.parent != null)
         {
            TweenMax.from(this.ui_earnFuel,0.25,{
               "delay":delay = delay + d,
               "x":tx,
               "ease":easeFunction,
               "easeParams":easeParams
            });
         }
         Audio.sound.play("sound/interface/int-open.mp3");
      }
      
      public function transitionOut(param1:Number = 0) : void
      {
         if(this._transitionedIn == false)
         {
            return;
         }
         this._transitionedIn = false;
         var _loc2_:Function = Back.easeIn;
         var _loc3_:Array = [0.75];
         var _loc4_:Number = 0.05;
         var _loc5_:int = -(this.res_water.width + 60);
         TweenMax.to(this.res_ammunition,0.25,{
            "delay":param1 = param1 + _loc4_,
            "x":_loc5_,
            "ease":_loc2_,
            "easeParams":_loc3_
         });
         if(this.ui_earnFuel.parent != null)
         {
            TweenMax.to(this.ui_earnFuel,0.25,{
               "delay":param1 = param1 + _loc4_,
               "x":_loc5_,
               "ease":_loc2_,
               "easeParams":_loc3_
            });
         }
         TweenMax.to(this.res_water,0.25,{
            "delay":param1 = param1 + _loc4_,
            "x":_loc5_,
            "ease":_loc2_,
            "easeParams":_loc3_
         });
         TweenMax.to(this.res_food,0.25,{
            "delay":param1 = param1 + _loc4_,
            "x":_loc5_,
            "ease":_loc2_,
            "easeParams":_loc3_
         });
         TweenMax.to(this.res_cloth,0.25,{
            "delay":param1 = param1 + _loc4_,
            "x":_loc5_,
            "ease":_loc2_,
            "easeParams":_loc3_
         });
         TweenMax.to(this.res_metal,0.25,{
            "delay":param1 = param1 + _loc4_,
            "x":_loc5_,
            "ease":_loc2_,
            "easeParams":_loc3_
         });
         TweenMax.to(this.res_wood,0.25,{
            "delay":param1 = param1 + _loc4_,
            "x":_loc5_,
            "ease":_loc2_,
            "easeParams":_loc3_
         });
      }
      
      private function updateAllResources() : void
      {
         var _loc2_:String = null;
         var _loc1_:GameResources = Network.getInstance().playerData.compound.resources;
         for each(_loc2_ in GameResources.getResourceList())
         {
            if(_loc2_ != GameResources.CASH)
            {
               this.updateResourceDisplay(_loc2_);
            }
         }
      }
      
      private function updateResourceDisplay(param1:String) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc2_:UIResourceDisplay = this["res_" + param1] as UIResourceDisplay;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Number = Math.floor(this._network.playerData.compound.resources.getAmount(param1));
         var _loc4_:Number = this._network.playerData.compound.resources.getTotalStorageCapacity(param1);
         _loc2_.maxValue = _loc4_;
         _loc2_.value = _loc3_;
         if(param1 == GameResources.FOOD || param1 == GameResources.WATER)
         {
            _loc5_ = this._network.playerData.compound.resources.getResourceDaysRemaining(param1);
            _loc6_ = this._network.playerData.compound.resources.getResourceDaysRequired(param1);
            _loc2_.label = _loc5_ == Number.POSITIVE_INFINITY ? this._lang.getString("infinity") : this._lang.getString(_loc5_ == 1 ? "num_day" : "num_days",_loc5_);
            _loc2_.labelColor = _loc5_ < _loc6_ ? int(Effects.COLOR_WARNING) : 16777215;
         }
      }
      
      private function getWoodTooltip() : String
      {
         var _loc1_:Number = Math.floor(this._network.playerData.compound.resources.getAmount(GameResources.WOOD));
         var _loc2_:int = Math.floor(this._network.playerData.compound.resources.getTotalStorageCapacity(GameResources.WOOD));
         var _loc3_:String = NumberFormatter.format(_loc1_,0);
         var _loc4_:String = NumberFormatter.format(_loc2_,0);
         var _loc5_:String = NumberFormatter.format(Number(this._network.playerData.compound.resources.getTotalProductionRate(GameResources.WOOD).toFixed(2)),2,",",false);
         return this._lang.getString("tooltip.res_wood",_loc3_,_loc4_,_loc5_);
      }
      
      private function getMetalTooltip() : String
      {
         var _loc1_:Number = Math.floor(this._network.playerData.compound.resources.getAmount(GameResources.METAL));
         var _loc2_:int = Math.floor(this._network.playerData.compound.resources.getTotalStorageCapacity(GameResources.METAL));
         var _loc3_:String = NumberFormatter.format(_loc1_,0);
         var _loc4_:String = NumberFormatter.format(_loc2_,0);
         var _loc5_:String = NumberFormatter.format(Number(this._network.playerData.compound.resources.getTotalProductionRate(GameResources.METAL).toFixed(2)),2,",",false);
         return this._lang.getString("tooltip.res_metal",_loc3_,_loc4_,_loc5_);
      }
      
      private function getClothTooltip() : String
      {
         var _loc1_:Number = Math.floor(this._network.playerData.compound.resources.getAmount(GameResources.CLOTH));
         var _loc2_:int = Math.floor(this._network.playerData.compound.resources.getTotalStorageCapacity(GameResources.CLOTH));
         var _loc3_:String = NumberFormatter.format(_loc1_,0);
         var _loc4_:String = NumberFormatter.format(_loc2_,0);
         var _loc5_:String = NumberFormatter.format(Number(this._network.playerData.compound.resources.getTotalProductionRate(GameResources.CLOTH).toFixed(2)),2,",",false);
         return this._lang.getString("tooltip.res_cloth",_loc3_,_loc4_,_loc5_);
      }
      
      private function getAmmoTooltip() : String
      {
         var _loc1_:Number = Math.floor(this._network.playerData.compound.resources.getAmount(GameResources.AMMUNITION));
         var _loc2_:int = Math.floor(this._network.playerData.compound.resources.getTotalStorageCapacity(GameResources.AMMUNITION));
         var _loc3_:String = NumberFormatter.format(_loc1_,0);
         var _loc4_:String = NumberFormatter.format(_loc2_,0);
         var _loc5_:String = NumberFormatter.format(Number(this._network.playerData.compound.resources.getTotalProductionRate(GameResources.AMMUNITION).toFixed(2)),2,",",false);
         return this._lang.getString("tooltip.res_ammunition",_loc3_,_loc4_,_loc5_);
      }
      
      private function getFoodTooltip() : String
      {
         var _loc1_:Number = Math.floor(this._network.playerData.compound.resources.getAmount(GameResources.FOOD));
         var _loc2_:int = Math.floor(this._network.playerData.compound.resources.getTotalStorageCapacity(GameResources.FOOD));
         var _loc3_:String = NumberFormatter.format(_loc1_,0);
         var _loc4_:String = NumberFormatter.format(_loc2_,0);
         var _loc5_:String = NumberFormatter.format(Number(this._network.playerData.compound.resources.getTotalProductionRate(GameResources.FOOD).toFixed(2)),2,",",false);
         var _loc6_:int = int(Config.constant.SURVIVOR_ADULT_FOOD_CONSUMPTION);
         var _loc7_:int = 60 * 60 * 24;
         var _loc8_:int = this._network.playerData.compound.survivors.length;
         var _loc9_:Number = _loc8_ * (_loc7_ / _loc6_);
         _loc9_ += _loc9_ * (this._network.playerData.compound.getEffectValue(EffectType.getTypeValue("FoodConsumption")) / 100);
         var _loc10_:String = NumberFormatter.format(_loc9_,0);
         return this._lang.getString("tooltip.res_food",_loc3_,_loc4_,_loc5_,_loc10_);
      }
      
      private function getWaterTooltip() : String
      {
         var _loc1_:Number = Math.floor(this._network.playerData.compound.resources.getAmount(GameResources.WATER));
         var _loc2_:int = Math.floor(this._network.playerData.compound.resources.getTotalStorageCapacity(GameResources.WATER));
         var _loc3_:String = NumberFormatter.format(_loc1_,0);
         var _loc4_:String = NumberFormatter.format(_loc2_,0);
         var _loc5_:String = NumberFormatter.format(Number(this._network.playerData.compound.resources.getTotalProductionRate(GameResources.WATER).toFixed(2)),2,",",false);
         var _loc6_:int = int(Config.constant.SURVIVOR_ADULT_WATER_CONSUMPTION);
         var _loc7_:int = 60 * 60 * 24;
         var _loc8_:int = this._network.playerData.compound.survivors.length;
         var _loc9_:Number = _loc8_ * (_loc7_ / _loc6_);
         _loc9_ += _loc9_ * (this._network.playerData.compound.getEffectValue(EffectType.getTypeValue("WaterConsumption")) / 100);
         var _loc10_:String = NumberFormatter.format(_loc9_,0);
         return this._lang.getString("tooltip.res_water",_loc3_,_loc4_,_loc5_,_loc10_);
      }
      
      private function onResourceChanged(param1:String, param2:Number) : void
      {
         if(param1 == GameResources.CASH)
         {
            return;
         }
         var _loc3_:UIResourceDisplay = UIResourceDisplay(this["res_" + param1]);
         var _loc4_:Number = _loc3_.value;
         this.updateResourceDisplay(param1);
         var _loc5_:String = "";
         var _loc6_:int = Math.round(param2 - _loc4_);
         if(_loc6_ > 0)
         {
            _loc5_ = "+" + NumberFormatter.format(_loc6_,0) + " " + this._lang.getString("items." + param1).toUpperCase();
            if(_loc3_.value >= _loc3_.maxValue)
            {
               _loc5_ += " (" + this._lang.getString("msg_storage_full") + ")";
            }
            if(this._gui != null)
            {
               this._gui.messageArea.addNotification(_loc5_,GameResources.RESOURCE_COLORS[param1]);
            }
         }
      }
      
      private function onResourceCapacityChanged(param1:String) : void
      {
         this.updateResourceDisplay(param1);
      }
      
      private function onClickAddResource(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:UIResourceDisplay = UIResourceDisplay(param1.currentTarget);
         switch(_loc3_)
         {
            case this.res_cloth:
               _loc2_ = GameResources.CLOTH;
               break;
            case this.res_metal:
               _loc2_ = GameResources.METAL;
               break;
            case this.res_wood:
               _loc2_ = GameResources.WOOD;
               break;
            case this.res_food:
               _loc2_ = GameResources.FOOD;
               break;
            case this.res_water:
               _loc2_ = GameResources.WATER;
               break;
            case this.res_ammunition:
               _loc2_ = GameResources.AMMUNITION;
         }
         if(_loc2_ != null)
         {
            Tracking.trackEvent("Interface","BuyResource",_loc2_);
         }
         var _loc4_:StoreDialogue = new StoreDialogue("resource",_loc2_);
         _loc4_.open();
      }
      
      private function onClickEarnFuel(param1:MouseEvent) : void
      {
         PaymentSystem.getInstance().openEarnCoinsScreen();
      }
      
      public function get tutorialArrowTargetObject() : DisplayObject
      {
         return this.res_cloth;
      }
      
      public function get gui() : GameGUI
      {
         return this._gui;
      }
      
      public function set gui(param1:GameGUI) : void
      {
         this._gui = param1;
      }
   }
}

