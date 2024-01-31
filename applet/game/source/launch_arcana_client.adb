with
     arcana.Client.local,

     ada.Characters.latin_1,
     ada.command_Line,
     ada.Text_IO,
     ada.Exceptions;


procedure launch_arcana_Client
--
-- Starts an Arcana client.
--
is
   use ada.Text_IO;
begin
   -- Usage
   --
   if ada.command_Line.argument_Count /= 1
   then
      put_Line ("Usage:   $ ./launch_arcana_Client  <nickname>");
      return;
   end if;


   declare
      use arcana.Client.local;

      client_Name : constant String                   := ada.command_Line.Argument (1);
      the_Client  : aliased  arcana.Client.local.item := to_Client (client_Name);
   begin
      the_Client.open;
      the_Client.run;
   end;


   put_Line ("Closing client.");


exception
   when E : others =>
      new_Line;
      put_Line ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
      put_Line ("Unhandled exception, aborting. Please report the following to developer.");
      put_Line ("________________________________________________________________________");
      put_Line (ada.Exceptions.exception_Information (E));
      put (ada.Characters.latin_1.ESC & "[1A");                   -- Move cursor up.
      put_Line ("________________________________________________________________________");
      new_Line;
end launch_arcana_Client;
