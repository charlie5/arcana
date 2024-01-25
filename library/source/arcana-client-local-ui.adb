with
     arcana.Server,

     Glib,
     glib.Error,
     glib.Object,

     gtk.Adjustment,
     gtk.Button,
     gtk.radio_Button,
     gtk.toggle_Button,
     gtk.text_Buffer,
     gtk.Main,

     gtkAda.Builder,

     ada.Characters.latin_1,
     ada.Text_IO;


package body arcana.Client.local.UI
is
   use glib,
       glib.Error,
       glib.Object,

       gtk.Box,
       gtk.Button,
       gtk.gEntry,
       gtk.toggle_Button,
       gtk.radio_Button,
       gtk.scrolled_Window,
       gtk.text_Buffer,
       gtk.text_View,

       gtkAda.Builder,

       ada.Text_IO;


   glade_Filename : constant String := "./glade/arcana-client.glade";
   --
   --  This is the file from which we'll read our GTK UI description.


   -----------
   --- Widgets
   --

   -- Pace Buttons.
   --
   halt_Button     : gtk_radio_Button;
   walk_Button     : gtk_radio_Button;
   jog_Button      : gtk_radio_Button;
   run_Button      : gtk_radio_Button;
   dash_Button     : gtk_radio_Button;

   -- Movement Controls
   --
   approach_Button : gtk_Button;



   procedure update_UI
   is
   begin
      case my_Client.Pace
      is
         --  when Halt => halt_Button.set_Active (True);
         when others => null;
      end case;

   end update_UI;



   -------------------
   --- Event Handlers.
   --

   -- Chat
   --

   procedure on_Chat_activated (Self : access Gtk_Entry_Record'Class)
   is
      Text : constant String := get_Chars (Self, 0);
   begin
      Self.delete_Text (0);
      arcana.Server.add_Chat (From    => my_Client.all'Access,
                              Message => Text);
   end on_Chat_activated;



   -- Paces
   --

   procedure on_halt_Pace_selected (Self : access Gtk_Toggle_Button_Record'Class)
   is
      use arcana.Server;
   begin
      if Self.get_Active
      then
         log ("Setting pace to halt.");
         my_Client.Pace := Halt;
         update_UI;

         my_Client.emit (pc_pace_Event' (sprite_Id => my_Client.pc_sprite_Id,
                                         Pace      => Halt));
         my_Client.chat_Entry.grab_Focus;     -- Change focus so that left/right arrow keys do not affect pace.
      end if;
   end on_halt_Pace_selected;



   procedure on_walk_Pace_selected (Self : access Gtk_Toggle_Button_Record'Class)
   is
      use arcana.Server;
   begin
      if Self.get_Active
      then
         log ("Setting pace to walk.");
         my_Client.Pace := Walk;
         update_UI;

         my_Client.emit (pc_pace_Event' (sprite_Id => my_Client.pc_sprite_Id,
                                         Pace      => Walk));
         my_Client.chat_Entry.grab_Focus;     -- Change focus so that left/right arrow keys do not affect pace.
      end if;
   end on_walk_Pace_selected;



   procedure on_jog_Pace_selected (Self : access Gtk_Toggle_Button_Record'Class)
   is
      use arcana.Server;
   begin
      if Self.get_Active
      then
         log ("Setting pace to jog.");
         my_Client.Pace := Jog;
         update_UI;

         my_Client.emit (pc_pace_Event' (sprite_Id => my_Client.pc_sprite_Id,
                                         Pace      => Jog));
         my_Client.chat_Entry.grab_Focus;     -- Change focus so that left/right arrow keys do not affect pace.
      end if;
   end on_jog_Pace_selected;



   procedure on_run_Pace_selected (Self : access Gtk_Toggle_Button_Record'Class)
   is
      use arcana.Server;
   begin
      if Self.get_Active
      then
         log ("Setting pace to run.");
         my_Client.Pace := Run;
         update_UI;

         my_Client.emit (pc_pace_Event' (sprite_Id => my_Client.pc_sprite_Id,
                                         Pace      => Run));
         my_Client.chat_Entry.grab_Focus;     -- Change focus so that left/right arrow keys do not affect pace.
      end if;
   end on_run_Pace_selected;



   procedure on_dash_Pace_selected (Self : access Gtk_Toggle_Button_Record'Class)
   is
      use arcana.Server;
   begin
      if Self.get_Active
      then
         log ("Setting pace to dash.");
         my_Client.Pace := Dash;
         update_UI;

         my_Client.emit (pc_pace_Event' (sprite_Id => my_Client.pc_sprite_Id,
                                         Pace      => Dash));
         my_Client.chat_Entry.grab_Focus;     -- Change focus so that left/right arrow keys do not affect pace.
      end if;
   end on_dash_Pace_selected;



   -- Movement Controls
   --

   procedure on_approach_Button_clicked (Self : access Gtk_Button_Record'Class)
   is
      use arcana.Server;
   begin
      --  log ("on_approach_Button_clicked");

      my_Client.emit (pc_approach_Event' (sprite_Id => my_Client.pc_sprite_Id));

      --  my_Client.Pace := Dash;
      --  update_UI;
      --
      --  my_Client.emit (pc_pace_Event' (sprite_Id => my_Client.pc_sprite_Id,
      --                                  Pace      => Dash));
      --  my_Client.chat_Entry.grab_Focus;     -- Change focus so that left/right arrow keys do not affect pace.
   end on_approach_Button_clicked;




   --------------
   --- Setup Gtk.
   --

   procedure setup_Gtk (Self : in out Client.local.item)
   is
      use gtk.Label,
          gtkAda.Builder;

      Builder :         gtkAda_Builder;
      Error   : aliased gError;
   begin
      gtk.Main.init;     -- Initialise GtkAda.

      --  Create a new Gtkada_Builder object.
      --
      gtk_New (Builder);

      --  Read in our XML file.
      --
      if Builder.add_from_File (glade_Filename,
                                Error'Access) = 0
      then
         put_Line ("Error [Builder.add_from_File]: " & get_Message (Error));
         Error_free (Error);
      end if;

      ----------------------
      ---  Find our widgets.
      --
      Self.top_Window    := gtk_Window          (Builder.get_Object ("Top"));
      Self.gl_Box        := gtk_Box             (Builder.get_Object ("gl_Box"));
      Self.chat_Entry    := gtk_Entry           (Builder.get_Object ("chat_Entry"));

      Self.events_Text   := gtk_Text_View       (Builder.get_Object ("events_Text"));
      Self.  chat_Text   := gtk_Text_View       (Builder.get_Object (  "chat_Text"));
      Self. melee_Text   := gtk_Text_View       (Builder.get_Object ( "melee_Text"));

      Self.events_Window := gtk_scrolled_Window (Builder.get_Object ("events_Window"));
      Self.  chat_Window := gtk_scrolled_Window (Builder.get_Object (  "chat_Window"));
      Self. melee_Window := gtk_scrolled_Window (Builder.get_Object ( "melee_Window"));

      Self.target_Name   := gtk_Label           (Builder.get_Object ("target_Name"));

      approach_Button    := gtk_Button          (Builder.get_Object ("approach_Button"));


      -- Pace radio buttons.
      --
      halt_Button := gtk_radio_Button (Builder.get_Object (Name => "halt_Button"));
      walk_Button := gtk_radio_Button (Builder.get_Object (Name => "walk_Button"));
      jog_Button  := gtk_radio_Button (Builder.get_Object (Name =>  "jog_Button"));
      run_Button  := gtk_radio_Button (Builder.get_Object (Name =>  "run_Button"));
      dash_Button := gtk_radio_Button (Builder.get_Object (Name => "dash_Button"));


      ---------------------------
      ---  Configure our widgets.
      --
      Self.events_Text.set_size_Request (Width  =>  -1,
                                         Height => 100);

      -----------------------
      ---  Set up GTK events.
      --
      do_Connect (Builder);

      Self.chat_Entry.on_Activate (call => on_Chat_activated'Access);

      halt_Button.on_Toggled (on_halt_Pace_selected'Access);
      walk_Button.on_Toggled (on_walk_Pace_selected'Access);
      jog_Button .on_Toggled ( on_jog_Pace_selected'Access);
      run_Button .on_Toggled ( on_run_Pace_selected'Access);
      dash_Button.on_Toggled (on_dash_Pace_selected'Access);

      approach_Button.On_Clicked (on_approach_Button_clicked'Access);


      --  Set the size of the main window.
      --
      Self.top_Window.set_default_Size (Width  => 1920,
                                        Height => 1080);
   end setup_Gtk;



   -------------------------------------------------------
   --- Add messages to the events, chat and melee windows.
   --

   procedure add_events_Line (Self : in Client.local.item;   Message : in String)
   is
   begin
      Self.events_Text.get_Buffer.insert_at_Cursor (Message & ada.Characters.latin_1.LF);

      declare
         Adjuster : constant gtk.Adjustment.gtk_Adjustment := Self.events_Window.get_vAdjustment;
      begin
         Adjuster.set_Value (Adjuster.get_Upper);
      end;
   end add_events_Line;



   procedure add_chat_Line (Self : in Client.local.item;   Message : in String)
   is
   begin
      Self.chat_Text.get_Buffer.insert_at_Cursor (Message & ada.Characters.latin_1.LF);

      declare
         Adjuster : constant gtk.Adjustment.gtk_Adjustment := Self.chat_Window.get_vAdjustment;
      begin
         Adjuster.set_Value (Adjuster.get_Upper);
      end;
   end add_chat_Line;



   procedure add_melee_Line (Self : in Client.local.item;   Message : in String)
   is
   begin
      Self.melee_Text.get_Buffer.insert_at_Cursor (Message & ada.Characters.latin_1.LF);

      declare
         Adjuster : constant gtk.Adjustment.gtk_Adjustment := Self.events_Window.get_vAdjustment;
      begin
         Adjuster.set_Value (Adjuster.get_Upper);
      end;
   end add_melee_Line;


end arcana.Client.local.UI;
