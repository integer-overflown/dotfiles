--- This monstrosity of the code only exists to overcome the limitation of
--- the codelldb adapter/DAP layer for the adapter.
--- codelldb requires the port to be passed, which forces one to select
--- a particular value in the config.
--- This breaks with an "address in use" type of error when attempting to launch
--- another session from the same neovim instance or even a different one (since
--- it still tries to use the same port from the configuration)
---
--- This module implements port-tracking using a form of an IPC.
--- The approach is simple: there is a state file that contains the port number.
--- Each instance of neovim that sources this config will read the file, parse the
--- port number, and select the next port. Then, the file is updated to have the
--- incremented port number, so that the next process starts from there.
---
--- The file updates are guarded by a fcntl exclusive lock to avoid concurrent updates
--- and resource races.
---
--- Note that fcntl guards a separate lock file, not the port file itself.
--- This specifically covers the case when the port file does not yet exist.
--- If we were guarding the port file, there would be ambiguity when creating a port file
--- from multiple processes, and the error management would be quite tricky, as well as trying
--- to point multiple processes to the same file.
---
--- With a separate lock file, we only care that it exists.
--- Whatever process creates it first has it.
--- The others would just use that file if it has already been created.
---
--- HACK:
--- I must say, I hate this approach and the fact that so much code is needed to overcome
--- a fairly basic problem.
--- Ideally, codelldb would auto-select ports as any other debug adapter does.
--- Not sure why they removed port auto-selection in the newer versions, but until this
--- is resolved in dap/codelldb or I find a bizarre, well-hidden and undocumented way
--- of doing this, preserved in secrecy and passed verbally between generations of
--- open-source community members as the legends of old, I'm sticking with this insanity.
--- It was fun to write tho.
local M = {}

local DEFAULT_PORT = 25000
local FILE_NAME = vim.fn.stdpath("state") .. "/codelldb_port"
local LOCK_NAME = vim.fn.stdpath("state") .. "/codelldb_port.lock"

local function read_port(lock_fd)
  local log = require("utils.log")

  local nio = require("nio")
  local fcntl = require("posix.fcntl")

  log.debug("Reading a codelldb port, lock_fd:", lock_fd)

  -- place an exclusive lock on the lock file
  local flag = fcntl.fcntl(lock_fd, fcntl.F_SETLKW, {
    l_type = fcntl.F_WRLCK,
    l_whence = fcntl.SEEK_SET,
    l_start = 0,
    l_len = 0,
  })

  if flag ~= nil then
    log.error("File lock has failed")
    return DEFAULT_PORT
  end

  local err, fd = nio.uv.fs_open(FILE_NAME, "a+", 600)

  if err ~= nil then
    log.error("Cannot open the port file:", err)
    return DEFAULT_PORT
  end

  local stat_err, stat = nio.uv.fs_fstat(fd)
  assert(not stat_err, stat_err)

  local err, data = nio.uv.fs_read(fd, stat.size, 0)

  if err ~= nil then
    log.error("Cannot read the port file:", err)
    nio.uv.fs_close(fd)
    return DEFAULT_PORT
  end

  local port = data:len() > 0 and tonumber(data) or DEFAULT_PORT

  if not port then
    log.error("Invalid port:", data)
    nio.uv.fs_close(fd)
    return DEFAULT_PORT
  end

  local err, _ = nio.uv.fs_ftruncate(fd, 0)

  if err ~= nil then
    log.error("Failed to truncate file")
    -- try to continue anyway
  end

  local err, _ = nio.uv.fs_write(fd, tostring(port + 1), 0)

  if err ~= nil then
    log.error("Failed to update the port value:", err)
    nio.uv.fs_close(fd)
    return DEFAULT_PORT
  end

  flag = fcntl.fcntl(lock_fd, fcntl.F_SETLKW, {
    l_type = fcntl.F_UNLCK,
    l_whence = fcntl.SEEK_SET,
    l_start = 0,
    l_len = 0,
  })

  assert(flag == 0, "Unclock failed: " .. flag)

  log.debug("codelldb port:", port)

  nio.uv.fs_close(fd)
  return port
end

M.get_codelldb_port = function()
  local log = require("utils.log")
  log.debug("get_codelldb_port")

  local nio = require("nio")

  -- open or create a lock file if one does not exist ("w" flag behaviour)
  -- the file is always empty, we don't care about the contents
  -- it only matters that it exists in the filesystem
  local lock_err, lock_fd = nio.uv.fs_open(LOCK_NAME, "w", 600)

  if lock_err then
    log.error("lock error:", lock_err)
    return DEFAULT_PORT
  end

  log.debug("Opened the lock file")

  nio.uv.fs_close(lock_fd)
  return read_port(lock_fd)
end

return M
