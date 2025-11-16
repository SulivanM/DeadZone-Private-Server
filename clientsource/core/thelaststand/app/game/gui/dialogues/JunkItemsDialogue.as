package thelaststand.app.game.gui.dialogues
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.gui.lists.UIInventoryList;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.common.lang.Language;
   
   public class JunkItemsDialogue extends BaseDialogue
   {
      
      private var _items:Vector.<Item>;
      
      private var _numCols:int = 5;
      
      private var btn_ok:PushButton;
      
      private var mc_container:Sprite;
      
      private var txt_desc:BodyTextField;
      
      private var txt_xp:BodyTextField;
      
      private var ui_items:UIInventoryList;
      
      public var started:Signal;
      
      public function JunkItemsDialogue(param1:Vector.<Item>, param2:int, param3:Boolean, param4:Boolean = false)
      {
         var options:ItemListOptions;
         var numRows:int;
         var lang:Language = null;
         var langId:String = null;
         var items:Vector.<Item> = param1;
         var xp:int = param2;
         var completed:Boolean = param3;
         var inProgress:Boolean = param4;
         lang = Language.getInstance();
         langId = completed ? "junk_removed_" : "junk_removal_";
         this._items = items;
         this.mc_container = new Sprite();
         super("junkremoved-dialogue",this.mc_container);
         _autoSize = false;
         this.started = new Signal();
         if(this._items.length == 0)
         {
            this._items = Vector.<Item>([null]);
         }
         addTitle(lang.getString(langId + "title"),completed ? 3183890 : BaseDialogue.TITLE_COLOR_GREY);
         if(completed || inProgress)
         {
            addButton(lang.getString("junk_removed_ok"),true,{"width":120});
         }
         else
         {
            addButton(lang.getString(langId + "cancel"),true,{"width":70});
            addButton(lang.getString(langId + "ok"),false,{
               "width":100,
               "iconBackgroundColor":41732,
               "icon":new Bitmap(new BmpIconButtonArrow())
            }).clicked.addOnce(function(param1:MouseEvent):void
            {
               started.dispatch();
               close();
            });
         }
         this.txt_desc = new BodyTextField({
            "color":10790052,
            "size":11,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_desc.text = lang.getString(langId + "msg").toUpperCase();
         this.mc_container.addChild(this.txt_desc);
         options = new ItemListOptions();
         options.clothingPreviews = ClothingPreviewDisplayOptions.DISABLED;
         options.allowSelection = false;
         options.showNewIcons = false;
         numRows = Math.max(1,Math.ceil(this._items.length / this._numCols));
         this.ui_items = new UIInventoryList(48,10,options);
         this.ui_items.y = int(this.txt_desc.y + this.txt_desc.height);
         this.ui_items.width = (this._numCols + 1) * 48;
         this.ui_items.height = Math.max(72,numRows * 72 - 18);
         this.ui_items.itemList = this._items;
         this.mc_container.addChild(this.ui_items);
         if(xp > 0)
         {
            this.txt_xp = new BodyTextField({
               "color":16363264,
               "size":14,
               "bold":true,
               "filters":[Effects.TEXT_SHADOW]
            });
            this.txt_xp.text = lang.getString("msg_xp_awarded",NumberFormatter.format(xp,0));
            this.txt_xp.y = int(this.ui_items.y + this.ui_items.height + 10);
            this.mc_container.addChild(this.txt_xp);
         }
         _width = int(this.ui_items.width + _padding * 2);
         _height = int(this.ui_items.y + this.ui_items.height + 38 + _padding * 2);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._items = null;
         this.ui_items.dispose();
         this.started.removeAll();
      }
   }
}

