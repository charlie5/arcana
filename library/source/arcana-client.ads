with
     Gel,
     lace.Subject,
     lace.Observer;


package arcana.Client
--
-- Provides an interface to a arcana client.
--
is
   pragma remote_Types;

   type Item is  limited interface
             and lace.Subject .item
             and lace.Observer.item;

   type View  is access all Item'Class;
   type Views is array (Positive range <>) of View;


   procedure Server_has_shutdown (Self : in out Item) is abstract;
   procedure ping                (Self : in     Item) is null;

   function  as_Observer (Self : access Item) return lace.Observer.view is abstract;
   function  as_Subject  (Self : access Item) return lace.Subject .view is abstract;

   procedure pc_sprite_Id_is (Self : in out Item;   Now : in gel.sprite_Id) is abstract;
   function  pc_sprite_Id    (Self : in     Item)     return gel.sprite_Id  is abstract;

   procedure receive_Chat    (Self : in     Item;   Message : in String)    is abstract;


end arcana.Client;
