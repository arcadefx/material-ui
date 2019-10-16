--====================================================================--
-- Module: database
-- 
--    Copyright (C) 2013-2017 Anedix Technologies, Inc.  All Rights Reserved.
--
-- License:
--
--
-- Overview: 
--
--    This module allows you to save to a database.
--
--
-- Usage:
--
--    local panel = require("database")
--
-- Examples:
--
--    myDatabase.open()
--    myDatabase.insert("players",{name="tommy",scoreint=25,mdate="now()",rowstate=1})
--    myDatabase.update("players",{name="tommy lee",scoreint=50,mdate="now()",rowstate=1},"name='tommy'")
--    myDatabase.query("SELECT * FROM players WHERE rowstate=1 LIMIT 1")
--    myDatabase.close()
--
-- Notice: 
--
--
--====================================================================--
--
local M = {}

M.myDB = nil
M.pagination = {}
M.databaseName = nil
M.version = 1.0

--function to remove table
function M.dropTable( tablename )
    if M.open() == false or tablename == nil then
        return false
    end
    
    local sql = string.format([[DROP TABLE IF EXISTS %s]], tablename)
    M.myDB:exec(sql)
    return true
end


-- method: exists
-- expects: tab as string
-- returns: true or false if table exists
function M.tableExist(tab)
  local ret = false  
  local sql = string.format([[SELECT count(name) as count FROM sqlite_master WHERE type='table' AND name='%s']],tab)

  if M.open() == false then return false end

  for total in M.myDB:urows(sql) do
    if total > 0 then ret = true end
  end  

  return ret
end


-- method: exec
-- expects: query
-- returns: nothing
function M.exec(query)
  if query == nil then return end
  if M.open() == false then return false end
  M.myDB:exec( query )
end


-- method: query
-- expects: string
-- returns: rows
function M.query( query )
  if M.open() == false then return {} end
  local result = {}
  
  -- if nothing to do
  if query == nil or (query ~=nil and query == "") then
    return result
  end

  local n = 1

  for row in M.myDB:nrows(query) do
    result[n] = {}
    result[n] = row
    n = n + 1
  end
  return result
end


function M.startPagination(name)
    if name == nil then return end
    M.pagination[name] = { total=0, from=0, per_page = 5, page_count=0, page=0 }
end


function M.removePagination(name)
    if name == nil then return end
    M.pagination[name] = nil
end


function M.getPagination(name)
    if name == nil then return end
    return M.pagination[name]
end


-- method: paginate
-- expects: table {}
-- returns: rows
function M.paginate( attr )
  local name = ""
  if M.open() == false or attr == nil then return {} end
  if attr.name == nil then
    print("paginate: Missing pagination name. Specify by { name = <string> } in options")
    return {}
  end
  name = attr.name
  if M.pagination[name] == nil then M.startPagination( name ) end

  local result = {}
  
  local query = attr.query
  local query_count = attr.query_count
  local direction = attr.direction or "next"
  local per_page = attr.per_page or 5
  local from = attr.from or 0
  local debug = attr.debug or false

  -- if nothing to do
  if (query == nil or (query ~=nil and query == "")) or (query_count == nil or (query_count ~=nil and query_count == "")) then
    return result
  end

  -- handle per_page
  M.pagination[name].per_page = per_page

  -- handle from
  if attr.from == nil then
    if direction == "next" then
      if M.pagination[name].page < M.pagination[name].page_count-1 then        
        M.pagination[name].from = (M.pagination[name].page + 1) * M.pagination[name].per_page
      end
    elseif direction == "prev" then
      if M.pagination[name].page > 0 then
        M.pagination[name].from = (M.pagination[name].page - 1) * M.pagination[name].per_page
      else
        M.pagination[name].from = 0
      end
    end
    from = M.pagination[name].from
  end

  -- query_count
  local total = 0

  for x in M.myDB:urows(query_count) do
    total = x
  end
  M.pagination[name].total = total

  -- query
  local limit = from .. ", " .. M.pagination[name].per_page 

  local n = 1

  if debug == true then print("paginate() query: ".. query .. " LIMIT " .. limit) end
  for row in M.myDB:nrows(query .. " LIMIT " .. limit) do
    result[n] = {}
    result[n] = row
    n = n + 1
  end

  from = math.min(from, total)
  
  M.pagination[name].from = from
  M.pagination[name].page_count = math.floor((total + M.pagination[name].per_page - 1) / M.pagination[name].per_page)
  M.pagination[name].page = math.floor(from / M.pagination[name].per_page)

  return result
