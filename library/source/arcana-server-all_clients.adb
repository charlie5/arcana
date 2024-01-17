package body arcana.Server.all_Clients
is

   use type Client.view;


   protected safe_Clients
   is
      procedure add (the_Client : in Client.view);
      procedure rid (the_Client : in Client.view);

      function  all_client_Info return client_Info_array;
      function  Info (for_Client : in Client.view) return client_Info;

   private
      Clients : client_Info_array (1 .. max_Clients);
   end safe_Clients;



   protected body safe_Clients
   is
      procedure add (the_Client : in Client.view)
      is
         function "+" (From : in String) return unbounded_String
           renames to_unbounded_String;
      begin
         for i in Clients'Range
         loop
            if Clients (i).Client = null
            then
               Clients (i).Client       :=  the_Client;
               Clients (i).Name         := +the_Client.Name;
               Clients (i).as_Observer  :=  the_Client.as_Observer;
               Clients (i).as_Subject   :=  the_Client.as_Subject;
               Clients (i).pc_sprite_Id :=  the_Client.pc_sprite_Id;
               return;
            end if;
         end loop;
      end add;


      procedure rid (the_Client : in Client.view)
      is
      begin
         for i in Clients'Range
         loop
            if Clients (i).Client = the_Client then
               Clients (i).Client := null;
               return;
            end if;
         end loop;

         raise Program_Error with "Unknown client.";
      end rid;


      function all_client_Info return client_Info_array
      is
         Count  : Natural := 0;
         Result : client_Info_array (1 .. max_Clients);
      begin
         for i in Clients'Range
         loop
            if Clients (i).Client /= null
            then
               Count          := Count + 1;
               Result (Count) := Clients (i);
            end if;
         end loop;

         return Result (1 .. Count);
      end all_client_Info;


      function Info (for_Client : in Client.view) return client_Info
      is
      begin
         for i in Clients'Range
         loop
            if Clients (i).Client = for_Client
            then
               return Clients (i);
            end if;
         end loop;

         raise program_Error with "Unknown client.";
      end Info;


   end safe_Clients;




   function Info return client_Info_array
   is
   begin
      return safe_Clients.all_client_Info;
   end Info;



   function Info (for_Client : in Client.view) return client_Info
   is
   begin
      return safe_Clients.Info (for_Client);
   end Info;



   procedure add (the_Client : in Client.view)
   is
   begin
      safe_Clients.add (the_Client);
   end add;



   procedure rid (the_Client : in Client.view)
   is
   begin
      safe_Clients.rid (the_Client);
   end rid;




   function fetch return arcana.Client.views
   is
      all_Info : constant client_Info_array := safe_Clients.all_client_Info;
      Result   :          arcana.Client.views (all_Info'Range);
   begin
      for i in Result'Range
      loop
         Result (i) := all_Info (i).Client;
      end loop;

      return Result;
   end fetch;


end arcana.Server.all_Clients;
