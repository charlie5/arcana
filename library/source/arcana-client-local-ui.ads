
package arcana.Client.local.UI
--
-- Provides GtkAda support for a local client.
--
is
   procedure setup_Gtk     (Self : in out Client.local.item);

   procedure add_events_Line (Self : in     Client.local.item;   Message : in String);
   procedure   add_chat_Line (Self : in     Client.local.item;   Message : in String);
   procedure  add_melee_Line (Self : in     Client.local.item;   Message : in String);

end arcana.Client.local.UI;
