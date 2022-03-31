-- Copyright 2012 Jo-Philipp Wich <jow@openwrt.org>
-- Licensed to the public under the Apache License 2.0.

local m, s

m = Map("cryptmanage", translate("Cryptmanage"),
	translate("This page allows you to configure the UUIDs and Names of encrypted drives for simple (un)locking and (u)mounting."))

s = m:section(TypedSection, "cryptdevice", "")
s.template = "cbi/tblsection"
s.anonymous = true
s.addremove = true

s:option(Value, "uuid", translate("Device UUID"),
         translate("The UUID of the device"))

s:option(Value, "name", translate("Device Name"),
         translate("A friendly name for the device"))

return m
