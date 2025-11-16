package thelaststand.app.game.logic.ai.effects
{
   import thelaststand.app.game.data.ItemAttributes;
   import thelaststand.app.game.logic.ai.AIAgent;
   
   public class GenericEffect extends AbstractAIEffect
   {
      
      private var _attributes:ItemAttributes;
      
      private var _agent:AIAgent;
      
      public function GenericEffect(param1:AIAgent, param2:ItemAttributes, param3:Number = 0)
      {
         super();
         this._agent = param1;
         this._attributes = param2;
         _length = param3;
      }
      
      override public function dispose() : void
      {
         this._agent = null;
         this._attributes = null;
         super.dispose();
      }
      
      override public function start(param1:Number) : void
      {
         super.start(param1);
      }
      
      override public function update(param1:Number, param2:Number) : void
      {
         super.update(param1,param2);
      }
      
      override public function getMultiplierForAttribute(param1:String) : Number
      {
         var _loc2_:Number = Number(this._attributes.getValue(ItemAttributes.GROUP_SURVIVOR,param1));
         if(isNaN(_loc2_))
         {
            return 0;
         }
         return _loc2_;
      }
   }
}

