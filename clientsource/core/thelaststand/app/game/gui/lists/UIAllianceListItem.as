package thelaststand.app.game.gui.lists
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import flash.system.LoaderContext;
   import flash.text.AntiAliasType;
   import org.osflash.signals.Signal;
   import thelaststand.app.audio.Audio;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceDataSummary;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.buttons.PushButton;
   import thelaststand.common.lang.Language;
   
   public class UIAllianceListItem extends UIPagedListItem
   {
      
      private static const BG_COLOR_NORMAL:uint = 2434341;
      
      private static const BG_COLOR_ALT:uint = 1447446;
      
      private static const BG_COLOR_OVER:uint = 3158064;
      
      private static const BG_COLOR_SELECTED:uint = 8138780;
      
      public static const PORTRAIT_OUTLINE:GlowFilter = new GlowFilter(3618101,1,1.5,1.5,10,1);
      
      private var _alternating:Boolean = false;
      
      private var _bgColor:ColorTransform = new ColorTransform();
      
      private var mc_background:Sprite;
      
      private var txt_label:BodyTextField;
      
      private var btn_view:PushButton;
      
      private var ui_portrait:UIImage;
      
      private var _allianceData:AllianceDataSummary;
      
      public var clickedView:Signal = new Signal(UIAllianceListItem);
      
      public function UIAllianceListItem()
      {
         super();
         _height = 40;
         _width = 495;
         this.mc_background = new Sprite();
         addChild(this.mc_background);
         this.ui_portrait = new UIImage(30,30,0,1,true);
         this.ui_portrait.context = new LoaderContext(true);
         this.ui_portrait.graphics.beginFill(0);
         this.ui_portrait.graphics.drawRect(-1,-1,32,32);
         this.ui_portrait.graphics.endFill();
         this.ui_portrait.filters = [PORTRAIT_OUTLINE];
         this.ui_portrait.x = 10;
         this.ui_portrait.y = Math.round((_height - this.ui_portrait.height) * 0.5 + 1);
         addChild(this.ui_portrait);
         this.txt_label = new BodyTextField({
            "text":" ",
            "color":13421772,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_label.x = this.ui_portrait.x + this.ui_portrait.width + 10;
         this.txt_label.y = int((_height - this.txt_label.height) * 0.5);
         addChild(this.txt_label);
         this.btn_view = new PushButton();
         this.btn_view.label = Language.getInstance().getString("alliance.viewtarget_viewBtn");
         this.btn_view.width = 120;
         this.btn_view.clicked.add(this.onViewClicked);
         addChild(this.btn_view);
         this.draw();
         mouseChildren = true;
         hitArea = this.mc_background;
         mouseOver.add(this.onMouseOver);
         mouseOut.add(this.onMouseOut);
         mouseDown.add(this.onMouseDown);
         TooltipManager.getInstance().add(this.btn_view,Language.getInstance().getString("alliance.viewtarget_tooltip"),new Point(Number.NaN,-int(_height * 0.5)),TooltipDirection.DIRECTION_DOWN);
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
      
      public function get allianceData() : AllianceDataSummary
      {
         return this._allianceData;
      }
      
      public function set allianceData(param1:AllianceDataSummary) : void
      {
         this._allianceData = param1;
         if(this._allianceData != null)
         {
            this.txt_label.text = param1.name + " [" + param1.tag + "]";
            this.btn_view.visible = true;
            this.ui_portrait.visible = true;
            this.ui_portrait.uri = Boolean(param1.thumbURI) && param1.thumbURI != "" ? param1.thumbURI : AllianceSystem.getThumbURI(param1.id);
         }
         else
         {
            this.txt_label.text = "";
            this.btn_view.visible = false;
            this.ui_portrait.visible = false;
         }
         this.updateLabelPosition();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         this.txt_label.dispose();
         this._allianceData = null;
         if(this.btn_view != null)
         {
            TooltipManager.getInstance().remove(this.btn_view);
            this.btn_view.dispose();
         }
      }
      
      private function draw() : void
      {
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginFill(this._alternating ? BG_COLOR_ALT : BG_COLOR_NORMAL);
         this.mc_background.graphics.drawRect(0,0,_width,_height);
         this.mc_background.graphics.endFill();
         this.updateLabelPosition();
         if(this.btn_view)
         {
            this.btn_view.x = int(_width - this.btn_view.width - 5);
            this.btn_view.y = int((_height - this.btn_view.height) * 0.5);
         }
      }
      
      private function updateLabelPosition() : void
      {
         this.txt_label.maxWidth = int(_width - this.txt_label.x - 6);
         this.txt_label.y = int((_height - this.txt_label.height) * 0.5);
      }
      
      private function updateStateDisplay() : void
      {
         this._bgColor.color = this.getBackgroundColor();
         if(super.selected)
         {
            this.txt_label.textColor = 16767439;
         }
         else
         {
            this.txt_label.textColor = 11974326;
         }
         this.mc_background.transform.colorTransform = this._bgColor;
      }
      
      private function getBackgroundColor() : uint
      {
         if(selected)
         {
            return BG_COLOR_SELECTED;
         }
         return this._alternating ? BG_COLOR_ALT : BG_COLOR_NORMAL;
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         this._bgColor.color = BG_COLOR_OVER;
         this.mc_background.transform.colorTransform = this._bgColor;
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         this._bgColor.color = this.getBackgroundColor();
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
      
      private function onViewClicked(param1:MouseEvent) : void
      {
         this.clickedView.dispatch(this);
      }
   }
}

