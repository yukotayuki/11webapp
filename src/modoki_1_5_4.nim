import net
import tables
import unicode
import strutils
import times
import os
import threadpool


const content_type_map = {
  "html": "text/html",
  "htm": "text/html",
  "txt": "text/plain",
  "css": "text/css",
  "png": "image/png",
  "jpg": "image/jpeg",
  "jpeg": "image/jpeg",
  "gif": "image/gif",
}.toTable

proc get_contetnt_type(ext: string): string =
  if ext in content_type_map:
    return content_type_map[ext]
  elif ext.toLower() in content_type_map:
    echo "lower()"
    return content_type_map[ext.toLower()]
  else:
    return "application/octet-stream"

proc write_line(sock: Socket, data: string) =
  sock.send(data & "\r\n")

proc server_thread(sock: Socket, num: int) {.thread.} =
  defer:
    echo "finaly"
    sock.close()

  echo "try num: " & num.intToStr
  var DOCUMENT_ROOT: string = getCurrentDir()
 

  let msg: string = sock.recv(1024)
  echo msg
  
  var path: string = ""
  var ext: string = ""
  for line in msg.splitLines:
    if line.startsWith("GET"):
      path = line.split(" ")[1]
      ext = path.split(".")[1]

  write_line(sock, "HTTP/1.1 200 OK")
  write_line(sock, format(now().utc(),
                   "ddd, dd MMM yyyy HH:mm:ss") & " GMT")
  write_line(sock, "Server: Modoki/0.1")
  write_line(sock, "Connection: close")
  let content_type: string = get_contetnt_type(ext)
  write_line(sock, "Content-Type: " & content_type)
  write_line(sock, "")

  block:
    echo "ファイルをオープン"
    echo DOCUMENT_ROOT & path
    var f: File = open(DOCUMENT_ROOT & path, FileMode.fmRead)
    defer:
      close(f)
    while f.endOfFile == false:
      if "image" in content_type:
        sock.send(f.readLine())
      else:
        write_line(sock, f.readLine())

proc main() =
  var server = newSocket(AF_INET, SOCK_STREAM, IPPROTO_TCP, false)
  server.setSockOpt(OptReusePort, true)
  server.bindAddr(Port(8001))
  server.listen()

  echo "クライアントからの接続を待ちます"

  var index = 0

  defer:
    server.close()
  while true:
    var client: Socket = new(Socket)
    server.accept(client)

    # spawn server_thread(client, index)
    server_thread(client, index)
    index += 1

when isMainModule:
  main()
