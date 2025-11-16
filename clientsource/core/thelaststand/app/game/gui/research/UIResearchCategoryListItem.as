package thelaststand.app.game.gui.research
{
   import com.deadreckoned.threshold.display.Color;
   import com.exileetiquette.math.MathUtils;
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import flash.display.BitmapData;
   import flash.display.BlendMode;
   import flash.display.LineScaleMode;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.text.AntiAliasType;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.data.RequirementTypes;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.research.ResearchState;
   import thelaststand.app.game.data.research.ResearchSystem;
   import thelaststand.app.game.data.research.ResearchTask;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.network.Network;
   import thelaststand.common.lang.Language;
   
   public class UIResearchCategoryListItem extends UIComponent
   {
      
      private static var bmdHeaderBackground:BitmapData = new BmpResearchBarBg();
      
      private var _xml:XML;
      
      private var _category:String;
      
      private var _width:int = 340;
      
      private var _headerHeight:int = 50;
      
      private var _expandedHeight:int = 0;
      
      private var _researchState:ResearchState;
      
      private var _expanded:Boolean;
      
      private var _invalidListItems:Boolean = true;
      
      private var _listItems:Vector.<UIResearchListItem> = new Vector.<UIResearchListItem>();
      
      private var _overlay_y:Number;
      
      private var _selectedItem:UIResearchListItem;
      
      private var _currentTaskItem:UIResearchListItem;
      
      private var txt_title:BodyTextField;
      
      private var txt_percTotal:BodyTextField;
      
      private var txt_researched:BodyTextField;
      
      private var mc_header:Sprite;
      
      private var mc_bgOverlay:Shape;
      
      private var mc_listContainer:Sprite;
      
      private var mc_progress:Shape;
      
      private var mc_texture:Shape;
      
      private var ui_image:UIImage;
      
      public var expandedStateChanged:Signal = new Signal(UIResearchCategoryListItem,Boolean);
      
      public var headerClicked:Signal = new Signal(UIResearchCategoryListItem);
      
      public var selectionChanged:Signal = new Signal(UIResearchCategoryListItem,UIResearchListItem);
      
      public function UIResearchCategoryListItem()
      {
         this._overlay_y = Math.random() * bmdHeaderBackground.height;
         super();
         this._researchState = Network.getInstance().playerData.researchState;
         this.mc_listContainer = new Sprite();
         addChild(this.mc_listContainer);
         this.mc_header = new Sprite();
         addChild(this.mc_header);
         this.mc_progress = new Shape();
         this.mc_header.addChild(this.mc_progress);
         this.mc_bgOverlay = new Shape();
         this.mc_header.addChild(this.mc_bgOverlay);
         this.ui_image = new UIImage(76,48,0,0,true);
         this.mc_header.addChild(this.ui_image);
         this.txt_title = new BodyTextField({
            "color":16579836,
            "size":20,
            "bold":true,
            "filters":[Effects.STROKE],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_title.text = " ";
         this.mc_header.addChild(this.txt_title);
         this.txt_percTotal = new BodyTextField({
            "color":16777215,
            "size":22,
            "bold":true,
            "filters":[Effects.STROKE],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_percTotal.text = "0%";
         this.mc_header.addChild(this.txt_percTotal);
         this.txt_researched = new BodyTextField({
            "color":11842740,
            "size":10,
            "bold":true,
            "filters":[Effects.STROKE],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_researched.text = Language.getInstance().getString("research_researched");
         this.mc_header.addChild(this.txt_researched);
         this.mc_header.mouseChildren = false;
         this.mc_header.addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         this.mc_header.addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         this.mc_header.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         this.mc_header.addEventListener(MouseEvent.CLICK,this.onClickHeader,false,0,true);
      }
      
      public function get category() : String
      {
         return this._category;
      }
      
      public function set category(param1:String) : void
      {
         this._category = param1;
         this._xml = ResearchSystem.getCategoryXML(this._category);
         this._invalidListItems = true;
         this.createListItems();
         invalidate();
      }
      
      public function get isExpanded() : Boolean
      {
         return this._expanded;
      }
      
      public function set isExpanded(param1:Boolean) : void
      {
         if(param1)
         {
            this.expand();
         }
         else
         {
            this.collapse();
         }
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
         return this._expanded ? this._expandedHeight : this._headerHeight;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIResearchListItem = null;
         super.dispose();
         removeEventListener(Event.ENTER_FRAME,this.updateCurrentTaskItem);
         this.txt_title.dispose();
         this.txt_percTotal.dispose();
         this.txt_researched.dispose();
         this.ui_image.dispose();
         for each(_loc1_ in this._listItems)
         {
            _loc1_.dispose();
         }
         this._listItems.length = 0;
      }
      
      public function expand() : void
      {
         if(this._expanded)
         {
            return;
         }
         this._expanded = true;
         this.mc_listContainer.visible = true;
         this.expandedStateChanged.dispatch(this,this._expanded);
      }
      
      public function collapse() : void
      {
         if(!this._expanded)
         {
            return;
         }
         this._expanded = false;
         this.mc_listContainer.visible = false;
         this.expandedStateChanged.dispatch(this,this._expanded);
      }
      
      public function toggleExpanded() : Boolean
      {
         if(this._expanded)
         {
            this.collapse();
         }
         else
         {
            this.expand();
         }
         this.expandedStateChanged.dispatch(this,this._expanded);
         return this._expanded;
      }
      
      public function deselect() : void
      {
         var _loc2_:UIResearchListItem = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._listItems.length)
         {
            _loc2_ = this._listItems[_loc1_];
            _loc2_.selected = false;
            _loc1_++;
         }
         if(this._selectedItem != null)
         {
            this._selectedItem = null;
         }
      }
      
      public function selectByGroup(param1:String) : void
      {
         if(param1 == null)
         {
            this.deselect();
         }
         else
         {
            this._selectedItem = this.getItemByGroup(param1);
            if(this._selectedItem != null)
            {
               this._selectedItem.selected = true;
               this.expand();
            }
         }
         this.selectionChanged.dispatch(this,this._selectedItem);
      }
      
      public function selectByIndex(param1:int) : void
      {
         if(this._listItems.length == 0)
         {
            return;
         }
         this.selectByItem(this._listItems[param1]);
      }
      
      public function selectByItem(param1:UIResearchListItem) : void
      {
         if(this._selectedItem != null && this._selectedItem == param1)
         {
            return;
         }
         if(this._selectedItem != null)
         {
            this._selectedItem.selected = false;
         }
         var _loc2_:int = int(this._listItems.indexOf(param1));
         if(_loc2_ <= -1)
         {
            this.deselect();
            return;
         }
         this._selectedItem = param1;
         this._selectedItem.selected = true;
         this.selectionChanged.dispatch(this,this._selectedItem);
      }
      
      private function getItemByGroup(param1:String) : UIResearchListItem
      {
         var _loc3_:UIResearchListItem = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._listItems.length)
         {
            _loc3_ = this._listItems[_loc2_];
            if(_loc3_.xmlGroup.@id.toString() == param1)
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      override protected function draw() : void
      {
         var _loc1_:uint = 0;
         _loc1_ = Color.hexToColor(this._xml.@color.toString());
         var _loc2_:Number = this._researchState.getCategoryPrecentage(this._category);
         if(this._invalidListItems)
         {
            this.createListItems();
         }
         this.mc_header.graphics.clear();
         this.mc_header.graphics.lineStyle(1,_loc1_,1,true,LineScaleMode.NONE);
         this.mc_header.graphics.beginFill(2302755);
         this.mc_header.graphics.drawRect(0,0,this._width,this._headerHeight);
         this.mc_header.graphics.endFill();
         this.mc_progress.graphics.clear();
         this.mc_progress.graphics.beginFill(Color.scale(_loc1_,0.9),1);
         this.mc_progress.graphics.drawRect(0,0,this._width * _loc2_,this._headerHeight);
         this.mc_progress.graphics.endFill();
         var _loc3_:Matrix = new Matrix();
         _loc3_.createBox(this._width / bmdHeaderBackground.width,1,0,0,this._overlay_y);
         this.mc_bgOverlay.graphics.clear();
         this.mc_bgOverlay.graphics.beginBitmapFill(bmdHeaderBackground,_loc3_,true,true);
         this.mc_bgOverlay.graphics.drawRect(1,1,this.mc_header.width - 2,this.mc_header.height - 2);
         this.mc_bgOverlay.graphics.endFill();
         this.mc_bgOverlay.blendMode = BlendMode.OVERLAY;
         this.ui_image.x = this.ui_image.y = 1;
         this.ui_image.uri = "images/ui/research-" + this._category + ".png";
         this.txt_title.text = Language.getInstance().getString("research_categories." + this._category + ".name").toUpperCase();
         this.txt_title.x = 80;
         this.txt_title.y = int((this._headerHeight - this.txt_title.height) * 0.5);
         this.txt_percTotal.text = NumberFormatter.format(Math.round(_loc2_ * 100),0) + "%";
         this.txt_percTotal.textColor = _loc1_;
         this.txt_percTotal.x = int(this._width - this.txt_percTotal.width - 10);
         this.txt_researched.x = int(this._width - this.txt_researched.width - 10);
         var _loc4_:int = -6;
         var _loc5_:int = int(this.txt_percTotal.height + this.txt_researched.height + _loc4_);
         this.txt_percTotal.y = int((this._headerHeight - _loc5_) * 0.5);
         this.txt_researched.y = int(this.txt_percTotal.y + this.txt_percTotal.height + _loc4_);
         this.mc_listContainer.x = 0;
         this.mc_listContainer.y = int(this._headerHeight + 8);
         this.mc_listContainer.visible = this._expanded;
         this.updateListItems();
      }
      
      private function getNextLevel(param1:String, param2:String) : int
      {
         var _loc3_:int = Network.getInstance().playerData.researchState.getLevel(param1,param2);
         var _loc4_:int = ResearchSystem.getMaxLevel(param1,param2);
         return Math.min(_loc3_ + 1,_loc4_);
      }
      
      private function updateListItems() : void
      {
         var currentTask:ResearchTask;
         var ty:int;
         var i:int;
         var item:UIResearchListItem = null;
         var group:String = null;
         var currentLevel:int = 0;
         var maxLevel:int = 0;
         var xmlLevel:XML = null;
         this._currentTaskItem = null;
         removeEventListener(Event.ENTER_FRAME,this.updateCurrentTaskItem);
         currentTask = Network.getInstance().playerData.researchState.currentTask;
         ty = 0;
         i = 0;
         while(i < this._listItems.length)
         {
            item = this._listItems[i];
            item.width = this._width;
            item.y = ty;
            group = item.xmlGroup.@id.toString();
            currentLevel = Network.getInstance().playerData.researchState.getLevel(this.category,group);
            maxLevel = ResearchSystem.getMaxLevel(this.category,group);
            item.level = Math.min(currentLevel + 1,maxLevel);
            if(currentLevel >= maxLevel)
            {
               item.state = UIResearchListItem.STATE_COMPLETED;
               item.progress = 1;
               item.progressColor = 2697513;
            }
            else if(currentTask != null && this._category == currentTask.category && group == currentTask.group)
            {
               item.state = UIResearchListItem.STATE_RESEARCHING;
               item.progress = currentTask.progress;
               item.progressColor = 537931;
               this._currentTaskItem = item;
            }
            else
            {
               xmlLevel = item.xmlGroup.level.(@n == item.level.toString())[0];
               if(!Network.getInstance().playerData.meetsRequirements(xmlLevel.req.children(),RequirementTypes.NotItemsResources))
               {
                  item.state = UIResearchListItem.STATE_UNAVAILABLE;
               }
               else
               {
                  item.state = UIResearchListItem.STATE_AVAILABLE;
               }
               item.progress = MathUtils.clamp(currentLevel / maxLevel,0,1);
               item.progressColor = 2697513;
            }
            item.redraw();
            ty += item.height + 2;
            i++;
         }
         this._expandedHeight = int(this.mc_listContainer.y + ty);
         if(this._currentTaskItem != null)
         {
            addEventListener(Event.ENTER_FRAME,this.updateCurrentTaskItem,false,0,true);
         }
      }
      
      private function createListItems() : void
      {
         var _loc1_:UIResearchListItem = null;
         var _loc2_:XMLList = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         for each(_loc1_ in this._listItems)
         {
            _loc1_.dispose();
         }
         this._listItems.length = 0;
         _loc2_ = this._xml.group;
         _loc3_ = int(_loc2_.length());
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc1_ = new UIResearchListItem();
            _loc1_.addEventListener(MouseEvent.CLICK,this.onClickItem,false,0,true);
            _loc1_.xmlGroup = _loc2_[_loc4_];
            _loc1_.level = this.getNextLevel(this._category,_loc1_.xmlGroup.@id.toString());
            this.mc_listContainer.addChild(_loc1_);
            this._listItems.push(_loc1_);
            _loc4_++;
         }
         this._invalidListItems = false;
      }
      
      private function updateCurrentTaskItem(param1:Event) : void
      {
         var _loc2_:ResearchTask = null;
         if(this._currentTaskItem != null)
         {
            _loc2_ = Network.getInstance().playerData.researchState.currentTask;
            if(_loc2_ != null)
            {
               this._currentTaskItem.progress = _loc2_.progress;
               this._currentTaskItem.progressColor = 537931;
            }
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         Audio.sound.play("sound/interface/int-over.mp3");
         TweenMax.to(this.mc_header,0,{
            "colorTransform":{"exposure":1.1},
            "overwrite":true
         });
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         TweenMax.to(this.mc_header,0.25,{
            "colorTransform":{"exposure":1},
            "overwrite":true
         });
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         Audio.sound.play("sound/interface/int-click.mp3");
         TweenMax.to(this.mc_header,0,{"colorTransform":{"exposure":1.5}});
         TweenMax.to(this.mc_header,0.25,{
            "delay":0.01,
            "colorTransform":{"exposure":1.1}
         });
      }
      
      private function onClickHeader(param1:MouseEvent) : void
      {
         this.headerClicked.dispatch(this);
      }
      
      private function onClickItem(param1:MouseEvent) : void
      {
         var _loc2_:UIResearchListItem = UIResearchListItem(param1.currentTarget);
         this.selectByItem(_loc2_);
      }
   }
}

