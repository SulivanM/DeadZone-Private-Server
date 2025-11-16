package thelaststand.app.game.data.alliance
{
   import flash.utils.Dictionary;
   import org.osflash.signals.Signal;
   
   public class AllianceMemberList
   {
      
      private var _members:Vector.<AllianceMember>;
      
      private var _membersById:Dictionary;
      
      private var _numMembers:int;
      
      public var memberAdded:Signal = new Signal(AllianceMember);
      
      public var memberRemoved:Signal = new Signal(AllianceMember);
      
      public var memberRankChanged:Signal = new Signal(AllianceMember);
      
      public function AllianceMemberList()
      {
         super();
         this._members = new Vector.<AllianceMember>();
         this._membersById = new Dictionary(true);
      }
      
      public function get numMembers() : int
      {
         return this._numMembers;
      }
      
      public function clear() : void
      {
         this._numMembers = 0;
         this._members.length = 0;
         this._membersById = new Dictionary(true);
      }
      
      public function contains(param1:AllianceMember) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         return this._membersById[param1.id] == param1;
      }
      
      public function containsId(param1:String) : Boolean
      {
         return this._membersById[param1] != null;
      }
      
      public function addMember(param1:AllianceMember) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:int = int(this._members.indexOf(param1));
         if(_loc2_ > -1)
         {
            return;
         }
         this._members.push(param1);
         this._membersById[param1.id] = param1;
         ++this._numMembers;
         param1.rankChanged.add(this.onRankChanged);
         this.memberAdded.dispatch(param1);
      }
      
      public function removeMember(param1:AllianceMember) : void
      {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:int = int(this._members.indexOf(param1));
         if(_loc2_ > -1)
         {
            this._members.splice(_loc2_,1);
         }
         delete this._membersById[param1.id];
         --this._numMembers;
         param1.rankChanged.remove(this.onRankChanged);
         this.memberRemoved.dispatch(param1);
      }
      
      public function removeMemberById(param1:String) : void
      {
         this.removeMember(this.getMemberById(param1));
      }
      
      public function getMember(param1:int) : AllianceMember
      {
         if(param1 < 0 || param1 >= this._numMembers)
         {
            return null;
         }
         return this._members[param1];
      }
      
      public function getMemberById(param1:String) : AllianceMember
      {
         return this._membersById[param1];
      }
      
      public function getFounder() : AllianceMember
      {
         var _loc2_:AllianceMember = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._numMembers)
         {
            _loc2_ = this._members[_loc1_];
            if(_loc2_.rank == AllianceRank.FOUNDER)
            {
               return _loc2_;
            }
            _loc1_++;
         }
         return null;
      }
      
      public function deserialize(param1:Object) : void
      {
         var _loc4_:Object = null;
         var _loc5_:AllianceMember = null;
         this.clear();
         var _loc2_:Array = param1 as Array;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc3_];
            if(!(_loc4_ == null || !_loc4_.playerId))
            {
               _loc5_ = new AllianceMember(_loc4_);
               this._members.push(_loc5_);
               this._membersById[_loc5_.id] = _loc5_;
               ++this._numMembers;
               _loc5_.rankChanged.add(this.onRankChanged);
            }
            _loc3_++;
         }
      }
      
      private function onRankChanged(param1:AllianceMember) : void
      {
         this.memberRankChanged.dispatch(param1);
      }
   }
}

