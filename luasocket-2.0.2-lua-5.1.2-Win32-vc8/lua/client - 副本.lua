-- client.lua
SimpleClient = {}

SimpleClient.socket = nil
SimpleClient.host = "127.0.0.1"
SimpleClient.port = 12345
SimpleClient.sock = nil

function SimpleClient:setupClient(socket)
    self.socket = socket
    self:reconnect()
end

function SimpleClient:reconnect()
    while self.sock == nil do
        print("try connect to server...")
        self.sock = self.socket.connect(self.host, self.port)
        local recvt, sendt, status = self.socket.select({self.sock}, nil, 1)
        print(string.format("connect......recvt:%s, sendt:%s, status:%s, sock:%s", Library:PrintTBData(recvt), Library:PrintTBData(sendt), tostring(status), Library:PrintTBData(self.sock)))
    end

    self.sock:settimeout(0)
    print("connected! Press enter after input something:")
    --print(debug.traceback())
end

function SimpleClient:updateClient()
    local input, recvt, sendt, status
    
    input = io.read()
    if #input > 0 then
        local _waiting = true
        --一直等待server的回复,否则就阻塞
        while _waiting do
            recvt, sendt, status = self.socket.select({self.sock}, nil, 1)
            print(string.format("recive.....recvt:%s, sendt:%s, status:%s, sock:%s", Library:PrintTBData(recvt), Library:PrintTBData(sendt), tostring(status), Library:PrintTBData(self.sock)))

            while #recvt > 0 do
                local response, receive_status = self.sock:receive()
                if receive_status ~= "closed" then
                    if response then
                        print(response)
                        recvt, sendt, status = self.socket.select({self.sock}, nil, 1)

                        if #recvt == 0 then
                            _waiting = false
                            break
                        end
                    end
                else
                    self:reconnect()
                    _waiting = false
                    break
                end
            end

            if self.sock ~= nil then
                self.sock:send(input .. "\n")
                _waiting = false
                break
            else
                self:reconnect()
            end

        end
    end
     
    
end
