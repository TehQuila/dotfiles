#!/usr/bin/bash

yaourt -S foldingathome
echo "User: TehQuila"
echo "Passkey: d35d3f263c8851e4adee9da93a9630f7"
echo "Arch Team: 230686"
/opt/fah/FAHClient --configure
systemctl start foldingathome
systemctl enable foldingathome
