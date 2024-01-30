with
     arcana.Client.local;


private
package arcana.Client.Network
is

   task check_Server_lives
   is
      entry start (Self : in arcana.Client.local.view);
      entry halt;
   end check_Server_lives;


end arcana.Client.Network;
