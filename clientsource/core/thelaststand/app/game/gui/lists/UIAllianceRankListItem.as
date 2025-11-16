package thelaststand.app.game.gui.lists
{
   import flash.display.BitmapData;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.common.lang.Language;
   
   public class UIAllianceRankListItem extends UIPagedListItem
   {
      
      private static const BG_COLOR_NORMAL:uint = 3486515;
      
      private static const BG_COLOR_OVER:uint = 4670789;
      
      private static const BG_COLOR_SELECTED:uint = 8138780;
      
      private static const BMP_NEW:BitmapData = new BmpIconNewItem();
      
      private var _rank:int = 0;
      
      private var _alternating:Boolean = false;
      
      private var _category:String;
      
      private var _label:String;
      
      private var _bgColor:ColorTransform = new ColorTransform();
      
      private var mc_background:Sprite;
      
      private var mc_square:Shape;
      
      private var txt_label:BodyTextField;
      
      private var btn_edit:EditRankButton;
      
      public var clickedEdit:Signal = new Signal(UIAllianceRankListItem);
      
      public function UIAllianceRankListItem(param1:Boolean = false)
      {
         super();
         _height = 24;
         _width = 188;
         this.mc_background = new Sprite();
         addChild(this.mc_background);
         this.mc_square = new Shape();
         this.mc_square.graphics.beginFill(16777215,0.25);
         this.mc_square.graphics.drawRect(0,0,6,6);
         this.mc_square.graphics.endFill();
         this.mc_square.y = int((_height - this.mc_square.height) * 0.5);
         this.mc_square.x = int(this.mc_square.y);
         addChild(this.mc_square);
         this.txt_label = new BodyTextField({
            "text":" ",
            "color":11974326,
            "size":13,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_label.x = int(this.mc_square.x * 2 + this.mc_square.width);
         this.txt_label.y = int((_height - this.txt_label.height) * 0.5);
         this.txt_label.mouseEnabled = false;
         addChild(this.txt_label);
         this.draw();
         mouseChildren = true;
         hitArea = this.mc_background;
         mouseOver.add(this.onMouseOver);
         mouseOut.add(this.onMouseOut);
         mouseDown.add(this.onMouseDown);
         if(param1)
         {
            this.btn_edit = new EditRankButton();
            this.btn_edit.onClick.add(this.onEditClicked);
            this.btn_edit.x = int(_width - this.btn_edit.width * 0.5 - 2);
            this.btn_edit.y = int(_height * 0.5);
            addChild(this.btn_edit);
            TooltipManager.getInstance().add(this.btn_edit,Language.getInstance().getString("alliance.editrankname_tooltip"),new Point(0,-int(_height * 0.5)),TooltipDirection.DIRECTION_DOWN);
         }
      }
      
      public function get alternating() : Boolean
      {
         return this._alternating;
      }
      
      public function set alternating(param1:Boolean) : void
      {
         this._alternating = param1;
         this.updateStateDisplay();
      }
      
      public function get rank() : int
      {
         return this._rank;
      }
      
      public function set rank(param1:int) : void
      {
         this._rank = param1;
      }
      
      public function get label() : String
      {
         return this._label;
      }
      
      public function set label(param1:String) : void
      {
         this._label = param1;
         this.txt_label.text = this._label ? this._label.toUpperCase() : "";
      }
      
      override public function set selected(param1:Boolean) : void
      {
         super.selected = param1;
         this.updateStateDisplay();
      }
      
      override public function set width(param1:Number) : void
      {
         _width = param1;
         this.draw();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.txt_label.dispose();
         if(this.btn_edit != null)
         {
            TooltipManager.getInstance().remove(this.btn_edit);
            this.btn_edit.dispose();
         }
      }
      
      private function draw() : void
      {
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginFill(BG_COLOR_NORMAL);
         this.mc_background.graphics.drawRect(0,0,_width,_height);
         this.mc_background.graphics.endFill();
         this.updateLabelPosition();
      }
      
      private function updateLabelPosition() : void
      {
         this.txt_label.maxWidth = int(_width - this.txt_label.x - 6);
         this.txt_label.y = int((_height - this.txt_label.height) * 0.5);
         if(this.btn_edit)
         {
            this.btn_edit.x = int(_width - this.btn_edit.width * 0.5 - 2);
            this.btn_edit.y = int(_height * 0.5);
         }
      }
      
      private function updateStateDisplay() : void
      {
         this._bgColor.color = this.getBackgroundColor();
         if(super.selected)
         {
            this.txt_label.textColor = 16767439;
            this._bgColor.alphaMultiplier = 1;
         }
         else
         {
            this.txt_label.textColor = 11974326;
            this._bgColor.alphaMultiplier = this._alternating ? 0 : 1;
         }
         if(this.btn_edit)
         {
            this.btn_edit.visible = super.selected;
         }
         this.mc_background.transform.colorTransform = this._bgColor;
      }
      
      private function getBackgroundColor() : uint
      {
         return selected ? BG_COLOR_SELECTED : BG_COLOR_NORMAL;
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         this._bgColor.color = BG_COLOR_OVER;
         this._bgColor.alphaMultiplier = 1;
         this.mc_background.transform.colorTransform = this._bgColor;
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         this._bgColor.color = this.getBackgroundColor();
         this._bgColor.alphaMultiplier = this._alternating ? 0 : 1;
         this.mc_background.transform.colorTransform = this._bgColor;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         Audio.sound.play("sound/interface/int-click.mp3");
      }
      
      private function onEditClicked() : void
      {
         this.clickedEdit.dispatch(this);
      }
   }
}

import com.greensock.TweenMax;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import org.osflash.signals.Signal;
import thelaststand.app.audio.Audio;

class EditRankButton extends Sprite
{
   
   private var bmp:Bitmap;
   
   public var onClick:Signal = new Signal();
   
   public function EditRankButton()
   {
      super();
      mouseChildren = false;
      buttonMode = true;
      this.bmp = new Bitmap(new BmpIconEditSurvivorName(),"auto",true);
      this.bmp.x = -int(this.bmp.width * 0.5);
      this.bmp.y = -int(this.bmp.height * 0.5);
      addChild(this.bmp);
      this.bmp.alpha = 0.5;
      addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
      addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
      addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
      addEventListener(MouseEvent.CLICK,this.onMouseClick,false,0,true);
   }
   
   public function dispose() : void
   {
      if(parent)
      {
         parent.removeChild(this);
      }
      this.onClick.removeAll();
      removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
      removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
      removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
      removeEventListener(MouseEvent.CLICK,this.onMouseClick);
   }
   
   private function onRollOver(param1:MouseEvent) : void
   {
      TweenMax.to(this.bmp,0.15,{
         "alpha":0.75,
         "glowFilter":{
            "color":16777215,
            "alpha":0.75,
            "blurX":10,
            "blurY":10,
            "strength":1,
            "quality":2
         }
      });
   }
   
   private function onRollOut(param1:MouseEvent) : void
   {
      TweenMax.to(this.bmp,0.25,{
         "alpha":0.5,
         "glowFilter":{
            "alpha":0,
            "remove":true,
            "overwrite":true
         }
      });
   }
   
   private function onMouseDown(param1:MouseEvent) : void
   {
      Audio.sound.play("sound/interface/int-click.mp3");
   }
   
   private function onMouseClick(param1:MouseEvent) : void
   {
      param1.stopImmediatePropagation();
      this.onClick.dispatch();
   }
}
