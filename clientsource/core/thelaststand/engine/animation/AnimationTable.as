package thelaststand.engine.animation
{
   import alternativa.engine3d.animation.AnimationClip;
   import alternativa.engine3d.animation.AnimationNotify;
   import flash.utils.Dictionary;
   import thelaststand.common.resources.Resource;
   import thelaststand.common.resources.ResourceManager;
   
   public class AnimationTable
   {
      
      private var _animsByName:Dictionary;
      
      private var _animNames:Array;
      
      public function AnimationTable(param1:String = null)
      {
         var _loc2_:Resource = null;
         super();
         if(param1)
         {
            _loc2_ = ResourceManager.getInstance().getResource(param1);
            if(_loc2_ != null)
            {
               this.parse(_loc2_.content);
            }
         }
      }
      
      public static function getAnimURIsFromTable(param1:String) : Array
      {
         var _loc6_:Array = null;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc2_:Array = [];
         param1 = param1.replace(/^[\/\/]+.+/igm,"");
         param1 = param1.replace(/\s+$|^ \s+|^\t+/gm,"");
         param1 = param1.replace(/[\t]+/g,"\t");
         var _loc3_:Array = param1.split("\n");
         if(_loc3_.length == 0)
         {
            _loc3_ = param1.split("\r");
         }
         var _loc4_:int = 0;
         var _loc5_:int = int(_loc3_.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc3_[_loc4_].split("\t");
            _loc7_ = _loc6_[0];
            if(_loc7_ == "anim")
            {
               _loc8_ = _loc6_[1];
               _loc2_.push(_loc8_);
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function dispose() : void
      {
         var _loc1_:String = null;
         var _loc2_:AnimationClip = null;
         var _loc3_:int = 0;
         var _loc4_:AnimationNotify = null;
         for(_loc1_ in this._animsByName)
         {
            _loc2_ = this._animsByName[_loc1_];
            _loc3_ = int(_loc2_.notifiers.length - 1);
            while(_loc3_ >= 0)
            {
               _loc4_ = _loc2_.notifiers[_loc3_];
               if(_loc2_.objects != null)
               {
                  _loc2_.objects.length = 0;
               }
               _loc2_.removeNotify(_loc4_);
               _loc3_--;
            }
            this._animsByName[_loc1_] = null;
            delete this._animsByName[_loc1_];
         }
         this._animsByName = null;
         this._animNames = null;
      }
      
      public function getAnimationAt(param1:int) : AnimationClip
      {
         if(!this._animsByName || !this._animNames)
         {
            return null;
         }
         return this._animsByName[this._animNames[param1]];
      }
      
      public function getAnimationByName(param1:String) : AnimationClip
      {
         if(!this._animsByName)
         {
            return null;
         }
         return this._animsByName[param1];
      }
      
      public function getAnimationNames() : Array
      {
         return this._animNames.concat();
      }
      
      public function getName(param1:int) : String
      {
         return this._animNames ? this._animNames[param1] : null;
      }
      
      public function parse(param1:String) : void
      {
         var _loc2_:AnimationClip = null;
         var _loc3_:int = 0;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:AnimationClip = null;
         var _loc12_:int = 0;
         var _loc13_:Number = NaN;
         var _loc14_:String = null;
         this._animsByName = new Dictionary(true);
         this._animNames = [];
         param1 = param1.replace(/^[\/\/]+.+/igm,"");
         param1 = param1.replace(/\s+$|^ \s+|^\t+/gm,"");
         param1 = param1.replace(/[\t]+/g,"\t");
         _loc3_ = 30;
         var _loc4_:Array = param1.split("\n");
         var _loc5_:int = 0;
         var _loc6_:int = int(_loc4_.length);
         loop0:
         while(true)
         {
            if(_loc5_ >= _loc6_)
            {
               return;
            }
            _loc7_ = _loc4_[_loc5_].split("\t");
            _loc8_ = _loc7_[0];
            switch(_loc8_)
            {
               case "anim":
                  _loc2_ = ResourceManager.getInstance().getResource(_loc7_[1]).content;
                  if(_loc2_ == null)
                  {
                  }
                  break;
               case "framerate":
                  _loc3_ = Number(_loc7_[1]);
                  break;
               default:
                  if(_loc7_.length >= 3)
                  {
                     if(_loc2_ == null)
                     {
                        break loop0;
                     }
                     _loc9_ = Number(_loc7_[1]) / _loc3_;
                     _loc10_ = Number(_loc7_[2]) / _loc3_;
                     _loc11_ = _loc2_.slice(_loc9_,_loc10_);
                     _loc11_.name = _loc8_;
                     if(_loc7_.length > 3)
                     {
                        _loc12_ = 3;
                        while(_loc12_ < _loc7_.length)
                        {
                           _loc13_ = Number(_loc7_[_loc12_]) / _loc3_;
                           _loc14_ = _loc7_[_loc12_ + 1];
                           _loc11_.addNotify(_loc13_ - _loc9_,_loc14_);
                           _loc12_ += 2;
                        }
                     }
                     this._animsByName[_loc8_] = _loc11_;
                     this._animNames.push(_loc8_);
                  }
            }
            _loc5_++;
         }
      }
      
      public function get numAnimations() : int
      {
         return this._animNames ? int(this._animNames.length) : 0;
      }
   }
}

