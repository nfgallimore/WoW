--
-- Tools for Unit Tests
--
-- Intended to be used for unit testing WoW addons.
--
-- !!WARNING!!  Do not include in any WoW addon .toc file.  !!WARNING!!
--
-- (c) Fitzcairn of Cenarion Circle
-- fitz.wowaddons@gmail.com


-- Get current working directory for require path (from lua-users.org)
function getcwd()
   local pipe = io.popen('cd', 'r')
   local cdir = pipe:read('*l')
   pipe:close()
   return cdir
end

-- Given a .toc file, load all files listed in order.
function LoadForUnitTest(toc_file)
   -- Pull in contents of TOC file and load.
   local fh = io.open(toc_file,"r")
   while true do
      line = fh.read(fh)
      if not line then break end
      if string.match(line, ".lua") then
         require(string.match(line, "^(.+)%.lua"))
      end
   end
   fh:close()
end

