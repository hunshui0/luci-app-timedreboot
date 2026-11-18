m=Map("timedreboot",translate("Timed Reboot"),translate("Timed Reboot Setting. <a href=\"https://github.com/kongfl888/luci-app-timedreboot\">Github</a>"))

s=m:section(TypedSection,"main","")
s.addremove=false
s.anonymous=true

enable=s:option(Flag,"enable",translate("Enable"))
enable.rmempty = false
enable.default=0

hour=s:option(Value,"hour",translate("Hour"))
hour.datatype = "range(0,23)"
hour.rmempty = false

minute=s:option(Value,"minute",translate("Minute"))
minute.datatype = "range(0,59)"
minute.rmempty = false

local schedule = s:option(ListValue, "_schedule", translate("Reboot schedule"))
schedule:value("7", translate("Everyday"))
schedule:value("weekly", translate("Weekly"))
schedule:value("8", translate("Someday"))
schedule.rmempty = false

-- Keep daily, monthly and weekly schedules in the existing UCI option.
function schedule.cfgvalue(self, section)
    local value = self.map:get(section, "week")
    if value == "7" or value == "8" then
        return value
    end
    return "weekly"
end

function schedule.write(self, section, value)
    if value ~= "weekly" then
        return self.map:set(section, "week", value)
    end
end

local week = s:option(MultiValue, "week", translate("Week Day"))
week.template = "timedreboot/weekdays"
week:value(1,translate("Monday"))
week:value(2,translate("Tuesday"))
week:value(3,translate("Wednesday"))
week:value(4,translate("Thursday"))
week:value(5,translate("Friday"))
week:value(6,translate("Saturday"))
week:value(0,translate("Sunday"))
week.default = "6"
week.rmempty = false
week:depends("_schedule", "weekly")

function week.parse(self, section, novld)
    if schedule:formvalue(section) ~= "weekly" then
        return
    end
    local value = self:formvalue(section)
    if not novld and (not value or #value == 0) then
        self:add_error(section, "missing", translate("Select at least one weekday."))
        return
    end
    MultiValue.parse(self, section, novld)
end

day=s:option(Value,"sday",translate("Days of month"),translate("You also can use like this: 2,8,16 or 5-15."))
day.default=15
day.rmempty = true
day:depends("_schedule", "8")

once=s:option(Flag,"once",translate("Only once"))
once.rmempty = false
once.default=0

return m
