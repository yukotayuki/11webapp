import net
import util
import times
import strutils


proc send_ok_response*(sock: Socket, file_path: string, ext: string) =
  write_line(sock, "HTTP/1.1 200 OK")
  write_line(sock, "Date: " & format(now().utc(),
                   "ddd, dd MMM yyyy HH:mm:ss") & " GMT")
  write_line(sock, "Server: Modoki/0.2")
  write_line(sock, "Connection: close")
  let content_type: string = get_contetnt_type(ext)
  write_line(sock, "Content-Type: " & content_type)
  write_line(sock, "")

  block:
    var f: File = open(file_path, FileMode.fmRead)
    defer:
      close(f)
    while f.endOfFile == false:
      if "image" in content_type:
        sock.send(f.readLine())
      else:
        write_line(sock, f.readLine())

proc send_move_permanently_response*(sock: Socket, location: string) =
  write_line(sock, "HTTP/1.1 301 Moved Permanently")
  write_line(sock, "Date: " & format(now().utc(),
                   "ddd, dd MMM yyyy HH:mm:ss") & " GMT")
  write_line(sock, "Server: Modoki/0.2")
  write_line(sock, "Location: " & location)
  write_line(sock, "Connection: close")
  write_line(sock, "Content-Type: " & get_contetnt_type("html"))
  write_line(sock, "")

proc send_not_found_response*(sock: Socket, error_document_root: string) =
  write_line(sock, "HTTP/1.1 404 Not Found")
  write_line(sock, "Date: " & format(now().utc(),
                   "ddd, dd MMM yyyy HH:mm:ss") & " GMT")
  write_line(sock, "Server: Modoki/0.2")
  write_line(sock, "Connection: close")
  write_line(sock, "Content-Type: " & get_contetnt_type("html") )
  write_line(sock, "")

  block:
    var f: File = open(error_document_root & "/404.html", FileMode.fmRead)
    defer:
      close(f)
    while f.endOfFile == false:
      write_line(sock, f.readLine())

