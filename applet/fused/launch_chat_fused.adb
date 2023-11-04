with
     launch_chat_Server,
     launch_chat_Client,

     ada.Characters.latin_1,
     ada.Text_IO,
     ada.Exceptions;


procedure launch_Chat_fused
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
      launch_chat_Server;

   exception
      when E : others =>
         new_Line;
         put_Line ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
         put_Line ("Server_fused ~ Unhandled exception, aborting. Please report the following to developer.");
         put_Line ("_______________________________________________________________________________________");
         put_Line (ada.Exceptions.exception_Information (E));
         put (ada.Characters.latin_1.ESC & "[1A");   -- Move cursor up.
         put_Line ("_______________________________________________________________________________________");
         new_Line;
   end Server;



   task body Client
   is
   begin
      accept start;
      launch_chat_Client;

   exception
      when E : others =>
         new_Line;
         put_Line ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
         put_Line ("Client_fused ~ Unhandled exception, aborting. Please report the following to developer.");
         put_Line ("_______________________________________________________________________________________");
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
      put_Line ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
      put_Line ("launch_Chat_fused ~ Unhandled exception, aborting. Please report the following to developer.");
      put_Line ("_______________________________________________________________________________________________");
      put_Line (ada.Exceptions.exception_Information (E));
      put (ada.Characters.latin_1.ESC & "[1A");   -- Move cursor up.
      put_Line ("________________________________________________________________________________________________");
      new_Line;
end launch_Chat_fused;
