package thelaststand.app.game.gui.dialogues
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.gui.UIMessageArrow;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.construction.ConstructionInfoOptions;
   import thelaststand.app.game.gui.construction.UIConstructionInfo;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class ConstructionUpgradeDialogue extends BaseDialogue
   {
      
      private const IMAGE_STROKE:GlowFilter;
      
      private const UPGRADE_IMAGE_COLOR:ColorMatrix;
      
      private var _building:Building;
      
      private var _lang:Language;
      
      private var _xml:XML;
      
      private var btn_build:PushButton;
      
      private var btn_buildNow:PurchasePushButton;
      
      private var bmp_locked:Bitmap;
      
      private var bmp_arrow:Bitmap;
      
      private var ui_info:UIConstructionInfo;
      
      private var mc_container:Sprite;
      
      private var mc_buymsg:UIMessageArrow;
      
      private var mc_imageCurrentLevel:UIImage;
      
      private var mc_imageNextLevel:UIImage;
      
      public function ConstructionUpgradeDialogue(param1:Building)
      {
         var currentLevelNode:XML;
         var nextLevelNode:XML = null;
         var imageHeight:int = 0;
         var building:Building = param1;
         this.IMAGE_STROKE = new GlowFilter(8224125,1,4,4,10,1);
         this.UPGRADE_IMAGE_COLOR = new ColorMatrix();
         this.UPGRADE_IMAGE_COLOR.colorize(0,0.5);
         this._building = building;
         this.mc_container = new Sprite();
         super("upgrade-dialogue",this.mc_container,true);
         _autoSize = false;
         _width = 410;
         _height = 440;
         _padding = 15;
         this._lang = Language.getInstance();
         this._xml = ResourceManager.getInstance().getResource("xml/buildings.xml").content;
         addTitle(this._lang.getString("construct_upgrade_title",this._building.getName(),this._building.level + 2),6398924);
         currentLevelNode = this._building.xml.lvl.(@n == String(_building.level))[0];
         nextLevelNode = this._building.xml.lvl.(@n == String(_building.level + 1))[0];
         this.ui_info = new UIConstructionInfo(ConstructionInfoOptions.ALL ^ ConstructionInfoOptions.BUILDING_NAME);
         this.ui_info.setBuilding(this._building.type,this._building.level + 1);
         this.ui_info.x = int(_width - _padding * 2 - this.ui_info.width);
         this.ui_info.y = 6;
         this.mc_container.addChild(this.ui_info);
         imageHeight = int((this.ui_info.height - 30) / 2);
         this.mc_imageNextLevel = new UIImage(80,imageHeight);
         this.mc_imageNextLevel.y = 8;
         this.mc_imageNextLevel.uri = nextLevelNode.hasOwnProperty("img") ? nextLevelNode.img.@uri.toString() : this._building.xml.img.@uri.toString();
         this.mc_imageNextLevel.filters = [this.IMAGE_STROKE];
         this.mc_imageNextLevel.bitmap.filters = [this.UPGRADE_IMAGE_COLOR.filter];
         this.mc_container.addChild(this.mc_imageNextLevel);
         this.bmp_locked = new Bitmap(new BmpUpgradeLocked());
         this.bmp_locked.x = int(this.mc_imageNextLevel.x + (this.mc_imageNextLevel.width - this.bmp_locked.width) * 0.5);
         this.bmp_locked.y = int(this.mc_imageNextLevel.y + (this.mc_imageNextLevel.height - this.bmp_locked.height) * 0.5);
         this.mc_container.addChild(this.bmp_locked);
         this.mc_imageCurrentLevel = new UIImage(80,imageHeight);
         this.mc_imageCurrentLevel.uri = currentLevelNode.hasOwnProperty("img") ? currentLevelNode.img.@uri.toString() : this._building.xml.img.@uri.toString();
         this.mc_imageCurrentLevel.y = int(this.ui_info.y + this.ui_info.height - this.mc_imageCurrentLevel.height - 2);
         this.mc_imageCurrentLevel.filters = [this.IMAGE_STROKE];
         this.mc_container.addChild(this.mc_imageCurrentLevel);
         this.bmp_arrow = new Bitmap(new BmpUpgradeArrow());
         this.bmp_arrow.x = int(this.mc_imageNextLevel.x + (this.mc_imageNextLevel.width - this.bmp_arrow.width) * 0.5);
         this.bmp_arrow.y = int(this.mc_imageNextLevel.y + (this.mc_imageCurrentLevel.y + this.mc_imageCurrentLevel.height - this.bmp_arrow.height) * 0.5) - 10;
         this.mc_container.addChild(this.bmp_arrow);
         this.btn_build = new PushButton(this._lang.getString("construct_upgrade_build"),new BmpIconButtonBuild(),16761856);
         this.btn_build.clicked.add(this.onBuildClicked);
         this.btn_build.enabled = false;
         this.btn_build.width = 100;
         this.btn_build.x = int(_width - this.btn_build.width - _padding * 2);
         this.btn_build.y = int(_height - this.btn_build.height - _padding * 2 - 10);
         this.mc_container.addChild(this.btn_build);
         this.btn_buildNow = new PurchasePushButton();
         this.btn_buildNow.clicked.add(this.onBuildClicked);
         this.btn_buildNow.label = this._lang.getString("construct_upgrade_buildnow");
         this.btn_buildNow.width = 150;
         this.btn_buildNow.x = int(this.btn_build.x - this.btn_buildNow.width - 12);
         this.btn_buildNow.y = this.btn_build.y;
         this.mc_container.addChild(this.btn_buildNow);
         this.mc_buymsg = new UIMessageArrow(this._lang.getString("construct_upgrade_buymsg"));
         this.mc_buymsg.x = -int(_padding + 4);
         this.mc_buymsg.y = this.btn_build.y - 6;
         this.mc_container.addChild(this.mc_buymsg);
         this.updateBuildButtonStates();
         Network.getInstance().playerData.inventory.itemAdded.add(this.onPlayerItemAdded);
         Network.getInstance().playerData.compound.resources.resourceChanged.add(this.onPlayerResourceChanged);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         TooltipManager.getInstance().removeAllFromParent(this.mc_container,true);
         Network.getInstance().playerData.inventory.itemAdded.remove(this.onPlayerItemAdded);
         Network.getInstance().playerData.compound.resources.resourceChanged.remove(this.onPlayerResourceChanged);
         this._building = null;
         this._lang = null;
         this._xml = null;
         this.btn_build.dispose();
         this.btn_buildNow.dispose();
         this.mc_buymsg.dispose();
         this.ui_info.dispose();
         this.mc_imageCurrentLevel.dispose();
         this.mc_imageNextLevel.dispose();
         this.bmp_locked.bitmapData.dispose();
         this.bmp_locked.bitmapData = null;
         this.bmp_arrow.bitmapData.dispose();
         this.bmp_arrow.bitmapData = null;
      }
      
      private function updateBuildButtonStates() : void
      {
         var buildingId:String = null;
         var network:Network = null;
         var nextLevel:int = 0;
         var xmlLvl:XML = null;
         var meetsBldReq:Boolean = false;
         var meetsLvlReq:Boolean = false;
         var meetsAllReq:Boolean = false;
         var costResources:Dictionary = null;
         var costItems:Dictionary = null;
         var hasResources:Boolean = false;
         var hasItems:Boolean = false;
         var cost:int = 0;
         buildingId = this._building.xml.@id.toString();
         network = Network.getInstance();
         nextLevel = this._building.level + 1;
         xmlLvl = this._building.xml.lvl.(@n == nextLevel)[0];
         meetsBldReq = network.playerData.meetsRequirements(xmlLvl.req.bld);
         meetsLvlReq = network.playerData.meetsRequirements(xmlLvl.req.lvl);
         meetsAllReq = network.playerData.meetsRequirements(xmlLvl.req.children());
         costResources = new Dictionary(true);
         costItems = new Dictionary(true);
         Building.getBuildingUpgradeResourceItemCost(buildingId,nextLevel,costResources,costItems);
         hasResources = network.playerData.compound.resources.hasResources(costResources);
         hasItems = network.playerData.inventory.containsQuantitiesOfTypes(costItems);
         this.btn_build.enabled = meetsAllReq && hasResources && hasItems;
         if(this.btn_build.enabled)
         {
            TooltipManager.getInstance().remove(this.btn_build);
         }
         else
         {
            TooltipManager.getInstance().add(this.btn_build,this._lang.getString("tooltip.all_req_notmet"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
         }
         cost = Building.getBuildingUpgradeFuelCost(buildingId,nextLevel);
         this.btn_buildNow.enabled = cost > 0 && meetsBldReq && meetsLvlReq;
         this.btn_buildNow.label = this._lang.getString("construct_upgrade_buildnow");
         this.btn_buildNow.cost = this.btn_buildNow.enabled ? cost : 0;
         if(this.btn_buildNow.enabled)
         {
            TooltipManager.getInstance().add(this.btn_buildNow,this._lang.getString("tooltip.bld_build_now") + "<br/><br/>" + this._lang.getString("tooltip.spend_fuel",NumberFormatter.format(cost,0)),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
         }
         else
         {
            TooltipManager.getInstance().add(this.btn_buildNow,this._lang.getString("tooltip.bld_req_notmet"),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
         }
         setTitleColor(this.btn_build.enabled ? 6398924 : 11403264);
      }
      
      private function onBuildClicked(param1:MouseEvent) : void
      {
         var _loc2_:Building = null;
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         switch(param1.currentTarget)
         {
            case this.btn_build:
               _loc2_ = this._building;
               close();
               _loc2_.upgrade();
               break;
            case this.btn_buildNow:
               _loc3_ = this._building.xml.@id.toString();
               _loc4_ = this._building.level + 1;
               _loc5_ = Building.getBuildingUpgradeFuelCost(_loc3_,_loc4_);
               _loc6_ = Network.getInstance().playerData.compound.resources.getAmount(GameResources.CASH);
               if(_loc5_ > _loc6_)
               {
                  PaymentSystem.getInstance().openBuyCoinsScreen();
                  return;
               }
               this._building.upgrade(true);
               close();
         }
      }
      
      private function onPlayerResourceChanged(param1:String, param2:Number) : void
      {
         this.updateBuildButtonStates();
      }
      
      private function onPlayerItemAdded(param1:Item) : void
      {
         this.updateBuildButtonStates();
      }
   }
}

