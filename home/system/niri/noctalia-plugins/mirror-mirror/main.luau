--!nonstrict
-- Service entry: owns the wl-mirror process, ports Main.qml from the v4
-- plugin. Entries are separate VMs, so the panel talks to this service
-- through noctalia.state: the panel publishes a "cmd" table, the service
-- publishes mirroring/error status back.

local mirroring = false
local lastError = ""

local function shellQuote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function publish()
  noctalia.state.set("mirroring", mirroring)
  noctalia.state.set("error", lastError)
end

-- Ports isIgnorableWlMirrorLine / isBackendAttemptFailureLine from Main.qml:
-- wl-mirror logs backend fallback probes to stderr that are not real errors.
local function isIgnorableWlMirrorLine(line)
  local normalized = noctalia.string.trim((line or ""):lower())
  if normalized == "" then
    return true
  end
  return normalized:find("mirror%-extcopy::init%(%): missing ext_image_copy_capture protocol", 1, false) ~= nil
    or normalized:find("mirror::auto_backend_fallback%(%):", 1, false) ~= nil
end

local function isBackendAttemptFailureLine(line)
  local normalized = noctalia.string.trim((line or ""):lower())
  if normalized == "" then
    return false
  end
  return (normalized:find("failed", 1, true) ~= nil and normalized:find("backend", 1, true) ~= nil)
    or (normalized:find("missing", 1, true) ~= nil and normalized:find("protocol", 1, true) ~= nil)
    or (normalized:find("no supported", 1, true) ~= nil and normalized:find("backend", 1, true) ~= nil)
end

local function startMirror(source, destination)
  if mirroring then
    lastError = noctalia.tr("main.error.alreadyMirroring")
    publish()
    return
  end
  if source == "" or destination == "" then
    lastError = noctalia.tr("main.error.selectBothMonitors")
    publish()
    return
  end
  if source == destination then
    lastError = noctalia.tr("main.error.sameMonitor")
    publish()
    return
  end

  lastError = ""
  mirroring = true
  noctalia.state.set("source", source)
  noctalia.state.set("destination", destination)

  -- Shell string form: stderr must be merged into stdout, since runStream
  -- only delivers stdout lines.
  noctalia.runStream(
    "wl-mirror --fullscreen-output "
      .. shellQuote(destination)
      .. " "
      .. shellQuote(source)
      .. " 2>&1",
    function(line)
      if isIgnorableWlMirrorLine(line) then
        return
      end
      if isBackendAttemptFailureLine(line) then
        lastError = noctalia.tr("main.error.noCompatibleBackend")
        publish()
        return
      end
      local msg = noctalia.string.trim(line)
      if msg ~= "" then
        lastError = msg
        publish()
      end
    end
  )
  publish()
end

local function stopMirror()
  if not mirroring then
    return
  end
  noctalia.runAsync("pkill -x wl-mirror 2>/dev/null")
  -- update() reconciles mirroring with the real process state within a second.
end

noctalia.state.watch("cmd", function(cmd)
  if type(cmd) ~= "table" or cmd.seq == nil then
    return
  end
  if cmd.action == "start" then
    startMirror(tostring(cmd.source or ""), tostring(cmd.destination or ""))
  elseif cmd.action == "stop" then
    stopMirror()
    publish()
  end
end)

noctalia.setUpdateInterval(1000)

function update()
  -- Reconcile with reality: wl-mirror can exit on its own (monitor unplug,
  -- crash), and pkill from outside the plugin also has to be picked up.
  noctalia.processMatches(function(matched)
    if matched ~= mirroring then
      mirroring = matched
      publish()
    end
  end, "wl-mirror")
end

function onExit(_signal, _reason)
  -- Don't leave a mirror session behind when the plugin stops or reloads.
  if mirroring then
    noctalia.runAsync("pkill -x wl-mirror 2>/dev/null")
  end
end

publish()
