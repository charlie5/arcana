with
     arcana.Client.local.Events,
     arcana.Client.local.UI,
     arcana.Client.Network,
     arcana.Client.Chat,
     arcana.Server,

     lace.Observer,
     lace.Event.utility,
     lace.Text,

     gel.Forge,
     gel.Window.setup,
     gel.Window.gtk,
     gel.remote.World,

     Physics,

     openGL.Light,
     openGL.Palette,

     system.RPC,

     ada.Calendar,
     ada.Exceptions;

pragma Unreferenced (gel.Window.setup);


package body arcana.Client.local
is

   procedure occlude_hidden_dynamic_Sprites (Self : in out Item);


   --------
   -- Forge
   --

   function to_Client (Name : in String) return Item
   is
      use openGL;
      use type gel.Math.Vector_3;

   begin
      return Self : Item
      do
         --- Setup GtkAda.
         --

         UI.setup_Gtk (Self);

         --  Create a window.
         --
         Self.Name   := to_unbounded_String (Name);
         Self.Applet := gel.Forge.new_client_Applet (Named         => "Arcana",
                                                     window_Width  => 1920,
                                                     window_Height => 1080,
                                                     space_Kind    => physics.Box2d);

         --  Add our openGL area into the GTK windows open_GL box.
         --
         Self.gl_Box.pack_Start (gel.Window.gtk.view (Self.Applet.Window).GL_Area);

         --  Display our main window and all of it's children.
         --
         Self.top_Window.show_All;

         -- Connect GEL events.
         --
         Events.setup (Self);

         -- Set up the camera.
         --
         Self.Applet.Camera.Site_is ([0.0, 0.0, 30.0]);

         -- Set the lights position.
         --
         declare
            Light : openGL.Light.item := Self.Applet.Renderer.new_Light;
         begin
            Light.Site_is                ([0.0, -1000.0, 0.0]);
            Light.ambient_Coefficient_is (0.5);

            Self.Applet.Renderer.set (Light);
         end;

         -- Reserve Ids for use by the server world.
         --
         Self.client_World.reserve_Ids (Before => 50_000_000);

         -- Create our target selection marker.
         --
         Self.target_Marker := gel.Forge.new_circle_Sprite (in_World    => Self.Applet.client_World.all'Access,
                                                            Name        => "target Marker",
                                                            Site        => gel.math.Origin_3D + [0.0, 0.0, target_marker_Height],
                                                            Mass        => 0.0,
                                                            is_Tangible => False,
                                                            Radius      => 0.666,
                                                            Color       => (Palette.White, Opacity => 0.666),
                                                            Sides       => 6,
                                                            Fill        => False);
         Self.Applet.client_World.add (Self.target_Marker);

         --- Set the 'my_Client' convenience access for subprogams (ie event responses).
         --
         my_Client := Self'unchecked_Access;
      end return;
   end to_Client;



   -------------
   -- Attributes
   --

   overriding
   function Name (Self : in Item) return String
   is
   begin
      return to_String (Self.Name);
   end Name;



   overriding
   function as_Observer (Self : access Item) return lace.Observer.view
   is
   begin
      return Self;
   end as_Observer;



   overriding
   function as_Subject (Self : access Item) return lace.Subject.view
   is
   begin
      return Self;
   end as_Subject;



   overriding
   procedure pc_sprite_Id_is (Self : in out Item;   Now : in gel.sprite_Id)
   is
   begin
      Self.pc_sprite_Id := Now;
   end pc_sprite_Id_is;



   overriding
   function pc_sprite_Id (Self : in Item) return gel.sprite_Id
   is
   begin
      return Self.pc_sprite_Id;
   end pc_sprite_Id;



   -------------
   -- Operations
   --

   procedure Server_is_dead (Self : in out Item)
   is
   begin
      Self.Server_is_dead := True;
   end Server_is_dead;



   overriding
   procedure Server_has_shutdown (Self : in out Item)
   is
      use ada.Text_IO;
   begin
      put_Line ("The Server has shutdown. Press <Enter> to exit.");

      Self.Server_has_shutdown := True;
   end Server_has_shutdown;



   function client_World (Self : in Item) return gel.World.client.view
   is
   begin
      return gel.World.client.view (Self.Applet.World (1));
   end client_World;



   overriding
   procedure receive_Chat (Self : in Item;   Message : in String)
   is
   begin
      Chat.chat_Messages.add (Message);
   end receive_Chat;




   --------
   --- Open
   --

   procedure open  (Self : in out arcana.Client.local.item)
   is
      use gel.Applet.client_world;

   begin
      log ("Registering client with server.");

      begin
         arcana.Server.register (Self'unchecked_Access);   -- Register our client with the server.
      exception
         when arcana.Server.Name_already_used =>
            log (+Self.Name & " is already in use.");
            Network.check_Server_lives.halt;
            free (Self.Applet);

         when E : others =>
            log ("Unahndled exception in client:");
            log (ada.Exceptions.exception_Information (E));
            return;
      end;

      lace.Event.utility.use_text_Logger ("events");

      Network.check_Server_lives.start (Self'unchecked_Access);

      Self.Applet.client_World.Gravity_is  ([0.0, 0.0, 0.0]);
      Self.Applet.client_World.is_a_Mirror (of_World      => arcana.Server.World);
      Self.Applet.enable_Mouse             (detect_Motion => False);
   end open;




   -------
   --- Run
   --

   procedure run (Self : in out arcana.Client.local.item)
   is
      use gel.Applet.client_world,
          gel.Math,
          ada.Calendar;

      use type gel.Sprite.view,
               gel.sprite_Id;

      next_evolve_Time   : ada.Calendar.Time := ada.Calendar.Clock;
      next_evolve_Report : ada.Calendar.Time := next_evolve_Time;
      evolve_Count       : Natural           := 0;

   begin
      while Self.Applet.is_open
      loop
         --- Report evolve rate.
         --
         evolve_Count := evolve_Count + 1;

         declare
            Now : constant ada.Calendar.TIme := ada.Calendar.Clock;
         begin
            if Now > next_evolve_Report
            then
               log ("                                               Client ~ Evolves per second:" & evolve_Count'Image);
               next_evolve_Report := next_evolve_Report + 1.0;
               evolve_Count       := 0;
            end if;
         end;


         if Self.pc_Sprite /= null
         then
            if evolve_Count mod 4 = 0        -- Only need to do occlusion check a few times per second.
            then
               Self.occlude_hidden_dynamic_Sprites;
            end if;

            Self.Applet.Camera.Site_is (  Self.pc_Sprite.Site                           -- Move the camera to follow the players sprite.
                                        + [0.0, 0.0, Self.Applet.Camera.Site (3)]);
         end if;


         --- Evolve the world, handle new events and update the screen.
         --
         Self.Applet.freshen;


         --- Setup our PC sprite.
         --
         if    Self.pc_Sprite     = null
           and Self.pc_sprite_Id /= gel.null_sprite_Id
         then
            Self.pc_Sprite := Self.client_World.fetch_Sprite (Self.pc_sprite_Id);
            Self.pc_Sprite.is_Visible   (True);
            Self.pc_Sprite.user_Data_is (new sprite_Info);
         end if;


         --- Move the target marker to follow the targeted sprite.
         --
         if Self.Target /= null
         then
            Self.target_Marker.Site_is (Self.Target.Site + [0.0, 0.0, target_marker_Height]);
         end if;


         --- Display any new chat messages.
         --
         declare
            use lace.Text;

            Messages : lace.Text.items_256 (1 .. 50);
            Count    : Natural;
         begin
            Chat.chat_Messages.fetch (Messages, Count);

            for i in 1 .. Count
            loop
               UI.add_chat_Line (Self, +Messages (i));
            end loop;
         end;


         --- Loop exit.
         --
         exit when Self.Server_has_shutdown
           or      Self.Server_is_dead
           or not  Self.Applet.is_open;


         --- Delay until next evolve time.
         --
         delay until next_evolve_Time;
         next_evolve_Time := next_evolve_Time + 1.0 / 60.0;
      end loop;


      --- Shutdown
      --
      arcana.Server.World.deregister (Self.Applet.client_World.all'Access);

      if    not Self.Server_has_shutdown
        and not Self.Server_is_dead
      then
         begin
            arcana.Server.deregister (Self'unchecked_Access);
         exception
            when system.RPC.communication_Error =>
               Self.Server_is_dead := True;
         end;
      end if;

      Network.check_Server_lives.halt;
      free (Self.Applet);
      lace.Event.utility.close;

   exception
      when others =>
         Network.check_Server_lives.halt;
         free (Self.Applet);
         lace.Event.utility.close;

         raise;
   end run;




   procedure occlude_hidden_dynamic_Sprites (Self : in out Item)
   is
      use type gel.Sprite.view;

   begin
      for Angle in 0 .. 359
      loop
         declare
            use gel.World,
                gel.Geometry_2D,
                gel.Math;

            the_Angle : constant Radians       := to_Radians (Degrees (Angle));
            ray_End   : constant Vector_2      := to_Site    ((Angle  => the_Angle,
                                                               Extent => 50.0));

            Collision : constant ray_Collision := Self.client_World.cast_Ray (From => Self.pc_Sprite.Site,
                                                                              To   => Vector_3 (ray_End & 0.0));
         begin
            if Collision.near_Sprite /= null
            then
               declare
                  the_Sprite      : gel.Sprite.view renames Collision.near_Sprite;
                  the_sprite_Info : sprite_Info     renames sprite_Info (the_Sprite.user_Data.all);
               begin
                  if the_Sprite.is_Static
                  then
                     the_sprite_Info.occlude_Countdown := 60;
                  else
                     the_sprite_Info.occlude_Countdown :=  6;
                  end if;
               end;
            end if;

         end;
      end loop;


      for Each of my_Client.client_World.all_Sprites.fetch
      loop
         if    Each /= my_Client.pc_Sprite
           and Each /= my_Client.target_Marker
         then
            declare
               use openGL.texture_Set;

               the_Sprite      : gel.Sprite.view renames Each;
               the_sprite_Info : sprite_Info     renames sprite_Info (the_Sprite.user_Data.all);
            begin
               if the_sprite_Info.occlude_Countdown > 0
               then
                  Each.is_Visible (Now => True);
                  the_sprite_Info.fade_Level := 0.0;
               else
                  the_sprite_Info.fade_Level := fade_Level'Min (the_sprite_Info.fade_Level + 0.1,
                                                                1.0);
                  if the_sprite_Info.fade_Level >= 0.99
                  then
                     Each.is_Visible (Now => False);
                  end if;
               end if;

               the_Sprite.Visual.Model.Fade_is (Which => 1,
                                                Now   => the_sprite_Info.fade_Level);
               if not the_Sprite.is_Static
               then
                  the_sprite_Info.occlude_Countdown := the_sprite_Info.occlude_Countdown - 1;
               end if;
            end;
         end if;
      end loop;

   end occlude_hidden_dynamic_Sprites;



   -- 'last_chance_Handler' is commented out to avoid multiple definitions
   --  of link symbols in 'build_All' test procedure (Lace Tier 5).
   --

   --  procedure last_chance_Handler (Msg  : in system.Address;
   --                                 Line : in Integer);
   --
   --  pragma Export (C, last_chance_Handler,
   --                 "__gnat_last_chance_handler");
   --
   --  procedure last_chance_Handler (Msg  : in System.Address;
   --                                 Line : in Integer)
   --  is
   --     pragma Unreferenced (Msg, Line);
   --     use ada.Text_IO;
   --  begin
   --     put_Line ("The Server is not running.");
   --     put_Line ("Press Ctrl-C to quit.");
   --     check_Server_lives.halt;
   --     delay Duration'Last;
   --  end last_chance_Handler;


end arcana.Client.local;
