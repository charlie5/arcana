with
     arcana.Server,

     Glib,
     glib.Error,
     glib.Object,

     gtk.Adjustment,
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
       gtk.GEntry,
       gtk.scrolled_Window,
       gtk.text_Buffer,
       gtk.text_View,

       gtkAda.Builder,

       ada.Text_IO;


   glade_Filename : constant String := "./glade/arcana-client.glade";
   --
   --  This is the file from which we'll read our GTK UI description.


   procedure on_Chat_activated (Self : access Gtk_Entry_Record'Class)
   is
      Text : constant String := get_Chars (Self, 0);
   begin
      Self.delete_Text (0);
      arcana.Server.add_Chat (From    => my_Client.all'Access,
                              Message => Text);
   end on_Chat_activated;




   procedure setup_Gtk (Self : in out Client.local.item)
   is
      use gtkAda.Builder;

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

      --  Set our widgets.
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

      --  Configure our widgets.
      --
      Self.events_Text.set_size_Request (Width  =>  -1,
                                         Height => 100);
      --  Set up GTK events.
      --
      do_Connect (Builder);
      Self.chat_Entry.on_Activate (call => on_Chat_activated'Access);

      --  Set the size of the main window.
      --
      Self.top_Window.set_default_Size (Width  => 1920,
                                        Height => 1080);
   end setup_Gtk;



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
