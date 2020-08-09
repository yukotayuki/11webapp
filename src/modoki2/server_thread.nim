import net
import strutils
import os
import uri
import send_response


proc server_thread*(sock: Socket) {.thread.} =
  defer:
    # finaly
    sock.close()

  # 環境に応じて変更
  var DOCUMENT_ROOT: string = getCurrentDir()
  var SERVER_NAME: string = "lcoalhsot:8001"

  let msg: string = sock.recv(1024).decodeUrl()
  stdout.write msg
  
  var path: string = ""
  var ext: string = ""
  var host: string = ""
  for line in msg.splitLines:
    if line.startsWith("GET"):
      path = line.split(" ")[1]
      let tmp = path.split(".")
      ext = tmp[tmp.len - 1]
    elif line.startsWith("Host:"):
      host = line.split("Host: ")[1]

  if path == "":
    return

  # 末尾 "/" の場合 index.htmlをパスに付与
  if path.endsWith("/"):
    path &= "index.html"
    ext = "html"

  var real_path = normalizedPath(DOCUMENT_ROOT & path)
  # ディレクトリトラバーサル対策
  if not (real_path.startsWith(DOCUMENT_ROOT)):
    send_not_found_response(sock, DOCUMENT_ROOT)
    return

  # ディクトリを指定した場合 "/"を付与してリダイレクト
  if real_path.existsDir():
    if host == "":
      host = SERVER_NAME
    let location = "http://" & host
    send_move_permanently_response(sock, location)
    return

  # ファイルが存在しない場合
  if not real_path.existsFile():
    send_not_found_response(sock, DOCUMENT_ROOT)
    return

  send_ok_response(sock, real_path, ext)

