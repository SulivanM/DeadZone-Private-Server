package thelaststand.app.game.data.alliance
{
   public class AllianceLifetimeStats
   {
      
      public var userName:String;
      
      public var points:int;
      
      public var wins:int;
      
      public var losses:int;
      
      public var abandons:int;
      
      public var defWins:int;
      
      public var defLosses:int;
      
      public var pointsAttack:int;
      
      public var pointsDefend:int;
      
      public var missionSuccess:int;
      
      public var missionFail:int;
      
      public var missionAbandon:int;
      
      public var pointsMission:int;
      
      public var raidPerc:Number;
      
      public var missionPerc:Number;
      
      public function AllianceLifetimeStats()
      {
         super();
      }
      
      public function deserialize(param1:Object) : void
      {
         if(param1.hasOwnProperty("userName"))
         {
            this.userName = param1["userName"];
         }
         this.points = int(param1["points"]);
         this.wins = int(param1["wins"]);
         this.losses = int(param1["losses"]);
         this.abandons = int(param1["abandons"]);
         this.defWins = int(param1["defWins"]);
         this.defLosses = int(param1["defLosses"]);
         this.pointsAttack = int(param1["pointsAttack"]);
         this.pointsDefend = int(param1["pointsDefend"]);
         this.missionSuccess = int(param1["missionSuccess"]);
         this.missionFail = int(param1["missionFail"]);
         this.missionAbandon = int(param1["missionAbandon"]);
         this.pointsMission = int(param1["pointsMission"]);
         this.raidPerc = 0;
         if(this.wins > 0)
         {
            this.raidPerc = this.wins / Number(this.wins + this.losses + this.abandons) * 100;
         }
         this.missionPerc = 0;
         if(this.missionSuccess > 0)
         {
            this.missionPerc = this.missionSuccess / Number(this.missionSuccess + this.missionFail + this.missionAbandon) * 100;
         }
      }
   }
}

