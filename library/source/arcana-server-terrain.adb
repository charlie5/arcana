with
     gel.World.server,
     gel.Sprite,
     gel.Forge,
     gel.Events,

     openGL.Palette,
     openGL.IO,

     Physics,

     lace.Observer,
     lace.Subject,
     lace.Response,
     lace.Event.utility,
     lace.Text.forge,

     float_Math.random,

     system.RPC,

     ada.Exceptions,
     ada.Calendar,
     ada.Strings.unbounded,
     ada.Text_IO;


package body arcana.Server.Terrain
is
   use gel.World.server,
       openGL.Palette,
       ada.Strings.unbounded;

   use type Client.view;


   procedure set_up_Boulders (in_World : gel.World.view)
   is
      use openGL,
          gel.Math.Random;

      the_Boulders : constant openGL.Image    := openGL.IO.to_Image (openGL.to_Asset ("assets/terrain/boulders.png"));
      half_Width   : constant gel.Math.Real   := gel.Math.Real (the_Boulders'Length (1)) / 2.0;
      half_Height  : constant gel.Math.Real   := gel.Math.Real (the_Boulders'Length (2)) / 2.0;
      Counter      :          Natural         := 0;
      Color        :          openGL.rgb_Color;
      the_Boulder  :          gel.Sprite.view;

   begin
      for Row in the_Boulders'Range (1)
      loop
         for Col in the_Boulders'Range (2)
         loop
            Color := the_Boulders (Row, Col);

            if to_Color (Color) /= Black
            then
               Counter     := Counter + 1;
               the_Boulder := gel.Forge.new_circle_Sprite (in_World => in_World,
                                                           Name     => "Boulder ~" & Counter'Image,
                                                           Site     => [gel.Math.Real (Col) - half_Width  + random_Real (Lower => -0.25, Upper => 0.25),
                                                                        gel.Math.Real (Row) - half_Height + random_Real (Lower => -0.25, Upper => 0.25),
                                                                        0.0                               + random_Real (Lower => -0.01, Upper => 0.01)],     -- Prevent openGL from flipping visuals due to being all at same 'Z' position.
                                                           Mass     => 0.0,
                                                           Bounce   => 1.0,
                                                           Friction => 0.0,
                                                           Radius   => 0.5 + random_Real (Lower => -0.25, Upper => 0.25),
                                                           Texture  => openGL.to_Asset ("assets/rock.png"));
               in_World.add (the_Boulder);
            end if;
         end loop;
      end loop;

      ada.Text_IO.put_Line ("Boulder count:" & Counter'Image);
   end set_up_Boulders;



   procedure set_up_Trees (in_World : gel.World.view)
   is
      use openGL,
          gel.Math.Random;

      the_Trees    : constant openGL.Image    := openGL.IO.to_Image (openGL.to_Asset ("assets/terrain/trees.png"));
      Count        :          Natural         := 0;
      half_Width   : constant gel.Math.Real   := gel.Math.Real (the_Trees'Length (1)) / 2.0;
      half_Height  : constant gel.Math.Real   := gel.Math.Real (the_Trees'Length (2)) / 2.0;
      Color        :          openGL.rgb_Color;
      Counter      :          Natural         := 0;

      the_Tree     : gel.Sprite.view;

   begin
      for Row in the_Trees'Range (1)
      loop
         for Col in the_Trees'Range (2)
         loop
            Color := the_Trees (Row, Col);

            if to_Color (Color) /= Black
            then
               --  log ("Tree color:" & Color'Image);

               Counter  := Counter + 1;
               the_Tree := gel.Forge.new_circle_Sprite (in_World => in_World,
                                                        Name     => "Tree ~" & Counter'Image,
                                                        Site     => [gel.Math.Real (Col) - half_Width  + random_Real (Lower => -0.25, Upper => 0.25),
                                                                     gel.Math.Real (Row) - half_Height + random_Real (Lower => -0.25, Upper => 0.25),
                                                                     0.0                               + random_Real (Lower => -0.01 - 0.01, Upper => 0.01 - 0.01)],     -- Prevent openGL from flipping visuals due to being all at same 'Z' position.
                                                        Mass     => 0.0,
                                                        Bounce   => 1.0,
                                                        Friction => 0.0,
                                                        Radius   => 0.5 + random_Real (Lower => -0.25, Upper => 0.25),
                                                        Texture  => openGL.to_Asset ("assets/tree7.png"));
               in_World.add (the_Tree);
               Count := Count + 1;
            end if;
         end loop;
      end loop;

      ada.Text_IO.put_Line ("Tree count:" & Count'Image);
   end set_up_Trees;




end arcana.Server.Terrain;
