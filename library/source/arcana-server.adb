with
     gel.World.server,
     gel.Sprite,
     gel.Forge,
     gel.Events,
     float_Math.Random,

     openGL.Palette,
     openGL.IO,

     Physics,

     lace.Observer,
     lace.Subject,
     lace.Response,
     lace.Event.utility,

     lace.Text.forge,

     system.RPC,

     ada.Exceptions,
     ada.Calendar,
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



   -----------
   --- Clients
   --

   --  protected new_Clients
   --  is
   --     procedure add (the_Client : in Client.view);
   --     function  fetch return Client.views;
   --     procedure clear;
   --
   --  private
   --     Clients : Client.views (1 .. 25);
   --     Count   : Natural := 0;
   --  end new_Clients;
   --
   --
   --  protected body new_Clients
   --  is
   --     procedure add (the_Client : in Client.view)
   --     is
   --     begin
   --        Count           := Count + 1;
   --        Clients (Count) := the_Client;
   --     end add;
   --
   --     function fetch return Client.views
   --     is
   --     begin
   --        return Clients (1 .. Count);
   --     end fetch;
   --
   --     procedure clear
   --     is
   --     begin
   --        Count := 0;
   --     end clear;
   --
   --  end new_Clients;
   --
   --
   --
   --  protected old_Clients
   --  is
   --     procedure add (the_Client : in Client.view);
   --     function  fetch return Client.views;
   --     procedure clear;
   --
   --  private
   --     Clients : Client.views (1 .. 25);
   --     Count   : Natural := 0;
   --  end old_Clients;
   --
   --
   --  protected body old_Clients
   --  is
   --     procedure add (the_Client : in Client.view)
   --     is
   --     begin
   --        Count           := Count + 1;
   --        Clients (Count) := the_Client;
   --     end add;
   --
   --
   --     function fetch return Client.views
   --     is
   --     begin
   --        return Clients (1 .. Count);
   --     end fetch;
   --
   --
   --     procedure clear
   --     is
   --     begin
   --        Count := 0;
   --     end clear;
   --
   --  end old_Clients;




   type client_Info is
      record
         Client       : arcana.Client.view;
         Name         : unbounded_String;
         as_Observer  : lace.Observer.view;
         as_Subject   : lace.Subject .view;
         pc_sprite_Id : gel.sprite_Id;
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
      function  Info (for_Client : in Client.view) return client_Info;

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
            if Clients (i).Client = null
            then
               Clients (i).Client       :=  the_Client;
               Clients (i).Name         := +the_Client.Name;
               Clients (i).as_Observer  :=  the_Client.as_Observer;
               Clients (i).as_Subject   :=  the_Client.as_Subject;
               Clients (i).pc_sprite_Id :=  the_Client.pc_sprite_Id;
               --  log ("JHJKJH " & Clients (i).pc_sprite_Id'Image);
               return;
            end if;
         end loop;
      end add;


      procedure rid (the_Client : in Client.view)
      is
      begin
         for i in Clients'Range
         loop
            if Clients (i).Client = the_Client then
               Clients (i).Client := null;
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
            if Clients (i).Client /= null
            then
               Count          := Count + 1;
               Result (Count) := Clients (i);
            end if;
         end loop;

         return Result (1 .. Count);
      end all_client_Info;


      function Info (for_Client : in Client.view) return client_Info
      is
      begin
         for i in Clients'Range
         loop
            if Clients (i).Client = for_Client
            then
               return Clients (i);
            end if;
         end loop;

         raise program_Error with "Unknown client.";
      end Info;


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
            when Forward  => the_sprite_Data.Movement := the_sprite_Data.Movement + [0.0,  4.0, 0.0];
            when Backward => the_sprite_Data.Movement := the_sprite_Data.Movement + [0.0, -4.0, 0.0];
            when Left     => the_sprite_Data.Spin     := the_sprite_Data.Spin     + 120.0;
            when Right    => the_sprite_Data.Spin     := the_sprite_Data.Spin     - 120.0;
         end case;
      else
         case the_Event.Direction
         is
            when Forward  => the_sprite_Data.Movement := the_sprite_Data.Movement + [ 0.0, -4.0, 0.0];
            when Backward => the_sprite_Data.Movement := the_sprite_Data.Movement + [ 0.0,  4.0, 0.0];
            when Left     => the_sprite_Data.Spin     := the_sprite_Data.Spin     - 120.0;
            when Right    => the_sprite_Data.Spin     := the_sprite_Data.Spin     + 120.0;
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

      --  new_Clients.add (the_Client);

      -- Create the Player.
      --
      declare
         --  the_Player : constant gel.Sprite.view := gel.Forge.new_rectangle_Sprite (in_World => the_World'Access,
         --                                                                           Site     => [-0.0, 0.0],
         --                                                                           Mass     => 1.0,
         --                                                                           Bounce   => 1.0,
         --                                                                           Friction => 1.0,
         --                                                                           Width    => 1.0,
         --                                                                           Height   => 1.0,
         --                                                                           Color    => openGL.Palette.Grey,
         --                                                                           Texture  => openGL.to_Asset ("assets/human.png"));
         the_Player : gel.Sprite.view := gel.Forge.new_circle_Sprite (in_World => the_World'Access,
                                                                               Site     => [0.0, 0.0, 0.0],
                                                                               Mass     => 1.0,
                                                                               Bounce   => 1.0,
                                                                               Friction => 1.0,
                                                                               Radius   => 0.5,
                                                                               Color    => Green,
                                                                               Texture  => openGL.to_Asset ("assets/human.png"));
      begin
         --  log ("arcana.Server.register ~ the_Player.Visual.Model.Id:" & the_Player.Visual.Model.Id'Image);

         world_Lock.acquire;
         the_Player := gel.Forge.new_circle_Sprite (in_World => the_World'Access,
                                                    Site     => [0.0, 0.0, 0.0],
                                                    Mass     => 1.0,
                                                    Bounce   => 1.0,
                                                    Friction => 1.0,
                                                    Radius   => 0.5,
                                                    Color    => Green,
                                                    Texture  => openGL.to_Asset ("assets/human.png"));
         the_Player.user_Data_is (new sprite_Data);
         the_World.add (the_Player);
         world_Lock.release;

         -- Emit a new 'add sprite' event for any interested observers.
         --
         declare
            the_Event : constant gel.events.new_sprite_Event
              := (Pair => (sprite_Id         => the_Player.Id,
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

      safe_Clients.add (the_Client);

      lace.Event.utility.connect (the_Observer  => the_World.local_Observer,
                                  to_Subject    => the_Client.as_Subject,
                                  with_Response => the_pc_move_Response'Access,
                                  to_Event_Kind => lace.Event.utility.to_Kind (pc_move_Event'Tag));
   end register;



   --  procedure register_new (Client : in arcana.Client.view)
   --  is
   --  begin
   --     -- Create the Player.
   --     --
   --     declare
   --        the_Player : constant gel.Sprite.view := gel.Forge.new_circle_Sprite (in_World => the_World'Access,
   --                                                                              Site     => [0.0, 0.0],
   --                                                                              Mass     => 1.0,
   --                                                                              Bounce   => 1.0,
   --                                                                              Friction => 1.0,
   --                                                                              Radius   => 0.5,
   --                                                                              Color    => Green,
   --                                                                              Texture  => openGL.to_Asset ("assets/human.png"));
   --     begin
   --        log ("arcana.Server.register_new ~ the_Player.Visual.Model.Id:" & the_Player.Visual.Model.Id'Image);
   --
   --        the_Player.user_Data_is (new sprite_Data);
   --        the_World.add (the_Player);
   --
   --        -- Emit a new 'add sprite' event for any interested observers.
   --        --
   --        declare
   --           the_Event : constant gel.events.new_sprite_Event
   --             := (Pair => (sprite_Id         => the_Player.Id,
   --                          graphics_model_Id => the_Player.Visual.Model.Id,
   --                          physics_model_Id  => the_Player.physics_Model.Id,
   --                          mass              => the_Player.Mass,
   --                          transform         => the_Player.Transform,
   --                          is_visible        => the_Player.is_Visible));
   --        begin
   --           the_World.emit (the_Event);
   --        end;
   --
   --        Client.pc_sprite_Id_is (the_Player.Id);
   --     end;
   --
   --     safe_Clients.add (Client);
   --
   --     lace.Event.utility.connect (the_Observer  => the_World.local_Observer,
   --                                 to_Subject    => Client.as_Subject,
   --                                 with_Response => the_pc_move_Response'Access,
   --                                 to_Event_Kind => lace.Event.utility.to_Kind (pc_move_Event'Tag));
   --  end register_new;



   -------------------------
   --- Client Deregistration
   --

   procedure deregister (the_Client : in Client.view)
   is
      client_Info : constant Server.client_Info := safe_Clients.Info (for_Client => the_Client);
   begin
      log ("Deregistering '" & to_String (client_Info.Name) & "'.");

      --  old_Clients.add (the_Client);

      -- Emit a new 'rid sprite' event for any interested observers.
      --
      declare
         the_Event : constant gel.events.rid_sprite_Event := (Id => client_Info.pc_sprite_Id);
      begin
         the_World.emit (the_Event);
      end;

      safe_Clients.rid     (the_Client);

      world_Lock.acquire;
      the_World .rid (the_World.fetch_Sprite (client_Info.pc_sprite_Id));
      world_Lock.release;

      lace.Event.utility.disconnect (the_Observer  => the_World.local_Observer,
                                     from_Subject  => client_Info.as_Subject,
                                     for_Response  => the_pc_move_Response'Access,
                                     to_Event_Kind => lace.Event.utility.to_Kind (pc_move_Event'Tag),
                                     subject_Name  => to_String (client_Info.Name));
   end deregister;



   --  procedure deregister_old (Client : in arcana.Client.view)
   --  is
   --     client_Info : constant Server.client_Info := safe_Clients.Info (for_Client => Client);
   --  begin
   --     log ("Deregistering old client '" & to_String (client_Info.Name) & "'.");
   --
   --     -- Emit a new 'rid sprite' event for any interested observers.
   --     --
   --     declare
   --        the_Event : constant gel.events.rid_sprite_Event := (Id => client_Info.pc_sprite_Id);
   --     begin
   --        the_World.emit (the_Event);
   --     end;
   --
   --     safe_Clients.rid     (Client);
   --     the_World   .rid     (the_World.fetch_Sprite (client_Info.pc_sprite_Id));
   --     --  the_World   .destroy (the_World.fetch_Sprite (the_Client.pc_sprite_Id));
   --
   --     lace.Event.utility.disconnect (the_Observer  => the_World.local_Observer,
   --                                    from_Subject  => client_Info.as_Subject,
   --                                    for_Response  => the_pc_move_Response'Access,
   --                                    to_Event_Kind => lace.Event.utility.to_Kind (pc_move_Event'Tag),
   --                                    subject_Name  => to_String (client_Info.Name));
   --  end deregister_old;




   function all_Clients return arcana.Client.views
   is
      all_Info : constant client_Info_array := safe_Clients.all_client_Info;
      Result   :          arcana.Client.views (all_Info'Range);
   begin
      for i in Result'Range
      loop
         Result (i) := all_Info (i).Client;
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

            --  Dead        : client_Info_array (all_Info'Range);
            --  dead_Count  : Natural := 0;

            function "+" (From : in unbounded_String) return String
                          renames to_String;
         begin
            for Each of all_Info
            loop
               begin
                  Each.Client.ping;
               exception
                  when system.RPC.communication_Error
                     | storage_Error =>
                     put_Line (+Each.Name & " has died.");
                     deregister (Each.Client);

                     --  dead_Count        := dead_Count + 1;
                     --  Dead (dead_Count) := Each;
               end;
            end loop;

            --  declare
            --     all_Clients : constant Client.views := arcana.Server.all_Clients;
            --  begin
            --     for Each of all_Clients
            --     loop
            --        for i in 1 .. dead_Count
            --        loop
            --           begin
            --              put_Line ("Ridding " & (+Dead (i).Name) & " from " & Each.Name);
            --              Each.deregister_Client ( Dead (i).as_Observer,
            --                                      +Dead (i).Name);
            --           exception
            --              when arcana.Client.unknown_Client =>
            --                 put_Line ("Deregister of " & (+Dead (i).Name) & " from " & Each.Name & " is not needed.");
            --           end;
            --        end loop;
            --     end loop;
            --  end;
         end;
      end loop;

   exception
      when E : others =>
         new_Line;
         put_Line ("Error in check_Client_lives task.");
         new_Line;
         put_Line (ada.Exceptions.exception_Information (E));
   end check_Client_lives;





   ------------------
   --- Chat messages.
   --

   type client_message_Pair is
      record
         Client  : arcana.Client.view;
         Message : lace.Text.item_256;
      end record;

   type client_message_Pairs is array (Positive range <>) of client_message_Pair;



   protected chat_Messages
   is
      procedure add   (From     : in Client.view;
                       Message  : in String);

      procedure fetch (the_Messages : out client_message_Pairs;
                       the_Count    : out Natural);

   private
      Messages : client_message_Pairs (1 .. 50);
      Count    : Natural := 0;
   end chat_Messages;


   protected body chat_Messages
   is
      procedure add   (From     : in Client.view;
                       Message  : in String)
      is
         use lace.Text.forge;
      begin
         Count := Count + 1;
         Messages (Count) := (Client => From,
                              Message => to_Text_256 (Message));
      end add;


      procedure fetch (the_Messages : out client_message_Pairs;
                       the_Count    : out Natural)
      is
      begin
         the_Messages (1 .. Count) := Messages (1 .. Count);
         the_Count                 := Count;
         Count                     := 0;
      end fetch;

   end chat_Messages;



   procedure add_Chat (From    : in Client.view;
                       Message : in String)
   is
   begin
      chat_Messages.add (From    => From,
                         Message => Message);
   end add_Chat;




   ---------
   --- Start
   --

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
      the_one_Tree := gel.Forge.new_circle_Sprite (in_World => the_World'Access,
                                                   Site     => [0.0, 0.0, 0.0],
                                                   Mass     => 0.0,
                                                   Bounce   => 1.0,
                                                   Friction => 0.0,
                                                   Radius   => 0.5,
                                                   Color    => Green,
                                                   Texture  => openGL.to_Asset ("assets/tree7.png"));
      log (the_one_Tree.Site'Image);

      the_World.add (the_one_Tree);

      --  log (openGL.IO.to_Image (openGL.to_Asset ("assets/terrain/trees.png"))'Length (1)'Image);

      declare
         use openGL,
             gel.Math.Random;

         the_Trees   : constant openGL.Image    := openGL.IO.to_Image (openGL.to_Asset ("assets/terrain/trees.png"));
         Count       :          Natural         := 0;
         half_Width  : constant gel.Math.Real   := gel.Math.Real (the_Trees'Length (1)) / 2.0;
         half_Height : constant gel.Math.Real   := gel.Math.Real (the_Trees'Length (2)) / 2.0;
         Color       :          openGL.rgb_Color;
      begin
         for Row in the_Trees'Range (1)
         loop
            for Col in the_Trees'Range (2)
            loop
               Color := the_Trees (Row, Col);

               if to_Color (Color) /= Black
               then
                  --  log ("Tree color:" & Color'Image);

                  the_one_Tree := gel.Forge.new_circle_Sprite (in_World => the_World'Access,
                                                               Site     => [gel.Math.Real (Col) - half_Width  + gel.Math.Random.random_Real (Lower => -0.25, Upper => 0.25),
                                                                            gel.Math.Real (Row) - half_Height + gel.Math.Random.random_Real (Lower => -0.25, Upper => 0.25),
                                                                            gel.Math.Random.random_Real (Lower => -0.01, Upper => 0.01)],     -- Prevent openGL from flipping visuals due to being all at same 'Z' position.
                                                               Mass     => 0.0,
                                                               Bounce   => 1.0,
                                                               Friction => 0.0,
                                                               Radius   => 0.5,
                                                               Color    => Green,
                                                               Texture  => openGL.to_Asset ("assets/tree7.png"));
                  the_World.add (the_one_Tree);

                  Count := Count + 1;
               end if;
            end loop;
         end loop;

         log ("Tree count:" & Count'Image);
      end;


      declare
         use ada.Calendar;

         next_evolve_Time   : ada.Calendar.Time := ada.Calendar.Clock;
         next_evolve_Report : ada.Calendar.Time := next_evolve_Time;
         evolve_Count       : Natural           := 0;

      begin
         --  while the_World.is_open
         loop
            --  -- Register new clients.
            --  --
            --  for Each of new_Clients.fetch
            --  loop
            --     register_new (Each);
            --  end loop;
            --
            --  new_Clients.clear;


            --  -- Deregister old clients.
            --  --
            --  for Each of old_Clients.fetch
            --  loop
            --     deregister_old (Each);
            --  end loop;
            --
            --  old_Clients.clear;

            evolve_Count := evolve_Count + 1;

            declare
               Now : constant ada.Calendar.TIme := ada.Calendar.Clock;
            begin
               if Now > next_evolve_Report
               then
                  log ("Server ~ Evolves per second:" & evolve_Count'Image);
                  next_evolve_Report := next_evolve_Report + 1.0;
                  evolve_Count             := 0;
               end if;
            end;


            world_Lock.acquire;

            for Each of the_World.all_Sprites.fetch
            loop
               if Each.user_Data /= null
               then
                  Each.Speed_is (  sprite_Data (Each.user_Data.all).Movement
                                 * Each.Spin);
                  --  Each.apply_Force (  sprite_Data (Each.user_Data.all).Movement
                  --                    * Each.Spin);
               end if;
            end loop;

            world_Lock.release;


            world_Lock.acquire;
            the_World .evolve;     -- Advance the world in time.
            world_Lock.release;


            -- Send chat messages
            --
            declare
               use lace.Text;

               Messages : client_message_Pairs (1 .. 50);
               Count    : Natural;
            begin
               chat_Messages.fetch (Messages,
                                    Count);
               for i in 1 .. Count
               loop
                  for Each of all_Clients
                  loop
                     Each.receive_Chat (Messages (i).Client.Name
                                        & " says '"
                                        & to_String (Messages (i).Message)
                                        & "'.");
                  end loop;
               end loop;
            end;

            delay until next_evolve_Time;
            next_evolve_Time := next_evolve_Time + 1.0 / (1.0 * 60.0);
         end loop;
      end;
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
