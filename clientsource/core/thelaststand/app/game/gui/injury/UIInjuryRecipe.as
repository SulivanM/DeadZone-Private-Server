package thelaststand.app.game.gui.injury
{
   import com.quasimondo.geom.ColorMatrix;
   import flash.display.Bitmap;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.AntiAliasType;
   import flash.utils.Timer;
   import org.osflash.signals.Signal;
   import thelaststand.app.display.BodyTextField;
   import thelaststand.app.display.Effects;
   import thelaststand.app.display.TitleTextField;
   import thelaststand.app.game.data.Item;
   import thelaststand.app.game.data.MedicalItem;
   import thelaststand.app.game.data.injury.Injury;
   import thelaststand.app.game.data.injury.InjurySeverity;
   import thelaststand.app.game.gui.UIRequirementsChecklist;
   import thelaststand.app.game.gui.dialogues.ClothingPreviewDisplayOptions;
   import thelaststand.app.game.gui.dialogues.ItemListDialogue;
   import thelaststand.app.game.gui.dialogues.ItemListOptions;
   import thelaststand.app.gui.UIComponent;
   import thelaststand.app.network.Network;
   import thelaststand.app.utils.DateTimeUtils;
   import thelaststand.app.utils.GraphicUtils;
   import thelaststand.app.utils.XMLUtils;
   import thelaststand.common.lang.Language;
   import thelaststand.common.resources.ResourceManager;
   
   public class UIInjuryRecipe extends UIComponent
   {
      
      private const INDENT:int = 12;
      
      private var _width:int = 288;
      
      private var _height:int = 250;
      
      private var _timeAreaHeight:int = 62;
      
      private var _infoAreaHeight:int;
      
      private var _panelSpacing:int = 8;
      
      private var _timePanelPadding:int = 6;
      
      private var _injury:Injury;
      
      private var _inputs:Vector.<UIInputItem> = new Vector.<UIInputItem>();
      
      private var _inputItems:Vector.<Item> = new Vector.<Item>();
      
      private var _updateTimer:Timer;
      
      private var bmp_title:Bitmap;
      
      private var bmp_time:Bitmap;
      
      private var txt_title:TitleTextField;
      
      private var txt_materials:BodyTextField;
      
      private var txt_timeTitle:BodyTextField;
      
      private var txt_time:BodyTextField;
      
      private var ui_requirements:UIRequirementsChecklist;
      
      public var itemChanged:Signal = new Signal();
      
      public function UIInjuryRecipe()
      {
         super();
         this._infoAreaHeight = this._height - this._timeAreaHeight - this._panelSpacing;
         GraphicUtils.drawUIBlock(graphics,this._width,this._infoAreaHeight);
         this.bmp_title = new Bitmap(new BmpTopBarBackground(),"auto",true);
         this.bmp_title.x = this.bmp_title.y = 4;
         this.bmp_title.height = 34;
         this.bmp_title.width = int(this._width - this.bmp_title.x * 2);
         addChild(this.bmp_title);
         this.txt_title = new TitleTextField({
            "text":" ",
            "color":16777215,
            "size":21,
            "autoSize":"none",
            "align":"center",
            "filters":[Effects.TEXT_SHADOW]
         });
         this.txt_title.width = this._width;
         this.txt_title.y = int(this.bmp_title.y + (this.bmp_title.height - this.txt_title.height) * 0.5);
         addChild(this.txt_title);
         this.txt_materials = new BodyTextField({
            "color":12961221,
            "size":11,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_materials.x = this.INDENT - 4;
         this.txt_materials.y = int(this.bmp_title.y + this.bmp_title.height + 4);
         this.txt_materials.text = Language.getInstance().getString("injuries_materials").toUpperCase();
         addChild(this.txt_materials);
         this.ui_requirements = new UIRequirementsChecklist();
         this.ui_requirements.width = int(this.width - this.INDENT * 2);
         this.ui_requirements.x = this.INDENT;
         addChild(this.ui_requirements);
         this._updateTimer = new Timer(500);
         this._updateTimer.addEventListener(TimerEvent.TIMER,this.onUpdateTimerTick,false,0,true);
         var _loc1_:int = this._infoAreaHeight + this._panelSpacing;
         GraphicUtils.drawUIBlock(graphics,this._width,this._timeAreaHeight,0,_loc1_);
         graphics.beginFill(1381653);
         graphics.drawRect(this._timePanelPadding,_loc1_ + 22,this._width - this._timePanelPadding * 2,this._timeAreaHeight - 16 - this._timePanelPadding * 2);
         graphics.endFill();
         this.txt_timeTitle = new BodyTextField({
            "color":12961221,
            "size":11,
            "bold":true,
            "antiAliasType":AntiAliasType.ADVANCED
         });
         this.txt_timeTitle.x = this.INDENT - 4;
         this.txt_timeTitle.y = int(_loc1_ + 4);
         this.txt_timeTitle.text = Language.getInstance().getString("injuries_time").toUpperCase();
         addChild(this.txt_timeTitle);
         this.bmp_time = new Bitmap(new BmpIconInjuryTimer());
         addChild(this.bmp_time);
         this.txt_time = new BodyTextField({
            "color":Effects.COLOR_WARNING,
            "size":18,
            "bold":true
         });
         addChild(this.txt_time);
      }
      
      public function get numInputs() : int
      {
         return this._inputItems.length;
      }
      
      public function get injury() : Injury
      {
         return this._injury;
      }
      
      public function set injury(param1:Injury) : void
      {
         if(param1 == this._injury)
         {
            return;
         }
         this._injury = param1;
         this._updateTimer.start();
         if(this._injury == null)
         {
            this._inputItems.length = 0;
         }
         else
         {
            this.autoFillInputItems();
         }
         invalidate();
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      override public function set width(param1:Number) : void
      {
      }
      
      override public function get height() : Number
      {
         return this._height;
      }
      
      override public function set height(param1:Number) : void
      {
      }
      
      override public function dispose() : void
      {
         var _loc1_:UIInputItem = null;
         super.dispose();
         this._updateTimer.stop();
         this.bmp_title.bitmapData.dispose();
         this.txt_materials.dispose();
         this.txt_title.dispose();
         this.ui_requirements.dispose();
         this.txt_time.dispose();
         this.txt_timeTitle.dispose();
         this.bmp_time.bitmapData.dispose();
         for each(_loc1_ in this._inputs)
         {
            _loc1_.dispose();
         }
         this._inputs = null;
         this._inputItems = null;
         this.itemChanged.removeAll();
      }
      
      public function getInputItem(param1:int) : Item
      {
         return this._inputItems[param1];
      }
      
      private function getMedicalItemsXMLByGrade(param1:String, param2:int, param3:Boolean = true) : Vector.<XML>
      {
         var itemsXML:XML = null;
         var items:XMLList = null;
         var numItems:int = 0;
         var itemsByGrade:Vector.<XML> = null;
         var i:int = 0;
         var medClass:String = param1;
         var medGrade:int = param2;
         var allowBetterGrades:Boolean = param3;
         itemsXML = ResourceManager.getInstance().getResource("xml/items.xml").content;
         items = allowBetterGrades ? itemsXML.item.medical.(cls == medClass && int(grade) >= medGrade) : itemsXML.item.medical.(cls == medClass && int(grade) == medGrade);
         numItems = int(items.length());
         itemsByGrade = new Vector.<XML>(numItems,true);
         i = 0;
         while(i < numItems)
         {
            itemsByGrade[i] = items[i].parent();
            i++;
         }
         itemsByGrade.sort(function(param1:XML, param2:XML):int
         {
            return int(param1.medical.grade) - int(param2.medical.grade);
         });
         return itemsByGrade;
      }
      
      private function getFirstCraftableItemData(param1:Vector.<XML>) : XML
      {
         var _loc4_:XML = null;
         var _loc5_:String = null;
         var _loc2_:int = 0;
         var _loc3_:int = int(param1.length);
         while(_loc2_ < _loc3_)
         {
            _loc4_ = param1[_loc2_];
            _loc5_ = _loc4_.@id.toString();
            if(Network.getInstance().playerData.inventory.hasSchematicForItem(_loc5_))
            {
               return _loc4_;
            }
            _loc2_++;
         }
         return null;
      }
      
      override protected function draw() : void
      {
         var colorMat:ColorMatrix;
         var ox:int;
         var oy:int;
         var tx:int;
         var ty:int;
         var maxCol:int;
         var reqList:XMLList;
         var itemsXML:XML;
         var i:int;
         var len:int;
         var otherReq:XMLList;
         var input:UIInputItem = null;
         var xml:XML = null;
         var col:int = 0;
         var reqNode:XML = null;
         var medClass:String = null;
         var medGrade:int = 0;
         var medItems:Vector.<XML> = null;
         var buyItem:XML = null;
         var bestCraft:XML = null;
         var itemType:String = null;
         var itemData:XML = null;
         for each(input in this._inputs)
         {
            input.dispose();
         }
         this._inputs.length = 0;
         if(this._injury == null)
         {
            this.txt_title.visible = this.ui_requirements.visible = false;
            return;
         }
         this.txt_title.visible = true;
         this.txt_title.text = this._injury.getName().toUpperCase();
         colorMat = new ColorMatrix();
         colorMat.colorize(InjurySeverity.getColor(this._injury.severity));
         colorMat.adjustBrightness(25);
         this.bmp_title.filters = [colorMat.filter];
         xml = this._injury.getXML();
         ox = this.INDENT;
         oy = int(this.txt_materials.y + this.txt_materials.height + 6);
         tx = ox;
         ty = oy;
         maxCol = 2;
         reqList = xml.recipe.med + xml.recipe.itm;
         itemsXML = ResourceManager.getInstance().getResource("xml/items.xml").content;
         i = 0;
         len = int(reqList.length());
         while(i < len)
         {
            reqNode = reqList[i];
            input = new UIInputItem();
            input.clicked.add(this.onClickInputItem);
            input.x = tx;
            input.y = ty;
            if(reqNode.localName() == "med")
            {
               medClass = reqNode.@id.toString();
               medGrade = int(reqNode.@grade.toString());
               medItems = this.getMedicalItemsXMLByGrade(medClass,medGrade,true);
               buyItem = medItems[0];
               if(buyItem.length() > 0)
               {
                  input.getBuyCraftOptions().setBuyItem(buyItem.@id.toString(),buyItem.@type.toString());
                  input.getBuyCraftOptions().showBuy = !buyItem.hasOwnProperty("@canbuy") || buyItem.@canbuy != "0";
                  bestCraft = this.getFirstCraftableItemData(medItems);
                  if(bestCraft != null)
                  {
                     input.getBuyCraftOptions().showCraft = true;
                     input.getBuyCraftOptions().setCraftItem(bestCraft.@id.toString(),bestCraft.@type.toString());
                  }
                  else
                  {
                     input.getBuyCraftOptions().showCraft = true;
                  }
               }
               else
               {
                  input.getBuyCraftOptions().showBuy = false;
                  input.getBuyCraftOptions().showCraft = false;
               }
               input.data = {
                  "medClass":medClass,
                  "medGrade":medGrade
               };
               input.label = Language.getInstance().getString("med_class." + medClass) + "<br/>" + Language.getInstance().getString("med_grade",medGrade);
            }
            else
            {
               itemType = reqNode.@id.toString();
               itemData = itemsXML.item.(@id == itemType)[0];
               input.label = Language.getInstance().getString("items." + itemType);
               input.data = {"item":itemType};
               input.getBuyCraftOptions().showCraft = true;
               input.getBuyCraftOptions().showBuy = !itemData.hasOwnProperty("@canbuy") || itemData.@canbuy != "0";
               input.getBuyCraftOptions().setItem(itemType,itemData.@type.toString());
            }
            input.item = this._inputItems[i];
            if(++col >= maxCol)
            {
               col = 0;
               tx = ox;
               ty += int(input.height + 8);
            }
            else
            {
               tx += 138;
            }
            addChild(input);
            this._inputs.push(input);
            i++;
         }
         if(reqList.length() > 0)
         {
            ty += int(input.height + 8);
         }
         otherReq = xml.recipe.children().(localName() != "med" && localName() != "itm" && localName() != "res");
         otherReq = XMLUtils.sortXMLList(otherReq,function(param1:XML, param2:XML):int
         {
            return int(param1.@lvl) - int(param2.@lvl);
         });
         this.ui_requirements.list = otherReq;
         this.ui_requirements.visible = true;
         this.ui_requirements.y = this._infoAreaHeight - 25;
         this.updateTime();
      }
      
      private function updateTime() : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         this.txt_time.text = DateTimeUtils.secondsToString(this._injury.timer.getSecondsRemaining(),false,true);
         var _loc1_:int = 4;
         var _loc2_:int = this.bmp_time.width + _loc1_ + this.txt_time.width;
         _loc3_ = this._height - this._timeAreaHeight + 22;
         _loc4_ = this._timeAreaHeight - this._timePanelPadding * 2 - 16;
         this.bmp_time.x = this._timePanelPadding + int((this._width - this._timePanelPadding * 2 - _loc2_) * 0.5);
         this.bmp_time.y = int(_loc3_ + (_loc4_ - this.bmp_time.height) * 0.5);
         this.txt_time.x = int(this.bmp_time.x + this.bmp_time.width + _loc1_);
         this.txt_time.y = int(_loc3_ + (_loc4_ - this.txt_time.height) * 0.5);
      }
      
      private function autoFillInputItems() : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:XML = null;
         var _loc9_:Vector.<Item> = null;
         var _loc10_:Item = null;
         var _loc11_:String = null;
         var _loc12_:int = 0;
         var _loc13_:Vector.<XML> = null;
         var _loc14_:String = null;
         var _loc15_:String = null;
         var _loc1_:XML = this._injury.getXML();
         var _loc2_:XMLList = _loc1_.recipe.med + _loc1_.recipe.itm;
         var _loc3_:int = int(_loc2_.length());
         this._inputItems.length = 0;
         this._inputItems.length = _loc3_;
         var _loc7_:int = 0;
         while(_loc7_ < _loc3_)
         {
            _loc8_ = _loc2_[_loc7_];
            if(_loc8_.localName() == "med")
            {
               _loc11_ = _loc8_.@id.toString();
               _loc12_ = int(_loc8_.@grade.toString());
               _loc13_ = this.getMedicalItemsXMLByGrade(_loc11_,_loc12_,false);
               _loc4_ = 0;
               loop2:
               while(_loc4_ < _loc13_.length)
               {
                  _loc14_ = String(_loc13_[_loc4_].@id);
                  _loc9_ = Network.getInstance().playerData.inventory.getItemsOfType(_loc14_);
                  _loc5_ = 0;
                  _loc6_ = int(_loc9_.length);
                  while(_loc5_ < _loc6_)
                  {
                     _loc10_ = _loc9_[_loc5_];
                     if(this.isInputItemValid(_loc10_,_loc7_))
                     {
                        this._inputItems[_loc7_] = _loc10_;
                        break loop2;
                     }
                     _loc5_++;
                  }
                  _loc4_++;
               }
            }
            else
            {
               _loc15_ = String(_loc8_.@id);
               if(_loc15_)
               {
                  _loc9_ = Network.getInstance().playerData.inventory.getItemsOfType(_loc15_);
                  _loc4_ = 0;
                  _loc6_ = int(_loc9_.length);
                  while(_loc4_ < _loc6_)
                  {
                     _loc10_ = _loc9_[_loc4_];
                     if(this.isInputItemValid(_loc10_,_loc7_))
                     {
                        this._inputItems[_loc7_] = _loc10_;
                        break;
                     }
                     _loc4_++;
                  }
               }
            }
            _loc7_++;
         }
      }
      
      private function isInputItemValid(param1:Item, param2:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Item = null;
         if(param1 == null)
         {
            return true;
         }
         if(this._inputItems[param2] == param1)
         {
            return true;
         }
         if(!param1.quantifiable)
         {
            return this._inputItems.indexOf(param1) == -1;
         }
         _loc3_ = 0;
         _loc4_ = 0;
         _loc5_ = int(this._inputItems.length);
         while(_loc4_ < _loc5_)
         {
            _loc6_ = this._inputItems[_loc4_];
            if(_loc6_ == param1)
            {
               _loc3_++;
            }
            _loc4_++;
         }
         if(_loc3_ >= param1.quantity)
         {
            return false;
         }
         return true;
      }
      
      private function onClickInputItem(param1:MouseEvent) : void
      {
         var inputData:Object;
         var inputItem:UIInputItem = null;
         var inputIndex:int = 0;
         var dlgTitle:String = null;
         var i:int = 0;
         var dlgInv:ItemListDialogue = null;
         var medItem:MedicalItem = null;
         var e:MouseEvent = param1;
         inputItem = UIInputItem(e.currentTarget);
         inputIndex = int(this._inputs.indexOf(inputItem));
         var items:Vector.<Item> = null;
         var options:ItemListOptions = new ItemListOptions();
         options.clothingPreviews = ClothingPreviewDisplayOptions.DISABLED;
         options.showNoneItem = true;
         inputData = inputItem.data;
         if(inputData.medClass != null)
         {
            items = Network.getInstance().playerData.inventory.getItemsOfCategory("medical");
            i = int(items.length - 1);
            while(i >= 0)
            {
               medItem = items[i] as MedicalItem;
               if(medItem == null || medItem.medicalClass != inputData.medClass || medItem.medicalGrade < inputData.medGrade)
               {
                  items.splice(i,1);
               }
               else if(!this.isInputItemValid(medItem,inputIndex))
               {
                  items.splice(i,1);
               }
               i--;
            }
            dlgTitle = Language.getInstance().getString("srv_healselectitem_title",Language.getInstance().getString("med_class." + inputData.medClass));
            options.header = new UIMedicalItemSelectHeader(inputData.medClass,inputData.medGrade);
         }
         else
         {
            items = Network.getInstance().playerData.inventory.getItemsOfType(inputData.item);
            i = int(items.length - 1);
            while(i >= 0)
            {
               if(!this.isInputItemValid(items[i],inputIndex))
               {
                  items.splice(i,1);
               }
               i--;
            }
            dlgTitle = Language.getInstance().getString("srv_healselectitem_title",Language.getInstance().getString("items." + inputData.item));
         }
         dlgInv = new ItemListDialogue(dlgTitle,items,options);
         dlgInv.selectItem(this._inputItems[inputIndex]);
         dlgInv.selected.addOnce(function(param1:Item):void
         {
            if(isInputItemValid(param1,inputIndex))
            {
               _inputItems[inputIndex] = param1;
               inputItem.item = param1;
               itemChanged.dispatch();
            }
            dlgInv.close();
         });
         dlgInv.open();
      }
      
      private function onUpdateTimerTick(param1:TimerEvent) : void
      {
         this.updateTime();
      }
   }
}

