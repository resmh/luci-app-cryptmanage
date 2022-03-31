module("luci.controller.cryptmanage", package.seeall)

function index()
	entry({"admin", "system", "cryptmanage"}, firstchild(), _("CryptManage"), 80).acl_depends = { "luci-app-cryptmanage" }
	entry({"admin", "system", "cryptmanage", "dashboard"}, template("cryptmanage"), _("Dashboard"), 1)
	entry({"admin", "system", "cryptmanage", "config"}, cbi("cryptmanage"), _("Configure"), 2)

	entry({"admin", "system", "cryptmanage", "mount"}, call("action_mount"), nil, 3).leaf = true

end

local function action_mount_command(devid, args)
	local argv = { }
	local uci = require "luci.model.uci".cursor()
	if devid == nil or devid == '' then
		argv[#argv+1] = "/sbin/cryptmanage.sh"
		return argv
		
	else
		if uci:get("cryptmanage", devid) == "cryptdevice" then
			local cryptdevice = uci:get_all("cryptmanage", devid)

			argv[#argv+1] = "/sbin/cryptmanage.sh"
			argv[#argv+1] = cryptdevice.uuid
			argv[#argv+1] = luci.http.urldecode(args)

			for i, v in ipairs(argv) do
				if v:match("[^%w%.%-i/|]") then
					argv[i] = '"%s"' % v:gsub('"', '\\"')
				end
			end

			return argv
		end
		
	end
end

function action_mount(...)
	local fs = require "nixio.fs"
	local argv = action_mount_command(...)
	if argv then
		local outfile = os.tmpname()
		local errfile = os.tmpname()

		local rv = os.execute(table.concat(argv, " ") .. " >%s 2>%s" %{ outfile, errfile })
		local stdout = fs.readfile(outfile, 1024 * 512) or ""
		local stderr = fs.readfile(errfile, 1024 * 512) or ""

		fs.unlink(outfile)
		fs.unlink(errfile)

		local binary = not not (stdout:match("[%z\1-\8\14-\31]"))

		return_json({
			ok       = true,
			command  = table.concat(argv, " "),
			stdout   = not binary and stdout,
			stderr   = stderr,
			exitcode = rv,
			binary   = binary
		})
	else
		return_json({
			ok       = false,
			code     = 404,
			reason   = "No such command"
		})
	end
end

function return_json(result)
	if result.ok then
		luci.http.prepare_content("application/json")
		luci.http.write_json(result)
	else
		luci.http.status(result.code, result.reason)
	end
end
