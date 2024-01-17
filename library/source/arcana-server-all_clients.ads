with
     arcana.Client;


private
package arcana.Server.all_Clients
--
-- A singleton containing all of the servers clients.
--
is

   function  fetch                              return arcana.Client.views;
   function  Info                               return client_Info_array;
   function  Info (for_Client : in Client.view) return client_Info;

   procedure add  (the_Client : in Client.view);
   procedure rid  (the_Client : in Client.view);


end arcana.Server.all_Clients;
