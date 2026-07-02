from textual.app import App, ComposeResult
from textual.containers import Container, Horizontal, Vertical
from textual.widgets import Header, Footer, Static, ProgressBar, Log, Label
from textual.reactive import reactive
import asyncio

from .runner import SwiftRunner

class ReMasteraApp(App):
    """A Textual app for ReMastera Video Processing."""
    
    CSS = """
    Screen {
        background: $surface-darken-1;
        layout: vertical;
    }
    
    #dashboard {
        height: auto;
        margin: 1;
        padding: 1;
        border: round $accent;
        background: $surface;
    }
    
    #status-container {
        height: auto;
        padding: 1;
    }
    
    #progress-bar {
        margin-top: 1;
    }
    
    #log-view {
        border: panel $primary;
        margin: 1;
        height: 1fr;
    }
    
    .amber {
        color: #ffbf00;
    }
    
    .title {
        text-style: bold;
        color: #ffbf00;
    }
    """
    
    BINDINGS = [
        ("q", "quit", "Quit"),
    ]
    
    def __init__(self, source: str, destination: str, preset: str,
                 denoise: bool, film_look: bool, subtitles: bool, upscale: bool, hdr10: bool, bin_path: str):
        super().__init__()
        self.runner = SwiftRunner(bin_path, source, destination, preset, denoise, film_look, subtitles, upscale, hdr10)
        self.source = source
        self.preset = preset
        self.tags = [t for t, enabled in [("Denoise", denoise), ("FilmLook", film_look), 
                                         ("Subtitles", subtitles), ("Upscale", upscale), 
                                         ("HDR10", hdr10)] if enabled]
                                         
    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)
        
        with Container(id="dashboard"):
            yield Label("🎬 [bold #ffbf00]ReMastera Processing Dashboard[/]", classes="title")
            yield Label(f"Source: [white]{self.source}[/]")
            yield Label(f"Preset: [cyan]{self.preset}[/]")
            yield Label(f"Active Tags: [green]{', '.join(self.tags) if self.tags else 'None'}[/]")
            
        with Container(id="status-container"):
            self.stage_label = Label("Stage: [dim]Initializing...[/]")
            yield self.stage_label
            self.progress = ProgressBar(total=1.0, show_eta=False, id="progress-bar")
            yield self.progress
            
        self.log_widget = Log(id="log-view", highlight=True)
        yield self.log_widget
        
        yield Footer()

    async def on_mount(self) -> None:
        self.log_widget.write_line("[bold #ffbf00]ReMastera[/] Offline Video Processor Started.")
        self.run_worker(self.process_video(), exclusive=True)
        
    async def process_video(self) -> None:
        try:
            async for data in self.runner.run():
                if "error" in data:
                    self.log_widget.write_line(f"[bold red]Error:[/] {data['error']}")
                    self.stage_label.update("Stage: [bold red]Failed[/]")
                    continue
                    
                if "log" in data:
                    self.log_widget.write_line(f"[dim]{data['log']}[/]")
                    continue
                    
                # Parse JobData struct JSON
                status = data.get("status", "queued")
                stage = data.get("currentStage", "Processing...")
                progress_val = data.get("progress", 0.0)
                logs = data.get("logs", [])
                
                # Update UI safely
                self.call_from_thread(self.update_ui, status, stage, progress_val)
                
                # If there are logs, write the latest ones
                # (Since Swift sends all logs, we should only write new ones, but for simplicity
                # we'll just write the last one if we want, or rely on Swift's stdout printing.
                # Since Swift's Job object contains all logs, the array grows.)
                
        except Exception as e:
            self.log_widget.write_line(f"[bold red]Exception:[/] {str(e)}")
            
    def update_ui(self, status: str, stage: str, progress_val: float) -> None:
        color = "white"
        if status == "completed":
            color = "green"
            self.progress.advance(1.0 - self.progress.progress)
        elif status == "failed":
            color = "red"
        elif status == "processing":
            color = "cyan"
            self.progress.update(progress=progress_val)
            
        self.stage_label.update(f"Stage: [bold {color}]{stage}[/]")
