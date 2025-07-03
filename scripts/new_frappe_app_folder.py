import argparse
from pathlib import Path


def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument('name')
    parser.add_argument('--root', type=Path, default=Path('app'))
    args = parser.parse_args(argv)

    app_root = args.root / args.name
    (app_root / 'config').mkdir(parents=True, exist_ok=True)
    (app_root / 'templates').mkdir(parents=True, exist_ok=True)
    (app_root / args.name).mkdir(parents=True, exist_ok=True)
    (app_root / 'patches.txt').write_text('')

    root = app_root.parent
    (root / 'pyproject.toml').write_text('[tool.poetry]\n')
    (root / 'README.md').write_text('# App')
    (root / 'license.txt').write_text('MIT')
    (root / '.gitignore').write_text('*.pyc\n')


if __name__ == '__main__':
    main()
