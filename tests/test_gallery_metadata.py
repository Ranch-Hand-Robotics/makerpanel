"""Exercise the actual gallery hook with isolated example directories."""

import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('gallery_hooks', ROOT / '.github/hooks.py')
hooks = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(hooks)


class GalleryMetadataTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.examples = self.root / 'examples'
        self.example = self.examples / 'sample'
        self.example.mkdir(parents=True)
        self.readme = self.example / 'README.md'
        for name, value in (
            ('EXAMPLES_DIR', self.examples),
            ('GALLERY_JSON_PATH', self.root / 'gallery.json'),
            ('EXAMPLE_OVERRIDES', {}),
        ):
            patcher = patch.object(hooks, name, value)
            patcher.start()
            self.addCleanup(patcher.stop)

    def write(self, text):
        self.readme.write_text(text, encoding='utf-8')

    def test_missing_and_plain_readmes_preserve_defaults(self):
        for text in (None, '# Sample\n\nOrdinary prose.\n---\nMore text.'):
            if text is not None:
                self.write(text)
            entry = hooks._build_example_entry('sample')
            self.assertEqual(entry['description'], 'Makerpanel example design.')

    def test_yaml_strings_multiline_and_dimensions_override_defaults(self):
        hooks.EXAMPLE_OVERRIDES['sample'] = {'title': 'Old', 'category': 'Tools'}
        self.write('---\ntitle: "New: title"\ndescription: >-\n'
                   '  First line\n  second line.\ncontributor: Maker\n'
                   'horizontalPitch: 12\nverticalUnits: 2.5\n---\n# Body')
        entry = hooks._build_example_entry('sample')
        self.assertEqual(entry['title'], 'New: title')
        self.assertEqual(entry['description'], 'First line second line.')
        self.assertEqual(entry['category'], 'Tools')
        self.assertEqual(entry['contributor'], 'Maker')
        self.assertEqual(entry['horizontalPitch'], 12)
        self.assertEqual(entry['verticalUnits'], 2.5)

    def test_bom_crlf_lowercase_readme_and_unrelated_keys(self):
        self.readme = self.example / 'readme.md'
        self.write('\ufeff---\r\ntitle: Sample\r\ncustom: [a, b]\r\n---\r\n')
        self.assertEqual(hooks._read_example_metadata('sample'), {'title': 'Sample'})

    def test_blank_null_and_empty_metadata_keep_fallbacks(self):
        hooks.EXAMPLE_OVERRIDES['sample'] = {'description': 'Existing'}
        for header in ('', 'description: null', 'description: "  "'):
            self.write(f'---\n{header}\n---\n')
            self.assertEqual(hooks._build_example_entry('sample')['description'],
                             'Existing')

    def test_invalid_metadata_fails_with_filename(self):
        for header in ('title: [bad', '- list', 'title: 123',
                       'description: false', 'category: [Tools]',
                       'contributor: {}', 'verticalUnits: true',
                       'horizontalPitch: "12"', 'verticalUnits: 0',
                       'horizontalPitch: -1', 'verticalUnits: .nan',
                       'verticalUnits: .inf', '!!python/object:unsafe {}'):
            with self.subTest(header=header):
                self.write(f'---\n{header}\n---\n')
                with self.assertRaisesRegex(ValueError, 'README.md'):
                    hooks._build_example_entry('sample')
        self.write('---\ntitle: missing end')
        with self.assertRaisesRegex(ValueError, 'closing front matter'):
            hooks._build_example_entry('sample')

    def test_sync_is_idempotent_preserves_uploads_and_non_examples(self):
        self.write('---\ndescription: Useful description\n---\n')
        payload = {'version': 1, 'panels': [
            {'slug': 'sample', 'thumbnail': 'images/upload.png'},
            {'slug': 'community', 'title': 'Community', 'description': 'Keep me'},
        ]}
        hooks.GALLERY_JSON_PATH.write_text(json.dumps(payload), encoding='utf-8')
        hooks.sync_examples_into_gallery_json()
        first = hooks.GALLERY_JSON_PATH.read_bytes()
        hooks.sync_examples_into_gallery_json()
        self.assertEqual(hooks.GALLERY_JSON_PATH.read_bytes(), first)
        entries = {p['slug']: p for p in json.loads(first)['panels']}
        self.assertEqual(entries['sample']['description'], 'Useful description')
        self.assertEqual(entries['sample']['thumbnail'], 'images/upload.png')
        self.assertEqual(entries['community'], payload['panels'][1])
        self.write('---\ndescription: Updated description\n---\n')
        hooks.sync_examples_into_gallery_json()
        self.assertIn('Updated description',
                      hooks.GALLERY_JSON_PATH.read_text(encoding='utf-8'))

    def test_readme_leaves_scad_dimension_discovery_enabled(self):
        scad = self.example / 'sample.scad'
        scad.write_text('horizontalPitch = 12;\nverticalUnits = 3;', encoding='utf-8')
        self.write('---\ntitle: Sample panel\n---\n')
        with patch.object(hooks, '_find_scad_url', return_value=str(scad)):
            entry = hooks._build_example_entry('sample')
        self.assertEqual(entry['horizontalPitch'], 12)
        self.assertEqual(entry['verticalUnits'], 3)

    def test_parts_follow_primary_dropdown_not_metadata_or_helpers(self):
        scad = self.example / 'sample.scad'
        helper = self.example / 'helper.scad'
        helper.write_text('part = "helper"; // [helper]\n', encoding='utf-8')
        self.write('---\nscadParts: [stale]\nmountingPart: wrong\n---\n')
        hooks.EXAMPLE_OVERRIDES['sample'] = {
            'scadFile': str(scad), 'scadParts': ['stale'],
        }
        scad.write_text(
            '// part = "wrong"; // [wrong]\n'
            '/*\npart = "wrong"; // [wrong]\n*/\n'
            'part = "assembly"; // [assembly: Preview, '
            'makerpanel: Mounting panel, panel_2d, makerpanel]\n',
            encoding='utf-8',
        )
        entry = hooks._build_example_entry('sample')
        self.assertEqual(entry['scadParts'],
                         ['assembly', 'makerpanel', 'panel_2d'])
        self.assertNotIn('mountingPart', entry)
        scad.write_text('part = "makerpanel"; // [makerpanel]\n',
                        encoding='utf-8')
        updated = hooks._build_example_entry('sample', entry)
        self.assertEqual(updated['scadParts'], ['makerpanel'])
        scad.write_text('cube(1);\n', encoding='utf-8')
        self.assertNotIn('scadParts', hooks._build_example_entry('sample', updated))

    def test_literal_part_arrays(self):
        scad = self.example / 'sample.scad'
        hooks.EXAMPLE_OVERRIDES['sample'] = {'scadFile': str(scad)}
        for name in ('part', 'parts'):
            with self.subTest(name=name):
                scad.write_text(
                    f'{name} = [\n"assembly", // Preview\n'
                    '"makerpanel", /* Mount */ "assembly"\n];\n',
                    encoding='utf-8',
                )
                self.assertEqual(hooks._build_example_entry('sample')['scadParts'],
                                 ['assembly', 'makerpanel'])

    def test_missing_or_unsupported_selectors_do_not_invent_parts(self):
        scad = self.example / 'sample.scad'
        hooks.EXAMPLE_OVERRIDES['sample'] = {'scadFile': str(scad)}
        self.assertNotIn('scadParts', hooks._build_example_entry('sample'))
        for source in ('cube(1);', 'part = "assembly";',
                       'parts = [some_variable];', 'parts = [1, 2];',
                       'parts = [];', '// parts = ["wrong"];'):
            with self.subTest(source=source):
                scad.write_text(source, encoding='utf-8')
                self.assertNotIn('scadParts', hooks._build_example_entry('sample'))


