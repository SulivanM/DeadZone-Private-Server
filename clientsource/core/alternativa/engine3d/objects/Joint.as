package alternativa.engine3d.objects
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.core.Object3D;
   import alternativa.engine3d.core.Transform3D;
   import flash.geom.Matrix3D;
   
   use namespace alternativa3d;
   
   public class Joint extends Object3D
   {
      
      alternativa3d var jointTransform:Transform3D = new Transform3D();
      
      alternativa3d var bindPoseTransform:Transform3D = new Transform3D();
      
      public function Joint()
      {
         super();
      }
      
      alternativa3d function setBindPoseMatrix(param1:Vector.<Number>) : void
      {
         this.alternativa3d::bindPoseTransform.initFromVector(param1);
      }
      
      public function get bindingMatrix() : Matrix3D
      {
         return new Matrix3D(Vector.<Number>([this.alternativa3d::bindPoseTransform.a,this.alternativa3d::bindPoseTransform.e,this.alternativa3d::bindPoseTransform.i,0,this.alternativa3d::bindPoseTransform.b,this.alternativa3d::bindPoseTransform.f,this.alternativa3d::bindPoseTransform.j,0,this.alternativa3d::bindPoseTransform.c,this.alternativa3d::bindPoseTransform.g,this.alternativa3d::bindPoseTransform.k,0,this.alternativa3d::bindPoseTransform.d,this.alternativa3d::bindPoseTransform.h,this.alternativa3d::bindPoseTransform.l,1]));
      }
      
      public function set bindingMatrix(param1:Matrix3D) : void
      {
         var _loc2_:Vector.<Number> = null;
         _loc2_ = param1.rawData;
         this.alternativa3d::bindPoseTransform.a = _loc2_[0];
         this.alternativa3d::bindPoseTransform.b = _loc2_[4];
         this.alternativa3d::bindPoseTransform.c = _loc2_[8];
         this.alternativa3d::bindPoseTransform.d = _loc2_[12];
         this.alternativa3d::bindPoseTransform.e = _loc2_[1];
         this.alternativa3d::bindPoseTransform.f = _loc2_[5];
         this.alternativa3d::bindPoseTransform.g = _loc2_[9];
         this.alternativa3d::bindPoseTransform.h = _loc2_[13];
         this.alternativa3d::bindPoseTransform.i = _loc2_[2];
         this.alternativa3d::bindPoseTransform.j = _loc2_[6];
         this.alternativa3d::bindPoseTransform.k = _loc2_[10];
         this.alternativa3d::bindPoseTransform.l = _loc2_[14];
      }
      
      alternativa3d function calculateBindingMatrices() : void
      {
         var _loc2_:Joint = null;
         var _loc1_:Object3D = alternativa3d::childrenList;
         while(_loc1_ != null)
         {
            _loc2_ = _loc1_ as Joint;
            if(_loc2_ != null)
            {
               if(_loc2_.alternativa3d::transformChanged)
               {
                  _loc2_.alternativa3d::composeTransforms();
               }
               _loc2_.alternativa3d::bindPoseTransform.combine(this.alternativa3d::bindPoseTransform,_loc2_.alternativa3d::inverseTransform);
               _loc2_.alternativa3d::calculateBindingMatrices();
            }
            _loc1_ = _loc1_.alternativa3d::next;
         }
      }
      
      alternativa3d function calculateTransform() : void
      {
         if(this.alternativa3d::bindPoseTransform != null)
         {
            this.alternativa3d::jointTransform.combine(alternativa3d::localToGlobalTransform,this.alternativa3d::bindPoseTransform);
         }
      }
      
      override public function clone() : Object3D
      {
         var _loc1_:Joint = new Joint();
         _loc1_.clonePropertiesFrom(this);
         return _loc1_;
      }
      
      override protected function clonePropertiesFrom(param1:Object3D) : void
      {
         var _loc2_:Joint = null;
         super.clonePropertiesFrom(param1);
         _loc2_ = param1 as Joint;
         this.alternativa3d::bindPoseTransform.a = _loc2_.alternativa3d::bindPoseTransform.a;
         this.alternativa3d::bindPoseTransform.b = _loc2_.alternativa3d::bindPoseTransform.b;
         this.alternativa3d::bindPoseTransform.c = _loc2_.alternativa3d::bindPoseTransform.c;
         this.alternativa3d::bindPoseTransform.d = _loc2_.alternativa3d::bindPoseTransform.d;
         this.alternativa3d::bindPoseTransform.e = _loc2_.alternativa3d::bindPoseTransform.e;
         this.alternativa3d::bindPoseTransform.f = _loc2_.alternativa3d::bindPoseTransform.f;
         this.alternativa3d::bindPoseTransform.g = _loc2_.alternativa3d::bindPoseTransform.g;
         this.alternativa3d::bindPoseTransform.h = _loc2_.alternativa3d::bindPoseTransform.h;
         this.alternativa3d::bindPoseTransform.i = _loc2_.alternativa3d::bindPoseTransform.i;
         this.alternativa3d::bindPoseTransform.j = _loc2_.alternativa3d::bindPoseTransform.j;
         this.alternativa3d::bindPoseTransform.k = _loc2_.alternativa3d::bindPoseTransform.k;
         this.alternativa3d::bindPoseTransform.l = _loc2_.alternativa3d::bindPoseTransform.l;
      }
   }
}

