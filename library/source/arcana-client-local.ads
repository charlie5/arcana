with
     lace.Any;

private
with
     lace.make_Subject,
     lace.make_Observer,

     gel.Applet.client_world,
     gel.World .client,
     gel.Sprite,

     openGL.texture_Set,

     gtk.Box,
     gtk.Label,
     gtk.gEntry,
     gtk.scrolled_Window,
     gtk.Text_View,
     gtk.Window,

     ada.Text_IO,
     ada.Strings.unbounded;


package arcana.Client.local
--
--  Provides a local client.
--  Client names must be unique.
--
is
   type Item is limited new lace.Any.limited_item
                        and arcana.Client.item with private;

   type View is access all Item'Class;


   -- Forge
   --
   function to_Client (Name : in String) return Item;


   -- Attributes
   --
   overriding
   function Name (Self : in Item) return String;

   overriding
   function as_Observer (Self : access Item) return lace.Observer.view;

   overriding
   function as_Subject  (Self : access Item) return lace.Subject.view;


   -- Operations
   --
   procedure open  (Self : in out arcana.Client.local.item);
   procedure run   (Self : in out arcana.Client.local.item);

   procedure Server_is_dead (Self : in out Item);

   overriding
   procedure Server_has_shutdown (Self : in out Item);

   overriding
   procedure pc_sprite_Id_is (Self : in out Item;   Now : in gel.sprite_Id);

   overriding
   function  pc_sprite_Id    (Self : in     Item)     return gel.sprite_Id;

   overriding
   procedure receive_Chat    (Self : in     Item;   Message : in String);



private

   package Observer is new lace.make_Observer (lace.Any.limited_item);
   package Subject  is new lace.make_Subject  (Observer        .item);


   use gtk.Box,
       gtk.Window,

       ada.Strings.unbounded;


   --------
   --- Item
   --

   type Item is limited new Subject      .item
                        and arcana.Client.item with
      record
         Name                : unbounded_String;
         Server_has_shutdown : Boolean := False;
         Server_is_dead      : Boolean := False;

         -- GtkAda objects.
         --
         top_Window    : gtk_Window;
         gl_Box        : gtk_vBox;
         chat_Entry    : gtk.gEntry.gtk_gEntry;

         events_Text   : gtk.Text_View.gtk_Text_View;
         chat_Text     : gtk.Text_View.gtk_Text_View;
         melee_Text    : gtk.Text_View.gtk_Text_View;

         events_Window : gtk.scrolled_Window.gtk_scrolled_Window;
         chat_Window   : gtk.scrolled_Window.gtk_scrolled_Window;
         melee_Window  : gtk.scrolled_Window.gtk_scrolled_Window;

         -- Gel objects.
         --
         pc_sprite_Id  : gel.sprite_Id  := gel.null_sprite_Id;
         pc_Sprite     : gel.Sprite.view;
         Applet        : gel.Applet.client_world.view;

         -- Targeting.
         --
         target_Marker : gel.Sprite.view;
         Target        : gel.Sprite.view;
         target_Name   : gtk.Label.gtk_Label;

         -- Movement.
         --
         Pace : Pace_t := Halt;

      end record;


   target_marker_Height : constant := 0.2;


   ---------------
   --- Sprite Info
   --

   type sprite_Info is new gel.Sprite.any_user_Data with
      record
         occlude_Countdown : Integer                       := 0;
         fade_Level        : openGL.texture_Set.fade_Level := 0.0;
      end record;



   ---------------
   --- Convenience
   --
   function client_World (Self : in Item) return gel.World.client.view;

   my_Client : Client.local.view;
   --
   -- Provide a convenience access to the client. This simplifies many of the event responses.
   -- There should cause no problems in a 'distributed' build but limits a 'fused' build to a single client.



   -----------
   --- Utility
   --
   procedure log (Message : in String := "")
                  renames ada.Text_IO.put_Line;

   function "+"  (From : in unbounded_String) return String
                  renames to_String;

end arcana.Client.local;
