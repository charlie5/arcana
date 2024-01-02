with
     arcana.Server,

     lace.Observer,
     lace.Event.utility,
     lace.Text.forge,

     gel.Forge,
     gel.Window.setup,
     gel.Window.gtk,
     gel.Keyboard,
     gel.World.client,
     gel.Events,
     gel.remote.World,

     Physics,

     openGL.Palette,
     openGL.Light,

     glib,
     glib.Error,
     glib.Object,

     gtk.Adjustment,
     gtk.Box,
     gtk.Button,
     gtk.Editable,
     gtk.gEntry,
     gtk.Grid,
     gtk.Frame,
     gtk.Main,
     gtk.radio_Button,
     gtk.spin_Button,
     gtk.Text_Buffer,
     gtk.Text_View,
     gtk.Toggle_Button,
     gtk.Label,
     gtk.Widget,
     gtkAda.Builder,

     system.RPC,

     ada.Calendar,
     ada.Characters.latin_1,
     ada.Exceptions,
     ada.Text_IO;

pragma Unreferenced (gel.Window.setup);


package body arcana.Client.local
is
   use glib,
       glib.Error,
       glib.Object,

       gtk.Box,
       gtk.Button,
       gtk.GEntry,
       gtk.Grid,
       gtk.Editable,
       gtk.Frame,
       gtk.Label,
       gtk.spin_Button,
       gtk.scrolled_Window,
       gtk.radio_Button,
       gtk.Text_Buffer,
       gtk.Text_View,
       gtk.Toggle_Button,

       --  Common,
       gtkAda.Builder,

       ada.Text_IO;


   default_Filename : constant String := "./glade/arcana-client.glade";
   --
   --  This is the file from which we'll read our UI description.


   ----------
   -- Utility
   --

   function "+" (From : in unbounded_String) return String
                 renames to_String;


   procedure log (Message : in String := "")
                  renames ada.Text_IO.put_Line;



   -------
   --- Gtk
   --

   --  top_Grid : gtk.Grid.gtk_Grid;
   --  gl_Box   : gtk.Box.gtk_Box;



   procedure on_Chat_activated (Self : access Gtk_Entry_Record'Class)
   is
      Text : constant String := get_Chars (Self, 0);
   begin
      Self.delete_Text (0);
      arcana.Server.add_Chat (from    => my_Client.all'Access,
                              Message => Text);

      --  the_PC.Name_is (name_Entry.get_Text);
   end on_Chat_activated;




   procedure setup_Gtk (Self : in out Client.local.item)
   is
      use gtk.Widget,
          gtkAda.Builder;

      Builder :         gtkAda_Builder;
      Error   : aliased gError;
   begin
      --  gtk.Main.init;

      --  Create a new Gtkada_Builder object.
      --
      gtk_New (Builder);

      --  Read in our XML file.
      --
      if Builder.add_from_File (default_Filename,
                                Error'Access) = 0
      then
         put_Line ("Error [Builder.add_from_File]: "
                   & get_Message (Error));
         Error_free (Error);
      end if;


      -- Set our widgets.
      --

      --  top_Grid := gtk_Grid (Builder.get_Object (Name =>       "top_Grid"));
      --  gl_Box   := gtk_Box  (Builder.get_Object (Name =>       "gl_Box"));


      --  name_Entry         := gtk_gEntry (Builder.get_Object (Name =>       "name_Entry"));
      --  appearance_Entry   := gtk_gEntry (Builder.get_Object (Name => "appearance_Entry"));
      --
      --  dwarf_Button       := gtk_radio_Button (Builder.get_Object (Name =>  "dwarf_Button"));
      --  elf_Button         := gtk_radio_Button (Builder.get_Object (Name =>    "elf_Button"));
      --  goblin_Button      := gtk_radio_Button (Builder.get_Object (Name => "goblin_Button"));
      --  hobbit_Button      := gtk_radio_Button (Builder.get_Object (Name => "hobbit_Button"));
      --  man_Button         := gtk_radio_Button (Builder.get_Object (Name =>    "man_Button"));
      --
      --  avail_points_Label := gtk_Label (Builder.get_Object (Name => "avail_points_Label"));
      --  total_points_Label := gtk_Label (Builder.get_Object (Name => "total_points_Label"));
      --
      --  brawn_Spinner := gtk_Spin_Button (Builder.get_Object (Name => "brawn_Spinner"));
      --  wit_Spinner   := gtk_Spin_Button (Builder.get_Object (Name =>   "wit_Spinner"));
      --  deft_Spinner  := gtk_Spin_Button (Builder.get_Object (Name =>  "deft_Spinner"));
      --  grit_Spinner  := gtk_Spin_Button (Builder.get_Object (Name =>  "grit_Spinner"));
      --  will_Spinner  := gtk_Spin_Button (Builder.get_Object (Name =>  "will_Spinner"));
      --  agile_Spinner := gtk_Spin_Button (Builder.get_Object (Name => "agile_Spinner"));
      --
      --  hit_points_Label     := gtk_Label (Builder.get_Object (Name =>     "hit_points_Label"));
      --  fatigue_points_Label := gtk_Label (Builder.get_Object (Name => "fatigue_points_Label"));
      --  perception_Label     := gtk_Label (Builder.get_Object (Name =>     "perception_Label"));
      --
      --  swing_damage_Label   := gtk_Label (Builder.get_Object (Name =>   "swing_damage_Label"));
      --  thrust_damage_Label  := gtk_Label (Builder.get_Object (Name =>  "thrust_damage_Label"));
      --
      --  none_encumbrance_Label    := gtk_Label (Builder.get_Object (Name =>    "none_encumbrance_Label"));
      --  light_encumbrance_Label   := gtk_Label (Builder.get_Object (Name =>   "light_encumbrance_Label"));
      --  medium_encumbrance_Label  := gtk_Label (Builder.get_Object (Name =>  "medium_encumbrance_Label"));
      --  heavy_encumbrance_Label   := gtk_Label (Builder.get_Object (Name =>   "heavy_encumbrance_Label"));
      --  maximum_encumbrance_Label := gtk_Label (Builder.get_Object (Name => "maximum_encumbrance_Label"));
      --
      --  none_move_Label    := gtk_Label (Builder.get_Object (Name => "none_move_Label"));
      --  light_move_Label   := gtk_Label (Builder.get_Object (Name => "light_move_Label"));
      --  medium_move_Label  := gtk_Label (Builder.get_Object (Name => "medium_move_Label"));
      --  heavy_move_Label   := gtk_Label (Builder.get_Object (Name => "heavy_move_Label"));
      --  maximum_move_Label := gtk_Label (Builder.get_Object (Name => "maximum_move_Label"));
      --
      --  none_dodge_Label    := gtk_Label (Builder.get_Object (Name => "none_dodge_Label"));
      --  light_dodge_Label   := gtk_Label (Builder.get_Object (Name => "light_dodge_Label"));
      --  medium_dodge_Label  := gtk_Label (Builder.get_Object (Name => "medium_dodge_Label"));
      --  heavy_dodge_Label   := gtk_Label (Builder.get_Object (Name => "heavy_dodge_Label"));
      --  maximum_dodge_Label := gtk_Label (Builder.get_Object (Name => "maximum_dodge_Label"));


      -- Set up events.
      --
      --  on_Changed (+name_Entry,       call =>       on_Name_changed'Access);
      --  on_Changed (+appearance_Entry, call => on_Appearance_changed'Access);

      --  dwarf_Button .on_Toggled ( on_dwarf_Race_selected'Access);
      --  elf_Button   .on_Toggled (   on_elf_Race_selected'Access);
      --  goblin_Button.on_Toggled (on_goblin_Race_selected'Access);
      --  hobbit_Button.on_Toggled (on_hobbit_Race_selected'Access);
      --  man_Button   .on_Toggled (   on_man_Race_selected'Access);
      --
      --  brawn_Spinner.on_Value_changed (on_Brawn_changed'Access);
      --  grit_Spinner .on_Value_changed (on_Grit_changed 'Access);
      --  wit_Spinner  .on_Value_changed (on_Wit_changed  'Access);
      --  will_Spinner .on_Value_changed (on_Will_changed 'Access);
      --  deft_Spinner .on_Value_changed (on_Deft_changed 'Access);
      --  agile_Spinner.on_Value_changed (on_Agile_changed'Access);


      --  Do the necessary event connections.
      --
      --  register_Handler
      --    (Builder      => Builder,
      --     Handler_Name => "on_btn_concatenate_clicked",
      --     Handler      => On_Btn_Concatenate_Clicked'Access);
      --
      --  register_Handler
      --    (Builder      => Builder,
      --     Handler_Name => "on_btn_console_greeting_clicked",
      --     Handler      => On_Btn_Console_Greeting_Clicked'Access);
      --
      --  register_Handler
      --    (Builder      => Builder,
      --     Handler_Name => "on_window1_delete_event",
      --     Handler      => On_Window1_Delete_Event'Access);
      --
      --  register_Handler
      --    (Builder      => Builder,
      --     Handler_Name => "on_Top_destroy",
      --     Handler      => on_Top_destroy'Access);
      --
      --  register_Handler
      --    (Builder      => Builder,
      --     Handler_Name => "on_print_to_console",
      --     Handler      => On_Print_To_Console'Access);

      --  Find our main window, then display it and all of its children.
      --
      Self.top_Window    := gtk_Window          (Builder.get_Object ("Top"));
      Self.gl_Box        := gtk_Box             (Builder.get_Object ("gl_Box"));
      Self.chat_Entry    := gtk_Entry           (Builder.get_Object ("chat_Entry"));
      Self.events_Text   := gtk_Text_View       (Builder.get_Object ("events_Text"));
      Self.events_Window := gtk_scrolled_Window (Builder.get_Object ("events_Window"));

      Self.events_Text.Set_Size_Request (Width => -1,
                                         Height => 100);

      do_Connect (Builder);

      -- Set up events.
      --
      --  on_Changed (+Self.chat_Entry,       call =>       on_Name_changed'Access);
      --  on_Activate (+Self.chat_Entry,       call =>       on_Name_changed'Access);

      Self.chat_Entry.on_Activate (call => on_Chat_activated'Access);

      Self.top_Window.show_All;
   end setup_Gtk;




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


   type Sprite_clicked_Response is new lace.Response.item with
      record
         Sprite : gel.Sprite.view;
      end record;

   type Sprite_clicked_Response_view is access all Sprite_clicked_Response;



   overriding
   procedure respond (Self : in out Sprite_clicked_Response;  to_Event : in lace.Event.Item'Class)
   is
   begin
      log ("*********************************************************************** Sprite '" & Self.Sprite.Name & "' clicked ...");
   end respond;


   --  the_Sprite_clicked_Response : aliased Sprite_clicked_Response;




   type Sprite_added_Response is new lace.Response.item with
      record
         Sprite : gel.Sprite.view;
      end record;

   type Sprite_added_Response_view is access all Sprite_added_Response;



   overriding
   procedure respond (Self : in out Sprite_added_Response;  to_Event : in lace.Event.Item'Class)
   is
      use lace.Event.utility;

      the_Event    : gel.Remote.World.sprite_added_Event := gel.Remote.World.sprite_added_Event (to_Event);
      the_Sprite   : gel.Sprite.view                     := my_Client.Applet.World.fetch_Sprite (the_Event.Sprite);
      new_Response : Sprite_clicked_Response_view        := new Sprite_clicked_Response;
   begin
      log ("LLL " & the_Event.Sprite'Image);
      log ("ADDED ****************************  Sprite '" & the_Sprite.Name & "' added ...");

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
      use openGL.Palette,
          lace.Event.utility;
   begin
      gtk.Main.init;     -- Initialize GtkAda.


      return Self : Item
      do
         --- Setup GtkAda.
         --

         setup_Gtk (Self);

         --  Create a window with a size of 800 x 650.
         --
         --  gtk_new (Self.top_Window);
         Self.top_Window.set_default_Size (1920, 1080);

         --  Create a gl_Box to organize vertically the contents of the window.
         --
         --  gtk_New_vBox        (Self.Box);
         --  Self.top_Window.add (Self.gl_Box);

         --  Add a label.
         --
         --  gtk_new             (Self.Label, "Hello Arcana.");
         --  Self.gl_Box.pack_Start (Self.Label,
         --  gl_Box.pack_Start (Self.Label,
                              --  Expand  => False,
                              --  Fill    => False,
                              --  Padding => 10);

         Self.Name   := to_unbounded_String (Name);
         Self.Applet := gel.Forge.new_client_Applet (Named         => "Arcana",
                                                     window_Width  => 1920,
                                                     window_Height => 1080,
                                                     space_Kind    => physics.Box2d);

         Self.gl_Box.pack_Start (gel.Window.gtk.view (Self.Applet.Window).GL_Area);

         --  gel.Window.gtk.view (Self.Applet.Window).GL_Area.set_can_Focus (True);

         --  top_Grid.attach (gel.Window.gtk.view (Self.Applet.Window).GL_Area, 1, 1);
         --  gl_Box.pack_Start (gel.Window.gtk.view (Self.Applet.Window).GL_Area);

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

         connect ( Self.Applet.local_Observer,
                   Self.client_World.all'Access,
                   the_Sprite_added_Response'unchecked_Access,
                  +gel.remote.World.sprite_added_Event'Tag);



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



   overriding
   function pc_sprite_Id (Self : in Item) return gel.sprite_Id
   is
   begin
      return Self.pc_sprite_Id;
   end pc_sprite_Id;



   -------------
   -- Operations
   --

   --  overriding
   --  procedure register_Client (Self : in out Item;   other_Client : in Client.view)
   --  is
   --     use lace.Event.utility,
   --         ada.Text_IO;
   --  begin
   --     lace.Event.utility.connect (the_Observer  => Self'unchecked_Access,
   --                                 to_Subject    => other_Client.as_Subject,
   --                                 with_Response => the_Response'Access,
   --                                 to_Event_Kind => to_Kind (arcana.Client.Message'Tag));
   --
   --     put_Line (other_Client.Name & " is here.");
   --  end register_Client;
   --
   --
   --
   --  overriding
   --  procedure deregister_Client (Self : in out Item;   other_Client_as_Observer : in lace.Observer.view;
   --                                                     other_Client_Name        : in String)
   --  is
   --     use lace.Event.utility,
   --         ada.Text_IO;
   --  begin
   --     begin
   --        Self.as_Subject.deregister (other_Client_as_Observer,
   --                                    to_Kind (arcana.Client.Message'Tag));
   --     exception
   --        when constraint_Error =>
   --           raise unknown_Client with "Other client not known. Deregister is not required.";
   --     end;
   --
   --     Self.as_Observer.rid (the_Response'unchecked_Access,
   --                           to_Kind (arcana.Client.Message'Tag),
   --                           other_Client_Name);
   --
   --     put_Line (other_Client_Name & " leaves.");
   --  end deregister_Client;



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
         Count := Count + 1;
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




   type retreat_Sprite is new lace.Response.item with
      record
         Sprite : gel.Sprite.view;
      end record;

   overriding
   procedure respond (Self : in out retreat_Sprite;  to_Event : in lace.Event.Item'Class)
   is
   begin
      ada.text_io.put_Line ("*** retreat_Sprite ***");
   end respond;

   retreat_Sprite_Response : aliased retreat_Sprite; -- := (lace.Response.item with sprite => the_Ball);






   ---------
   --- Start
   --

   procedure start (Self : in out arcana.Client.local.item)
   is
      use gel.Applet.client_world,
          gel.Math,
          ada.Text_IO;

      use type gel.Sprite.view,
               gel.sprite_Id;

      Cycle : Natural := 0;

      --  the_Ball : constant gel.Sprite.view := gel.Forge.new_ball_Sprite (Self.Applet.World (1),
      --                                                                    Site => (2.0, 1.0, 1.0),
      --                                                                    Color => (opengl.Palette.Red, 1.0),
      --                                                                    Mass => 1.0);


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
            free (Self.Applet);
            return;
      end;

      lace.Event.utility.use_text_Logger ("events");

      check_Server_lives.start (Self'unchecked_Access);

      --  declare
      --     Peers : constant arcana.Client.views := arcana.Server.all_Clients;
      --  begin
      --     for i in Peers'Range
      --     loop
      --        if Self'unchecked_Access /= Peers (i)
      --        then
      --           begin
      --              Peers (i).register_Client (Self'unchecked_Access);    -- Register our client with all other clients.
      --              Self     .register_Client (Peers (i));                -- Register all other clients with our client.
      --           exception
      --              when system.RPC.communication_Error
      --                 | storage_Error =>
      --                 null;     -- Peer (i) has died, so ignore it and do nothing.
      --           end;
      --        end if;
      --     end loop;
      --  end;

      Self.Applet.client_World.is_a_Mirror (of_World      => arcana.Server.World);
      Self.Applet.enable_Mouse             (detect_Motion => False);
      Self.Applet.client_World.Gravity_is  ([0.0, 0.0, 0.0]);

      --  retreat_Sprite_Response.Sprite := the_Ball;

      --  Self.Applet.client_World.add (the_Ball);

      ------------
      -- Main Loop
      --
      declare
         use lace.Event.utility,
             ada.Calendar;

         next_evolve_Time   : ada.Calendar.Time := ada.Calendar.Clock;
         next_evolve_Report : ada.Calendar.Time := next_evolve_Time;
         evolve_Count       : Natural           := 0;

      begin
         while Self.Applet.is_open
         loop
            Cycle := Cycle + 1;

            if Cycle = 1500
            then
               null;
               --  raise Constraint_Error with "cycle 500";
            end if;



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



            --  Self.Applet.World.evolve;     -- Advance the world.
            Self.Applet.freshen;          -- Evolve the world, handle new events and update the screen.
            --  Self.Applet.local_Observer.respond;

            if    Self.pc_Sprite     = null
              and Self.pc_sprite_Id /= gel.null_sprite_Id
            then
               begin
                  Self.pc_Sprite := Self.client_World.fetch_Sprite (Self.pc_sprite_Id);
                  --  the_Sprite_clicked_Response.Sprite := Self.pc_Sprite;
                  --
                  --  connect (the_Observer  =>  Self.Applet.local_Observer,
                  --           to_Subject    =>  lace.Subject.view (Self.pc_Sprite),
                  --           with_Response =>  the_Sprite_clicked_Response'Access,
                  --           to_Event_Kind => +gel.Events.sprite_click_down_Event'Tag);
                  --
                  --  --  Self.Applet.enable_following_Dolly (follow => Self.pc_Sprite);
               exception
                  when constraint_Error =>
                     log ("Warning: Unable to fetch PC sprite" & Self.pc_sprite_Id'Image & ".");
               end;
            end if;


            if Self.pc_Sprite /= null
            then
               --  log (Self.pc_Sprite.all'Image);

               if Cycle mod 60 = 0
               then
                  log (Self.pc_Sprite.Site'Image);
               end if;

               Self.Applet.Camera.Site_is (Self.pc_Sprite.Site + (0.0, 0.0, 30.0));
               --  Self.Applet.Camera.Site_is (Self.Applet.Camera.Site + (0.001, 0.0, 0.0));
               --  Self.Applet.Camera.Site_is (Self.pc_Sprite.Site +  Self.pc_Sprite.Spin * (0.0, 10.0, 30.0));
               --  Self.Applet.Camera.Spin_is (Self.pc_Sprite.Spin);
               --  log (Self.pc_Sprite.Spin'Image);
            end if;



            --- Chat messages.
            --
            declare
               use lace.Text;

               Messages : lace.Text.items_256 (1 .. 50);
               Count    : Natural;
            begin
               chat_Messages.fetch (Messages, Count);

               for i in 1 .. Count
               loop
                  Self.events_Text.get_Buffer.insert_at_Cursor (  to_String (Messages (i))
                                                                  & ada.Characters.latin_1.LF);
               end loop;

               if Count > 0
               then
                  declare
                     Adjust : constant gtk.Adjustment.gtk_Adjustment := Self.events_Window.get_vAdjustment;
                  begin
                     Adjust.set_Value (Adjust.get_Upper);
                  end;
               end if;
            end;



            --- Loop exit.
            --
            exit when Self.Server_has_shutdown
              or      Self.Server_is_dead
              or not  Self.Applet.is_open;


            delay until next_evolve_Time;
            next_evolve_Time := next_evolve_Time + 1.0 / (1.0 * 60.0);
         end loop;
      end;


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

         --  if not Self.Server_is_dead
         --  then
         --     declare
         --        Peers : constant arcana.Client.views := arcana.Server.all_Clients;
         --     begin
         --        for i in Peers'Range
         --        loop
         --           if Self'unchecked_Access /= Peers (i)
         --           then
         --              begin
         --                 Peers (i).deregister_Client ( Self'unchecked_Access,   -- Deregister our client with every other client.
         --                                              +Self.Name);
         --              exception
         --                 when system.RPC.communication_Error
         --                    | storage_Error =>
         --                    null;   -- Peer is dead, so do nothing.
         --              end;
         --           end if;
         --        end loop;
         --     end;
         --  end if;
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
   end start;


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
