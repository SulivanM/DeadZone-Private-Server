package thelaststand.app.game.gui.survivor
{
   import flash.display.BitmapData;
   import flash.display.Shape;
   import thelaststand.app.game.data.Survivor;
   import thelaststand.app.game.data.injury.Injury;
   import thelaststand.app.game.gui.UISimpleProgressBar;
   
   public class UISurvivorHealthBarLarge extends UISimpleProgressBar
   {
      
      private static var BmdInjuryFill:BitmapData = new BmpHealthBarInjury();
      
      private const COLOR_BAD:uint = 15597568;
      
      private const COLOR_GOOD:uint = 5692748;
      
      private var _survivor:Survivor;
      
      private var _injuryDamge:Number = 0;
      
      private var mc_injury:Shape;
      
      public function UISurvivorHealthBarLarge(param1:Survivor = null)
      {
         super(this.COLOR_GOOD);
         mouseEnabled = mouseChildren = false;
         if(param1 != null)
         {
            this.survivor = param1;
         }
         this.mc_injury = new Shape();
         addChild(this.mc_injury);
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
         if(this._survivor != null)
         {
            this._survivor.healthChanged.remove(this.onHealthChanged);
            this._survivor.injuries.added.remove(this.onInjuryAdded);
         }
         this._survivor = param1;
         this._survivor.healthChanged.add(this.onHealthChanged);
         this._survivor.injuries.added.add(this.onInjuryAdded);
         this.updateInjuries();
         this.updateHealth();
      }
      
      override public function dispose() : void
      {
         super.dispose();
         if(this._survivor != null)
         {
            this._survivor.healthChanged.remove(this.onHealthChanged);
            this._survivor.injuries.added.remove(this.onInjuryAdded);
            this._survivor = null;
         }
      }
      
      override protected function draw() : void
      {
         super.draw();
         this.mc_injury.graphics.clear();
         this.mc_injury.graphics.beginBitmapFill(BmdInjuryFill);
         this.mc_injury.graphics.drawRect(0,0,width * this._injuryDamge,height);
         this.mc_injury.graphics.endFill();
         this.mc_injury.x = width - this.mc_injury.width;
      }
      
      private function updateInjuries() : void
      {
         this._injuryDamge = this._survivor.getInjuryDamage() / this._survivor.maxHealth;
         invalidate();
      }
      
      private function updateHealth() : void
      {
         var _loc1_:Number = this._survivor.maxHealth;
         progress = this._survivor.health / _loc1_;
         colorBar = this._survivor.health < _loc1_ * 0.5 ? this.COLOR_BAD : this.COLOR_GOOD;
      }
      
      private function onHealthChanged(param1:Survivor) : void
      {
         this.updateHealth();
      }
      
      private function onInjuryAdded(param1:Survivor, param2:Injury) : void
      {
         this.updateInjuries();
         this.updateHealth();
      }
   }
}

