package alternativa.engine3d.effects
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Camera3D;
   import alternativa.engine3d.core.Debug;
   import alternativa.engine3d.core.DrawUnit;
   import alternativa.engine3d.core.Light3D;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Renderer;
   import alternativa.engine3d.materials.compiler.Procedure;
   import flash.display3D.Context3D;
   import flash.display3D.Context3DBlendFactor;
   import flash.display3D.Context3DProgramType;
   import flash.display3D.Context3DTriangleFace;
   import flash.display3D.Context3DVertexBufferFormat;
   import flash.display3D.IndexBuffer3D;
   import flash.display3D.Program3D;
   import flash.display3D.VertexBuffer3D;
   import flash.display3D.textures.TextureBase;
   import flash.geom.Vector3D;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   
   use namespace alternativa3d;
   
   public class ParticleSystem extends Object3D
   {
      
      private static var vertexBuffer:VertexBuffer3D;
      
      private static var indexBuffer:IndexBuffer3D;
      
      private static var diffuseProgram:Program3D;
      
      private static var opacityProgram:Program3D;
      
      private static var diffuseBlendProgram:Program3D;
      
      private static var opacityBlendProgram:Program3D;
      
      private static const limit:int = 31;
      
      public var resolveByAABB:Boolean = true;
      
      public var gravity:Vector3D = new Vector3D(0,0,-1);
      
      public var wind:Vector3D = new Vector3D();
      
      public var fogColor:int = 0;
      
      public var fogMaxDensity:Number = 0;
      
      public var fogNear:Number = 0;
      
      public var fogFar:Number = 0;
      
      alternativa3d var scale:Number = 1;
      
      alternativa3d var effectList:ParticleEffect;
      
      private var drawUnit:DrawUnit = null;
      
      private var diffuse:TextureBase = null;
      
      private var opacity:TextureBase = null;
      
      private var blendSource:String = null;
      
      private var blendDestination:String = null;
      
      private var counter:int;
      
      private var za:Number;
      
      private var zb:Number;
      
      private var fake:Vector.<Object3D> = new Vector.<Object3D>();
      
      private var fakeCounter:int = 0;
      
      private var pause:Boolean = false;
      
      private var stopTime:Number;
      
      private var subtractiveTime:Number = 0;
      
      public function ParticleSystem()
      {
         super();
      }
      
      public static function disposeBuffers() : void
      {
         if(vertexBuffer != null)
         {
            vertexBuffer.dispose();
            vertexBuffer = null;
         }
         if(indexBuffer != null)
         {
            indexBuffer.dispose();
            indexBuffer = null;
         }
      }
      
      public function clear() : void
      {
         var _loc2_:ParticleEffect = null;
         var _loc1_:ParticleEffect = this.alternativa3d::effectList;
         while(_loc1_ != null)
         {
            _loc2_ = _loc1_.alternativa3d::nextInSystem;
            _loc1_.alternativa3d::nextInSystem = null;
            _loc1_.alternativa3d::system = null;
            _loc1_.alternativa3d::next = null;
            _loc1_ = _loc2_;
         }
         this.alternativa3d::effectList = null;
         this.stopTime = this.subtractiveTime = 0;
      }
      
      public function stop() : void
      {
         if(!this.pause)
         {
            this.stopTime = getTimer() * 0.001;
            this.pause = true;
         }
      }
      
      public function play() : void
      {
         if(this.pause)
         {
            this.subtractiveTime += getTimer() * 0.001 - this.stopTime;
            this.pause = false;
         }
      }
      
      public function prevFrame() : void
      {
         this.stopTime -= 0.001;
      }
      
      public function nextFrame() : void
      {
         this.stopTime += 0.001;
      }
      
      public function addEffect(param1:ParticleEffect) : ParticleEffect
      {
         if(param1.alternativa3d::system != null)
         {
            throw new Error("Cannot add the same effect twice.");
         }
         param1.alternativa3d::startTime = this.alternativa3d::getTime();
         param1.alternativa3d::system = this;
         param1.alternativa3d::setPositionKeys(0);
         param1.alternativa3d::setDirectionKeys(0);
         param1.alternativa3d::nextInSystem = this.alternativa3d::effectList;
         this.alternativa3d::effectList = param1;
         return param1;
      }
      
      public function getEffectByName(param1:String) : ParticleEffect
      {
         var _loc2_:ParticleEffect = this.alternativa3d::effectList;
         while(_loc2_ != null)
         {
            if(_loc2_.name == param1)
            {
               return _loc2_;
            }
            _loc2_ = _loc2_.alternativa3d::nextInSystem;
         }
         return null;
      }
      
      alternativa3d function getTime() : Number
      {
         return this.pause ? this.stopTime - this.subtractiveTime : getTimer() * 0.001 - this.subtractiveTime;
      }
      
      override alternativa3d function collectDraws(param1:Camera3D, param2:Vector.<Light3D>, param3:int, param4:Boolean) : void
      {
         var _loc5_:ParticleEffect = null;
         var _loc10_:Number = NaN;
         var _loc11_:int = 0;
         if(vertexBuffer == null)
         {
            this.createAndUpload(param1.alternativa3d::context3D);
         }
         this.alternativa3d::scale = Math.sqrt(alternativa3d::localToCameraTransform.a * alternativa3d::localToCameraTransform.a + alternativa3d::localToCameraTransform.e * alternativa3d::localToCameraTransform.e + alternativa3d::localToCameraTransform.i * alternativa3d::localToCameraTransform.i);
         this.alternativa3d::scale += Math.sqrt(alternativa3d::localToCameraTransform.b * alternativa3d::localToCameraTransform.b + alternativa3d::localToCameraTransform.f * alternativa3d::localToCameraTransform.f + alternativa3d::localToCameraTransform.j * alternativa3d::localToCameraTransform.j);
         this.alternativa3d::scale += Math.sqrt(alternativa3d::localToCameraTransform.c * alternativa3d::localToCameraTransform.c + alternativa3d::localToCameraTransform.g * alternativa3d::localToCameraTransform.g + alternativa3d::localToCameraTransform.k * alternativa3d::localToCameraTransform.k);
         this.alternativa3d::scale /= 3;
         param1.alternativa3d::calculateFrustum(alternativa3d::cameraToLocalTransform);
         var _loc6_:Boolean = false;
         var _loc7_:Number = this.alternativa3d::getTime();
         var _loc8_:ParticleEffect = this.alternativa3d::effectList;
         var _loc9_:ParticleEffect = null;
         while(_loc8_ != null)
         {
            _loc10_ = _loc7_ - _loc8_.alternativa3d::startTime;
            if(_loc10_ <= _loc8_.alternativa3d::lifeTime)
            {
               _loc11_ = 63;
               if(_loc8_.boundBox != null)
               {
                  _loc8_.alternativa3d::calculateAABB();
                  _loc11_ = _loc8_.alternativa3d::aabb.alternativa3d::checkFrustumCulling(param1.alternativa3d::frustum,63);
               }
               if(_loc11_ >= 0)
               {
                  if(_loc8_.alternativa3d::calculate(_loc10_))
                  {
                     if(_loc8_.alternativa3d::particleList != null)
                     {
                        _loc8_.alternativa3d::next = _loc5_;
                        _loc5_ = _loc8_;
                        _loc6_ ||= _loc8_.boundBox == null;
                     }
                     _loc9_ = _loc8_;
                     _loc8_ = _loc8_.alternativa3d::nextInSystem;
                  }
                  else if(_loc9_ != null)
                  {
                     _loc9_.alternativa3d::nextInSystem = _loc8_.alternativa3d::nextInSystem;
                     _loc8_ = _loc9_.alternativa3d::nextInSystem;
                  }
                  else
                  {
                     this.alternativa3d::effectList = _loc8_.alternativa3d::nextInSystem;
                     _loc8_ = this.alternativa3d::effectList;
                  }
               }
               else
               {
                  _loc9_ = _loc8_;
                  _loc8_ = _loc8_.alternativa3d::nextInSystem;
               }
            }
            else if(_loc9_ != null)
            {
               _loc9_.alternativa3d::nextInSystem = _loc8_.alternativa3d::nextInSystem;
               _loc8_ = _loc9_.alternativa3d::nextInSystem;
            }
            else
            {
               this.alternativa3d::effectList = _loc8_.alternativa3d::nextInSystem;
               _loc8_ = this.alternativa3d::effectList;
            }
         }
         if(_loc5_ != null)
         {
            if(_loc5_.alternativa3d::next != null)
            {
               this.drawConflictEffects(param1,_loc5_);
            }
            else
            {
               this.drawParticleList(param1,_loc5_.alternativa3d::particleList);
               _loc5_.alternativa3d::particleList = null;
               if(param1.debug && _loc5_.boundBox != null && Boolean(param1.alternativa3d::checkInDebug(this) & Debug.BOUNDS))
               {
                  Debug.alternativa3d::drawBoundBox(param1,_loc5_.alternativa3d::aabb,alternativa3d::localToCameraTransform);
               }
            }
            this.flush(param1);
            this.drawUnit = null;
            this.diffuse = null;
            this.opacity = null;
            this.blendSource = null;
            this.blendDestination = null;
            this.fakeCounter = 0;
         }
      }
      
      private function createAndUpload(param1:Context3D) : void
      {
         var _loc2_:Vector.<Number> = new Vector.<Number>();
         var _loc3_:Vector.<uint> = new Vector.<uint>();
         var _loc4_:int = 0;
         while(_loc4_ < limit)
         {
            _loc2_.push(0,0,0,0,0,_loc4_ * 4,0,1,0,0,1,_loc4_ * 4,1,1,0,1,1,_loc4_ * 4,1,0,0,1,0,_loc4_ * 4);
            _loc3_.push(_loc4_ * 4,_loc4_ * 4 + 1,_loc4_ * 4 + 3,_loc4_ * 4 + 2,_loc4_ * 4 + 3,_loc4_ * 4 + 1);
            _loc4_++;
         }
         vertexBuffer = param1.createVertexBuffer(limit * 4,6);
         vertexBuffer.uploadFromVector(_loc2_,0,limit * 4);
         indexBuffer = param1.createIndexBuffer(limit * 6);
         indexBuffer.uploadFromVector(_loc3_,0,limit * 6);
         var _loc5_:Array = ["mov t2, c[a1.z]","sub t0.z, a0.x, t2.x","sub t0.w, a0.y, t2.y","mul t0.z, t0.z, t2.z","mul t0.w, t0.w, t2.w","mov t2, c[a1.z+1]","mov t1.z, t2.w","sin t1.x, t1.z","cos t1.y, t1.z","mul t1.z, t0.z, t1.y","mul t1.w, t0.w, t1.x","sub t0.x, t1.z, t1.w","mul t1.z, t0.z, t1.x","mul t1.w, t0.w, t1.y","add t0.y, t1.z, t1.w","add t0.x, t0.x, t2.x","add t0.y, t0.y, t2.y","add t0.z, a0.z, t2.z","mov t0.w, a0.w","dp4 o0.x, t0, c124","dp4 o0.y, t0, c125","dp4 o0.z, t0, c126","dp4 o0.w, t0, c127","mov t2, c[a1.z+2]","mul t1.x, a1.x, t2.x","mul t1.y, a1.y, t2.y","add t1.x, t1.x, t2.z","add t1.y, t1.y, t2.w","mov v0, t1","mov v1, c[a1.z+3]","mov v2, t0"];
         var _loc6_:Array = ["tex t0, v0, s0 <2d,clamp,linear,miplinear>","mul t0, t0, v1","sub t1.w, v2.z, c1.x","div t1.w, t1.w, c1.y","max t1.w, t1.w, c1.z","min t1.w, t1.w, c0.w","sub t1.xyz, c0.xyz, t0.xyz","mul t1.xyz, t1.xyz, t1.w","add t0.xyz, t0.xyz, t1.xyz","mov o0, t0"];
         var _loc7_:Array = ["tex t0, v0, s0 <2d,clamp,linear,miplinear>","tex t1, v0, s1 <2d,clamp,linear,miplinear>","mov t0.w, t1.x","mul t0, t0, v1","sub t1.w, v2.z, c1.x","div t1.w, t1.w, c1.y","max t1.w, t1.w, c1.z","min t1.w, t1.w, c0.w","sub t1.xyz, c0.xyz, t0.xyz","mul t1.xyz, t1.xyz, t1.w","add t0.xyz, t0.xyz, t1.xyz","mov o0, t0"];
         var _loc8_:Array = ["tex t0, v0, s0 <2d,clamp,linear,miplinear>","mul t0, t0, v1","sub t1.w, v2.z, c1.x","div t1.w, t1.w, c1.y","max t1.w, t1.w, c1.z","min t1.w, t1.w, c0.w","sub t1.w, c1.w, t1.w","mul t0.w, t0.w, t1.w","mov o0, t0"];
         var _loc9_:Array = ["tex t0, v0, s0 <2d,clamp,linear,miplinear>","tex t1, v0, s1 <2d,clamp,linear,miplinear>","mov t0.w, t1.x","mul t0, t0, v1","sub t1.w, v2.z, c1.x","div t1.w, t1.w, c1.y","max t1.w, t1.w, c1.z","min t1.w, t1.w, c0.w","sub t1.w, c1.w, t1.w","mul t0.w, t0.w, t1.w","mov o0, t0"];
         diffuseProgram = param1.createProgram();
         opacityProgram = param1.createProgram();
         diffuseBlendProgram = param1.createProgram();
         opacityBlendProgram = param1.createProgram();
         var _loc10_:ByteArray = this.compileProgram(Context3DProgramType.VERTEX,_loc5_);
         diffuseProgram.upload(_loc10_,this.compileProgram(Context3DProgramType.FRAGMENT,_loc6_));
         opacityProgram.upload(_loc10_,this.compileProgram(Context3DProgramType.FRAGMENT,_loc7_));
         diffuseBlendProgram.upload(_loc10_,this.compileProgram(Context3DProgramType.FRAGMENT,_loc8_));
         opacityBlendProgram.upload(_loc10_,this.compileProgram(Context3DProgramType.FRAGMENT,_loc9_));
      }
      
      private function compileProgram(param1:String, param2:Array) : ByteArray
      {
         var _loc3_:Procedure = new Procedure(param2);
         return _loc3_.getByteCode(param1);
      }
      
      private function flush(param1:Camera3D) : void
      {
         if(this.fakeCounter == this.fake.length)
         {
            this.fake[this.fakeCounter] = new Object3D();
         }
         var _loc2_:Object3D = this.fake[this.fakeCounter];
         ++this.fakeCounter;
         _loc2_.alternativa3d::localToCameraTransform.l = (this.za + this.zb) / 2;
         this.drawUnit.alternativa3d::object = _loc2_;
         this.drawUnit.alternativa3d::numTriangles = this.counter << 1;
         if(this.blendDestination == Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA)
         {
            this.drawUnit.alternativa3d::program = this.opacity != null ? opacityProgram : diffuseProgram;
         }
         else
         {
            this.drawUnit.alternativa3d::program = this.opacity != null ? opacityBlendProgram : diffuseBlendProgram;
         }
         this.drawUnit.alternativa3d::setVertexBufferAt(0,vertexBuffer,0,Context3DVertexBufferFormat.FLOAT_3);
         this.drawUnit.alternativa3d::setVertexBufferAt(1,vertexBuffer,3,Context3DVertexBufferFormat.FLOAT_3);
         this.drawUnit.alternativa3d::setProjectionConstants(param1,124);
         this.drawUnit.alternativa3d::setFragmentConstantsFromNumbers(0,(this.fogColor >> 16 & 0xFF) / 255,(this.fogColor >> 8 & 0xFF) / 255,(this.fogColor & 0xFF) / 255,this.fogMaxDensity);
         this.drawUnit.alternativa3d::setFragmentConstantsFromNumbers(1,this.fogNear,this.fogFar - this.fogNear,0,1);
         this.drawUnit.alternativa3d::setTextureAt(0,this.diffuse);
         if(this.opacity != null)
         {
            this.drawUnit.alternativa3d::setTextureAt(1,this.opacity);
         }
         this.drawUnit.alternativa3d::blendSource = this.blendSource;
         this.drawUnit.alternativa3d::blendDestination = this.blendDestination;
         this.drawUnit.alternativa3d::culling = Context3DTriangleFace.NONE;
         param1.renderer.alternativa3d::addDrawUnit(this.drawUnit,Renderer.TRANSPARENT_SORT);
      }
      
      private function drawParticleList(param1:Camera3D, param2:Particle) : void
      {
         var _loc3_:Particle = null;
         var _loc5_:* = 0;
         if(param2.next != null)
         {
            param2 = this.sortParticleList(param2);
         }
         var _loc4_:Particle = param2;
         while(_loc4_ != null)
         {
            if(this.counter >= limit || _loc4_.diffuse != this.diffuse || _loc4_.opacity != this.opacity || _loc4_.blendSource != this.blendSource || _loc4_.blendDestination != this.blendDestination)
            {
               if(this.drawUnit != null)
               {
                  this.flush(param1);
               }
               this.drawUnit = param1.renderer.alternativa3d::createDrawUnit(null,null,indexBuffer,0,0);
               this.diffuse = _loc4_.diffuse;
               this.opacity = _loc4_.opacity;
               this.blendSource = _loc4_.blendSource;
               this.blendDestination = _loc4_.blendDestination;
               this.counter = 0;
               this.za = _loc4_.z;
            }
            _loc5_ = this.counter << 2;
            this.drawUnit.alternativa3d::setVertexConstantsFromNumbers(_loc5_++,_loc4_.originX,_loc4_.originY,_loc4_.width,_loc4_.height);
            this.drawUnit.alternativa3d::setVertexConstantsFromNumbers(_loc5_++,_loc4_.x,_loc4_.y,_loc4_.z,_loc4_.rotation);
            this.drawUnit.alternativa3d::setVertexConstantsFromNumbers(_loc5_++,_loc4_.uvScaleX,_loc4_.uvScaleY,_loc4_.uvOffsetX,_loc4_.uvOffsetY);
            this.drawUnit.alternativa3d::setVertexConstantsFromNumbers(_loc5_++,_loc4_.red,_loc4_.green,_loc4_.blue,_loc4_.alpha);
            ++this.counter;
            this.zb = _loc4_.z;
            _loc3_ = _loc4_;
            _loc4_ = _loc4_.next;
         }
         _loc3_.next = Particle.collector;
         Particle.collector = param2;
      }
      
      private function sortParticleList(param1:Particle) : Particle
      {
         var _loc2_:Particle = param1;
         var _loc3_:Particle = param1.next;
         while(_loc3_ != null && _loc3_.next != null)
         {
            param1 = param1.next;
            _loc3_ = _loc3_.next.next;
         }
         _loc3_ = param1.next;
         param1.next = null;
         if(_loc2_.next != null)
         {
            _loc2_ = this.sortParticleList(_loc2_);
         }
         if(_loc3_.next != null)
         {
            _loc3_ = this.sortParticleList(_loc3_);
         }
         var _loc4_:* = _loc2_.z > _loc3_.z;
         if(_loc4_)
         {
            param1 = _loc2_;
            _loc2_ = _loc2_.next;
         }
         else
         {
            param1 = _loc3_;
            _loc3_ = _loc3_.next;
         }
         var _loc5_:Particle = param1;
         while(_loc2_ != null)
         {
            if(_loc3_ == null)
            {
               _loc5_.next = _loc2_;
               return param1;
            }
            if(_loc4_)
            {
               if(_loc2_.z > _loc3_.z)
               {
                  _loc5_ = _loc2_;
                  _loc2_ = _loc2_.next;
               }
               else
               {
                  _loc5_.next = _loc3_;
                  _loc5_ = _loc3_;
                  _loc3_ = _loc3_.next;
                  _loc4_ = false;
               }
            }
            else if(_loc3_.z > _loc2_.z)
            {
               _loc5_ = _loc3_;
               _loc3_ = _loc3_.next;
            }
            else
            {
               _loc5_.next = _loc2_;
               _loc5_ = _loc2_;
               _loc2_ = _loc2_.next;
               _loc4_ = true;
            }
         }
         _loc5_.next = _loc3_;
         return param1;
      }
      
      private function drawConflictEffects(param1:Camera3D, param2:ParticleEffect) : void
      {
         var _loc3_:Particle = null;
         var _loc5_:ParticleEffect = null;
         var _loc6_:Particle = null;
         var _loc4_:ParticleEffect = param2;
         while(_loc4_ != null)
         {
            _loc5_ = _loc4_.alternativa3d::next;
            _loc4_.alternativa3d::next = null;
            _loc6_ = _loc4_.alternativa3d::particleList;
            while(_loc6_.next != null)
            {
               _loc6_ = _loc6_.next;
            }
            _loc6_.next = _loc3_;
            _loc3_ = _loc4_.alternativa3d::particleList;
            _loc4_.alternativa3d::particleList = null;
            if(param1.debug && _loc4_.boundBox != null && Boolean(param1.alternativa3d::checkInDebug(this) & Debug.BOUNDS))
            {
               Debug.alternativa3d::drawBoundBox(param1,_loc4_.alternativa3d::aabb,alternativa3d::localToCameraTransform,16711680);
            }
            _loc4_ = _loc5_;
         }
         this.drawParticleList(param1,_loc3_);
      }
   }
}

