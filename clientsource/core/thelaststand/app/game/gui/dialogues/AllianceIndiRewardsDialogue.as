package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.gui.UIItemInfo;
   import thelaststand.app.game.gui.lists.UIInventoryListItem;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.gui.dialogues.Dialogue;
   import thelaststand.common.lang.Language;
   
   public class AllianceIndiRewardsDialogue extends BaseDialogue
   {
      
      private var itemInfo:UIItemInfo;
      
      private var mc_container:Sprite;
      
      private var ui_image:UIImage;
      
      private var txt_body:BodyTextField;
      
      private var slots:Vector.<UIInventoryListItem>;
      
      public function AllianceIndiRewardsDialogue(param1:Object)
      {
         var _loc6_:Item = null;
         var _loc7_:UIInventoryListItem = null;
         this.mc_container = new Sprite();
         super("allianceIndiReward",this.mc_container,true);
         addTitle(Language.getInstance().getString("alliance.indiReward_award_title"));
         this.ui_image = new UIImage(255,146,0,0,true,"images/alliances/allaiance_indiRewards.jpg");
         this.ui_image.x = this.ui_image.y = 4;
         this.mc_container.addChild(this.ui_image);
         GraphicUtils.drawUIBlock(this.mc_container.graphics,this.ui_image.width + this.ui_image.x * 2,this.ui_image.height + this.ui_image.y * 2);
         this.txt_body = new BodyTextField({
            "size":14,
            "align":"center",
            "multiline":true
         });
         this.txt_body.width = 255;
         this.txt_body.height = 30;
         this.txt_body.htmlText = Language.getInstance().getString("alliance.indiReward_award_body",param1.rewardScore);
         this.txt_body.y = this.ui_image.height + this.ui_image.y * 3;
         this.txt_body.x = Math.round((this.ui_image.x + this.ui_image.width - this.txt_body.width) * 0.5);
         this.mc_container.addChild(this.txt_body);
         this.itemInfo = new UIItemInfo();
         this.slots = new Vector.<UIInventoryListItem>();
         var _loc2_:Sprite = new Sprite();
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         while(_loc5_ < param1.items.length)
         {
            _loc6_ = ItemFactory.createItemFromObject(param1.items[_loc5_]);
            if(_loc6_ != null)
            {
               Network.getInstance().playerData.inventory.addItem(_loc6_);
               _loc7_ = new UIInventoryListItem();
               _loc7_.x = _loc3_;
               _loc7_.y = _loc4_;
               this.itemInfo.addRolloverTarget(_loc7_);
               _loc7_.mouseOver.add(this.onItemOver);
               _loc7_.itemData = _loc6_;
               _loc2_.addChild(_loc7_);
               this.slots.push(_loc7_);
               _loc3_ += _loc7_.width + 14;
               if(this.slots.length % 3 == 0)
               {
                  _loc3_ = 0;
                  _loc4_ += _loc7_.height + 8;
               }
            }
            _loc5_++;
         }
         _loc2_.x = Math.round((this.ui_image.x + this.ui_image.width - _loc2_.width) * 0.5);
         _loc2_.y = this.txt_body.y + this.txt_body.height + 16;
         this.mc_container.addChild(_loc2_);
         GraphicUtils.drawUIBlock(this.mc_container.graphics,this.ui_image.width + 8,_loc2_.height + 24,0,_loc2_.y - 8);
         _buttonAlign = Dialogue.BUTTON_ALIGN_CENTER;
         addButton(Language.getInstance().getString("alliance.indiReward_award_ok"),true,{
            "width":190,
            "backgroundColor":Effects.BUTTON_GREEN
         });
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIInventoryListItem = null;
         super.dispose();
         this.txt_body.dispose();
         this.ui_image.dispose();
         this.itemInfo.dispose();
         for each(_loc1_ in this.slots)
         {
            _loc1_.dispose();
         }
      }
      
      private function onItemOver(param1:MouseEvent) : void
      {
         var _loc2_:UIInventoryListItem = UIInventoryListItem(param1.target);
         this.itemInfo.setItem(_loc2_.itemData,null,{
            "showResourceLimited":false,
            "showAction":false
         });
      }
   }
}

