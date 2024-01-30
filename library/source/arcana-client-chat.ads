with
     lace.Text;


private
package arcana.Client.Chat
is

   protected chat_Messages
   is
      procedure add   (Message  : in String);

      procedure fetch (the_Messages : out lace.Text.items_256;
                       the_Count    : out Natural);

   private
      Messages : lace.Text.items_256 (1 .. 50);
      Count    : Natural := 0;
   end chat_Messages;


end arcana.Client.Chat;
