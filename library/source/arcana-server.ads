with
     arcana.Client,
     gel.remote.World,
     lace.Event;

private
with
     lace.Observer,
     lace.Subject,
     ada.Strings.unbounded;


package arcana.Server
--
-- A singleton providing the central arcana server.
-- Limited to a maximum of 5_000 arcana clients running at once.
--
is
   pragma remote_call_Interface;


   procedure open;
   procedure run;
   procedure close;


   ------------
   --- Clients.
   --
   Name_already_used : exception;

   procedure   register (the_Client : in Client.view);
   procedure deregister (the_Client : in Client.view);

   function  fetch_all_Clients return arcana.Client.views;

   procedure ping;


   -------------------------------------------
   --- Client access to the servers Gel world.
   --
   function  World return gel.remote.World.view;



   -------------
   --- Movement.
   --

   type move_Direction is (Forward, Backward, Left, Right);

   type pc_move_Event is new lace.Event.item with
      record
         sprite_Id : gel.sprite_Id;
         Direction : move_Direction;
         On        : Boolean;            -- When 'On' then run moving, else stop moving.
      end record;


   type pc_pace_Event is new lace.Event.item with
      record
         sprite_Id : gel.sprite_Id;
         Pace      : arcana.Pace_t;
      end record;



   -------------
   --- Targeting
   --

   type target_ground_Event is new lace.Event.item with
      record
         sprite_Id   : gel.sprite_Id;         -- The sprite which has targeted the ground.
         ground_Site : gel.math.Vector_3;     -- Site where the ground has been targeted.
      end record;



   ---------
   --- Chat.
   --

   procedure add_Chat (From    : in Client.view;
                       Message : in String);


   private

   use ada.Strings.unbounded;


   -----------
   --- Clients
   --

   type client_Info is
      record
         Client       : arcana.Client.view;
         Name         : unbounded_String;
         as_Observer  : lace.Observer.view;
         as_Subject   : lace.Subject .view;
         pc_sprite_Id : gel.sprite_Id;
      end record;

   type client_Info_array is array (Positive range <>) of client_Info;

   max_Clients : constant := 5_000;



   -----------
   --- Sundry.
   --

   function "+" (From : in ada.Strings.unbounded.unbounded_String) return String
                 renames ada.Strings.unbounded.to_String;

   procedure log (Message : in String := "");


end arcana.Server;
