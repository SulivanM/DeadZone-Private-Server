package thelaststand.app.game.gui.lists
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
   import thelaststand.app.game.data.alliance.AllianceMember;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.app.gui.UIBusySpinner;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   
   public class UIAllianceMemberTaskContributionListItem extends UIPagedListItem
   {
      
      public static const PORTRAIT_OUTLINE:GlowFilter = new GlowFilter(3618101,1,1.5,1.5,10,1);
      
      internal static const COLOR_NORMAL:int = 2434341;
      
      internal static const COLOR_ALT:int = 1447446;
      
      internal static const COLOR_OVER:int = 3158064;
      
      private const COL_WIDTHS:Vector.<int>;
      
      private var _lang:Language;
      
      private var _tooltips:TooltipManager;
      
      private var _alternating:Boolean;
      
      private var _member:AllianceMember;
      
      private var _remotePlayerData:RemotePlayerData;
      
      private var _separators:Vector.<UIListSeparator>;
      
      private var mc_background:Sprite;
      
      private var ui_portrait:UIImage;
      
      private var txt_name:BodyTextField;
      
      private var txt_task0:BodyTextField;
      
      private var txt_task1:BodyTextField;
      
      private var txt_task2:BodyTextField;
      
      private var txt_task3:BodyTextField;
      
      private var ui_busy:UIBusySpinner;
      
      private var _taskContributions:Vector.<uint>;
      
      public function UIAllianceMemberTaskContributionListItem()
      {
         var _loc3_:UIListSeparator = null;
         this.COL_WIDTHS = new <int>[256,116,116,116,116];
         this._taskContributions = Vector.<uint>([0,0,0,0]);
         super();
         this._lang = Language.getInstance();
         this._tooltips = TooltipManager.getInstance();
         _width = 720;
         _height = 26;
         this.mc_background = new Sprite();
         this.mc_background.graphics.beginFill(COLOR_NORMAL);
         this.mc_background.graphics.drawRect(0,0,_width,_height);
         this.mc_background.graphics.endFill();
         addChild(this.mc_background);
         this.ui_portrait = new UIImage(16,16,0,1,true);
         this.ui_portrait.context = new LoaderContext(true);
         this.ui_portrait.graphics.beginFill(0);
         this.ui_portrait.graphics.drawRect(-1,-1,18,18);
         this.ui_portrait.graphics.endFill();
         this.ui_portrait.filters = [PORTRAIT_OUTLINE];
         this.ui_portrait.x = 5;
         this.ui_portrait.y = Math.round((_height - this.ui_portrait.height) * 0.5 + 1);
         this.ui_busy = new UIBusySpinner();
         this.ui_busy.x = int(this.ui_portrait.x + this.ui_portrait.width * 0.5);
         this.ui_busy.y = int(this.ui_portrait.y + this.ui_portrait.height * 0.5);
         this.txt_name = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_name.y = 3;
         this.txt_task0 = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_task0.y = int((_height - this.txt_task0.height) * 0.5);
         this.txt_task1 = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_task1.y = int((_height - this.txt_task1.height) * 0.5);
         this.txt_task2 = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_task2.y = int((_height - this.txt_task2.height) * 0.5);
         this.txt_task3 = new BodyTextField({
            "text":" ",
            "color":16777215,
            "size":14,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW],
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_task3.y = int((_height - this.txt_task3.height) * 0.5);
         this._separators = new Vector.<UIListSeparator>();
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this.COL_WIDTHS.length - 1)
         {
            _loc1_ += this.COL_WIDTHS[_loc2_];
            _loc3_ = new UIListSeparator(_height + 1);
            _loc3_.x = _loc1_;
            addChild(_loc3_);
            this._separators.push(_loc3_);
            _loc2_++;
         }
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIListSeparator = null;
         var _loc2_:Resource = null;
         if(this.ui_portrait != null && this.ui_portrait.uri != null)
         {
            _loc2_ = ResourceManager.getInstance().getResource(this.ui_portrait.uri);
            if(_loc2_ != null && !_loc2_.loaded)
            {
               ResourceManager.getInstance().purge(this.ui_portrait.uri);
            }
         }
         TweenMax.killChildTweensOf(this);
         this._tooltips.removeAllFromParent(this);
         super.dispose();
         AllianceSystem.getInstance().roundStarted.remove(this.onRoundStarted);
         if(this._member != null)
         {
            this._member = null;
         }
         this._lang = null;
         this._tooltips = null;
         this._remotePlayerData = null;
         for each(_loc1_ in this._separators)
         {
            _loc1_.dispose();
         }
         this._separators = null;
         this._taskContributions = null;
         this.txt_name.dispose();
         this.txt_name = null;
         this.txt_task0.dispose();
         this.txt_task0 = null;
         this.txt_task1.dispose();
         this.txt_task1 = null;
         this.txt_task2.dispose();
         this.txt_task2 = null;
         this.txt_task3.dispose();
         this.txt_task3 = null;
      }
      
      private function update() : void
      {
         var _loc5_:BodyTextField = null;
         var _loc6_:int = 0;
         if(this._member == null)
         {
            if(this.ui_portrait.parent != null)
            {
               this.ui_portrait.parent.removeChild(this.ui_portrait);
            }
            if(this.txt_name.parent != null)
            {
               this.txt_name.parent.removeChild(this.txt_name);
            }
            if(this.txt_task0.parent != null)
            {
               this.txt_task0.parent.removeChild(this.txt_task0);
            }
            if(this.txt_task1.parent != null)
            {
               this.txt_task1.parent.removeChild(this.txt_task1);
            }
            if(this.txt_task2.parent != null)
            {
               this.txt_task2.parent.removeChild(this.txt_task2);
            }
            if(this.txt_task3.parent != null)
            {
               this.txt_task3.parent.removeChild(this.txt_task3);
            }
            return;
         }
         this.ui_portrait.uri = this._remotePlayerData != null ? this._remotePlayerData.getPortraitURI() : null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:* = this.member.nickname == "$formermember";
         this.ui_portrait.x = _loc2_ + 8;
         if(_loc3_)
         {
            this.txt_name.htmlText = "[" + Language.getInstance().getString("alliance.formermember").toUpperCase() + "]";
         }
         else
         {
            this.txt_name.htmlText = this._member.nickname + (this._member.joinDate.time > AllianceSystem.getInstance().round.activeTime.time ? " <font color=\'#A2A2A2\'>[" + this._lang.getString("alliance.enlisting").toUpperCase() + "]</font>" : "");
         }
         this.txt_name.x = this.ui_portrait.x + this.ui_portrait.width + 8;
         var _loc4_:int = 0;
         while(_loc4_ < 4)
         {
            _loc2_ += this.COL_WIDTHS[_loc1_++];
            _loc5_ = this["txt_task" + _loc4_];
            if(this._taskContributions[_loc4_] <= 0)
            {
               _loc5_.htmlText = "<font color=\'#c4c4c4\'>-</font>";
            }
            else
            {
               _loc5_.text = NumberFormatter.format(this._taskContributions[_loc4_],0);
            }
            _loc6_ = _loc4_ + 1 < this.COL_WIDTHS.length ? this.COL_WIDTHS[_loc4_ + 1] : _width;
            _loc5_.x = int(_loc2_ + (_loc6_ - _loc5_.width) * 0.5);
            _loc4_++;
         }
         addChild(this.ui_portrait);
         addChild(this.txt_name);
         addChild(this.txt_task0);
         addChild(this.txt_task1);
         addChild(this.txt_task2);
         addChild(this.txt_task3);
         if(this._remotePlayerData == null && !_loc3_)
         {
            addChild(this.ui_busy);
            this.ui_portrait.visible = false;
            removeEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
            removeEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         }
         else
         {
            if(this.ui_busy.parent)
            {
               this.ui_busy.parent.removeChild(this.ui_busy);
            }
            this.ui_portrait.visible = !_loc3_;
            addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver,false,0,true);
            addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut,false,0,true);
         }
      }
      
      public function getSortValue(param1:String) : *
      {
         switch(param1)
         {
            case "name":
               return this._member.nickname;
            case "task0":
               return this._taskContributions[0];
            case "task1":
               return this._taskContributions[1];
            case "task2":
               return this._taskContributions[2];
            case "task3":
               return this._taskContributions[3];
            default:
               return 0;
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         TweenMax.to(this.mc_background,0,{"tint":COLOR_OVER});
      }
      
      private function onMouseOut(param1:MouseEvent) : void
      {
         if(selected)
         {
            return;
         }
         TweenMax.to(this.mc_background,0,{"tint":(this._alternating ? COLOR_ALT : COLOR_NORMAL)});
      }
      
      private function onRoundStarted() : void
      {
         this.update();
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
      
      public function get member() : AllianceMember
      {
         return this._member;
      }
      
      public function set member(param1:AllianceMember) : void
      {
         this._member = param1;
         this.update();
      }
      
      public function parseTaskContributions(param1:Object) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._taskContributions.length)
         {
            this._taskContributions[_loc2_] = 0;
            if(param1 != null && String(_loc2_) in param1)
            {
               this._taskContributions[_loc2_] = uint(param1[String(_loc2_)]);
            }
            _loc2_++;
         }
         if(this._member != null)
         {
            this.update();
         }
      }
      
      public function get remotePlayerData() : RemotePlayerData
      {
         return this._remotePlayerData;
      }
      
      public function set remotePlayerData(param1:RemotePlayerData) : void
      {
         this._remotePlayerData = param1;
         if(this._member != null)
         {
            this.update();
         }
      }
   }
}