class BuiltInCatalogPartsTests(unittest.TestCase):
    def test_actual_catalog_parts_and_idempotence(self):
        previous_cwd = Path.cwd()
        self.addCleanup(os.chdir, previous_cwd)
        os.chdir(ROOT)
        with tempfile.TemporaryDirectory() as directory, \
             patch.object(hooks, 'EXAMPLES_DIR', ROOT / 'examples'), \
             patch.object(hooks, 'GALLERY_JSON_PATH',
                          Path(directory) / 'gallery.json'), \
             patch.object(hooks, '_iso_now', return_value='2026-01-01T00:00:00Z'):
            hooks.sync_examples_into_gallery_json()
            first = hooks.GALLERY_JSON_PATH.read_bytes()
            entries = {p['slug']: p for p in json.loads(first)['panels']}
            mounting_samples = {
                'Antenna', 'iris_keyboard', 'joystick',
                'lilygo_screen_4_7_s3', 'lilygo_t-encoder-pro', 'measure',
                'monitor_panel', 'mouse_panel', 'prime79_panel', 'rail_panel',
                'power_panel',
                'streamdeck_panel', 'switch_panel', 'trackball_panel', 'vent_panel',
            }
            self.assertEqual(set(entries), mounting_samples | {'keyboard'})
            for slug in mounting_samples:
                with self.subTest(slug=slug):
                    self.assertIn('makerpanel', entries[slug]['scadParts'])
                    self.assertNotIn('mountingPart', entries[slug])
            self.assertNotIn('makerpanel', entries['keyboard']['scadParts'])
            self.assertIn('mx_switch_3d', entries['keyboard']['scadParts'])
            self.assertIn('assembly', entries['monitor_panel']['scadParts'])
            power = entries['power_panel']
            self.assertEqual(power['category'], 'Power')
            self.assertEqual(power['horizontalPitch'], 20)
            self.assertEqual(power['verticalUnits'], 1)
            self.assertEqual(power['scadFile'],
                             'examples/power_panel/PowerPanel.scad')
            self.assertEqual(power['scadParts'], ['makerpanel', 'panel_2d'])
            encoder = entries['lilygo_t-encoder-pro']
            self.assertEqual(encoder['scadFile'],
                             'examples/lilygo_t-encoder-pro/design/'
                             'lilygo_t-encoder-pro.scad')
            self.assertTrue((ROOT / encoder['scadFile']).is_file())
            with patch.object(hooks, '_iso_now',
                              return_value='2026-01-02T00:00:00Z'):
                hooks.sync_examples_into_gallery_json()
            self.assertEqual(hooks.GALLERY_JSON_PATH.read_bytes(), first)


class BuiltInPanelDefaultsTests(unittest.TestCase):
    def test_mouse_and_vent_heights_follow_scad(self):
        for slug in ('mouse_panel', 'vent_panel'):
            with self.subTest(slug=slug):
                override = hooks.EXAMPLE_OVERRIDES[slug]
                self.assertNotIn('verticalUnits', override)
                absolute_override = {
                    **override,
                    'scadFile': str(ROOT / override['scadFile']),
                }
                with patch.object(hooks, 'EXAMPLES_DIR', ROOT / 'examples'), \
                     patch.dict(hooks.EXAMPLE_OVERRIDES,
                                {slug: absolute_override}):
                    entry = hooks._build_example_entry(slug)
                    self.assertEqual(entry['verticalUnits'], 4)
                    with patch.object(hooks, '_find_scad_dimensions',
                                      return_value=(35, 6)):
                        updated = hooks._build_example_entry(slug)
                    self.assertEqual(updated['verticalUnits'], 6)


if __name__ == '__main__':
    unittest.main()