package thelaststand.app.game.gui.dialogues
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Building;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.game.data.IRecyclable;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.gui.lists.UIInventoryList;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class RecycleDialogue extends BaseDialogue
   {
      
      private var _target:IRecyclable;
      
      private var _numCols:int = 5;
      
      private var btn_recycle:PushButton;
      
      private var btn_cancel:PushButton;
      
      private var mc_container:Sprite;
      
      private var txt_desc:BodyTextField;
      
      private var ui_items:UIInventoryList;
      
      public var recycled:Signal;
      
      public function RecycleDialogue(param1:IRecyclable)
      {
         var _loc5_:* = false;
         var _loc6_:String = null;
         var _loc8_:int = 0;
         var _loc9_:Item = null;
         var _loc10_:XML = null;
         var _loc11_:String = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc2_:Language = Language.getInstance();
         this._target = param1;
         this.recycled = new Signal(IRecyclable);
         this.mc_container = new Sprite();
         super("recycle-dialogue",this.mc_container);
         var _loc3_:Vector.<Item> = this._target.getRecycleItems();
         var _loc4_:int = int(_loc3_.length - 1);
         while(_loc4_ >= 0)
         {
            _loc9_ = _loc3_[_loc4_];
            if(_loc9_.category == "resource")
            {
               _loc10_ = _loc9_.xml.res.res[0];
               _loc11_ = _loc10_.@id.toString();
               if(_loc11_ != GameResources.CASH)
               {
                  _loc12_ = int(_loc10_.toString());
                  _loc13_ = _loc12_ * _loc9_.quantity;
                  _loc14_ = Network.getInstance().playerData.compound.resources.getAvailableStorageCapacity(_loc11_);
                  if(_loc12_ > _loc14_)
                  {
                     _loc9_.quantity = 1;
                  }
                  else
                  {
                     _loc9_.quantity = Math.min(_loc9_.quantity,int(_loc14_ / _loc12_));
                  }
               }
            }
            _loc4_--;
         }
         if(_loc3_.length == 0)
         {
            _loc3_.push(null);
         }
         _loc5_ = this._target is Building;
         _loc6_ = _loc5_ ? "recycle_bld_" : "recycle_";
         addTitle(_loc2_.getString(_loc6_ + "title",this._target.getName()),_loc5_ ? 16761856 : 3183890);
         this.txt_desc = new BodyTextField({
            "color":10790052,
            "size":11
         });
         this.txt_desc.text = _loc2_.getString(_loc6_ + "desc");
         this.txt_desc.filters = [Effects.TEXT_SHADOW];
         this.mc_container.addChild(this.txt_desc);
         var _loc7_:ItemListOptions = new ItemListOptions();
         _loc7_.clothingPreviews = ClothingPreviewDisplayOptions.DISABLED;
         _loc7_.allowSelection = false;
         _loc8_ = Math.max(1,Math.ceil(_loc3_.length / this._numCols));
         this.ui_items = new UIInventoryList(48,10,_loc7_);
         this.ui_items.y = int(this.txt_desc.y + this.txt_desc.height);
         this.ui_items.width = (this._numCols + 1) * 48;
         this.ui_items.height = Math.max(72,_loc8_ * 72 - 18);
         this.ui_items.itemList = _loc3_;
         this.mc_container.addChild(this.ui_items);
         this.btn_cancel = new PushButton(_loc2_.getString("recycle_cancel"));
         this.btn_cancel.clicked.addOnce(this.onButtonClicked);
         this.btn_cancel.width = 120;
         this.btn_cancel.x = 2;
         this.btn_cancel.y = int(this.ui_items.y + this.ui_items.height + 10);
         this.mc_container.addChild(this.btn_cancel);
         this.btn_recycle = new PushButton(_loc2_.getString(_loc6_ + "ok"),_loc5_ ? new BmpIconDismantle() : new BmpIconRecycle(),_loc5_ ? 16761856 : 3183890);
         this.btn_recycle.clicked.addOnce(this.onButtonClicked);
         this.btn_recycle.width = this.btn_cancel.width;
         this.btn_recycle.x = int(this.ui_items.x + this.ui_items.width - this.btn_recycle.width - 2);
         this.btn_recycle.y = int(this.ui_items.y + this.ui_items.height + 10);
         this.mc_container.addChild(this.btn_recycle);
         _width = int(this.ui_items.width + _padding * 2);
         _height = int(this.btn_recycle.y + this.btn_recycle.height);
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.recycled.removeAll();
         this._target = null;
         this.txt_desc.dispose();
         this.ui_items.dispose();
         this.btn_cancel.dispose();
         this.btn_recycle.dispose();
      }
      
      private function onButtonClicked(param1:MouseEvent) : void
      {
         var recycleObj:IRecyclable = null;
         var e:MouseEvent = param1;
         switch(e.currentTarget)
         {
            case this.btn_cancel:
               close();
               break;
            case this.btn_recycle:
               recycleObj = this._target;
               Network.getInstance().playerData.recycleObject(recycleObj,function(param1:Boolean):void
               {
                  if(param1)
                  {
                     recycled.dispatch(recycleObj);
                  }
                  close();
               });
         }
      }
   }
}

