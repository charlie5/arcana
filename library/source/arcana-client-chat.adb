with
     lace.Text.forge;


package body arcana.Client.Chat
is

   protected body chat_Messages
   is
      procedure add (Message : in String)
      is
         use lace.Text.forge;
      begin
         Count            := Count + 1;
         Messages (Count) := to_Text_256 (Message);
      end add;



      procedure fetch (the_Messages : out lace.Text.items_256;
                       the_Count    : out Natural)
      is
      begin
         the_Messages (1 .. Count) := Messages (1 .. Count);
         the_Count                 := Count;
         Count                     := 0;
      end fetch;

   end chat_Messages;


end arcana.Client.Chat;
