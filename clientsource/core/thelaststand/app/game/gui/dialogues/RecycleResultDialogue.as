package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.gui.lists.UIInventoryList;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.common.lang.Language;
   
   public class RecycleResultDialogue extends BaseDialogue
   {
      
      private var _items:Vector.<Item>;
      
      private var _numCols:int = 5;
      
      private var mc_container:Sprite;
      
      private var txt_desc:BodyTextField;
      
      private var ui_items:UIInventoryList;
      
      public function RecycleResultDialogue(param1:Vector.<Item>)
      {
         var _loc3_:ItemListOptions = null;
         var _loc2_:Language = Language.getInstance();
         this._items = param1;
         this.mc_container = new Sprite();
         super("recycle-result-dialogue",this.mc_container);
         addTitle(_loc2_.getString("recycle_result_title"),BaseDialogue.TITLE_COLOR_GREY);
         addButton(_loc2_.getString("recycle_result_ok"),true,{"width":80});
         this.txt_desc = new BodyTextField({
            "color":10790052,
            "size":11
         });
         this.txt_desc.text = _loc2_.getString("recycle_result_desc");
         this.txt_desc.filters = [Effects.TEXT_SHADOW];
         this.mc_container.addChild(this.txt_desc);
         _loc3_ = new ItemListOptions();
         _loc3_.clothingPreviews = ClothingPreviewDisplayOptions.DISABLED;
         _loc3_.allowSelection = false;
         var _loc4_:int = Math.max(1,Math.ceil(this._items.length / this._numCols));
         this.ui_items = new UIInventoryList(48,10,_loc3_);
         this.ui_items.y = int(this.txt_desc.y + this.txt_desc.height);
         this.ui_items.width = (this._numCols + 1) * 48;
         this.ui_items.height = Math.max(72,_loc4_ * 72 - 18);
         this.ui_items.itemList = this._items;
         this.mc_container.addChild(this.ui_items);
         _width = int(this.ui_items.width + _padding * 2);
         _height = int(this.ui_items.y + this.ui_items.height);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._items = null;
         this.txt_desc.dispose();
         this.ui_items.dispose();
      }
   }
}

