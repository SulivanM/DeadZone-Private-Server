package thelaststand.app.game.data.task
{
   import thelaststand.app.game.data.CompoundData;
   import thelaststand.app.game.data.JunkBuilding;
   import thelaststand.app.game.data.Task;
   import thelaststand.app.game.data.TaskType;
   import thelaststand.app.game.entities.EntityFlags;
   
   public class JunkRemovalTask extends Task
   {
      
      private var _target:JunkBuilding;
      
      private var _targetId:String;
      
      private var _xp:int = 0;
      
      public function JunkRemovalTask(param1:JunkBuilding = null)
      {
         _type = TaskType.JUNK_REMOVAL;
         super();
         if(param1 != null)
         {
            this._target = param1;
            this._targetId = param1.id;
            _length = param1.removalTime;
            _items = param1.items.concat();
            this._xp = int(this._target.xml.xp[0]);
            this._target.tasks.push(this);
            if(this._target.entity != null)
            {
               this._target.entity.flags |= EntityFlags.BEING_REMOVED;
            }
         }
      }
      
      override public function getXP() : int
      {
         return this._xp;
      }
      
      override public function completeTask() : void
      {
         var _loc1_:int = 0;
         super.completeTask();
         if(this._target != null)
         {
            _loc1_ = int(this._target.tasks.indexOf(this));
            if(_loc1_ > -1)
            {
               this._target.tasks.splice(_loc1_,1);
            }
            this._target.dispose();
         }
      }
      
      override public function writeObject(param1:Object = null) : Object
      {
         param1 = super.writeObject(param1);
         param1.buildingId = this._targetId;
         return param1;
      }
      
      override public function readObject(param1:Object, param2:CompoundData) : Boolean
      {
         super.readObject(param1,param2);
         this._targetId = String(param1.buildingId);
         this._target = param2 != null && param2.buildings != null ? param2.buildings.getBuildingById(this._targetId) as JunkBuilding : null;
         if(this._target == null)
         {
            return false;
         }
         this._target.tasks.push(this);
         this._xp = this._target.xml != null ? int(this._target.xml.xp[0]) : 0;
         if(this._target.entity != null)
         {
            this._target.entity.flags |= EntityFlags.BEING_REMOVED;
         }
         return true;
      }
      
      public function get target() : JunkBuilding
      {
         return this._target;
      }
   }
}

