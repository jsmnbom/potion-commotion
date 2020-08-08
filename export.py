# requires:
# python libs: sh, click
# git
# godot
# wine + rcedit

# pylint: disable=no-name-in-module
from sh import git
# pylint: disable=no-name-in-module
from sh import godot
# pylint: disable=no-name-in-module
from sh import wine
# pylint: disable=no-name-in-module
from sh import whereis
import click

from pathlib import Path
from shutil import copyfile, make_archive
from zipfile import ZipFile

export_dir = Path('exports')
game_file_name = 'PotionCommotion-HeartEdition'
game_pretty_name = 'Potion Commotion - Heart Edition'
platforms = [('Windows Desktop 64', 'windows64'), ('Linux/X11 64', 'linux64'),
             ('Windows Desktop 32', 'windows32'), ('Linux/X11 32', 'linux32')]
windows_icon = Path('assets/icon.ico')
legal_copyright = 'Copyright Jasmin Bom 2020'
info = 'https://jsmnbom.itch.io/potion-commotion'


def main():
    version_file = Path('VERSION')
    version = str(git.describe('--tags')).strip()
    short_version = version.rsplit('-', maxsplit=1)[0]
    print(f'Version: {version} ({short_version})')

    with version_file.open('w') as f:
        f.write(version)
    print('VERSION file created')

    global export_dir
    export_dir = export_dir / version
    export_dir.mkdir(exist_ok=True)
    print(f'Export directory: {export_dir}')

    for platform, short_platform in platforms:
        file_name = f'{game_file_name}-{short_platform}-{short_version}'
        platform_export_dir = export_dir / file_name
        platform_export_dir.mkdir(exist_ok=True)

        export_path = platform_export_dir / file_name
        if 'windows' in short_platform:
            export_path = export_path.parent / (export_path.name + '.exe')

        print(f'Exporting {platform} to {export_path}')
        godot('--export', platform, export_path)

        license_file = Path(__file__).parent / 'LICENSE'
        copyfile(license_file, Path(platform_export_dir) / 'LICENSE')

        if 'windows' in short_platform:
            _, _, rcedit = whereis('rcedit-x64.exe' if '64' in short_platform
                                   else 'rcedit-x86.exe').partition(':')
            rcedit = rcedit.strip()
            print(f'Using rcedit at {rcedit}')
            commands = [
                ['--set-icon', windows_icon],
                ['--set-file-version', short_version[1:]],
                ['--set-product-version', short_version[1:]],
                ['--set-version-string', 'CompanyName', game_pretty_name],
                ['--set-version-string', 'ProductName', game_pretty_name],
                ['--set-version-string', 'Info', info],
                ['--set-version-string', 'FileDescription', game_pretty_name],
                ['--set-version-string', 'OriginalFilename', export_path.name],
                ['--set-version-string', 'LegalCopyright', legal_copyright]
            ]
            for command in commands:
                wine(rcedit, export_path, *command)

        archive_path = export_dir / (file_name + '.zip')
        print(f'Archiving to {archive_path}')
        make_archive(archive_path.with_suffix(''), 'zip', platform_export_dir)

        with ZipFile(archive_path, 'r') as f:
            print('Files in archive:', f.namelist())

    version_file.unlink()


if __name__ == '__main__':
    main()
