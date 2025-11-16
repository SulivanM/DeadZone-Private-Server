package thelaststand.app.game.gui.dialogues
{
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import thelaststand.app.core.Config;
   import thelaststand.app.game.data.Inventory;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.bounty.InfectedBounty;
   import thelaststand.app.game.gui.bounty.BountyInfectedPage;
   import thelaststand.app.game.gui.bounty.BountySurvivorListPage;
   import thelaststand.app.game.gui.notification.UINotificationCount;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class BountyOfficeDialogue extends BaseDialogue
   {
      
      public static const PAGE_INFECTED:String = "infected";
      
      public static const PAGE_SURVIVOR:String = "survivor";
      
      private static var _currentPageId:String = null;
      
      private var _selectedMenuButton:PushButton;
      
      private var _currentPage:Sprite;
      
      private var _tooltip:TooltipManager;
      
      private var _survivorUnlocked:Boolean;
      
      private var _infectedUnlocked:Boolean;
      
      private var _infectedBounty:InfectedBounty;
      
      private var mc_container:Sprite;
      
      private var bd_titleIcon:BitmapData;
      
      private var btn_infected:PushButton;
      
      private var btn_survivor:PushButton;
      
      private var page_infected:BountyInfectedPage;
      
      private var page_survivor:BountySurvivorListPage;
      
      private var ui_infectedNote:UINotificationCount;
      
      public function BountyOfficeDialogue(param1:String = null, ... rest)
      {
         var _loc4_:int = 0;
         this.mc_container = new Sprite();
         super("bounty-office",this.mc_container,true,true);
         _autoSize = false;
         _width = 794;
         _height = 456;
         this._tooltip = TooltipManager.getInstance();
         var _loc3_:int = int(Network.getInstance().playerData.getPlayerSurvivor().level);
         this._survivorUnlocked = _loc3_ >= Config.constant.BOUNTY_MIN_LEVEL;
         this._infectedUnlocked = _loc3_ >= Config.constant.BOUNTY_ZOMBIE_MIN_LEVEL;
         this._infectedBounty = Network.getInstance().playerData.infectedBounty;
         if(this._infectedBounty != null)
         {
            this._infectedBounty.viewed.addOnce(this.onInfectedBountyViewed);
            this._infectedBounty.completed.addOnce(this.onInfectedBountyComplete);
         }
         this.bd_titleIcon = new BmpBountySkull();
         addTitle(Language.getInstance().getString("bounty.office_title"),BaseDialogue.TITLE_COLOR_GREY,-1,this.bd_titleIcon);
         this.btn_infected = new PushButton(Language.getInstance().getString("bounty.infected_bounties"));
         this.btn_infected.data = PAGE_INFECTED;
         this.btn_infected.y = int(_padding * 0.5);
         this.btn_infected.width = 154;
         this.btn_infected.clicked.add(this.onMenuButtonClicked);
         this.btn_infected.enabled = this._infectedUnlocked && this._infectedBounty != null;
         this.mc_container.addChild(this.btn_infected);
         this.btn_survivor = new PushButton(Language.getInstance().getString("bounty.survivor_bounties"));
         this.btn_survivor.data = PAGE_SURVIVOR;
         this.btn_survivor.y = int(_padding * 0.5);
         this.btn_survivor.x = int(this.btn_infected.x + this.btn_infected.width + 12);
         this.btn_survivor.width = 154;
         this.btn_survivor.clicked.add(this.onMenuButtonClicked);
         this.btn_survivor.enabled = this._survivorUnlocked;
         this.mc_container.addChild(this.btn_survivor);
         this.ui_infectedNote = new UINotificationCount(10030858);
         this.ui_infectedNote.label = "!";
         this.ui_infectedNote.visible = false;
         this.ui_infectedNote.x = this.btn_infected.x;
         this.ui_infectedNote.y = this.btn_infected.y;
         this.mc_container.addChild(this.ui_infectedNote);
         if(this._infectedUnlocked)
         {
            this.updateInfectedBountyNotification();
         }
         else
         {
            this._tooltip.add(this.btn_infected,Language.getInstance().getString("bounty.infected_locked",Config.constant.BOUNTY_ZOMBIE_MIN_LEVEL + 1),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
         }
         if(!this._survivorUnlocked)
         {
            this._tooltip.add(this.btn_survivor,Language.getInstance().getString("bounty.survivor_locked",Config.constant.BOUNTY_MIN_LEVEL + 1),new Point(NaN,0),TooltipDirection.DIRECTION_DOWN,0);
         }
         param1 ||= _currentPageId || PAGE_INFECTED;
         if(param1 == _currentPageId)
         {
            _currentPageId = "";
         }
         this.gotoPage(param1);
         if(rest.length > 0)
         {
            if(this.page_infected != null)
            {
               _loc4_ = int(rest[0]);
               this.page_infected.selectTask(_loc4_);
            }
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         Network.getInstance().playerData.inventory.itemRemoved.remove(this.onInventoryItemRemoved);
         this._tooltip.removeAllFromParent(sprite);
         this._tooltip = null;
         if(this._infectedBounty != null)
         {
            this._infectedBounty.completed.remove(this.onInfectedBountyComplete);
            this._infectedBounty.viewed.remove(this.onInfectedBountyViewed);
            this._infectedBounty = null;
         }
         this.bd_titleIcon.dispose();
         this.btn_infected.dispose();
         this.btn_survivor.dispose();
         this.ui_infectedNote.dispose();
         if(this.page_infected != null)
         {
            this.page_infected.dispose();
         }
         if(this.page_survivor != null)
         {
            this.page_survivor.dispose();
         }
      }
      
      private function gotoPage(param1:String) : void
      {
         if(param1 == _currentPageId)
         {
            return;
         }
         if(this._selectedMenuButton != null)
         {
            if(this._selectedMenuButton.data != param1)
            {
               this._selectedMenuButton.selected = false;
               this._selectedMenuButton = null;
            }
         }
         if(this._currentPage != null)
         {
            if(this._currentPage.parent != null)
            {
               this._currentPage.parent.removeChild(this._currentPage);
            }
            this._currentPage = null;
         }
         if(param1 == PAGE_INFECTED && !this._infectedUnlocked)
         {
            param1 = PAGE_SURVIVOR;
         }
         _currentPageId = param1;
         switch(_currentPageId)
         {
            case PAGE_INFECTED:
               this._selectedMenuButton = this.btn_infected;
               if(this.page_infected == null)
               {
                  this.page_infected = new BountyInfectedPage();
               }
               this._currentPage = this.page_infected;
               break;
            case PAGE_SURVIVOR:
               this._selectedMenuButton = this.btn_survivor;
               if(this.page_survivor == null)
               {
                  this.page_survivor = new BountySurvivorListPage();
               }
               this._currentPage = this.page_survivor;
               break;
            default:
               _currentPageId = PAGE_INFECTED;
               this.gotoPage(_currentPageId);
               return;
         }
         if(this._selectedMenuButton != null)
         {
            this._selectedMenuButton.selected = true;
         }
         if(this._currentPage != null)
         {
            this._currentPage.x = 0;
            this._currentPage.y = int(this.btn_infected.y + this.btn_infected.height + _padding);
            this.mc_container.addChild(this._currentPage);
         }
      }
      
      private function updateInfectedBountyNotification() : void
      {
         var _loc1_:Item = null;
         if(this._infectedBounty == null)
         {
            this.ui_infectedNote.visible = false;
            return;
         }
         if(this._infectedBounty.isCompleted)
         {
            _loc1_ = Network.getInstance().playerData.inventory.getItemById(this._infectedBounty.rewardItemId);
            if(_loc1_ != null)
            {
               Network.getInstance().playerData.inventory.itemRemoved.add(this.onInventoryItemRemoved);
               this.ui_infectedNote.color = 622336;
               this.ui_infectedNote.visible = true;
            }
            else
            {
               this.ui_infectedNote.visible = false;
            }
         }
         else if(!this._infectedBounty.isViewed)
         {
            this.ui_infectedNote.color = 10030858;
            this.ui_infectedNote.visible = true;
         }
         else
         {
            this.ui_infectedNote.visible = false;
         }
      }
      
      private function onMenuButtonClicked(param1:MouseEvent) : void
      {
         this.gotoPage(PushButton(param1.currentTarget).data);
      }
      
      private function onInfectedBountyViewed(param1:InfectedBounty) : void
      {
         this._infectedBounty.viewed.remove(this.onInfectedBountyViewed);
         this.updateInfectedBountyNotification();
      }
      
      private function onInfectedBountyComplete(param1:InfectedBounty) : void
      {
         this._infectedBounty.completed.remove(this.onInfectedBountyComplete);
         this.updateInfectedBountyNotification();
      }
      
      private function onInventoryItemRemoved(param1:Item) : void
      {
         var _loc2_:Inventory = Network.getInstance().playerData.inventory;
         if(this._infectedBounty == null)
         {
            _loc2_.itemRemoved.remove(this.onInventoryItemRemoved);
            return;
         }
         if(param1.id.toUpperCase() == this._infectedBounty.rewardItemId.toUpperCase())
         {
            _loc2_.itemRemoved.remove(this.onInventoryItemRemoved);
            this.updateInfectedBountyNotification();
         }
      }
   }
}

