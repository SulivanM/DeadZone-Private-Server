package com.exileetiquette.sound
{
   import com.exileetiquette.sound.effects.ISoundEffect;
   import flash.media.Sound;
   import flash.media.SoundTransform;
   import flash.utils.Dictionary;
   
   public class SoundManager
   {
      
      private static const GLOBAL_ID:String = "$_global";
      
      private static var _instances:Dictionary = new Dictionary();
      
      public static var effectHandlerByProperty:Dictionary = new Dictionary();
      
      private var _categoriesByName:Dictionary;
      
      private var _id:String;
      
      private var _soundEnabled:Boolean = true;
      
      private var _transform:SoundTransform;
      
      public function SoundManager()
      {
         super();
         this._categoriesByName = new Dictionary(true);
         this._transform = new SoundTransform();
      }
      
      public static function activateEffects(param1:Array) : void
      {
         var _loc2_:Class = null;
         var _loc3_:ISoundEffect = null;
         for each(_loc2_ in param1)
         {
            _loc3_ = new _loc2_();
            effectHandlerByProperty[_loc3_.propertyName] = _loc2_;
         }
      }
      
      public static function getInstance(param1:String = null) : SoundManager
      {
         if(!param1)
         {
            param1 = GLOBAL_ID;
         }
         var _loc2_:SoundManager = _instances[param1];
         if(!_loc2_)
         {
            _loc2_ = new SoundManager();
            _loc2_.setId(param1);
            _instances[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      public function addSound(param1:*, param2:String, param3:String = "default") : void
      {
         var _loc4_:SoundCategory = this._categoriesByName[param3];
         if(!_loc4_)
         {
            _loc4_ = new SoundCategory(this._transform);
            this._categoriesByName[param3] = _loc4_;
         }
         _loc4_.addSound(param2,param1);
      }
      
      public function destroy() : void
      {
         var _loc1_:String = null;
         var _loc2_:SoundCategory = null;
         for(_loc1_ in this._categoriesByName)
         {
            _loc2_ = this._categoriesByName[_loc1_];
            _loc2_.destroy();
            this._categoriesByName[_loc1_] = null;
            delete this._categoriesByName[_loc1_];
         }
         this._categoriesByName = null;
         this._transform = null;
      }
      
      public function getCategory(param1:String = "default") : SoundCategory
      {
         return this._categoriesByName[param1];
      }
      
      public function isPlaying(param1:String = null, param2:String = "default") : Boolean
      {
         var _loc3_:SoundCategory = null;
         if(!param1)
         {
            for each(_loc3_ in this._categoriesByName)
            {
               if(_loc3_.isPlaying())
               {
                  return true;
               }
            }
            return false;
         }
         _loc3_ = this._categoriesByName[param2];
         return _loc3_ ? _loc3_.isPlaying(param1) : false;
      }
      
      public function getNumPlaying(param1:String = null, param2:String = "default") : int
      {
         var _loc3_:int = 0;
         var _loc4_:SoundCategory = null;
         if(!param1)
         {
            for each(_loc4_ in this._categoriesByName)
            {
               _loc3_ += _loc4_.numPlaying;
            }
         }
         else
         {
            _loc4_ = this._categoriesByName[param2];
            if(!_loc4_)
            {
               return 0;
            }
            _loc3_ = _loc4_.getNumPlaying(param1);
         }
         return _loc3_;
      }
      
      public function getSound(param1:String, param2:String = "default") : Sound
      {
         var _loc3_:SoundCategory = this._categoriesByName[param2];
         if(!_loc3_)
         {
            return null;
         }
         return _loc3_.getSound(param1);
      }
      
      public function getLength(param1:String, param2:String = "default") : Number
      {
         var _loc3_:SoundCategory = this._categoriesByName[param2];
         if(!_loc3_)
         {
            return 0;
         }
         return _loc3_.getLength(param1);
      }
      
      public function play(param1:String, param2:Object = "default") : SoundData
      {
         var _loc3_:String = null;
         if(param2 is String)
         {
            _loc3_ = String(param2);
         }
         else if(!param2 || param2 is Number || !param2.category)
         {
            _loc3_ = "default";
         }
         else
         {
            _loc3_ = param2.category;
         }
         var _loc4_:SoundCategory = this._categoriesByName[_loc3_];
         return _loc4_ ? _loc4_.play(param1,param2) : null;
      }
      
      public function removeSound(param1:String, param2:String = "default") : void
      {
         var _loc3_:SoundCategory = this._categoriesByName[param2];
         _loc3_.removeSound(param1);
      }
      
      public function stop(param1:String, param2:String = "default") : void
      {
         var _loc3_:SoundCategory = this._categoriesByName[param2];
         if(!_loc3_)
         {
            return;
         }
         _loc3_.stop(param1);
      }
      
      public function stopAll(param1:String = null) : void
      {
         var _loc2_:SoundCategory = null;
         if(param1 != null)
         {
            _loc2_ = this._categoriesByName[param1];
            if(!_loc2_)
            {
               return;
            }
            _loc2_.stopAll();
         }
         else
         {
            for each(_loc2_ in this._categoriesByName)
            {
               _loc2_.stopAll();
            }
         }
      }
      
      public function stopAllDelayed(param1:String = null) : void
      {
         var _loc2_:SoundCategory = null;
         if(param1 != null)
         {
            _loc2_ = this._categoriesByName[param1];
            if(!_loc2_)
            {
               return;
            }
            _loc2_.stopAllDelayed();
         }
         else
         {
            for each(_loc2_ in this._categoriesByName)
            {
               _loc2_.stopAllDelayed();
            }
         }
      }
      
      internal function setId(param1:String) : void
      {
         this._id = param1;
      }
      
      private function updatePlayingSounds() : void
      {
         var _loc1_:SoundCategory = null;
         for each(_loc1_ in this._categoriesByName)
         {
            _loc1_.updatePlayingSounds();
         }
      }
      
      public function get leftToLeft() : Number
      {
         return this._transform.leftToLeft;
      }
      
      public function set leftToLeft(param1:Number) : void
      {
         this._transform.leftToLeft = param1;
         this.updatePlayingSounds();
      }
      
      public function get leftToRight() : Number
      {
         return this._transform.leftToRight;
      }
      
      public function set leftToRight(param1:Number) : void
      {
         this._transform.leftToRight = param1;
         this.updatePlayingSounds();
      }
      
      public function get pan() : Number
      {
         return this._transform.pan;
      }
      
      public function set pan(param1:Number) : void
      {
         this._transform.pan = param1;
         this.updatePlayingSounds();
      }
      
      public function get rightToLeft() : Number
      {
         return this._transform.rightToLeft;
      }
      
      public function set rightToLeft(param1:Number) : void
      {
         this._transform.rightToLeft = param1;
         this.updatePlayingSounds();
      }
      
      public function get rightToRight() : Number
      {
         return this._transform.rightToRight;
      }
      
      public function set rightToRight(param1:Number) : void
      {
         this._transform.rightToRight = param1;
         this.updatePlayingSounds();
      }
      
      public function get soundEnabled() : Boolean
      {
         return this._soundEnabled;
      }
      
      public function set soundEnabled(param1:Boolean) : void
      {
         this._soundEnabled = param1;
         if(!this._soundEnabled)
         {
            this.stopAll();
         }
      }
      
      public function get volume() : Number
      {
         return this._transform.volume;
      }
      
      public function set volume(param1:Number) : void
      {
         this._transform.volume = param1;
         this.updatePlayingSounds();
      }
      
      public function get id() : String
      {
         return this._id;
      }
   }
}

