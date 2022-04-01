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
- Add releases to your ```/etc/opkg/customfeeds.conf```:

```src luci_app_cryptmanage https://github.com/resmh/luci-app-cryptmanage/releases/download/latest```

- Upload ```luci_app_cryptmanage.signify.pub``` from this repository to a temporary location

```/tmp/luci_app_cryptmanage.signify.pub```

- Associate key with opkg

```opkg-key add /tmp/luci_app_cryptmanage.signify.pub```

- Delete temporary file, call ```opkg update``` and finally ```opkg install luci-app-cryptmanage```
