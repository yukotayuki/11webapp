import net
import times
import strutils
import os

proc write_line(sock: Socket, data: string) =
  sock.send(data & "\r\n")


proc main() =
  var DOCUMENT_ROOT: string = getCurrentDir()
  var socket = newSocket(AF_INET, SOCK_STREAM, IPPROTO_TCP, false)
  socket.setSockOpt(OptReusePort, true)

  socket.bindAddr(Port(8001))
  socket.listen()

  var client: Socket = new(Socket)
  socket.accept(client)

  var msg: string = client.recv(1024)
  echo "リクエスト内容:"
  echo msg

  var path: string = ""
  for line in msg.splitLines:
    if line.startsWith("GET"):
      path = line.split(" ")[1]

  write_line(client, "HTTP/1.1 200 OK")
  write_line(client, format(now().utc(),
                     "ddd, dd MMM yyyy HH:mm:ss") & " GMT")
  write_line(client, "Server: Modoki/0.1")
  write_line(client, "Connection: close")
  write_line(client, "Content-Type: text/html")
  write_line(client, "")

  block:
    var f: File = open(DOCUMENT_ROOT & path, FileMode.fmRead)
    defer:
      close(f)
    while f.endOfFile == false:
      write_line(client, f.readLine())
      # client.send(f.readLine() & "\r\n")

  echo "通信を終了しました。"
  socket.close()


when isMainModule:
  main()
