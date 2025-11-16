package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Settings;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.logic.DialogueController;
   import thelaststand.app.gui.CheckBox;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class InventoryFullDialogue extends BaseDialogue
   {
      
      public static const SCAVENGE_NEAR_FULL:uint = 0;
      
      public static const SCAVENGE_FULL:uint = 1;
      
      public static const TRADE_FULL:uint = 2;
      
      public static const CRAFT_FULL:uint = 3;
      
      private var _lang:Language;
      
      private var _warningType:uint;
      
      private var mc_container:Sprite;
      
      private var ui_image:UIImage;
      
      private var btn_upgrade:PurchasePushButton;
      
      private var btn_inventory:PushButton;
      
      private var btn_ok:PushButton;
      
      private var txt_message:BodyTextField;
      
      private var check_dontask:CheckBox;
      
      public var ignored:Signal;
      
      public function InventoryFullDialogue(param1:uint)
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc6_:int = 0;
         this._lang = Language.getInstance();
         this.ignored = new Signal();
         this.mc_container = new Sprite();
         super("inventory-full",this.mc_container,true);
         _autoSize = false;
         this._warningType = param1;
         var _loc4_:Boolean = Network.getInstance().playerData.canUpgradeInventory();
         switch(this._warningType)
         {
            case SCAVENGE_NEAR_FULL:
               _loc2_ = this._lang.getString("mission_inv_near_full_title");
               _loc3_ = !_loc4_ ? this._lang.getString("mission_inv_near_full_msg_hasupgrade") : this._lang.getString("mission_inv_near_full_msg");
               break;
            case SCAVENGE_FULL:
               _loc2_ = this._lang.getString("mission_inv_full_title");
               _loc3_ = !_loc4_ ? this._lang.getString("mission_inv_full_msg_hasupgrade") : this._lang.getString("mission_inv_full_msg");
               break;
            case TRADE_FULL:
               _loc2_ = this._lang.getString("trade_inv_full_title");
               _loc3_ = !_loc4_ ? this._lang.getString("trade_inv_full_msg_hasupgrade") : this._lang.getString("trade_inv_full_msg");
               break;
            case CRAFT_FULL:
               _loc2_ = this._lang.getString("craft_inv_full_title");
               _loc3_ = !_loc4_ ? this._lang.getString("craft_inv_full_msg_hasupgrade") : this._lang.getString("craft_inv_full_msg");
         }
         addTitle(_loc2_,BaseDialogue.TITLE_COLOR_GREY,-1,new BmpIconNotification());
         var _loc5_:int = _padding * 0.5;
         _loc6_ = 240;
         var _loc7_:int = 178;
         var _loc8_:int = 167;
         var _loc9_:int = 3;
         this.txt_message = new BodyTextField({
            "color":16777215,
            "size":14,
            "multiline":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_message.htmlText = _loc3_;
         this.txt_message.x = 0;
         this.txt_message.y = _loc5_;
         this.mc_container.addChild(this.txt_message);
         if(this._warningType == SCAVENGE_FULL)
         {
            this.check_dontask = new CheckBox(null,"right");
            this.check_dontask.changed.add(this.onCheckDontAskChanged);
            this.check_dontask.label = this._lang.getString("mission_inv_dontask");
            this.mc_container.addChild(this.check_dontask);
         }
         this.btn_inventory = new PushButton(this._lang.getString("mission_inv_full_ok"));
         this.btn_inventory.clicked.add(this.onClickInventory);
         this.btn_inventory.width = 120;
         this.mc_container.addChild(this.btn_inventory);
         this.btn_ok = new PushButton(this._lang.getString("mission_inv_full_cancel"));
         this.btn_ok.clicked.add(this.onClickOK);
         this.btn_ok.width = 50;
         this.mc_container.addChild(this.btn_ok);
         if(!_loc4_)
         {
            _width = 380;
            this.txt_message.width = int(_width - _padding * 2);
            if(this.check_dontask != null)
            {
               this.check_dontask.labelAlign = "left";
               this.check_dontask.x = int(_width - this.check_dontask.width - _padding * 2);
               this.check_dontask.y = int(this.txt_message.y + this.txt_message.height + 20);
               this.btn_ok.y = int(this.check_dontask.y + this.check_dontask.height + 20);
            }
            else
            {
               this.btn_ok.y = int(this.txt_message.y + this.txt_message.height + 20);
            }
            this.btn_ok.x = int(_width - this.btn_ok.width - _padding * 2);
            this.btn_inventory.x = int(this.btn_ok.x - this.btn_inventory.width - 14);
            this.btn_inventory.y = int(this.btn_ok.y);
         }
         else
         {
            _width = int(_loc6_ + _loc7_ + _loc9_ + _padding * 2);
            GraphicUtils.drawUIBlock(this.mc_container.graphics,_loc7_ + _loc9_ * 2,_loc8_ + _loc9_ * 2,_loc6_,_loc5_);
            this.ui_image = new UIImage(_loc7_,_loc8_,0,0,true,"images/ui/inventory-full-upgrade.jpg");
            this.ui_image.x = int(_loc6_ + 3);
            this.ui_image.y = int(_loc5_ + 3);
            this.mc_container.addChild(this.ui_image);
            this.txt_message.width = int(_loc6_ - _padding * 0.5);
            if(this.check_dontask != null)
            {
               this.check_dontask.x = 0;
               this.check_dontask.y = int(_loc5_ + _loc8_ + _loc9_ - this.check_dontask.height);
            }
            this.btn_upgrade = new PurchasePushButton(this._lang.getString("mission_inv_upgrade"),0,false);
            this.btn_upgrade.clicked.add(this.onClickUpgrade);
            this.btn_upgrade.width = _loc7_;
            this.btn_upgrade.x = int(this.ui_image.x + (this.ui_image.width - this.btn_upgrade.width) * 0.5);
            this.btn_upgrade.y = int(_loc5_ + _loc8_ + _padding + _loc9_);
            this.mc_container.addChild(this.btn_upgrade);
            this.btn_inventory.x = 4;
            this.btn_inventory.y = int(this.btn_upgrade.y);
            this.btn_ok.x = int(this.btn_inventory.x + this.btn_inventory.width + 14);
            this.btn_ok.y = int(this.btn_upgrade.y);
         }
         _height = int(this.btn_ok.y + this.btn_ok.height + _padding * 2 + 10);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._lang = null;
         if(this.ui_image != null)
         {
            this.ui_image.dispose();
         }
         if(this.btn_upgrade != null)
         {
            this.btn_upgrade.dispose();
         }
         this.btn_inventory.dispose();
         this.btn_ok.dispose();
         this.txt_message.dispose();
         if(this.check_dontask != null)
         {
            this.check_dontask.dispose();
         }
         this.ignored.removeAll();
      }
      
      private function onClickUpgrade(param1:MouseEvent) : void
      {
         DialogueController.getInstance().openInventoryUpgrade();
         close();
      }
      
      private function onClickInventory(param1:MouseEvent) : void
      {
         new InventoryDialogue().open();
         close();
      }
      
      private function onClickOK(param1:MouseEvent) : void
      {
         this.ignored.dispatch();
         close();
      }
      
      private function onCheckDontAskChanged(param1:CheckBox) : void
      {
         switch(this._warningType)
         {
            case SCAVENGE_NEAR_FULL:
               Settings.getInstance().session_dontAskInventoryNearCapacity = param1.selected;
               break;
            case SCAVENGE_FULL:
               Settings.getInstance().session_dontAskInventoryFull = param1.selected;
         }
      }
   }
}

