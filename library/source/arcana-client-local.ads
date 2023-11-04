with
     lace.Any;

private
with
     lace.make_Subject,
     lace.make_Observer,
     lace.Response,

     gel.Applet.gui_world,
     gel.Sprite,

     gtk.Box,
     gtk.Label,
     gtk.Window,

     ada.Strings.unbounded;


package arcana.Client.local
--
-- Provides a local client.
-- Names must be unique.
--
is
   type Item is limited new lace.Any.limited_item
                        and arcana.Client  .item with private;

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
   procedure start (Self : in out arcana.Client.local.item);

   overriding
   procedure   register_Client (Self : in out Item;   other_Client : in Client.view);

   overriding
   procedure deregister_Client (Self : in out Item;   other_Client_as_Observer : in lace.Observer.view;
                                                      other_Client_Name        : in String);
   overriding
   procedure Server_has_shutdown (Self : in out Item);



private

   package Observer is new lace.make_Observer (lace.Any.limited_item);
   package Subject  is new lace.make_Subject  (Observer        .item);


   --------------
   --- Gel Events
   --
   type   key_press_Response is new lace.Response.item with null record;
   type key_release_Response is new lace.Response.item with null record;

   overriding
   procedure respond (Self : in out   key_press_Response;   to_Event : in lace.Event.item'Class);
   overriding
   procedure respond (Self : in out key_release_Response;   to_Event : in lace.Event.item'Class);


   use gtk.Box,
       gtk.Label,
       gtk.Window,

       ada.Strings.unbounded;


   --------
   --- Item
   --

   type Item is limited new Subject       .item
                        and arcana.Client.item with
      record
         Name                : unbounded_String;
         Server_has_shutdown : Boolean := False;
         Server_is_dead      : Boolean := False;

         -- GtkAda objects.
         --
         top_Window : Gtk_Window;
         Label      : Gtk_Label;
         Box        : Gtk_Vbox;

         -- Gel objects.
         --
         Applet : gel.Applet.gui_world.view;
         Player : gel.Sprite.view;

         -- Gel Events.
         --
         my_key_press_Response   : aliased key_press_Response;
         my_key_release_Response : aliased key_release_Response;
      end record;


end arcana.Client.local;
