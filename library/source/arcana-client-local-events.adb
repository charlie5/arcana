with
     arcana.Server,

     gel.Keyboard,
     gel.Events,
     gel.remote.World,

     lace.Response,
     lace.Event.utility,

     ada.Text_IO;


package body arcana.Client.local.Events
is
   ----------
   -- Utility
   --

   procedure log (Message : in String := "")
                  renames ada.Text_IO.put_Line;



   ----------------
   --- Key presses.
   --

   --- Guards against key repeats.
   --
      up_Key_is_already_pressed,
    down_Key_is_already_pressed,
    left_Key_is_already_pressed,
   right_Key_is_already_pressed : Boolean := False;



   type key_press_Response is new lace.Response.item with null record;


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
         when Up     => my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => my_Client.pc_sprite_Id,  Direction => Forward,   On => True));
         when Down   => my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => my_Client.pc_sprite_Id,  Direction => Backward,  On => True));
         when Right  => my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => my_Client.pc_sprite_Id,  Direction => Right,     On => True));
         when Left   => my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => my_Client.pc_sprite_Id,  Direction => Left,      On => True));
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


   the_key_press_Response : aliased key_press_Response;




   type key_release_Response is new lace.Response.item with null record;

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
         when Up     => my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => my_Client.pc_sprite_Id,  Direction => Forward,   On => False));
         when Down   => my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => my_Client.pc_sprite_Id,  Direction => Backward,  On => False));
         when Right  => my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => my_Client.pc_sprite_Id,  Direction => Right,     On => False));
         when Left   => my_Client.emit (arcana.Server.pc_move_Event' (sprite_Id => my_Client.pc_sprite_Id,  Direction => Left,      On => False));
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


   the_key_release_Response : aliased key_release_Response;




   ------------------
   --- Sprite clicks.
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

      my_Client.Target := Self.Sprite;
      my_Client.target_Name.set_Label (Self.Sprite.Name);
   end respond;




   -----------------
   --- Sprite added.
   --

   type Sprite_added_Response is new lace.Response.item with null record;

   overriding
   procedure respond (Self : in out Sprite_added_Response;  to_Event : in lace.Event.Item'Class)
   is
      use lace.Event.utility;

      the_Event    : constant gel.Remote.World.sprite_added_Event := gel.Remote.World.sprite_added_Event (to_Event);
      the_Sprite   : constant gel.Sprite.view                     := my_Client.Applet.World.fetch_Sprite (the_Event.Sprite);
      new_Response : constant Sprite_clicked_Response_view        := new Sprite_clicked_Response;
   begin
      --  log ("'" & the_Sprite.Name & "' added.");

      --- Add a 'clicked' response to each newly added sprite.
      --
      new_Response.Sprite := the_Sprite;

      connect (the_Observer  =>  my_Client.Applet.local_Observer,
               to_Subject    =>  lace.Subject .view (the_Sprite),
               with_Response =>  lace.Response.view (new_Response),
               to_Event_Kind => +gel.Events.sprite_click_down_Event'Tag);
   end respond;


   the_Sprite_added_Response : aliased Sprite_added_Response;




   ------------------
   --- Space clicked.
   --

   type Space_clicked_Response is new lace.Response.item with null record;

   overriding
   procedure respond (Self : in out Space_clicked_Response;  to_Event : in lace.Event.Item'Class)
   is
      the_Event : constant gel.Events.space_click_down_Event := gel.Events.space_click_down_Event (to_Event);
   begin
      --  log ("Space clicked. " & the_Event.world_Site'Image);

      my_Client.target_Name.set_Label ("Ground");
      my_Client.target_Marker.Site_is (the_Event.world_Site);
      my_Client.Target := null;
   end respond;


   the_Space_clicked_Response : aliased Space_clicked_Response;




   ----------
   --- Setup.
   --

   procedure setup (Self : in out arcana.Client.local.item)
   is
      use lace.Event.utility;
   begin
      connect (the_Observer  =>  Self.Applet.local_Observer,
               to_Subject    =>  Self.Applet.Keyboard,
               with_Response =>  the_key_press_Response'Access,
               to_event_Kind => +gel.Keyboard.key_press_Event'Tag);

      connect (the_Observer  =>  Self.Applet.local_Observer,
               to_Subject    =>  Self.Applet.Keyboard,
               with_Response =>  the_key_release_Response'Access,
               to_event_Kind => +gel.Keyboard.key_release_Event'Tag);

      connect (the_Observer  =>  Self.Applet.local_Observer,
               to_Subject    =>  Self.client_World.all'Access,
               with_Response =>  the_Sprite_added_Response'Access,
               to_event_Kind => +gel.remote.World.sprite_added_Event'Tag);

      connect (the_Observer  =>  Self.Applet.local_Observer,
               to_Subject    =>  Self.Applet.all'Access,
               with_Response =>  the_Space_clicked_Response'Access,
               to_event_Kind => +gel.Events.space_click_down_Event'Tag);
   end setup;


end arcana.Client.local.Events;
