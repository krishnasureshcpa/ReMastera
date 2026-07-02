import asyncio
import json
import subprocess
from typing import AsyncGenerator, Dict, Any

class SwiftRunner:
    def __init__(self, bin_path: str, source: str, destination: str, preset: str,
                 denoise: bool, film_look: bool, subtitles: bool, upscale: bool, hdr10: bool):
        self.bin_path = bin_path
        self.source = source
        self.destination = destination
        self.preset = preset
        self.denoise = denoise
        self.film_look = film_look
        self.subtitles = subtitles
        self.upscale = upscale
        self.hdr10 = hdr10

    async def run(self) -> AsyncGenerator[Dict[str, Any], None]:
        cmd = [
            self.bin_path,
            self.source,
            self.destination,
            "--preset", self.preset
        ]
        
        if self.denoise: cmd.append("--denoise")
        if self.film_look: cmd.append("--film-look")
        if self.subtitles: cmd.append("--subtitles")
        if self.upscale: cmd.append("--upscale")
        if self.hdr10: cmd.append("--hdr10")
        
        process = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        
        assert process.stdout is not None
        
        while True:
            line = await process.stdout.readline()
            if not line:
                break
                
            line_str = line.decode('utf-8').strip()
            if not line_str:
                continue
                
            try:
                data = json.loads(line_str)
                yield data
            except json.JSONDecodeError:
                # If Swift prints something that is not JSON, we can pass it as a log message
                yield {"log": line_str}
                
        await process.wait()
        
        if process.returncode != 0:
            assert process.stderr is not None
            err = await process.stderr.read()
            yield {"error": err.decode('utf-8')}
