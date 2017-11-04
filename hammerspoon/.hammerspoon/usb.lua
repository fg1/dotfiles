local logger = hs.logger.new('usb', 'debug')
local watcher = require "hs.usb.watcher"
local notify = require "hs.notify"

local mod = {}

function switchKbLayout()
	if mod.usbKbPresent then
		hs.keycodes.setLayout(mod.usbKbLayout)
	else
		hs.keycodes.setLayout(mod.defaultLayout)
	end
end

function usbDeviceCallback(data)
	if (data.productID == mod.usbKbProductID) and (data.vendorID == mod.usbKbVendorID) then
        if (data.eventType == "added") then
			logger.d("USB keyboard connected")
            mod.usbKbPresent = true
        elseif (data.eventType == "removed") then
			logger.d("USB keyboard removed")
            mod.usbKbPresent = false
        end
		switchKbLayout()
    end
end

function mod.init(usbKbVendorID, usbKbProductID, usbKbLayout, defaultLayout)
    mod.usbKbPresent = false
    mod.usbKbVendorID = usbKbVendorID
    mod.usbKbProductID = usbKbProductID
    mod.usbKbLayout = usbKbLayout
    mod.defaultLayout = defaultLayout

	usb_table = hs.usb.attachedDevices()
	for _, dev in pairs(usb_table) do
		if (dev.productID == mod.usbKbProductID) and (dev.vendorID == mod.usbKbVendorID) then
			mod.usbKbPresent = true
			break
		end
	end
	switchKbLayout()

	usbWatcher = hs.usb.watcher.new(usbDeviceCallback)
	usbWatcher:start()
end

return mod
