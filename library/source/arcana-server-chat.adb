with
     lace.Text.forge;


package body arcana.Server.chat
is

   protected body chat_Messages
   is
      procedure add   (From     : in Client.view;
                       Message  : in String)
      is
         use lace.Text.forge;
      begin
         Count := Count + 1;
         Messages (Count) := (Client => From,
                              Message => to_Text_256 (Message));
      end add;


      procedure fetch (the_Messages : out client_message_Pairs;
                       the_Count    : out Natural)
      is
      begin
         the_Messages (1 .. Count) := Messages (1 .. Count);
         the_Count                 := Count;
         Count                     := 0;
      end fetch;

   end chat_Messages;



   procedure add_Chat (From    : in Client.view;
                       Message : in String)
   is
   begin
      chat_Messages.add (From    => From,
                         Message => Message);
   end add_Chat;


end arcana.Server.chat;
