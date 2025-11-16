package thelaststand.app.game.gui.lists
{
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.system.LoaderContext;
   import flash.text.AntiAliasType;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceDataSummary;
   import thelaststand.app.gui.UIImage;
   import thelaststand.common.lang.Language;
   
   public class UIAllianceEnemyListItem extends UIPagedListItem
   {
      
      internal static var ExpandIcon:BitmapData;
      
      public static const PORTRAIT_OUTLINE:GlowFilter = new GlowFilter(3618101,1,1.5,1.5,10,1);
      
      internal static const COLOR_NORMAL:int = 2434341;
      
      internal static const COLOR_ALT:int = 1447446;
      
      internal static const COLOR_OVER:int = 3158064;
      
      private var _alternating:Boolean;
      
      private var _alliance:AllianceDataSummary;
      
      private var _lang:Language;
      
      private var _launchEnabled:Boolean = true;
      
      private var mc_background:Sprite;
      
      private var ui_portrait:UIImage;
      
      private var expandIcon:Bitmap;
      
      private var txt_name:BodyTextField;
      
      private var txt_level:BodyTextField;
      
      public var triggered:Signal = new Signal(UIAllianceEnemyListItem);
      
      public function UIAllianceEnemyListItem()
      {
         super();
         this._lang = Language.getInstance();
         _width = 240;
         _height = 40;
         this.mc_background = new Sprite();
         this.mc_background.graphics.beginFill(COLOR_NORMAL);
         this.mc_background.graphics.drawRect(0,0,_width,_height);
         this.mc_background.graphics.endFill();
         addChild(this.mc_background);
         if(ExpandIcon == null)
         {
            ExpandIcon = new BmpIconPanelUndock();
         }
         this.expandIcon = new Bitmap(ExpandIcon);
         this.expandIcon.x = this.mc_background.width - this.expandIcon.width - 10;
         this.expandIcon.y = int((this.mc_background.height - this.expandIcon.height) * 0.5);
         this.expandIcon.visible = false;
         TweenMax.to(this.expandIcon,0,{"colorTransform":{
            "tint":11614778,
            "tintAmount":0.5
         }});
         this.ui_portrait = new UIImage(30,30,0,1,true);
         this.ui_portrait.context = new LoaderContext(true);
         this.ui_portrait.graphics.beginFill(0);
         this.ui_portrait.graphics.drawRect(-1,-1,32,32);
         this.ui_portrait.graphics.endFill();
         this.ui_portrait.filters = [PORTRAIT_OUTLINE];
         this.ui_portrait.x = 5;
         this.ui_portrait.y = Math.round((_height - this.ui_portrait.height) * 0.5 + 1);
         this.txt_name = new BodyTextField({
            "text":" ",
            "color":11614778,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_name.x = this.ui_portrait.x + this.ui_portrait.width + 5;
         this.txt_name.y = 2;
         this.txt_name.maxWidth = int(this.expandIcon.x - this.txt_name.x - 5);
         this.txt_level = new BodyTextField({
            "text":" ",
            "color":7357508,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_level.x = this.txt_name.x;
         this.txt_level.y = int(this.txt_name.y + this.txt_name.height - 4);
         this.txt_level.maxWidth = int(this.expandIcon.x - this.txt_level.x - 5);
      }
      
      override public function dispose() : void
      {
         TweenMax.killChildTweensOf(this);
         super.dispose();
         this._lang = null;
         this._alliance = null;
         this.ui_portrait.dispose();
         this.txt_name.dispose();
         this.txt_level.dispose();
         this.triggered.removeAll();
      }
      
      private function update() : void
      {
         if(this._alliance == null)
         {
            if(this.txt_name.parent != null)
            {
               this.txt_name.parent.removeChild(this.txt_name);
            }
            if(this.txt_level.parent != null)
            {
               this.txt_level.parent.removeChild(this.txt_level);
            }
            if(this.ui_portrait.parent != null)
            {
               this.ui_portrait.parent.removeChild(this.ui_portrait);
            }
            if(this.expandIcon.parent != null)
            {
               this.expandIcon.parent.removeChild(this.expandIcon);
            }
            return;
         }
         this.txt_name.text = this._alliance.name;
         this.txt_level.text = "[" + this._alliance.tag + "]";
         this.ui_portrait.uri = this._alliance.thumbURI;
         addChild(this.txt_name);
         addChild(this.txt_level);
         addChild(this.ui_portrait);
         addChild(this.expandIcon);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(selected || !this._launchEnabled)
         {
            return;
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(selected || !this._launchEnabled)
         {
            return;
         }
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         if(!this._launchEnabled)
         {
            return;
         }
      }
      
      private function onClicked(param1:MouseEvent) : void
      {
         if(!this._launchEnabled)
         {
            return;
         }
      }
      
      public function get alternating() : Boolean
      {
         return this._alternating;
      }
      
      public function set alternating(param1:Boolean) : void
      {
         var _loc2_:ColorTransform = null;
         this._alternating = param1;
         if(!selected)
         {
            _loc2_ = this.mc_background.transform.colorTransform;
            _loc2_.color = this._alternating ? uint(COLOR_ALT) : uint(COLOR_NORMAL);
            this.mc_background.transform.colorTransform = _loc2_;
         }
      }
      
      public function get alliance() : AllianceDataSummary
      {
         return this._alliance;
      }
      
      public function set alliance(param1:AllianceDataSummary) : void
      {
         if(param1 == this._alliance)
         {
            return;
         }
         if(this._alliance != null)
         {
            removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
            removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
            removeEventListener(MouseEvent.CLICK,this.onClicked);
         }
         this._alliance = param1;
         this.update();
         if(this._alliance != null)
         {
            addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
            addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
            addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown,false,0,true);
            addEventListener(MouseEvent.CLICK,this.onClicked,false,0,true);
         }
      }
      
      public function get launchEnabled() : Boolean
      {
         return this._launchEnabled;
      }
      
      public function set launchEnabled(param1:Boolean) : void
      {
         this._launchEnabled = param1;
      }
   }
}

