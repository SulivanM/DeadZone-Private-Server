package thelaststand.app.game.gui.store
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import thelaststand.app.game.data.GameResources;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.common.lang.Language;
   
   public class UIStoreResourcePage extends Sprite
   {
      
      private const PANEL_SPACING:int = 6;
      
      private var _buttons:Vector.<PushButton>;
      
      private var _resources:Vector.<String>;
      
      private var _panelY:int;
      
      private var _panelsByResource:Dictionary;
      
      private var _selectedResource:String;
      
      private var _currentPanel:UIStoreResourcePanel;
      
      private var _width:int;
      
      private var _height:int;
      
      public function UIStoreResourcePage(param1:int, param2:int)
      {
         var _loc9_:String = null;
         var _loc10_:PushButton = null;
         super();
         this._width = param1;
         this._height = param2;
         this._buttons = new Vector.<PushButton>();
         this._resources = new Vector.<String>();
         this._panelsByResource = new Dictionary(true);
         var _loc3_:Array = GameResources.getResourceList();
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc9_ = _loc3_[_loc4_];
            if(_loc9_ != GameResources.CASH)
            {
               _loc10_ = new PushButton(Language.getInstance().getString("items." + _loc9_));
               _loc10_.clicked.add(this.onClickResourceButton);
               _loc10_.data = _loc9_;
               this._buttons.push(_loc10_);
               this._resources.push(_loc9_);
            }
            _loc4_++;
         }
         var _loc5_:int = 4;
         var _loc6_:int = 0;
         var _loc7_:int = 16;
         var _loc8_:int = (this._width - _loc5_ * 2 - _loc7_ * (this._buttons.length - 1)) / this._buttons.length;
         _loc4_ = 0;
         while(_loc4_ < this._buttons.length)
         {
            _loc10_ = this._buttons[_loc4_];
            _loc10_.autoSize = false;
            _loc10_.width = _loc8_;
            _loc10_.x = _loc5_;
            _loc10_.y = _loc6_;
            _loc5_ += int(_loc10_.width + 16);
            addChild(_loc10_);
            _loc4_++;
         }
         this._panelY = int(_loc10_.y + _loc10_.height + 12);
         this.selectResource(String(this._buttons[0].data));
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         var _loc1_:int = 0;
         while(_loc1_ < this._buttons.length)
         {
            this._buttons[_loc1_].dispose();
            _loc1_++;
         }
      }
      
      public function selectResource(param1:String) : void
      {
         var _loc4_:PushButton = null;
         if(param1 == this._selectedResource)
         {
            return;
         }
         if(this._selectedResource != null)
         {
            _loc4_ = this.getButtonByData(this._selectedResource);
            if(_loc4_ != null)
            {
               _loc4_.selected = false;
            }
         }
         if(this._currentPanel != null)
         {
            if(this._currentPanel.parent != null)
            {
               this._currentPanel.parent.removeChild(this._currentPanel);
            }
         }
         this._selectedResource = param1;
         var _loc2_:PushButton = this.getButtonByData(this._selectedResource);
         _loc2_.selected = true;
         var _loc3_:UIStoreResourcePanel = this._panelsByResource[this._selectedResource];
         if(_loc3_ == null)
         {
            _loc3_ = new UIStoreResourcePanel(this._selectedResource);
            this._panelsByResource[this._selectedResource] = _loc3_;
            _loc3_.y = this._panelY;
            _loc3_.width = this._width;
            _loc3_.height = int(this._height - _loc3_.y);
            _loc3_.redraw();
         }
         this._currentPanel = _loc3_;
         addChild(this._currentPanel);
      }
      
      private function getButtonByData(param1:*) : PushButton
      {
         var _loc3_:PushButton = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._buttons.length)
         {
            _loc3_ = this._buttons[_loc2_];
            if(_loc3_.data == param1)
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      private function onClickResourceButton(param1:MouseEvent) : void
      {
         var _loc2_:PushButton = PushButton(param1.currentTarget);
         this.selectResource(String(_loc2_.data));
      }
   }
}

