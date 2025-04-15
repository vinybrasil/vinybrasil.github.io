---
author: Vinicyus Brasil
title: Caching API responses with Redis in Zig
date: 2025-03-11
description: Using Redis to cache responses from Zap, the Zig blazingly fast webframewor
math: false
---



## Introduction

When fetching a database, our server must perform a READ operation. Every transation has a cost of time and money (computational cost in the cloud). One way of reducing this cost it's 
to cache the last record fetched so we don't have to perform another READ operation. This can help when the same record is requested multiple times.

To do this caching, we can use Redis, a advanced key-value store that works as a in memory database. It is really fast and combines with our choice for the backend: `zap`, a blazingly fast 
webframework written in Zig. 

This project is heavily inspired by [this post](https://medium.com/@aarav.gupta9/unlocking-the-power-of-redis-using-redis-with-python-ff09d459dad2) but we'll code it in Zig, a system programming language capable of handling thousands of requests (the original one was
written in Python). The Zig version used is 0.14 and the redis version is 7.0.15. In this blogpost there's only a few snippets of the code since most of it is not that 
important but you can check the full code [here](https://github.com/vinybrasil/cache-redis-zig).

OBS: since Redis is also a database, I'll use the term "database" referring to the database where the data is stored (in our case a hashmap) and use the term "redis" refering 
to the Redis database.

## Implementation

To simulate a database, we'll use a hashmap instead of deploying one. Note that our database has different users indexed by an ID, which we'll be used to fetch them.
The User struct is quite simple: has a id, a name, an email and an age. 
```zig 
var users = std.AutoHashMap(u32, entities.User).init(allocator);
defer users.deinit();

try users.put(1, entities.User{
    .id = 1,
    .name = "Alice",
    .email = "alice@example.com",
    .age = 25,
});
try users.put(2, entities.User{
    .id = 2,
    .name = "Bob",
    .email = "bob@example.com",
    .age = 30,
});
try users.put(3, entities.User{
    .id = 3,
    .name = "Charlie",
    .email = "charlie@example.com",
    .age = 22,
});
```
Make sure you install redis and that it's running:
```bash
sudo apt-get install redis-server
sudo systemctl start redis.service
```
First we need to connect to the redis running in the machine. To do it, we'll use okredis, a client for Redis written in Zig. If you're running it in Docker you gotta 
change the IP the same way I did in the repository.
```zig 
pub fn main() !void {
    var client: Client = undefined;

    const addr = try net.Address.parseIp4("127.0.0.1", 6379);
    const connection = try net.tcpConnectToAddress(addr);

    try client.init(connection);
    defer client.close();

    const redischace: RedisCache = RedisCache{
        .ttl = "30",
        .client = client,
    };
}
```

The ideia is the following: we'll try to find the record in the cache. If it's not cached, we'll fetch them in the database and insert it into the cache.
The implementation it's simple: first we need to try to get the value from redis:
```zig
switch (try self.redisCache.client.sendAlloc(
    OrErr([]u8),
    self.allocator,
    .{ "GET", id_request },
)) 
```
There's three possible cases from the switch case: if it's .Ok, we'll just use the value. If it's Nil (the ID is not in redis), fetch the database and insert it into redis.
The last case is a .Err, where something goes wrong, and we'll just log the error by now. 
```zig       
{   .Ok => |value| {
        response = try self.allocator.dupe(u8, value);
    },
    .Nil => {
        const id_request_int = try std.fmt.parseInt(
            u8,
            id_request,
            10,
        );
        const id_request_casted: u32 = @intCast(id_request_int);

        if (self.users.getPtr(id_request_casted)) |user| {
            user.timestamp = std.time.timestamp();
            const json_string = try json.stringifyAlloc(
                self.allocator,
                user,
                .{},
            );
            defer self.allocator.free(json_string);

            try self.redisCache.client.send(void, .{ "SET", id_request, 
                                                    json_string, "EX", self.redisCache.ttl });
            response = try self.allocator.dupe(u8, json_string);
        } else {
            std.log.err("User {d} not found", .{id_request_casted});
        }
    },

    .Err => |err| std.log.err("error code = {any}\n", .{err.getCode()}),
}
```
Note that when we send to the client (in the .Nil case), we set a parameter "EX" (defined here in self.redisCache.ttl).
The "EX" is the expiring time in seconds, also called "time to live" (ttl). The value we are using here is 30, so during 
30 seconds every time the response will be the same. It can be verified by the "timestamp" field in the json. 


## Testing 

To test it, we'll make a GET request with the following body:
```
{
    "id": "2"
}
```
It will fetch it and return the record in the "value" field:
```
{
    "id": "2",
    "value": "{\"id\":2,\"name\":\"Bob\",\"email\":\"bob@example.com\",
                \"age\":30,\"timestamp\":1741712135}"
}
```
Since we set a TTL of 30 seconds, if the call it again the result would be the same. After 30 seconds, 
the value is removed from redis. 

If we call an ID that is not in the database, this should be the return.

```
{
    "id": "4",
    "value": ""
}
```
I just included the most important parts of the code here because I don't want to tire my beloved readers but, as always, the full code is on this [public repository](https://github.com/vinybrasil/cache-redis-zig). 
And that's all folks. Keep on learning :D