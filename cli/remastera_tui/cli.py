import typer
import os
import sys
from pathlib import Path
from .app import ReMasteraApp

app = typer.Typer(help="ReMastera CLI - Interactive Media Processing Suite")

@app.command()
def process(
    source: str = typer.Argument(..., help="Source video file"),
    destination: str = typer.Argument(..., help="Destination directory or file"),
    preset: str = typer.Option("Balanced 4K", help="Preset (e.g., 'Balanced 4K', 'Fast Preview')"),
    denoise: bool = typer.Option(False, "--denoise", help="Enable denoise filter"),
    film_look: bool = typer.Option(False, "--film-look", help="Enable Kodak film look"),
    subtitles: bool = typer.Option(False, "--subtitles", help="Extract subtitles"),
    upscale: bool = typer.Option(False, "--upscale", help="Upscale to 4K"),
    hdr10: bool = typer.Option(False, "--hdr10", help="Enable HDR10 tagging"),
    bin_path: str = typer.Option(
        None, 
        "--bin-path", 
        help="Path to ReMasteraCLI binary. If not provided, it looks in .build/release/ReMasteraCLI"
    )
):
    """
    Launch the immersive ReMastera TUI for video processing.
    """
    if bin_path is None:
        # Default to standard swift build output path relative to repo root
        # Find repo root assuming this is run from within the repo
        current = Path.cwd()
        bin_path = str(current / ".build" / "release" / "ReMasteraCLI")
        if not os.path.exists(bin_path):
            bin_path = str(current / ".build" / "debug" / "ReMasteraCLI")
            
    if not os.path.exists(bin_path):
        typer.echo(f"Error: ReMasteraCLI binary not found at {bin_path}", err=True)
        typer.echo("Run ./scripts/install-cli.sh to build the Swift binary.", err=True)
        raise typer.Exit(1)
        
    tui_app = ReMasteraApp(
        source=source,
        destination=destination,
        preset=preset,
        denoise=denoise,
        film_look=film_look,
        subtitles=subtitles,
        upscale=upscale,
        hdr10=hdr10,
        bin_path=bin_path
    )
    tui_app.run()

if __name__ == "__main__":
    app()
