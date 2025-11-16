package thelaststand.app.game.gui.dialogues
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.data.PlayerFlags;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.MedicalItem;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.injury.Injury;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.injury.UIInjuryHealthBar;
   import thelaststand.app.game.gui.injury.UIInjuryRecipe;
   import thelaststand.app.game.gui.lists.UIInjuryList;
   import thelaststand.app.game.gui.lists.UIInjuryListItem;
   import thelaststand.app.game.gui.loadout.UILoadoutPortrait;
   import thelaststand.app.game.gui.survivor.UISurvivorInfoOverview;
   import thelaststand.app.gui.buttons.HelpButton;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.NetworkMessage;
   import thelaststand.app.network.PaymentSystem;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class InjuriesDialogue extends BaseDialogue
   {
      
      private var _lang:Language;
      
      private var _survivor:Survivor;
      
      private var _selectedInjury:Injury;
      
      private var _overviewY:int;
      
      private var _overviewHeight:int = 52;
      
      private var _healEnabledTimer:Timer;
      
      private var mc_container:Sprite = new Sprite();
      
      private var btn_heal:PushButton;
      
      private var btn_healAll:PurchasePushButton;
      
      private var btn_inventory:PushButton;
      
      private var btn_help:HelpButton;
      
      private var bmp_inventory:Bitmap;
      
      private var ui_portrait:UILoadoutPortrait;
      
      private var ui_srvInfo:UISurvivorInfoOverview;
      
      private var ui_injuryList:UIInjuryList;
      
      private var ui_injury:UIInjuryRecipe;
      
      private var ui_health:UIInjuryHealthBar;
      
      private var dlg_inventory:InventoryDialogue;
      
      public function InjuriesDialogue(param1:Survivor)
      {
         super("injuries",this.mc_container,true);
         this._lang = Language.getInstance();
         _width = 522;
         _height = 400;
         _autoSize = false;
         this._survivor = param1;
         this._healEnabledTimer = new Timer(500);
         this._healEnabledTimer.addEventListener(TimerEvent.TIMER,this.onHealEnabledTimerTick,false,0,true);
         addTitle(this._lang.getString("injuries_title"),8958342,-1,new BmpIconInjuriesLarge());
         this._overviewY = int(_padding * 0.5);
         GraphicUtils.drawUIBlock(this.mc_container.graphics,int(_width - _padding * 2),this._overviewHeight,0,this._overviewY);
         this.ui_portrait = new UILoadoutPortrait();
         this.ui_portrait.mouseEnabled = false;
         this.ui_portrait.survivor = this._survivor;
         this.ui_portrait.y = int(this._overviewY + (this._overviewHeight - this.ui_portrait.height) * 0.5);
         this.ui_portrait.x = int(this.ui_portrait.y - this._overviewY);
         this.mc_container.addChild(this.ui_portrait);
         this.ui_srvInfo = new UISurvivorInfoOverview();
         this.ui_srvInfo.survivor = this._survivor;
         this.ui_srvInfo.y = int(this.ui_portrait.y + (this.ui_portrait.height - this.ui_srvInfo.height) * 0.5);
         this.ui_srvInfo.x = int(_width - _padding * 2 - 180);
         this.mc_container.addChild(this.ui_srvInfo);
         this.ui_health = new UIInjuryHealthBar();
         this.ui_health.x = int(this.ui_portrait.x + this.ui_portrait.width + 10);
         this.ui_health.y = int(this.ui_portrait.y + (this.ui_portrait.height - this.ui_health.height) * 0.5);
         this.ui_health.width = int(this.ui_srvInfo.x - this.ui_health.x - 10);
         this.mc_container.addChild(this.ui_health);
         this.ui_injuryList = new UIInjuryList();
         this.ui_injuryList.width = 190;
         this.ui_injuryList.height = 249;
         this.ui_injuryList.x = 0;
         this.ui_injuryList.y = int(this._overviewY + this._overviewHeight + _padding);
         this.ui_injuryList.injuries = this._survivor.injuries.toVector();
         this.ui_injuryList.changed.add(this.onInjurySelected);
         this.mc_container.addChild(this.ui_injuryList);
         this.ui_injury = new UIInjuryRecipe();
         this.ui_injury.x = int(_width - _padding * 2 - this.ui_injury.width);
         this.ui_injury.y = int(this.ui_injuryList.y);
         this.ui_injury.itemChanged.add(this.onRecipeItemChanged);
         this.mc_container.addChild(this.ui_injury);
         this.btn_heal = new PushButton(this._lang.getString("injuries_heal"));
         this.btn_heal.clicked.add(this.onHealClicked);
         this.btn_heal.x = int(_width - this.btn_heal.width - _padding * 2 - 2);
         this.btn_heal.y = int(this.ui_injury.y + this.ui_injury.height + 16);
         this.mc_container.addChild(this.btn_heal);
         this.btn_inventory = new PushButton(this._lang.getString("injuries_inventory"));
         this.btn_inventory.clicked.add(this.onInventoryClicked);
         this.btn_inventory.width = 100;
         this.btn_inventory.x = int(this.btn_heal.x - this.btn_inventory.width - 20);
         this.btn_inventory.y = int(this.btn_heal.y);
         this.btn_inventory.labelOffset = -20;
         this.mc_container.addChild(this.btn_inventory);
         var _loc2_:Boolean = Network.getInstance().playerData.isInventoryUpgraded();
         this.bmp_inventory = new Bitmap(_loc2_ ? new BmpIconHUDInventoryUpgrade1() : new BmpIconHUDInventory(),"auto",true);
         this.bmp_inventory.height = 42;
         this.bmp_inventory.scaleX = this.bmp_inventory.scaleY;
         this.bmp_inventory.x = int(this.btn_inventory.x + this.btn_inventory.width - this.bmp_inventory.width - 10);
         this.bmp_inventory.y = int(this.btn_inventory.y + (this.btn_inventory.height - this.bmp_inventory.height) * 0.5);
         this.bmp_inventory.filters = [Effects.ICON_SHADOW];
         this.mc_container.addChild(this.bmp_inventory);
         this.btn_help = new HelpButton("injury_help");
         this.btn_help.x = this.ui_injuryList.x;
         this.btn_help.y = int(this.btn_inventory.y + (this.btn_inventory.height - this.btn_help.height) * 0.5);
         this.mc_container.addChild(this.btn_help);
         this.btn_healAll = new PurchasePushButton(this._lang.getString("injuries_healall"));
         this.btn_healAll.iconAlign = PurchasePushButton.ICON_ALIGN_LABEL_RIGHT;
         this.btn_healAll.width = int(this.ui_injuryList.width - this.btn_help.width - 20);
         this.btn_healAll.x = int(this.ui_injuryList.x + this.ui_injuryList.width - this.btn_healAll.width - 4);
         this.btn_healAll.y = int(this.btn_heal.y);
         this.btn_healAll.clicked.add(this.onHealAllClicked);
         this.mc_container.addChild(this.btn_healAll);
         this._survivor.injuries.changed.add(this.onInjuriesChanged);
         this.mc_container.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         this.mc_container.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         TweenMax.killDelayedCallsTo(this.showFirstViewHelp);
         this._healEnabledTimer.stop();
         this.mc_container.removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.mc_container.removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         if(this.dlg_inventory != null)
         {
            this.dlg_inventory.dispose();
         }
         this.ui_health.dispose();
         this.btn_help.dispose();
         this.btn_heal.dispose();
         this.btn_healAll.dispose();
         this.btn_inventory.dispose();
         this.ui_portrait.dispose();
         this.ui_srvInfo.dispose();
         this.ui_injury.dispose();
         this.ui_injuryList.dispose();
         this.bmp_inventory.bitmapData.dispose();
         this.bmp_inventory.bitmapData = null;
         Network.getInstance().playerData.inventory.itemAdded.remove(this.onItemAddedOrRemoved);
         Network.getInstance().playerData.inventory.itemRemoved.remove(this.onItemAddedOrRemoved);
         this._selectedInjury = null;
         this._survivor.injuries.changed.remove(this.onInjuriesChanged);
         this._survivor = null;
      }
      
      override public function open() : void
      {
         super.open();
         if(!Network.getInstance().playerData.flags.get(PlayerFlags.InjuryHelpComplete))
         {
            TweenMax.delayedCall(1,this.showFirstViewHelp);
         }
      }
      
      private function showFirstViewHelp() : void
      {
         var dlgHelp:TutorialHelpDialogue = new TutorialHelpDialogue(this._lang.getString("injury_tut_title"),new <Sprite>[new HelpPage("images/ui/help-injury1.jpg",this._lang.getString("injury_tut_help1_title"),this._lang.getString("injury_tut_help1_msg")),new HelpPage("images/ui/help-injury2.jpg",this._lang.getString("injury_tut_help2_title"),this._lang.getString("injury_tut_help2_msg")),new HelpPage("images/ui/help-injury3.jpg",this._lang.getString("injury_tut_help3_title"),this._lang.getString("injury_tut_help3_msg"))]);
         dlgHelp.closed.addOnce(function(param1:Dialogue):void
         {
            Network.getInstance().connection.send(NetworkMessage.FLAG_CHANGED,PlayerFlags.InjuryHelpComplete,true);
         });
         dlgHelp.open();
      }
      
      private function canHealSelectedInjury() : Boolean
      {
         var itemsXML:XML;
         var reqList:XMLList;
         var i:int;
         var len:int;
         var otherReqList:XMLList;
         var injuryXML:XML = null;
         var inputItem:Item = null;
         var reqNode:XML = null;
         var medItem:MedicalItem = null;
         var reqItemXML:XML = null;
         if(this._selectedInjury == null)
         {
            return false;
         }
         if(this._selectedInjury.timer.getSecondsRemaining() < 10)
         {
            return false;
         }
         injuryXML = this._selectedInjury.getXML();
         itemsXML = ResourceManager.getInstance().getResource("xml/items.xml").content;
         reqList = injuryXML.recipe.med + injuryXML.recipe.itm;
         i = 0;
         len = int(reqList.length());
         while(i < len)
         {
            inputItem = this.ui_injury.getInputItem(i);
            if(inputItem == null)
            {
               return false;
            }
            reqNode = reqList[i];
            if(reqNode.localName() == "med")
            {
               if(inputItem.category != "medical")
               {
                  return false;
               }
               medItem = MedicalItem(inputItem);
               if(medItem.medicalClass != reqNode.@id.toString())
               {
                  return false;
               }
               if(medItem.medicalGrade < int(reqNode.@grade))
               {
                  return false;
               }
            }
            else
            {
               reqItemXML = itemsXML.item.(@id == reqList[i].@id.toString())[0];
               if(inputItem.type != reqList[i].@id)
               {
                  return false;
               }
            }
            i++;
         }
         otherReqList = injuryXML.recipe.children().(localName() != "med" && localName() != "itm" && localName() != "res");
         return Network.getInstance().playerData.meetsRequirements(otherReqList);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         if(this.ui_injuryList.injuries.length > 0)
         {
            this.btn_healAll.enabled = true;
            this.btn_healAll.cost = this._survivor.injuries.getHealAllCost();
            this.ui_injuryList.selectItem(0);
            this.onInjurySelected();
         }
         else
         {
            this.btn_heal.enabled = false;
            this.btn_healAll.enabled = false;
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onHealClicked(param1:MouseEvent) : void
      {
         var injury:Injury;
         var itemIdList:Array;
         var i:int;
         var len:int;
         var attemptHeal:Function;
         var network:Network = null;
         var itemList:Array = null;
         var srv:Survivor = null;
         var responseData:Object = null;
         var busyDone:Boolean = false;
         var dlgBusy:AutoProgressBarDialogue = null;
         var item:Item = null;
         var e:MouseEvent = param1;
         if(this._survivor == null || this._selectedInjury == null)
         {
            return;
         }
         injury = this.ui_injury.injury;
         network = Network.getInstance();
         itemList = [];
         itemIdList = [];
         i = 0;
         len = this.ui_injury.numInputs;
         while(i < len)
         {
            item = this.ui_injury.getInputItem(i);
            if(item == null)
            {
               return;
            }
            itemList[i] = item;
            itemIdList[i] = item.id;
            i++;
         }
         srv = this._survivor;
         responseData = null;
         attemptHeal = function():void
         {
            if(responseData == null || !busyDone)
            {
               return;
            }
            if(dlgBusy.isOpen)
            {
               dlgBusy.close();
            }
            if(responseData.success === false)
            {
               return;
            }
            network.playerData.inventory.itemRemoved.remove(onItemAddedOrRemoved);
            var _loc1_:int = 0;
            while(_loc1_ < itemList.length)
            {
               network.playerData.inventory.removeQuantity(itemList[_loc1_],1);
               _loc1_++;
            }
            srv.injuries.removeInjuryById(String(responseData.inj));
         };
         busyDone = false;
         dlgBusy = new AutoProgressBarDialogue(this._lang.getString("injuries_loading"),8174090,2);
         dlgBusy.completed.addOnce(function():void
         {
            busyDone = true;
            attemptHeal();
         });
         dlgBusy.open();
         Audio.sound.play("sound/interface/int-heal.mp3");
         network.startAsyncOp();
         network.save({
            "srv":this._survivor.id,
            "inj":this._selectedInjury.id,
            "itm":itemIdList
         },SaveDataMethod.SURVIVOR_HEAL_INJURY,function(param1:Object):void
         {
            network.completeAsyncOp();
            if(param1 == null)
            {
               dlgBusy.close();
               return;
            }
            responseData = param1;
            attemptHeal();
         });
      }
      
      private function onHealAllClicked(param1:MouseEvent) : void
      {
         var attemptHeal:Function;
         var network:Network = null;
         var srv:Survivor = null;
         var responseData:Object = null;
         var busyDone:Boolean = false;
         var dlgBusy:AutoProgressBarDialogue = null;
         var e:MouseEvent = param1;
         if(this._survivor == null)
         {
            return;
         }
         if(this._survivor.injuries.getHealAllCost() > Network.getInstance().playerData.compound.resources.getAmount(GameResources.CASH))
         {
            PaymentSystem.getInstance().openBuyCoinsScreen();
            return;
         }
         network = Network.getInstance();
         srv = this._survivor;
         responseData = null;
         attemptHeal = function():void
         {
            if(responseData == null || !busyDone)
            {
               return;
            }
            if(dlgBusy.isOpen)
            {
               dlgBusy.close();
            }
            if(responseData.success === false)
            {
               return;
            }
            srv.injuries.clear();
         };
         busyDone = false;
         dlgBusy = new AutoProgressBarDialogue(this._lang.getString("injuries_loading"),8174090,2);
         dlgBusy.completed.addOnce(function():void
         {
            busyDone = true;
            attemptHeal();
         });
         dlgBusy.open();
         Audio.sound.play("sound/interface/int-heal.mp3");
         network.startAsyncOp();
         network.save({"srv":this._survivor.id},SaveDataMethod.SURVIVOR_HEAL_ALL,function(param1:Object):void
         {
            network.completeAsyncOp();
            if(param1 == null)
            {
               dlgBusy.close();
               return;
            }
            responseData = param1;
            attemptHeal();
         });
      }
      
      private function onInventoryClicked(param1:MouseEvent) : void
      {
         if(this.dlg_inventory == null)
         {
            this.dlg_inventory = new InventoryDialogue("crafting");
            this.dlg_inventory.weakReference = false;
         }
         else
         {
            this.dlg_inventory.selectCategory("crafting");
         }
         this.dlg_inventory.open();
      }
      
      private function onInjurySelected() : void
      {
         this._selectedInjury = UIInjuryListItem(this.ui_injuryList.selectedItem).injury;
         this.ui_injury.injury = this._selectedInjury;
         this.btn_heal.enabled = this.canHealSelectedInjury();
         this.ui_health.maxHealth = this._survivor.maxHealth;
         this.ui_health.injuryDamage = this._survivor.getInjuryDamage();
         this.ui_health.highlightDamage = this._selectedInjury != null ? this._selectedInjury.damage : 0;
         var _loc1_:Network = Network.getInstance();
         if(this._selectedInjury != null)
         {
            _loc1_.playerData.inventory.itemAdded.add(this.onItemAddedOrRemoved);
            _loc1_.playerData.inventory.itemRemoved.add(this.onItemAddedOrRemoved);
         }
         else
         {
            _loc1_.playerData.inventory.itemAdded.remove(this.onItemAddedOrRemoved);
            _loc1_.playerData.inventory.itemRemoved.remove(this.onItemAddedOrRemoved);
         }
         this._healEnabledTimer.reset();
         this._healEnabledTimer.start();
      }
      
      private function onInjuriesChanged(param1:Survivor) : void
      {
         if(this._survivor.injuries.length == 0)
         {
            close();
            return;
         }
         this.btn_healAll.cost = this._survivor.injuries.getHealAllCost();
         var _loc2_:int = this.ui_injuryList.selectedIndex;
         var _loc3_:Vector.<Injury> = this._survivor.injuries.toVector();
         this.ui_injuryList.injuries = _loc3_;
         if(_loc2_ < 0)
         {
            _loc2_ = 0;
         }
         else if(_loc2_ >= _loc3_.length)
         {
            _loc2_ = int(_loc3_.length - 1);
         }
         this.ui_injuryList.selectItem(_loc2_);
         if(this.mc_container.stage != null)
         {
            this.onInjurySelected();
         }
      }
      
      private function onItemAddedOrRemoved(param1:Item) : void
      {
         this.btn_heal.enabled = this.canHealSelectedInjury();
      }
      
      private function onRecipeItemChanged() : void
      {
         this.btn_heal.enabled = this.canHealSelectedInjury();
      }
      
      private function onHealEnabledTimerTick(param1:TimerEvent) : void
      {
         var _loc3_:Injury = null;
         var _loc4_:int = 0;
         if(this._selectedInjury != null)
         {
            if(this._selectedInjury.timer.getSecondsRemaining() < 10)
            {
               this.btn_heal.enabled = false;
            }
         }
         var _loc2_:int = 0;
         for each(_loc3_ in this.ui_injuryList.injuries)
         {
            _loc4_ = _loc3_.timer.getSecondsRemaining();
            if(_loc4_ > _loc2_)
            {
               _loc2_ = _loc4_;
            }
         }
         this.btn_healAll.enabled = _loc2_ > 10;
      }
   }
}