end


-- method: clearResult
-- expects: table {}
-- returns: nothing
function M.clearResult( tab )
    if tab == nil or (tab ~= nil and (type(tab) ~= "table")) then return end
    for k,v in pairs(tab) do
        if (type(v) == "table") then
            for l, _ in pairs(v) do
                v[l] = nil
            end
        end
        tab[k]=nil 
    end
end

-- method: insert
-- expects: table name, sql w/ 1 insert or string with multiple inserts but requires 'rawmode' set to true
-- returns: array of {number of changes for insert, last row id inserted}
function M.insert(tab, data, rawmode)   

   if M.open() == false or tab == nil or data == nil then return {total=0, newid=0} end
   
   -- do some database calls...
   local count = 0
   local id = 0
   
   if rawmode == nil or rawmode == false then
     local sql = ""
     local fields = ""
     local values = ""
     
     for k,val in pairs(data) do
        if fields ~= "" then
            fields = fields .. ", "
        end
        fields = fields .. k

        if values ~= "" then
            values = values .. ", "
        end
        
        if type(val) == "number" then
            values = values .. "" .. val .. ""
        else
            -- check for current date using "now()" check
            if string.lower(val) == "now()" then
                values = values .. "date('now')"
            else
                values = values .. "'" .. val .. "'"
            end
        end
     end
     sql = "INSERT INTO " .. tab .. " (id, " .. fields .. ") VALUES (NULL," .. values ..  ");"
     M.myDB:exec(sql)
     --print("M.myDB:changes()=",M.myDB:changes())
     --print("INSERT WITH DATA AND PARMS:",sql)
   else
      if type(data) == "string" then
        db:exec(data)
      end
   end
   
   count = M.myDB:changes() 
   id = M.myDB:last_insert_rowid()
   
   return {total=count, newid=id}
end


-- method: update
-- expects: sql w/ 1 update
-- returns: db:changes() or number of changes for update
function M.update(tab, data, where, rawmode)   

   if M.open() == false or tab == nil or data == nil then return 0 end
   
   -- do some database calls...
   local count = 0
   
   if rawmode == nil or rawmode == false then
     local sql = ""
     
     for k,val in pairs(data) do
        if sql ~= "" then
            sql = sql .. ", "
        end
        
        if type(val) == "number" then
            sql = sql .. k .. "=" .. val .. ""
        else
            -- check for current date using "now()" check
            if string.lower(val) == "now()" then
                sql = sql .. k .. "=date('now')"
            else
                sql = sql .. k .. "='" .. val .. "'"
            end
        end
     end
     if where ~= nil and type(where) == "string" then
        sql = sql .. " WHERE " .. where
     end
     sql = "UPDATE " .. tab .. " SET " .. sql .. ";"
     M.myDB:exec(sql)
   else
      if type(data) == "string" then
        M.myDB:exec(data)
      end
   end
   
   count = M.myDB:changes() 
   
   return count
end


-- method: delete
-- expects: sql w/ 1 delete
-- returns: db:changes() or number of changes for delete
function M.delete(tab, where)   

   if tab == nil or where == nil then
     return 0
   end
   
   if tab == "" or where == "" then
     return 0
   end
   
   if M.open() == false then return 0 end

   local count = 0
   
   M.myDB:exec("DELETE FROM " .. tab .. " WHERE " .. where .. ";")

   count = M.myDB:changes() 
      
   return count
end


-- method: open
-- expects: database name
-- returns: true or false if successful
function M.open(db)
  local ret = false

  if M.myDB ~= nil and M.myDB:isopen() == true then
    return true
  end

    if db == nil then
        db = M.databaseName
    end

  if db ~= nil then
    local path = system.pathForFile( db .. ".db", system.DocumentsDirectory )
    M.myDB = sqlite3.open(path)
    if M.myDB == nil then
        ret = false
    else
        M.databaseName = db
        ret = true
    end
  end
  
  return ret
end


-- method: close
-- expects: nothing
-- returns: nothing
function M.close()
    if M.myDB ~= nil and M.myDB:isopen() == true then
        M.myDB:close()  -- close
    end
end

return M
