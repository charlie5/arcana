with
     arcana.Client;

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
   procedure shutdown;

end arcana.Server;
