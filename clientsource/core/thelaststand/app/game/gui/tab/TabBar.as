package thelaststand.app.game.gui.tab
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   
   public class TabBar extends Sprite
   {
      
      public static const ALIGN_LEFT:String = "left";
      
      public static const ALIGN_RIGHT:String = "right";
      
      private var _btns:Vector.<TabBarButton> = new Vector.<TabBarButton>();
      
      private var _btnsById:Dictionary = new Dictionary(true);
      
      private var _align:String;
      
      private var _selected:TabBarButton;
      
      private var _height:Number;
      
      public var onChange:Signal;
      
      public function TabBar(param1:String = "left")
      {
         super();
         var _loc2_:TabBarButton = new TabBarButton("temp","dummy");
         this._height = _loc2_.height;
         _loc2_.dispose();
         this.onChange = new Signal(String);
         this._align = param1;
      }
      
      public function dispose(param1:Boolean = true) : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.removeAll(param1);
         this.onChange.removeAll();
         this._btnsById = null;
         this._btns = null;
      }
      
      public function addButton(param1:TabBarButton) : void
      {
         this.addButtonAt(param1,this._btns.length);
      }
      
      public function addButtonAt(param1:TabBarButton, param2:int) : void
      {
         if(this._btnsById[param1.id] != null)
         {
            this.removeButton(param1);
         }
         if(param2 < 0)
         {
            param2 = 0;
         }
         if(param2 >= this._btns.length)
         {
            this._btns.push(param1);
         }
         else
         {
            this._btns.splice(param2,0,param1);
         }
         param1.clicked.add(this.onButtonClick);
         addChild(param1);
         this.updateLayout();
      }
      
      public function removeButtonById(param1:String) : void
      {
         var _loc2_:TabBarButton = this._btnsById[param1];
         if(_loc2_ == null)
         {
            return;
         }
         this.removeButton(_loc2_);
      }
      
      public function removeButton(param1:TabBarButton) : void
      {
         var _loc2_:int = int(this._btns.indexOf(param1));
         if(_loc2_ == -1)
         {
            return;
         }
         if(param1.parent)
         {
            param1.parent.removeChild(param1);
         }
         delete this._btnsById[param1.id];
         this._btns.splice(_loc2_,1);
         if(this._selected == param1)
         {
            this.setSelection(null);
         }
         this.updateLayout();
      }
      
      public function removeAll(param1:Boolean = true) : void
      {
         var _loc2_:TabBarButton = null;
         while(this._btns.length > 0)
         {
            _loc2_ = this._btns.pop();
            if(_loc2_.parent)
            {
               _loc2_.parent.removeChild(_loc2_);
            }
            if(param1)
            {
               _loc2_.dispose();
            }
         }
         this._btns.length = 0;
         this._btnsById = new Dictionary(true);
         this.setSelection(null);
      }
      
      private function updateLayout() : void
      {
         var _loc3_:TabBarButton = null;
         var _loc1_:TabBarButton = null;
         var _loc2_:int = 5;
         for each(_loc3_ in this._btns)
         {
            if(this._align == ALIGN_RIGHT)
            {
               _loc3_.x = _loc1_ ? _loc1_.x - _loc3_.width + _loc2_ : -_loc3_.width;
            }
            else
            {
               _loc3_.x = _loc1_ ? _loc1_.x + _loc1_.width - _loc2_ : 0;
            }
            setChildIndex(_loc3_,_loc1_ ? getChildIndex(_loc1_) : 0);
            _loc1_ = _loc3_;
         }
         if(this._selected)
         {
            addChild(this._selected);
         }
      }
      
      private function onButtonClick(param1:MouseEvent) : void
      {
         this.setSelection(TabBarButton(param1.target));
      }
      
      private function setSelection(param1:TabBarButton) : void
      {
         if(param1 == this._selected)
         {
            return;
         }
         if(this._selected)
         {
            this._selected.selected = false;
         }
         this._selected = param1;
         if(this._selected)
         {
            this._selected.selected = true;
         }
         this.onChange.dispatch(param1 ? param1.id : "");
         this.updateLayout();
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
      
      public function get btnCount() : uint
      {
         return this._btns.length;
      }
      
      public function get selectedIndex() : int
      {
         return this._selected ? int(this._btns.indexOf(this._selected)) : -1;
      }
      
      public function set selectedIndex(param1:int) : void
      {
         if(param1 < 0 || param1 >= this._btns.length)
         {
            this.setSelection(null);
         }
         else
         {
            this.setSelection(this._btns[param1]);
         }
      }
      
      public function get selectedId() : String
      {
         return this._selected ? this._selected.id : "";
      }
      
      public function set selectedId(param1:String) : void
      {
         this.setSelection(this._btnsById[param1]);
      }
      
      public function get selected() : TabBarButton
      {
         return this._selected;
      }
      
      public function set selected(param1:TabBarButton) : void
      {
         if(this._btns.indexOf(param1) == -1)
         {
            this.setSelection(null);
         }
         else
         {
            this.setSelection(param1);
         }
      }
   }
}

