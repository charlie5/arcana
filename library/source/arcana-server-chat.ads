with
     lace.Text;

private
package arcana.Server.chat
is

   type client_message_Pair is
      record
         Client  : arcana.Client.view;
         Message : lace.Text.item_256;
      end record;

   type client_message_Pairs is array (Positive range <>) of client_message_Pair;



   protected chat_Messages
   is
      procedure add   (From     : in Client.view;
                       Message  : in String);

      procedure fetch (the_Messages : out client_message_Pairs;
                       the_Count    : out Natural);

   private
      Messages : client_message_Pairs (1 .. 50);
      Count    : Natural := 0;
   end chat_Messages;



   procedure add_Chat (From    : in Client.view;
                       Message : in String);


end arcana.Server.chat;
