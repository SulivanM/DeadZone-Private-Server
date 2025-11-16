package thelaststand.app.game.gui.attacklog
{
   import flash.display.Sprite;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.gui.UISurvivorPortrait;
   import thelaststand.app.game.gui.loadout.UIMissionSurvivorSlot;
   import thelaststand.app.gui.UITitleBar;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.common.lang.Language;
   
   public class AttackLogSurvivorList extends Sprite
   {
      
      public static const ATTACKERS:String = "attackers";
      
      public static const DEFENDERS:String = "defenders";
      
      private var titleBar:UITitleBar;
      
      private var title:TitleTextField;
      
      private var _lang:Language;
      
      private var _slots:Vector.<UIMissionSurvivorSlot>;
      
      private var _type:String;
      
      public function AttackLogSurvivorList(param1:String, param2:String)
      {
         var _loc9_:int = 0;
         var _loc10_:UIMissionSurvivorSlot = null;
         super();
         var _loc3_:Number = param1 == ATTACKERS ? 182 : 362;
         var _loc4_:Number = 278;
         this._type = param1;
         this._lang = Language.getInstance();
         GraphicUtils.drawUIBlock(this.graphics,_loc3_,_loc4_);
         this.titleBar = new UITitleBar(null,2236962);
         this.titleBar.x = this.titleBar.y = 4;
         this.titleBar.width = _loc3_ - 8;
         this.titleBar.height = 28;
         addChild(this.titleBar);
         this.title = new TitleTextField({
            "color":10066329,
            "size":16
         });
         this.title.text = this._lang.getString(param1 == ATTACKERS ? "attack_log_combatants_attackersTitle" : "attack_log_combatants_defendersTitle",param2);
         this.title.x = this.titleBar.x + int((this.titleBar.width - this.title.width) * 0.5);
         this.title.y = this.titleBar.y + int((this.titleBar.height - this.title.height) * 0.5);
         addChild(this.title);
         this._slots = new Vector.<UIMissionSurvivorSlot>();
         var _loc5_:int = param1 == ATTACKERS ? 1 : 2;
         var _loc6_:Number = 6;
         var _loc7_:Number = 0;
         var _loc8_:int = 0;
         while(_loc8_ < _loc5_)
         {
            _loc7_ = this.title.y + this.title.height + 8;
            _loc9_ = 0;
            while(_loc9_ < 5)
            {
               _loc10_ = new UIMissionSurvivorSlot(UIMissionSurvivorSlot.SHOW_NONE,170,46,UISurvivorPortrait.SIZE_32x32,true);
               _loc10_.x = _loc6_;
               _loc10_.y = _loc7_;
               addChild(_loc10_);
               this._slots.push(_loc10_);
               _loc7_ += 48;
               _loc9_++;
            }
            _loc6_ += 178;
            _loc8_++;
         }
      }
      
      public function dispose() : void
      {
         var _loc1_:UIMissionSurvivorSlot = null;
         this._lang = null;
         this.titleBar.dispose();
         this.title.dispose();
         for each(_loc1_ in this._slots)
         {
            _loc1_.dispose();
         }
         this._slots = null;
      }
      
      public function populate(param1:Vector.<Survivor>) : void
      {
         var _loc3_:UIMissionSurvivorSlot = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._slots.length)
         {
            _loc3_ = this._slots[_loc2_];
            if(_loc2_ < param1.length)
            {
               _loc3_.setSurvivor(param1[_loc2_],this._type == DEFENDERS ? param1[_loc2_].loadoutDefence : param1[_loc2_].loadoutOffence);
               _loc3_.alpha = 1;
            }
            else
            {
               _loc3_.setSurvivor(null,null);
               _loc3_.alpha = 0.3;
            }
            _loc2_++;
         }
      }
   }
}

