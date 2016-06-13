-- client.lua
SimpleClient = {}

SimpleClient.socket = nil
SimpleClient.host = "127.0.0.1"
SimpleClient.port = 12345
SimpleClient.sock = nil

function SimpleClient:setupClient(socket)
    self.socket = socket
    self:reConnect()
    print("Press enter after input something:")
end

function SimpleClient:reConnect()
    while true do
        --connection refused
        print("try to connect..")
        local _ret, msg = self.socket.connect(self.host, self.port)
        --print("ret:%s, msg:%s", tostring(_ret), tostring(msg))

        if _ret ~= nil then
            self.sock = _ret
            self.sock:settimeout(0)
            print("connect success!")
            break
        end

        self.socket.select(nil, nil, 1)
    end
end

function SimpleClient:updateClient()
    local input, recvt, sendt, status
    
    print(">")
    input = io.read()
    if #input > 0 then
        local _ret, msg = self.sock:send(input .. "\n")
        --print("ret:%s, msg:%s", tostring(_ret), tostring(msg))
        if _ret == nil then
            --尝试重链
            self:reConnect()
            self.sock:send(input .. "\n")
            --return
        end
    end
     
    recvt, sendt, status = self.socket.select({self.sock}, nil, 1)
    while #recvt > 0 do
        local response, receive_status = self.sock:receive()
        if receive_status ~= "closed" then
            if response then
                print(response)
                recvt, sendt, status = self.socket.select({self.sock}, nil, 1)
            end
        else
            --如果关闭,则尝试链接
            self:reConnect()
        end
    end
end
