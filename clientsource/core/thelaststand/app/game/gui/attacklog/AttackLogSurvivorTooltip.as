package thelaststand.app.game.gui.attacklog
{
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.SurvivorLoadout;
   import thelaststand.app.game.gui.UISurvivorPortrait;
   import thelaststand.app.game.gui.loadout.UIMissionSurvivorSlot;
   import thelaststand.common.lang.Language;
   
   public class AttackLogSurvivorTooltip extends Sprite
   {
      
      private var container:Sprite;
      
      private var txt_vs:BodyTextField;
      
      private var slot1:UIMissionSurvivorSlot;
      
      private var slot2:UIMissionSurvivorSlot;
      
      public function AttackLogSurvivorTooltip()
      {
         super();
         this.container = new Sprite();
         this.container.filters = [Effects.ICON_SHADOW];
         addChild(this.container);
         this.slot1 = new UIMissionSurvivorSlot(UIMissionSurvivorSlot.SHOW_NONE,170,46,UISurvivorPortrait.SIZE_32x32,true);
         this.slot1.x = this.slot1.y = 4;
         this.container.addChild(this.slot1);
         this.txt_vs = new BodyTextField();
         this.txt_vs.text = Language.getInstance().getString("attack_log_vs");
         this.txt_vs.x = this.slot1.x + this.slot1.width + 4;
         this.txt_vs.y = this.slot1.y + int((this.slot1.height - this.txt_vs.height) * 0.5);
         this.slot2 = new UIMissionSurvivorSlot(UIMissionSurvivorSlot.SHOW_NONE,170,46,UISurvivorPortrait.SIZE_32x32,true);
         this.slot2.x = this.txt_vs.x + this.txt_vs.width + 4;
         this.slot2.y = this.slot1.y;
         addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
      }
      
      public function dispose() : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
         this.slot1.dispose();
         this.slot2.dispose();
         this.txt_vs.dispose();
         removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
      }
      
      public function populate(param1:Survivor, param2:SurvivorLoadout, param3:Survivor, param4:SurvivorLoadout, param5:Number, param6:Number = 0) : void
      {
         this.slot1.setSurvivor(param1,param2);
         var _loc7_:Number = this.slot1.x * 2 + this.slot1.width;
         var _loc8_:Number = this.slot1.y * 2 + this.slot1.height;
         if(param3 == null || param1 == param3)
         {
            if(this.slot2.parent)
            {
               this.slot2.parent.removeChild(this.slot2);
            }
            if(this.txt_vs.parent)
            {
               this.txt_vs.parent.removeChild(this.txt_vs);
            }
         }
         else
         {
            this.slot2.setSurvivor(param3,param4);
            this.container.addChild(this.slot2);
            this.container.addChild(this.txt_vs);
            _loc7_ = this.slot2.x + this.slot2.width + this.slot1.x;
         }
         var _loc9_:Graphics = this.container.graphics;
         _loc9_.clear();
         _loc9_.beginFill(7237230,1);
         _loc9_.drawRect(0,0,_loc7_,_loc8_);
         _loc9_.beginFill(2171169,1);
         _loc9_.drawRect(1,1,_loc7_ - 2,_loc8_ - 2);
         _loc9_.endFill();
         graphics.clear();
         graphics.beginFill(16711680,0);
         graphics.drawRect(int((_loc7_ - param5) * 0.5),_loc8_,param5,param6);
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         if(parent)
         {
            parent.removeChild(this);
         }
      }
      
      public function get panelOnlyWidth() : Number
      {
         return this.container.width;
      }
      
      public function get panelOnlyHeight() : Number
      {
         return this.container.height;
      }
   }
}

