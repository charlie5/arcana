with
     arcana.Client;


private
package arcana.Server.all_Clients
--
-- A singleton containing all of the servers clients.
-- Limited to a maximum of 5_000 arcana clients running at once.
--
is

   function  all_client_Info return client_Info_array;
   --  function  fetch           return arcana.Client.views;

   procedure add  (the_Client : in Client.view);
   procedure rid  (the_Client : in Client.view);

   function  Info (for_Client : in Client.view) return client_Info;

end arcana.Server.all_Clients;
