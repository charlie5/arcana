with
     gel.World.server,
     gel.Sprite,
     gel.Forge,
     gel.Events,

     openGL.Palette,
     Physics,

     lace.Observer,
     lace.Response,
     lace.Event.utility,

     system.RPC,

     ada.Exceptions,
     ada.Strings.unbounded,
     ada.Text_IO;


package body arcana.Server
is
   use gel.World.server,
       openGL.Palette,
       ada.Strings.unbounded;

   use type Client.view;


   -------------
   --- Debugging
   --
   procedure log (Message : in String := "")
                  renames ada.Text_IO.put_Line;



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





   type client_Info is
         record
            View        : Client.view;
            Name        : unbounded_String;
            as_Observer : lace.Observer.view;
         end record;

   type client_Info_array is array (Positive range <>) of client_Info;

   max_Clients : constant := 5_000;



   -- Protection against race conditions.
   --

   protected safe_Clients
   is
      procedure add (the_Client : in Client.view);
      procedure rid (the_Client : in Client.view);

      function  all_client_Info return client_Info_array;
   private
      Clients : client_Info_array (1 .. max_Clients);
   end safe_Clients;



   protected body safe_Clients
   is
      procedure add (the_Client : in Client.view)
      is
         function "+" (From : in String) return unbounded_String
           renames to_unbounded_String;
      begin
         for i in Clients'Range
         loop
            if Clients (i).View = null then
               Clients (i).View        :=  the_Client;
               Clients (i).Name        := +the_Client.Name;
               Clients (i).as_Observer :=  the_Client.as_Observer;
               return;
            end if;
         end loop;
      end add;


      procedure rid (the_Client : in Client.view)
      is
      begin
         for i in Clients'Range
         loop
            if Clients (i).View = the_Client then
               Clients (i).View := null;
               return;
            end if;
         end loop;

         raise Program_Error with "Unknown client.";
      end rid;


      function all_client_Info return client_Info_array
      is
         Count  : Natural := 0;
         Result : client_Info_array (1 .. max_Clients);
      begin
         for i in Clients'Range
         loop
            if Clients (i).View /= null
            then
               Count          := Count + 1;
               Result (Count) := Clients (i);
            end if;
         end loop;

         return Result (1 .. Count);
      end all_client_Info;

   end safe_Clients;



   ---------------
   --- Sprite Data
   --

   type sprite_Data is new gel.Sprite.any_user_Data with
      record
         Movement : gel.Math.Vector_3 := [0.0, 0.0, 0.0];
         Spin     : gel.Math.Degrees  :=  0.0;
      end record;


   --------------------
   --- pc_move_Response
   --

   type pc_move_Response is new lace.Response.item with
      record
         null;
      end record;


   overriding
   procedure respond (Self : in out pc_move_Response;   to_Event : in lace.Event.item'Class)
   is
      use gel.Math;

      the_Event       : constant pc_move_Event           := pc_move_Event          (to_Event);
      the_Sprite      :          gel.Sprite.view    renames the_World.fetch_Sprite (the_Event.sprite_Id);
      the_sprite_Data :          server.sprite_Data renames server.sprite_Data     (the_Sprite.user_Data.all);

   begin
      if the_Event.On
      then
         case the_Event.Direction
         is
            when Forward  => the_sprite_Data.Movement := the_sprite_Data.Movement + [0.0,  0.1, 0.0];
            when Backward => the_sprite_Data.Movement := the_sprite_Data.Movement + [0.0, -0.1, 0.0];
            when Left     => the_sprite_Data.Spin     := the_sprite_Data.Spin     + 5.0;
            when Right    => the_sprite_Data.Spin     := the_sprite_Data.Spin     - 5.0;
         end case;
      else
         case the_Event.Direction
         is
            when Forward  => the_sprite_Data.Movement := the_sprite_Data.Movement + [ 0.0, -0.1, 0.0];
            when Backward => the_sprite_Data.Movement := the_sprite_Data.Movement + [ 0.0,  0.1, 0.0];
            when Left     => the_sprite_Data.Spin     := the_sprite_Data.Spin     - 5.0;
            when Right    => the_sprite_Data.Spin     := the_sprite_Data.Spin     + 5.0;
         end case;
      end if;

      the_Sprite.Gyre_is ([0.0,
                           0.0,
                           to_Radians (the_sprite_Data.Spin)]);
   end respond;


   the_pc_move_Response : aliased pc_move_Response;




   -----------------------
   --- Client Registration
   --

   procedure register (the_Client : in Client.view)
   is
      Name     : constant String            := the_Client.Name;
      all_Info : constant client_Info_array := safe_Clients.all_client_Info;
   begin
      log ("Registering '" & Name & "'.");


      for Each of all_Info
      loop
         if Each.Name = Name
         then
            raise Name_already_used;
         end if;
      end loop;

      safe_Clients.add (the_Client);


      -- Create the Player.
      --
      declare
         the_Player : constant gel.Sprite.view := gel.Forge.new_rectangle_Sprite (in_World => the_World'Access,
                                                                         Site     => [-0.0, 0.0],
                                                                         Mass     => 1.0,
                                                                         Bounce   => 1.0,
                                                                         Friction => 1.0,
                                                                         Width    => 1.0,
                                                                         Height   => 1.0,
                                                                         Color    => openGL.Palette.Grey,
                                                                         Texture  => openGL.to_Asset ("assets/human.png"));
      begin
         log ("arcana.Server.register ~ the_Player.Visual.Model.Id:" & the_Player.Visual.Model.Id'Image);

         the_Player.user_Data_is (new sprite_Data);
         the_World.add (the_Player);

         -- Emit a new sprite added event for any interested observers.
         --
         declare
            the_Event : constant gel.events.my_new_sprite_added_to_world_Event
              := (Pair => (sprite_id         => the_Player.Id,
                           graphics_model_Id => the_Player.Visual.Model.Id,
                           physics_model_id  => the_Player.physics_Model.Id,
                           mass              => the_Player.Mass,
                           transform         => the_Player.Transform,
                           is_visible        => the_Player.is_Visible));
         begin
            the_World.emit (the_Event);
         end;

         the_Client.pc_sprite_Id_is (the_Player.Id);
      end;


      lace.Event.utility.connect (the_Observer  => the_World.local_Observer,
                                  to_Subject    => the_Client.as_Subject,
                                  with_Response => the_pc_move_Response'Access,
                                  to_Event_Kind => lace.Event.utility.to_Kind (pc_move_Event'Tag));
   end register;



   procedure deregister (the_Client : in Client.view)
   is
   begin
      safe_Clients.rid (the_Client);
   end deregister;



   function all_Clients return arcana.Client.views
   is
      all_Info : constant client_Info_array := safe_Clients.all_client_Info;
      Result   :          arcana.Client.views (all_Info'Range);
   begin
      for i in Result'Range
      loop
         Result (i) := all_Info (i).View;
      end loop;

      return Result;
   end all_Clients;



   task check_Client_lives
   is
      entry halt;
   end check_Client_lives;

   task body check_Client_lives
   is
      use ada.Text_IO;
      Done : Boolean := False;
   begin
      loop
         select
            accept halt
            do
               Done := True;
            end halt;
         or
            delay 15.0;
         end select;

         exit when Done;

         declare
            all_Info    : constant client_Info_array := safe_Clients.all_client_Info;

            Dead        : client_Info_array (all_Info'Range);
            dead_Count  : Natural := 0;

            function "+" (From : in unbounded_String) return String
                          renames to_String;
         begin
            for Each of all_Info
            loop
               begin
                  Each.View.ping;
               exception
                  when system.RPC.communication_Error
                     | storage_Error =>
                     put_Line (+Each.Name & " has died.");
                     deregister (Each.View);

                     dead_Count        := dead_Count + 1;
                     Dead (dead_Count) := Each;
               end;
            end loop;

            declare
               all_Clients : constant Client.views := arcana.Server.all_Clients;
            begin
               for Each of all_Clients
               loop
                  for i in 1 .. dead_Count
                  loop
                     begin
                        put_Line ("Ridding " & (+Dead (i).Name) & " from " & Each.Name);
                        Each.deregister_Client ( Dead (i).as_Observer,
                                                +Dead (i).Name);
                     exception
                        when arcana.Client.unknown_Client =>
                           put_Line ("Deregister of " & (+Dead (i).Name) & " from " & Each.Name & " is not needed.");
                     end;
                  end loop;
               end loop;
            end;
         end;
      end loop;

   exception
      when E : others =>
         new_Line;
         put_Line ("Error in check_Client_lives task.");
         new_Line;
         put_Line (ada.Exceptions.exception_Information (E));
   end check_Client_lives;



   the_one_Tree : gel.Sprite.view;



   procedure start
   is
      use gel.Math,
          ada.Text_IO;

      use type gel.Sprite.any_user_Data_view;

   begin
      Put_Line ("Server world " & the_World'address'Image);
      the_World.Gravity_is ([0.0, 0.0, 0.0]);

      -- The One Tree.
      --
      the_one_Tree := gel.Forge.new_rectangle_Sprite (in_World => the_World'Access,
                                                      Site     => [0.0, 0.0],
                                                      Mass     => 0.0,
                                                      Bounce   => 1.0,
                                                      Friction => 1.0,
                                                      Width    => 1.0,
                                                      Height   => 1.0,
                                                      Color    => Green,
                                                      Texture  => openGL.to_Asset ("assets/tree7.png"));
      the_World.add (the_one_Tree);

      --  while the_World.is_open
      loop
         for Each of the_World.all_Sprites.fetch
         loop
            if Each.user_Data /= null
            then
               Each.Speed_is (  sprite_Data (Each.user_Data.all).Movement
                              * Each.Spin);
            end if;
         end loop;

         the_World.evolve;     -- Advance the world in time.
      end loop;
   end start;



   procedure shutdown
   is
      all_Clients : constant Client.views := arcana.Server.all_Clients;
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

      check_Client_lives.halt;
   end shutdown;



   procedure ping is null;




   ------------------------
   --- Last chance handler.
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
