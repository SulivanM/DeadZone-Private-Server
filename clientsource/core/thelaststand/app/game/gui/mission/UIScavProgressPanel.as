package thelaststand.app.game.gui.mission
{
   import flash.display.GradientType;
   import flash.geom.Matrix;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.common.lang.Language;
   
   public class UIScavProgressPanel extends UIComponent
   {
      
      private var _width:int = 86;
      
      private var _height:int = 164;
      
      private var checkpointScav100:ScavProgressPanelLine;
      
      private var lines:Array = new Array();
      
      private var bmp_warTitleBar:UITitleBar;
      
      private var txt_warpts:BodyTextField;
      
      private var _possibleWarPoints:int;
      
      private var _searchableContainers:int;
      
      public function UIScavProgressPanel(param1:int, param2:int)
      {
         super();
         this._searchableContainers = param1;
         this._possibleWarPoints = param2;
         this.checkpointScav100 = new ScavProgressPanelLine(new BmpIconAllianceCheckpointScav100());
         this.lines.push(this.checkpointScav100);
         this.bmp_warTitleBar = new UITitleBar(null,6194996);
         this.bmp_warTitleBar.height = 28;
         this.txt_warpts = new BodyTextField({
            "color":12379027,
            "text":" ",
            "size":14,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.UpdateProgress(0);
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
      
      override public function dispose() : void
      {
         var _loc2_:ScavProgressPanelLine = null;
         super.dispose();
         var _loc1_:int = 0;
         while(_loc1_ < this.lines.length)
         {
            _loc2_ = this.lines[_loc1_];
            _loc2_.dispose();
            _loc1_++;
         }
         this.lines = null;
         this.bmp_warTitleBar.dispose();
         this.bmp_warTitleBar = null;
         this.txt_warpts.dispose();
         this.txt_warpts = null;
      }
      
      override protected function draw() : void
      {
         var _loc5_:ScavProgressPanelLine = null;
         graphics.clear();
         var _loc1_:int = 4;
         var _loc2_:int = 0;
         while(_loc2_ < this.lines.length)
         {
            _loc5_ = this.lines[_loc2_];
            _loc5_.x = 4;
            _loc5_.y = _loc1_;
            addChild(_loc5_);
            _loc1_ += _loc5_.height + 4;
            _loc2_++;
         }
         var _loc3_:Matrix = new Matrix();
         var _loc4_:Array = [0,60,195,255];
         _loc3_.createGradientBox(this._width,this._height,Math.PI * 0.5);
         graphics.beginGradientFill(GradientType.LINEAR,[0,0,0,0],[0,0.5,0.5,0],_loc4_,_loc3_);
         graphics.drawRect(0,0,this._width,_loc1_);
         graphics.endFill();
         this._height = _loc1_;
         if(this._possibleWarPoints > 0)
         {
            this.bmp_warTitleBar.width = this._width;
            this.bmp_warTitleBar.x = 0;
            this.bmp_warTitleBar.y = _loc1_;
            addChild(this.bmp_warTitleBar);
            this.txt_warpts.text = Language.getInstance().getString("map_node_warptsShort",this._possibleWarPoints.toString());
            this.txt_warpts.x = int(this.bmp_warTitleBar.x + (this.bmp_warTitleBar.width - this.txt_warpts.width) * 0.5);
            this.txt_warpts.y = int(this.bmp_warTitleBar.y + (this.bmp_warTitleBar.height - this.txt_warpts.height) * 0.5) + 2;
            addChild(this.txt_warpts);
            this._height = this.bmp_warTitleBar.y + this.bmp_warTitleBar.height;
         }
         else
         {
            if(this.bmp_warTitleBar.parent)
            {
               this.bmp_warTitleBar.parent.removeChild(this.bmp_warTitleBar);
            }
            if(this.txt_warpts.parent)
            {
               this.txt_warpts.parent.removeChild(this.txt_warpts);
            }
         }
      }
      
      public function UpdateProgress(param1:int) : void
      {
         this.checkpointScav100.text = param1 + "/" + this._searchableContainers;
         this.bmp_warTitleBar.alpha = this.txt_warpts.alpha = param1 >= this._searchableContainers ? 1 : 0.3;
      }
   }
}

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.text.AntiAliasType;
import thelaststand.app.display.BodyTextField;

class ScavProgressPanelLine extends Sprite
{
   
   private var _bitmap:Bitmap;
   
   private var _tick:Bitmap;
   
   private var txt_label:BodyTextField;
   
   public function ScavProgressPanelLine(param1:BitmapData)
   {
      super();
      mouseChildren = false;
      graphics.beginFill(0,1);
      graphics.drawRect(0,0,32,32);
      this._bitmap = new Bitmap(param1);
      addChild(this._bitmap);
      this._tick = new Bitmap(new BmpExitZoneOK());
      this._tick.x = int((this._bitmap.width - this._tick.width) * 0.5);
      this._tick.y = int((this._bitmap.height - this._tick.height) * 0.5);
      this._tick.visible = false;
      addChild(this._tick);
      this.txt_label = new BodyTextField({
         "color":10066329,
         "text":" ",
         "size":14,
         "antiAliasType":AntiAliasType.ADVANCED
      });
      this.txt_label.x = this._tick.x + 32 + 4;
      this.txt_label.y = 8;
      addChild(this.txt_label);
   }
   
   public function dispose() : void
   {
      if(this._bitmap.bitmapData != null)
      {
         this._bitmap.bitmapData.dispose();
      }
      this._tick.bitmapData.dispose();
      this.txt_label.dispose();
      if(parent)
      {
         parent.removeChild(this);
      }
   }
   
   public function get text() : String
   {
      return this.txt_label.text;
   }
   
   public function set text(param1:String) : void
   {
      this.txt_label.text = param1;
   }
   
   public function get checked() : Boolean
   {
      return this._tick.visible;
   }
   
   public function set checked(param1:Boolean) : void
   {
      this._tick.visible = param1;
   }
}
