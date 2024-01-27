with
     gel.World.server,
     lace.Response;


private
package arcana.Server.Responses
is

   procedure World_is (Now : in gel.World.server.view);



   type pc_move_Response is new lace.Response.item with
      record
         null;
      end record;

   overriding
   procedure respond (Self : in out pc_move_Response;   to_Event : in lace.Event.item'Class);

   the_pc_move_Response : aliased pc_move_Response;




   type pc_pace_Response is new lace.Response.item with null record;

   overriding
   procedure respond (Self : in out pc_pace_Response;   to_Event : in lace.Event.item'Class);

   the_pc_pace_Response : aliased pc_pace_Response;




   type pc_approaching_Response is new lace.Response.item with null record;

   overriding
   procedure respond (Self : in out pc_approaching_Response;   to_Event : in lace.Event.item'Class);

   the_pc_approaching_Response : aliased pc_approaching_Response;




   type target_ground_Response is new lace.Response.item with
      record
         null; -- targeting_Sprite : gel.sprite_Id;
      end record;

   overriding
   procedure respond (Self : in out target_ground_Response;   to_Event : in lace.Event.item'Class);

   the_target_ground_Response : aliased target_ground_Response;




   type target_sprite_Response is new lace.Response.item with
      record
         null; -- targeting_Sprite : gel.sprite_Id;
      end record;

   overriding
   procedure respond (Self : in out target_sprite_Response;   to_Event : in lace.Event.item'Class);

   the_target_sprite_Response : aliased target_sprite_Response;



end arcana.Server.Responses;
