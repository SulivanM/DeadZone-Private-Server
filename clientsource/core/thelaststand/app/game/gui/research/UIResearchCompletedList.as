package thelaststand.app.game.gui.research
{
   import com.exileetiquette.math.MathUtils;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import org.osflash.signals.Signal;
   import thelaststand.app.game.data.research.ResearchSystem;
   import thelaststand.app.game.gui.UIScrollBar;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.resources.ResourceManager;
   
   public class UIResearchCompletedList extends UIComponent
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _padding:int = 8;
      
      private var _items:Vector.<CategoryList>;
      
      private var _scrollRect:Rectangle;
      
      private var _contentHeight:int;
      
      private var mc_mask:Sprite;
      
      private var mc_content:Sprite;
      
      private var ui_scrollbar:UIScrollBar;
      
      public var selectionChanged:Signal;
      
      public function UIResearchCompletedList()
      {
         var xmlCats:XMLList;
         var catNode:XML = null;
         var item:CategoryList = null;
         this._items = new Vector.<CategoryList>();
         this._scrollRect = new Rectangle();
         this.selectionChanged = new Signal(String,String,int);
         super();
         this.mc_content = new Sprite();
         this.mc_mask = new Sprite();
         this.mc_content.mask = this.mc_mask;
         this.ui_scrollbar = new UIScrollBar();
         this.ui_scrollbar.changed.add(this.onScrollbarChanged);
         addChild(this.mc_content);
         addChild(this.mc_mask);
         addChild(this.ui_scrollbar);
         xmlCats = ResourceManager.getInstance().get("xml/research.xml").research;
         for each(catNode in xmlCats)
         {
            item = new CategoryList(catNode);
            item.selectionChanged.add(this.onSelectionChanged);
            this.mc_content.addChild(item);
            this._items.push(item);
         }
         this._items.sort(function(param1:CategoryList, param2:CategoryList):int
         {
            var _loc3_:String = ResearchSystem.getCategoryName(param1.category);
            var _loc4_:String = ResearchSystem.getCategoryName(param2.category);
            return _loc3_.localeCompare(_loc4_);
         });
         addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel,false,0,true);
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         invalidate();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = param1;
         invalidate();
      }
      
      private function calculateContentHeight() : void
      {
         var _loc2_:CategoryList = null;
         this._contentHeight = 0;
         var _loc1_:int = 0;
         while(_loc1_ < this._items.length)
         {
            _loc2_ = this._items[_loc1_];
            if(_loc2_.parent != null)
            {
               this._contentHeight += _loc2_.height;
               if(_loc1_ < this._items.length - 1)
               {
                  this._contentHeight += this._padding + 10;
               }
            }
            _loc1_++;
         }
      }
      
      private function onMouseWheel(param1:MouseEvent) : void
      {
         if(this._contentHeight <= this._scrollRect.height)
         {
            return;
         }
         var _loc2_:Number = this._scrollRect.height / this._contentHeight;
         this.ui_scrollbar.value -= MathUtils.sign(param1.delta) * _loc2_;
         this.updateContentPosition();
      }
      
      override public function dispose() : void
      {
         var _loc1_:CategoryList = null;
         super.dispose();
         for each(_loc1_ in this._items)
         {
            _loc1_.dispose();
         }
      }
      
      public function selectFirst() : void
      {
         var _loc2_:CategoryList = null;
         if(this._items.length == 0)
         {
            return;
         }
         var _loc1_:int = 0;
         while(_loc1_ < this._items.length)
         {
            _loc2_ = this._items[_loc1_];
            if(_loc2_.getCompletedCount() > 0)
            {
               _loc2_.selectFirst();
               return;
            }
            _loc1_++;
         }
      }
      
      public function select(param1:String, param2:String) : void
      {
         var _loc4_:CategoryList = null;
         var _loc3_:int = 0;
         while(_loc3_ < this._items.length)
         {
            _loc4_ = this._items[_loc3_];
            if(_loc4_.category == param1)
            {
               _loc4_.selectByGroup(param2);
               break;
            }
            _loc3_++;
         }
      }
      
      override protected function draw() : void
      {
         graphics.clear();
         GraphicUtils.drawUIBlock(graphics,this._width,this._height);
         this.ui_scrollbar.x = int(this._width - this._padding - this.ui_scrollbar.width);
         this.ui_scrollbar.y = this._padding;
         this._scrollRect.x = this._padding;
         this._scrollRect.y = this._padding;
         this._scrollRect.width = this._width - this._padding * 3 - this.ui_scrollbar.width;
         this._scrollRect.height = this._height - this._padding * 2;
         this.mc_content.x = this._scrollRect.x;
         this.mc_content.y = this._scrollRect.y;
         this.ui_scrollbar.height = this._scrollRect.height;
         this.updateListItemPositions(true);
         this.mc_mask.x = this._scrollRect.x;
         this.mc_mask.y = this._scrollRect.y;
         this.mc_mask.graphics.clear();
         this.mc_mask.graphics.beginFill(16711680,0.25);
         this.mc_mask.graphics.drawRect(0,0,this._scrollRect.width,this._scrollRect.height);
         this.mc_mask.graphics.endFill();
      }
      
      private function updateListItemPositions(param1:Boolean = false) : void
      {
         var _loc4_:CategoryList = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this._items.length)
         {
            _loc4_ = this._items[_loc3_];
            if(_loc4_.getCompletedCount() > 0)
            {
               _loc4_.y = _loc2_;
               _loc4_.width = this._scrollRect.width - this._padding;
               if(param1)
               {
                  _loc4_.redraw();
               }
               this.mc_content.addChild(_loc4_);
               _loc2_ += _loc4_.height + this._padding + 10;
            }
            else if(_loc4_.parent != null)
            {
               _loc4_.parent.removeChild(_loc4_);
            }
            _loc3_++;
         }
         this.calculateContentHeight();
         this.ui_scrollbar.contentHeight = this._contentHeight;
      }
      
      private function updateContentPosition() : void
      {
         this.mc_content.y = int(this._scrollRect.y - Math.max(this._contentHeight - this._scrollRect.height,0) * this.ui_scrollbar.value);
      }
      
      private function onScrollbarChanged(param1:Number) : void
      {
         this.updateContentPosition();
      }
      
      private function onSelectionChanged(param1:CategoryList, param2:UIResearchListItem) : void
      {
         var _loc4_:CategoryList = null;
         var _loc5_:String = null;
         var _loc3_:int = 0;
         while(_loc3_ < this._items.length)
         {
            _loc4_ = this._items[_loc3_];
            if(_loc4_ != param1)
            {
               _loc4_.deselect();
            }
            _loc3_++;
         }
         if(param2 != null)
         {
            _loc5_ = param2.xmlGroup.@id.toString();
            this.selectionChanged.dispatch(param1.category,_loc5_,param2.level);
         }
      }
   }
}

