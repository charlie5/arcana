with
     arcana.Server.all_Clients,

     ada.Text_IO,
     ada.Exceptions,

     System.RPC;


package body arcana.Server.Network
is

   task body check_Client_lives
   is
      use ada.Text_IO;
      Done : Boolean := False;

   begin
      loop
         select
            accept halt
            do
               Done := True;
            end halt;
         or
            delay 15.0;
         end select;


         exit when Done;


         declare
            all_Info : constant arcana.Server.client_Info_array := arcana.Server.all_Clients.Info;
         begin
            for Each of all_Info
            loop
               begin
                  Each.Client.ping;
               exception
                  when system.RPC.communication_Error
                     | storage_Error =>

                     log (+Each.Name & " has died.");
                     deregister (Each.Client);
               end;
            end loop;
         end;

      end loop;

   exception
      when E : others =>
         new_Line;
         put_Line ("Error in check_Client_lives task.");
         new_Line;
         put_Line (ada.Exceptions.exception_Information (E));
   end check_Client_lives;


end arcana.Server.Network;
