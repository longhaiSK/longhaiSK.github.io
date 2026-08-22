#!/usr/bin/env python3
"""Local web server backing updateCV.html.

Serves updateCV.html (same directory as this script), and gives it three
JSON endpoints: read the CV file, save it back, and run `quarto render`
(the browser calls this twice in a row for ritem's two-pass reverse-
numbering, same as the old Tkinter app did).

Run this, then open the URL it prints (it also auto-opens a browser tab).
Everything else -- parsing, navigation, editing -- happens in the browser;
this process only touches the filesystem and shells out to quarto.
"""
import json
import subprocess
import threading
import webbrowser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

CV_FILE = Path("/Users/longhai/Github/longhaiSK.github.io/longhailiCV-2026.qmd")
HTML_FILE = Path(__file__).with_name("updateCV.html")
SERVER_PORT = 8877
HTML_PORT = 8080  # assumes a local server (e.g. `quarto preview` or `python3 -m
                   # http.server`) is already serving CV_FILE.parent on this port
RENDER_FORMAT = "profweb-html"


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass

    def _send_json(self, status, payload):
        body = json.dumps(payload).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _read_json(self):
        length = int(self.headers.get("Content-Length", 0))
        raw = self.rfile.read(length) if length else b"{}"
        return json.loads(raw or b"{}")

    def do_GET(self):
        if self.path in ("/", "/updateCV.html"):
            self._send_html()
        elif self.path == "/api/config":
            self._send_json(200, {
                "fileName": CV_FILE.name,
                "htmlPort": HTML_PORT,
                "cvStem": CV_FILE.stem,
            })
        elif self.path == "/api/file":
            if not CV_FILE.exists():
                self._send_json(404, {"ok": False, "error": f"Cannot find {CV_FILE}"})
                return
            self._send_json(200, {"ok": True, "text": CV_FILE.read_text()})
        else:
            self.send_error(404)

    def _send_html(self):
        if not HTML_FILE.exists():
            self.send_error(404, "updateCV.html not found next to updateCV_server.py")
            return
        body = HTML_FILE.read_bytes()
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        if self.path == "/api/save":
            data = self._read_json()
            text = data.get("text", "")
            if not text.endswith("\n"):
                text += "\n"
            CV_FILE.write_text(text)
            self._send_json(200, {"ok": True})
        elif self.path == "/api/render":
            try:
                result = subprocess.run(
                    ["quarto", "render", CV_FILE.name, "--to", RENDER_FORMAT],
                    cwd=CV_FILE.parent, capture_output=True, text=True,
                )
            except FileNotFoundError:
                self._send_json(200, {
                    "ok": False,
                    "error": "`quarto` not found on PATH. Is Quarto installed?",
                })
                return
            if result.returncode != 0:
                self._send_json(200, {"ok": False, "error": result.stderr[-2000:]})
            else:
                self._send_json(200, {"ok": True})
        elif self.path == "/api/shutdown":
            self._send_json(200, {"ok": True})
            threading.Thread(target=self.server.shutdown, daemon=True).start()
        else:
            self.send_error(404)


def main():
    if not CV_FILE.exists():
        print(f"Warning: {CV_FILE} not found.")
    if not HTML_FILE.exists():
        print(f"Warning: {HTML_FILE} not found next to this script.")

    server = ThreadingHTTPServer(("127.0.0.1", SERVER_PORT), Handler)
    url = f"http://127.0.0.1:{SERVER_PORT}/"
    print(f"Serving {HTML_FILE.name} at {url}  (Ctrl+C to stop)")
    threading.Timer(0.5, lambda: webbrowser.open(url)).start()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
