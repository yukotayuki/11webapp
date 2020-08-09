import net
import server_thread
import threadpool


proc main() =
  var server = newSocket(AF_INET, SOCK_STREAM, IPPROTO_TCP, false)
  server.setSockOpt(OptReusePort, true)
  server.bindAddr(Port(8001))
  server.listen()
  
  echo "クライアントからの接続を待ちます"
  
  defer:
    server.close()
  while true:
    var client: Socket = new(Socket)
    server.accept(client)
  
    spawn server_thread(client)


when isMainModule:
  main()
