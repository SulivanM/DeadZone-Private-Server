package thelaststand.app.game.gui.arena
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.ColorTransform;
   import flash.text.TextFormatAlign;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.arena.ArenaSession;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.SaveDataMethod;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class ArenaLeaderboardPanelView extends UIComponent
   {
      
      private var _session:ArenaSession;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _week:int;
      
      private var _leaderName:String;
      
      private var _points:int;
      
      private var _loaded:Boolean;
      
      private var _disposed:Boolean;
      
      private var bmp_background:Bitmap;
      
      private var bmp_titlebar:Bitmap;
      
      private var mc_bottomBar:Sprite;
      
      private var txt_title:BodyTextField;
      
      private var txt_name:BodyTextField;
      
      private var txt_points:BodyTextField;
      
      private var ui_busy:UIBusySpinner;
      
      public function ArenaLeaderboardPanelView(param1:ArenaSession)
      {
         var _loc2_:ColorTransform = null;
         super();
         this._session = param1;
         this.bmp_background = new Bitmap(new BmpArenaLeaderBg(),"auto",true);
         addChild(this.bmp_background);
         _loc2_ = new ColorTransform(1,1,1,1,28,-15,40,0);
         this.bmp_titlebar = new Bitmap(new BmpTopBarBackground(),"auto",true);
         this.bmp_titlebar.filters = [Effects.STROKE];
         this.bmp_titlebar.transform.colorTransform = _loc2_;
         addChild(this.bmp_titlebar);
         this.mc_bottomBar = new Sprite();
         this.mc_bottomBar.graphics.beginFill(0,0.4);
         this.mc_bottomBar.graphics.drawRect(0,0,1,1);
         this.mc_bottomBar.graphics.endFill();
         addChild(this.mc_bottomBar);
         this.txt_points = new BodyTextField({
            "color":11098127,
            "size":16,
            "bold":true
         });
         addChild(this.txt_points);
         this.txt_title = new BodyTextField({
            "color":16250871,
            "size":14
         });
         this.txt_title.filters = [Effects.TEXT_SHADOW];
         addChild(this.txt_title);
         this.txt_name = new BodyTextField({
            "color":15840578,
            "size":25,
            "bold":true,
            "align":TextFormatAlign.CENTER
         });
         this.txt_name.filters = [Effects.TEXT_SHADOW_DARK];
         addChild(this.txt_name);
         this.ui_busy = new UIBusySpinner();
         this.ui_busy.visible = false;
         addChild(this.ui_busy);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = int(param1);
         invalidate();
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
         this._height = int(param1);
         invalidate();
      }
      
      override public function dispose() : void
      {
         if(this._disposed)
         {
            return;
         }
         this._disposed = true;
         super.dispose();
         this.bmp_background.bitmapData.dispose();
         this.bmp_titlebar.bitmapData.dispose();
         this.txt_points.dispose();
         this.txt_title.dispose();
         this.txt_name.dispose();
      }
      
      override protected function draw() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         GraphicUtils.drawUIBlock(graphics,this.width,this.height,0,0);
         this.bmp_background.x = this.bmp_background.y = 3;
         this.bmp_background.width = int(this.width - this.bmp_background.x * 2);
         this.bmp_background.height = int(this.height - this.bmp_background.y * 2);
         this.bmp_titlebar.x = this.bmp_background.x + 2;
         this.bmp_titlebar.y = this.bmp_background.y + 2;
         this.bmp_titlebar.width = int(this.width - this.bmp_titlebar.x * 2);
         this.bmp_titlebar.height = 24;
         this.mc_bottomBar.x = 3;
         this.mc_bottomBar.width = int(this.width - this.mc_bottomBar.x * 2);
         this.mc_bottomBar.height = 24;
         this.mc_bottomBar.y = int(this.height - this.mc_bottomBar.height - 3);
         _loc1_ = int(this.mc_bottomBar.y - (this.bmp_titlebar.y + this.bmp_titlebar.height));
         if(this._loaded)
         {
            this.ui_busy.visible = false;
            _loc2_ = int(Network.getInstance().playerData.getPlayerSurvivor().level);
            this.txt_title.htmlText = Language.getInstance().getString("arena.leaderboard_preview_title",_loc2_ + 1);
            this.txt_points.htmlText = Language.getInstance().getString("arena.leaderboard_preview_points",NumberFormatter.format(this._points,0));
            this.txt_name.text = !this._leaderName ? "-" : this._leaderName;
         }
         else
         {
            this.ui_busy.visible = true;
            this.txt_title.htmlText = Language.getInstance().getString("arena.leaderboard_preview_loading");
            this.txt_points.htmlText = "";
            this.txt_name.text = "";
            this.ui_busy.x = int((this.width - this.ui_busy.width) * 0.5);
            this.ui_busy.y = int(this.bmp_titlebar.y + this.bmp_titlebar.height + (_loc1_ - this.ui_busy.height) * 0.5);
         }
         this.txt_title.x = int(this.bmp_titlebar.x + (this.bmp_titlebar.width - this.txt_title.width) * 0.5);
         this.txt_title.y = int(this.bmp_titlebar.y + (this.bmp_titlebar.height - this.txt_title.height) * 0.5);
         this.txt_name.maxWidth = int(this.bmp_background.width - 12);
         this.txt_name.x = int((this.width - this.txt_name.width) * 0.5);
         this.txt_name.y = int(this.bmp_titlebar.y + this.bmp_titlebar.height + (_loc1_ - this.txt_name.height) * 0.5);
         this.txt_points.maxWidth = this.mc_bottomBar.width - 6;
         this.txt_points.x = int(this.mc_bottomBar.x + (this.mc_bottomBar.width - this.txt_points.width) * 0.5);
         this.txt_points.y = int(this.mc_bottomBar.y + (this.mc_bottomBar.height - this.txt_points.height) * 0.5);
      }
      
      private function loadLeaderData() : void
      {
         var level:int = int(Network.getInstance().playerData.getPlayerSurvivor().level);
         var request:Object = {
            "name":this._session.name,
            "level":level
         };
         Network.getInstance().save(request,SaveDataMethod.ARENA_LEADER,function(param1:Object):void
         {
            if(_disposed)
            {
               return;
            }
            if(param1 == null || param1.success == false)
            {
               return;
            }
            _loaded = true;
            _week = int(param1.week);
            _leaderName = param1.name;
            _points = int(param1.points);
            invalidate();
         });
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         this.loadLeaderData();
      }
   }
}

