package thelaststand.app.game.gui.map
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.TimerData;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.network.RemotePlayerData;
   
   public class UIMissionAreaNode extends Sprite
   {
      
      private static const BMP_LOCKED:BitmapData = new BmpIconLoadoutLocked();
      
      private var _mission:MissionData;
      
      private var _locked:Boolean;
      
      private var bmp_locked:Bitmap;
      
      private var mc_filter:UIImage;
      
      private var _rect:Rectangle;
      
      public var type:String;
      
      public var suburb:String;
      
      public var level:int;
      
      public var possibleFinds:Array = [];
      
      public var neighbor:RemotePlayerData;
      
      public var highActivityIndex:int = -1;
      
      public function UIMissionAreaNode(param1:int, param2:int, param3:int, param4:int)
      {
         super();
         this._rect = new Rectangle(param1,param2,param3,param4);
         this.x = param1;
         this.y = param2;
         this.width = param3;
         this.height = param4;
      }
      
      public function dispose() : void
      {
         this._mission = null;
         this.neighbor = null;
         this.possibleFinds = null;
         if(this.bmp_locked != null)
         {
            this.bmp_locked.bitmapData = null;
            this.bmp_locked = null;
         }
         if(this.mc_filter != null)
         {
            this.mc_filter.dispose();
            this.mc_filter = null;
         }
      }
      
      public function showFilter(param1:String) : void
      {
         if(param1 == null)
         {
            if(this.mc_filter != null)
            {
               this.mc_filter.dispose();
            }
            this.mc_filter = null;
            return;
         }
         if(this.mc_filter == null)
         {
            this.mc_filter = new UIImage(32,32);
            this.mc_filter.x = int((this._rect.width - this.mc_filter.width) * 0.5);
            this.mc_filter.y = int((this._rect.height - this.mc_filter.height) * 0.5);
            this.mc_filter.graphics.beginFill(16777215,1);
            this.mc_filter.graphics.drawRect(-1,-1,34,34);
            this.mc_filter.graphics.endFill();
            addChild(this.mc_filter);
         }
         this.mc_filter.uri = "images/items/" + param1 + ".jpg";
      }
      
      private function setLocked(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         this._locked = param1;
         if(this._locked)
         {
            _loc2_ = 2;
            graphics.beginFill(10689050,0.6);
            graphics.drawRect(0,0,this._rect.width,this._rect.height);
            graphics.drawRect(_loc2_,_loc2_,this._rect.width - _loc2_ * 2,this._rect.height - _loc2_ * 2);
            graphics.endFill();
            graphics.beginFill(4200472,0.6);
            graphics.drawRect(_loc2_,_loc2_,this._rect.width - _loc2_ * 2,this._rect.height - _loc2_ * 2);
            graphics.endFill();
            if(this.bmp_locked == null)
            {
               this.bmp_locked = new Bitmap(BMP_LOCKED);
            }
            this.bmp_locked.x = int((this._rect.width - this.bmp_locked.width) * 0.5);
            this.bmp_locked.y = int((this._rect.height - this.bmp_locked.height) * 0.5);
            TweenMax.to(this.bmp_locked,0,{"colorMatrixFilter":{"colorize":16744062}});
            addChild(this.bmp_locked);
         }
         else
         {
            graphics.clear();
            if(this.bmp_locked != null)
            {
               if(this.bmp_locked.parent != null)
               {
                  this.bmp_locked.parent.removeChild(this.bmp_locked);
               }
               this.bmp_locked.bitmapData = null;
               this.bmp_locked = null;
            }
         }
      }
      
      private function onLockTimerComplete(param1:TimerData) : void
      {
         this.setLocked(false);
      }
      
      public function get mission() : MissionData
      {
         return this._mission;
      }
      
      public function set mission(param1:MissionData) : void
      {
         if(this._mission != null)
         {
            if(this._mission.lockTimer != null)
            {
               this._mission.lockTimer.completed.remove(this.onLockTimerComplete);
            }
         }
         this._mission = param1;
         if(this._mission.lockTimer != null && !this._mission.lockTimer.hasEnded())
         {
            this._mission.lockTimer.completed.addOnce(this.onLockTimerComplete);
            this.setLocked(true);
         }
         else
         {
            this.setLocked(false);
         }
      }
      
      public function get locked() : Boolean
      {
         return this._locked;
      }
      
      override public function get x() : Number
      {
         return super.x;
      }
      
      override public function set x(param1:Number) : void
      {
         super.x = param1;
         this._rect.x = param1;
      }
      
      override public function get y() : Number
      {
         return super.y;
      }
      
      override public function set y(param1:Number) : void
      {
         super.y = param1;
         this._rect.y = param1;
      }
      
      override public function get width() : Number
      {
         return this._rect.width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._rect.width = param1;
      }
      
      override public function get height() : Number
      {
         return this._rect.height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._rect.height = param1;
      }
      
      public function get rect() : Rectangle
      {
         return this._rect;
      }
   }
}

