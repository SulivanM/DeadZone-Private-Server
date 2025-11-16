package thelaststand.app.game.logic.ai
{
   import flash.geom.Vector3D;
   import thelaststand.app.core.Config;
   
   public class NoiseSource
   {
      
      private var _decayRate:Number = 0;
      
      private var _decayRateModifier:Number = 1;
      
      private var _disposed:Boolean;
      
      public var position:Vector3D;
      
      public var volume:Number = 0;
      
      public var time:Number = 0;
      
      public var owner:AIAgent;
      
      public var id:String;
      
      public function NoiseSource()
      {
         super();
         this.position = new Vector3D();
         this._decayRate = Config.constant.NOISE_DECAY_RATE * this._decayRateModifier;
      }
      
      public function get isDisposed() : Boolean
      {
         return this._disposed;
      }
      
      public function dispose() : void
      {
         if(this._disposed)
         {
            return;
         }
         this._disposed = true;
         this.position = null;
         this.owner = null;
      }
      
      public function update(param1:Number) : void
      {
         this.volume -= this._decayRate * param1;
         if(this.volume < 0)
         {
            this.volume = 0;
            return;
         }
      }
      
      public function get decayRateModifier() : Number
      {
         return this._decayRateModifier;
      }
      
      public function set decayRateModifier(param1:Number) : void
      {
         this._decayRateModifier = param1;
         this._decayRate = Config.constant.NOISE_DECAY_RATE * this._decayRateModifier;
      }
   }
}

