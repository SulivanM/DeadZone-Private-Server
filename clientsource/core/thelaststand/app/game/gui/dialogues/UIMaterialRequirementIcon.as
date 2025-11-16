package thelaststand.app.game.gui.dialogues
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.ItemFactory;
   import thelaststand.app.game.gui.buttons.UICraftBuyButtons;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.network.Network;
   import thelaststand.common.gui.dialogues.DialogueManager;
   import thelaststand.common.lang.Language;
   
   public class UIMaterialRequirementIcon extends Sprite
   {
      
      private static const BMP_ITEM_BACKGROUND:BitmapData = new BmpInventorySlotEmpty();
      
      private static const IMAGE_STROKE:GlowFilter = new GlowFilter(0,1,2,2,10,1);
      
      private static const CT_REQUIREMENTS_NOT_MET:ColorTransform = new ColorTransform();
      
      CT_REQUIREMENTS_NOT_MET.color = 11940608;
      
      private const BORDER_SIZE:int = 2;
      
      private const IMAGE_SIZE:int = 32;
      
      private var _borderColor:uint = 11453906;
      
      private var _showBuyOption:Boolean = true;
      
      private var _showCraftOption:Boolean = true;
      
      private var _materialId:String;
      
      private var _materialType:String;
      
      private var _materialXML:XML;
      
      private var _amountRequired:int;
      
      private var _network:Network;
      
      private var _lang:Language;
      
      private var mc_hitArea:Shape;
      
      private var mc_border:Shape;
      
      private var mc_imageBg:Bitmap;
      
      private var txt_amount:BodyTextField;
      
      private var ui_buyCraft:UICraftBuyButtons;
      
      private var ui_itemImage:UIImage;
      
      public function UIMaterialRequirementIcon(param1:Boolean = true, param2:Boolean = true)
      {
         super();
         this._showBuyOption = param1;
         this._showCraftOption = param2;
         this._network = Network.getInstance();
         this._lang = Language.getInstance();
         this.mc_hitArea = new Shape();
         this.mc_hitArea.graphics.beginFill(16711680,0);
         this.mc_hitArea.graphics.drawRect(0,0,10,this.IMAGE_SIZE + this.BORDER_SIZE * 2);
         this.mc_hitArea.graphics.endFill();
         addChild(this.mc_hitArea);
         this.mc_border = new Shape();
         this.mc_border.graphics.beginFill(this._borderColor);
         this.mc_border.graphics.drawRect(0,0,this.IMAGE_SIZE + this.BORDER_SIZE * 2,this.IMAGE_SIZE + this.BORDER_SIZE * 2);
         this.mc_border.graphics.drawRect(this.BORDER_SIZE,this.BORDER_SIZE,this.IMAGE_SIZE,this.IMAGE_SIZE);
         this.mc_border.graphics.endFill();
         this.mc_border.alpha = 0.3;
         addChild(this.mc_border);
         this.mc_imageBg = new Bitmap(BMP_ITEM_BACKGROUND,"auto",true);
         this.mc_imageBg.width = this.mc_imageBg.height = this.IMAGE_SIZE;
         this.mc_imageBg.x = this.mc_imageBg.y = this.BORDER_SIZE;
         this.mc_imageBg.alpha = 0.3;
         addChild(this.mc_imageBg);
         this.ui_itemImage = new UIImage(this.IMAGE_SIZE,this.IMAGE_SIZE,0,0,false);
         this.ui_itemImage.mouseEnabled = false;
         this.ui_itemImage.x = this.ui_itemImage.y = this.BORDER_SIZE;
         this.ui_itemImage.alpha = 0.3;
         this.ui_itemImage.imageDisplayed.add(this.onItemImageDisplayed);
         addChild(this.ui_itemImage);
         this.txt_amount = new BodyTextField({
            "color":16777215,
            "size":14,
            "bold":true
         });
         this.txt_amount.mouseEnabled = false;
         this.txt_amount.filters = [Effects.STROKE];
         this.ui_buyCraft = new UICraftBuyButtons();
      }
      
      public function get borderColor() : uint
      {
         return this._borderColor;
      }
      
      public function set borderColor(param1:uint) : void
      {
         this._borderColor = param1;
         this.mc_border.graphics.clear();
         this.mc_border.graphics.beginFill(this._borderColor);
         this.mc_border.graphics.drawRect(0,0,this.IMAGE_SIZE + this.BORDER_SIZE * 2,this.IMAGE_SIZE + this.BORDER_SIZE * 2);
         this.mc_border.graphics.drawRect(this.BORDER_SIZE,this.BORDER_SIZE,this.IMAGE_SIZE,this.IMAGE_SIZE);
         this.mc_border.graphics.endFill();
      }
      
      public function dispose() : void
      {
         TweenMax.killTweensOf(this);
         TooltipManager.getInstance().removeAllFromParent(this);
         Network.getInstance().playerData.compound.resources.resourceChanged.remove(this.onResourceChanged);
         Network.getInstance().playerData.inventory.itemAdded.remove(this.onItemAdded);
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this.mc_imageBg.bitmapData = null;
         this.ui_itemImage.dispose();
         this.txt_amount.dispose();
         this.ui_buyCraft.dispose();
         this._lang = null;
         this._network = null;
         this._materialXML = null;
      }
      
      public function setMaterial(param1:String, param2:int) : void
      {
         TooltipManager.getInstance().removeAllFromParent(this);
         this._network.playerData.compound.resources.resourceChanged.remove(this.onResourceChanged);
         this._network.playerData.inventory.itemAdded.remove(this.onItemAdded);
         if(param1 == null)
         {
            this._materialXML = null;
            this._materialId = null;
            this._materialType = null;
            this._amountRequired = 0;
            this.mc_border.transform.colorTransform = new ColorTransform();
            this.mc_border.alpha = this.mc_imageBg.alpha = this.ui_itemImage.alpha = 0.3;
            this.ui_itemImage.uri = null;
            this.ui_itemImage.filters = [];
            if(this.txt_amount.parent != null)
            {
               this.txt_amount.parent.removeChild(this.txt_amount);
            }
            if(this.ui_buyCraft.parent != null)
            {
               this.ui_buyCraft.parent.removeChild(this.ui_buyCraft);
            }
            return;
         }
         var _loc3_:XML = ItemFactory.getItemDefinition(param1);
         this._materialXML = _loc3_;
         this._materialId = param1;
         this._materialType = _loc3_.@type.toString();
         this._amountRequired = param2;
         this.ui_itemImage.filters = [];
         this.ui_itemImage.uri = _loc3_.img.@uri.toString();
         this.ui_itemImage.alpha = this.mc_border.alpha = this.mc_imageBg.alpha = 1;
         addChild(this.txt_amount);
         this.updateAmountDisplay();
         if(this._materialType == "resource")
         {
            this._network.playerData.compound.resources.resourceChanged.add(this.onResourceChanged);
         }
         else
         {
            this._network.playerData.inventory.itemAdded.add(this.onItemAdded);
         }
      }
      
      private function updateAmountDisplay() : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(!this._materialXML)
         {
            return;
         }
         var _loc1_:String = this._lang.getString("items." + this._materialId);
         var _loc2_:String = _loc1_;
         var _loc3_:String = "<br/>";
         var _loc4_:* = this._materialXML.@craft_only == "1";
         var _loc5_:Boolean = !_loc4_ && (!this._materialXML.hasOwnProperty("@canbuy") || this._materialXML.@canbuy != "0");
         if(_loc4_)
         {
            _loc2_ += " <b>[ " + this._lang.getString("items.craft_only") + " ]</b>";
         }
         if(this._materialType == "resource")
         {
            _loc6_ = this._network.playerData.compound.resources.getAmount(this._materialId);
         }
         else
         {
            _loc6_ = int(this._network.playerData.inventory.getNumItemsOfType(this._materialId));
         }
         this.txt_amount.text = _loc6_ + " / " + this._amountRequired;
         this.txt_amount.y = int(this.ui_itemImage.y + (this.ui_itemImage.height - this.txt_amount.height) * 0.5);
         if(_loc6_ < this._amountRequired)
         {
            _loc7_ = 0;
            this.ui_buyCraft.setItem(this._materialId,this._materialType);
            this.ui_buyCraft.showCraft = this._showCraftOption && Network.getInstance().playerData.inventory.hasSchematicForItem(this._materialId);
            this.ui_buyCraft.showBuy = _loc5_ && this._showBuyOption;
            if(this.ui_buyCraft.showCraft)
            {
               _loc2_ += _loc3_ + this._lang.getString("craftmore");
            }
            if(this.ui_buyCraft.showBuy)
            {
               _loc2_ += _loc3_ + this._lang.getString("buymore");
            }
            this.ui_buyCraft.x = int(this.ui_itemImage.x + this.ui_itemImage.width + this.BORDER_SIZE);
            this.ui_buyCraft.y = int(this.ui_itemImage.y + (this.ui_itemImage.height - this.ui_buyCraft.height) * 0.5);
            addChild(this.ui_buyCraft);
            this.txt_amount.textColor = 14550272;
            this.txt_amount.x = int(this.ui_buyCraft.x + this.ui_buyCraft.width + 2);
            this.mc_border.transform.colorTransform = CT_REQUIREMENTS_NOT_MET;
         }
         else
         {
            this.mc_border.transform.colorTransform = new ColorTransform();
            this.txt_amount.textColor = 16777215;
            this.txt_amount.x = int(this.ui_itemImage.x + this.ui_itemImage.width + this.BORDER_SIZE + 4);
            if(this.ui_buyCraft.parent != null)
            {
               this.ui_buyCraft.parent.removeChild(this.ui_buyCraft);
            }
         }
         this.mc_hitArea.width = this.txt_amount.x + this.txt_amount.width;
         TooltipManager.getInstance().add(this,_loc2_,new Point(0,NaN),TooltipDirection.DIRECTION_RIGHT,0);
      }
      
      private function onClickCraft(param1:MouseEvent) : void
      {
         var _loc2_:CraftingDialogue = DialogueManager.getInstance().getDialogueById("crafting-dialogue") as CraftingDialogue;
         if(_loc2_ == null)
         {
            _loc2_ = new CraftingDialogue(this._materialType,this._materialId);
            _loc2_.open();
         }
         else
         {
            _loc2_.setCategoryAndSelectSchematicByType(this._materialType,this._materialId);
         }
      }
      
      private function onClickBuy(param1:MouseEvent) : void
      {
         var _loc2_:StoreDialogue = null;
         var _loc3_:MiniStoreDialogue = null;
         if(this._materialType == "resource")
         {
            _loc2_ = new StoreDialogue("resource",this._materialId);
            _loc2_.open();
         }
         else
         {
            _loc3_ = new MiniStoreDialogue(this._materialId);
            _loc3_.open();
         }
      }
      
      private function onResourceChanged(param1:String, param2:int) : void
      {
         if(param1 == this._materialId)
         {
            this.updateAmountDisplay();
         }
      }
      
      private function onItemAdded(param1:Item) : void
      {
         if(param1.type == this._materialId)
         {
            this.updateAmountDisplay();
         }
      }
      
      private function onItemImageDisplayed(param1:UIImage) : void
      {
         if(param1.isPNG)
         {
            this.ui_itemImage.filters = [IMAGE_STROKE];
         }
      }
   }
}

