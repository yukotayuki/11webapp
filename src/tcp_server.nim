import net


when isMainModule:
  var socket = newSocket(AF_INET, SOCK_STREAM, IPPROTO_TCP, false)
  socket.bindAddr(Port(8001))
  socket.listen()
  echo "bind port 8001"

  echo "クライアントからの接続を待ちます。"

  var client: Socket = new(Socket)
  socket.accept(client)
  echo "クライアント接続。"

  block:
    var f : File = open("./server_recv.txt", FileMode.fmWrite)
    defer:
      close(f)
    let message: string = client.recv(1024)
    echo message
    f.write(message)

  echo "受信完了"

  block:
    var f : File = open("./server_send.txt", FileMode.fmRead)
    defer:
      close(f)
    while f.endOfFile == false:
      let data = f.readLine()
      client.send(data & "\r\n")

  echo "通信を終了しました。"
  socket.close()

