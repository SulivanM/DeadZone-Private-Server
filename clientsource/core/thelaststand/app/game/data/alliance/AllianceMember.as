package thelaststand.app.game.data.alliance
{
   import org.osflash.signals.Signal;
   import thelaststand.app.network.RemotePlayerData;
   
   public class AllianceMember
   {
      
      private var _id:String;
      
      private var _nickname:String;
      
      private var _level:int;
      
      private var _allianceId:String;
      
      private var _joinDate:Date;
      
      private var _rank:uint;
      
      private var _tokens:uint;
      
      private var _player:RemotePlayerData;
      
      private var _isOnline:Boolean;
      
      private var _points:uint = 0;
      
      private var _pointsAttack:uint = 0;
      
      private var _pointsDefend:uint = 0;
      
      private var _pointsMission:uint = 0;
      
      private var _efficiency:Number = 0;
      
      private var _wins:int = 0;
      
      private var _losses:int = 0;
      
      private var _defWins:int = 0;
      
      private var _defLosses:int = 0;
      
      private var _abandons:int = 0;
      
      private var _missionSuccess:uint = 0;
      
      private var _missionFail:uint = 0;
      
      private var _missionAbandon:uint = 0;
      
      private var _missionEfficiency:Number = 0;
      
      private var _raidWinPts:uint = 0;
      
      private var _raidLosePts:uint = 0;
      
      public var rankChanged:Signal = new Signal(AllianceMember);
      
      public var onlineStatusChanged:Signal = new Signal(AllianceMember);
      
      public function AllianceMember(param1:Object)
      {
         super();
         this.deserialize(param1);
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get nickname() : String
      {
         return this._nickname;
      }
      
      public function get level() : int
      {
         return this._level;
      }
      
      public function get joinDate() : Date
      {
         return this._joinDate;
      }
      
      public function get rank() : uint
      {
         return this._rank;
      }
      
      public function set rank(param1:uint) : void
      {
         if(param1 == this._rank)
         {
            return;
         }
         this._rank = param1;
         this.rankChanged.dispatch(this);
      }
      
      public function get tokens() : uint
      {
         return this._tokens;
      }
      
      public function get isOnline() : Boolean
      {
         return this._isOnline;
      }
      
      public function set isOnline(param1:Boolean) : void
      {
         if(param1 == this._isOnline)
         {
            return;
         }
         this._isOnline = param1;
         this.onlineStatusChanged.dispatch(this);
      }
      
      public function get efficiency() : Number
      {
         return this._efficiency;
      }
      
      public function get wins() : uint
      {
         return this._wins;
      }
      
      public function get losses() : uint
      {
         return this._losses;
      }
      
      public function get defWins() : uint
      {
         return this._defWins;
      }
      
      public function get defLosses() : uint
      {
         return this._defLosses;
      }
      
      public function get abandons() : uint
      {
         return this._abandons;
      }
      
      public function get missionSuccess() : uint
      {
         return this._missionSuccess;
      }
      
      public function get missionFail() : uint
      {
         return this._missionFail;
      }
      
      public function get missionAbandon() : uint
      {
         return this._missionAbandon;
      }
      
      public function get missionEfficiency() : Number
      {
         return this._missionEfficiency;
      }
      
      public function get points() : uint
      {
         return this._points;
      }
      
      public function get pointsAttack() : uint
      {
         return this._pointsAttack;
      }
      
      public function get pointsDefend() : uint
      {
         return this._pointsDefend;
      }
      
      public function get pointsMission() : uint
      {
         return this._pointsMission;
      }
      
      public function get raidWinPts() : uint
      {
         return this._raidWinPts;
      }
      
      public function get raidLosePts() : uint
      {
         return this._raidLosePts;
      }
      
      public function hasPrivilege(param1:uint) : Boolean
      {
         return AllianceRank.hasPrivilege(this._rank,param1);
      }
      
      public function setPoints(param1:int) : void
      {
         this._points = param1;
      }
      
      private function deserialize(param1:Object) : void
      {
         if(param1 == null)
         {
            return;
         }
         this._id = String(param1.playerId);
         this._nickname = String(param1.nickname);
         this._level = int(param1.level);
         this._joinDate = new Date(param1.joindate);
         this._joinDate.minutes -= this._joinDate.getTimezoneOffset();
         this._rank = uint(param1.rank);
         this._tokens = uint(param1.tokens);
         this._isOnline = Boolean(param1.online);
         this._points = uint(param1.points);
         this._pointsAttack = uint(param1.pointsAttack);
         this._pointsDefend = uint(param1.pointsDefend);
         this._pointsMission = uint(param1.pointsMission);
         this._efficiency = Number(param1.efficiency);
         this._wins = int(param1.wins);
         this._losses = int(param1.losses);
         this._abandons = int(param1.abandons);
         this._defWins = int(param1.defWins);
         this._defLosses = int(param1.defLosses);
         this._missionSuccess = int(param1.missionSuccess);
         this._missionFail = int(param1.missionFail);
         this._missionAbandon = int(param1.missionAbandon);
         this._missionEfficiency = Number(param1.missionEfficiency);
         this._raidWinPts = uint(param1.raidWinPts);
         this._raidLosePts = uint(param1.raidLosePts);
      }
   }
}

