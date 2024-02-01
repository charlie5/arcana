with
     arcana.Server.local,
     arcana.Server.Terrain,
     arcana.Server.all_Clients,
     arcana.Server.Responses,
     arcana.Server.Network,
     arcana.Server.chat,
--  arcana.Character,

     gel.World.server,
     gel.Sprite,
     gel.Forge,
     gel.Events,
     float_Math.Random,

     openGL.Palette,

     Physics,

     lace.Response,
     lace.Event.utility,
     lace.Text.forge,

     system.RPC,

     ada.Exceptions,
     ada.Calendar,
     ada.Text_IO;


package body arcana.Server
is
   use gel.World.server,
       openGL.Palette;

   use type Client.view;


   --------------
   --- The world.
   --

   the_World : aliased gel.World.server.item := forge.to_World (Name       => "arcana.Server",
                                                                Id         => 1,
                                                                space_Kind => physics.Box2D,
                                                                Renderer   => null);
   function World return gel.remote.World.view
   is
   begin
      return the_World'Access;
   end World;



   ---------------
   --- World lock.
   --

   protected world_Lock
   is
      entry acquire;
      entry release;
   private
      Locked : Boolean := False;
   end world_Lock;


   protected body world_Lock
   is
      entry acquire when not Locked
      is
      begin
         Locked := True;
      end acquire;


      entry release when Locked
      is
      begin
         Locked := False;
      end release;

   end world_Lock;



   -----------------------
   --- Client Registration
   --

   procedure register (the_Client : in Client.view)
   is
      Name     : constant String            := the_Client.Name;
      all_Info : constant client_Info_array := all_Clients.Info;
   begin
      log ("Registering '" & Name & "'.");


      for Each of all_Info
      loop
         if Each.Name = Name
         then
            raise Name_already_used;
         end if;
      end loop;


      -- Create the Player.
      --
      declare
         the_Player : gel.Sprite.view;
      begin
         world_Lock.acquire;
         the_Player := gel.Forge.new_circle_Sprite (in_World => the_World'Access,
                                                    Name     => Name,
                                                    Site     => [5.0, 0.0, 0.0],
                                                    Mass     => 1.0,
                                                    Bounce   => 0.0,
                                                    Friction => 0.0,
                                                    Radius   => 0.5,
                                                    Color    => (Green, openGL.Opaque),
                                                    Texture  => openGL.to_Asset ("assets/human.png"));
         the_Player.user_Data_is (new local.sprite_Data);
         the_World.add (the_Player);
         world_Lock.release;

         -- Emit a new 'add sprite' event for any interested observers.
         --
         declare
            the_Event : constant gel.events.new_sprite_Event
              := (Pair => (sprite_Id         => the_Player.Id,
                           sprite_Name       => lace.Text.forge.to_Text_64 (the_Player.Name),
                           graphics_model_Id => the_Player.Visual.Model.Id,
                           physics_model_Id  => the_Player.physics_Model.Id,
                           mass              => the_Player.Mass,
                           transform         => the_Player.Transform,
                           is_visible        => the_Player.is_Visible));
         begin
            the_World.emit (the_Event);
         end;

         the_Client.pc_sprite_Id_is (the_Player.Id);
      end;

      all_Clients.add (the_Client);

      lace.Event.utility.connect (the_Observer  => the_World.local_Observer,
                                  to_Subject    => the_Client.as_Subject,
                                  with_Response => Responses.the_pc_move_Response'Access,
                                  to_Event_Kind => lace.Event.utility.to_Kind (pc_move_Event'Tag));

      lace.Event.utility.connect (the_Observer  => the_World.local_Observer,
                                  to_Subject    => the_Client.as_Subject,
                                  with_Response => Responses.the_pc_pace_Response'Access,
                                  to_Event_Kind => lace.Event.utility.to_Kind (pc_pace_Event'Tag));

      lace.Event.utility.connect (the_Observer  => the_World.local_Observer,
                                  to_Subject    => the_Client.as_Subject,
                                  with_Response => Responses.the_pc_approaching_Response'Access,
                                  to_Event_Kind => lace.Event.utility.to_Kind (pc_approach_Event'Tag));

      lace.Event.utility.connect (the_Observer  => the_World.local_Observer,
                                  to_Subject    => the_Client.as_Subject,
                                  with_Response => Responses.the_target_ground_Response'Access,
                                  to_Event_Kind => lace.Event.utility.to_Kind (target_ground_Event'Tag));

      lace.Event.utility.connect (the_Observer  => the_World.local_Observer,
                                  to_Subject    => the_Client.as_Subject,
                                  with_Response => Responses.the_target_sprite_Response'Access,
                                  to_Event_Kind => lace.Event.utility.to_Kind (target_sprite_Event'Tag));
   end register;




   -------------------------
   --- Client Deregistration
   --

   procedure deregister (the_Client : in Client.view)
   is
      client_Info : constant Server.client_Info := all_Clients.Info (for_Client => the_Client);
   begin
      log ("Deregistering '" & to_String (client_Info.Name) & "'.");

      -- Emit a new 'rid sprite' event for any interested observers.
      --
      declare
         the_Event : constant gel.events.rid_sprite_Event := (Id => client_Info.pc_sprite_Id);
      begin
         the_World.emit (the_Event);
      end;

      all_Clients.rid (the_Client);

      world_Lock.acquire;
      the_World .rid (the_World.fetch_Sprite (client_Info.pc_sprite_Id));
      world_Lock.release;

      lace.Event.utility.disconnect (the_Observer  => the_World.local_Observer,
                                     from_Subject  => client_Info.as_Subject,
                                     for_Response  => Responses.the_pc_move_Response'Access,
                                     to_Event_Kind => lace.Event.utility.to_Kind (pc_move_Event'Tag),
                                     subject_Name  => to_String (client_Info.Name));

      lace.Event.utility.disconnect (the_Observer  => the_World.local_Observer,
                                     from_Subject  => client_Info.as_Subject,
                                     for_Response  => Responses.the_pc_pace_Response'Access,
                                     to_Event_Kind => lace.Event.utility.to_Kind (pc_pace_Event'Tag),
                                     subject_Name  => to_String (client_Info.Name));

   -- TODO: disconnect all repsonses.

   end deregister;




   function fetch_all_Clients return arcana.Client.views
   is
      all_Info : constant client_Info_array := all_Clients.Info;
      Result   :          arcana.Client.views (all_Info'Range);
   begin
      for i in Result'Range
      loop
         Result (i) := all_Info (i).Client;
      end loop;

      return Result;
   end fetch_all_Clients;



   procedure add_Chat (From    : in Client.view;
                       Message : in String)
   is
   begin
      chat.chat_Messages.add (From    => From,
                              Message => Message);
   end add_Chat;




   -------------------
   --- Open/Run/Close.
   --

   Boo : gel.Sprite.view;


   procedure open
   is
      use gel.Math;
      the_one_Tree : gel.Sprite.view;

   begin
      arcana.Server.Responses.World_is (the_World'Access);

      the_World.Gravity_is ([0.0, 0.0, 0.0]);

      -- The One Tree.
      --
      the_one_Tree := gel.Forge.new_circle_Sprite (in_World => the_World'Access,
                                                   Name     => "the One Tree",
                                                   Site     => [0.0, 0.0, 0.0],
                                                   Mass     =>  0.0,
                                                   Bounce   =>  1.0,
                                                   Friction =>  0.0,
                                                   Radius   =>  2.0,
                                                   Texture  => openGL.to_Asset ("assets/tree7.png"));
      the_World.add (the_one_Tree);


      -- 'Boo' test dog.
      --
      Boo := gel.Forge.new_circle_Sprite (in_World => the_World'Access,
                                          Name     => "Boo",
                                          Site     => [0.0, 10.0, 0.0],
                                          Mass     =>  2.0,
                                          Bounce   =>  1.0,
                                          Friction =>  0.0,
                                          Radius   =>  0.5,
                                          Texture  => openGL.to_Asset ("assets/hound-1.png"));
      Boo.user_Data_is (new local.sprite_Data);
      the_World.add    (Boo);


      -- Terrain.
      --
      --  Terrain.set_up_Ground   (in_World => the_World'Access);
      Terrain.set_up_Boulders (in_World => the_World'Access);
      Terrain.set_up_Trees    (in_World => the_World'Access);
   end open;




   procedure run
   is
      use gel.Math,
          ada.Calendar;
      use type gel.Sprite.any_user_Data_view;

      next_evolve_Time   : ada.Calendar.Time := ada.Calendar.Clock;
      next_evolve_Report : ada.Calendar.Time := next_evolve_Time;
      evolve_Count       : Natural           := 0;

      next_Boo_move_Time : ada.Calendar.Time := ada.Calendar.Clock;

   begin
      --  while the_World.is_open
      loop
         evolve_Count := evolve_Count + 1;

         declare
            Now : constant ada.Calendar.TIme := ada.Calendar.Clock;
         begin
            if Now > next_evolve_Report
            then
               --  log ("Server ~ Evolves per second:" & evolve_Count'Image);
               next_evolve_Report := next_evolve_Report + 1.0;
               evolve_Count       := 0;
            end if;
         end;


         world_Lock.acquire;

         -- Movement.
         --
         for Each of the_World.all_Sprites.fetch
         loop
            if Each.user_Data /= null
            then

               declare
                  use type gel.Sprite.view;

                  the_sprite_Data : local.sprite_Data renames local.sprite_Data (Each.user_Data.all);

                  pace_Multiplier : constant array (Pace_t) of Real := [Halt => 0.0,
                                                                        Walk => 0.5,
                                                                        Jog  => 1.0,
                                                                        Run  => 2.0,
                                                                        Dash => 4.0];
               begin
                  Each.Speed_is (  the_sprite_Data.Movement
                                 * pace_Multiplier (the_sprite_Data.Pace)
                                 * Each.Spin);

                  if    the_sprite_Data.Target /= null
                    and the_sprite_Data.is_Approaching
                  then
                     the_sprite_Data.target_Site := the_sprite_Data.Target.Site;
                  end if;

                  if the_sprite_Data.target_Site /= local.null_Site
                  then
                     declare
                        use gel.linear_Algebra,
                            gel.linear_Algebra_3D;

                        the_Delta : constant Vector_3 := the_sprite_Data.target_Site - Each.Site;

                     begin
                        if almost_Equals (the_Delta,
                                          [0.0, 0.0, 0.0],
                                          Tolerance => 0.1)
                        then     -- Has reached the targeted site.
                           the_sprite_Data.target_Site    := local.null_Site;
                           the_sprite_Data.is_Approaching := False;

                        else     -- Still moving towards the target site.
                           Each.Speed_is (  Each.Speed
                                            +   pace_Multiplier (the_sprite_Data.Pace)
                                            * Normalised (the_Delta)
                                            * 4.0);
                           declare
                              use gel.Geometry_2d;

                              Site  : constant gel.Geometry_2d.Site := [the_Delta (1),
                                                                        the_Delta (2)];
                              Angle : constant Real                 := to_Polar (Site).Angle;
                           begin
                              Each.Spin_is (to_Rotation (Axis  => [0.0, 0.0, 1.0],
                                                         Angle => Angle - to_Radians (90.0)));
                           end;
                        end if;
                     end;
                  end if;
               end;

            else
               null;
            end if;

         end loop;


         declare
            boo_Info :          local.sprite_Data renames local.sprite_Data (Boo.user_Data.all);
            Now      : constant ada.Calendar.TIme :=      ada.Calendar.Clock;
         begin
            if Now > next_Boo_move_Time
            then
               next_Boo_move_Time      := Now + 5.0;
               boo_Info.target_Site    := [gel.Math.Random.random_Real (-20.0, 20.0),
                                           gel.Math.Random.random_Real (-20.0, 20.0),
                                           gel.Math.Random.random_Real (-20.0, 20.0)];
               boo_Info.is_Approaching := True;
               boo_Info.Pace           := Run;
            end if;
         end;


         world_Lock.release;


         world_Lock.acquire;
         the_World .evolve;     -- Advance the world in time.
         world_Lock.release;


         -- Send chat messages
         --
         declare
            use lace.Text;

            Messages : chat.client_message_Pairs (1 .. 50);
            Count    : Natural;
         begin
            chat.chat_Messages.fetch (Messages,
                                      Count);
            for i in 1 .. Count
            loop
               for Each of fetch_all_Clients
               loop
                  Each.receive_Chat (Messages (i).Client.Name
                                     & " says '"
                                     & to_String (Messages (i).Message)
                                     & "'.");
               end loop;
            end loop;
         end;


         delay until next_evolve_Time;
         next_evolve_Time := next_evolve_Time + 1.0 / 60.0;
      end loop;
   end run;



   procedure close
   is
      all_Clients : constant Client.views := arcana.Server.fetch_all_Clients;
   begin
      for Each of all_Clients
      loop
         begin
            Each.Server_has_shutdown;
         exception
            when system.RPC.communication_Error =>
               null;   -- Client has died. No action needed since we are shutting down.
         end;
      end loop;

      Network.check_Client_lives.halt;
   end close;



   procedure ping is null;



   -----------
   --- Sundry.
   --

   procedure log (Message : in String := "")
                  renames ada.Text_IO.put_Line;



   --------------------------
   --- 'Last chance' handler.
   --

   procedure last_chance_Handler (Msg  : in system.Address;
                                  Line : in Integer);

   pragma Export (C, last_chance_Handler,
                  "__gnat_last_chance_handler");

   procedure last_chance_Handler (Msg  : in System.Address;
                                  Line : in Integer)
   is
      pragma Unreferenced (Msg, Line);
      use ada.Text_IO;
   begin
      put_Line ("Unable to start the Arcana server.");
      put_Line ("Please ensure the 'po_cos_naming' server is running.");
      put_Line ("Press Ctrl-C to quit.");

      delay Duration'Last;
   end last_chance_Handler;


end arcana.Server;
