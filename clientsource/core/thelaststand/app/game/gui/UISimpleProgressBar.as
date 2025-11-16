package thelaststand.app.game.gui
{
   import flash.display.Shape;
   import thelaststand.app.gui.UIComponent;
   
   public class UISimpleProgressBar extends UIComponent
   {
      
      private var _colorBar:uint = 15597568;
      
      private var _colorTrack:uint = 4210752;
      
      private var _colorBorder:uint = 0;
      
      private var _width:int = 26;
      
      private var _height:int = 3;
      
      private var _progress:Number = 0;
      
      private var _invalid:Boolean = true;
      
      private var mc_track:Shape;
      
      private var mc_bar:Shape;
      
      private var mc_bg:Shape;
      
      public function UISimpleProgressBar(param1:uint = 15597568, param2:uint = 4210752, param3:uint = 0)
      {
         super();
         this._colorBar = param1;
         this._colorTrack = param2;
         this._colorBorder = param3;
         this.mc_bg = new Shape();
         this.mc_track = new Shape();
         this.mc_bar = new Shape();
         addChild(this.mc_bg);
         addChild(this.mc_track);
         addChild(this.mc_bar);
      }
      
      override protected function draw() : void
      {
         scaleX = scaleY = 1;
         this.mc_bg.graphics.clear();
         this.mc_bg.graphics.beginFill(this._colorBorder);
         this.mc_bg.graphics.drawRect(-1,-1,this._width + 2,this._height + 2);
         this.mc_bg.graphics.endFill();
         this.mc_track.graphics.clear();
         this.mc_track.graphics.beginFill(this._colorTrack);
         this.mc_track.graphics.drawRect(0,0,this._width,this._height);
         this.mc_track.graphics.endFill();
         this.mc_bar.scaleX = 1;
         this.mc_bar.graphics.clear();
         this.mc_bar.graphics.beginFill(this._colorBar);
         this.mc_bar.graphics.drawRect(0,0,this._width,this._height);
         this.mc_bar.graphics.endFill();
         this.mc_bar.scaleX = this._progress;
      }
      
      public function get colorBar() : uint
      {
         return this._colorBar;
      }
      
      public function set colorBar(param1:uint) : void
      {
         if(param1 == this._colorBar)
         {
            return;
         }
         this._colorBar = param1;
         invalidate();
      }
      
      public function get colorTrack() : uint
      {
         return this._colorTrack;
      }
      
      public function set colorTrack(param1:uint) : void
      {
         if(param1 == this._colorTrack)
         {
            return;
         }
         this._colorTrack = param1;
         invalidate();
      }
      
      public function get progress() : Number
      {
         return this._progress;
      }
      
      public function set progress(param1:Number) : void
      {
         if(param1 == this._progress)
         {
            return;
         }
         if(param1 < 0)
         {
            param1 = 0;
         }
         else if(param1 > 1)
         {
            param1 = 1;
         }
         this._progress = param1;
         this.mc_bar.scaleX = this._progress;
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
   }
}