import com.deadreckoned.threshold.display.Color;
import flash.events.MouseEvent;
import flash.text.AntiAliasType;
import org.osflash.signals.Signal;
import thelaststand.app.display.BodyTextField;
import thelaststand.app.display.Effects;
import thelaststand.app.game.data.research.ResearchSystem;
import thelaststand.app.gui.UIComponent;
import thelaststand.app.network.Network;

class CategoryList extends UIComponent
{
   
   private var _category:String;
   
   private var _xml:XML;
   
   private var _items:Vector.<UIResearchListItem>;
   
   private var _selectedItem:UIResearchListItem;
   
   private var _width:int;
   
   private var _height:int;
   
   private var txt_header:BodyTextField;
   
   public var selectionChanged:Signal;
   
   public function CategoryList(param1:XML)
   {
      var _loc4_:XML = null;
      var _loc5_:UIResearchListItem = null;
      var _loc6_:int = 0;
      this._items = new Vector.<UIResearchListItem>();
      this.selectionChanged = new Signal(CategoryList,UIResearchListItem);
      super();
      this._xml = param1;
      this._category = this._xml.@id.toString();
      var _loc2_:String = ResearchSystem.getCategoryName(this._category).toUpperCase();
      var _loc3_:uint = Color.hexToColor(this._xml.@color.toString());
      this.txt_header = new BodyTextField({
         "text":_loc2_,
         "color":_loc3_,
         "bold":true,
         "size":14,
         "filters":[Effects.TEXT_SHADOW],
         "antiAliasType":AntiAliasType.ADVANCED
      });
      addChild(this.txt_header);
      for each(_loc4_ in this._xml.group)
      {
         _loc5_ = new UIResearchListItem();
         _loc6_ = Network.getInstance().playerData.researchState.getLevel(this._category,_loc4_.@id.toString());
         _loc5_.xmlGroup = _loc4_;
         _loc5_.level = _loc6_;
         _loc5_.addEventListener(MouseEvent.CLICK,this.onClickItem,false,0,true);
         this._items.push(_loc5_);
      }
   }
   
