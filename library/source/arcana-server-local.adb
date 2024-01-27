
package body arcana.Server.local
is

   the_World : gel.World.server.view;


   procedure World_is (Now : in gel.World.server.view)
   is
   begin
      the_World := Now;
   end World_is;


end arcana.Server.local;
