package thelaststand.common.gui.dialogues
{
   import flash.system.Capabilities;
   import flash.utils.Dictionary;
   import org.osflash.signals.DeluxeSignal;
   import org.osflash.signals.events.GenericEvent;
   import thelaststand.app.network.Network;
   
   public class DialogueManager
   {
      
      private static var _instance:DialogueManager;
      
      private var _activeDialogue:Dialogue;
      
      private var _dialogues:Vector.<Dialogue>;
      
      private var _dialoguesById:Dictionary;
      
      private var _dialoguesOpen:Vector.<Dialogue>;
      
      public var dialogueOpened:DeluxeSignal;
      
      public var dialogueClosed:DeluxeSignal;
      
      public function DialogueManager(param1:DialogueManagerSingletonEnforcer)
      {
         super();
         if(!param1)
         {
            throw new Error("DialogueManager is a Singleton and cannot be directly instantiated. Use DialogueManager.getInstance().");
         }
         this._dialogues = new Vector.<Dialogue>();
         this._dialoguesById = new Dictionary(true);
         this._dialoguesOpen = new Vector.<Dialogue>();
         this.dialogueOpened = new DeluxeSignal(this);
         this.dialogueClosed = new DeluxeSignal(this);
      }
      
      public static function getInstance() : DialogueManager
      {
         if(!_instance)
         {
            _instance = new DialogueManager(new DialogueManagerSingletonEnforcer());
         }
         return _instance;
      }
      
      public function closeAll() : void
      {
         var _loc1_:Dialogue = null;
         for each(_loc1_ in this._dialogues)
         {
            delete this._dialoguesById[_loc1_.id];
            _loc1_.close();
         }
         this._activeDialogue = null;
         this._dialogues.length = 0;
         this._dialoguesOpen.length = 0;
      }
      
      public function closeAllModal() : void
      {
         var _loc2_:Dialogue = null;
         var _loc1_:int = int(this._dialogues.length - 1);
         while(_loc1_ >= 0)
         {
            _loc2_ = this._dialogues[_loc1_];
            if(_loc2_.modal)
            {
               delete this._dialoguesById[_loc2_.id];
               _loc2_.close();
               if(_loc2_ == this._activeDialogue)
               {
                  this._activeDialogue = null;
               }
               this._dialogues.splice(_loc1_,1);
            }
            _loc1_--;
         }
      }
      
      public function closeAllNonModal() : void
      {
         var _loc2_:Dialogue = null;
         var _loc1_:int = int(this._dialogues.length - 1);
         while(_loc1_ >= 0)
         {
            _loc2_ = this._dialogues[_loc1_];
            if(!_loc2_.modal)
            {
               delete this._dialoguesById[_loc2_.id];
               _loc2_.close();
               if(_loc2_ == this._activeDialogue)
               {
                  this._activeDialogue = null;
               }
               this._dialogues.splice(_loc1_,1);
            }
            _loc1_--;
         }
      }
      
      public function closeDialogue(param1:* = null) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Dialogue = null;
         if(!param1)
         {
            if(this._activeDialogue != null)
            {
               this._activeDialogue.close();
            }
            return;
         }
         if(param1 is String)
         {
            _loc3_ = this.getDialogueById(String(param1));
            if(!_loc3_)
            {
               return;
            }
            _loc3_.close();
            return;
         }
         if(param1 is Dialogue)
         {
            _loc2_ = int(this._dialogues.indexOf(Dialogue(param1)));
            if(_loc2_ == -1)
            {
               return;
            }
            Dialogue(param1).close();
            return;
         }
         throw new TypeError("idOrDialogue must be either a String or an Dialogue instance.");
      }
      
      public function getActiveDialogue() : Dialogue
      {
         return this._activeDialogue;
      }
      
      public function getDialogueById(param1:String) : Dialogue
      {
         return this._dialoguesById[param1];
      }
      
      internal function addDialogue(param1:Dialogue) : void
      {
         if(this._dialogues.indexOf(param1) > -1)
         {
            return;
         }
         this._dialogues.push(param1);
         this._dialoguesById[param1.id] = param1;
         param1.opened.add(this.onDialogueOpened);
         param1.closed.add(this.onDialogueClosed);
      }
      
      internal function removeDialogue(param1:Dialogue) : void
      {
         var _loc2_:int = int(this._dialogues.indexOf(param1));
         if(_loc2_ > -1)
         {
            this._dialogues.splice(_loc2_,1);
         }
         _loc2_ = int(this._dialoguesOpen.indexOf(param1));
         if(_loc2_ > -1)
         {
            this._dialoguesOpen.splice(_loc2_,1);
         }
         if(this._dialoguesById[param1.id] == param1)
         {
            this._dialoguesById[param1.id] == null;
            delete this._dialoguesById[param1.id];
         }
         if(this._activeDialogue == param1)
         {
            this._activeDialogue = null;
         }
         if(param1.weakReference)
         {
            param1.opened.remove(this.onDialogueOpened);
            param1.closed.remove(this.onDialogueClosed);
         }
      }
      
      private function onDialogueClosed(param1:Dialogue) : void
      {
         var d:Dialogue = param1;
         try
         {
            this.removeDialogue(d);
            this._activeDialogue = this._dialoguesOpen.length > 0 ? this._dialoguesOpen[this._dialoguesOpen.length - 1] : null;
            this.dialogueClosed.dispatch(new GenericEvent(),d);
            if(d.weakReference)
            {
               d.dispose();
            }
         }
         catch(error:Error)
         {
            if(Capabilities.isDebugger)
            {
               if(Network.getInstance().client != null)
               {
                  Network.getInstance().client.errorLog.writeError("DialogueManager.onDialogueClosed",error.message,error.getStackTrace(),null);
               }
               throw error;
            }
         }
      }
      
      private function onDialogueOpened(param1:Dialogue) : void
      {
         var d:Dialogue = param1;
         try
         {
            this._activeDialogue = d;
            this._dialoguesOpen.push(d);
            this.dialogueOpened.dispatch(new GenericEvent(),d);
         }
         catch(error:Error)
         {
            if(Capabilities.isDebugger)
            {
               if(Network.getInstance().client != null)
               {
                  Network.getInstance().client.errorLog.writeError("DialogueManager.onDialogueOpened",error.message,error.getStackTrace(),null);
               }
               throw error;
            }
         }
      }
      
      public function get numDialoguesOpen() : int
      {
         return this._dialoguesOpen.length;
      }
      
      public function get numModalDialoguesOpen() : int
      {
         var _loc2_:Dialogue = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._dialoguesOpen)
         {
            if(_loc2_.modal)
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      public function get openDialogues() : Vector.<Dialogue>
      {
         return this._dialogues;
      }
   }
}

class DialogueManagerSingletonEnforcer
{
   
   public function DialogueManagerSingletonEnforcer()
   {
      super();
   }
}
