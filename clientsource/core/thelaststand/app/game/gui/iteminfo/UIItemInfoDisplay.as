package thelaststand.app.game.gui.iteminfo
{
   import flash.display.Sprite;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.gui.lists.UIInventoryListItem;
   import thelaststand.common.lang.Language;
   
   public class UIItemInfoDisplay extends Sprite implements IUIItemInfo
   {
      
      protected var _lang:Language;
      
      protected var _item:Item;
      
      protected var _loadout:SurvivorLoadout;
      
      protected var _survivor:Survivor;
      
      protected var _width:int = 264;
      
      protected var _height:int = 0;
      
      internal var mc_image:UIInventoryListItem;
      
      public function UIItemInfoDisplay()
      {
         super();
         this._lang = Language.getInstance();
         this.mc_image = new UIInventoryListItem();
         this.mc_image.showEquippedIcon = false;
         this.mc_image.showNewIcon = false;
         this.mc_image.x = 2;
         this.mc_image.y = 0;
         addChild(this.mc_image);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this._lang = null;
         this._loadout = null;
         this._survivor = null;
         this._item = null;
         this.mc_image.dispose();
      }
      
      public function setItem(param1:Item, param2:SurvivorLoadout = null, param3:Object = null) : void
      {
         param3 ||= {};
         this._item = param1;
         this._loadout = param2;
         this._survivor = this._loadout != null ? this._loadout.survivor : null;
         this.mc_image.itemData = this._item;
         this._height = int(this.mc_image.y + this.mc_image.height);
      }
      
      public function get item() : Item
      {
         throw new Error("Must be overridden by subclasses");
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

