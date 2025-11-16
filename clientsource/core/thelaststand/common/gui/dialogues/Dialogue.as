package thelaststand.common.gui.dialogues
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import org.osflash.signals.Signal;
   import thelaststand.common.gui.buttons.AbstractButton;
   
   public class Dialogue
   {
      
      public static const BUTTON_ALIGN_RIGHT:String = "right";
      
      public static const BUTTON_ALIGN_LEFT:String = "left";
      
      public static const BUTTON_ALIGN_CENTER:String = "center";
      
      public static const ALIGN_CENTER:String = "center";
      
      public static const ALIGN_TOP_RIGHT:String = "topRight";
      
      public static const ALIGN_LOWER_RIGHT:String = "lowerRight";
      
      protected var _autoSize:Boolean = true;
      
      protected var _buttonClass:Class = AbstractButton;
      
      protected var _buttonAlign:String = "right";
      
      protected var _buttonSpacing:int = 6;
      
      protected var _buttonYOffset:int = 0;
      
      protected var _minWidth:int = 100;
      
      protected var _minHeight:int = 20;
      
      protected var _padding:int = 8;
      
      protected var _contentOffset:Point = new Point();
      
      private var _buttons:Vector.<AbstractButton>;
      
      private var _content:DisplayObject;
      
      private var _id:String;
      
      private var _sprite:Sprite;
      
      private var _modal:Boolean;
      
      private var _isOpen:Boolean = false;
      
      protected var _width:int = -1;
      
      protected var _height:int = -1;
      
      protected var mc_buttons:Sprite;
      
      public var offset:Point;
      
      public var align:String = "center";
      
      public var priority:int = 0;
      
      public var opened:Signal;
      
      public var closed:Signal;
      
      public var weakReference:Boolean = true;
      
      public function Dialogue(param1:String = null, param2:DisplayObject = null, param3:Boolean = true)
      {
         super();
         this._sprite = new Sprite();
         this._sprite.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
         this._sprite.addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         this._buttons = new Vector.<AbstractButton>();
         this.opened = new Signal(Dialogue);
         this.closed = new Signal(Dialogue);
         this._id = param1;
         this._modal = param3;
         this.content = param2;
         this.offset = new Point();
         DialogueManager.getInstance().addDialogue(this);
      }
      
      public function addButton(param1:String, param2:Boolean = true, param3:Object = null) : AbstractButton
      {
         var _loc5_:String = null;
         if(!param3)
         {
            param3 = {};
         }
         param3.label = param1;
         if(!this.mc_buttons)
         {
            this.mc_buttons = new Sprite();
            this._sprite.addChild(this.mc_buttons);
         }
         var _loc4_:AbstractButton = param3.buttonClass ? new param3.buttonClass() : new this._buttonClass();
         if(param3.width != undefined)
         {
            _loc4_.autoSize = false;
            _loc4_.width = Number(param3.width);
         }
         else
         {
            _loc4_.autoSize = true;
         }
         if(param2)
         {
            _loc4_.clicked.addOnce(this.onClickButton);
         }
         for(_loc5_ in param3)
         {
            if(_loc4_.hasOwnProperty(_loc5_))
            {
               _loc4_[_loc5_] = param3[_loc5_];
            }
         }
         this.mc_buttons.addChild(_loc4_);
         this._buttons.push(_loc4_);
         this.updateElements();
         if(this._sprite.stage)
         {
            this.draw();
         }
         return _loc4_;
      }
      
      public function close() : void
      {
         if(!this._isOpen)
         {
            return;
         }
         this._isOpen = false;
         this.closed.dispatch(this);
      }
      
      public function dispose() : void
      {
         var _loc1_:AbstractButton = null;
         if(this._sprite.parent)
         {
            this._sprite.parent.removeChild(this._sprite);
         }
         if(Boolean(this._content) && Boolean(this._content.parent))
         {
            this._content.parent.removeChild(this._content);
            this._content = null;
         }
         for each(_loc1_ in this._buttons)
         {
            _loc1_.dispose();
         }
         this._buttons = null;
         this.opened.removeAll();
         this.closed.removeAll();
         this._isOpen = false;
         this._sprite.removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this._sprite.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
         DialogueManager.getInstance().removeDialogue(this);
      }
      
      public function getButton(param1:int) : AbstractButton
      {
         if(this._buttons.length == 0 || param1 < 0 || param1 >= this._buttons.length)
         {
            return null;
         }
         return this._buttons[param1];
      }
      
      public function getButtonByLabel(param1:String) : AbstractButton
      {
         var _loc2_:AbstractButton = null;
         for each(_loc2_ in this._buttons)
         {
            if(Boolean(_loc2_.hasOwnProperty("label")) && _loc2_["label"] == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function open() : void
      {
         if(this._isOpen)
         {
            return;
         }
         this._isOpen = true;
         this.opened.dispatch(this);
      }
      
      public function removeButton(param1:int) : AbstractButton
      {
         if(this._buttons.length == 0 || param1 < 0 || param1 >= this._buttons.length)
         {
            return null;
         }
         var _loc2_:AbstractButton = this._buttons.splice(param1,1)[0];
         if(this.mc_buttons.contains(_loc2_))
         {
            this.mc_buttons.removeChild(_loc2_);
         }
         this.updateElements();
         return _loc2_;
      }
      
      public function removeButtonByLabel(param1:String) : AbstractButton
      {
         var _loc2_:AbstractButton = this.getButtonByLabel(param1);
         if(!_loc2_)
         {
            return null;
         }
         var _loc3_:int = int(this._buttons.indexOf(_loc2_));
         if(_loc3_ > -1)
         {
            this._buttons.splice(_loc3_,1);
         }
         if(this.mc_buttons.contains(_loc2_))
         {
            this.mc_buttons.removeChild(_loc2_);
         }
         this.updateElements();
         return _loc2_;
      }
      
      protected function updateElements() : void
      {
         var _loc6_:Rectangle = null;
         var _loc7_:Sprite = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = int(this._buttons.length);
         while(_loc2_ < _loc3_)
         {
            _loc7_ = this._buttons[_loc2_];
            _loc7_.x = _loc1_;
            _loc1_ += int(_loc7_.width + this._buttonSpacing);
            _loc2_++;
         }
         var _loc4_:int = this._padding;
         var _loc5_:int = this._padding;
         if(this._content)
         {
            this._content.x = this._padding + this._contentOffset.x;
            this._content.y = this._padding + this._contentOffset.y;
            _loc6_ = this._content.getBounds(this._content);
         }
         if(this._autoSize)
         {
            this._width = this._contentOffset.x + this._padding * 2 + Math.max(_loc6_ != null ? _loc6_.width : 0,this.mc_buttons != null ? this.mc_buttons.width : 0,this._minWidth);
            this._height = this._contentOffset.y + this._padding * 2 + Math.max(_loc6_ != null ? _loc6_.height : 0,this._minHeight) + (this.mc_buttons != null ? Math.max(0,this.mc_buttons.height + this._buttonYOffset) + this._padding : 0);
         }
         if(this.mc_buttons != null)
         {
            this.mc_buttons.y = int(this._height - this._padding - this.mc_buttons.height + 2);
            switch(this._buttonAlign)
            {
               case BUTTON_ALIGN_LEFT:
                  this.mc_buttons.x = this._padding * 0.5;
                  break;
               case BUTTON_ALIGN_CENTER:
                  this.mc_buttons.x = int(this._padding * 0.5 + (this._width - this.mc_buttons.width) * 0.5 - 2);
                  break;
               case BUTTON_ALIGN_RIGHT:
               default:
                  this.mc_buttons.x = int(this._width - this._padding * 0.5 - this.mc_buttons.width);
            }
         }
      }
      
      protected function draw() : void
      {
         this._sprite.graphics.clear();
         this._sprite.graphics.beginFill(2236962);
         this._sprite.graphics.drawRect(0,0,this._width,this._height);
         this._sprite.graphics.endFill();
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.updateElements();
         this.draw();
      }
      
      private function onClickButton(param1:MouseEvent) : void
      {
         this.close();
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      public function get buttonAlign() : String
      {
         return this._buttonAlign;
      }
      
      public function set buttonAlign(param1:String) : void
      {
         this._buttonAlign = param1;
      }
      
      protected function get content() : DisplayObject
      {
         return this._content;
      }
      
      protected function set content(param1:DisplayObject) : void
      {
         if(Boolean(this._content) && Boolean(this._content.parent))
         {
            this._content.parent.removeChild(this._content);
         }
         this._content = param1;
         if(!this._content)
         {
            return;
         }
         this._sprite.addChild(this._content);
         this.updateElements();
         if(this._sprite.stage)
         {
            this.draw();
         }
      }
      
      public function get defaultButtonClass() : Class
      {
         return this._buttonClass;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get sprite() : Sprite
      {
         return this._sprite;
      }
      
      public function get width() : Number
      {
         return this._width;
      }
      
      public function get height() : Number
      {
         return this._height;
      }
      
      public function get modal() : Boolean
      {
         return this._modal;
      }
      
      public function set modal(param1:Boolean) : void
      {
         this._modal = param1;
      }
      
      public function get isOpen() : Boolean
      {
         return this._isOpen;
      }
   }
}

