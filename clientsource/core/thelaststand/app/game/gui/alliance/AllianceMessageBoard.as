package thelaststand.app.game.gui.alliance
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import thelaststand.app.core.Config;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.data.alliance.AllianceMessage;
   import thelaststand.app.game.data.alliance.AllianceMessageList;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.UIScrollBar;
   import thelaststand.app.game.gui.alliance.messages.UIAllianceMessageItem;
   import thelaststand.app.gui.dialogues.BaseDialogue;
   import thelaststand.app.gui.dialogues.MessageBox;
   import thelaststand.app.network.RPCResponse;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class AllianceMessageBoard extends Sprite
   {
      
      private var _width:Number = 470;
      
      private var _height:Number = 368;
      
      private var _padding:int = 10;
      
      private var _items:Vector.<UIAllianceMessageItem>;
      
      private var _messages:AllianceMessageList;
      
      private var mc_container:Sprite;
      
      private var mc_mask:Shape;
      
      private var txt_empty:BodyTextField;
      
      private var ui_scrollbar:UIScrollBar;
      
      public function AllianceMessageBoard()
      {
         super();
         this._items = new Vector.<UIAllianceMessageItem>();
         GraphicUtils.drawUIBlock(this.graphics,this._width,this._height);
         this.ui_scrollbar = new UIScrollBar();
         this.ui_scrollbar.x = this._width - this.ui_scrollbar.width - 5;
         this.ui_scrollbar.y = 5;
         this.ui_scrollbar.height = this._height - 10;
         this.ui_scrollbar.changed.add(this.onScrollChange);
         addChild(this.ui_scrollbar);
         this.mc_mask = new Shape();
         this.mc_mask.x = 1;
         this.mc_mask.y = 1;
         this.mc_mask.graphics.beginFill(16711680);
         this.mc_mask.graphics.drawRect(0,0,this.ui_scrollbar.x - 2,this._height - 2);
         this.mc_mask.alpha = 0.1;
         addChild(this.mc_mask);
         this.mc_container = new Sprite();
         this.mc_container.x = this.mc_mask.x;
         this.mc_container.y = this.mc_mask.y;
         addChild(this.mc_container);
         this.mc_container.mask = this.mc_mask;
         this.txt_empty = new BodyTextField({"text":Language.getInstance().getString("alliance.messages_empty")});
         this.txt_empty.x = int((this._width - this.txt_empty.width) * 0.5);
         this.txt_empty.y = int((this._height - this.txt_empty.height) * 0.5);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
         addEventListener(MouseEvent.MOUSE_WHEEL,this.onScrollWheel,false,0,true);
      }
      
      public function dispose() : void
      {
         var _loc1_:UIAllianceMessageItem = null;
         if(parent)
         {
            parent.removeChild(this);
         }
         if(this._messages != null)
         {
            this._messages.messageAdded.remove(this.onMessageAdded);
            this._messages.messageRemoved.remove(this.onMessageRemoved);
            this._messages.unreadMessageCountChange.remove(this.updateMessageListLastReadTime);
            this._messages = null;
         }
         for each(_loc1_ in this._items)
         {
            _loc1_.dispose();
         }
         this._items = null;
         this.ui_scrollbar.destroy();
         this.txt_empty.dispose();
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         removeEventListener(MouseEvent.MOUSE_WHEEL,this.onScrollWheel);
      }
      
      private function updateContentPos() : void
      {
         var _loc1_:Number = Math.max(this.mc_container.height + this._padding * 2 - this.mc_mask.height,0);
         this.mc_container.y = this.mc_mask.y - _loc1_ * this.ui_scrollbar.value + this._padding;
      }
      
      private function getMessageItem(param1:AllianceMessage) : UIAllianceMessageItem
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._items.length)
         {
            if(this._items[_loc2_].message == param1)
            {
               return this._items[_loc2_];
            }
            _loc2_++;
         }
         return null;
      }
      
      private function createItems() : void
      {
         var _loc1_:UIAllianceMessageItem = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         for each(_loc1_ in this._items)
         {
            _loc1_.dispose();
         }
         this._items.length = 0;
         if(this._messages.numMessages > 0)
         {
            _loc2_ = int(this.mc_mask.width - this._padding * 2);
            _loc3_ = 0;
            while(_loc3_ < this._messages.numMessages)
            {
               _loc1_ = UIAllianceMessageItem.create(this._messages.getMessage(_loc3_),_loc2_);
               _loc1_.addEventListener("msgDelete",this.onDeleteItemClicked,false,0,true);
               this._items.push(_loc1_);
               this.mc_container.addChild(_loc1_);
               _loc3_++;
            }
         }
         this.refresh();
      }
      
      private function refresh() : void
      {
         var ty:int;
         var i:int = 0;
         var item:UIAllianceMessageItem = null;
         var diff:Number = NaN;
         if(this._items.length == 0)
         {
            addChild(this.txt_empty);
            return;
         }
         if(this.txt_empty.parent)
         {
            this.txt_empty.parent.removeChild(this.txt_empty);
         }
         this._items.sort(function(param1:UIAllianceMessageItem, param2:UIAllianceMessageItem):int
         {
            if(param1.message.date == null)
            {
               return -1;
            }
            if(param2.message.date == null)
            {
               return 1;
            }
            return int(param2.message.date.time / 1000) - int(param1.message.date.time / 1000);
         });
         ty = 0;
         i = 0;
         while(i < this._items.length)
         {
            item = this._items[i];
            item.x = this._padding;
            item.y = ty;
            diff = int(Config.constant.ALLIANCE_MESSAGE_MAX_COUNT) - i;
            if(diff <= 0)
            {
               item.alpha = 0.25;
            }
            else if(diff == 1)
            {
               item.alpha = 0.5;
            }
            else if(diff == 2)
            {
               item.alpha = 0.75;
            }
            else
            {
               item.alpha = 1;
            }
            ty += int(item.height + this._padding);
            i++;
         }
         this.ui_scrollbar.contentHeight = int(this.mc_container.height + this._padding);
         this.ui_scrollbar.value = 0;
         this.updateContentPos();
      }
      
      public function forceRefresh() : void
      {
         this.createItems();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.refresh();
         this.updateMessageListLastReadTime();
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
      }
      
      private function onMessageAdded(param1:AllianceMessage) : void
      {
         var _loc2_:UIAllianceMessageItem = UIAllianceMessageItem.create(param1,int(this.mc_mask.width - this._padding * 2));
         _loc2_.addEventListener("msgDelete",this.onDeleteItemClicked,false,0,true);
         this._items.push(_loc2_);
         this.mc_container.addChild(_loc2_);
         this.refresh();
      }
      
      private function onMessageRemoved(param1:AllianceMessage) : void
      {
         var _loc3_:UIAllianceMessageItem = null;
         var _loc2_:int = int(this._items.length - 1);
         while(_loc2_ >= 0)
         {
            _loc3_ = this._items[_loc2_];
            if(_loc3_.message == param1)
            {
               this._items.splice(_loc2_,1);
               _loc3_.dispose();
               this.refresh();
               return;
            }
            _loc2_--;
         }
      }
      
      private function onScrollChange(param1:Number) : void
      {
         this.updateContentPos();
      }
      
      private function onScrollWheel(param1:MouseEvent) : void
      {
         if(this.mc_container.height < this.mc_mask.height)
         {
            return;
         }
         var _loc2_:Number = 30 / (this.mc_container.height - this.mc_mask.height);
         this.ui_scrollbar.value += param1.delta < 0 ? _loc2_ : -_loc2_;
         param1.stopPropagation();
         this.updateContentPos();
      }
      
      private function onDeleteItemClicked(param1:Event) : void
      {
         var lang:Language = null;
         var item:UIAllianceMessageItem = null;
         var e:Event = param1;
         lang = Language.getInstance();
         item = UIAllianceMessageItem(e.currentTarget);
         var msgConfirm:MessageBox = new MessageBox(lang.getString("alliance.deletemsg_confirm_msg"));
         msgConfirm.addTitle(lang.getString("alliance.deletemsg_confirm_title"),BaseDialogue.TITLE_COLOR_RUST);
         msgConfirm.addButton(lang.getString("alliance.deletemsg_confirm_cancel"));
         msgConfirm.addButton(lang.getString("alliance.deletemsg_confirm_ok")).clicked.addOnce(function(param1:MouseEvent):void
         {
            var e:MouseEvent = param1;
            item.mouseChildren = false;
            AllianceSystem.getInstance().deleteMessage(item.message.id,function(param1:RPCResponse):void
            {
               var _loc2_:MessageBox = null;
               if(!param1.success)
               {
                  _loc2_ = new MessageBox(lang.getString("alliance.deletemsg_error_msg"));
                  _loc2_.addTitle(lang.getString("alliance.deletemsg_error_title"),BaseDialogue.TITLE_COLOR_RUST);
                  _loc2_.addButton(lang.getString("alliance.deletemsg_error_ok"));
                  item.mouseChildren = true;
                  return;
               }
            });
         });
         msgConfirm.open();
      }
      
      private function updateMessageListLastReadTime(param1:int = 0) : void
      {
         if(stage == null)
         {
            return;
         }
         var _loc2_:Date = new Date();
         _loc2_.minutes += _loc2_.timezoneOffset;
         this._messages.lastViewedDate = _loc2_;
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
      
      public function get messages() : AllianceMessageList
      {
         return this._messages;
      }
      
      public function set messages(param1:AllianceMessageList) : void
      {
         if(param1 == this._messages)
         {
            return;
         }
         if(this._messages != null)
         {
            this._messages.messageAdded.remove(this.onMessageAdded);
            this._messages.messageRemoved.remove(this.onMessageRemoved);
            this._messages.unreadMessageCountChange.remove(this.updateMessageListLastReadTime);
         }
         this._messages = param1;
         this.createItems();
         if(this._messages != null)
         {
            this._messages.messageAdded.add(this.onMessageAdded);
            this._messages.messageRemoved.add(this.onMessageRemoved);
            this._messages.unreadMessageCountChange.add(this.updateMessageListLastReadTime);
         }
      }
   }
}

