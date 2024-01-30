with
     arcana.Server,
     ada.Text_IO,
     ada.Exceptions,
     System.RPC;


package body arcana.Client.Network
is

   task body check_Server_lives
   is
      use ada.Text_IO;
      Done : Boolean := False;
      Self : arcana.Client.local.view;
   begin
      loop
         select
            accept start (Self : in arcana.Client.local.view)
            do
               check_Server_lives.Self := Self;
            end start;
         or
            accept halt
            do
               Done := True;
            end halt;
         or
            delay 15.0;
         end select;

         exit when Done;

         begin
            arcana.Server.ping;
         exception
            when system.RPC.communication_Error =>
               put_Line ("The Server has died. Press <Enter> to exit.");
               Self.Server_is_dead;
         end;
      end loop;

   exception
      when E : others =>
         new_Line;
         put_Line ("Error in 'check_Server_lives' task.");
         new_Line;
         put_Line (ada.exceptions.exception_Information (E));
   end check_Server_lives;


end arcana.Client.Network;
