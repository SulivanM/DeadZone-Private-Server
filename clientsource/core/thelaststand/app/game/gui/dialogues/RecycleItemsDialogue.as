package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.BatchRecycleJob;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.gui.buttons.PurchasePushButton;
   import thelaststand.app.game.gui.lists.UIInventoryList;
   import thelaststand.app.gui.UIPagination;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.common.lang.Language;
   
   public class RecycleItemsDialogue extends BaseDialogue
   {
      
      private var _job:BatchRecycleJob;
      
      private var _items:Vector.<Item>;
      
      private var _numCols:int = 5;
      
      private var btn_ok:PushButton;
      
      private var mc_container:Sprite;
      
      private var txt_desc:BodyTextField;
      
      private var ui_items:UIInventoryList;
      
      private var ui_pagination:UIPagination;
      
      public var started:Signal;
      
      public function RecycleItemsDialogue(param1:BatchRecycleJob)
      {
         var options:ItemListOptions;
         var lang:Language = null;
         var langId:String = null;
         var numRows:int = 0;
         var job:BatchRecycleJob = param1;
         this._job = job;
         this._items = this._job.items;
         lang = Language.getInstance();
         langId = this._job.isComplete ? "batch_recycle_complete_" : "batch_recycle_inprogress_";
         this.mc_container = new Sprite();
         super("recycleitems-dialogue",this.mc_container);
         _autoSize = false;
         this.started = new Signal();
         if(this._job.items.length == 0)
         {
            this._items = Vector.<Item>([null]);
         }
         addTitle(lang.getString(langId + "title"),BaseDialogue.TITLE_COLOR_GREEN);
         if(!this._job.isComplete && this._job.timer != null && this._job.timer.getSecondsRemaining() > 5)
         {
            addButton(lang.getString("batch_recycle_speedup"),false,{
               "buttonClass":PurchasePushButton,
               "showIcon":false,
               "width":120
            }).clicked.add(function(param1:MouseEvent):void
            {
               var _loc2_:SpeedUpDialogue = new SpeedUpDialogue(_job);
               _loc2_.speedUpSelected.addOnce(close);
               _loc2_.open();
            });
         }
         addButton(lang.getString(langId + "ok"),true,{"width":120});
         this.txt_desc = new BodyTextField({
            "color":10790052,
            "size":11,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_desc.text = lang.getString(langId + "msg").toUpperCase();
         this.mc_container.addChild(this.txt_desc);
         this._numCols = Math.max(5,Math.min(this._items.length,8));
         options = new ItemListOptions();
         options.clothingPreviews = ClothingPreviewDisplayOptions.DISABLED;
         options.allowSelection = false;
         options.showNewIcons = false;
         numRows = Math.max(1,Math.ceil(this._items.length / this._numCols));
         numRows = Math.min(numRows,5);
         this.ui_items = new UIInventoryList(48,10,options);
         this.ui_items.y = int(this.txt_desc.y + this.txt_desc.height);
         this.ui_items.width = this._numCols * 48 + (this._numCols + 1) * 10 - 2;
         this.ui_items.height = Math.max(68,numRows * 48 + (numRows + 1) * 10 + 4);
         this.ui_items.itemList = this._items;
         this.mc_container.addChild(this.ui_items);
         _width = int(this.ui_items.width + _padding * 2);
         _height = int(this.ui_items.y + this.ui_items.height + 38 + _padding * 2);
         if(this.ui_items.numPages > 1)
         {
            this.ui_pagination = new UIPagination(this.ui_items.numPages);
            this.ui_pagination.changed.add(this.onPageChange);
            this.ui_pagination.x = this.ui_items.x + Math.floor((this.ui_items.width - this.ui_pagination.width) * 0.5);
            this.ui_pagination.y = this.ui_items.y + this.ui_items.height + 10;
            this.mc_container.addChild(this.ui_pagination);
            _height += this.ui_pagination.height + 10;
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this._job = null;
         this._items = null;
         this.txt_desc.dispose();
         this.ui_items.dispose();
         this.started.removeAll();
         if(this.ui_pagination != null)
         {
            this.ui_pagination.dispose();
         }
      }
      
      private function onPageChange(param1:int) : void
      {
         this.ui_items.gotoPage(param1);
      }
   }
}

