package thelaststand.app.game.data.assignment
{
   public class AssignmentCollection
   {
      
      private var _list:Vector.<AssignmentData> = new Vector.<AssignmentData>();
      
      public function AssignmentCollection()
      {
         super();
      }
      
      public function get length() : int
      {
         return this._list.length;
      }
      
      public function add(param1:AssignmentData) : void
      {
         this._list.push(param1);
      }
      
      public function remove(param1:AssignmentData) : void
      {
         var _loc2_:int = int(this._list.indexOf(param1));
         if(_loc2_ <= -1)
         {
            return;
         }
         this._list.splice(_loc2_,1);
      }
      
      public function getAt(param1:int) : AssignmentData
      {
         return this._list[param1];
      }
      
      public function getByName(param1:String) : AssignmentData
      {
         var _loc3_:AssignmentData = null;
         if(param1 == null)
         {
            return null;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this._list.length)
         {
            _loc3_ = this._list[_loc2_];
            if(_loc3_.name == param1)
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      public function getById(param1:String) : AssignmentData
      {
         var _loc3_:AssignmentData = null;
         if(param1 == null)
         {
            return null;
         }
         param1 = param1.toUpperCase();
         var _loc2_:int = 0;
         while(_loc2_ < this._list.length)
         {
            _loc3_ = this._list[_loc2_];
            if(_loc3_.id.toUpperCase() == param1)
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      public function parse(param1:Object) : void
      {
         var _loc4_:Object = null;
         var _loc5_:AssignmentData = null;
         this._list.length = 0;
         var _loc2_:Array = param1 as Array;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc3_];
            _loc5_ = AssignmentData.create(_loc4_);
            if(_loc5_ != null)
            {
               this._list.push(_loc5_);
            }
            _loc3_++;
         }
      }
   }
}

