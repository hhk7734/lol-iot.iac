from pathlib import Path

import pulumi

BASE_DIR = Path(__file__).resolve().parent

chart_dir = BASE_DIR.parent.parent.parent.parent.parent / "charts"

stack_name = pulumi.get_stack()

config = pulumi.Config()
