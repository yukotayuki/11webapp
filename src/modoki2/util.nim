import net
import tables
import unicode


const content_type_map = {
  "html": "text/html; charset=utf-8",
  "htm": "text/html; charset=utf-8",
  "txt": "text/plain",
  "css": "text/css",
  "png": "image/png",
  "jpg": "image/jpeg",
  "jpeg": "image/jpeg",
  "gif": "image/gif",
}.toTable

proc write_line*(sock: Socket, data: string) =
  sock.send(data & "\r\n")

proc get_contetnt_type*(ext: string): string =
  if ext in content_type_map:
    return content_type_map[ext]
  elif ext.toLower() in content_type_map:
    echo "lower()"
    return content_type_map[ext.toLower()]
  else:
    return "application/octet-stream"
