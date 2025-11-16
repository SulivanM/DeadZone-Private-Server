package thelaststand.app.game.gui.chat.commspanel
{
   import com.greensock.TweenMax;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextFieldAutoSize;
   import flash.utils.setTimeout;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.game.gui.UIOnlineStatus;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.chat.ChatSystem;
   
   public class UICommsPanelTabButton extends Sprite
   {
      
      public static const SELECT_TAB:String = "select_tab";
      
      public static const TOGGLE_STATUS:String = "toggle_status";
      
      public var channelId:String;
      
      private var _enabled:Boolean = true;
      
      private var _selected:Boolean;
      
      private var _status:Boolean = false;
      
      private var _container:Sprite;
      
      private var _label:String = "";
      
      private var _customCompactLabel:String = "";
      
      private var _bg:Shape;
      
      private var _pulse:Shape;
      
      private var _content:Sprite;
      
      private var txt_label:BodyTextField;
      
      private var _statusIndicator:UIOnlineStatus;
      
      private var _toggleDelayed:Boolean = false;
      
      private var _compactMode:Boolean = true;
      
      public function UICommsPanelTabButton(param1:String, param2:String)
      {
         super();
         this.channelId = param2;
         buttonMode = true;
         mouseChildren = false;
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         this._container = new Sprite();
         addChild(this._container);
         this._bg = new Shape();
         this._container.addChild(this._bg);
         this._pulse = new Shape();
         this._container.addChild(this._pulse);
         this._pulse.alpha = 0;
         this._content = new Sprite();
         this._container.addChild(this._content);
         this.txt_label = new BodyTextField({
            "color":16777215,
            "compactMode":TextFieldAutoSize.LEFT,
            "size":12,
            "bold":true
         });
         this.txt_label.filters = [new GlowFilter(0,0.8,2,2,5)];
         this._content.addChild(this.txt_label);
         this.txt_label.mouseEnabled = false;
         this._statusIndicator = new UIOnlineStatus();
         this._statusIndicator.status = UIOnlineStatus.STATUS_OFFLINE;
         this._statusIndicator.width = this._statusIndicator.height = 14;
         this._statusIndicator.y = 3;
         this._content.addChild(this._statusIndicator);
         this._statusIndicator.visible = param2 != ChatSystem.CHANNEL_ADMIN || Network.getInstance().playerData.isAdmin;
         this._statusIndicator.buttonMode = true;
         this._statusIndicator.addEventListener(MouseEvent.MOUSE_DOWN,this.onStatusMouseDown,false,0,true);
         this.Label = param1;
         this.setSelected(false);
      }
      
      public function destroy() : void
      {
         removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         if(parent)
         {
            parent.removeChild(this);
         }
      }
      
      public function pulse() : void
      {
         this._pulse.alpha = 0.6;
         TweenMax.to(this._pulse,1,{"alpha":0});
      }
      
      private function setEnabled(param1:Boolean) : void
      {
         this._enabled = param1;
         mouseEnabled = this._enabled && !this._selected;
      }
      
      private function setSelected(param1:Boolean) : void
      {
         this._selected = param1;
         mouseEnabled = this._enabled && !this._selected;
         this.txt_label.alpha = this._selected ? 1 : 0.3;
         this._statusIndicator.alpha = this._selected ? 1 : 0.6;
         this._bg.alpha = this._selected ? 1 : 0.8;
         mouseChildren = this._selected;
         buttonMode = !this._selected;
         this.drawBackground();
      }
      
      public function get Label() : String
      {
         return this._label;
      }
      
      public function set Label(param1:String) : void
      {
         this._label = param1;
         if(!this._compactMode || this._customCompactLabel == "")
         {
            this.UpdateLabel();
         }
      }
      
      public function get CompactLabel() : String
      {
         return this._customCompactLabel;
      }
      
      public function set CompactLabel(param1:String) : void
      {
         this._customCompactLabel = param1;
         if(this._compactMode)
         {
            this.UpdateLabel();
         }
      }
      
      private function UpdateLabel() : void
      {
         var _loc1_:String = null;
         if(!this._compactMode)
         {
            this.txt_label.text = this._label;
            this._statusIndicator.x = this.txt_label.width + 10;
            this._content.x = 12;
         }
         else
         {
            _loc1_ = this._customCompactLabel;
            if(_loc1_ == null || _loc1_ == "")
            {
               _loc1_ = this._label.length > 1 ? this._label.substr(0,1) + "..." : this._label;
            }
            this.txt_label.text = _loc1_;
            this._statusIndicator.x = this.txt_label.width + 2;
            this._content.x = 4;
         }
         this.drawBackground();
      }
      
      private function drawBackground() : void
      {
         var _loc1_:Graphics = this._bg.graphics;
         _loc1_.clear();
         _loc1_.beginFill(3683891,1);
         _loc1_.drawRoundRectComplex(0,0,Math.ceil(this._content.x + this._content.width + 6),this._selected ? 20 : 19,6,6,0,0);
         _loc1_.beginFill(1315860,1);
         _loc1_.drawRoundRectComplex(1,1,this._bg.width - 2,this._bg.height - 1,5,5,0,0);
         _loc1_.endFill();
         _loc1_ = this._pulse.graphics;
         _loc1_.clear();
         _loc1_.beginFill(15597568,1);
         _loc1_.drawRoundRectComplex(1,1,this._bg.width - 2,this._bg.height - 1,5,5,0,0);
         _loc1_.endFill();
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(!this._enabled || this._selected)
         {
            return;
         }
         dispatchEvent(new Event(SELECT_TAB));
      }
      
      private function onStatusMouseDown(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         if(!this._enabled || !this._selected || this._toggleDelayed)
         {
            return;
         }
         this._toggleDelayed = true;
         setTimeout(function():void
         {
            _toggleDelayed = false;
         },5000);
         this.status = !this._status;
         dispatchEvent(new Event(TOGGLE_STATUS));
      }
      
      public function get toggleDelayed() : Boolean
      {
         return this._toggleDelayed;
      }
      
      public function get compactMode() : Boolean
      {
         return this._compactMode;
      }
      
      public function set compactMode(param1:Boolean) : void
      {
         var value:Boolean = param1;
         if(this._compactMode != value)
         {
            this._compactMode = value;
            this.UpdateLabel();
            if(this._compactMode)
            {
               TooltipManager.getInstance().add(this,function():String
               {
                  return Label;
               },null,TooltipDirection.DIRECTION_DOWN);
            }
            else
            {
               TooltipManager.getInstance().remove(this);
            }
         }
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         this.setEnabled(param1);
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this.setSelected(param1);
      }
      
      public function get status() : Boolean
      {
         return this._status;
      }
      
      public function set status(param1:Boolean) : void
      {
         this._status = param1;
         this._statusIndicator.status = this._status ? UIOnlineStatus.STATUS_ONLINE : UIOnlineStatus.STATUS_OFFLINE;
      }
   }
}

