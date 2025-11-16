package thelaststand.app.game.gui.header
{
   import com.deadreckoned.threshold.display.Color;
   import com.greensock.TweenMax;
   import flash.display.Bitmap;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import thelaststand.app.data.IOpponent;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.alliance.AllianceSystem;
   import thelaststand.app.game.gui.UILargeProgressBar;
   import thelaststand.app.game.gui.UISurvivorPortrait;
   import thelaststand.app.network.Network;
   import thelaststand.app.network.RemotePlayerData;
   import thelaststand.common.lang.Language;
   
   public class UIXPDisplay extends Sprite
   {
      
      public static const ALIGN_LEFT:String = "left";
      
      public static const ALIGN_RIGHT:String = "right";
      
      private const BAR_WIDTH:int = 200;
      
      private const BAR_HEIGHT:int = 24;
      
      private const TRACK_GLOW:GlowFilter = new GlowFilter(7039851,1,3,3,3,2);
      
      private var _align:String = "left";
      
      private var _data:*;
      
      private var _restedXP:int;
      
      private var _isPlayerSurvivor:Boolean;
      
      private var bmp_portraitBG:Bitmap;
      
      private var mc_bar:UILargeProgressBar;
      
      private var mc_track:Shape;
      
      private var mc_portait:UISurvivorPortrait;
      
      private var txt_name:BodyTextField;
      
      private var txt_level:BodyTextField;
      
      private var mc_levelUpReminder:LevelUpReminder;
      
      private var mc_restedBar:Sprite;
      
      private var mc_restedArrow:Sprite;
      
      public function UIXPDisplay(param1:* = null, param2:String = "left", param3:uint = 15180544, param4:uint = 3646208)
      {
         super();
         this._align = param2;
         mouseChildren = false;
         this.bmp_portraitBG = new Bitmap(new BmpTopBarPortraitBG());
         addChild(this.bmp_portraitBG);
         this.mc_portait = new UISurvivorPortrait(UISurvivorPortrait.SIZE_40x40,param4);
         addChild(this.mc_portait);
         this.mc_track = new Shape();
         this.mc_track.graphics.beginFill(2631204);
         this.mc_track.graphics.drawRect(0,0,this.BAR_WIDTH,this.BAR_HEIGHT);
         this.mc_track.graphics.endFill();
         this.mc_track.filters = [this.TRACK_GLOW];
         this.mc_track.cacheAsBitmap = true;
         addChildAt(this.mc_track,0);
         var _loc5_:int = 2;
         this.mc_bar = new UILargeProgressBar(param3,this.BAR_WIDTH - _loc5_ - 10,this.BAR_HEIGHT - _loc5_ * 2,this._align);
         addChildAt(this.mc_bar,getChildIndex(this.mc_track) + 1);
         this.txt_name = new BodyTextField({
            "color":16777215,
            "bold":true
         });
         this.txt_name.text = "?";
         this.txt_name.filters = [Effects.TEXT_SHADOW];
         addChild(this.txt_name);
         var _loc6_:Color = new Color(param3);
         _loc6_.adjustBrightness(1.25);
         this.txt_level = new BodyTextField({
            "color":_loc6_.RGB,
            "bold":true
         });
         this.txt_level.text = "LVL 0";
         this.txt_level.filters = [Effects.TEXT_SHADOW];
         addChild(this.txt_level);
         this.data = param1;
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         TweenMax.killChildTweensOf(this);
         this.bmp_portraitBG.bitmapData.dispose();
         this.bmp_portraitBG.bitmapData = null;
         this.bmp_portraitBG = null;
         this.txt_name.dispose();
         this.txt_name = null;
         this.txt_level.dispose();
         this.txt_level = null;
         this.mc_bar.dispose();
         this.mc_bar = null;
         this.mc_portait.dispose();
         this.mc_portait = null;
         this.mc_track.filters = [];
         this.mc_track = null;
         if(this.mc_restedArrow != null)
         {
            this.mc_restedArrow.filters = [];
         }
         AllianceSystem.getInstance().disconnected.remove(this.onAllianceSystemConnectionChanged);
         AllianceSystem.getInstance().connected.remove(this.onAllianceSystemConnectionChanged);
         this._data = null;
      }
      
      private function positionElements() : void
      {
         if(this._align == ALIGN_LEFT)
         {
            this.bmp_portraitBG.x = 0;
            this.mc_track.x = int(this.bmp_portraitBG.x + this.bmp_portraitBG.width - 10);
            this.mc_bar.x = int(this.bmp_portraitBG.x + this.bmp_portraitBG.width);
            this.txt_level.x = int(this.mc_track.x + this.mc_track.width - this.txt_level.width - 3);
            this.txt_name.x = int(this.bmp_portraitBG.x + this.bmp_portraitBG.width + 5);
            this.txt_name.maxWidth = int(this.txt_level.x - this.txt_name.x - 10);
         }
         else
         {
            this.mc_track.x = 0;
            this.mc_bar.x = int(this.mc_track.x + 2);
            this.bmp_portraitBG.x = int(this.mc_track.x + this.mc_track.width - 10);
            this.txt_level.x = int(this.mc_track.x + 3);
            this.txt_name.maxWidth = int(this.bmp_portraitBG.x - 5 - (this.txt_level.x + this.txt_level.width) - 10);
            this.txt_name.x = int(this.bmp_portraitBG.x - this.txt_name.width - 5);
         }
         this.mc_track.y = 2;
         this.mc_bar.y = int(this.mc_track.y + 2);
         if(this.mc_levelUpReminder != null)
         {
            this.mc_levelUpReminder.x = this.bmp_portraitBG.x + this.bmp_portraitBG.width;
            this.mc_levelUpReminder.y = this.mc_track.y;
         }
         this.txt_name.y = Math.round(this.mc_track.y + (this.mc_track.height - this.txt_name.height) * 0.5);
         this.txt_level.y = this.txt_name.y;
         this.mc_portait.x = int(this.bmp_portraitBG.x + 2);
         this.mc_portait.y = int(this.bmp_portraitBG.y + 2);
      }
      
      private function updateRestedXPDisplay() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(this._restedXP <= 0)
         {
            if(this.mc_restedBar != null && this.mc_restedBar.parent != null)
            {
               this.mc_restedBar.parent.removeChild(this.mc_restedBar);
            }
            if(this.mc_restedArrow != null && this.mc_restedArrow.parent != null)
            {
               this.mc_restedArrow.parent.removeChild(this.mc_restedArrow);
            }
         }
         else
         {
            if(this.mc_restedBar == null)
            {
               this.mc_restedBar = new Sprite();
               this.mc_restedBar.graphics.beginFill(8340993);
               this.mc_restedBar.graphics.drawRect(0,0,10,this.mc_bar.height);
               this.mc_restedBar.graphics.endFill();
            }
            if(this.mc_restedArrow == null)
            {
               this.mc_restedArrow = new Sprite();
               this.mc_restedArrow.graphics.beginFill(14460455);
               this.mc_restedArrow.graphics.moveTo(0,0);
               this.mc_restedArrow.graphics.lineTo(-4,-4);
               this.mc_restedArrow.graphics.lineTo(4,-4);
               this.mc_restedArrow.graphics.lineTo(0,0);
               this.mc_restedArrow.graphics.endFill();
               this.mc_restedArrow.filters = [Effects.STROKE];
            }
            if(this.mc_restedBar.parent == null)
            {
               addChildAt(this.mc_restedBar,getChildIndex(this.mc_bar));
            }
            if(this.mc_restedArrow.parent == null)
            {
               addChild(this.mc_restedArrow);
            }
            _loc1_ = this.mc_bar.x + this.mc_bar.barWidth;
            _loc2_ = this.mc_bar.width - this.mc_bar.barWidth;
            _loc3_ = Math.min(_loc2_,Math.min(this._restedXP / this.mc_bar.maxValue,1) * this.mc_bar.width);
            this.mc_restedBar.x = _loc1_;
            this.mc_restedBar.y = int(this.mc_bar.y);
            this.mc_restedBar.width = _loc3_;
            this.mc_restedArrow.x = int(this.mc_restedBar.x + this.mc_restedBar.width);
            this.mc_restedArrow.y = int(this.mc_restedBar.y);
         }
      }
      
      private function updateDisplay() : void
      {
         var _loc1_:String = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Survivor = null;
         var _loc6_:String = null;
         var _loc7_:IOpponent = null;
         var _loc8_:RemotePlayerData = null;
         if(this._data == null)
         {
            this.mc_bar.value = this.mc_bar.maxValue = 0;
            this.txt_name.text = " ";
            this.txt_level.text = " ";
         }
         else
         {
            if(this._data is Survivor)
            {
               _loc5_ = Survivor(this._data);
               _loc3_ = _loc5_.XP;
               _loc4_ = _loc5_.getXPForNextLevel();
               _loc2_ = int(_loc5_.level);
               _loc1_ = _loc5_.firstName;
               this.mc_portait.survivor = _loc5_;
               if(this._isPlayerSurvivor)
               {
                  _loc6_ = Network.getInstance().playerData.allianceTag;
                  if(_loc6_)
                  {
                     _loc1_ += " [" + _loc6_ + "]";
                  }
                  AllianceSystem.getInstance().disconnected.add(this.onAllianceSystemConnectionChanged);
                  AllianceSystem.getInstance().connected.add(this.onAllianceSystemConnectionChanged);
               }
            }
            else if(this._data is IOpponent)
            {
               _loc7_ = IOpponent(this._data);
               _loc3_ = 0;
               _loc4_ = 1;
               _loc2_ = _loc7_.level;
               this.mc_portait.survivor = null;
               if(_loc7_.isPlayer)
               {
                  _loc8_ = RemotePlayerData(_loc7_);
                  _loc1_ = _loc7_.nickname + (_loc8_.allianceTag ? " [" + _loc8_.allianceTag + "]" : "");
                  this.mc_portait.loadPortrait(_loc8_.getPortraitURI());
               }
               else
               {
                  _loc1_ = _loc7_.nickname;
                  this.mc_portait.loadPortrait(_loc7_.imageURI);
               }
               AllianceSystem.getInstance().disconnected.remove(this.onAllianceSystemConnectionChanged);
               AllianceSystem.getInstance().connected.remove(this.onAllianceSystemConnectionChanged);
            }
            this.mc_bar.maxValue = _loc4_;
            this.mc_bar.value = _loc3_;
            this.txt_level.text = Language.getInstance().getString("lvl",_loc2_ + 1);
            this.txt_name.text = _loc1_.toUpperCase();
            this.updateLevelUpReminder();
         }
         this.positionElements();
      }
      
      private function updateLevelUpReminder() : void
      {
         if(!this._isPlayerSurvivor || Network.getInstance().playerData.levelPoints <= 0)
         {
            if(this.mc_levelUpReminder != null && this.mc_levelUpReminder.parent != null)
            {
               this.mc_levelUpReminder.parent.removeChild(this.mc_levelUpReminder);
            }
            TweenMax.killTweensOf(this.txt_level);
            this.txt_level.transform.colorTransform = new ColorTransform();
         }
         else
         {
            if(this.mc_levelUpReminder != null && this.mc_levelUpReminder.parent != null)
            {
               return;
            }
            if(this.mc_levelUpReminder == null)
            {
               this.mc_levelUpReminder = new LevelUpReminder();
            }
            addChild(this.mc_levelUpReminder);
            this.positionElements();
            TweenMax.to(this.txt_level,0.25,{"colorTransform":{"exposure":1.75}});
         }
      }
      
      private function onSurvivorNameChanged(param1:Survivor) : void
      {
         var _loc3_:String = null;
         var _loc2_:String = param1.firstName;
         if(this._isPlayerSurvivor)
         {
            _loc3_ = Network.getInstance().playerData.allianceTag;
            if(_loc3_)
            {
               _loc2_ += " [" + _loc3_ + "]";
            }
         }
         this.txt_name.text = _loc2_.toUpperCase();
      }
      
      private function onLevelIncreased(param1:Survivor, param2:int) : void
      {
         this.txt_level.text = Language.getInstance().getString("lvl",param2 + 1);
         this.mc_bar.maxValue = param1.getXPForNextLevel();
         this.mc_bar.value = param1.XP;
         this.updateRestedXPDisplay();
      }
      
      private function onXPIncreased(param1:Survivor, param2:int) : void
      {
         this.mc_bar.maxValue = param1.getXPForNextLevel();
         this.mc_bar.value = param2;
         this.updateRestedXPDisplay();
      }
      
      private function onLevelUpPointsChanged() : void
      {
         this.updateLevelUpReminder();
      }
      
      private function onAllianceSystemConnectionChanged() : void
      {
         this.updateDisplay();
      }
      
      public function get data() : *
      {
         return this._data;
      }
      
      public function set data(param1:*) : void
      {
         var _loc2_:Survivor = null;
         Network.getInstance().playerData.levelUpPointsChanged.remove(this.onLevelUpPointsChanged);
         if(this._data is Survivor)
         {
            _loc2_ = Survivor(this._data);
            _loc2_.nameChanged.remove(this.onSurvivorNameChanged);
            _loc2_.levelIncreased.remove(this.onLevelIncreased);
            _loc2_.xpIncreased.remove(this.onXPIncreased);
         }
         this._data = param1;
         this._isPlayerSurvivor = false;
         if(this._data is Survivor)
         {
            this._isPlayerSurvivor = _loc2_ == Network.getInstance().playerData.getPlayerSurvivor();
            _loc2_ = Survivor(this._data);
            _loc2_.nameChanged.add(this.onSurvivorNameChanged);
            _loc2_.levelIncreased.add(this.onLevelIncreased);
            _loc2_.xpIncreased.add(this.onXPIncreased);
            if(this._isPlayerSurvivor)
            {
               Network.getInstance().playerData.levelUpPointsChanged.add(this.onLevelUpPointsChanged);
            }
         }
         this.updateDisplay();
         this.updateRestedXPDisplay();
      }
      
      public function get restedXP() : int
      {
         return this._restedXP;
      }
      
      public function set restedXP(param1:int) : void
      {
         this._restedXP = param1;
         this.updateRestedXPDisplay();
      }
   }
}

