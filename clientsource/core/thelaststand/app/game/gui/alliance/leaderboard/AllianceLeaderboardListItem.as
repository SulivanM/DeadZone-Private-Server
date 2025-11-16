package thelaststand.app.game.gui.alliance.leaderboard
{
   import com.exileetiquette.utils.NumberFormatter;
   import com.greensock.TweenMax;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.system.LoaderContext;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.dialogues.AllianceViewMemberListDialogue;
   import thelaststand.app.game.gui.lists.UIListSeparator;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIImage;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   
   public class AllianceLeaderboardListItem extends Sprite
   {
      
      public static const PORTRAIT_OUTLINE:GlowFilter = new GlowFilter(3618101,1,1.5,1.5,10,1);
      
      internal static const COLOR_NORMAL:int = 2434341;
      
      internal static const COLOR_ALT:int = 1447446;
      
      internal static const COLOR_OVER:int = 3158064;
      
      private static const COLOR_GREY:int = 13882323;
      
      private var _width:Number = 495;
      
      private var _height:Number = 40;
      
      private var _data:Object;
      
      private var _alternating:Boolean;
      
      private var _lang:Language;
      
      private var _separators:Vector.<UIListSeparator>;
      
      private var _tooltip:TooltipManager;
      
      private var mc_background:Sprite;
      
      private var ui_portrait:UIImage;
      
      private var txt_rank:BodyTextField;
      
      private var txt_name:BodyTextField;
      
      private var txt_score:BodyTextField;
      
      private var txt_efficiency:BodyTextField;
      
      private var btn_view:AllianceListMemberButton;
      
      private var _selected:Boolean;
      
      public function AllianceLeaderboardListItem()
      {
         var _loc1_:Number = NaN;
         this._separators = new Vector.<UIListSeparator>();
         super();
         this._lang = Language.getInstance();
         this.mc_background = new Sprite();
         this.mc_background.graphics.beginFill(COLOR_NORMAL);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
         addChild(this.mc_background);
         _loc1_ = 0;
         this.txt_rank = new BodyTextField({
            "text":"100",
            "color":13421772,
            "size":14,
            "bold":true,
            "align":"center",
            "autoSize":"none",
            "width":40,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_rank.y = int((this._height - this.txt_rank.height) * 0.5);
         addChild(this.txt_rank);
         _loc1_ += 40;
         this.createSeparator(_loc1_);
         this.ui_portrait = new UIImage(30,30,0,1,true);
         this.ui_portrait.context = new LoaderContext(true);
         this.ui_portrait.graphics.beginFill(0);
         this.ui_portrait.graphics.drawRect(-1,-1,32,32);
         this.ui_portrait.graphics.endFill();
         this.ui_portrait.filters = [PORTRAIT_OUTLINE];
         this.ui_portrait.x = _loc1_ + 13;
         this.ui_portrait.y = Math.round((this._height - this.ui_portrait.height) * 0.5 + 1);
         addChild(this.ui_portrait);
         this.txt_name = new BodyTextField({
            "text":" ",
            "color":13421772,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_name.x = this.ui_portrait.x + this.ui_portrait.width + 10;
         this.txt_name.y = int((this._height - this.txt_name.height) * 0.5);
         addChild(this.txt_name);
         _loc1_ += 265;
         this.btn_view = new AllianceListMemberButton();
         this.btn_view.clicked.add(this.onViewClick);
         addChild(this.btn_view);
         this.btn_view.x = _loc1_ - 20;
         this.btn_view.y = 20;
         this.txt_name.maxWidth = _loc1_ - this.txt_name.x - 30;
         this.createSeparator(_loc1_);
         this.txt_score = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":14,
            "bold":true,
            "align":"center",
            "autoSize":"none",
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_score.x = _loc1_ + 5;
         this.txt_score.y = int((this._height - this.txt_score.height) * 0.5);
         addChild(this.txt_score);
         _loc1_ += 102;
         this.txt_score.width = _loc1_ - this.txt_score.x - 5;
         this.createSeparator(_loc1_);
         this.txt_efficiency = new BodyTextField({
            "text":" ",
            "color":9145227,
            "size":12,
            "bold":true,
            "align":"center",
            "autoSize":"none",
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_efficiency.x = _loc1_ + 5;
         this.txt_efficiency.y = int((this._height - this.txt_efficiency.height) * 0.5);
         addChild(this.txt_efficiency);
         _loc1_ += 84;
         this.txt_efficiency.width = _loc1_ - this.txt_efficiency.x - 5;
         this._tooltip = TooltipManager.getInstance();
      }
      
      public function dispose() : void
      {
         var _loc1_:Resource = null;
         if(this.ui_portrait != null && this.ui_portrait.uri != null)
         {
            _loc1_ = ResourceManager.getInstance().getResource(this.ui_portrait.uri);
            if(_loc1_ != null && !_loc1_.loaded)
            {
               ResourceManager.getInstance().purge(this.ui_portrait.uri);
            }
         }
         TweenMax.killChildTweensOf(this);
         this._tooltip.removeAllFromParent(this);
         this._lang = null;
         this._tooltip = null;
         while(this._separators.length > 0)
         {
            this._separators.pop().dispose();
         }
         this._separators = null;
         this.txt_name.dispose();
         this.txt_name = null;
         this.txt_rank.dispose();
         this.txt_rank = null;
         this.txt_score.dispose();
         this.txt_score = null;
         this.txt_efficiency.dispose();
         this.txt_efficiency = null;
         this.ui_portrait.dispose();
         this.ui_portrait = null;
         this.btn_view.dispose();
      }
      
      private function update() : void
      {
         if(this._data == null)
         {
            this.ui_portrait.visible = false;
            this.txt_name.visible = this.txt_rank.visible = this.txt_score.visible = this.txt_efficiency.visible = false;
            this.btn_view.visible = false;
            return;
         }
         this.txt_rank.text = this._data.rank.toString() + ".";
         this.txt_rank.visible = true;
         this.ui_portrait.uri = AllianceSystem.getThumbURI(this._data.allianceId);
         this.ui_portrait.visible = true;
         this.txt_name.htmlText = this._data.name + " <font color=\'#6b6b6b\'>[" + this._data.tag + "]</font>";
         this.txt_name.visible = true;
         this.txt_name.height = int((this._height - this.txt_name.height) * 0.5);
         this.txt_score.text = NumberFormatter.format(this._data.points,0);
         this.txt_score.visible = true;
         var _loc1_:Number = this._data.wins / (this._data.wins + this._data.losses) * 100;
         this.txt_efficiency.text = NumberFormatter.format(_loc1_,2) + "%";
         this.txt_efficiency.visible = true;
         this.btn_view.visible = true;
      }
      
      private function createSeparator(param1:int) : void
      {
         var _loc2_:UIListSeparator = new UIListSeparator(this._height);
         _loc2_.x = int(param1 - _loc2_.width * 0.5);
         addChild(_loc2_);
         this._separators.push(_loc2_);
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(this.selected)
         {
            return;
         }
         TweenMax.to(this.mc_background,0,{"tint":COLOR_OVER});
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(this.selected)
         {
            return;
         }
         TweenMax.to(this.mc_background,0,{"tint":(this._alternating ? COLOR_ALT : COLOR_NORMAL)});
      }
      
      private function onViewClick() : void
      {
         var _loc1_:AllianceViewMemberListDialogue = new AllianceViewMemberListDialogue(this._data.allianceId,this._data.name,this._data.tag);
         _loc1_.open();
      }
      
      public function get alternating() : Boolean
      {
         return this._alternating;
      }
      
      public function set alternating(param1:Boolean) : void
      {
         var _loc2_:ColorTransform = null;
         this._alternating = param1;
         if(!this.selected)
         {
            _loc2_ = this.mc_background.transform.colorTransform;
            _loc2_.color = this._alternating ? uint(COLOR_ALT) : uint(COLOR_NORMAL);
            this.mc_background.transform.colorTransform = _loc2_;
         }
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set data(param1:Object) : void
      {
         if(this._data != null)
         {
            removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         }
         this._data = param1;
         this.update();
         if(this._data != null)
         {
            addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
            addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         }
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this._selected = param1;
      }
   }
}

import com.greensock.TweenMax;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import org.osflash.signals.Signal;
import thelaststand.app.audio.Audio;

class AllianceListMemberButton extends Sprite
{
   
   private var icon:Shape;
   
   public var clicked:Signal = new Signal();
   
   public function AllianceListMemberButton()
   {
      super();
      mouseChildren = false;
      buttonMode = true;
      this.icon = new Shape();
      var _loc1_:Graphics = this.icon.graphics;
      _loc1_.beginFill(0,0);
      _loc1_.drawRect(0,0,16,14);
      _loc1_.beginFill(65793,1);
      _loc1_.drawRect(0,0,16,4);
      _loc1_.drawRect(0,5,16,4);
      _loc1_.drawRect(0,10,16,4);
      _loc1_.endFill();
      _loc1_.beginFill(12632256,1);
      _loc1_.drawRect(1,1,14,2);
      _loc1_.drawRect(1,6,14,2);
      _loc1_.drawRect(1,11,14,2);
      _loc1_.endFill();
      this.icon.x = -int(this.icon.width * 0.5);
      this.icon.y = -int(this.icon.height * 0.5);
      addChild(this.icon);
      this.icon.cacheAsBitmap = true;
      this.icon.alpha = 0.5;
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
      this.clicked.removeAll();
      TweenMax.killChildTweensOf(this);
      removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
      removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
      removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDown);
      removeEventListener(MouseEvent.CLICK,this.onMouseClick);
   }
   
   private function onRollOver(param1:MouseEvent) : void
   {
      TweenMax.to(this.icon,0.15,{
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
      TweenMax.to(this.icon,0.25,{
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
      this.clicked.dispatch();
   }
}
