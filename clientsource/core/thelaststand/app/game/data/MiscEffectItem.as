package thelaststand.app.game.data
{
   import thelaststand.common.lang.Language;
   
   public class MiscEffectItem extends EffectItem
   {
      
      public function MiscEffectItem()
      {
         super();
      }
      
      override public function getName() : String
      {
         if(_name == null)
         {
            _name = Language.getInstance().getString("effect_names." + effect.type);
         }
         return _name;
      }
   }
}

