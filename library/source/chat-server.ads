with
     Chat.Client;

package Chat.Server
--
-- A singleton providing the central chat server.
-- Limited to a maximum of 5_000 chat clients running at once.
--
is
   pragma remote_Call_interface;

   Name_already_used : exception;

   procedure   register (the_Client : in Client.view);
   procedure deregister (the_Client : in Client.view);

   function  all_Clients return Chat.Client.views;

   procedure ping;
   procedure shutdown;

end Chat.Server;
