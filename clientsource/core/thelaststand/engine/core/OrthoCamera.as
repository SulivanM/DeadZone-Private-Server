package thelaststand.engine.core
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Camera3D;
   import flash.display.Stage3D;
   import flash.geom.Vector3D;
   import flash.utils.getTimer;
   
   use namespace alternativa3d;
   
   public class OrthoCamera extends Camera3D
   {
      
      private var _focalLengthSet:Boolean;
      
      private var _position:Vector3D;
      
      private var _shakeData:ShakeData;
      
      private var _viewWidth:int;
      
      private var _viewHeight:int;
      
      public function OrthoCamera(param1:Number = 100000, param2:Number = 1000000)
      {
         super(param1,param2);
         this._position = new Vector3D();
      }
      
      override public function render(param1:Stage3D) : void
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         if(!this._focalLengthSet)
         {
            super.render(param1);
            this.setFocalLength(200000);
            this._focalLengthSet = true;
         }
         var _loc2_:Number = this.getFocalLength();
         var _loc3_:Number = this._position.x;
         var _loc4_:Number = this._position.z + _loc2_;
         var _loc5_:Number = this._position.y - _loc2_ * 1.732;
         if(this._shakeData)
         {
            _loc6_ = (getTimer() - this._shakeData.timeStart) / 1000;
            if(_loc6_ < 1)
            {
               _loc7_ = this._shakeData.strength * (1 - _loc6_);
               _loc3_ += -_loc7_ + Math.random() * _loc7_ * 2;
               _loc5_ += -_loc7_ + Math.random() * _loc7_ * 2;
            }
            else
            {
               this._shakeData = null;
            }
         }
         super.x = _loc3_;
         super.y = _loc5_;
         super.z = _loc4_;
         super.render(param1);
      }
      
      public function shake(param1:Number) : void
      {
         if(!this._shakeData)
         {
            this._shakeData = new ShakeData();
         }
         this._shakeData.timeStart = getTimer();
         this._shakeData.strength = Math.min(this._shakeData.strength + param1,50);
      }
      
      private function getFocalLength() : Number
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         if(view != null && (this._viewWidth != view.width || this._viewHeight != view.height))
         {
            this._viewWidth = view.width;
            this._viewHeight = view.height;
            _loc1_ = view.width * 0.5;
            _loc2_ = view.height * 0.5;
            alternativa3d::focalLength = Math.sqrt(_loc1_ * _loc1_ + _loc2_ * _loc2_) / Math.tan(fov * 0.5);
         }
         return alternativa3d::focalLength;
      }
      
      private function setFocalLength(param1:Number) : void
      {
         if(view == null || param1 <= 0)
         {
            return;
         }
         var _loc2_:Number = view.width * 0.5;
         var _loc3_:Number = view.height * 0.5;
         fov = 2 * Math.atan2(Math.sqrt(_loc2_ * _loc2_ + _loc3_ * _loc3_),param1);
      }
      
      public function get position() : Vector3D
      {
         return this._position;
      }
      
      override public function get x() : Number
      {
         return this._position.x;
      }
      
      override public function set x(param1:Number) : void
      {
         this._position.x = param1;
      }
      
      override public function get y() : Number
      {
         return this._position.y;
      }
      
      override public function set y(param1:Number) : void
      {
         this._position.y = param1;
      }
      
      override public function get z() : Number
      {
         return this._position.z;
      }
      
      override public function set z(param1:Number) : void
      {
         this._position.z = param1;
      }
   }
}

class ShakeData
{
   
   public var timeStart:int;
   
   public var strength:Number = 0;
   
   public function ShakeData()
   {
      super();
   }
}
