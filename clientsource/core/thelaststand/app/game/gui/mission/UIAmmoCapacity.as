package thelaststand.app.game.gui.mission
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import thelaststand.app.game.data.WeaponData;
   
   public class UIAmmoCapacity extends Sprite
   {
      
      private const BORDER:int = 1;
      
      private const MIN_ALPHA:Number = 0.3;
      
      private const MAX_BAR_WIDTH:int = 10;
      
      private const MIN_BAR_WIDTH:int = 2;
      
      private const BAR_SPACING:int = 1;
      
      private const MAX_COLS:int = 14;
      
      private const MAX_ROWS:int = 2;
      
      private var _color:uint = 15575040;
      
      private var _maxWidth:int = 40;
      
      private var _height:int = 5;
      
      private var _numBars:int = 0;
      
      private var _barWidth:int = 0;
      
      private var _roundsPerBar:Number = 0;
      
      private var _weaponData:WeaponData;
      
      private var mc_background:Shape;
      
      private var mc_bars:Shape;
      
      public function UIAmmoCapacity()
      {
         super();
         mouseEnabled = mouseChildren = false;
         this.mc_background = new Shape();
         this.mc_background.graphics.beginFill(0);
         this.mc_background.graphics.drawRect(0,0,10,10);
         this.mc_background.graphics.endFill();
         addChild(this.mc_background);
         this.mc_bars = new Shape();
         this.mc_bars.x = this.mc_bars.y = this.BORDER;
         addChild(this.mc_bars);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent != null)
         {
            parent.removeChild(this);
         }
         if(this._weaponData != null)
         {
            this._weaponData.roundsChanged.remove(this.update);
            this._weaponData = null;
         }
      }
      
      private function init() : void
      {
         var _loc3_:int = 0;
         var _loc1_:int = this._weaponData.capacity;
         this._numBars = Math.max(_loc1_,int(_loc1_ / 4));
         var _loc2_:int = this.MAX_COLS * this.MAX_ROWS;
         if(this._numBars > _loc2_)
         {
            this._numBars = _loc2_;
         }
         else if(this._numBars > this.MAX_COLS)
         {
            _loc3_ = this._numBars % this.MAX_COLS;
            if(_loc3_ != 0)
            {
               this._numBars -= _loc3_;
            }
         }
         this._barWidth = Math.max(this.MIN_BAR_WIDTH,Math.min(this.MAX_BAR_WIDTH,(this._maxWidth - this.BAR_SPACING * _loc1_) / _loc1_));
         this._roundsPerBar = _loc1_ / this._numBars;
         this.update();
      }
      
      private function update() : void
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         this.mc_bars.graphics.clear();
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = this._height - this.BORDER * 2;
         var _loc5_:Number = this.weaponData.roundsInMagazine;
         var _loc6_:int = 0;
         while(_loc6_ < this._numBars)
         {
            _loc7_ = 1;
            _loc5_ -= this._roundsPerBar;
            if(_loc5_ < 0)
            {
               _loc8_ = _loc5_ / this._roundsPerBar;
               if(_loc8_ < 0)
               {
                  _loc8_ = -_loc8_;
               }
               if(_loc8_ > 1)
               {
                  _loc8_ = 1;
               }
               _loc7_ = this.MIN_ALPHA + (1 - this.MIN_ALPHA) * (1 - _loc8_);
            }
            this.mc_bars.graphics.beginFill(this._color,_loc7_);
            this.mc_bars.graphics.drawRect(_loc2_,_loc3_,this._barWidth,_loc4_);
            this.mc_bars.graphics.endFill();
            if(++_loc1_ >= this.MAX_COLS)
            {
               _loc1_ = 0;
               _loc2_ = 0;
               _loc3_ += this._height - this.BORDER * 2 + this.BAR_SPACING;
            }
            else
            {
               _loc2_ += this._barWidth + this.BAR_SPACING;
            }
            _loc6_++;
         }
         this.mc_background.width = this.mc_bars.width + this.BORDER * 2;
         this.mc_background.height = this.mc_bars.height + this.BORDER * 2;
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         if(this._weaponData != null)
         {
            this.update();
         }
      }
      
      public function get weaponData() : WeaponData
      {
         return this._weaponData;
      }
      
      public function set weaponData(param1:WeaponData) : void
      {
         if(this._weaponData != null)
         {
            this._weaponData.roundsChanged.remove(this.update);
         }
         this._weaponData = param1;
         this._weaponData.roundsChanged.add(this.update);
         this.init();
      }
   }
}

