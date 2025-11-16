package thelaststand.app.game.gui.arena
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.CrateMysteryItem;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.game.gui.dialogues.CrateMysteryUnlockDialogue;
   import thelaststand.app.game.gui.dialogues.InventoryDialogue;
   import thelaststand.app.game.gui.raid.RaidDialogue;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class ArenaEndedDialogue extends BaseDialogue
   {
      
      private var _session:ArenaSession;
      
      private var mc_container:Sprite = new Sprite();
      
      private var btn_collectReward:PushButton;
      
      private var ui_objectivesView:ArenaEndedObjectivesView;
      
      private var ui_result:Sprite;
      
      private var ui_resultImage:UIImage;
      
      private var mc_resultBlocks:Shape;
      
      private var txt_resultTitle:BodyTextField;
      
      public function ArenaEndedDialogue(param1:ArenaSession)
      {
         super("arena-end",this.mc_container,true);
         _width = 784;
         _height = 420;
         _autoSize = false;
         this._session = param1;
         addTitle(Language.getInstance().getString("arena.title",Language.getInstance().getString("arena." + this._session.name + ".name")),BaseDialogue.TITLE_COLOR_GREY,-1,new BmpBountySkull());
         this.ui_result = new Sprite();
         GraphicUtils.drawUIBlock(this.ui_result.graphics,329,388);
         this.ui_result.x = int(_width - _padding * 2 - this.ui_result.width);
         this.ui_result.y = 0;
         this.mc_container.addChild(this.ui_result);
         var _loc2_:int = 6;
         this.ui_resultImage = new UIImage(this.ui_result.width - _loc2_ * 2,this.ui_result.height - _loc2_ * 2);
         this.ui_resultImage.x = this.ui_resultImage.y = _loc2_;
         this.ui_resultImage.uri = ("images/arenas/" + this._session.name + "_" + (this._session.successful ? "success" : "failure") + ".jpg").toLowerCase();
         this.ui_result.addChild(this.ui_resultImage);
         this.mc_resultBlocks = new Shape();
         this.mc_resultBlocks.graphics.beginFill(0,0.8);
         this.mc_resultBlocks.graphics.drawRect(6,6,this.ui_result.width - 12,30);
         this.mc_resultBlocks.graphics.endFill();
         var _loc3_:Boolean = this._session.rewardItems != null && this._session.rewardItems.length > 0;
         if(_loc3_)
         {
            this.mc_resultBlocks.graphics.beginFill(0,0.8);
            this.mc_resultBlocks.graphics.drawRect(6,this.ui_result.height - 70 - 3,this.ui_result.width - 12,70);
            this.mc_resultBlocks.graphics.endFill();
         }
         this.ui_result.addChild(this.mc_resultBlocks);
         var _loc4_:uint = this._session.successful ? 9360403 : 13898515;
         this.txt_resultTitle = new BodyTextField({
            "color":_loc4_,
            "size":20,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_resultTitle.text = this._session.successful ? Language.getInstance().getString("arena.arena_success") : Language.getInstance().getString("arena.arena_failed");
         this.txt_resultTitle.x = int((this.ui_result.width - this.txt_resultTitle.width) * 0.5);
         this.txt_resultTitle.y = 6;
         this.ui_result.addChild(this.txt_resultTitle);
         if(_loc3_)
         {
            this.btn_collectReward = new PushButton(Language.getInstance().getString("arena.collect_reward"),new BmpIconNewItem(),RaidDialogue.COLOR,{"bold":true});
            this.btn_collectReward.width = 200;
            this.btn_collectReward.height = 44;
            this.btn_collectReward.clicked.addOnce(this.onClickCollectReward);
            this.btn_collectReward.showBorder = false;
            this.btn_collectReward.x = int((this.ui_result.width - this.btn_collectReward.width) * 0.5);
            this.btn_collectReward.y = int(this.ui_result.height - this.btn_collectReward.height - 16);
            this.ui_result.addChild(this.btn_collectReward);
         }
         this.ui_objectivesView = new ArenaEndedObjectivesView();
         this.ui_objectivesView.width = int(this.ui_result.x - _padding);
         this.ui_objectivesView.height = int(this.ui_result.height);
         this.ui_objectivesView.setData(this._session);
         this.mc_container.addChild(this.ui_objectivesView);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this.btn_collectReward != null)
         {
            this.btn_collectReward.dispose();
         }
         this.txt_resultTitle.dispose();
         this.ui_objectivesView.dispose();
         this._session = null;
      }
      
      private function onClickCollectReward(param1:MouseEvent) : void
      {
         var _loc2_:CrateMysteryItem = null;
         var _loc3_:Item = null;
         var _loc4_:CrateMysteryUnlockDialogue = null;
         var _loc5_:InventoryDialogue = null;
         for each(_loc3_ in this._session.rewardItems)
         {
            if(_loc3_ is CrateMysteryItem)
            {
               _loc2_ = CrateMysteryItem(_loc3_);
               break;
            }
         }
         if(_loc2_ != null)
         {
            _loc4_ = new CrateMysteryUnlockDialogue(_loc2_);
            _loc4_.open();
         }
         else
         {
            _loc5_ = new InventoryDialogue("new");
            _loc5_.open();
         }
         close();
      }
   }
}

