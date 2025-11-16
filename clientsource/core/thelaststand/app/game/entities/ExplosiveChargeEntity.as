package thelaststand.app.game.entities
{
   import flash.geom.Vector3D;
   import flash.utils.getTimer;
   import thelaststand.app.game.data.Gear;
   import thelaststand.app.game.data.ItemAttributes;
   import thelaststand.app.game.entities.effects.Explosion;
   import thelaststand.app.game.entities.effects.ExplosionType;
   import thelaststand.app.game.entities.effects.SmokeExplosion;
   import thelaststand.app.game.entities.gui.UIRangeIndicator;
   import thelaststand.app.game.gui.mission.UIHUDCircleProgress;
   import thelaststand.app.game.logic.ai.AIAgent;
   import thelaststand.engine.audio.SoundSource3D;
   import thelaststand.engine.meshes.MeshGroup;
   import thelaststand.engine.objects.GameEntity;
   import thelaststand.engine.objects.GameEntityFlags;
   
   public class ExplosiveChargeEntity extends GameEntity
   {
      
      private static var _nextId:int = 0;
      
      private var _item:Gear;
      
      private var _owner:AIAgent;
      
      private var _model:MeshGroup;
      
      private var _spawnTime:Number;
      
      private var _detonationTime:Number = 0;
      
      private var _exploded:Boolean = false;
      
      private var _damage:Number = 2;
      
      private var _damageVsBuildings:Number = 1;
      
      private var _rangexy:Number;
      
      private var _rangez:Number;
      
      private var _soundSource:SoundSource3D;
      
      private var ui_range:UIRangeIndicator;
      
      public var ui_timer:UIHUDCircleProgress;
      
      public function ExplosiveChargeEntity(param1:AIAgent, param2:Gear)
      {
         super();
         passable = false;
         losVisible = false;
         flags |= GameEntityFlags.IGNORE_TILEMAP | GameEntityFlags.IGNORE_TRANSFORMS;
         name = "grenade" + _nextId++;
         this._owner = param1;
         this._item = param2;
         this._soundSource = new SoundSource3D(transform.position,name + "_sound");
         this._rangexy = this._item.attributes.getValue(ItemAttributes.GROUP_GEAR,"rng") * 100;
         this._rangez = this._item.attributes.getValue(ItemAttributes.GROUP_GEAR,"vrng") * 100;
         this._detonationTime = this._item.attributes.getValue(ItemAttributes.GROUP_GEAR,"dettime") * 1000;
         asset = this._model = new MeshGroup();
         this._model.addChildrenFromResource(param2.xml.mdl.@uri.toString());
         this._model.mouseEnabled = this._model.mouseChildren = false;
         this.ui_range = new UIRangeIndicator(this._rangexy);
         addedToScene.addOnce(this.onAddedToScene);
         removedFromScene.addOnce(this.onRemovedFromScene);
      }
      
      override public function dispose() : void
      {
         addedToScene.remove(this.onAddedToScene);
         removedFromScene.remove(this.onRemovedFromScene);
         super.dispose();
         this._soundSource.dispose();
         if(this.ui_timer != null)
         {
            this.ui_timer.dispose();
         }
         if(this.ui_range != null)
         {
            this.ui_range.dispose();
         }
         this._owner = null;
         this._item = null;
      }
      
      override public function update(param1:Number = 1) : void
      {
         if(this._exploded)
         {
            return;
         }
         var _loc2_:Number = getTimer() - this._spawnTime;
         var _loc3_:Number = _loc2_ / this._detonationTime;
         this.ui_timer.progress = _loc3_;
         if(_loc3_ >= 1)
         {
            this.explode();
         }
      }
      
      private function explode() : void
      {
         var _loc1_:Vector3D = null;
         var _loc2_:Explosion = null;
         var _loc3_:SmokeExplosion = null;
         this._exploded = true;
         _loc1_ = transform.position;
         switch(this._item.xml.gear.exp.toString())
         {
            case ExplosionType.FRAG:
               _loc2_ = new Explosion(this._owner,_loc1_.x,_loc1_.y,_loc1_.z,this._item.attributes.getValue(ItemAttributes.GROUP_GEAR,"dmg"),this._item.attributes.getValue(ItemAttributes.GROUP_GEAR,"dmg_bld"),this._rangexy,this._rangez,this._owner.blackboard.allAgents,this._item.getSound("explode"));
               _loc2_.ownerItem = this._item;
               scene.addEntity(_loc2_);
               break;
            case ExplosionType.SMOKE:
               _loc3_ = new SmokeExplosion(_loc1_.x,_loc1_.y,_loc1_.z,this._rangexy,this._item.attributes.getValue(ItemAttributes.GROUP_GEAR,"dur"));
               scene.addEntity(_loc3_);
         }
         this.dispose();
      }
      
      private function onAddedToScene(param1:GameEntity) : void
      {
         this._spawnTime = getTimer();
         scene.addEntity(this._soundSource);
         this._soundSource.play(this._item.getSound("place"));
         this.ui_range.transform.position.copyFrom(transform.position);
         scene.addEntity(this.ui_range);
         this.ui_timer = new UIHUDCircleProgress(scene,transform.position,new Vector3D(0,0,100));
      }
      
      private function onRemovedFromScene(param1:GameEntity) : void
      {
         scene.removeEntity(this._soundSource);
         scene.removeEntity(this.ui_range);
         this.ui_timer.dispose();
         this.ui_timer = null;
      }
   }
}

