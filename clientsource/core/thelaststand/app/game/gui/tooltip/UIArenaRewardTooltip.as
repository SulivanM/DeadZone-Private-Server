package thelaststand.app.game.gui.tooltip
{
   import com.exileetiquette.utils.NumberFormatter;
   import thelaststand.common.lang.Language;
   
   public class UIArenaRewardTooltip extends UIRewardTierTooltip
   {
      
      public function UIArenaRewardTooltip()
      {
         super();
      }
      
      override protected function getTitle() : String
      {
         return Language.getInstance().getString("arena.reward_title").toUpperCase();
      }
      
      override protected function getRewardInstruction() : String
      {
         var _loc1_:String = NumberFormatter.format(Number(tierXML.@score),0);
         switch(state)
         {
            case STATE_PAST:
               return Language.getInstance().getString("arena.reward_state_past",_loc1_);
            case STATE_ACTIVE:
               return Language.getInstance().getString("arena.reward_state_active",_loc1_);
            case STATE_FUTURE:
         }
         return Language.getInstance().getString("arena.reward_state_future",_loc1_);
      }
      
      override protected function getDisclaimer() : String
      {
         switch(state)
         {
            case STATE_PAST:
               return Language.getInstance().getString("arena.reward_desc_past");
            case STATE_ACTIVE:
               return Language.getInstance().getString("arena.reward_desc_active");
            case STATE_FUTURE:
         }
         return Language.getInstance().getString("arena.reward_desc_future");
      }
   }
}