   public function get category() : String
   {
      return this._category;
   }
   
   override public function get width() : Number
   {
      return this._width;
   }
   
   override public function set width(param1:Number) : void
   {
      this._width = param1;
      invalidate();
   }
   
   override public function get height() : Number
   {
      return this._height;
   }
   
   override public function set height(param1:Number) : void
   {
      this._height = param1;
      invalidate();
   }
   
   override public function dispose() : void
   {
      var _loc1_:UIResearchListItem = null;
      super.dispose();
      this.txt_header.dispose();
      for each(_loc1_ in this._items)
      {
         _loc1_.dispose();
      }
   }
   
   public function getCompletedCount() : int
   {
      var _loc3_:UIResearchListItem = null;
      var _loc4_:int = 0;
      var _loc1_:int = 0;
      var _loc2_:int = 0;
      while(_loc2_ < this._items.length)
      {
         _loc3_ = this._items[_loc2_];
         _loc4_ = Network.getInstance().playerData.researchState.getLevel(this._category,_loc3_.xmlGroup.@id.toString());
         if(_loc4_ > -1)
         {
            _loc1_++;
         }
         _loc2_++;
      }
      return _loc1_;
   }
   
   override protected function draw() : void
   {
      var _loc3_:UIResearchListItem = null;
      var _loc4_:int = 0;
      this.txt_header.width = this._width;
      this.txt_header.x = 0;
      this.txt_header.y = 0;
      var _loc1_:int = int(this.txt_header.y + this.txt_header.height + 2);
      var _loc2_:int = 0;
      while(_loc2_ < this._items.length)
      {
         _loc3_ = this._items[_loc2_];
         _loc4_ = Network.getInstance().playerData.researchState.getLevel(this._category,_loc3_.xmlGroup.@id.toString());
         if(_loc4_ > -1)
         {
            _loc3_.y = _loc1_;
            _loc3_.width = this._width;
            _loc3_.height = this._height;
            _loc3_.level = _loc4_;
            _loc3_.state = UIResearchListItem.STATE_AVAILABLE;
            _loc1_ += int(_loc3_.height + 2);
            addChild(_loc3_);
         }
         else if(_loc3_.parent != null)
         {
            _loc3_.parent.removeChild(_loc3_);
         }
         _loc2_++;
      }
      this._height = _loc1_ - 2;
   }
   
   public function deselect() : void
   {
      if(this._selectedItem != null)
      {
         this._selectedItem.selected = false;
         this._selectedItem = null;
      }
   }
   
   public function selectFirst() : void
   {
      var _loc2_:UIResearchListItem = null;
      var _loc3_:int = 0;
      var _loc1_:int = 0;
      while(_loc1_ < this._items.length)
      {
         _loc2_ = this._items[_loc1_];
         _loc3_ = Network.getInstance().playerData.researchState.getLevel(this._category,_loc2_.xmlGroup.@id.toString());
         if(_loc3_ > -1)
         {
            this.selectItem(_loc2_);
            return;
         }
         _loc1_++;
      }
   }
   
   public function selectByIndex(param1:int) : void
   {
      if(param1 < 0 || param1 >= this._items.length)
      {
         return;
      }
      var _loc2_:UIResearchListItem = this._items[param1];
      this.selectItem(_loc2_);
   }
   
   public function selectByGroup(param1:String) : void
   {
      var _loc3_:UIResearchListItem = null;
      var _loc2_:int = 0;
      while(_loc2_ < this._items.length)
      {
         _loc3_ = this._items[_loc2_];
         if(_loc3_.xmlGroup.@id.toString() == param1)
         {
            this.selectItem(_loc3_);
            return;
         }
         _loc2_++;
      }
   }
   
   private function selectItem(param1:UIResearchListItem) : void
   {
      if(param1 == this._selectedItem)
      {
         return;
      }
      if(this._selectedItem != null)
      {
         this._selectedItem.selected = false;
         this._selectedItem = null;
      }
      this._selectedItem = param1;
      if(this._selectedItem != null)
      {
         this._selectedItem.selected = true;
      }
      this.selectionChanged.dispatch(this,this._selectedItem);
   }
   
   private function onClickItem(param1:MouseEvent) : void
   {
      this.selectItem(UIResearchListItem(param1.currentTarget));
   }
}
