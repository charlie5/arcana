with
     Chat.Server,
     ada.Exceptions,
     ada.Characters.latin_1,
     ada.Text_IO;


procedure launch_chat_Server
--
-- Launches the Chat server.
--
is
   use ada.Text_IO;
begin
   loop
      declare
         Command : constant String := get_Line;
      begin
         exit when Command = "q";
      end;
   end loop;

   put_Line ("Shutting down.");
   Chat.Server.shutdown;

exception
   when E : others =>
      new_Line;
      put_Line ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
      put_Line ("Unhandled exception, aborting. Please report the following to developer.");
      put_Line ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
      put_Line (ada.Exceptions.exception_Information (E));
      put (ada.Characters.latin_1.ESC & "[1A");   -- Move cursor up.
      put_Line ("________________________________________________________________________");
      new_Line;
end launch_chat_Server;
