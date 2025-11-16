package alternativa.engine3d.effects
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.BoundBox;
   import alternativa.engine3d.core.Transform3D;
   import flash.geom.Vector3D;
   
   use namespace alternativa3d;
   
   public class ParticleEffect
   {
      
      private static var randomNumbers:Vector.<Number>;
      
      private static const randomNumbersCount:int = 1000;
      
      private static const vector:Vector3D = new Vector3D();
      
      public var name:String;
      
      public var scale:Number = 1;
      
      public var boundBox:BoundBox;
      
      alternativa3d var next:ParticleEffect;
      
      alternativa3d var nextInSystem:ParticleEffect;
      
      alternativa3d var system:ParticleSystem;
      
      alternativa3d var startTime:Number;
      
      alternativa3d var lifeTime:Number = 1.7976931348623157e+308;
      
      alternativa3d var particleList:Particle;
      
      alternativa3d var aabb:BoundBox;
      
      alternativa3d var keyPosition:Vector3D;
      
      protected var keyDirection:Vector3D;
      
      protected var timeKeys:Vector.<Number>;
      
      protected var positionKeys:Vector.<Vector3D>;
      
      protected var directionKeys:Vector.<Vector3D>;
      
      protected var scriptKeys:Vector.<Function>;
      
      protected var keysCount:int = 0;
      
      private var randomOffset:int;
      
      private var randomCounter:int;
      
      private var _position:Vector3D;
      
      private var _direction:Vector3D;
      
      public function ParticleEffect()
      {
         var _loc1_:int = 0;
         this.alternativa3d::aabb = new BoundBox();
         this.timeKeys = new Vector.<Number>();
         this.positionKeys = new Vector.<Vector3D>();
         this.directionKeys = new Vector.<Vector3D>();
         this.scriptKeys = new Vector.<Function>();
         this._position = new Vector3D(0,0,0);
         this._direction = new Vector3D(0,0,1);
         super();
         if(randomNumbers == null)
         {
            randomNumbers = new Vector.<Number>();
            _loc1_ = 0;
            while(_loc1_ < randomNumbersCount)
            {
               randomNumbers[_loc1_] = Math.random();
               _loc1_++;
            }
         }
         this.randomOffset = Math.random() * randomNumbersCount;
      }
      
      public function get position() : Vector3D
      {
         return this._position.clone();
      }
      
      public function set position(param1:Vector3D) : void
      {
         this._position.x = param1.x;
         this._position.y = param1.y;
         this._position.z = param1.z;
         this._position.w = param1.w;
         if(this.alternativa3d::system != null)
         {
            this.alternativa3d::setPositionKeys(this.alternativa3d::system.alternativa3d::getTime() - this.alternativa3d::startTime);
         }
      }
      
      public function get direction() : Vector3D
      {
         return this._direction.clone();
      }
      
      public function set direction(param1:Vector3D) : void
      {
         this._direction.x = param1.x;
         this._direction.y = param1.y;
         this._direction.z = param1.z;
         this._direction.w = param1.w;
         if(this.alternativa3d::system != null)
         {
            this.alternativa3d::setDirectionKeys(this.alternativa3d::system.alternativa3d::getTime() - this.alternativa3d::startTime);
         }
      }
      
      public function stop() : void
      {
         var _loc1_:Number = this.alternativa3d::system.alternativa3d::getTime() - this.alternativa3d::startTime;
         var _loc2_:int = 0;
         while(_loc2_ < this.keysCount)
         {
            if(_loc1_ < this.timeKeys[_loc2_])
            {
               break;
            }
            _loc2_++;
         }
         this.keysCount = _loc2_;
      }
      
      protected function get particleSystem() : ParticleSystem
      {
         return this.alternativa3d::system;
      }
      
      protected function get cameraTransform() : Transform3D
      {
         return this.alternativa3d::system.alternativa3d::cameraToLocalTransform;
      }
      
      protected function random() : Number
      {
         var _loc1_:Number = randomNumbers[this.randomCounter];
         ++this.randomCounter;
         if(this.randomCounter == randomNumbersCount)
         {
            this.randomCounter = 0;
         }
         return _loc1_;
      }
      
      protected function addKey(param1:Number, param2:Function) : void
      {
         this.timeKeys[this.keysCount] = param1;
         this.positionKeys[this.keysCount] = new Vector3D();
         this.directionKeys[this.keysCount] = new Vector3D();
         this.scriptKeys[this.keysCount] = param2;
         ++this.keysCount;
      }
      
      protected function setLife(param1:Number) : void
      {
         this.alternativa3d::lifeTime = param1;
      }
      
      alternativa3d function calculateAABB() : void
      {
         this.alternativa3d::aabb.minX = this.boundBox.minX * this.scale + this._position.x;
         this.alternativa3d::aabb.minY = this.boundBox.minY * this.scale + this._position.y;
         this.alternativa3d::aabb.minZ = this.boundBox.minZ * this.scale + this._position.z;
         this.alternativa3d::aabb.maxX = this.boundBox.maxX * this.scale + this._position.x;
         this.alternativa3d::aabb.maxY = this.boundBox.maxY * this.scale + this._position.y;
         this.alternativa3d::aabb.maxZ = this.boundBox.maxZ * this.scale + this._position.z;
      }
      
      alternativa3d function setPositionKeys(param1:Number) : void
      {
         var _loc3_:Vector3D = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.keysCount)
         {
            if(param1 <= this.timeKeys[_loc2_])
            {
               _loc3_ = this.positionKeys[_loc2_];
               _loc3_.x = this._position.x;
               _loc3_.y = this._position.y;
               _loc3_.z = this._position.z;
            }
            _loc2_++;
         }
      }
      
      alternativa3d function setDirectionKeys(param1:Number) : void
      {
         var _loc3_:Vector3D = null;
         vector.x = this._direction.x;
         vector.y = this._direction.y;
         vector.z = this._direction.z;
         vector.normalize();
         var _loc2_:int = 0;
         while(_loc2_ < this.keysCount)
         {
            if(param1 <= this.timeKeys[_loc2_])
            {
               _loc3_ = this.directionKeys[_loc2_];
               _loc3_.x = vector.x;
               _loc3_.y = vector.y;
               _loc3_.z = vector.z;
            }
            _loc2_++;
         }
      }
      
      alternativa3d function calculate(param1:Number) : Boolean
      {
         var _loc3_:Number = NaN;
         var _loc4_:Function = null;
         this.randomCounter = this.randomOffset;
         var _loc2_:int = 0;
         while(_loc2_ < this.keysCount)
         {
            _loc3_ = this.timeKeys[_loc2_];
            if(param1 < _loc3_)
            {
               break;
            }
            this.alternativa3d::keyPosition = this.positionKeys[_loc2_];
            this.keyDirection = this.directionKeys[_loc2_];
            _loc4_ = this.scriptKeys[_loc2_];
            _loc4_.call(this,_loc3_,param1 - _loc3_);
            _loc2_++;
         }
         return _loc2_ < this.keysCount || this.alternativa3d::particleList != null;
      }
   }
}

