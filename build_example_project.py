"""Build the downloadable example project archive for the project-setup page.

Zips the `my_project/` source folder into `my_project.zip`, adding the empty
`output/` and `figures/` folders so the unzipped project matches the folder
structure shown on the page. Run from the repo root:

    python build_example_project.py

The resulting `my_project.zip` is served by Quarto (listed under
`resources` in `_quarto.yml`) and linked from `topics/project-setup.qmd`.
"""

import os
import zipfile

SRC = "my_project"
OUT = "my_project.zip"
EXCLUDE_NAMES = {".gitkeep", ".DS_Store", "Thumbs.db"}
EMPTY_DIRS = ["output", "figures"]


def main():
    if os.path.exists(OUT):
        os.remove(OUT)

    with zipfile.ZipFile(OUT, "w", zipfile.ZIP_DEFLATED) as zf:
        for root, _dirs, files in os.walk(SRC):
            for name in files:
                if name in EXCLUDE_NAMES:
                    continue
                full = os.path.join(root, name)
                arc = os.path.relpath(full, ".").replace(os.sep, "/")
                zf.write(full, arc)
        # Ship empty output/ and figures/ folders so the structure is complete.
        for d in EMPTY_DIRS:
            zf.writestr(zipfile.ZipInfo(f"{SRC}/{d}/"), "")

    with zipfile.ZipFile(OUT) as zf:
        print(f"Wrote {OUT} with:")
        for n in sorted(zf.namelist()):
            print("  " + n)


if __name__ == "__main__":
    main()
