# luci-app-cryptmanage
The application at hand adds a rudimentary interface to detecting and (u)mounting devices secured by means of LUKS. It is accessible through the "System" menu and subdivided into dashboard as well as settings tab.

## UCI Fields
```
cryptmanage
  cryptdevice
    uuid
    name
```
## Status
Please note: This application has been subjected to non-exhaustive internal tests and is therefore **not** cleared for productive use. Invoking cryptsetup requires super user privileges. Do not make it accessible to unprivileged users.

## Manual Updates
```opkg install https://github.com/resmh/luci-app-cryptmanage/releases/download/latest/luci-app-cryptmanage.ipk```

## Automatic Updates
Add repository, add repository key, update package lists and install:

```
echo 'src luci_app_cryptmanage https://github.com/resmh/luci-app-cryptmanage/releases/download/latest' >> /etc/opkg/customfeeds.conf; \
wget -O /tmp/luci_app_cryptmanage https://github.com/resmh/luci-app-cryptmanage/releases/download/latest/luci_app_cryptmanage.signify.pub; \
opkg-key add /tmp/luci_app_cryptmanage; \
rm /tmp/luci_app_cryptmanage; \
opkg update; \
opkg install luci-app-cryptmanage
```
