package thelaststand.app.game.gui.map
{
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.text.AntiAliasType;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.MissionData;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.UIOnlineStatus;
   import thelaststand.app.gui.UIImage;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.common.lang.Language;
   
   public class UIAreaNodeInfo extends Sprite
   {
      
      private var _areaNode:UIMissionAreaNode;
      
      private var _lootImages:Vector.<UIImage>;
      
      private var _padding:int = 10;
      
      private var _width:int = 234;
      
      private var _height:int = 114;
      
      private var _allianceSystem:AllianceSystem;
      
      private var mc_background:Shape;
      
      private var mc_loot:Sprite;
      
      private var bmp_titleBar:Bitmap;
      
      private var txt_location:BodyTextField;
      
      private var txt_level:BodyTextField;
      
      private var txt_time:BodyTextField;
      
      private var ui_online:UIOnlineStatus;
      
      private var bmp_warTitleBar:UITitleBar;
      
      private var txt_warpts:BodyTextField;
      
      private var txt_highActivityLabel:BodyTextField;
      
      public function UIAreaNodeInfo()
      {
         super();
         mouseEnabled = mouseChildren = false;
         this._lootImages = new Vector.<UIImage>();
         this.mc_background = new Shape();
         this.mc_background.filters = [new DropShadowFilter(0,0,0,1,8,8,5,1,true),new GlowFilter(6905685,1,1.75,1.75,10,1),new DropShadowFilter(1,45,0,1,8,8,1,2)];
         addChild(this.mc_background);
         this.mc_loot = new Sprite();
         this.bmp_titleBar = new Bitmap(new BmpTopBarBackground(),"always",true);
         this.bmp_titleBar.height = 28;
         addChild(this.bmp_titleBar);
         this.txt_location = new BodyTextField({
            "color":16777215,
            "text":" ",
            "size":16,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         addChild(this.txt_location);
         this.txt_level = new BodyTextField({
            "color":13948116,
            "text":" ",
            "size":14,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_level);
         this.txt_highActivityLabel = new BodyTextField({
            "color":Effects.COLOR_WARNING,
            "text":Language.getInstance().getString("haz_highactivity"),
            "size":14,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_highActivityLabel);
         this.txt_time = new BodyTextField({
            "color":13027014,
            "text":" ",
            "size":14,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         addChild(this.txt_time);
         this.ui_online = new UIOnlineStatus();
         this.bmp_warTitleBar = new UITitleBar(null,6194996);
         this.bmp_warTitleBar.height = 28;
         this.txt_warpts = new BodyTextField({
            "color":12379027,
            "text":" ",
            "size":14,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this._allianceSystem = AllianceSystem.getInstance();
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage,false,0,true);
      }
      
      public function dispose() : void
      {
         var _loc1_:UIImage = null;
         if(parent != null)
         {
            parent.removeChild(this);
         }
         removeEventListener(Event.ENTER_FRAME,this.updateLockTimer);
         removeEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         this.bmp_titleBar.bitmapData.dispose();
         this.bmp_titleBar.bitmapData = null;
         this.bmp_titleBar = null;
         this.mc_background.filters = [];
         this.mc_background = null;
         this.txt_level.dispose();
         this.txt_level = null;
         this.txt_location.dispose();
         this.txt_location = null;
         this.txt_highActivityLabel.dispose();
         this.txt_highActivityLabel = null;
         this.txt_time.dispose();
         this.txt_time = null;
         this.ui_online.dispose();
         this.ui_online = null;
         this._areaNode = null;
         for each(_loc1_ in this._lootImages)
         {
            _loc1_.dispose();
         }
         this._lootImages.length = 0;
         this._lootImages = null;
         this._allianceSystem = null;
         this.bmp_warTitleBar.dispose();
         this.bmp_warTitleBar = null;
         this.txt_warpts.dispose();
         this.txt_warpts = null;
      }
      
      private function update() : void
      {
         var _loc2_:* = false;
         var _loc1_:Language = Language.getInstance();
         _loc2_ = this._areaNode.highActivityIndex >= 0;
         this.bmp_titleBar.width = int(this._width - this._padding * 2 + 8);
         this.bmp_titleBar.x = int((this._width - this.bmp_titleBar.width) * 0.5);
         this.bmp_titleBar.y = this.bmp_titleBar.x;
         this.bmp_titleBar.transform.colorTransform = _loc2_ ? new ColorTransform(1,0,0,1,20,0,0,0) : new ColorTransform();
         var _loc3_:int = this._areaNode.level;
         if(this._areaNode.neighbor != null)
         {
            _loc3_ = this._areaNode.neighbor.level;
            this.txt_location.text = this._areaNode.neighbor.nickname;
            this.txt_level.text = _loc1_.getString("map_node_level",_loc3_ + 1);
            this.ui_online.status = this._areaNode.neighbor.online ? UIOnlineStatus.STATUS_ONLINE : UIOnlineStatus.STATUS_OFFLINE;
            addChild(this.ui_online);
         }
         else
         {
            this.txt_location.text = _loc1_.getString("location_types." + this._areaNode.type).toUpperCase();
            this.txt_level.text = _loc1_.getString("map_node_level",_loc3_ + 1);
            if(this.ui_online.parent != null)
            {
               this.ui_online.parent.removeChild(this.ui_online);
            }
         }
         if(this._areaNode.locked)
         {
            this.txt_time.textColor = Effects.COLOR_WARNING;
            addEventListener(Event.ENTER_FRAME,this.updateLockTimer,false,0,true);
            this.updateLockTimer();
         }
         else
         {
            this.txt_time.textColor = 13948116;
            this.txt_time.text = _loc1_.getString("map_node_return",DateTimeUtils.secondsToString(MissionData.calculateReturnTime(_loc3_,false,this._areaNode.type == "compound")));
            removeEventListener(Event.ENTER_FRAME,this.updateLockTimer);
         }
         var _loc4_:int = int(this.bmp_titleBar.x + 5);
         if(this.ui_online.parent != null)
         {
            this.ui_online.x = _loc4_;
            this.ui_online.y = int(this.bmp_titleBar.y + (this.bmp_titleBar.height - this.ui_online.height) * 0.5);
            this.txt_location.x = int(this.ui_online.x + this.ui_online.width + 2);
         }
         else
         {
            this.txt_location.x = _loc4_;
         }
         this.txt_location.y = int(this.bmp_titleBar.y + (this.bmp_titleBar.height - this.txt_location.height) * 0.5);
         this.txt_level.x = int(this.bmp_titleBar.x + this.bmp_titleBar.width - this.txt_level.width - 6);
         this.txt_level.y = int(this.bmp_titleBar.y + (this.bmp_titleBar.height - this.txt_level.height) * 0.5);
         this.txt_highActivityLabel.x = _loc4_;
         this.txt_highActivityLabel.y = int(this.bmp_titleBar.y + this.bmp_titleBar.height + 6);
         this.txt_highActivityLabel.visible = _loc2_;
         this.txt_time.x = _loc4_;
         this.txt_time.y = _loc2_ ? int(this.txt_highActivityLabel.y + this.txt_highActivityLabel.height + 4) : this.txt_highActivityLabel.y;
         this.updateLoot();
         if(this._lootImages.length > 0)
         {
            this.mc_loot.x = int(this.txt_location.x);
            this.mc_loot.y = int(this.txt_time.y + this.txt_time.height + 4);
            addChild(this.mc_loot);
         }
         else if(this.mc_loot.parent != null)
         {
            this.mc_loot.parent.removeChild(this.mc_loot);
         }
         this._width = Math.max(int(this.mc_loot.width + this.mc_loot.x * 2),234);
         this._height = this.mc_loot.parent != null ? int(this.mc_loot.y + this.mc_loot.height + 10) : int(this.txt_time.y + this.txt_time.height + 10);
         var _loc5_:int = this._allianceSystem.calcMissionScore(_loc3_,_loc2_);
         if(this._areaNode.type.indexOf("aicomp") == -1 && _loc5_ > 0)
         {
            this.bmp_warTitleBar.width = this.bmp_titleBar.width;
            this.bmp_warTitleBar.x = this.bmp_titleBar.x;
            this.bmp_warTitleBar.y = this.mc_loot.parent != null ? int(this.mc_loot.y + this.mc_loot.height + 6) : int(this.txt_time.y + this.txt_time.height + 6);
            addChild(this.bmp_warTitleBar);
            this.txt_warpts.text = _loc1_.getString("map_node_warpts",_loc5_.toString());
            this.txt_warpts.x = int(this.bmp_warTitleBar.x + 5);
            this.txt_warpts.y = int(this.bmp_warTitleBar.y + (this.bmp_warTitleBar.height - this.txt_warpts.height) * 0.5) + 2;
            addChild(this.txt_warpts);
            this._height = this.bmp_warTitleBar.y + this.bmp_warTitleBar.height + 8;
         }
         else
         {
            if(this.bmp_warTitleBar.parent)
            {
               this.bmp_warTitleBar.parent.removeChild(this.bmp_warTitleBar);
            }
            if(this.txt_warpts.parent)
            {
               this.txt_warpts.parent.removeChild(this.txt_warpts);
            }
         }
         this.mc_background.graphics.clear();
         this.mc_background.graphics.beginFill(1184274);
         this.mc_background.graphics.drawRect(0,0,this._width,this._height);
         this.mc_background.graphics.endFill();
      }
      
      private function updateLoot() : void
      {
         var _loc1_:UIImage = null;
         for each(_loc1_ in this._lootImages)
         {
            _loc1_.dispose();
         }
         this._lootImages.length = 0;
         if(this._areaNode.neighbor != null)
         {
            return;
         }
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this._areaNode.possibleFinds.length)
         {
            _loc1_ = new UIImage(32,32,0,1,true,"images/items/" + this._areaNode.possibleFinds[_loc3_] + ".jpg");
            _loc1_.x = _loc2_;
            _loc2_ += _loc1_.width + 4;
            this.mc_loot.addChild(_loc1_);
            this._lootImages.push(_loc1_);
            _loc3_++;
         }
      }
      
      private function updateLockTimer(param1:Event = null) : void
      {
         if(!this._areaNode.locked)
         {
            removeEventListener(Event.ENTER_FRAME,this.updateLockTimer);
            this.update();
            return;
         }
         if(this._areaNode.mission == null || this._areaNode.mission.lockTimer == null)
         {
            return;
         }
         var _loc2_:Language = Language.getInstance();
         var _loc3_:String = DateTimeUtils.secondsToString(this._areaNode.mission.lockTimer.getSecondsRemaining(),false,true);
         this.txt_time.text = _loc2_.getString("map_node_locked",_loc3_);
      }
      
      private function onAddedToStage(param1:Event) : void
      {
         if(this._areaNode != null && this._areaNode.mission != null && this._areaNode.mission.lockTimer != null)
         {
            addEventListener(Event.ENTER_FRAME,this.updateLockTimer,false,0,true);
         }
      }
      
      private function onRemovedFromStage(param1:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,this.updateLockTimer);
      }
      
      public function get areaNode() : UIMissionAreaNode
      {
         return this._areaNode;
      }
      
      public function set areaNode(param1:UIMissionAreaNode) : void
      {
         this._areaNode = param1;
         this.update();
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
   }
}

