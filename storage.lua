--====================================================================--
-- Module: storage
-- 
--    Copyright (C) 2013-2015 Anedix Technologies, Inc.  All Rights Reserved.
--
-- License:
--
--
-- Overview: 
--
--    This module allows you to save game information and history.
--
--
-- Usage:
--
--    local storage = require("storage")
--
--
-- Notice: 
--
--
--====================================================================--
--
local M = {}

M.filter = ""
M.orderby = ""
M.groupby = ""
M.searchResults = { tm=0, total=0, from=0, to=0, per_page = 5, page_count=0, page=0, method=nil, query="", filter=false, query="" }
M.pageinate_anim = false
M.callback = nil
M.callbackParms = {}
M.callbackTeamObj = nil
M.callbackDtype = nil
M.entryId = 0
M.entryPos = 0
M.mode = "insert"


M.game = {
	id=0,
	name="QUICKPLAY",
	gametype=0,
	mdate=0,
	edate=0,
	rowstate=1
}

M.team = {
	id=0,
	name="",
	mdate=0,
	rowstate=1
}

M.record = { 
	id=0,
    name="", 
	team=0,
	scoreint=0,
	scoreflt=0.0,
	scoretyp=0,
	gameid=0,
	color="grey",
	mdate=0,
	rowstate=1
}

M.log = {
	id=0,
    name="", 
	player=0,
	team=0,
	scoreint=0,
	scoreflt=0.0,
	scoretyp=0,
	gameid=0,
   gametype=0,
	color="grey",
	mdate=0,
	rowstate=1
}


M.settings = {
	id=0,
	name="NONE",
	value="EMPTY",
	rowstate=1
}


-- method: init
-- expects: nothing
-- returns: nothing
function M.init()
  if myDevice ~= nil then
    M.searchResults.per_page = myDevice.basePerPage
  end
end


function M.setPerPage(value)
   if value ~= nil then
     M.searchResults.per_page = tonumber(value)
     myDevice.basePerPage = M.searchResults.per_page
   end
end


-- method: firstSceneVisit
-- expects: nothing
-- returns: true/false if user has viewed the scene already
function M.firstSceneVisit(scene_name)

  local total = 0
  local return_val
  local sql = ""
  
  if scene_name == nil then return false end
  
  myDatabase.open()

  sql = "select count(*) from settings where name='"..scene_name.."' and rowstate < 999"
  for x in myDatabase.myDB:urows(sql) do 
     total = x
  end

  if total == nil or total < 1 then
    name = scene_name
    value = 1
    myDatabase.insert("settings",{name=name,value=1,rowstate=1})
    return_val = true
  else    
    return_val = false
  end

  myDatabase.close()
  
  return return_val
end


-- method: resetFilter
-- expects: nothing
-- returns: nothing
function M.resetFilter()
	M.filter = ""
	M.orderby = ""
	M.groupby = ""
end


function M.saveGame(name, game_type)
  if name == nil then return end
  
  myDatabase.open()
  
  local total = 0
  sql = "SELECT count(*) FROM game WHERE id=" .. GameSettings.gameid
  for x in myDatabase.myDB:urows(sql) do 
    total = x
  end
  
  if total < 1 then
  	 local res = myDatabase.insert("game",{name=name,gametype=game_type,mdate="now()",rowstate=1})
	 if res.newid > 0 then
	   M.game.id = res.newid
      GameSettings.gameid = res.newid
      GameSettings.name = name
      GameSettings.gametype = game_type
      GameSettings.count = 0
	  end
  else
		res = myDatabase.update("game",{mdate="now()",name=name,rowstate=1},"id=" .. GameSettings.gameid)
      GameSettings.name = name
  end
  myDatabase.close()
  
  return GameSettings.gameid
end


-- method: startGame
-- expects: nothing
-- returns: nothing
function M.startGame()
  myDatabase.open()
  
  if M.game.id == 0 then
	M.game.type = GameSettings.gametype
	M.game.name = GameSettings.name
	--print("GAME",GameSettings.name,"TYPE",GameSettings.gametype,M.game.type)
	-- ask database for new id
	local res = myDatabase.insert("game",{name=M.game.name,gametype=M.game.type,mdate="now()",rowstate=1})
	if res.newid > 0 then
	  M.game.id = res.newid
	end
  end

  myDatabase.close()

  return M.game.id  
end


-- method: endGame
-- expects: nothing
-- returns: nothing
function M.endGame(attr)
  myDatabase.open()
  
  local endAllGames = false
  if attr ~= nil then
	if attr.endAll == true then endAllGames = true end
  end
  
  local res
  if GameSettings.gameid > 0 then
	-- end the game
	if endAllGames == false then
		res = myDatabase.update("game",{edate="now()",rowstate=2},"id=" .. GameSettings.gameid)
	else
		res = myDatabase.update("game",{edate="now()",rowstate=2},"rowstate=1")
	end
	--print("END THEGAME=", res)
  end
  
  myDatabase.close()
end


-- method: lastGame
-- expects: nothing
-- returns: nothing
function M.lastGame()
  local res = 0
  
  myDatabase.open()
  
  local gamesql=""
  if StartGameHistory == true then
    gamesql = " AND id="..GameHistoryId.." "
    StartGameHistory = false
  end
  local sql = "SELECT id,name,gametype FROM game WHERE id > 0 AND rowstate=1 "..gamesql.." ORDER BY id DESC LIMIT 1"
  for id,name,gametype in myDatabase.myDB:urows(sql) do 
	GameSettings.gameid = id
	GameSettings.name = name
	GameSettings.gametype = gametype
   --print("gametype="..gametype.." for name: "..name.." id="..id)
    res = id
  end
  -- if game exist
  if res > 0 then
	-- remove prior friends
	for i=0, #GameSettings.player do
		table.remove(GameSettings.player)
	end

	-- remove prior team
	for i=0, #GameSettings.team do
		table.remove(GameSettings.team)
	end
	if GameSettings.gametype == 1 or GameSettings.gametype == 3 then -- individual
		sql = "SELECT player FROM gamelog WHERE gameid=" .. GameSettings.gameid .. " and rowstate=1"
		for player in myDatabase.myDB:urows(sql) do 
			table.insert(GameSettings.player, player)
		end
	elseif GameSettings.gametype == 2 then -- team
		sql = "SELECT DISTINCT team FROM gamelog WHERE gameid=" .. GameSettings.gameid .. " and rowstate=1"
		for team in myDatabase.myDB:urows(sql) do 
			table.insert(GameSettings.team, team)
		end	
	end
  end
  -- WAIT CHECK AbOve iF statements for gametype == 3 too!
  
  myDatabase.close()
  
  return res
end


-- method: resumeGame
-- expects: nothing
-- returns: nothing
function M.resumeGame()

  myDatabase.open()

  if M.game.id > 0 then
	-- resume the game
  end
  
  myDatabase.close()
  
end

-- method: playersExist
-- expects: nothing
-- returns: true/false
function M.playersExist()

  local total = 0
  local return_val
  myDatabase.open()

   sql = "SELECT count(*) FROM players WHERE rowstate=1"
   for x in myDatabase.myDB:urows(sql) do 
      total = x
   end
   
  myDatabase.close()
  
  if total == nil or total < 1 then
    return_val = false
  else
    return_val = true
  end

  M.dialogResult("Need Players")
  
  return return_val

end


-- method: teamsExist
-- expects: nothing
-- returns: true/false
function M.teamsExist()

  local total = 0
  local return_val
  myDatabase.open()

   sql = "SELECT count(*) FROM team WHERE rowstate=1"
   for x in myDatabase.myDB:urows(sql) do 
      total = x
   end

  myDatabase.close()

  if total == nil or total < 1 then
    return_val = false
  else
    return_val = true
  end
  
  M.dialogResult("Need Teams")
  
  return return_val

end


-- method: teamsAndPlayersExist
-- expects: nothing
-- returns: true/false
function M.teamsAndPlayersExist()

  local total = 0
  local return_val
  local sql = ""

  if M.teamsExist() == false then return false end

  myDatabase.open()

   sql = "select count(*) from teamplayers where rowstate < 999"
   for x in myDatabase.myDB:urows(sql) do 
      total = x
   end

   myDatabase.close()

  if total == nil or total < 1 then
    return_val = false
  else
    return_val = true
  end
  
  M.dialogResult("Need Players")
  
  return return_val

end


