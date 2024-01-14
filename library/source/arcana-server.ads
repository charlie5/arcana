with
     arcana.Client,
     gel.remote.World,
     lace.Event;


package arcana.Server
--
-- A singleton providing the central arcana server.
-- Limited to a maximum of 5_000 arcana clients running at once.
--
is
   pragma remote_Call_interface;

   Name_already_used : exception;

   procedure   register (the_Client : in Client.view);
   procedure deregister (the_Client : in Client.view);

   function  all_Clients return arcana.Client.views;

   procedure ping;
   procedure start;
   procedure shutdown;


   function World return gel.remote.World.view;



   type move_Direction is (Forward, Backward, Left, Right);

   type pc_move_Event is new lace.Event.item with
      record
         sprite_Id : gel.sprite_Id;
         Direction : move_Direction;
         On        : Boolean;            -- When On start moving, else stop moving.
      end record;


   type pc_pace_Event is new lace.Event.item with
      record
         sprite_Id : gel.sprite_Id;
         Pace      : arcana.Pace_t;
      end record;


   procedure add_Chat (From    : in Client.view;
                       Message : in String);


end arcana.Server;
