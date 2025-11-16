package alternativa.engine3d.loaders.collada
{
   import alternativa.engine3d.animation.keys.NumberTrack;
   import alternativa.engine3d.animation.keys.Track;
   import alternativa.engine3d.animation.keys.TransformTrack;
   import flash.geom.Matrix3D;
   
   use namespace collada;
   
   public class DaeSampler extends DaeElement
   {
      
      private var times:Vector.<Number>;
      
      private var values:Vector.<Number>;
      
      private var timesStride:int;
      
      private var valuesStride:int;
      
      public function DaeSampler(param1:XML, param2:DaeDocument)
      {
         super(param1,param2);
      }
      
      override protected function parseImplementation() : Boolean
      {
         var _loc2_:DaeSource = null;
         var _loc3_:DaeSource = null;
         var _loc6_:DaeInput = null;
         var _loc7_:String = null;
         var _loc1_:XMLList = data.input;
         var _loc4_:int = 0;
         var _loc5_:int = int(_loc1_.length());
         for(; _loc4_ < _loc5_; _loc4_++)
         {
            _loc6_ = new DaeInput(_loc1_[_loc4_],document);
            _loc7_ = _loc6_.semantic;
            if(_loc7_ == null)
            {
               continue;
            }
            switch(_loc7_)
            {
               case "INPUT":
                  _loc2_ = _loc6_.prepareSource(1);
                  if(_loc2_ != null)
                  {
                     this.times = _loc2_.numbers;
                     this.timesStride = _loc2_.stride;
                  }
                  break;
               case "OUTPUT":
                  _loc3_ = _loc6_.prepareSource(1);
                  if(_loc3_ != null)
                  {
                     this.values = _loc3_.numbers;
                     this.valuesStride = _loc3_.stride;
                  }
            }
         }
         return true;
      }
      
      public function parseNumbersTrack(param1:String, param2:String) : NumberTrack
      {
         var _loc3_:NumberTrack = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(this.times != null && this.values != null && this.timesStride > 0)
         {
            _loc3_ = new NumberTrack(param1,param2);
            _loc4_ = this.times.length / this.timesStride;
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               _loc3_.addKey(this.times[int(this.timesStride * _loc5_)],this.values[int(this.valuesStride * _loc5_)]);
               _loc5_++;
            }
            return _loc3_;
         }
         return null;
      }
      
      public function parseTransformationTrack(param1:String) : Track
      {
         var _loc2_:TransformTrack = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Matrix3D = null;
         if(this.times != null && this.values != null && this.timesStride != 0)
         {
            _loc2_ = new TransformTrack(param1);
            _loc3_ = this.times.length / this.timesStride;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _loc5_ = this.valuesStride * _loc4_;
               _loc6_ = new Matrix3D(Vector.<Number>([this.values[_loc5_],this.values[_loc5_ + 4],this.values[_loc5_ + 8],this.values[_loc5_ + 12],this.values[_loc5_ + 1],this.values[_loc5_ + 5],this.values[_loc5_ + 9],this.values[_loc5_ + 13],this.values[_loc5_ + 2],this.values[_loc5_ + 6],this.values[_loc5_ + 10],this.values[_loc5_ + 14],this.values[_loc5_ + 3],this.values[_loc5_ + 7],this.values[_loc5_ + 11],this.values[_loc5_ + 15]]));
               _loc2_.addKey(this.times[_loc4_ * this.timesStride],_loc6_);
               _loc4_++;
            }
            return _loc2_;
         }
         return null;
      }
      
      public function parsePointsTracks(param1:String, param2:String, param3:String, param4:String) : Vector.<Track>
      {
         var _loc5_:NumberTrack = null;
         var _loc6_:NumberTrack = null;
         var _loc7_:NumberTrack = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Number = NaN;
         if(this.times != null && this.values != null && this.timesStride != 0)
         {
            _loc5_ = new NumberTrack(param1,param2);
            _loc5_.object = param1;
            _loc6_ = new NumberTrack(param1,param3);
            _loc6_.object = param1;
            _loc7_ = new NumberTrack(param1,param4);
            _loc7_.object = param1;
            _loc8_ = this.times.length / this.timesStride;
            _loc9_ = 0;
            while(_loc9_ < _loc8_)
            {
               _loc10_ = _loc9_ * this.valuesStride;
               _loc11_ = this.times[_loc9_ * this.timesStride];
               _loc5_.addKey(_loc11_,this.values[_loc10_]);
               _loc6_.addKey(_loc11_,this.values[_loc10_ + 1]);
               _loc7_.addKey(_loc11_,this.values[_loc10_ + 2]);
               _loc9_++;
            }
            return Vector.<Track>([_loc5_,_loc6_,_loc7_]);
         }
         return null;
      }
   }
}