-- method: teamsAndPlayersExistForTeamId()
-- expects: nothing
-- returns: true/false
function M.teamsAndPlayersExistForTeamId(team_id)

  local total = 0
  local return_val
  local sql = ""
  
  if team_id == nil then return false end
  
  if M.teamsExist() == false then return false end
  
  myDatabase.open()

   sql = "select count(*) from teamplayers where rowstate < 999 and team="..team_id
   for x in myDatabase.myDB:urows(sql) do 
      total = x
   end

   myDatabase.close()

  if total == nil or total < 1 then
    return_val = false
  else
    return_val = true
  end
  
  M.dialogResult("Need Players")
  
  return return_val

end


-- method: resetSearch
-- expects: nothing
-- returns: nothing
-- notes: it resets all search parameters back to default
function M.resetSearch()
   --local scene = director:getCurrentScene()
	M.searchResults.from=0
	M.searchResults.to=0
	M.searchResults.pages_count = 0
	M.searchResults.page = 0
	M.searchResults.method = nil
	M.searchResults.query = ""
	M.searchResults.filter = false
	M.callbackDtype = nil
   --scene:reload()
end


-- method: loadPlayers
-- expects: nothing
-- returns: nothing
-- notes: it populars the player board with the last names played for a game id
function M.loadPlayers(attr)

  if attr.query ~= nil then 
    return M.loadPlayersFilter(attr)
  end

  myDatabase.open()
  
  M.callback = assert(M.loadPlayers)
  M.callbackParms = attr

  local from = 0

  if attr.cmd ~= nil then
    if attr.cmd == 'next' then
      if M.searchResults.page < M.searchResults.page_count-1 then        
        M.searchResults.from = (M.searchResults.page + 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'prev' then
      if M.searchResults.page > 0 then
        M.searchResults.from = (M.searchResults.page - 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'reload' then
      M.searchResults.from = (M.searchResults.page) * M.searchResults.per_page
    end
  end  

  if M.searchResults.from > 0 then from = M.searchResults.from end
  if searchPrevFrom.Players > 0 then
    from = searchPrevFrom.Players
    searchPrevFrom.Players = 0
  end
  
  local limit = from .. ", " .. M.searchResults.per_page  
  local total = 0
  for x in myDatabase.myDB:urows("SELECT COUNT(*) FROM players WHERE rowstate < 999") do
	total = x
  end
  M.searchResults.total = total
  
  -- load the players with test data
  if total < 1 and false then
    for n=1,20 do
      local res = myDatabase.insert("players",{name="Test Player "..(100+n).."",mdate="now()",rowstate=1})
    end
    total = 20
  end
    
  -- load the players
  -- 
  local sql = "SELECT"
  sql = sql .. " id,name,mdate "
  sql = sql .. " FROM players "
  sql = sql .. " WHERE name != '' and rowstate < 999 ORDER BY name COLLATE NOCASE ASC LIMIT "..limit
  local result = {}
  local n = 1
  --print("QUERY="..sql.." total="..total)
  for id, name, mdate in myDatabase.myDB:urows(sql) do 
    result[n] = {}
    result[n].name = name
    result[n].mdate = mdate
    result[n].id = id
    n = n + 1
    --print("LOADED PLAYER: "..name.." id="..id)
  end

  from = math.min(from, total)
  
  M.searchResults.from = from
  M.searchResults.page_count = math.floor((total + M.searchResults.per_page - 1) / M.searchResults.per_page)
  M.searchResults.page = math.floor(from / M.searchResults.per_page)
  
  myDatabase.close()
  return result
end


-- method: savePlayerById
-- expects: data and id in an array
-- returns: nothing
function M.savePlayerById(attr)
  local start=0
  local id = 0

  if attr == nil then
	 return id
  elseif attr.data == nil or attr.id == nil then
    return id
  end
  
  myDatabase.open()

  if string.len(attr.data) > MaxNameLength then
    attr.data = string.sub(attr.data,1,MaxNameLength)
  end
  
  local sql = "SELECT count(*) FROM players WHERE name='" .. attr.data .. "' and rowstate=1 ORDER BY name ASC"
  local total = 0
  for c in myDatabase.myDB:urows(sql) do 
    total = c
  end
  
  if total > 0 then return 0 end
  
  if attr.id == 0 then

    -- insert new
    local res = myDatabase.insert("players",
	  			    {
		  		    name=attr.data,
				    mdate="now()",
				    rowstate=1
				    })		

	 if res.newid > 0 then
	 	id = res.newid
	 end
    
    M.mode = "insert"
    
  elseif attr.id > 0 then
  
    -- update current
    local res = myDatabase.update("players",
	  			    {
		  		    name=attr.data,
				    mdate="now()",
				    rowstate=1
				    },
				    "id=" .. attr.id)		
    id = tonumber(attr.id)

    M.mode = "update"
  end
  myDatabase.close()
  return id
end


-- method: saveTeamById
-- expects: data and id in an array
-- returns: nothing
function M.saveTeamById(attr)
  local start=0
  local id = 0

  if attr == nil then
	 return id
  elseif attr.data == nil or attr.id == nil then
    return id
  end
  
  myDatabase.open()
  
  if string.len(attr.data) > MaxNameLength then
    attr.data = string.sub(attr.data,1,MaxNameLength)
  end

  local sql = "SELECT count(*) FROM team WHERE name='" .. attr.data .. "' and rowstate=1 ORDER BY name ASC"
  local total = 0
  for c in myDatabase.myDB:urows(sql) do 
    total = c
  end
  
  if total > 0 then return 0 end
  
  if attr.id == 0 then

    -- insert new
    local res = myDatabase.insert("team",
	  			    {
		  		    name=attr.data,
				    mdate="now()",
				    rowstate=1
				    })		

	 if res.newid > 0 then
	 	id = res.newid
	 end                
    
  elseif attr.id > 0 then
  
    -- update current
    local res = myDatabase.update("team",
	  			    {
		  		    name=attr.data,
				    mdate="now()",
				    rowstate=1
				    },
				    "id=" .. attr.id)		
    id = tonumber(attr.id)
  end
  myDatabase.close()
  return id
end


-- method: loadPlayersForGame
-- returns: array of players
-- notes: it populates the player list
function M.loadPlayersForGame(attr)
  local result = {}

  if GameSettings.gameid < 1 then return end
  
  local scene = director:getCurrentScene()
  
  myDatabase.open()

  M.callback = assert(M.loadPlayersForGame)
  M.callbackParms = attr

  local from = 0
  
  if attr.cmd ~= nil and attr.loadall == nil then
    if attr.cmd == 'next' then
      if M.searchResults.page < M.searchResults.page_count-1 then        
        M.searchResults.from = (M.searchResults.page + 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'prev' then
      if M.searchResults.page > 0 then
        M.searchResults.from = (M.searchResults.page - 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'reload' then
      if M.searchResults.page > 0 then
        M.searchResults.from = (M.searchResults.page) * M.searchResults.per_page
      end
     -- M.searchResults.from = (M.searchResults.page) * M.searchResults.per_page
    end
  end  

  --print("M.searchResults.from: " .. M.searchResults.from)

  if M.searchResults.from > 0 then from = M.searchResults.from end
  if searchPrevFrom.HistoryDetails > 0 and scene.name == "HistoryDetails" then
    from = searchPrevFrom.HistoryDetails
    searchPrevFrom.HistoryDetails = 0
  end

  if searchPrevFrom.GamePlayers > 0 and scene.name == "Game" then
    from = searchPrevFrom.GamePlayers
    searchPrevFrom.GamePlayers = 0
  end
  
  local limit = from .. ", " .. M.searchResults.per_page 

  -- check for load all
  if attr.loadall ~= nil then limit = "" end
  
  local total = 0
  
  -- for History section, but maybe other areas later.
  local game_id = GameSettings.gameid
  if EventGameId > 0 then
    game_id = EventGameId
    EventGameId = 0
  end

  if GameSettings.gametype < 3 then
     for x in myDatabase.myDB:urows("SELECT COUNT(*) FROM players WHERE id in (select player from gamelog where gameid="..game_id..") and rowstate < 999") do
      total = x
     end
  else
     for x in myDatabase.myDB:urows("SELECT COUNT(*) FROM team WHERE id in (select player from gamelog where gameid="..game_id..") and rowstate < 999") do
      total = x
     end
  end

    GameSettings.count = total

  -- print("total is " .. total)
  -- load the players
  -- 
  --               select players.id, players.name, players.mdate, gamelog.scoreint from players left join gamelog on players.id=gamelog.player where gamelog.gameid=50;
  
  local sql = "SELECT"

  print("GameSettings.gametype: "..GameSettings.gametype)
  if GameSettings.gametype < 3 then
     sql = sql .. " players.id, players.name, gamelog.scoreint, gamelog.team, players.mdate, (select name from team where id=gamelog.team) as teamname "
     sql = sql .. " FROM players "
     sql = sql .. " LEFT JOIN gamelog ON players.id=gamelog.player "
     sql = sql .. " WHERE players.name != '' and gamelog.gameid="..game_id.." and players.rowstate < 999 ORDER BY teamname,gamelog.scoreint desc,players.name COLLATE NOCASE ASC "
  else
     sql = sql .. " team.id, team.name, gamelog.scoreint, team.id, 0, team.mdate, team.name"
     sql = sql .. " FROM team "
     sql = sql .. " LEFT JOIN gamelog ON team.id=gamelog.player "
     sql = sql .. " WHERE team.name != '' and gamelog.gameid="..game_id.." and team.rowstate < 999 ORDER BY gamelog.scoreint desc,team.name COLLATE NOCASE ASC "
  end
  if string.len(limit) > 0 then sql = sql .." LIMIT "..limit end

  local result = {}
  local n = 1
  local lastTeam = 0
  local teamidx = 0
  local tally = 0
  --print("QUERY="..sql.." total="..total)
   
  for id, name, scoreint, team, mdate, teamname in myDatabase.myDB:urows(sql) do 
    result[n] = {}
    
    if M.checkForDuplicate(id, result) == false then
       if GameSettings.gametype < 3 then
          if team > 0 and lastTeam ~= team then
            teamidx = n
            result[n].id = -1
            result[n].mdate = ""      
            result[n].name = teamname
            result[n].team = team
            result[n].teamname = teamname
            result[n].scoreint = 0
            lastTeam = team
            -- since team takes a slot increment and create a new slot
            total = total + 1
            n = n + 1
            result[n] = {}
          end
       end
       result[n].name = name
       result[n].mdate = mdate
       result[n].scoreint = scoreint
       result[n].id = id
       result[n].team = team
       result[n].teamname = teamname
       n = n + 1
       
       if teamidx > 0 then
         result[teamidx].scoreint = result[teamidx].scoreint + scoreint
       end
    else
        -- print("DuplicatePlayerFound")
    end
    -- print("LOADED PLAYER: "..name.." id="..id)
  end

  from = math.min(from, total)

  M.searchResults.total = total
  if cmd ~= "reload" then
    M.searchResults.from = from
  end
  M.searchResults.page_count = math.floor((total + M.searchResults.per_page - 1) / M.searchResults.per_page)
  M.searchResults.page = math.floor(from / M.searchResults.per_page)
  
  myDatabase.close()
  return result
end


-- method: addPlayersToGame
-- returns: nothing
-- notes: it populates the gamelog table (game creation only! no score updates)
function M.addPlayersToGame(player_id)
  local player_name = "unknown"
  
  if GameSettings.name == "" or player_id < 1 then return end
  
  myDatabase.open()
  
  if GameSettings.gameid < 1 then
    -- create new game ()
    GameSettings.gametype = 1
    GameSettings.gameid = M.startGame()
  end
   
  if GameSettings.gameid > 0 then
    
    if GameSettings.gametype < 3 then
       -- look up the player and get the name
       for x in myDatabase.myDB:urows("SELECT name FROM players WHERE id="..player_id.." and rowstate=1") do
         player_name = x
       end
    else
       -- look up the team and get the name
       for x in myDatabase.myDB:urows("SELECT name FROM team WHERE id="..player_id.." and rowstate=1") do
         player_name = x
       end
    end
    
    if player_name == "" or player_name == "unknown" then return end
    
    -- look up player in game on the team (team 0 in this case)
    local total = 0
    local sql = "gameid="..GameSettings.gameid
          sql = sql .. " and team=0"
          sql = sql .. " and player="..player_id
    for x in myDatabase.myDB:urows("SELECT COUNT(*) FROM gamelog WHERE "..sql.." and rowstate=1") do
	  total = x
    end
    
    if total < 1 then    
      myDatabase.insert("gamelog",{
                        name=player_name,
                        player=player_id,
	   						team=0,
                        scoreint=0,
                        gameid=GameSettings.gameid,
                        gametype=GameSettings.gametype,
                        mdate="now()",
                        rowstate=1
	   						})      
    end
    
  end
  
end

-- method: removePlayersFromGame
-- returns: nothing
-- notes: it removes players from the gamelog table
function M.removePlayersFromGame(player_id)  
  if GameSettings.gameid < 1 or player_id < 1 then return end

  myDatabase.open()
  myDatabase.delete("gamelog","player="..player_id.." and gameid="..GameSettings.gameid)   
end


-- method: loadPlayersNotInGame
-- returns: nothing
-- notes: it loads the players based on the gamelog table
function M.loadPlayersNotInGame(attr)
  local result = {}
  if GameSettings.gameid < 1 then return end
  
  myDatabase.open()

  
  M.callback = assert(M.loadPlayersNotInGame)
  M.callbackParms = attr

  local from = 0

  if attr.cmd ~= nil then
    if attr.cmd == 'next' then
      if M.searchResults.page < M.searchResults.page_count-1 then        
        M.searchResults.from = (M.searchResults.page + 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'prev' then
      if M.searchResults.page > 0 then
        M.searchResults.from = (M.searchResults.page - 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'reload' then
      M.searchResults.from = (M.searchResults.page) * M.searchResults.per_page
    end
  end
  
  query = ""  
  if attr.query ~= nil then
    query = " and " .. attr.query
  end

  if M.searchResults.from > 0 then from = M.searchResults.from end
  if searchPrevFrom.GetPlayers > 0 then
    from = searchPrevFrom.Players
    searchPrevFrom.GetPlayers = 0
  end
  
  local limit = from .. ", " .. M.searchResults.per_page  
  local total = 0
  for x in myDatabase.myDB:urows("SELECT COUNT(*) FROM players WHERE id not in (select player from gamelog where gameid="..GameSettings.gameid..") and rowstate < 999 "..query) do
	total = x
  end
    
  -- load the players
  -- 
  local sql = "SELECT"
  sql = sql .. " id,name,mdate "
  sql = sql .. " FROM players "
  sql = sql .. " WHERE name != '' and id not in (select player from gamelog where gameid="..GameSettings.gameid..") and rowstate < 999 "..query.." ORDER BY name COLLATE NOCASE ASC LIMIT "..limit
  local result = {}
  local n = 1
  --print("QUERY="..sql.." total="..total)
  for id, name, mdate in myDatabase.myDB:urows(sql) do 
    result[n] = {}
    result[n].name = name
    result[n].mdate = mdate
    result[n].id = id
    n = n + 1
    --print("LOADED PLAYER: "..name.." id="..id)
  end

  from = math.min(from, total)
  
  M.searchResults.from = from
  M.searchResults.page_count = math.floor((total + M.searchResults.per_page - 1) / M.searchResults.per_page)
  M.searchResults.page = math.floor(from / M.searchResults.per_page)
  M.searchResults.total = total
  
  myDatabase.close()
  return result
end

--[[ update scores ]]--
function M.updateScore(attr)
  if GameSettings.gameid < 1 then return end
  
  myDatabase.open()

  -- put check if gamelog.gametype == 0 then normal if 1 then team name is player
  
  if attr.player ~= nil and attr.scoreint ~= nil then
    local team = 0
    if attr.team == nil then
      team = myGamePlayersDetailsInterface:getTeamId(attr.player)
    else
      team = tonumber(attr.team)
    end
    myDatabase.update("gamelog",{scoreint=tonumber(attr.scoreint)},"player="..attr.player.." AND gameid="..GameSettings.gameid.." AND team="..team)
    -- update result set scores too...
    for j,v in pairs(myGamePlayersDetailsInterface.result) do
      if v ~= nil then
        if tonumber(v.id) == tonumber(attr.player) then
          v.scoreint = tonumber(attr.scoreint)          
          break
        end
      end
    end
    
    -- update team
    if GameSettings.gametype < 3 then
       if team > 0 then
         local idx = 0
         local tally = 0
         for j,v in pairs(myGamePlayersDetailsInterface.result) do
           if tonumber(v.team) == team then
              if v.id == -1 then
                 idx = j
              else
                 tally = tally + tonumber(v.scoreint)
              end
           end
         end
         if idx > 0 then myGamePlayersDetailsInterface.result[idx].scoreint = tally end
       end
      end
  end
end


--[[ TEAM BASED ]]--

-- method: loadTeamsForGame
-- returns: array of players
-- notes: it populates the player list
function M.loadTeamsForGame(attr)
  local result = {}
  if GameSettings.gameid < 1 then return end
  
  myDatabase.open()

  
  M.callback = assert(M.loadTeamsForGame)
  M.callbackParms = attr

  local from = 0

  if attr.cmd ~= nil then
    if attr.cmd == 'next' then
      if M.searchResults.page < M.searchResults.page_count-1 then        
        M.searchResults.from = (M.searchResults.page + 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'prev' then
      if M.searchResults.page > 0 then
        M.searchResults.from = (M.searchResults.page - 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'reload' then
      M.searchResults.from = (M.searchResults.page) * M.searchResults.per_page
    end
  end  

  if M.searchResults.from > 0 then from = M.searchResults.from end
  if searchPrevFrom.Teams > 0 then
    from = searchPrevFrom.Players
    searchPrevFrom.Teams = 0
  end
  
  local limit = from .. ", " .. M.searchResults.per_page  
  local total = 0
  for x in myDatabase.myDB:urows("SELECT COUNT(*) FROM team WHERE id in (select team from gameteamlog where gameid="..GameSettings.gameid..") and rowstate < 999") do
	total = x
  end
    
  -- load the players
  -- 
  local sql = "SELECT"
  sql = sql .. " id,name,mdate "
  sql = sql .. " FROM team "
  sql = sql .. " WHERE name != '' and id in (select team from gameteamlog where gameid="..GameSettings.gameid..") and rowstate < 999 ORDER BY name COLLATE NOCASE ASC LIMIT "..limit
  local result = {}
  local n = 1
  --print("QUERY="..sql.." total="..total)
  for id, name, mdate in myDatabase.myDB:urows(sql) do
    if M.checkForDuplicate(id, result) == false then
       result[n] = {}
       result[n].name = name
       result[n].mdate = mdate
       result[n].id = id
       n = n + 1
       --print("LOADED PLAYER: "..name.." id="..id)
    else
       total = total - 1
    end
  end

   -- show how many we have in the table
  GameSettings.count = total

  from = math.min(from, total)
  
  M.searchResults.from = from
  M.searchResults.page_count = math.floor((total + M.searchResults.per_page - 1) / M.searchResults.per_page)
  M.searchResults.page = math.floor(from / M.searchResults.per_page)
  
  myDatabase.close()
  return result
end


-- method: checkForDuplicate(id, list)
-- returns: boolean
function M.checkForDuplicate(id, list)
   found = false
   for k, v in pairs(list) do
      if v.id == id then
         found = true
         break
      end
   end
   return found
end

-- method: addTeamsToGame
-- returns: nothing
-- notes: it populates the gamelog table (game creation only! no score updates)
function M.addTeamsToGame(team_id)
  local team_name = "unknown"
  
  if GameSettings.name == "" or team_id < 1 then return end
  
  myDatabase.open()
  
  if GameSettings.gameid < 1 then
    -- create new game ()
    GameSettings.gametype = 1
    GameSettings.gameid = M.startGame()
  end
   
  if GameSettings.gameid > 0 then

    -- look up the team in gameteamlog
    local team = 0
    for x in myDatabase.myDB:urows("SELECT team FROM gameteamlog WHERE team="..team_id.." and gameid="..GameSettings.gameid) do
	   team = tonumber(x)
    end
    
    -- if team not set up for game, insert it
    if team < 1 then 
      myDatabase.insert("gameteamlog",{team=team_id,gameid=GameSettings.gameid,rowstate=1})
    end
  
    -- look up the team and get the name
    local team_name = ""
    for x in myDatabase.myDB:urows("SELECT name FROM team WHERE id="..team_id.." and rowstate=1") do
	   team_name = x
    end
    
    if team_name == "" or team_name == "unknown" then return end
    
    
    -- find all the players that are on the team that are "not" in the game
    local tempResult = {}
    local n = 0
    if GameSettings.gametype < 3 then
       for id, name in myDatabase.myDB:urows("SELECT id,name FROM players WHERE id in (select player from teamplayers where rowstate < 999 and team="..team_id..") and rowstate=1") do
         tempResult[n] = {}
         tempResult[n].id = id
         tempResult[n].name = name
         n = n + 1
       end
    else
       for id, name in myDatabase.myDB:urows("SELECT id,name FROM team WHERE id="..team_id) do
         tempResult[n] = {}
         tempResult[n].id = id
         tempResult[n].name = name
         n = n + 1
       end    
    end
    
    -- nothing to add
    if n < 1 then return end
    
    -- look up player in game on the team (team 0 in this case)
    n = 0
    local logResult = {}
    for id in myDatabase.myDB:urows("SELECT player FROM gamelog where team="..team_id.." and gameid="..GameSettings.gameid.." and rowstate=1") do
      logResult[n] = {}
      logResult[n].id = id      
      n = n + 1
    end
    
    for j,v in pairs(tempResult) do
      local found = false
      for k,x in pairs(logResult) do
        if tonumber(v.id) == tonumber(x.id) then
          found = true
          break
        end
      end
      if not found then
        myDatabase.insert("gamelog",{
                        name=tempResult[j].name,
                        player=tempResult[j].id,
	   						team=team_id,
                        scoreint=0,
                        gameid=GameSettings.gameid,
                        gametype=GameSettings.gametype,
                        mdate="now()",
                        rowstate=1
	   						})      
      end      
    end
    
  end
  
end


-- method: removeTeamsFromGame
-- returns: nothing
-- notes: it removes teams from the gamelog table
function M.removeTeamsFromGame(team_id)  
  if GameSettings.gameid < 1 or team_id < 1 then return end

  myDatabase.open()
  myDatabase.delete("gamelog","team="..team_id.." and gameid="..GameSettings.gameid)   
  myDatabase.delete("gameteamlog","team="..team_id.." and gameid="..GameSettings.gameid)   
end


-- method: loadTeamsNotInGame
-- returns: nothing
-- notes: it loads the teams based on the gamelog table
function M.loadTeamsNotInGame(attr)
  local result = {}
  if GameSettings.gameid < 1 then return end
  
  myDatabase.open()

  
  M.callback = assert(M.loadTeamsNotInGame)
  M.callbackParms = attr

  local from = 0

  if attr.cmd ~= nil then
    if attr.cmd == 'next' then
      if M.searchResults.page < M.searchResults.page_count-1 then        
        M.searchResults.from = (M.searchResults.page + 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'prev' then
      if M.searchResults.page > 0 then
        M.searchResults.from = (M.searchResults.page - 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'reload' then
      M.searchResults.from = (M.searchResults.page) * M.searchResults.per_page
    end
  end  

  if M.searchResults.from > 0 then from = M.searchResults.from end
  if searchPrevFrom.Teams > 0 then
    from = searchPrevFrom.Teams
    searchPrevFrom.Teams = 0
  end

  query = ""  
  if attr.query ~= nil then
    query = " and " .. attr.query
  end
  
  local limit = from .. ", " .. M.searchResults.per_page  
  local total = 0
  for x in myDatabase.myDB:urows("SELECT COUNT(*) FROM team WHERE id not in (select team from gameteamlog where gameid="..GameSettings.gameid..") and rowstate < 999 " .. query) do
	total = x
  end
    
  -- load the teams
  -- 
  local sql = "SELECT"
  sql = sql .. " id,name,mdate "
  sql = sql .. " FROM team "
  sql = sql .. " WHERE name != '' and id not in (select team from gameteamlog where gameid="..GameSettings.gameid..") and rowstate < 999 " .. query .." ORDER BY name COLLATE NOCASE ASC LIMIT "..limit
  local result = {}
  local n = 1
  --print("QUERY="..sql.." total="..total)
  for id, name, mdate in myDatabase.myDB:urows(sql) do 
    result[n] = {}
    result[n].name = name
    result[n].mdate = mdate
    result[n].id = id
    n = n + 1
    --print("LOADED PLAYER: "..name.." id="..id)
  end

  from = math.min(from, total)
  
  M.searchResults.from = from
  M.searchResults.page_count = math.floor((total + M.searchResults.per_page - 1) / M.searchResults.per_page)
  M.searchResults.page = math.floor(from / M.searchResults.per_page)
  M.searchResults.total = total
  
  myDatabase.close()
  return result
end


-- method: loadTeams
-- expects: teamObj from myPanelClass, dtype <string> one of: team, teamplay (team is editing, teamplay is playing)
-- returns: nothing
-- notes: it populates the teams
function M.loadTeams(attr)

  if attr.query ~= nil then
    return M.loadTeamsFilter(attr)
  end

  M.callback = assert(M.loadTeams)
  M.callbackParms = attr

  myDatabase.open()

  local from = 0
  if attr.cmd ~= nil then
    if attr.cmd == 'next' then
      if M.searchResults.page < M.searchResults.page_count-1 then        
        M.searchResults.from = (M.searchResults.page + 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'prev' then
      if M.searchResults.page > 0 then
        M.searchResults.from = (M.searchResults.page - 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'reload' then
      M.searchResults.from = (M.searchResults.page) * M.searchResults.per_page
    end
  end  

  if M.searchResults.from > 0 then from = M.searchResults.from end
  if searchPrevFrom.Team > 0 then
    from = searchPrevFrom.Team
    searchPrevFrom.Team = 0
  end
  
  local limit = from .. ", " .. M.searchResults.per_page
  local total = 0
  for x in myDatabase.myDB:urows("SELECT COUNT(*) FROM team WHERE name != '' and rowstate=1") do
	total = x
  end
  M.searchResults.total = total
  
  -- load the Team with test data
  if total < 2 and false then
    for n=1,20 do
      local res = myDatabase.insert("team",{name="Test Team "..(100+n).."",mdate="now()",rowstate=1})
    end
    total = 20
  end

  -- load the teams
  local sql = "SELECT id,name,mdate FROM team WHERE name != '' and rowstate=1 ORDER BY name COLLATE NOCASE ASC LIMIT " .. limit
  local result = {}
  local n = 1
  for id, name, mdate in myDatabase.myDB:urows(sql) do 
    result[n] = {}
    result[n].name = name
    result[n].mdate = mdate
    result[n].id = id
    n = n + 1
    --print("LOADED TEAM: "..name.." id="..id)
  end

  from = math.min(from, total)
  
  M.searchResults.from = from
  M.searchResults.page_count = math.floor((total + M.searchResults.per_page - 1) / M.searchResults.per_page)
  M.searchResults.page = math.floor(from / M.searchResults.per_page)
  
  myDatabase.close()
 
  return result
end


-- method: loadTeamsFilter
-- expects: teamObj from myPanelClass, dtype <string> one of: team, teamplay (team is editing, teamplay is playing)
-- returns: nothing
-- notes: it populates the teams
function M.loadTeamsFilter(attr)
  
  myDatabase.open()
  
  M.callback = assert(M.loadTeamsFilter)
  M.callbackParms = attr
  
  local from = 0
  if attr.cmd ~= nil then
    if attr.cmd == 'next' then
      if M.searchResults.page < M.searchResults.page_count-1 then        
        M.searchResults.from = (M.searchResults.page + 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'prev' then
      if M.searchResults.page > 0 then
        M.searchResults.from = (M.searchResults.page - 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'reload' then
      M.searchResults.from = (M.searchResults.page) * M.searchResults.per_page
    end
  end  

  if attr.whereclause ~= "" and attr.whereclause ~= nil then
    M.searchResults.query = attr.whereclause
  elseif attr.query ~= nil and attr.query ~= "" then
    M.searchResults.query = attr.query
    attr.whereclause = M.searchResults.query
  else
    attr.whereclause = " rowstate < 999 "
  end

  if M.searchResults.from > 0 then from = M.searchResults.from end
  if searchPrevFrom.Team > 0 then
    from = searchPrevFrom.Team
    searchPrevFrom.Team = 0
  end

  local limit = from .. ", " .. M.searchResults.per_page
  local total = 0
  for x in myDatabase.myDB:urows("SELECT COUNT(*) FROM team WHERE name != '' and rowstate=1 and "..attr.whereclause) do
	total = x
  end

  -- load the teams
  local sql = "SELECT id,name,mdate FROM team WHERE name != '' and rowstate=1 and "..attr.whereclause.." ORDER BY name COLLATE NOCASE ASC LIMIT " .. limit
  local result = {}
  local n = 1
  for id, name, mdate in myDatabase.myDB:urows(sql) do 
    result[n] = {}
    result[n].name = name
    result[n].mdate = mdate
    result[n].id = id
    n = n + 1
    --print("LOADED TEAM: "..name)
  end
  
  from = math.min(from, total)
  
  M.searchResults.from = from
  M.searchResults.page_count = math.floor((total + M.searchResults.per_page - 1) / M.searchResults.per_page)
  M.searchResults.page = math.floor(from / M.searchResults.per_page)

  myDatabase.close()

  if total < 1 then
	M.dialogNoResults()
	M.resetSearch()
  else
    M.searchResults.filter = true
  end

  return result
end


-- method: loadTeamById
-- expects: nothing
-- returns: nothing
-- notes: it populates the team board
function M.loadTeamById(id)
  myDatabase.open()
  
  -- we must have a valid entry
  if id == nil then
	return
  end
  
  -- load the players
  local sql = "SELECT id,name,mdate FROM team WHERE id="..id
  local result = {}
  for id, name, mdate in myDatabase.myDB:urows(sql) do 
	result.id = id
   result.name = name
   result.mdate = mdate
	--print("LOADED =",name)
  end  
  
  myDatabase.close()
  return result
end


-- method: loadPlayerFilter
-- expects: teamObj from myPanelClass, dtype <string> one of: team, teamplay (team is editing, teamplay is playing)
-- returns: nothing
-- notes: it populates the players
function M.loadPlayersFilter(attr)
  
  myDatabase.open()
  
  if M.searchResults.filter == false then
	M.callback = assert(M.loadPlayersFilter)
	M.callbackParms = attr
  end
  
  local from = 0

  if attr.cmd ~= nil then
    if attr.cmd == 'next' then
      if M.searchResults.page < M.searchResults.page_count-1 then        
        M.searchResults.from = (M.searchResults.page + 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'prev' then
      if M.searchResults.page > 0 then
        M.searchResults.from = (M.searchResults.page - 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'reload' then
      M.searchResults.from = (M.searchResults.page) * M.searchResults.per_page
    end
  end  

  if M.searchResults.from > 0 then from = M.searchResults.from end
  if searchPrevFrom.Players > 0 then
    from = searchPrevFrom.Players
    searchPrevFrom.Players = 0
  end
    
  if attr.whereclause ~= "" and attr.whereclause ~= nil then
    M.searchResults.query = attr.whereclause
  elseif attr.query ~= nil and attr.query ~= "" then
    M.searchResults.query = attr.query
    attr.whereclause = M.searchResults.query
  else
    attr.whereclause = " rowstate < 999 "
  end
  
  if searchPrevQuery.Players ~= "" and searchPrevQuery.Players ~= nil then
    M.searchResults.query = searchPrevQuery.Players
  end


  local limit = from .. ", " .. M.searchResults.per_page  
  local total = 0
  for x in myDatabase.myDB:urows("SELECT COUNT(*) FROM players WHERE name != '' and rowstate < 999 and "..attr.whereclause) do
	total = x
  end
      
  -- load the players
  -- 
  local sql = "SELECT"
  sql = sql .. " id,name,mdate "
  sql = sql .. " FROM players "
  sql = sql .. " WHERE name != '' and rowstate < 999 and "..attr.whereclause.." ORDER BY name COLLATE NOCASE ASC LIMIT "..limit
  local result = {}
  local n = 1
  for id, name, mdate in myDatabase.myDB:urows(sql) do 
    if M.checkForDuplicate(id, result) == false then
       result[n] = {}
       result[n].name = name
       result[n].mdate = mdate
       result[n].id = id
       n = n + 1
    else
       total = total - 1
    end
  end
  
  from = math.min(from, total)
  
  M.searchResults.from = from
  M.searchResults.page_count = math.floor((total + M.searchResults.per_page - 1) / M.searchResults.per_page)
  M.searchResults.page = math.floor(from / M.searchResults.per_page)
  
  myDatabase.close()
  if total < 1 then
	M.dialogNoResults()
	M.resetSearch()
  else
    M.searchResults.filter = true
  end

  return result
end


function M.loadPlayersNotOnTeam(attr)
  
  myDatabase.open()
  
  if M.searchResults.filter == false then
	M.callback = assert(M.loadPlayersNotOnTeam)
	M.callbackParms = attr
  end
  
  local from = 0

  if attr.cmd ~= nil then
    if attr.cmd == 'next' then
      if M.searchResults.page < M.searchResults.page_count-1 then        
        M.searchResults.from = (M.searchResults.page + 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'prev' then
      if M.searchResults.page > 0 then
        M.searchResults.from = (M.searchResults.page - 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'reload' then
      M.searchResults.from = (M.searchResults.page) * M.searchResults.per_page
    end
  end  
  
  if attr.whereclause ~= "" and attr.whereclause ~= nil then
    M.searchResults.query = attr.whereclause
  elseif attr.query ~= nil and attr.query ~= "" then
    M.searchResults.query = attr.query
    attr.whereclause = M.searchResults.query
  else
    attr.whereclause = " rowstate < 999 "
  end

  if searchPrevQuery.GetPlayers ~= "" and searchPrevQuery.GetPlayers ~= nil then
    M.searchResults.query = searchPrevQuery.GetPlayers
  end
  
  if M.searchResults.from > 0 then from = M.searchResults.from end
  if searchPrevFrom.GetPlayers > 0 then
    from = searchPrevFrom.GetPlayers
    searchPrevFrom.GetPlayers = 0
  end


  local limit = from .. ", " .. M.searchResults.per_page  
  local total = 0
  local sqlC = "SELECT COUNT(*) FROM players WHERE id not in (select player from teamplayers where team="..EntryTeamId..") and rowstate < 999 and name != '' and "..attr.whereclause
  for x in myDatabase.myDB:urows(sqlC) do
	total = x
  end  
      
  -- load the players
  -- 
  local sql = "SELECT"
  sql = sql .. " id,name,mdate "
  sql = sql .. " FROM players "
  sql = sql .. " WHERE name != '' and rowstate < 999 and id not in (select player from teamplayers where team="..EntryTeamId..") and "..attr.whereclause.." ORDER BY name COLLATE NOCASE ASC LIMIT "..limit
  local result = {}
  local n = 1
  for id, name, mdate in myDatabase.myDB:urows(sql) do 
    result[n] = {}
    result[n].name = name
    result[n].mdate = mdate
    result[n].id = id
    n = n + 1
  end

  from = math.min(from, total)
  
  M.searchResults.from = from
  M.searchResults.page_count = math.floor((total + M.searchResults.per_page - 1) / M.searchResults.per_page)
  M.searchResults.page = math.floor(from / M.searchResults.per_page)
  
  myDatabase.close()
  return result
end


function M.addToTeam(id)
  if id ~= nil then
    if tonumber(id) > 0 and EntryTeamId > 0 then
      myDatabase.open()
      myDatabase.insert("teamplayers",{player=id,team=EntryTeamId,mdate="now()",rowstate=1})
    end
  end
end


function M.removeFromTeam(id)
  if id ~= nil then
    if tonumber(id) > 0 and EntryTeamId > 0 then
      myDatabase.open()
      myDatabase.delete("teamplayers","player="..id.." and team="..EntryTeamId)
      myDatabase.delete("gamelog","player="..id.." and team="..EntryTeamId)
    end
  end
end


-- method: loadPlayersForTeam
-- expects: nothing
-- returns: nothing
-- notes: it populates the members of a team
function M.loadPlayersForTeam(attr)
  myDatabase.open()
  
  local teamId = 0
  
  -- we must belong to a team
  if attr == nil then
    if EntryTeamId > 0 then 
      teamId = EntryTeamId 
    else
      return
    end
  elseif attr.teamid == nil then
    if EntryTeamId > 0 then 
      teamId = EntryTeamId 
    else
      return
    end
  else
    teamId = attr.teamid
  end

  local from = 0

  if attr.cmd ~= nil then
    if attr.cmd == 'next' then
      if M.searchResults.page < M.searchResults.page_count-1 then        
        M.searchResults.from = (M.searchResults.page + 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'prev' then
      if M.searchResults.page > 0 then
        M.searchResults.from = (M.searchResults.page - 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'reload' then
      M.searchResults.from = (M.searchResults.page) * M.searchResults.per_page
    end
  end  

  if M.searchResults.from > 0 then from = M.searchResults.from end
  if searchPrevFrom.TeamPlayers > 0 then
    from = searchPrevFrom.TeamPlayers
    searchPrevFrom.TeamPlayers = 0
  end
    
  if searchPrevQuery.TeamPlayers ~= "" and searchPrevQuery.TeamPlayers ~= nil then
    M.searchResults.query = searchPrevQuery.TeamPlayers
  end

  local limit = from .. ", " .. M.searchResults.per_page  
  local total = 0

  local sqlC = "SELECT COUNT(*) FROM players INNER JOIN teamplayers on players.id=teamplayers.player where teamplayers.team="..teamId.." and players.rowstate < 999"
  for x in myDatabase.myDB:urows(sqlC) do
	total = x
  end  
  
  -- load the Team with test data
  if total < 2 and false then
    local res = myDatabase.insert("teamplayers",{player=28,team=84,mdate="now()",rowstate=1})
    local res = myDatabase.insert("teamplayers",{player=9,team=84,mdate="now()",rowstate=1})
    local res = myDatabase.insert("teamplayers",{player=32,team=84,mdate="now()",rowstate=1})
    local res = myDatabase.insert("teamplayers",{player=33,team=84,mdate="now()",rowstate=1})
    local res = myDatabase.insert("teamplayers",{player=12,team=84,mdate="now()",rowstate=1})
    total = 5
  end
  
  --inner join
  --  
  local sql = "SELECT players.id as id,players.name as name FROM players INNER JOIN teamplayers on players.id=teamplayers.player where teamplayers.team="..teamId.." and players.rowstate < 999 ORDER BY players.name COLLATE NOCASE ASC LIMIT "..limit

  result = {}
  local n=1
  for id, name in myDatabase.myDB:urows(sql) do 
    result[n] = {}
    result[n].id = id
    result[n].name = name
    result[n].team = teamId
    n = n + 1
  end
  
  from = math.min(from, total)
  
  M.searchResults.from = from
  M.searchResults.page_count = math.floor((total + M.searchResults.per_page - 1) / M.searchResults.per_page)
  M.searchResults.page = math.floor(from / M.searchResults.per_page)
  
  return result
end


-- method: loadPlayersById
-- expects: nothing
-- returns: nothing
-- notes: it populates the player board with the last names played for a game id
function M.loadPlayerById(id)
  myDatabase.open()
  
  -- we must have a valid entry
  if id == nil then
	return
  end
  
  -- load the players
  local sql = "SELECT id,name,mdate FROM players WHERE id="..id
  local result = {}
  for id, name, mdate in myDatabase.myDB:urows(sql) do 
	result.id = id
   result.name = name
   result.mdate = mdate
	--print("LOADED =",name)
  end  
  
  myDatabase.close()
  return result
end


function M.removeTeamById(id)
  myDatabase.open()
  
  if id == nil then return end
  
  -- remove from main players table
  myDatabase.delete("team","id=" .. id)
  
  --remove from gamelog
  myDatabase.delete("gamelog","team=" .. id)

  --remove from teamplayers
  myDatabase.delete("teamplayers","team=" .. id)
  
end


function M.removeTeams()
  local countMax = #myTeamPanel.panel
  local myList = ""
  local str_length = string.len
  
  if myTeamPanel.panel[0] == nil then return nil end
  
  myDatabase.open()
  
  for i=0,countMax do
    if myTeamPanel.panel[i].removeEntry == true then
		if str_length(myList) > 0 then
			myList = myList .. ","
		end
		myList = myList .. myTeamPanel.panel[i].teamid
	end
  end
  if str_length(myList) > 0 then
	myDatabase.delete("team","id in (" .. myList .. ")")
	myDatabase.delete("players","team in (" .. myList .. ")")
	sceneTeam:removeTeams()
	sceneTeam:removePlayers()
	M.loadTeams(myTeamPanel, "team")
	--print("remove teams [".. myList .."]")
  end
  
  myDatabase.close()
end


function M.removePlayerById(id)
  myDatabase.open()
  
  if id == nil then return end
  
  -- remove from main players table
  myDatabase.delete("players","id=" .. id)
  
  --remove from gamelog
  myDatabase.delete("gamelog","player=" .. id)

  --remove from teamplayers
  myDatabase.delete("teamplayers","player=" .. id)
end


function M.removePlayers(panelObj)
  local countMax = #panelObj.panel
  local myList = ""
  local str_length = string.len
  local myTeamid = 0
  local count = 0
  
  if panelObj.panel[0] == nil then print("CRAP");return nil end
  
  myDatabase.open()
  
  for i=0,countMax do
    if panelObj.panel[i].removeEntry == true or panelObj.panel[i].panel_status == 999 then
		if str_length(myList) > 0 then
			myList = myList .. ","
		end
		myList = myList .. panelObj.panel[i].playerid
		myTeamid = panelObj.panel[i].teamid
		--print("remove t="..panelObj.panel[i].teamid.." id="..panelObj.panel[i].name)
		count = count + 1
	end
  end

  if str_length(myList) > 0 then
	local scene = director:getCurrentScene()
	
	if scene.name == "Friend" then
	  myDatabase.delete("players","id IN (" .. myList .. ")")
	  sceneFriend:removePlayers()
	  M.loadPlayersForTeam({teamid=myTeamid,playerObj=myFriendPanel})
	elseif scene.name == "Game" then
	  myDatabase.delete("players","id IN (" .. myList .. ") AND team=0")
	  myDatabase.delete("gamelog","player IN (" .. myList .. ") AND team < 1 AND gameid="..GameSettings.gameid)
	  --print("delete ".."player IN (" .. myList .. ") AND team < 1 AND gameid="..GameSettings.gameid)
	else
	  myDatabase.delete("players","id IN (" .. myList .. ")")
	  sceneTeam:removePlayers()
	  M.loadPlayersForTeam({teamid=myTeamid,playerObj=myMemberPanel})
	end
  end
  
  myDatabase.close()
  return count
end


-- method: loadHistory
-- expects: nothing
-- returns: nothing
-- notes: it populates the teams
function M.loadHistory(attr)  

  if attr.query ~= nil then 
    return M.loadHistoryFilter(attr)
  end

  myDatabase.open()

  M.callback = assert(M.loadHistory)
  M.callbackParms = attr
  local from = 0

  if attr.cmd ~= nil then
    if attr.cmd == 'next' then
      if M.searchResults.page < M.searchResults.page_count-1 then        
        M.searchResults.from = (M.searchResults.page + 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'prev' then
      if M.searchResults.page > 0 then
        M.searchResults.from = (M.searchResults.page - 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'reload' then
      M.searchResults.from = (M.searchResults.page) * M.searchResults.per_page
    end
  end  

  
  if M.searchResults.from > 0 then from = M.searchResults.from end
  if searchPrevFrom.History > 0 then
    from = searchPrevFrom.History
    searchPrevFrom.History = 0
  end

  local limit = from .. ", " .. M.searchResults.per_page
  local total = 0
  for x in myDatabase.myDB:urows("SELECT COUNT(*) FROM game WHERE rowstate < 999") do
	total = x
  end
  
  -- load the history
  if total < 1 and false then
  for n=1,20 do
    local res = myDatabase.insert("game",{name=M.game.name..(100+n),gametype=M.game.type,mdate="now()",rowstate=1})
  end
  total = 20
  end
  
  local sql = "SELECT id,name,mdate FROM game WHERE rowstate < 999 ORDER BY mdate DESC,name ASC LIMIT " .. limit
  
  local result = {}
  local n = 1
  for id, name, mdate in myDatabase.myDB:urows(sql) do 
    result[n] = {}
    result[n].name = name
    result[n].mdate = mdate
    result[n].id = id
    n = n + 1
  end  

  from = math.min(from, total)
  
  M.searchResults.from = from
  M.searchResults.page_count = math.floor((total + M.searchResults.per_page - 1) / M.searchResults.per_page)
  M.searchResults.page = math.floor(from / M.searchResults.per_page)

  --print("page_count=",M.searchResults.page_count.." total="..total)
  
  myDatabase.close()
  return result
end


function M.removeHistory(id)
  if id == nil then return nil end
  
  myDatabase.open()
  	
  myDatabase.delete("game","id=" .. id)
  myDatabase.delete("gamelog","gameid=" .. id)
  
  myDatabase.close()

end


-- method: loadHistoryFilter
-- expects: nothing
-- returns: nothing
-- notes: it populates the teams
function M.loadHistoryFilter(attr)  
  myDatabase.open()

  if M.searchResults.filter == false then
	M.callback = assert(M.loadHistoryFilter)
	M.callbackParms = attr
  end
  
  if attr.query ~= nil then attr.whereclause = attr.query end
  
  if searchPrevQuery.History ~= "" and searchPrevQuery.History ~= nil then
    M.searchResults.query = searchPrevQuery.History
    attr.whereclause = M.searchResults.query
  end

  if attr.cmd ~= nil then
    if attr.cmd == 'next' then
      if M.searchResults.page < M.searchResults.page_count-1 then        
        M.searchResults.from = (M.searchResults.page + 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'prev' then
      if M.searchResults.page > 0 then
        M.searchResults.from = (M.searchResults.page - 1) * M.searchResults.per_page
      end
    elseif attr.cmd == 'reload' then
      M.searchResults.from = (M.searchResults.page) * M.searchResults.per_page
    end
  end  
  
  local from = 0
  if M.searchResults.from > 0 then from = M.searchResults.from end

  if searchPrevFrom.HistoryDetails > 0 then
    from = searchPrevFrom.HistoryDetails
    searchPrevFrom.HistoryDetails = 0
  end
  
  -- load the history
  local limit = from .. ", " .. M.searchResults.per_page
  local total = 0
  local sql = ""

  sql = "SELECT count(DISTINCT(game.id)) "
  sql = sql .. " FROM game "
  sql = sql .. " LEFT JOIN gamelog ON gamelog.gameid = game.id "
  sql = sql .. " LEFT JOIN players ON players.id = gamelog.player "
  sql = sql .. " WHERE "
  if attr.whereclause ~= "" and attr.whereclause ~= nil then
    M.searchResults.query = attr.whereclause
	sql = sql .. attr.whereclause
	sql = sql .. " AND "
  end
  sql = sql .. " (( game.rowstate < 999 ) OR (game.rowstate < 999 AND gamelog.rowstate < 999)) "
  --sql = sql .. " GROUP BY game.id"

  for x in myDatabase.myDB:urows(sql) do
    total = x
  end
  
  sql = "SELECT game.id as id,game.name as name,game.mdate as mdate, "
  sql = sql .. " players.name as playername "
  sql = sql .. " FROM game "
  sql = sql .. " LEFT JOIN gamelog ON gamelog.gameid = game.id "
  sql = sql .. " LEFT JOIN players ON players.id = gamelog.player "
  sql = sql .. " WHERE "
  if attr.whereclause ~= "" and attr.whereclause ~= nil then
	sql = sql .. attr.whereclause
	sql = sql .. " AND "
  end
  sql = sql .. " (( game.rowstate < 999 ) OR (game.rowstate < 999 AND players.rowstate < 999)) "
  sql = sql .. " GROUP BY game.id ORDER BY game.mdate DESC,game.name ASC LIMIT " .. limit

  --print("search sql=["..sql.."]")

  local rowCount = 0
  local result = {}
  local n = 1
  for id, name, mdate, playername in myDatabase.myDB:urows(sql) do 
   result[n] = {}
   result[n].name = name
   result[n].mdate = mdate
   result[n].id = id
   n = n + 1
	rowCount = rowCount + 1
  end
  
  if rowCount < 1 then
	M.dialogNoResults()
	M.resetSearch()
  else
    M.searchResults.filter = true
  end
  
  from = math.min(from, total)
  
  M.searchResults.from = from
  M.searchResults.page_count = math.floor((total + M.searchResults.per_page - 1) / M.searchResults.per_page)
  M.searchResults.page = math.floor(from / M.searchResults.per_page)

  --print("page_count=",M.searchResults.page_count)

  myDatabase.close()
  
  return result
end


-- method: loadPlayersForHistory
-- expects: array()
-- returns: nothing
-- notes: it populates the player board with the last names played for a game id
function M.loadPlayersForHistory(attr)
  myDatabase.open()
  
  -- we must belong to a team
  if EventGameId > 0 then attr.gameid = EventGameId end
  if attr.gameid == nil then
	return nil
  end

  local from = 0
  if M.searchResults.from > 0 then from = M.searchResults.from end
  
  -- load the history
  local limit = from .. ", " .. M.searchResults.per_page
  local total = 0
  
  local sorted = "team,scoreint DESC"
  if attr.sorted ~= nil then
	sorted = attr.sorted
  end
  
  -- specify the game
  local gameid = 0
  if attr.gameid ~= nil then
	gameid = attr.gameid
	M.game.id = gameid
  end
  
  local prevTeamId = 0  
  local playerObjGame = attr.playerObjGame
  local sql = ""
  
  -- load playerid and score from the gamelog for the gameid
  local n = 0
  local previd = 0
  local winnerid = 0
  local highscore = 0
  sql = "SELECT scoreint, team from gamelog WHERE gameid = " .. gameid .. " AND rowstate  < 999 ORDER BY team"
  for score, teamid in myDatabase.myDB:urows(sql) do
	if teamid ~= previd then
	  n = 0
	  previd = teamid
	end
	n = n + score
	if n > highscore then
	  winnerid = teamid
	  highscore = n
	end
  end
  
  sql = ""
  sql = "SELECT gamelog.player as player, gamelog.scoreint as score, gamelog.team as teamid,"
  sql = sql .. " players.color as colorname, players.id as id, players.name as name"
  sql = sql .. " FROM gamelog INNER JOIN PLAYERS ON gamelog.player = players.id WHERE gamelog.gameid=" .. gameid
  sql = sql .. " AND gamelog.rowstate < 999"
  sql = sql .. " ORDER BY gamelog.team,gamelog.scoreint DESC,players.name LIMIT " .. limit
  local myTeamName = ""
  local result = {}
  n = 1
  for player, score, teamid, colorname, id, name in myDatabase.myDB:urows(sql) do 
			
	-- create the team banner
		-- load the teams
	if prevTeamId ~= teamid then 
		local sql = "SELECT name FROM team WHERE id=" .. teamid .. " AND rowstate=1 ORDER BY name ASC"
		for teamname in myDatabase.myDB:urows(sql) do 
			myTeamName = teamname
			break
		end
	end
		
	if prevTeamId ~= teamid and myTeamName ~= "" then
		local winnerText = ""
	    if teamid == winnerid then
			winnerText = "\nWinner"
		end
      
      result[n] = {}
      result[n].name = myTeamName .. winnerText
      result[n].playerid = -(id)
      result[n].teamid = teamid
      result[n].scoreint = numWithCommas(score)
      n = n + 1
      
      --[[
		playerObj:addPanel( { 
			name="Panel-Banner-" .. id,
			strokeColor=color.black,
			color=myColorPickerStorage:getColorByName(colorname),
			label = "Team: " .. myTeamName .. winnerText,
			labelColor = color.white,
			datatype = "player",
			playerid = -(id),
			teamid = teamid,
			scoreint = numWithCommas(score),
			colorname = colorname
		} )
      --]]--      
	end

   result[n] = {}
   result[n].name = name .. "\n" .. numWithCommas(score)
   result[n].mdate = mdate
   result[n].playerid = id
   result[n].teamid = teamid
   result[n].scoreint = numWithCommas(score)
   n = n + 1
	
   --[[
	-- add the team members
	playerObj:addPanel( { 
		name="Panel-" .. id,
		strokeColor=color.black,
		color=myColorPickerStorage:getColorByName(colorname),
		label = name .. "\n" .. numWithCommas(score),
		labelColor = color.white,
		datatype = "player",
		playerid = id,
		teamid = teamid,
		scoreint = numWithCommas(score),
		colorname = colorname
	} )
   --]]--
			
	prevTeamId = teamid 
  end

  from = math.min(from, total)
  
  M.searchResults.from = from
  M.searchResults.page_count = math.floor((total + M.searchResults.per_page - 1) / M.searchResults.per_page)
  M.searchResults.page = math.floor(from / M.searchResults.per_page)
  
  myDatabase.close()
end


function M.paginateBackEventHandler(event)
  local processEvent = true
  
  if DialogInUse == true then return end

  if myDevice.keyboard:isKeyboardActive() or myDevice.keyboard:isKeypadActive() then
	processEvent = false
  end

  --determine if touch is lasting long time
  if event.phase == "began" then
	myDevice.touchTime = event.time
	event.target.strokeColor = color.white
	processEvent = false
  end
  
  if event.phase == "ended" then
    processEvent = true -- myDevice.touched( event.time )
	--print("CAN I PROCEED?",processEvent)
  end

  if event.phase == "ended" and processEvent == true and M.pageinate_anim == false then
	event.target.strokeColor = color.black
	M.pageinate_anim = true
	tween:from(event.target, { xScale=1.2, yScale=1.2, time=0.3, onComplete=M.animateRectEnd })	
    --print("BACK ARROW!")
	
	-- set the back amount
	local x = M.searchResults.from - M.searchResults.per_page
	if x < 0 then x = 0 end
	if M.searchResults.page-1 >= 0 then
		M.searchResults.from = x
	else
		M.searchResults.from = 0
	end

	M.BackAndForwardEvent()
  end
end


function M.BackAndForwardEvent()
	local scene = director:getCurrentScene()
	-- next method is temporary
	M.emptyScene()
	-- call the related callback and pass in parameters
	if scene.name == "Team" and M.searchResults.filter == false then
		myStorage.loadTeams(myTeamPanel, M.callbackDtype)
	elseif scene.name == "Team" and M.searchResults.filter == true then
		--print("TEAM FILTER START")
		myStorage.loadTeamsFilter({whereclause=M.searchResults.query})
	elseif scene.name == "NewGame" and M.searchResults.filter == false then
		local evt = nil
		  
		if newGameType == "peopleNewGame" then
			evt = {target = {action="peopleNewGame"}}
		elseif newGameType == "teamNewGame" then
			evt = {target = {action="teamNewGame"}}
		end
		if evt ~= nil then
			newGameChoosePlayerEventHandler(evt)
		end
	elseif scene.name == "NewGame" and M.searchResults.filter == true then
		if newGameType == "peopleNewGame" then
			myStorage.loadPlayerFilter({whereclause=M.searchResults.query,panelObj=myFriendPanel2})
		elseif newGameType == "teamNewGame" then
			myStorage.loadTeamsFilter({whereclause=M.searchResults.query, newgame=true})
		end
	elseif scene.name == "Friend" and M.searchResults.filter == false then
		myStorage.loadPlayersForTeam({teamid=-100,playerObj=myFriendPanel})
	elseif scene.name == "Friend" and M.searchResults.filter == true then
		myStorage.loadPlayerFilter({whereclause=M.searchResults.query,panelObj=myFriendPanel})
	elseif scene.name == "History" and M.searchResults.filter == false then
		myStorage.loadHistory({panelObj=myHistoryPanel})
	elseif scene.name == "History" and M.searchResults.filter == true then
		myStorage.loadHistoryFilter({whereclause=M.searchResults.query,panelObj=myHistoryPanel})
	else
	end
end


function M.paginateForwardEventHandler(event)
  local processEvent = true
  
  if DialogInUse == true then return end

  if myDevice.keyboard:isKeyboardActive() or myDevice.keyboard:isKeypadActive() then
	processEvent = false
  end

  --determine if touch is lasting long time
  if event.phase == "began" then
	myDevice.touchTime = event.time
	event.target.strokeColor = color.white
	processEvent = false
  end
  
  if event.phase == "ended" then
    processEvent = true -- myDevice.touched( event.time )
  end

  if event.phase == "ended" and processEvent == true and M.pageinate_anim == false then	
	event.target.strokeColor = color.black
	M.pageinate_anim = true
	tween:from(event.target, { xScale=1.2, yScale=1.2, time=0.3, onComplete=M.animateRectEnd })	
	
	-- set the forward amount
	local x = M.searchResults.from + M.searchResults.per_page
	if M.searchResults.page+1 < M.searchResults.page_count then
		M.searchResults.from = x
		--print("On page M.searchResults.page=",M.searchResults.page, M.searchResults.page_count)
	end
	
	M.BackAndForwardEvent()
  end
end


function M.emptyScene()
	local scene = director:getCurrentScene()
	-- next conditions are temporary
	if scene.name == "Game" or scene.name == "NewGame" then
	  scene:removePlayers()
	  scene:removeTeams()
	elseif scene.name == "Friend" then
	  scene:removePlayers()
	elseif scene.name == "Team" then
	  sceneTeam:removeTeams()
	  sceneTeam:removePlayers()
	elseif scene.name == "History" then
	  scene:removeGames()
	  scene:removeHistoryPlayers()
	end
end


M.animateRectEnd = function (event)
	M.pageinate_anim = false
	event.strokeColor = color.black
end


function M.dialogResult(message)
	-- show warning dialog
	--action = "confirm", "info", "warn"

   local timeDiff = system:getTime() - EventDialogTime

   if message == nil then return end

   if timeDiff < 0.400 then
     return
   end
   
	local myDialogConfirm = myDialogClass:new()
	myDialogConfirm:init()
	myDialogConfirm:addPanel( { 
		name="Dialog-Search-History-Filter",
		type_of_dialog="warn",
		strokeColor=color.black,
		color={0x91,0x1A,0xE5},
		label = message,
		labelColor = color.white,
		colorname="black",
		action_ok="ok",
		action_cancel="cancel",
		action_func=nil,
      widthoffset=80
	} )
end


function M.dialogNoResults()
	-- show warning dialog
	--action = "confirm", "info", "warn"

   local timeDiff = system:getTime() - EventDialogTime

   if timeDiff < 0.400 then
     return
   end
   
   EventDialogTime = system:getTime()

	local myDialogConfirm = myDialogClass:new()
	myDialogConfirm:init()
	myDialogConfirm:addPanel( { 
		name="Dialog-Search-History-Filter",
		type_of_dialog="warn",
		strokeColor=color.black,
		color={0x91,0x1A,0xE5},
		label = "No results found.",
		labelColor = color.white,
		colorname="black",
		action_ok="ok",
		action_cancel="cancel",
		action_func=nil,
      widthoffset=80
	} )
end

return M