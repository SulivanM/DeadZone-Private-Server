package alternativa.engine3d.loaders.collada
{
   import alternativa.engine3d.alternativa3d;
   import alternativa.engine3d.animation.keys.NumberKey;
   import alternativa.engine3d.animation.keys.NumberTrack;
   import alternativa.engine3d.animation.keys.Track;
   
   use namespace alternativa3d;
   
   public class DaeChannel extends DaeElement
   {
      
      public static const PARAM_UNDEFINED:String = "undefined";
      
      public static const PARAM_TRANSLATE_X:String = "x";
      
      public static const PARAM_TRANSLATE_Y:String = "y";
      
      public static const PARAM_TRANSLATE_Z:String = "z";
      
      public static const PARAM_SCALE_X:String = "scaleX";
      
      public static const PARAM_SCALE_Y:String = "scaleY";
      
      public static const PARAM_SCALE_Z:String = "scaleZ";
      
      public static const PARAM_ROTATION_X:String = "rotationX";
      
      public static const PARAM_ROTATION_Y:String = "rotationY";
      
      public static const PARAM_ROTATION_Z:String = "rotationZ";
      
      public static const PARAM_TRANSLATE:String = "translate";
      
      public static const PARAM_SCALE:String = "scale";
      
      public static const PARAM_MATRIX:String = "matrix";
      
      public var tracks:Vector.<Track>;
      
      public var animatedParam:String = "undefined";
      
      public var animName:String;
      
      public function DaeChannel(param1:XML, param2:DaeDocument)
      {
         super(param1,param2);
      }
      
      public function get node() : DaeNode
      {
         var _loc2_:Array = null;
         var _loc3_:DaeNode = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc1_:XML = data.@target[0];
         if(_loc1_ != null)
         {
            _loc2_ = _loc1_.toString().split("/");
            _loc3_ = document.findNodeByID(_loc2_[0]);
            if(_loc3_ != null)
            {
               _loc2_.pop();
               _loc4_ = 1;
               _loc5_ = int(_loc2_.length);
               while(_loc4_ < _loc5_)
               {
                  _loc6_ = _loc2_[_loc4_];
                  _loc3_ = _loc3_.getNodeBySid(_loc6_);
                  if(_loc3_ == null)
                  {
                     return null;
                  }
                  _loc4_++;
               }
               return _loc3_;
            }
         }
         return null;
      }
      
      override protected function parseImplementation() : Boolean
      {
         this.parseTransformationType();
         this.parseSampler();
         return true;
      }
      
      private function parseTransformationType() : void
      {
         var _loc6_:XML = null;
         var _loc12_:XML = null;
         var _loc13_:XML = null;
         var _loc14_:String = null;
         var _loc15_:Array = null;
         var _loc1_:XML = data.@target[0];
         if(_loc1_ == null)
         {
            return;
         }
         var _loc2_:Array = _loc1_.toString().split("/");
         var _loc3_:String = _loc2_.pop();
         var _loc4_:Array = _loc3_.split(".");
         var _loc5_:int = int(_loc4_.length);
         var _loc7_:DaeNode = this.node;
         if(_loc7_ == null)
         {
            return;
         }
         this.animName = _loc7_.animName;
         var _loc8_:XMLList = _loc7_.data.children();
         var _loc9_:int = 0;
         var _loc10_:int = int(_loc8_.length());
         while(_loc9_ < _loc10_)
         {
            _loc12_ = _loc8_[_loc9_];
            _loc13_ = _loc12_.@sid[0];
            if(_loc13_ != null && _loc13_.toString() == _loc4_[0])
            {
               _loc6_ = _loc12_;
               break;
            }
            _loc9_++;
         }
         var _loc11_:String = _loc6_ != null ? _loc6_.localName() as String : null;
         if(_loc5_ > 1)
         {
            _loc14_ = _loc4_[1];
            switch(_loc11_)
            {
               case "translate":
                  switch(_loc14_)
                  {
                     case "X":
                        this.animatedParam = PARAM_TRANSLATE_X;
                        break;
                     case "Y":
                        this.animatedParam = PARAM_TRANSLATE_Y;
                        break;
                     case "Z":
                        this.animatedParam = PARAM_TRANSLATE_Z;
                  }
                  break;
               case "rotate":
                  _loc15_ = parseNumbersArray(_loc6_);
                  switch(_loc15_.indexOf(1))
                  {
                     case 0:
                        this.animatedParam = PARAM_ROTATION_X;
                        break;
                     case 1:
                        this.animatedParam = PARAM_ROTATION_Y;
                        break;
                     case 2:
                        this.animatedParam = PARAM_ROTATION_Z;
                  }
                  break;
               case "scale":
                  switch(_loc14_)
                  {
                     case "X":
                        this.animatedParam = PARAM_SCALE_X;
                        break;
                     case "Y":
                        this.animatedParam = PARAM_SCALE_Y;
                        break;
                     case "Z":
                        this.animatedParam = PARAM_SCALE_Z;
                  }
            }
         }
         else
         {
            switch(_loc11_)
            {
               case "translate":
                  this.animatedParam = PARAM_TRANSLATE;
                  break;
               case "scale":
                  this.animatedParam = PARAM_SCALE;
                  break;
               case "matrix":
                  this.animatedParam = PARAM_MATRIX;
            }
         }
      }
      
      private function parseSampler() : void
      {
         var _loc2_:NumberTrack = null;
         var _loc3_:Number = NaN;
         var _loc4_:NumberKey = null;
         var _loc1_:DaeSampler = document.findSampler(data.@source[0]);
         if(_loc1_ != null)
         {
            _loc1_.parse();
            if(this.animatedParam == PARAM_MATRIX)
            {
               this.tracks = Vector.<Track>([_loc1_.parseTransformationTrack(this.animName)]);
               return;
            }
            if(this.animatedParam == PARAM_TRANSLATE)
            {
               this.tracks = _loc1_.parsePointsTracks(this.animName,"x","y","z");
               return;
            }
            if(this.animatedParam == PARAM_SCALE)
            {
               this.tracks = _loc1_.parsePointsTracks(this.animName,"scaleX","scaleY","scaleZ");
               return;
            }
            if(this.animatedParam == PARAM_ROTATION_X || this.animatedParam == PARAM_ROTATION_Y || this.animatedParam == PARAM_ROTATION_Z)
            {
               _loc2_ = _loc1_.parseNumbersTrack(this.animName,this.animatedParam);
               _loc3_ = Math.PI / 180;
               _loc4_ = _loc2_.alternativa3d::keyList;
               while(_loc4_ != null)
               {
                  _loc4_.alternativa3d::_value *= _loc3_;
                  _loc4_ = _loc4_.alternativa3d::next;
               }
               this.tracks = Vector.<Track>([_loc2_]);
               return;
            }
            if(this.animatedParam == PARAM_TRANSLATE_X || this.animatedParam == PARAM_TRANSLATE_Y || this.animatedParam == PARAM_TRANSLATE_Z || this.animatedParam == PARAM_SCALE_X || this.animatedParam == PARAM_SCALE_Y || this.animatedParam == PARAM_SCALE_Z)
            {
               this.tracks = Vector.<Track>([_loc1_.parseNumbersTrack(this.animName,this.animatedParam)]);
            }
         }
         else
         {
            document.logger.logNotFoundError(data.@source[0]);
         }
      }
   }
}

