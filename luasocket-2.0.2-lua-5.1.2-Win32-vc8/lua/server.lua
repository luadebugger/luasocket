-- server.lua
SimpleServer = {}
SimpleServer.socket = nil
SimpleServer.host = "127.0.0.1"
SimpleServer.port = "12345"
SimpleServer.server = nil
SimpleServer.client_tab = nil
SimpleServer.conn_count = nil

function SimpleServer:setupServer(socket)
    self.socket = socket
    -- if self.server ~= nil then
    --     --先关闭自己
    --     print("关闭自己")
    --     SimpleServer.server:close()
    -- end

    self.server = assert(self.socket.bind(self.host, self.port, 1024))
    self.server:settimeout(0)
    self.client_tab = {}
    self.conn_count = 0
    print("setup server success! wait for client")
end
 
function SimpleServer:updateServer()
    local conn = self.server:accept()
    if conn then
        self.conn_count = self.conn_count + 1
        self.client_tab[self.conn_count] = conn
        print("A client successfully connect!") 
    end
  
    for conn_count, client in pairs(self.client_tab) do
        local recvt, sendt, status = self.socket.select({client}, nil, 1)
        if #recvt > 0 then
            local receive, receive_status = client:receive()
            if receive_status ~= "closed" then
                if receive then
                    assert(client:send("Client " .. conn_count .. " Send : " .. receive .. "\n"))
                    --assert(client:send(receive .. "\n"))
                    print("Receive Client " .. conn_count .. " : ", receive)
                    --这里后面要
                    -- local _cmd = Library:SplitStr(receive, "\0")
                    -- assert(false)
                    -- local func = callFunc[_cmd[1]]
                    -- if func == nil then
                    --     self.socket.close()
                    -- else
                    --     func(_cmd[2])
                    -- end
                end
            else
                table.remove(self.client_tab, conn_count) 
                client:close() 
                print("Client " .. conn_count .. " disconnect!") 
            end
        end
    end
end