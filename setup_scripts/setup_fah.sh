#!/usr/bin/bash

aurman -S foldingathome
/opt/fah/FAHClient --configure
systemctl enable foldingathome
systemctl start foldingathome
