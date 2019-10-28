# requires:
# python libs: sh, click
# git
# godot
# butler

from sh import git
from sh import godot
from sh import butler
import click

from pathlib import Path
from shutil import copyfile, make_archive
from zipfile import ZipFile

itch_io_project = 'jsmnbom/potion-commotion'
game_name = ['PotionCommotion', 'HeartEdition']
platforms = [('Windows Desktop', 'windows'), ('Linux/X11', 'linux')]

def main():
    print('fetching version')
    version = str(git.describe('--tags')).strip()
    short_version = version.rsplit('-', maxsplit=1)[0]
    print('new version: {} ({})'.format(version, short_version))
    with open('VERSION', 'w') as f:
        f.write(version)
    print('VERSION updated')
    export_dir = Path(__file__).resolve().parent.parent / 'exports' / version
    export_dir.mkdir(exist_ok=True)
    print('export directory: {}'.format(export_dir))

    for platform, short_platform in platforms:
        platform_export_dir = export_dir / '-'.join(game_name + [short_platform, short_version])
        platform_export_dir.mkdir(exist_ok=True)
        export_path = platform_export_dir / '-'.join(game_name)
        if short_platform == 'windows':
            export_path = export_path.with_suffix('.exe')
        print('exporting {} to {}'.format(platform, export_path))
        godot('--export', platform, export_path)

        copyfile(Path(__file__).parent / 'LICENSE', Path(platform_export_dir) / 'LICENSE')

        archive_path = export_dir / ('-'.join(game_name + [short_platform, short_version]) + '.zip')
        print('archiving to {}'.format(archive_path))
        make_archive(archive_path.with_suffix(''), 'zip', platform_export_dir)

        with ZipFile(archive_path, 'r') as f:
            print(f.namelist())
    
    # if click.confirm('Upload to itch.io?', default=False):
    #     for _, short_platform in platforms:
    #         archive_path = export_dir / ('-'.join(game_name + [short_platform, short_version]) + '.zip')
    #         channel = '{}:{}'.format(itch_io_project, short_platform)
    #         print('uploading {} to itch.io {} with version {}'.format(archive_path, channel, short_version[1:]))
    #         butler.push(archive_path, channel, '--userversion', short_version[1:])

if __name__ == '__main__':
    main()
