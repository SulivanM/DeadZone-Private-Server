package thelaststand.app.game.gui.survivor
{
   import com.exileetiquette.utils.NumberFormatter;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.utils.getDefinitionByName;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.gui.UISimpleProgressBar;
   import thelaststand.app.gui.TooltipDirection;
   import thelaststand.app.gui.TooltipManager;
   import thelaststand.common.lang.Language;
   
   public class UISurvivorInfoOverview extends Sprite
   {
      
      private var txt_srvName:BodyTextField;
      
      private var txt_srvLevel:BodyTextField;
      
      private var txt_srvClass:BodyTextField;
      
      private var ui_xp:UISimpleProgressBar;
      
      private var bmp_classIcon:Bitmap;
      
      private var _survivor:Survivor;
      
      private var _lang:Language;
      
      public function UISurvivorInfoOverview()
      {
         super();
         this._lang = Language.getInstance();
         this.bmp_classIcon = new Bitmap();
         this.txt_srvName = new BodyTextField({
            "color":16777215,
            "size":13,
            "bold":true,
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_srvClass = new BodyTextField({
            "color":12237498,
            "size":12,
            "bold":true
         });
         this.txt_srvLevel = new BodyTextField({
            "color":16434707,
            "size":12,
            "bold":true
         });
         this.ui_xp = new UISimpleProgressBar(16434707,0);
      }
      
      public function get survivor() : Survivor
      {
         return this._survivor;
      }
      
      public function set survivor(param1:Survivor) : void
      {
         if(param1 == this._survivor)
         {
            return;
         }
         this._survivor = param1;
         this.update();
      }
      
      public function dispose() : void
      {
         TooltipManager.getInstance().removeAllFromParent(this);
         if(parent != null)
         {
            parent.removeChild(this);
         }
         this._lang = null;
         this.txt_srvName.dispose();
         this.txt_srvLevel.dispose();
         this.txt_srvClass.dispose();
         this.ui_xp.dispose();
         if(this.bmp_classIcon.bitmapData != null)
         {
            this.bmp_classIcon.bitmapData.dispose();
         }
      }
      
      private function update() : void
      {
         if(this.bmp_classIcon.bitmapData != null)
         {
            this.bmp_classIcon.bitmapData.dispose();
         }
         this.txt_srvName.x = this.txt_srvName.y = 0;
         this.txt_srvName.text = this._survivor.fullName.toUpperCase();
         addChild(this.txt_srvName);
         var _loc1_:Class = getDefinitionByName("BmpIconClass_" + this.survivor.classId) as Class;
         if(_loc1_ != null)
         {
            this.bmp_classIcon.bitmapData = new _loc1_();
            this.bmp_classIcon.x = this.txt_srvName.x;
            this.bmp_classIcon.y = int(this.txt_srvName.y + this.txt_srvName.height);
            addChild(this.bmp_classIcon);
         }
         this.txt_srvClass.text = this._lang.getString("survivor_classes." + this._survivor.classId).toUpperCase();
         this.txt_srvClass.x = this.bmp_classIcon.bitmapData != null ? this.bmp_classIcon.x + this.bmp_classIcon.width + 2 : this.txt_srvName.x;
         this.txt_srvClass.y = int(this.txt_srvName.y + this.txt_srvName.height - 1);
         this.txt_srvClass.filters = [Effects.TEXT_SHADOW_DARK];
         addChild(this.txt_srvClass);
         this.txt_srvLevel.text = this._lang.getString("lvl",this._survivor.level + 1) + (this._survivor.level >= this.survivor.levelMax ? " (" + this._lang.getString("max").toUpperCase() + ")" : "");
         this.txt_srvLevel.x = int(this.txt_srvClass.x + this.txt_srvClass.width + 8);
         this.txt_srvLevel.y = this.txt_srvClass.y;
         this.txt_srvLevel.filters = [Effects.TEXT_SHADOW_DARK];
         addChild(this.txt_srvLevel);
         this.ui_xp.width = 35;
         this.ui_xp.height = 5;
         this.ui_xp.x = int(this.txt_srvLevel.x + this.txt_srvLevel.width + 6);
         this.ui_xp.y = int(this.txt_srvLevel.y + (this.txt_srvLevel.height - this.ui_xp.height) * 0.5) + 1;
         this.ui_xp.progress = this._survivor.XP / this._survivor.getXPForNextLevel();
         addChild(this.ui_xp);
         if(this.survivor.level >= this.survivor.levelMax)
         {
            TooltipManager.getInstance().remove(this.ui_xp);
         }
         else
         {
            TooltipManager.getInstance().add(this.ui_xp,this.getXPTooltip,new Point(this.ui_xp.width,NaN),TooltipDirection.DIRECTION_LEFT);
         }
      }
      
      private function getXPTooltip() : String
      {
         var _loc1_:String = NumberFormatter.format(this._survivor.XP,0) + " / " + NumberFormatter.format(this._survivor.getXPForNextLevel(),0);
         return this._lang.getString("tooltip.xp_srv",_loc1_);
      }
   }
}

