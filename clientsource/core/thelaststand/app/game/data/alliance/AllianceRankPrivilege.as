package thelaststand.app.game.data.alliance
{
   public class AllianceRankPrivilege
   {
      
      public static const None:uint = 0;
      
      public static const ChangeLeadership:uint = 1;
      
      public static const Disband:uint = 2;
      
      public static const PostMessages:uint = 4;
      
      public static const DeleteMessages:uint = 8;
      
      public static const InviteMembers:uint = 16;
      
      public static const RemoveMembers:uint = 32;
      
      public static const PromoteMembers:uint = 64;
      
      public static const DemoteMembers:uint = 128;
      
      public static const SpendTokens:uint = 256;
      
      public static const EditRankNames:uint = 512;
      
      public static const EditBanner:uint = 1024;
      
      public static const All:uint = 1048575;
      
      public function AllianceRankPrivilege()
      {
         super();
         throw new Error("AllianceRankPrivilege cannot be directly instantiated.");
      }
   }
}

