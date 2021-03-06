--  Licensed to the Apache Software Foundation (ASF) under one
--  or more contributor license agreements.  See the NOTICE file
--  distributed with this work for additional information
--  regarding copyright ownership.  The ASF licenses this file
--  to you under the Apache License, Version 2.0 (the
--  "License"); you may not use this file except in compliance
--  with the License.  You may obtain a copy of the License at
--
--  http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.

require 'os'

function read_data(c)
    local nt = os.time()..' Zheng.\n'
    local resp =  'HTTP/1.0 200 OK\r\n' ..
                  'Server: ATS/5.2.0\r\n' ..
                  'Content-Type: text/plain\r\n' ..
                  'Content-Length: ' .. string.format('%d', string.len(nt)) .. '\r\n' ..
                  'Last-Modified: ' .. os.date("%a, %d %b %Y %H:%M:%S GMT", os.time()) .. '\r\n' ..
                  'Connection: keep-alive\r\n' ..
                  'Cache-Control: max-age=7200\r\n' ..
                  'Accept-Ranges: bytes\r\n\r\n' ..
                  nt

    local rfd = ts.cache_open('http://foo.com/large.pdf', TS_LUA_CACHE_READ, 'uh')

    if rfd.hit then
        while ts.cache_eof(rfd) ~= true do
            d = ts.cache_read(rfd, 1024*1024*5)
            if ts.cache_err(rfd) then
                break
            end
            print(string.len(d))
        end

        ts.cache_close(rfd)

    else
        print('miss')
    end

    ts.say(resp)
end

function do_remap()
    local cc = ts.client_request.header['CC']
    if cc == nil then
        return 0
    end

    ts.http.intercept(read_data, cc)
    return 0
end
