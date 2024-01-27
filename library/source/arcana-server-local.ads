with
     gel.Sprite,
     gel.World.server;


private
package arcana.Server.local
is

   ---------------
   --- Sprite Data
   --

   null_Site : constant gel.math.Vector_3 := [gel.math.Real'Last,
                                              gel.math.Real'Last,
                                              gel.math.Real'Last];


   type sprite_Data is new gel.Sprite.any_user_Data with
      record
         Pace           : Pace_t            := Halt;
         Movement       : gel.Math.Vector_3 := gel.Math.Origin_3D;
         Spin           : gel.Math.Degrees  :=  0.0;
         Target         : gel.Sprite.view;
         target_Site    : gel.Math.Vector_3 := null_Site;
         is_Approaching : Boolean           := False;
      end record;




   procedure World_is (Now : in gel.World.server.view);


end arcana.Server.local;
