with
     arcana.Server,

     lace.Observer,
     lace.Event.utility,

     gel.Forge,
     gel.Window.setup,
     gel.Window.gtk,
     gel.Keyboard,
     gel.World.client,

     Physics,

     openGL.Palette,
     openGL.Light,

     gtk.Main,

     system.RPC,
     --  ada.Tags,
     ada.Exceptions,
     ada.Text_IO;

pragma Unreferenced (gel.Window.setup);


package body arcana.Client.local
is
   ----------
   -- Utility
   --

   function "+" (From : in unbounded_String) return String
                 renames to_String;


   procedure log (Message : in String := "")
                  renames ada.Text_IO.put_Line;


   --------------
   --- Gel Events
   --

   type Show is new lace.Response.item with null record;

   -- Response is to display the arcana message on the users console.
   --
   overriding
   procedure respond (Self : in out Show;   to_Event : in lace.Event.item'Class)
   is
      pragma Unreferenced (Self);
      use ada.Text_IO;

      the_Message : constant Message := Message (to_Event);
   begin
      put_Line (the_Message.Text (1 .. the_Message.Length));
   end respond;

   the_Response : aliased arcana.Client.local.show;




   --- Guards against key repeats.
   --
      up_Key_is_already_pressed,
    down_Key_is_already_pressed,
    left_Key_is_already_pressed,
   right_Key_is_already_pressed : Boolean := False;


   overriding
   procedure respond (Self : in out key_press_Response;   to_Event : in lace.Event.item'Class)
   is
      use arcana.Server,
          gel.Keyboard;

      the_Event :          gel.Keyboard.key_press_Event renames gel.Keyboard.key_press_Event (to_Event);
      the_Key   : constant gel.keyboard.Key                  := the_Event.modified_Key.Key;
   begin
      -- Guard against key repeats.
      --
      if   (   up_Key_is_already_pressed and the_Key = Up)
        or ( down_Key_is_already_pressed and the_Key = Down)
        or ( left_Key_is_already_pressed and the_Key = Left)
        or (right_Key_is_already_pressed and the_Key = Right)
      then
         return;
      end if;

      case the_Key
      is
         when Up     => Self.my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => Self.my_Client.pc_sprite_Id,  Direction => Forward,   On => True));
         when Down   => Self.my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => Self.my_Client.pc_sprite_Id,  Direction => Backward,  On => True));
         when Right  => Self.my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => Self.my_Client.pc_sprite_Id,  Direction => Right,     On => True));
         when Left   => Self.my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => Self.my_Client.pc_sprite_Id,  Direction => Left,      On => True));
         when others => null;
      end case;

      case the_Key
      is
         when Up     =>    up_Key_is_already_pressed := True;
         when Down   =>  down_Key_is_already_pressed := True;
         when Right  => right_Key_is_already_pressed := True;
         when Left   =>  left_Key_is_already_pressed := True;
         when others => null;
      end case;

   end respond;



   overriding
   procedure respond (Self : in out key_release_Response;   to_Event : in lace.Event.item'Class)
   is
      use arcana.Server,
          gel.Keyboard;

      the_Event :          gel.Keyboard.key_release_Event renames gel.Keyboard.key_release_Event (to_Event);
      the_Key   : constant gel.keyboard.Key                    := the_Event.modified_Key.Key;
   begin
      case the_Key
      is
         when Up     => Self.my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => Self.my_Client.pc_sprite_Id,  Direction => Forward,   On => False));
         when Down   => Self.my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => Self.my_Client.pc_sprite_Id,  Direction => Backward,  On => False));
         when Right  => Self.my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => Self.my_Client.pc_sprite_Id,  Direction => Right,     On => False));
         when Left   => Self.my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => Self.my_Client.pc_sprite_Id,  Direction => Left,      On => False));
         when others => null;
      end case;

      case the_Key
      is
         when Up     =>    up_Key_is_already_pressed := False;
         when Down   =>  down_Key_is_already_pressed := False;
         when Right  => right_Key_is_already_pressed := False;
         when Left   =>  left_Key_is_already_pressed := False;
         when others => null;
      end case;
   end respond;



   --  overriding
   --  procedure respond (Self : in out key_press_Response;   to_Event : in lace.Event.item'Class)
   --  is
   --     use arcana.Server,
   --         gel.Keyboard;
   --
   --     the_Event :          gel.Keyboard.key_press_Event renames gel.Keyboard.key_press_Event (to_Event);
   --     the_Key   : constant gel.keyboard.Key                  := the_Event.modified_Key.Key;
   --  begin
   --     -- Guard against key repeats.
   --     --
   --     if   (   up_Key_is_already_pressed and the_Key = w)
   --       or ( down_Key_is_already_pressed and the_Key = s)
   --       or ( left_Key_is_already_pressed and the_Key = a)
   --       or (right_Key_is_already_pressed and the_Key = d)
   --     then
   --        return;
   --     end if;
   --
   --     case the_Key
   --     is
   --        when w  => Self.my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => Self.my_Client.pc_sprite_Id,  Direction => Forward,   On => True));
   --        when s  => Self.my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => Self.my_Client.pc_sprite_Id,  Direction => Backward,  On => True));
   --        when a  => Self.my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => Self.my_Client.pc_sprite_Id,  Direction => Left,      On => True));
   --        when d  => Self.my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => Self.my_Client.pc_sprite_Id,  Direction => Right,     On => True));
   --        when others => null;
   --     end case;
   --
   --     case the_Key
   --     is
   --        when w  =>    up_Key_is_already_pressed := True;
   --        when s  =>  down_Key_is_already_pressed := True;
   --        when a  =>  left_Key_is_already_pressed := True;
   --        when d  => right_Key_is_already_pressed := True;
   --        when others => null;
   --     end case;
   --
   --  end respond;
   --
   --
   --
   --  overriding
   --  procedure respond (Self : in out key_release_Response;   to_Event : in lace.Event.item'Class)
   --  is
   --     use arcana.Server,
   --         gel.Keyboard;
   --
   --     the_Event :          gel.Keyboard.key_release_Event renames gel.Keyboard.key_release_Event (to_Event);
   --     the_Key   : constant gel.keyboard.Key                    := the_Event.modified_Key.Key;
   --  begin
   --     case the_Key
   --     is
   --        when w  => Self.my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => Self.my_Client.pc_sprite_Id,  Direction => Forward,   On => False));
   --        when s  => Self.my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => Self.my_Client.pc_sprite_Id,  Direction => Backward,  On => False));
   --        when a  => Self.my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => Self.my_Client.pc_sprite_Id,  Direction => Left,      On => False));
   --        when d  => Self.my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => Self.my_Client.pc_sprite_Id,  Direction => Right,     On => False));
   --        when others => null;
   --     end case;
   --
   --     case the_Key
   --     is
   --        when w  =>    up_Key_is_already_pressed := False;
   --        when s  =>  down_Key_is_already_pressed := False;
   --        when a  =>  left_Key_is_already_pressed := False;
   --        when d  => right_Key_is_already_pressed := False;
   --        when others => null;
   --     end case;
   --  end respond;
   --




   --------
   -- Forge
   --

   function to_Client (Name : in String) return Item
   is
      use openGL.Palette,
          lace.Event.utility;
   begin
      gtk.Main.init;     -- Initialize GtkAda.


      return Self : Item
      do
         --- Setup GtkAda.
         --

         --  Create a window with a size of 800 x 650.
         --
         gtk_new (Self.top_Window);
         Self.top_Window.set_default_Size (1920, 1080);

         --  Create a box to organize vertically the contents of the window.
         --
         gtk_New_vBox        (Self.Box);
         Self.top_Window.add (Self.Box);

         --  Add a label.
         --
         gtk_new             (Self.Label, "Hello Arcana.");
         Self.Box.pack_Start (Self.Label,
                              Expand  => False,
                              Fill    => False,
                              Padding => 10);

         Self.Name   := to_unbounded_String (Name);
         Self.Applet := gel.Forge.new_client_Applet (Named         => "Arcana",
                                                     window_Width  => 1920,
                                                     window_Height => 1080,
                                                     space_Kind    => physics.Box2d);

         Self.Box.pack_Start (gel.Window.gtk.view (Self.Applet.Window).GL_Area);

         --  Show the window.
         --
         Self.top_Window.show_All;


         -- Connect events.
         --
         connect ( Self.Applet.local_Observer,
                   Self.Applet.Keyboard,
                   Self.my_key_press_Response'unchecked_Access,
                  +gel.Keyboard.key_press_Event'Tag);

         connect ( Self.Applet.local_Observer,
                   Self.Applet.Keyboard,
                   Self.my_key_release_Response'unchecked_Access,
                  +gel.Keyboard.key_release_Event'Tag);


         --  -- Ball
         --  --
         --  Self.Player := gel.Forge.new_circle_Sprite (in_World => Self.Applet.World,
         --                                              Site     => [0.0, 0.0],
         --                                              Mass     => 1.0,
         --                                              Bounce   => 1.0,
         --                                              Friction => 0.0,
         --                                              Radius   => 0.5,
         --                                              Color    => Grey,
         --                                              Texture  => openGL.to_Asset ("assets/opengl/texture/Face1.bmp"));

         Self.Applet.Camera.Site_is ([0.0, 0.0, 20.0]);

         --  Self.Applet.enable_simple_Dolly (in_World => 1);
         --  Self.Applet.World.Gravity_is ([0.0, 0.0,  0.0]);
         --  Self.Applet.World.add        (Self.Player);


         -- Set the lights position.
         --
         declare
            Light : openGL.Light.item := Self.Applet.Renderer.new_Light;
         begin
            Light.Site_is                ([0.0, -1000.0, 0.0]);
            Light.ambient_Coefficient_is (0.5);

            Self.Applet.Renderer.set (Light);
         end;
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



   function pc_sprite_Id (Self : in Item) return gel.sprite_Id
   is
   begin
      return Self.pc_sprite_Id;
   end pc_sprite_Id;



   -------------
   -- Operations
   --

   overriding
   procedure register_Client (Self : in out Item;   other_Client : in Client.view)
   is
      use lace.Event.utility,
          ada.Text_IO;
   begin
      lace.Event.utility.connect (the_Observer  => Self'unchecked_Access,
                                  to_Subject    => other_Client.as_Subject,
                                  with_Response => the_Response'Access,
                                  to_Event_Kind => to_Kind (arcana.Client.Message'Tag));

      put_Line (other_Client.Name & " is here.");
   end register_Client;



   overriding
   procedure deregister_Client (Self : in out Item;   other_Client_as_Observer : in lace.Observer.view;
                                                      other_Client_Name        : in String)
   is
      use lace.Event.utility,
          ada.Text_IO;
   begin
      begin
         Self.as_Subject.deregister (other_Client_as_Observer,
                                     to_Kind (arcana.Client.Message'Tag));
      exception
         when constraint_Error =>
            raise unknown_Client with "Other client not known. Deregister is not required.";
      end;

      Self.as_Observer.rid (the_Response'unchecked_Access,
                            to_Kind (arcana.Client.Message'Tag),
                            other_Client_Name);

      put_Line (other_Client_Name & " leaves.");
   end deregister_Client;



   overriding
   procedure Server_has_shutdown (Self : in out Item)
   is
      use ada.Text_IO;
   begin
      put_Line ("The Server has shutdown. Press <Enter> to exit.");

      Self.Server_has_shutdown := True;
   end Server_has_shutdown;



   task check_Server_lives
   is
      entry start (Self : in arcana.Client.local.view);
      entry halt;
   end check_Server_lives;


   task body check_Server_lives
   is
      use ada.Text_IO;
      Done : Boolean := False;
      Self : arcana.Client.local.view;
   begin
      loop
         select
            accept start (Self : in arcana.Client.local.view)
            do
               check_Server_lives.Self := Self;
            end start;
         or
            accept halt
            do
               Done := True;
            end halt;
         or
            delay 15.0;
         end select;

         exit when Done;

         begin
            arcana.Server.ping;
         exception
            when system.RPC.communication_Error =>
               put_Line ("The Server has died. Press <Enter> to exit.");
               Self.Server_is_dead := True;
         end;
      end loop;

   exception
      when E : others =>
         new_Line;
         put_Line ("Error in check_Server_lives task.");
         new_Line;
         put_Line (ada.exceptions.exception_Information (E));
   end check_Server_lives;



   function client_World (Self : in Item) return gel.World.client.view
   is
   begin
      return gel.World.client.view (Self.Applet.World (1));
   end client_World;



   procedure start (Self : in out arcana.Client.local.item)
   is
      use gel.Applet.client_world,
          gel.Math,
          ada.Text_IO;

      use type gel.Sprite.view,
               gel.sprite_Id;
   begin
      log ("Registering client with server.");

      --------
      -- Setup
      --
      begin
         arcana.Server.register (Self'unchecked_Access);   -- Register our client with the server.
      exception
         when arcana.Server.Name_already_used =>
            put_Line (+Self.Name & " is already in use.");
            check_Server_lives.halt;
            return;
      end;

      lace.Event.utility.use_text_Logger ("events");

      check_Server_lives.start (Self'unchecked_Access);

      declare
         Peers : constant arcana.Client.views := arcana.Server.all_Clients;
      begin
         for i in Peers'Range
         loop
            if Self'unchecked_Access /= Peers (i)
            then
               begin
                  Peers (i).register_Client (Self'unchecked_Access);    -- Register our client with all other clients.
                  Self     .register_Client (Peers (i));                -- Register all other clients with our client.
               exception
                  when system.RPC.communication_Error
                     | storage_Error =>
                     null;     -- Peer (i) has died, so ignore it and do nothing.
               end;
            end if;
         end loop;
      end;

      Put_Line ("Client world " & Self.Applet.client_World'address'Image);

      Self.Applet.client_World.is_a_Mirror (of_World => arcana.Server.World);


      ------------
      -- Main Loop
      --
      while Self.Applet.is_open
      loop
         --  put_Line ("MMM");
         Self.Applet.World.evolve;     -- Advance the world.
         Self.Applet.freshen;          -- Handle any new events and update the screen.


         if    Self.pc_Sprite     = null
           and Self.pc_sprite_Id /= gel.null_sprite_Id
         then
            Self.pc_Sprite := Self.client_World.fetch_Sprite (Self.pc_sprite_Id);
            --  Self.Applet.enable_following_Dolly (follow => Self.pc_Sprite);
         end if;


         if Self.pc_Sprite /= null
         then
            Self.Applet.Camera.Site_is (Self.pc_Sprite.Site + (0.0, 0.0, 30.0));
            --  Self.Applet.Camera.Site_is (Self.pc_Sprite.Site +  Self.pc_Sprite.Spin * (0.0, 10.0, 30.0));
            --  Self.Applet.Camera.Spin_is (Self.pc_Sprite.Spin);
            --  log (Self.pc_Sprite.Spin'Image);
         end if;


         declare
            procedure broadcast (the_Text : in String)
            is
               the_Message : constant arcana.Client.Message := (Length (Self.Name) + 2 + the_Text'Length,
                                                               +Self.Name & ": " & the_Text);
            begin
               Self.emit (the_Message);
            end broadcast;

            chat_Message : constant String := ""; -- get_Line;
         begin
            exit
              when   Self.Server_has_shutdown
              or     Self.Server_is_dead
              or not Self.Applet.is_open;

            --  broadcast (chat_Message);
         end;
      end loop;


      -----------
      -- Shutdown
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

         if not Self.Server_is_dead
         then
            declare
               Peers : constant arcana.Client.views := arcana.Server.all_Clients;
            begin
               for i in Peers'Range
               loop
                  if Self'unchecked_Access /= Peers (i)
                  then
                     begin
                        Peers (i).deregister_Client ( Self'unchecked_Access,   -- Deregister our client with every other client.
                                                     +Self.Name);
                     exception
                        when system.RPC.communication_Error
                           | storage_Error =>
                           null;   -- Peer is dead, so do nothing.
                     end;
                  end if;
               end loop;
            end;
         end if;
      end if;

      check_Server_lives.halt;
      free (Self.Applet);
      lace.Event.utility.close;
   end start;


   -- 'last_chance_Handler' is commented out to avoid multiple definitions
   --  of link symbols in 'build_All' test procedure (Tier 5).
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
