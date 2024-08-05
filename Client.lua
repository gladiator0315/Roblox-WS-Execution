local Services = setmetatable({}, { __index = function(Self, Key) return game.GetService(game, Key) end })
local Client = Services.Players.LocalPlayer
local SMethod = (WebSocket and WebSocket.connect)

if not SMethod then return Client:Kick("Executor is too shitty.") end

local Main = function()
    local Success, WebSocket = pcall(SMethod, "ws://localhost:9000/")
    if not Success then return end

    local function HandleMessage(Unparsed)
        local Parsed = Services.HttpService:JSONDecode(Unparsed)
        
        if Parsed.Method == "Execute" then
            local Function, Error = loadstring(Parsed.Data)

            if Error then 
                WebSocket:Send(Services.HttpService:JSONEncode({
                    Method = "Error",
                    Message = Error
                }))
                return
            end
            
            Function()
        end
    end

    local function HandleClose()
        Main() 
    end

    WebSocket.OnMessage:Connect(HandleMessage)
    WebSocket.OnClose:Connect(HandleClose)

    WebSocket:Send(Services.HttpService:JSONEncode({
        Method = "Authorization",
        Name = Client.Name
    }))
end

Main()
