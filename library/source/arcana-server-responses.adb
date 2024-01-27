with
     gel.Sprite,
     arcana.Server.local;


package body arcana.Server.Responses
is

   the_World : gel.World.server.view;


   procedure World_is (Now : in gel.World.server.view)
   is
   begin
      the_World := Now;
   end World_is;




   overriding
   procedure respond (Self : in out pc_move_Response;   to_Event : in lace.Event.item'Class)
   is
      use gel.Math;

      the_Event       : constant pc_move_Event                 := pc_move_Event            (to_Event);
      the_Sprite      :          gel.Sprite.view          renames the_World.fetch_Sprite   (the_Event.sprite_Id);
      the_sprite_Data :          Server.local.sprite_Data renames Server.local.sprite_Data (the_Sprite.user_Data.all);

   begin
      if the_Event.On
      then
         case the_Event.Direction
         is
            when Forward  => the_sprite_Data.Movement := the_sprite_Data.Movement + [0.0,  4.0, 0.0];
            when Backward => the_sprite_Data.Movement := the_sprite_Data.Movement + [0.0, -4.0, 0.0];
            when Left     => the_sprite_Data.Spin     := the_sprite_Data.Spin     + 180.0;
            when Right    => the_sprite_Data.Spin     := the_sprite_Data.Spin     - 180.0;
         end case;
      else
         case the_Event.Direction
         is
            when Forward  => the_sprite_Data.Movement := the_sprite_Data.Movement + [ 0.0, -4.0, 0.0];
            when Backward => the_sprite_Data.Movement := the_sprite_Data.Movement + [ 0.0,  4.0, 0.0];
            when Left     => the_sprite_Data.Spin     := the_sprite_Data.Spin     - 180.0;
            when Right    => the_sprite_Data.Spin     := the_sprite_Data.Spin     + 180.0;
         end case;
      end if;

      the_Sprite.Gyre_is ([0.0,
                          0.0,
                          to_Radians (the_sprite_Data.Spin)]);
   end respond;




   overriding
   procedure respond (Self : in out pc_pace_Response;   to_Event : in lace.Event.item'Class)
   is
      the_Event       : constant pc_pace_Event                 := pc_pace_Event            (to_Event);
      the_Sprite      :          gel.Sprite.view          renames the_World.fetch_Sprite   (the_Event.sprite_Id);
      the_sprite_Data :          Server.local.sprite_Data renames Server.local.sprite_Data (the_Sprite.user_Data.all);
   begin
      the_sprite_Data.Pace := the_Event.Pace;
   end respond;




   overriding
   procedure respond (Self : in out pc_approaching_Response;   to_Event : in lace.Event.item'Class)
   is
      the_Event       : constant pc_approach_Event             := pc_approach_Event        (to_Event);
      the_Sprite      :          gel.Sprite.view          renames the_World.fetch_Sprite   (the_Event.sprite_Id);
      the_sprite_Data :          Server.local.sprite_Data renames Server.local.sprite_Data (the_Sprite.user_Data.all);
   begin
      the_sprite_Data.is_Approaching := True;
   end respond;




   overriding
   procedure respond (Self : in out target_ground_Response;   to_Event : in lace.Event.item'Class)
   is
      use Gel;

      the_Event       : constant target_ground_Event           := target_ground_Event      (to_Event);
      the_Sprite      :          gel.Sprite.view          renames the_World.fetch_Sprite   (the_Event.sprite_Id);
      the_sprite_Data :          Server.local.sprite_Data renames Server.local.sprite_Data (the_Sprite.user_Data.all);

   begin
      --  if the_Event.sprite_Id = null_sprite_Id
      --  then   -- The ground has been targeted.
      the_sprite_Data.Target         := null;
      the_sprite_Data.is_Approaching := False;
      the_sprite_Data.target_Site    := the_Event.ground_Site;
      --  end if;
   end respond;





   overriding
   procedure respond (Self : in out target_sprite_Response;   to_Event : in lace.Event.item'Class)
   is
      use Gel;

      the_Event       : constant target_sprite_Event           := target_sprite_Event      (to_Event);
      the_Sprite      :          gel.Sprite.view          renames the_World.fetch_Sprite   (the_Event.sprite_Id);
      the_sprite_Data :          Server.local.sprite_Data renames Server.local.sprite_Data (the_Sprite.user_Data.all);
      target_Sprite   :          gel.Sprite.view          renames the_World.fetch_Sprite   (the_Event.target_sprite_Id);
   begin
      --  if the_Event.sprite_Id = null_sprite_Id
      --  then   -- The ground has been targeted.
      the_sprite_Data.Target      := target_Sprite;
      --  the_sprite_Data.target_Site := target_Sprite.Site;
      --  end if;
   end respond;







end arcana.Server.Responses;
