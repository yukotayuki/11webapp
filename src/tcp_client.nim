import net


when isMainModule:
  var client = newSocket(AF_INET, SOCK_STREAM, IPPROTO_TCP, false)
  client.connect("localhost", Port(8001))

  block:
    var f : File = open("./client_send.txt", FileMode.fmRead)
    defer :
      close(f)
    while f.endOfFile == false :
      let data = f.readLine()
      client.send(data & "\r\n")

  echo "送信完了"
  var recv_msg = client.recv(1024)
  echo recv_msg

  block:
    var f : File = open("./client_recv.txt", FileMode.fmWrite)
    defer :
      close(f)
    f.write(recv_msg)

  client.close()

