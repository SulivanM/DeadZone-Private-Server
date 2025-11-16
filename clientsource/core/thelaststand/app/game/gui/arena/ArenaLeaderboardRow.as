package thelaststand.app.game.gui.arena
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormatAlign;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.network.PlayerIOConnector;
   
   public class ArenaLeaderboardRow extends UIComponent
   {
      
      public static var columns:Array = [{
         "id":"level",
         "width":40
      },{
         "id":"name",
         "width":0
      },{
         "id":"points",
         "width":120
      }];
      
      private var _alternate:Boolean;
      
      private var _width:int;
      
      private var _height:int;
      
      private var txt_level:BodyTextField;
      
      private var txt_name:BodyTextField;
      
      private var txt_points:BodyTextField;
      
      private var ui_portrait:UIImage;
      
      public function ArenaLeaderboardRow()
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
         this.ui_portrait = new UIImage(1,1,0,1,false);
         addChild(this.ui_portrait);
         this.txt_name = new BodyTextField({
            "color":13355979,
            "bold":true,
            "size":15
         });
         addChild(this.txt_name);
         this.txt_points = new BodyTextField({
            "color":16250871,
            "bold":true,
            "size":15,
            "autoSize":TextFieldAutoSize.NONE,
            "align":TextFormatAlign.CENTER
         });
         addChild(this.txt_points);
      }
      
      public function get alternate() : Boolean
      {
         return this._alternate;
      }
      
      public function set alternate(param1:Boolean) : void
      {
         this._alternate = param1;
         invalidate();
      }
      
      override public function set data(param1:*) : void
      {
         super.data = param1;
         invalidate();
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
         this.ui_portrait.dispose();
      }
      
      override protected function draw() : void
      {
         graphics.clear();
         if(this._alternate)
         {
            graphics.beginFill(1447446,1);
         }
         else
         {
            graphics.beginFill(0,0);
         }
         graphics.drawRect(0,0,this.width,this.height);
         graphics.endFill();
         var _loc1_:int = 0;
         var _loc2_:int = 10;
         var _loc3_:int = int(columns[0].width);
         var _loc4_:int = int(columns[2].width);
         var _loc5_:int = this.width - (_loc3_ + _loc4_);
         this.txt_level.text = int(data.level + 1).toString();
         this.txt_level.width = _loc3_;
         this.txt_level.x = int(_loc1_ + (_loc3_ - this.txt_level.width) * 0.5);
         this.txt_level.y = int((this.height - this.txt_level.height) * 0.5);
         _loc1_ += _loc3_;
         this.drawDivider(_loc1_ - 2);
         this.ui_portrait.visible = data != null;
         this.ui_portrait.width = this.ui_portrait.height = this.height - 8;
         this.ui_portrait.x = int(_loc1_ + _loc2_);
         this.ui_portrait.y = int((this.height - this.ui_portrait.height) * 0.5);
         if(data.serviceAvatar)
         {
            this.ui_portrait.uri = String(data.serviceAvatar);
         }
         else if(Boolean(data.id) && data.id.substr(0,2) == PlayerIOConnector.SERVICE_FACEBOOK)
         {
            this.ui_portrait.uri = "https://graph.facebook.com/" + data.id.substr(2) + "/picture";
         }
         else
         {
            this.ui_portrait.uri = null;
         }
         this.txt_name.text = data.name != null ? data.name : "-";
         this.txt_name.maxWidth = _loc5_ - (this.ui_portrait.width + _loc2_ * 2);
         this.txt_name.x = int(this.ui_portrait.x + this.ui_portrait.width + _loc2_);
         this.txt_name.y = int((this.height - this.txt_name.height) * 0.5);
         _loc1_ += _loc5_;
         this.drawDivider(_loc1_ - 2);
         this.txt_points.text = data.points != null ? NumberFormatter.format(int(data.points),0) : "-";
         this.txt_points.x = int(_loc1_);
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

