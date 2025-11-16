package thelaststand.app.game.data.alliance
{
   import com.exileetiquette.utils.NumberFormatter;
   import org.osflash.signals.Signal;
   import thelaststand.common.lang.Language;
   
   public class AllianceTask
   {
      
      private var _id:String;
      
      private var _value:int;
      
      private var _goalPerMember:int;
      
      private var _tokensPerMember:int;
      
      private var _goalType:String;
      
      private var _goalId:String;
      
      private var _imageURI:String;
      
      private var _iconType:String;
      
      public var progressChanged:Signal = new Signal(AllianceTask);
      
      public function AllianceTask(param1:XML)
      {
         super();
         this.parse(param1);
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function get isComplete() : Boolean
      {
         return this.progress >= 1;
      }
      
      public function get goal() : int
      {
         return this._goalPerMember * Math.max(AllianceSystem.getInstance().round.memberCount,2);
      }
      
      public function get goalType() : String
      {
         return this._goalType;
      }
      
      public function get goalId() : String
      {
         return this._goalId;
      }
      
      public function get value() : int
      {
         return this._value;
      }
      
      public function get progress() : Number
      {
         return this.value / this.goal;
      }
      
      public function get tokenReward() : int
      {
         return this._tokensPerMember * Math.max(AllianceSystem.getInstance().round.memberCount,2);
      }
      
      public function get imageURI() : String
      {
         return this._imageURI;
      }
      
      public function get iconType() : String
      {
         return this._iconType;
      }
      
      public function getName() : String
      {
         return Language.getInstance().getString("alliance.task_" + this._id);
      }
      
      public function getDescription() : String
      {
         return Language.getInstance().getString("alliance.task_" + this._id + "_desc");
      }
      
      public function getGoalDescription() : String
      {
         switch(this._goalType)
         {
            case "res":
               return NumberFormatter.format(this.goal,0) + " " + Language.getInstance().getString("items." + this._goalId);
            case "stat":
               return NumberFormatter.format(this.goal,0) + " " + Language.getInstance().getString("stat." + this._goalId);
            default:
               return "?";
         }
      }
      
      internal function setValue(param1:Number) : void
      {
         if(param1 == this._value)
         {
            return;
         }
         this._value = param1;
         this.progressChanged.dispatch(this);
      }
      
      private function parse(param1:XML) : void
      {
         this._id = param1.@id.toString();
         this._imageURI = param1.img.@uri.toString();
         this._iconType = param1.icon.toString();
         var _loc2_:XML = param1.goal.children()[0];
         this._goalType = _loc2_.localName();
         this._goalId = _loc2_.@id.toString();
         this._goalPerMember = int(_loc2_.toString());
         var _loc3_:XML = param1.tokens[0];
         this._tokensPerMember = int(_loc3_.toString());
      }
   }
}

