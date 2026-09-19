#!/usr/bin/env python3
"""No Leak Helium — local bang list mirror.

Serves the bundled bangs.json over loopback HTTP only (127.0.0.1), so Helium's
native bang loader can fetch `!bang` definitions without ever touching
services.helium.imput.net.

Privacy properties (intentional, do not regress):
  * Binds to 127.0.0.1 only. No interface other than loopback is listened on.
  * Serves exactly one path: GET /bangs.json. Everything else is 404.
  * No cookies, no tracking, no request logging beyond optional stderr lines.
  * The served file is static, pinned by sha256 at install time; nothing here
    ever fetches from the network.
"""
from __future__ import annotations

import argparse
import hashlib
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

MANIFEST_PATH = Path(__file__).resolve().parent / "bangs.json"
# Only route that exists. Everything else is 404 by design.
ROUTE = "/bangs.json"


def sha256_of(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 16), b""):
            h.update(chunk)
    return h.hexdigest()


class BangsHandler(BaseHTTPRequestHandler):
    server_version = "NLH-BangsMirror/0.1"

    def _404(self, method: str) -> None:
        self.send_response(404)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", "0")
        self.send_header("Connection", "close")
        self.end_headers()
        print(f"[bangs-mirror] {method} {self.path} -> 404", flush=True)

    def do_GET(self) -> None:  # noqa: N802 (http.server API)
        if self.path.split("?", 1)[0] != ROUTE:
            self._404("GET")
            return
        try:
            body = self.server.bang_data
        except AttributeError:
            body = self.server.load_data()
        if body is None:
            self._404("GET")
            return
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("Connection", "close")
        self.end_headers()
        self.wfile.write(body)

    def do_HEAD(self) -> None:  # noqa: N802
        self._404("HEAD")

    def do_POST(self) -> None:  # noqa: N802
        self._404("POST")

    def log_message(self, fmt: str, *args) -> None:  # silence default stderr noise
        pass


class BangsServer(ThreadingHTTPServer):
    daemon_threads = True
    allow_reuse_address = True

    def __init__(self, addr, handler, manifest: Path):
        super().__init__(addr, handler)
        self.manifest = manifest
        self.bang_data = self.load_data()

    def load_data(self):
        if not self.manifest.exists():
            print(f"[bangs-mirror] missing manifest: {self.manifest}", flush=True)
            return None
        data = self.manifest.read_bytes()
        print(
            f"[bangs-mirror] loaded {self.manifest.name}: {len(data)} bytes "
            f"sha256={sha256_of(self.manifest)}",
            flush=True,
        )
        return data


def main() -> int:
    p = argparse.ArgumentParser(description="Serve bundled bangs.json on loopback.")
    p.add_argument("--port", type=int, default=8317,
                   help="loopback port (default 8317)")
    p.add_argument("--manifest", type=Path, default=MANIFEST_PATH,
                   help="path to the bundled bangs.json")
    args = p.parse_args()

    if not args.manifest.exists():
        print(f"[bangs-mirror] fatal: manifest not found at {args.manifest}", flush=True)
        return 1

    if args.port < 1 or args.port > 65535:
        print(f"[bangs-mirror] fatal: invalid port {args.port}", flush=True)
        return 1

    try:
        server = BangsServer(("127.0.0.1", args.port), BangsHandler, args.manifest)
    except OSError as e:
        print(f"[bangs-mirror] fatal: cannot bind 127.0.0.1:{args.port}: {e}", flush=True)
        return 1

    print(
        f"[bangs-mirror] serving {ROUTE} from {args.manifest} on "
        f"http://127.0.0.1:{args.port} (loopback only)",
        flush=True,
    )
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    return 0


if __name__ == "__main__":
    raise SystemExit(main())