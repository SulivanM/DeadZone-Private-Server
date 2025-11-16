package thelaststand.app.game.data
{
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   import thelaststand.common.io.ISerializable;
   
   public class SurvivorCollection implements ISerializable
   {
      
      private var _compound:CompoundData;
      
      private var _survivors:Vector.<Survivor>;
      
      private var _survivorsById:Dictionary;
      
      public var survivorAdded:Signal;
      
      public var survivorRallyAssignmentChanged:Signal;
      
      public function SurvivorCollection(param1:CompoundData)
      {
         super();
         this._compound = param1;
         this._survivors = new Vector.<Survivor>();
         this._survivorsById = new Dictionary(true);
         this.survivorAdded = new Signal(Survivor);
         this.survivorRallyAssignmentChanged = new Signal(Survivor);
      }
      
      public function addSurvivor(param1:Survivor) : Survivor
      {
         if(this._survivors.indexOf(param1) > -1)
         {
            return null;
         }
         if(this._survivorsById[param1.id] != null)
         {
            return null;
         }
         this._survivors.push(param1);
         this._survivorsById[param1.id] = param1;
         param1.rallyAssignmentChanged.add(this.onSurvivorRallyAssignmentChanged);
         this.survivorAdded.dispatch(param1);
         return param1;
      }
      
      public function containsSurvivor(param1:Survivor) : Boolean
      {
         return this._survivors.indexOf(param1) > -1;
      }
      
      public function containsSurvivorId(param1:String) : Boolean
      {
         return this._survivors[param1.toUpperCase()] != null;
      }
      
      public function dispose() : void
      {
         this.survivorRallyAssignmentChanged.removeAll();
         this.survivorAdded.removeAll();
         this._survivors = null;
         this._survivorsById = null;
         this._compound = null;
      }
      
      public function getAverageLevel() : int
      {
         var _loc2_:Survivor = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._survivors)
         {
            _loc1_ += _loc2_.level;
         }
         return Math.floor(_loc1_ / this._survivors.length);
      }
      
      public function getHighestLevel() : int
      {
         var _loc2_:Survivor = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._survivors)
         {
            if(_loc2_.level > _loc1_)
            {
               _loc1_ = int(_loc2_.level);
            }
         }
         return _loc1_;
      }
      
      public function getNumAssignedSurvivors() : int
      {
         var _loc2_:Survivor = null;
         var _loc1_:uint = 0;
         for each(_loc2_ in this._survivors)
         {
            if(_loc2_.rallyAssignment != null)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      public function getSurvivor(param1:uint) : Survivor
      {
         if(param1 >= this._survivors.length)
         {
            return null;
         }
         return this._survivors[param1];
      }
      
      public function getSurvivorsByClass(param1:String = "all") : Vector.<Survivor>
      {
         var _loc3_:Survivor = null;
         var _loc2_:Vector.<Survivor> = new Vector.<Survivor>();
         for each(_loc3_ in this._survivors)
         {
            if(param1 == "all" || _loc3_.classId == param1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function hasSurvivor(param1:String, param2:int = 0, param3:int = 1) : Boolean
      {
         var _loc5_:Survivor = null;
         var _loc4_:int = 0;
         for each(_loc5_ in this._survivors)
         {
            if(_loc5_.classId == param1 && _loc5_.level >= param2)
            {
               if(++_loc4_ >= param3)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function getSurvivorById(param1:String) : Survivor
      {
         if(param1 == null || this._survivorsById == null)
         {
            return null;
         }
         return this._survivorsById[param1.toUpperCase()];
      }
      
      public function getNumAvailableSurvivors() : int
      {
         var _loc2_:Survivor = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._survivors)
         {
            if(!(Boolean(_loc2_.state & SurvivorState.ON_MISSION) || Boolean(_loc2_.state & SurvivorState.REASSIGNING) || Boolean(_loc2_.state & SurvivorState.ON_ASSIGNMENT)))
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      public function getResourceURIs() : Array
      {
         var _loc2_:Survivor = null;
         var _loc1_:Array = [];
         for each(_loc2_ in this._survivors)
         {
            _loc1_ = _loc1_.concat(_loc2_.getResourceURIs());
         }
         return _loc1_;
      }
      
      public function writeObject(param1:Object = null) : Object
      {
         var _loc2_:Survivor = null;
         if(!param1)
         {
            param1 = [];
         }
         for each(_loc2_ in this._survivors)
         {
            param1.push(_loc2_.writeObject());
         }
         return param1;
      }
      
      public function readObject(param1:Object) : void
      {
         var _loc4_:Survivor = null;
         this._survivors.length = 0;
         if(!(param1 is Array))
         {
            return;
         }
         var _loc2_:int = 0;
         var _loc3_:int = int(param1.length);
         while(_loc2_ < _loc3_)
         {
            if(!(param1[_loc2_] == null || param1[_loc2_].id == null || param1[_loc2_].classId == null))
            {
               _loc4_ = new Survivor();
               _loc4_.readObject(param1[_loc2_]);
               _loc4_.rallyAssignmentChanged.add(this.onSurvivorRallyAssignmentChanged);
               this._survivors.push(_loc4_);
            }
            _loc2_++;
         }
         this.buildIdLookup();
      }
      
      public function removeSurvivor(param1:Survivor) : Survivor
      {
         var _loc2_:int = int(this._survivors.indexOf(param1));
         if(_loc2_ == -1)
         {
            return null;
         }
         if(this._survivorsById[param1.id] == null)
         {
            return null;
         }
         param1.rallyAssignmentChanged.remove(this.onSurvivorRallyAssignmentChanged);
         this._survivors.splice(_loc2_,1);
         this._survivorsById[param1.id] = null;
         delete this._survivorsById[param1.id];
         return param1;
      }
      
      public function removeAll() : void
      {
         var _loc1_:Survivor = null;
         for each(_loc1_ in this._survivors)
         {
            _loc1_.rallyAssignmentChanged.remove(this.onSurvivorRallyAssignmentChanged);
            this._survivorsById[_loc1_.id] = null;
            delete this._survivorsById[_loc1_.id];
         }
         this._survivors.length = 0;
      }
      
      public function removeSurvivorById(param1:String) : Survivor
      {
         var _loc2_:Survivor = this._survivorsById[param1.toUpperCase()];
         return this.removeSurvivor(_loc2_);
      }
      
      private function buildIdLookup() : void
      {
         var _loc1_:Survivor = null;
         this._survivorsById = new Dictionary(true);
         for each(_loc1_ in this._survivors)
         {
            this._survivorsById[_loc1_.id.toUpperCase()] = _loc1_;
         }
      }
      
      private function onSurvivorRallyAssignmentChanged(param1:Survivor) : void
      {
         this.survivorRallyAssignmentChanged.dispatch(param1);
      }
      
      public function get compound() : CompoundData
      {
         return this._compound;
      }
      
      public function get length() : int
      {
         return this._survivors.length;
      }
   }
}

