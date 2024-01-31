with
     launch_editor_Server,
     launch_editor_Client,

     ada.Characters.latin_1,
     ada.Text_IO,
     ada.Exceptions;


procedure launch_world_Editor
--
-- Starts the fused testbed.
--
is
   use ada.Text_IO;


   task Server
   is
      entry start;
   end Server;



   task Client
   is
      entry start;
   end Client;



   task body Server
   is
   begin
      accept start;
      launch_editor_Server;

   exception
      when E : others =>
         new_Line;
         put_Line ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
         put_Line ("launch_world_Editor.Server ~ Unhandled exception, aborting. Please report the following to developer.");
         put_Line ("_____________________________________________________________________________________________________");
         put_Line (ada.Exceptions.exception_Information (E));
         put (ada.Characters.latin_1.ESC & "[1A");   -- Move cursor up.
         put_Line ("_____________________________________________________________________________________________________");
         new_Line;
   end Server;



   task body Client
   is
   begin
      accept start;
      launch_editor_Client;

   exception
      when E : others =>
         new_Line;
         put_Line ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
         put_Line ("launch_world_Editor.Client ~ Unhandled exception, aborting. Please report the following to developer.");
         put_Line ("_____________________________________________________________________________________________________");
         put_Line (ada.Exceptions.exception_Information (E));
         put (ada.Characters.latin_1.ESC & "[1A");   -- Move cursor up.
         put_Line ("_______________________________________________________________________________________");
         new_Line;
   end Client;


begin
   Server.start;
   Client.start;

exception
   when E : others =>
      new_Line;
      put_Line ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
      put_Line ("launch_world_Editor ~ Unhandled exception, aborting. Please report the following to developer.");
      put_Line ("______________________________________________________________________________________________");
      put_Line (ada.Exceptions.exception_Information (E));
      put (ada.Characters.latin_1.ESC & "[1A");   -- Move cursor up.
      put_Line ("______________________________________________________________________________________________");
      new_Line;
end launch_world_Editor;
