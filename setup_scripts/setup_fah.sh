#!/usr/bin/bash

yaourt -S foldingathome
/opt/fah/FAHClient --configure
systemctl enable foldingathome
systemctl start foldingathome
