package thelaststand.app.game.logic.ai
{
   import thelaststand.app.game.logic.ai.states.IAIState;
   
   public class AIStateMachine
   {
      
      private var _current:IAIState;
      
      private var _previous:IAIState;
      
      private var _next:IAIState;
      
      private var _timeElapsed:Number = 0;
      
      private var _stateHistory:Vector.<IAIState>;
      
      public function AIStateMachine()
      {
         super();
         this._stateHistory = new Vector.<IAIState>();
      }
      
      public function gotoNextState() : void
      {
         this.setState(this._next);
      }
      
      public function gotoPreviousState() : IAIState
      {
         return this.setState(this._previous);
      }
      
      public function setNextState(param1:IAIState) : IAIState
      {
         this._next = param1;
         return param1;
      }
      
      public function clear() : void
      {
         var _loc1_:IAIState = null;
         if(this._current != null)
         {
            this._current.dispose();
         }
         if(this._previous != null)
         {
            this._previous.dispose();
         }
         if(this._next != null)
         {
            this._next.dispose();
         }
         for each(_loc1_ in this._stateHistory)
         {
            if(_loc1_ != null)
            {
               _loc1_.dispose();
            }
         }
         this._stateHistory.length = 0;
         this._previous = this._next = null;
         this._current = null;
      }
      
      public function setState(param1:IAIState, param2:Boolean = false) : IAIState
      {
         if(this._current != null)
         {
            this._current.exit(this._timeElapsed);
         }
         if(param2)
         {
            this.clear();
         }
         this._previous = this._current;
         this._current = param1;
         if(this._current != null)
         {
            this._current.enter(this._timeElapsed);
            this._stateHistory.push(this._current);
         }
         return param1;
      }
      
      public function update(param1:Number, param2:Number) : void
      {
         this._timeElapsed = param2;
         if(this._current != null)
         {
            this._current.update(param1,param2);
         }
      }
      
      public function get state() : IAIState
      {
         return this._current;
      }
      
      public function get nextState() : IAIState
      {
         return this._next;
      }
      
      public function get prevState() : IAIState
      {
         return this._previous;
      }
   }
}

