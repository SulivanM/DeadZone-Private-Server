package thelaststand.app.game.gui.arena
{
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormatAlign;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.common.lang.Language;
   
   public class ArenaLeaderboardHeaderRow extends UIComponent
   {
      
      private var _width:int;
      
      private var _height:int;
      
      private var txt_level:BodyTextField;
      
      private var txt_name:BodyTextField;
      
      private var txt_points:BodyTextField;
      
      public function ArenaLeaderboardHeaderRow()
      {
         super();
         this.txt_level = new BodyTextField({
            "color":8618883,
            "bold":true,
            "size":13,
            "autoSize":TextFieldAutoSize.NONE,
            "align":TextFormatAlign.CENTER
         });
         addChild(this.txt_level);
         this.txt_name = new BodyTextField({
            "color":8618883,
            "bold":true,
            "size":13
         });
         addChild(this.txt_name);
         this.txt_points = new BodyTextField({
            "color":8618883,
            "bold":true,
            "size":13,
            "autoSize":TextFieldAutoSize.NONE,
            "align":TextFormatAlign.CENTER
         });
         addChild(this.txt_points);
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
      
      override public function dispose() : void
      {
         super.dispose();
         this.txt_level.dispose();
         this.txt_name.dispose();
         this.txt_points.dispose();
      }
      
      override protected function draw() : void
      {
         graphics.clear();
         graphics.beginFill(2434341,1);
         graphics.drawRect(0,0,this.width,this.height);
         graphics.endFill();
         var _loc1_:int = 10;
         var _loc2_:int = 0;
         var _loc3_:int = int(ArenaLeaderboardRow.columns[0].width);
         var _loc4_:int = int(ArenaLeaderboardRow.columns[2].width);
         var _loc5_:int = this.width - (_loc3_ + _loc4_);
         this.txt_level.text = Language.getInstance().getString("arena.leaderboard_level");
         this.txt_level.width = _loc3_;
         this.txt_level.x = int(_loc2_ + (_loc3_ - this.txt_level.width) * 0.5);
         this.txt_level.y = int((this.height - this.txt_level.height) * 0.5);
         _loc2_ += _loc3_;
         this.drawDivider(_loc2_ - 2);
         this.txt_name.text = Language.getInstance().getString("arena.leaderboard_player");
         this.txt_name.maxWidth = _loc5_ - _loc1_ * 2;
         this.txt_name.x = int(_loc2_ + _loc1_);
         this.txt_name.y = int((this.height - this.txt_name.height) * 0.5);
         _loc2_ += _loc5_;
         this.drawDivider(_loc2_ - 2);
         this.txt_points.text = Language.getInstance().getString("arena.leaderboard_points");
         this.txt_points.x = int(_loc2_);
         this.txt_points.y = int((this.height - this.txt_points.height) * 0.5);
         this.txt_points.width = _loc4_;
      }
      
      private function drawDivider(param1:int) : void
      {
         var _loc2_:int = 4;
         graphics.beginFill(0,1);
         graphics.drawRect(param1,0,_loc2_,this._height);
         graphics.endFill();
         graphics.beginFill(4144959,1);
         graphics.drawRect(param1,0,1,this._height);
         graphics.endFill();
         graphics.beginFill(4144959,1);
         graphics.drawRect(param1 + _loc2_,0,1,this._height);
         graphics.endFill();
      }
   }
}

