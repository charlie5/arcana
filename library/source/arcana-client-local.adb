with
     arcana.Client.local.UI,
     arcana.Server,

     lace.Observer,
     lace.Event.utility,
     lace.Text.forge,

     gel.Forge,
     gel.Window.setup,
     gel.Window.gtk,
     gel.Keyboard,
     gel.Events,
     gel.remote.World,

     Physics,

     openGL.Light,

     system.RPC,

     ada.Calendar,
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

   --- Key presses.
   --

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


   type Sprite_clicked_Response is new lace.Response.item with
      record
         Sprite : gel.Sprite.view;
      end record;

   type Sprite_clicked_Response_view is access all Sprite_clicked_Response;



   overriding
   procedure respond (Self : in out Sprite_clicked_Response;  to_Event : in lace.Event.Item'Class)
   is
   begin
      log ("'" & Self.Sprite.Name & "' clicked.");
   end respond;



   type Sprite_added_Response is new lace.Response.item with null record;

   overriding
   procedure respond (Self : in out Sprite_added_Response;  to_Event : in lace.Event.Item'Class)
   is
      use lace.Event.utility;

      the_Event    : constant gel.Remote.World.sprite_added_Event := gel.Remote.World.sprite_added_Event (to_Event);
      the_Sprite   : constant gel.Sprite.view                     := my_Client.Applet.World.fetch_Sprite (the_Event.Sprite);
      new_Response : constant Sprite_clicked_Response_view        := new Sprite_clicked_Response;
   begin
      log ("'" & the_Sprite.Name & "' added.");

      new_Response.Sprite := the_Sprite;

      connect (the_Observer  =>  my_Client.Applet.local_Observer,
               to_Subject    =>  lace.Subject .view (the_Sprite),
               with_Response =>  lace.Response.view (new_Response),
               to_Event_Kind => +gel.Events.sprite_click_down_Event'Tag);
   end respond;


   the_Sprite_added_Response : aliased Sprite_added_Response;




   --------
   -- Forge
   --

   function to_Client (Name : in String) return Item
   is
      use lace.Event.utility;
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
         connect (the_Observer  =>  Self.Applet.local_Observer,
                  to_Subject    =>  Self.Applet.Keyboard,
                  with_Response =>  Self.my_key_press_Response'unchecked_Access,
                  to_event_Kind => +gel.Keyboard.key_press_Event'Tag);

         connect (the_Observer  =>  Self.Applet.local_Observer,
                  to_Subject    =>  Self.Applet.Keyboard,
                  with_Response =>  Self.my_key_release_Response'unchecked_Access,
                  to_event_Kind => +gel.Keyboard.key_release_Event'Tag);

         connect (the_Observer  =>  Self.Applet.local_Observer,
                  to_Subject    =>  Self.client_World.all'Access,
                  with_Response =>  the_Sprite_added_Response'unchecked_Access,
                  to_event_Kind => +gel.remote.World.sprite_added_Event'Tag);


         Self.Applet.Camera.Site_is ([0.0, 0.0, 20.0]);


         -- Set the lights position.
         --
         declare
            Light : openGL.Light.item := Self.Applet.Renderer.new_Light;
         begin
            Light.Site_is                ([0.0, -1000.0, 0.0]);
            Light.ambient_Coefficient_is (0.5);

            Self.Applet.Renderer.set (Light);
         end;


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
         put_Line ("Error in 'check_Server_lives' task.");
         new_Line;
         put_Line (ada.exceptions.exception_Information (E));
   end check_Server_lives;



   function client_World (Self : in Item) return gel.World.client.view
   is
   begin
      return gel.World.client.view (Self.Applet.World (1));
   end client_World;




   -----------------
   --- Chat messages
   --

   protected chat_Messages
   is
      procedure add   (Message  : in String);

      procedure fetch (the_Messages : out lace.Text.items_256;
                       the_Count    : out Natural);

   private
      Messages : lace.Text.items_256 (1 .. 50);
      Count    : Natural := 0;
   end chat_Messages;


   protected body chat_Messages
   is
      procedure add (Message : in String)
      is
         use lace.Text.forge;
      begin
         Count            := Count + 1;
         Messages (Count) := to_Text_256 (Message);
      end add;


      procedure fetch (the_Messages : out lace.Text.items_256;
                       the_Count    : out Natural)
      is
      begin
         the_Messages (1 .. Count) := Messages (1 .. Count);
         the_Count                 := Count;
         Count                     := 0;
      end fetch;

   end chat_Messages;



   overriding
   procedure receive_Chat (Self : in Item;   Message : in String)
   is
   begin
      chat_Messages.add (Message);
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
            check_Server_lives.halt;
            free (Self.Applet);

            return;
      end;

      lace.Event.utility.use_text_Logger ("events");

      check_Server_lives.start (Self'unchecked_Access);

      Self.Applet.client_World.is_a_Mirror (of_World      => arcana.Server.World);
      Self.Applet.enable_Mouse             (detect_Motion => False);
      Self.Applet.client_World.Gravity_is  ([0.0, 0.0, 0.0]);
   end open;




   -------
   --- Run
   --

   procedure run (Self : in out arcana.Client.local.item)
   is
      use gel.Applet.client_world,
          gel.Math;
          --  ada.Text_IO;

      use type gel.Sprite.view,
               gel.sprite_Id;
   begin
      ------------
      -- Main Loop
      --
      declare
         use ada.Calendar;

         next_evolve_Time   : ada.Calendar.Time := ada.Calendar.Clock;
         next_evolve_Report : ada.Calendar.Time := next_evolve_Time;
         evolve_Count       : Natural           := 0;

      begin
         while Self.Applet.is_open
         loop
            evolve_Count := evolve_Count + 1;

            declare
               Now : constant ada.Calendar.TIme := ada.Calendar.Clock;
            begin
               if Now > next_evolve_Report
               then
                  --  log ("                                               Client ~ Evolves per second:" & evolve_Count'Image);
                  next_evolve_Report := next_evolve_Report + 1.0;
                  evolve_Count       := 0;
               end if;
            end;


            Self.Applet.freshen;     -- Evolve the world, handle new events and update the screen.

            if    Self.pc_Sprite     = null
              and Self.pc_sprite_Id /= gel.null_sprite_Id
            then
               begin
                  Self.pc_Sprite := Self.client_World.fetch_Sprite (Self.pc_sprite_Id);
               exception
                  when constraint_Error =>
                     log ("Warning: Unable to fetch PC sprite" & Self.pc_sprite_Id'Image & ".");
               end;
            end if;


            if Self.pc_Sprite /= null
            then
               Self.Applet.Camera.Site_is (Self.pc_Sprite.Site + [0.0, 0.0, 30.0]);
            end if;


            --- Display any new chat messages.
            --
            declare
               use lace.Text;

               Messages : lace.Text.items_256 (1 .. 50);
               Count    : Natural;
            begin
               chat_Messages.fetch (Messages, Count);

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


            delay until next_evolve_Time;
            next_evolve_Time := next_evolve_Time + 1.0 / 60.0;
         end loop;
      end;


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

      check_Server_lives.halt;
      free (Self.Applet);
      lace.Event.utility.close;

   exception
      when others =>
         check_Server_lives.halt;
         free (Self.Applet);
         lace.Event.utility.close;

         raise;
   end run;





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
