# Arcana
An online real-time multi-player medieval fantasy roleplaying game.


# Play Testing

Download the client tarball https://github.com/charlie5/arcana/releases/download/version_0.3.1-add_ground_sprite/client_tarball.tar.gz

Open /etc/hosts and ensure it contains a line with your WAN (www) net address, matched with your hostname (as defined in /etc/hostname).

     <your WAN ip address>    <your hostname>

Make sure port 5003 is open in any firewall and forwarded from your router to the box running the client.

Extract the client tarball.

Change directory into the extracted 'client_tarball' folder.

Finally, launch the client ...

     $ ./client_partition-x86_64.AppImage <character_name>