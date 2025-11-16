package thelaststand.app.game.gui.research
{
   import com.exileetiquette.math.MathUtils;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.utils.setTimeout;
   import org.osflash.signals.Signal;
   import thelaststand.app.core.Settings;
   import thelaststand.app.game.data.research.ResearchSystem;
   import thelaststand.app.game.gui.UIScrollBar;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.resources.ResourceManager;
   
   public class UIResearchCategoryList extends UIComponent
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var _padding:int = 8;
      
      private var _items:Vector.<UIResearchCategoryListItem>;
      
      private var _scrollRect:Rectangle;
      
      private var _contentHeight:int;
      
      private var mc_mask:Sprite;
      
      private var mc_content:Sprite;
      
      private var ui_scrollbar:UIScrollBar;
      
      public var selectionChanged:Signal;
      
      public function UIResearchCategoryList()
      {
         var xmlCats:XMLList;
         var catNode:XML = null;
         var item:UIResearchCategoryListItem = null;
         this._items = new Vector.<UIResearchCategoryListItem>();
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
            item = new UIResearchCategoryListItem();
            item.category = catNode.@id.toString();
            item.isExpanded = Settings.getInstance().getData("research:" + item.category,false);
            item.expandedStateChanged.add(this.onCategoryExpandedStateChanged);
            item.headerClicked.add(this.onCategoryHeaderClicked);
            item.selectionChanged.add(this.onCategorySelectionChanged);
            this.mc_content.addChild(item);
            this._items.push(item);
         }
         this._items.sort(function(param1:UIResearchCategoryListItem, param2:UIResearchCategoryListItem):int
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
         var _loc2_:UIResearchCategoryListItem = null;
         this._contentHeight = 0;
         var _loc1_:int = 0;
         while(_loc1_ < this._items.length)
         {
            _loc2_ = this._items[_loc1_];
            this._contentHeight += _loc2_.height;
            if(_loc1_ < this._items.length - 1)
            {
               this._contentHeight += this._padding + (_loc2_.isExpanded ? 10 : 0);
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
         var _loc1_:UIResearchCategoryListItem = null;
         super.dispose();
         for each(_loc1_ in this._items)
         {
            _loc1_.dispose();
         }
      }
      
      public function selectFirst() : void
      {
         if(this._items.length == 0)
         {
            return;
         }
         var _loc1_:UIResearchCategoryListItem = this._items[0];
         _loc1_.selectByIndex(0);
      }
      
      public function select(param1:String, param2:String) : void
      {
         var _loc4_:UIResearchCategoryListItem = null;
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
         var _loc4_:UIResearchCategoryListItem = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this._items.length)
         {
            _loc4_ = this._items[_loc3_];
            _loc4_.y = _loc2_;
            _loc4_.width = this._scrollRect.width - this._padding;
            if(param1)
            {
               _loc4_.redraw();
            }
            _loc2_ += _loc4_.height + this._padding + (_loc4_.isExpanded ? 10 : 0);
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
      
      private function onCategoryHeaderClicked(param1:UIResearchCategoryListItem) : void
      {
         param1.toggleExpanded();
      }
      
      private function onCategorySelectionChanged(param1:UIResearchCategoryListItem, param2:UIResearchListItem) : void
      {
         var _loc4_:UIResearchCategoryListItem = null;
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
      
      private function fitItemToDisplay(param1:UIResearchCategoryListItem) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Rectangle = null;
         var _loc4_:Rectangle = null;
         this.calculateContentHeight();
         if(this._contentHeight <= this._scrollRect.height)
         {
            this.ui_scrollbar.value = 0;
         }
         else
         {
            _loc2_ = this.mc_content.y;
            _loc3_ = param1.getBounds(this.mc_content);
            _loc4_ = param1.getBounds(this);
            if(_loc4_.top < this._scrollRect.top)
            {
               _loc2_ = _loc3_.top;
            }
            else if(_loc4_.bottom > this._scrollRect.bottom)
            {
               _loc2_ = this._scrollRect.height - (param1.y + param1.height);
            }
            this.ui_scrollbar.value = Math.abs(Math.round(_loc2_)) / (this._contentHeight - this._scrollRect.height);
         }
         this.updateContentPosition();
      }
      
      private function onCategoryExpandedStateChanged(param1:UIResearchCategoryListItem, param2:Boolean) : void
      {
         var category:String = null;
         var item:UIResearchCategoryListItem = param1;
         var expanded:Boolean = param2;
         if(item == null)
         {
            return;
         }
         this.updateListItemPositions();
         this.fitItemToDisplay(item);
         category = item.category;
         setTimeout(function():void
         {
            Settings.getInstance().setData("research:" + category,expanded,true);
         },1000);
      }
   }
}

