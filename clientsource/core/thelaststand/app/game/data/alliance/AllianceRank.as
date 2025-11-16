package thelaststand.app.game.data.alliance
{
   import flash.utils.Dictionary;
   
   public class AllianceRank
   {
      
      private static var _privileges:Dictionary;
      
      public static const RANK_10:uint = 10;
      
      public static const RANK_9:uint = 9;
      
      public static const RANK_8:uint = 8;
      
      public static const RANK_7:uint = 7;
      
      public static const RANK_6:uint = 6;
      
      public static const RANK_5:uint = 5;
      
      public static const RANK_4:uint = 4;
      
      public static const RANK_3:uint = 3;
      
      public static const RANK_2:uint = 2;
      
      public static const RANK_1:uint = 1;
      
      public static const FOUNDER:uint = RANK_10;
      
      public static const TWO_IC:uint = RANK_9;
      
      public function AllianceRank()
      {
         super();
         throw new Error("AllianceRank cannot be directly instantiated.");
      }
      
      public static function getAllRanks() : Array
      {
         return [RANK_10,RANK_9,RANK_8,RANK_7,RANK_6,RANK_5,RANK_4,RANK_3,RANK_2,RANK_1];
      }
      
      public static function hasPrivilege(param1:uint, param2:uint) : Boolean
      {
         var _loc3_:uint = uint(_privileges[param1]);
         return (_loc3_ & param2) != 0;
      }
      
      internal static function deserialize(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:uint = 0;
         _privileges = new Dictionary(true);
         for(_loc2_ in param1)
         {
            _loc3_ = uint(_loc2_);
            _privileges[_loc3_] = uint(param1[_loc2_]);
         }
      }
   }
}

